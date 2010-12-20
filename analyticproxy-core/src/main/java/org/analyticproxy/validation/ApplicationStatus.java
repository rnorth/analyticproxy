/**
 * 
 */
package org.analyticproxy.validation;

import java.util.concurrent.ThreadPoolExecutor;

/**
 * @author richardnorth
 *
 */
public class ApplicationStatus implements ApplicationStatusMBean {

	private final ThreadPoolExecutor executor;

	public ApplicationStatus() {
		this.executor = ValidationResponseObserver.executor;
	}

	public int getActiveCount() {
		return executor.getActiveCount();
	}

	public long getCompletedTaskCount() {
		return executor.getCompletedTaskCount();
	}

	public int getWaitingCount() {
		return executor.getQueue().size();
	}
	
	public void startSession(String sessionId) {
		ValidationResponseObserver.activeSessionIdentifiers.add(sessionId);
	}
	
	public void endSession(String sessionId) {
		
		synchronized (ValidationResponseObserver.activeSessionIdentifiers) {
			if (ValidationResponseObserver.activeSessionIdentifiers.peek().equals(sessionId)) {
				ValidationResponseObserver.activeSessionIdentifiers.pop();
			} else {
				throw new IllegalArgumentException("Session ID " + sessionId + " is not the topmost entry in the stack");
			}
		}
		
		
	}
	
}
