package edu.utsa.tagger;

import edu.utsa.tagger.gui.GuiModelFactory;

/**
 * This class launches the Tagger automatically to be used as a stand-alone
 * tool.
 * 
 * @author Lauren Jett, Rebecca Strautman, Thomas Rognon, Jeremy Cockfield, Kay
 *         Robbins
 */
public class Launcher {
	public static void main(String[] args) {

		Loader.load(Loader.TAG_EDIT_ALL, 0, "CTAGGER", 3,
				new GuiModelFactory(), true, false);

	}
}
