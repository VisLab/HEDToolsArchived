package edu.utsa.tagger.app;

import static org.junit.Assert.assertTrue;

import java.io.IOException;

import org.junit.Test;

import edu.utsa.tagger.TaggerLoader;
import edu.utsa.tagger.gui.GuiModelFactory;

public class TestGui {

	@Test
	public void testShowDialogJSONInput() throws IOException {
		String hedXML = TestUtilities.getResourceAsString(TestUtilities.HedFileName);
		String events = TestUtilities.getResourceAsString(TestUtilities.JsonEventsArrays);

		String[] result = TaggerLoader.load(hedXML, events, TaggerLoader.USE_JSON | TaggerLoader.TAG_EDIT_ALL, 0,
				"Tagger Test - JSON + XML", 2, new GuiModelFactory(), true, true);
		System.out.println(result[1]);
		assertTrue(result != null);
	}

}
