/**
 * 
 */
package org.analyticproxy.validation;


/**
 * @author richardnorth
 *
 */
public class XslTransformException extends RuntimeException {

	/**
	 * 
	 */
	private static final long serialVersionUID = -8885358878736839839L;

	public XslTransformException(String string, Exception e) {
		super(string, e);
	}

}
