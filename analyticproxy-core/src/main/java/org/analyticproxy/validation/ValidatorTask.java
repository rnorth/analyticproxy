/**
 * 
 */
package org.analyticproxy.validation;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.net.URI;
import java.net.URISyntaxException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;

import org.analyticproxy.validation.ContentStore.ContentNature;
import org.apache.http.HttpResponse;
import org.apache.http.NameValuePair;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.HttpClient;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.message.BasicNameValuePair;
import org.apache.http.params.BasicHttpParams;
import org.apache.http.params.HttpParams;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.google.common.collect.Lists;
import com.google.common.collect.Maps;
import com.google.common.io.ByteStreams;

/**
 * @author richardnorth
 * 
 */
public class ValidatorTask implements Runnable {

	private static final Logger logger = LoggerFactory.getLogger(ValidatorTask.class);

	private final URI uri;
	private final Integer responseCode;
	private final Map<String, String> requestHeaders;
	private final Map<String, String> responseHeaders;
	private final String responseBody;

	private static final List<String> supportedContentTypes = Lists.newArrayList("text/html", "application/xhtml+xml", "text/css",
			"application/xml", "text/xml");

	private static final Map<String, String> contentTypeValidationType = Maps.newHashMap();

	private final ContentStore contentStore;
	static {
		contentTypeValidationType.put("text/html", "markup-validator");
		contentTypeValidationType.put("application/xhtml+xml", "markup-validator");
		contentTypeValidationType.put("text/css", "css-validator");
		contentTypeValidationType.put("application/xml", "markup-validator");
		contentTypeValidationType.put("text/xml", "markup-validator");
	}

	public ValidatorTask(URI uri, Integer responseCode, Map<String, String> requestHeaders, Map<String, String> responseHeaders,
			String responseBody, ContentStore contentStore) {

		this.uri = uri;
		this.responseCode = responseCode;
		this.requestHeaders = requestHeaders;
		this.responseHeaders = responseHeaders;
		this.responseBody = responseBody;
		this.contentStore = contentStore;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see java.lang.Runnable#run()
	 */
	public void run() {

		if (!isSupportedContentType(responseHeaders)) {
			logger.debug("Not processing unsupported content type");
			return;
		}

		logger.debug("uri.getHost() + \"/\" + uri.getPath() = " + uri.getHost() + "/" + uri.getPath());

		if (contentStore.hasExistingContentForUri(uri)) {
			logger.info("Content already captured for {} - not going to store or validate", uri);
			return;
		}

		// Store the witnessed content
		try {
			saveContent(ContentNature.RAW, responseBody);
		} catch (IOException e) {
			logger.error("Problem saving raw content - aborting", e);
			return;
		}
		logger.debug("Stored witnessed content");

		// Submit content to validator
		String validationResultsPage;
		try {
			validationResultsPage = submitToValidator();
		} catch (ClientProtocolException e) {
			logger.error("Problem performing validation - aborting", e);
			return;
		} catch (IOException e) {
			logger.error("Problem performing validation - aborting", e);
			return;
		}
		logger.debug("Validation results obtained");

		// Save validation results
		try {
			validationResultsPage = validationResultsPage.replaceAll("href=\\\"\\.\\/", "href=\"http://validator.w3.org/unicorn/");
			validationResultsPage = validationResultsPage.replaceAll("src=\\\"\\.\\/", "src=\"http://validator.w3.org/unicorn/");
			saveContent(ContentNature.VALIDATED, validationResultsPage);
		} catch (IOException e) {
			logger.error("Problem saving validated content - aborting", e);
			return;
		}
		logger.debug("Validation results saved");

	}

	private boolean isSupportedContentType(Map<String, String> responseHeaders2) {
		return getSupportedContentType(responseHeaders2) != null;
	}

	private String getSupportedContentType(Map<String, String> responseHeaders2) {
		for (Entry<String, String> e : responseHeaders2.entrySet()) {
			if (e.getKey().equals("Content-Type")) {

				logger.debug("Got content type={}", e.getValue());

				for (String supportedType : supportedContentTypes) {
					if (e.getValue().startsWith(supportedType)) {
						return supportedType;
					}
				}
			}
		}

		return null;
	}

	private String submitToValidator() throws IOException, ClientProtocolException {

		final String contentType = contentTypeValidationType.get(getSupportedContentType(responseHeaders));

		HttpPost post = new HttpPost(ConfigurationProvider.getSetting("unicornServerURI"));
		List<NameValuePair> formparams = new ArrayList<NameValuePair>();
		formparams.add(new BasicNameValuePair("ucn_text", responseBody));
		formparams.add(new BasicNameValuePair("ucn_text_mime", getSupportedContentType(responseHeaders)));
		formparams.add(new BasicNameValuePair("doctype", "inline"));
		formparams.add(new BasicNameValuePair("charset", "(detect automatically)"));
		formparams.add(new BasicNameValuePair("ucn_task", "custom"));
		formparams.add(new BasicNameValuePair("tests", contentType));
		UrlEncodedFormEntity entity = new UrlEncodedFormEntity(formparams, "UTF-8");
		post.setEntity(entity);

		HttpClient client = new DefaultHttpClient();
		HttpResponse httpResponse = client.execute(post);

		logger.debug("HTTP response code was {}", httpResponse.getStatusLine());
		if (httpResponse.getStatusLine().getStatusCode() != 200) {
			throw new IOException("Unexpected status code received!");
		}

		InputStream content = httpResponse.getEntity().getContent();

		ByteArrayOutputStream baos = new ByteArrayOutputStream();
		ByteStreams.copy(content, baos);
		return baos.toString();
	}

	private void saveContent(ContentNature nature, String contentToSave) throws IOException {
	
		contentStore.save(nature, uri, contentToSave);
	}

}
