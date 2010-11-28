package org.analyticproxy.validation;

import java.io.ByteArrayOutputStream;

import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.w3c.dom.Document;

public class XslTransformer {

	private static final Logger logger = LoggerFactory
			.getLogger(XslTransformer.class);
	private Transformer transformer;

	public XslTransformer(String xsltPath) throws TransformerConfigurationException {
		TransformerFactory transformerFactory = TransformerFactory
				.newInstance();
		transformer = transformerFactory
				.newTransformer(new StreamSource(xsltPath));
	}

	public String transform(Document document) {

		try {

			// DocumentFragment resultDocument =
			// DocumentBuilderFactory.newInstance()
			// .newDocumentBuilder().newDocument().createDocumentFragment();
			// DOMResult domResult = new DOMResult(resultDocument);

			// transformer.transform(new DOMSource(document), domResult);

			ByteArrayOutputStream baos = new ByteArrayOutputStream();
			StreamResult streamResult = new StreamResult(baos);
			transformer.transform(new DOMSource(document), streamResult);

			return baos.toString();
		} catch (TransformerException e) {
			throw new XslTransformException("Failed to transform content", e);
		}

	}

}
