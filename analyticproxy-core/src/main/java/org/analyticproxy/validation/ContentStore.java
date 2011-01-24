package org.analyticproxy.validation;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.net.URI;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class ContentStore {

	
	private static final String BASEPATH = "BASEPATH";
	private final String sessionId;
	private static final Logger logger = LoggerFactory.getLogger(ContentStore.class);

	public ContentStore(String sessionId) {
		this.sessionId = sessionId;
	}

	public boolean hasExistingContentForUri(URI uri) {
		return (calculateFileForURI(uri, ContentNature.RAW)).exists();
	}
	
	private File calculateFileForURI(URI uri, ContentNature nature) {

		String path = uri.getPath();
		if (path==null || path.equals("/")) {
			logger.debug("Resource has no path component - using {}", BASEPATH);
			path = BASEPATH;
		}
		
		File f = new File(ConfigurationProvider.getSetting("contentStoreBase") + 
					File.separator + sessionId + 
						File.separator + nature.folderName +
							File.separator + uri.getHost() +
								File.separator + path + nature.suffix);
		
		logger.debug("Calculating file path for uri [{}] -> [{}]", uri, f);
		
		return f;
	}

	public void save(ContentNature nature, URI uri, String contentToSave) {
		
		final File outputFile = calculateFileForURI(uri, nature);
		outputFile.getParentFile().mkdirs();
		
		FileWriter fw = null;
		try {
			fw = new FileWriter(outputFile);
			fw.write(contentToSave);
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} finally {
			if (fw != null) {
				try {
					fw.close();
				} catch (IOException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
			}
		}
	}

	public enum ContentNature {
		RAW("raw", ""), VALIDATED("validated", "-validated.html");
		
		private final String folderName;
		private final String suffix;

		private ContentNature(String folderName, String suffix) {
			this.folderName = folderName;
			this.suffix = suffix;
		}
	}

	
}
