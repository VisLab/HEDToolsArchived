package edu.utsa.hedschema;

import java.util.ArrayList;

import org.xml.sax.SAXException;
import org.xml.sax.SAXParseException;
import org.xml.sax.helpers.DefaultHandler;

/**
 * This class overrides the events raised by the SAX parser.
 * 
 * @author Jeremy Cockfield
 *
 */
public class MyErrorHandler extends DefaultHandler {
	ArrayList<String> warnings;
	ArrayList<String> errors;

	/**
	 * Creates a SAX Handler class that overrides the events raised by the SAX
	 * parser.
	 * 
	 * @param fileName
	 */
	public MyErrorHandler() {
		warnings = new ArrayList<String>();
		errors = new ArrayList<String>();
	}

	/**
	 * Overrides the event warnings.
	 */
	public void warning(SAXParseException e) throws SAXException {
		warnings.add("Warning on line " + e.getLineNumber() + "\n\t" + e.getMessage() + "\n");
	}

	/**
	 * Overrides the event errors.
	 */
	public void error(SAXParseException e) throws SAXException {
		errors.add("Error on line " + e.getLineNumber() + "\n\t" + e.getMessage() + "\n");
	}

	/**
	 * Overrides the fatal event errors.
	 */
	public void fatalError(SAXParseException e) throws SAXException {
		errors.add("Error on line " + e.getLineNumber() + "\n\t" + e.getMessage() + "\n");
	}

	/**
	 * Gets the validation errors
	 * 
	 * @return An array of errors
	 */
	public String[] getErrors() {
		return errors.toArray(new String[errors.size()]);
	}

	/**
	 * Gets the validation warnings
	 * 
	 * @return An array of warnings
	 */
	public String[] getWarnings() {
		return warnings.toArray(new String[warnings.size()]);
	}

}
