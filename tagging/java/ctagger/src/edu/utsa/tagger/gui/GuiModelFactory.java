package edu.utsa.tagger.gui;

import edu.utsa.tagger.AbstractEventModel;
import edu.utsa.tagger.AbstractTagModel;
import edu.utsa.tagger.IFactory;
import edu.utsa.tagger.Loader;
import edu.utsa.tagger.Tagger;

/**
 * This class is a factory to create the App view, tag models, and event models
 * used by the Tagger GUI.
 * 
 * @author Lauren Jett, Rebecca Strautman, Thomas Rognon, Jeremy Cockfield, Kay
 *         Robbins
 */
public class GuiModelFactory implements IFactory {

	@Override
	public AbstractEventModel createAbstractEventModel(Tagger tagger) {
		return new GuiEventModel(tagger);
	}

	@Override
	public AbstractTagModel createAbstractTagModel(Tagger tagger) {
		return new GuiTagModel(tagger);
	}

	@Override
	public AppView createApp(Loader loader, Tagger tagger, String frameTitle, boolean isStandAloneVersion) {
		return new AppView(loader, tagger, frameTitle, isStandAloneVersion);
	}

}
