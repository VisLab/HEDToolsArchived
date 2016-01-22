package edu.utsa.hedschema;

import static org.junit.Assert.assertTrue;

import org.junit.Test;

/**
 * This class tests the XMLValidator class.
 * 
 * @author Jeremy Cockfield
 *
 */
public class TestXMLValidator {
	String xmlSchema = "tests/data/HEDSchema2.027.xsd";
	String xmlValid = "tests/data/HED2.027_valid.xml";
	String xmlInvalid = "tests/data/HED2.027_invalid.xml";

	/**
	 * Tests the XMLValidator class constructor and the validateXml method.
	 * 
	 * @throws Exception
	 */
	@Test
	public void testXMLValidatorInvalid() {
		XMLValidator val = new XMLValidator(xmlSchema, xmlInvalid);
		val.validateXml();
		String[] errors = val.getErrors();
		assertTrue("There were no errors found", 2 == errors.length);
		String warnings[] = val.getWarnings();
		assertTrue("There were warnings found", 0 == warnings.length);
	}

	/**
	 * Tests the XMLValidator class constructor and the validateXml method.
	 * 
	 * @throws Exception
	 */
	@Test
	public void testXMLValidatorValid() {

		XMLValidator val = new XMLValidator(xmlSchema, xmlValid);
		val.validateXml();
		String[] errors = val.getErrors();
		assertTrue("There were errors found", 0 == errors.length);
		String warnings[] = val.getWarnings();
		assertTrue("There were warnings found", 0 == warnings.length);
	}

}
