package org.analyticproxy.validation;

import java.io.IOException;
import java.net.URI;
import java.util.Map;

import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamSource;

import org.analyticproxy.observer.ResponseObserver;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.w3c.dom.Document;
import org.w3c.dom.Node;
import org.xml.sax.SAXException;

public class ValidationResponseObserver implements ResponseObserver {

	private static final String CONTENT_TYPE = "Content-Type";
	private static final Logger logger = LoggerFactory.getLogger(ValidationResponseObserver.class);
	
	public void notify(URI uri, Integer responseCode,
			Map<String, String> requestHeaders,
			Map<String, String> responseHeaders, String responseBody) {
		// TODO Auto-generated method stub
		
		final String contentType = responseHeaders.get(CONTENT_TYPE);
		
		if (contentType.startsWith("text/html") && responseBody != null) {
			logger.info(uri.toString());
			logger.info(CONTENT_TYPE + ": " + contentType);
			validateContent(responseBody);
		}
	}

	private void validateContent(String responseBody) {
		try {
			//logger.info("Transforming document: " + responseBody);
			
			Document document = new ContentParser().parseHtml(responseBody);
			String transformedDocument = new XslTransformer("src/main/resources/wcag.xsl").transform(document);
			
			logger.info(transformedDocument);
			
		} catch (SAXException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (TransformerConfigurationException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

}
