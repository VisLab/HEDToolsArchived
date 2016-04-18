package edu.utsa.tagger;

import edu.utsa.tagger.gui.AppView;

/**
 * Interface for a factory to be used with the Tagger.
 * 
 * @author Lauren Jett, Rebecca Strautman, Thomas Rognon, Jeremy Cockfield, Kay
 *         Robbins
 */
public interface IFactory {

	AbstractEventModel createAbstractEventModel(Tagger tagger);

	AbstractTagModel createAbstractTagModel(Tagger tagger);

	AppView createApp(Loader loader, Tagger tagger, String frameTitle, boolean isStandAloneVersion);

}
