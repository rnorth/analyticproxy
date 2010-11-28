/**
 * 
 */
package org.analyticproxy.validation;

import static org.junit.Assert.assertEquals;

import java.io.IOException;

import org.junit.Test;
import org.w3c.dom.Document;
import org.w3c.dom.Node;
import org.xml.sax.SAXException;

/**
 * @author richardnorth
 * 
 */
public class ParseContentTest {

	@Test
	public void testCanParseSimpleXml() throws SAXException, IOException {

		ContentParser contentParser = new ContentParser();

		Document document = contentParser
				.parseHtml("<html><body><h1>Hello world</h1></body></html>");

		Node child = document.getFirstChild();
		print(child, "> ");

		assertEquals("html", document.getFirstChild().getNodeName());
		assertEquals("h1", document.getFirstChild().getChildNodes().item(1)
				.getFirstChild().getNodeName());
	}

	@Test
	public void testCanTransformSimpleXml() throws Exception {
		ContentParser contentParser = new ContentParser();
		XslTransformer xslTransformer = new XslTransformer("src/test/resources/test1.xsl");

		Document document = contentParser
				.parseHtml("<html><body><h1>Hello world</h1></body></html>");

		String resultXML = xslTransformer.transform(document);
		System.out.println(resultXML);
		
		assertEquals("<?xml version=\"1.0\" encoding=\"UTF-8\"?><heading xmlns=\"http://www.w3.org/1999/xhtml\">Hello world</heading>", resultXML.trim());
	}

	public void print(Node node, String indent) {
		System.out.println(indent + node.getClass().getName() + ": "
				+ node.getNodeName() + " " + node.getTextContent());
		for (int i = 0; i < node.getChildNodes().getLength(); i++) {
			Node child = node.getChildNodes().item(i);

			print(child, indent + " ");
		}
	}
}
