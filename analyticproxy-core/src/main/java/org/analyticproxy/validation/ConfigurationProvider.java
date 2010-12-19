/**
 * 
 */
package org.analyticproxy.validation;

import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException;

/**
 * @author richardnorth
 *
 */
public class ConfigurationProvider {

	private static Context environmentContext;

	public static String getSetting(String keyName) {
		try {
			return (String) getEnvironmentContext().lookup(keyName);
		} catch (NamingException e) {
			throw new RuntimeException("Failed to lookup configuration setting", e);
		}
	}

	private static synchronized Context getEnvironmentContext() throws NamingException {
		if (environmentContext==null) {
			Context initialContext = new InitialContext();
			environmentContext = (Context) initialContext.lookup("java:comp/env");
		}
		
		return environmentContext;
	}
}
