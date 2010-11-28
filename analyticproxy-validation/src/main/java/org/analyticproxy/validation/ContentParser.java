/**
 * 
 */
package org.analyticproxy.validation;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;

import org.apache.xerces.parsers.DOMParser;
import org.cyberneko.html.HTMLConfiguration;
import org.w3c.dom.Document;
import org.w3c.tidy.Tidy;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;

/**
 * @author richardnorth
 *
 */
public class ContentParser {



	public Document parseHtml(String xmlString) throws SAXException, IOException {
		
//		Tidy tidy = new Tidy();
//		tidy.setXHTML(true);
//		//tidy.setDocType("omit");
//		final ByteArrayOutputStream baos = new ByteArrayOutputStream();
//		tidy.parse(new ByteArrayInputStream(xmlString.getBytes()), baos);
		
		//System.out.println("Tidied: " + baos.toString());
		
		
		DOMParser parser = new DOMParser(new HTMLConfiguration());
		parser.setProperty("http://cyberneko.org/html/properties/names/elems", "lower");
		
		parser.parse(new InputSource(new ByteArrayInputStream(xmlString.getBytes())));

		Document document = parser.getDocument();
		return document;
	}
}
