/**
 * 
 */
package org.analyticproxy.validation;

import java.io.File;
import java.lang.management.ManagementFactory;
import java.net.URI;
import java.util.Map;
import java.util.Stack;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.ThreadPoolExecutor;
import java.util.concurrent.TimeUnit;

import javax.management.InstanceAlreadyExistsException;
import javax.management.MBeanRegistrationException;
import javax.management.MBeanServer;
import javax.management.MalformedObjectNameException;
import javax.management.NotCompliantMBeanException;
import javax.management.ObjectName;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * @author richardnorth
 * 
 */
public class ValidationResponseObserver implements ResponseObserver {

	static ThreadPoolExecutor executor = new ThreadPoolExecutor(1, 5, 5, TimeUnit.SECONDS, new LinkedBlockingQueue<Runnable>());
	static Stack<String> activeSessionIdentifiers = new Stack<String>();
	static {
		try {
			ApplicationStatus statusBean = new ApplicationStatus();
			MBeanServer beanServer = ManagementFactory.getPlatformMBeanServer();
			ObjectName name = new ObjectName("org.analyticproxy.validation:type=ApplicationStatus");
			beanServer.registerMBean(statusBean, name);
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

	private static final Logger logger = LoggerFactory.getLogger(ValidationResponseObserver.class);

	/*
	 * (non-Javadoc)
	 * 
	 * @see org.analyticproxy.observer.ResponseObserver#notify(java.net.URI,
	 * java.lang.Integer, java.util.Map, java.util.Map, java.lang.String)
	 */
	public void notify(URI uri, Integer responseCode, Map<String, String> requestHeaders, Map<String, String> responseHeaders,
			String responseBody) {
		
		final ContentStore contentStore = new ContentStore(getCurrentSessionId());
		ValidatorTask validatorTask = new ValidatorTask(uri, responseCode, requestHeaders, responseHeaders, responseBody, contentStore);
		executor.execute(validatorTask);

		logger.info("New task enqueued for URI {}, to be stored under {}", uri, contentStore);
	}

	private String getCurrentSessionId() {
		
		if (activeSessionIdentifiers.size()==0) {
			return "initialSession";
		}
		
		return activeSessionIdentifiers.peek();
	}

	public boolean isExecutionQuiet() {
		return executor.getActiveCount() == 0;
	}
}
