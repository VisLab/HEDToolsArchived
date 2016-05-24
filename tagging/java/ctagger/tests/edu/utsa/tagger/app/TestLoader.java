package edu.utsa.tagger.app;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;

import java.io.IOException;

import org.junit.Test;

import edu.utsa.tagger.TaggerLoader;
import edu.utsa.tagger.gui.GuiModelFactory;

public class TestLoader {

	@Test
	public void testLoadDelimitedString() throws IOException {
		System.out.println("It should load the data from a delimited string " + "and HED XML");
		String hedXml = TestUtilities.getResourceAsString(TestUtilities.HedFileName);
		String events = TestUtilities.getResourceAsString(TestUtilities.DelimitedString);
		String[] result = TaggerLoader.load(hedXml, events, 0, 0, "Test Tagger - Delimited String", 2, true, true);
		assertNotNull(result);
		assertEquals(hedXml, result[0]);
		assertEquals(events, result[1]);
	}

	@Test
	public void testLoaderJsonTagArrays() throws IOException {
		String hedXML = TestUtilities.getResourceAsString(TestUtilities.HedFileName);
		String events = TestUtilities.getResourceAsString(TestUtilities.JsonEventsArrays);
		System.out.println("It should work with a JSON event String and " + "HED XML String");
		String[] result = TaggerLoader.load(hedXML, events, TaggerLoader.USE_JSON, 0, "Tagger Test - JSON + XML", 3,
				new GuiModelFactory(), true, true);
		assertNotNull(result);
		assertEquals(hedXML, result[0]);
		assertEquals(events, result[1]);
	}

	@Test
	public void testLoadXmlData() {
		String xmlData = TestUtilities.getResourceAsString(TestUtilities.XmlDataFile);

		System.out.println("It should work with a String of XML data");
		String result = TaggerLoader.load(xmlData, TaggerLoader.USE_JSON, 0, "Tagger Test - XML Only", 3, new GuiModelFactory(),
				true, true);
		assertNotNull(result);
		assertEquals(xmlData, result); // Data should not change
	}

	@Test
	public void testTagEditAll() throws IOException {
		String hedXML = TestUtilities.getResourceAsString(TestUtilities.HedFileName);
		String events = TestUtilities.getResourceAsString(TestUtilities.JsonEventsArrays);
		System.out.println("It should work allowing all tags to be edited.");
		String[] result = TaggerLoader.load(hedXML, events, TaggerLoader.TAG_EDIT_ALL | TaggerLoader.USE_JSON, 0,
				"Tagger Test - TAG_EDIT_ALL", 2, new GuiModelFactory(), true, true);
		System.out.println(result[1]);
		assertTrue(result != null);
	}

	@Test
	public void testTagEditNone() throws IOException {
		String hedXML = TestUtilities.getResourceAsString(TestUtilities.HedFileName);
		String events = TestUtilities.getResourceAsString(TestUtilities.JsonEventsArrays);
		System.out.println("It should work allowing no tag " + "editing by default.");
		String[] result = TaggerLoader.load(hedXML, events, TaggerLoader.USE_JSON, 0, "Tagger Test - Default editing", 2,
				new GuiModelFactory(), true, true);
		System.out.println(result[1]);
		assertTrue(result != null);
	}
}