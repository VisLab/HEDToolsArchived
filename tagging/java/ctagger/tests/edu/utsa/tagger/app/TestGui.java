package edu.utsa.tagger.app;

import static org.junit.Assert.assertTrue;

import org.junit.Test;

import edu.utsa.tagger.Loader;
import edu.utsa.tagger.gui.GuiModelFactory;

public class TestGui {

	@Test
	public void testShowDialogJSONInput() {
		String hedXML = TestUtilities.getResourceAsString(TestUtilities.HedFileName);
		String events = TestUtilities.getResourceAsString(TestUtilities.JsonEventsArrays);

		String[] result = Loader.load(hedXML, events, Loader.USE_JSON | Loader.TAG_EDIT_ALL, 0,
				"Tagger Test - JSON + XML", 2, new GuiModelFactory(), true, true);
		System.out.println(result[1]);
		assertTrue(result != null);
	}

}
