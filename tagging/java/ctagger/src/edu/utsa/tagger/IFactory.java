package edu.utsa.tagger;

/**
 * Interface for a factory to be used with the Tagger.
 * 
 * @author Lauren Jett, Rebecca Strautman, Thomas Rognon, Jeremy Cockfield, Kay
 *         Robbins
 */
public interface IFactory {

	AbstractEventModel createAbstractEventModel(Tagger tagger);

	AbstractTagModel createAbstractTagModel(Tagger tagger);

	void createApp(Loader loader, Tagger tagger, String frameTitle,
			boolean isStandAloneVersion);

}
