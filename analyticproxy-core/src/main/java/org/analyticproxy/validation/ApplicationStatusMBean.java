package org.analyticproxy.validation;

public interface ApplicationStatusMBean {

	int getActiveCount();
	long getCompletedTaskCount();
	int getWaitingCount(); 
	void startSession(String sessionId);
	void endSession(String sessionId);
}
