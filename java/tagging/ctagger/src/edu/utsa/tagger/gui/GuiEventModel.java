package edu.utsa.tagger.gui;

import edu.utsa.tagger.AbstractEventModel;
import edu.utsa.tagger.Tagger;

/**
 * This class represents an event with information specific to the GUI.
 * 
 * @author Lauren Jett, Rebecca Strautman, Thomas Rognon, Jeremy Cockfield, Kay
 *         Robbins
 */
public class GuiEventModel extends AbstractEventModel {

	Tagger tagger;
	private boolean inEdit = false;
	private boolean inFirstEdit = false;
	private boolean showInfo = true;

	public GuiEventModel(Tagger tagger) {
		this.tagger = tagger;
	}

	public boolean isInEdit() {
		return inEdit;
	}

	public void setInEdit(boolean inEdit) {
		this.inEdit = inEdit;
	}

	public boolean isInFirstEdit() {
		return inFirstEdit;
	}

	public void setInFirstEdit(boolean inFirstEdit) {
		this.inFirstEdit = inFirstEdit;
	}

	public void setShowInfo(boolean showInfo) {
		this.showInfo = showInfo;
	}

	public boolean showInfo() {
		return showInfo;
	}

}
