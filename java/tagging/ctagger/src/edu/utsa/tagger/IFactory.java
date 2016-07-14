package edu.utsa.tagger;

import edu.utsa.tagger.gui.FieldOrderView;
import edu.utsa.tagger.gui.FieldSelectView;
import edu.utsa.tagger.gui.TaggerView;

/**
 * Interface for a factory to be used with the Tagger.
 * 
 * @author Lauren Jett, Rebecca Strautman, Thomas Rognon, Jeremy Cockfield, Kay
 *         Robbins
 */
public interface IFactory {

	AbstractEventModel createAbstractEventModel(Tagger tagger);

	AbstractTagModel createAbstractTagModel(Tagger tagger);

	TaggerView createTaggerView(TaggerLoader loader, Tagger tagger, String frameTitle, boolean isStandAloneVersion);

	FieldSelectView createFieldSelectView(FieldSelectLoader loader, String frameTitle, String[] excluded,
			String[] tagged, String primaryField);

	FieldOrderView createFieldOrderView(FieldOrderLoader loader, String frameTitle, String[] fields);

}
