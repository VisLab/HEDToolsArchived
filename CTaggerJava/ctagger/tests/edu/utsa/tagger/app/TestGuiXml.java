package edu.utsa.tagger.app;

import static org.junit.Assert.assertTrue;

import java.io.FileNotFoundException;
import java.net.URISyntaxException;

import org.junit.Test;

import edu.utsa.tagger.Loader;
import edu.utsa.tagger.gui.GuiModelFactory;

public class TestGuiXml {

	@Test
	public void testGuiXml() throws FileNotFoundException, URISyntaxException {
		String xmlData = TestUtilities.getResourceAsString(TestUtilities.XmlDataFile);
		String result = Loader.load(xmlData, 0, 0, "Tagger Test - XML data", 2, new GuiModelFactory(), true, true);
		System.out.println(result);
		assertTrue(result != null);
	}

}
