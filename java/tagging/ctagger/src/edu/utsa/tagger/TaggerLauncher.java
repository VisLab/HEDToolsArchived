package edu.utsa.tagger;

import edu.utsa.tagger.gui.GuiModelFactory;

/**
 * This class launches the Tagger automatically to be used as a stand-alone
 * tool.
 * 
 * @author Lauren Jett, Rebecca Strautman, Thomas Rognon, Jeremy Cockfield, Kay
 *         Robbins
 */
public class TaggerLauncher {
	public static void main(String[] args) {

		TaggerLoader.load(TaggerLoader.TAG_EDIT_ALL, 0, "CTagger", 3,
				new GuiModelFactory(), true, false);

	}
}
