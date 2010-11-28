/**
 * 
 */
package org.analyticproxy.validation;

import java.io.ByteArrayInputStream;
import java.io.IOException;

import org.cyberneko.html.parsers.DOMParser;
import org.w3c.dom.Document;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;

/**
 * @author richardnorth
 *
 */
public class ContentParser {



	public Document parseHtml(String xmlString) throws SAXException, IOException {
		DOMParser parser = new DOMParser();
		parser.setProperty("http://cyberneko.org/html/properties/names/elems", "lower");
		
		parser.parse(new InputSource(new ByteArrayInputStream(
				xmlString.getBytes())));

		Document document = parser.getDocument();
		return document;
	}
}
