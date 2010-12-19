/**
 * 
 */
package org.analyticproxy.validation;

import java.net.URI;
import java.util.Map;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.ThreadPoolExecutor;
import java.util.concurrent.TimeUnit;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * @author richardnorth
 *
 */
public class ValidationResponseObserver implements ResponseObserver {

	private static ThreadPoolExecutor executor = new ThreadPoolExecutor(1, 5, 5, TimeUnit.SECONDS, new LinkedBlockingQueue<Runnable>());
	private static final Logger logger = LoggerFactory.getLogger(ValidationResponseObserver.class);
	
	
	/* (non-Javadoc)
	 * @see org.analyticproxy.observer.ResponseObserver#notify(java.net.URI, java.lang.Integer, java.util.Map, java.util.Map, java.lang.String)
	 */
	public void notify(URI uri, Integer responseCode,
			Map<String, String> requestHeaders,
			Map<String, String> responseHeaders, String responseBody) {
		
		ValidatorTask validatorTask = new ValidatorTask(uri, responseCode, requestHeaders, responseHeaders, responseBody);
		executor.execute(validatorTask);
		
		logger.info("New task enqueued for URI {}", uri);
		logger.info("Executor size: " + executor.getActiveCount());
	}

	public boolean isExecutionQuiet() {
		return executor.getActiveCount() == 0;
	}
}
