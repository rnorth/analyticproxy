package org.analyticproxy.validation;

import java.net.URI;
import java.util.Map;

public interface ResponseObserver {

	void notify(URI uri, Integer responseCode,
			Map<String, String> requestHeaders,
			Map<String, String> responseHeaders, String responseBody);
}
