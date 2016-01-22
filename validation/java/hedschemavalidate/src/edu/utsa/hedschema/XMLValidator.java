package edu.utsa.hedschema;

import java.io.File;
import java.io.IOException;

import javax.xml.XMLConstants;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.parsers.SAXParser;
import javax.xml.parsers.SAXParserFactory;
import javax.xml.validation.Schema;
import javax.xml.validation.SchemaFactory;

import org.xml.sax.SAXException;

/**
 * This class validates a XML file against a XML schema file and writes the
 * warnings and errors to a text file.
 * 
 * @author Jeremy Cockfield
 */
public class XMLValidator {
	String[] errors;
	String[] warnings;
	String xmlSchemaFile;
	String xmlFile;

	/**
	 * Creates a XMLValidator object used to validate a XML file against a XML
	 * schema file.
	 * 
	 * @param xmlSchemaFile
	 *            The path to the xml schema file.
	 * @param xmlFile
	 *            The path to the xml file.
	 */
	public XMLValidator(String xmlSchemaFile, String xmlFile) {
		this.xmlSchemaFile = xmlSchemaFile;
		this.xmlFile = xmlFile;
		errors = new String[0];
		warnings = new String[0];
	}

	/**
	 * Validates a XML file against a XML schema file.
	 */
	public void validateXml() {
		MyErrorHandler meh = new MyErrorHandler();
		SchemaFactory schemaFactory = SchemaFactory.newInstance(XMLConstants.W3C_XML_SCHEMA_NS_URI);
		SAXParserFactory saxFactory = SAXParserFactory.newInstance();
		try {
			Schema schema = schemaFactory.newSchema(new File(xmlSchemaFile));
			saxFactory.setSchema(schema);
			SAXParser parser = saxFactory.newSAXParser();
			try {
				parser.parse(new File(xmlFile), meh);
			} catch (IOException e) {
			}
		} catch (ParserConfigurationException e) {

		} catch (SAXException e) {
			warnings = meh.getWarnings();
			errors = meh.getErrors();
		}
	}

	/**
	 * Gets the validation errors
	 * 
	 * @return An array of errors
	 */
	public String[] getErrors() {
		return errors;
	}

	/**
	 * Gets the validation warnings
	 * 
	 * @return An array of warnings
	 */
	public String[] getWarnings() {
		return warnings;
	}
}
