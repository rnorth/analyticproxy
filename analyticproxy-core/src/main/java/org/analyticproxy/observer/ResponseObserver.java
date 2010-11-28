/**
 * 
 */
package org.analyticproxy.observer;

import java.net.URL;

import org.apache.commons.httpclient.Header;

/**
 * @author richardnorth
 *
 */
public interface ResponseObserver {

	void notify(URL requestURL, Integer responseCode, Header[] requestHeaders, Header[] responseHeaders, String responseBody);
}
