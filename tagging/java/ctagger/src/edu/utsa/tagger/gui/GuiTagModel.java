package edu.utsa.tagger.gui;

import java.util.Set;

import edu.utsa.tagger.AbstractTagModel;
import edu.utsa.tagger.TaggedEvent;
import edu.utsa.tagger.Tagger;
import edu.utsa.tagger.ToggleTagMessage;
import edu.utsa.tagger.guisupport.ITagDisplay;

/**
 * This class represents a tag, including information used by the GUI.
 * 
 * @author Lauren Jett, Rebecca Strautman, Thomas Rognon, Jeremy Cockfield, Kay
 *         Robbins
 */
public class GuiTagModel extends AbstractTagModel {

	// Highlight color to display for tag
	public enum Highlight {
		NONE, HIGHLIGHT_MATCH, HIGHLIGHT_CLOSE_MATCH, HIGHLIGHT_TAKES_VALUE, GREY_VERY_VERY_LIGHT, GREY_VERY_LIGHT, GREY_LIGHT, GREY_VERY_VERY_MEDIUM, GREY_VERY_MEDIUM, GREY_MEDIUM, GREY_DARK, GREY_VERY_DARK, GREY_VERY_VERY_DARK;
	};

	private final Tagger tagger;
	private AppView appView;
	private TagView tagView;
	private TagEditView tagEditView;
	private TagChooserView tagChooserView;

	private boolean inEdit;
	private boolean firstEdit;
	private boolean inAddValue;
	private boolean collapsable;
	private boolean collapsed;
	private boolean missing = false;
	private Highlight highlight = Highlight.NONE;

	public int selectionState = SELECTION_STATE_NONE;

	public static final int SELECTION_STATE_NONE = 0;
	public static final int SELECTION_STATE_MIXED = 1;
	public static final int SELECTION_STATE_ALL = 2;

	public GuiTagModel(final Tagger tagger) {
		this.tagger = tagger;
	}

	/**
	 * Gets the view for adding a value, used if this tag takes a value.
	 * 
	 * @return
	 */
	public AddValueView getAddValueView() {
		return new AddValueView(tagger, appView, this);
	}

	/**
	 * Gets a view for adding a value, used if this tag takes a value. Uses an
	 * alternate tag display.
	 * 
	 * @param alternateView
	 *            A tag display other than the main appView.
	 * @return
	 */
	public AddValueView getAlternateAddValueView(ITagDisplay alternateView) {
		return new AddValueView(tagger, appView, alternateView, this);
	}

	public Highlight getHighlight() {
		return highlight;
	}

	/**
	 * Returns a tag view for using the tag chooser dialog.
	 * 
	 * @param baseDepth
	 *            The depth of the tag at the base of the sub-hierarchy
	 * @return
	 */
	public TagChooserView getTagChooserView(int baseDepth) {
		if (tagChooserView == null) {
			tagChooserView = new TagChooserView(tagger, this);
		}
		tagChooserView.setDepth(getDepth() - baseDepth);
		return tagChooserView;
	}

	/**
	 * Gets the view for editing the tag in the GUI.
	 * 
	 * @return
	 */
	public TagEditView getTagEditView() {
		if (tagEditView == null) {
			tagEditView = new TagEditView(tagger, appView, this);
		}
		return tagEditView;
	}

	public RRTagView getRRTagView(TaggedEvent taggedEvent) {
		return new RRTagView(tagger, appView, taggedEvent, this);
	}

	public TagEventEditView getTagEgtEditView(TaggedEvent taggedEvent) {
		return new TagEventEditView(tagger, taggedEvent, this);
	}

	public TagEventView getTagEgtView(int groupId) {
		return new TagEventView(tagger, appView, groupId, this, false);
	}

	/**
	 * Returns the tag view to be used when searching tags.
	 * 
	 * @return
	 */
	public TagSearchView getTagSearchView() {
		return new TagSearchView(tagger, appView, this);
	}

	/**
	 * Gets the basic tag view for the GUI.
	 * 
	 * @return
	 */
	public TagView getTagView() {
		if (tagView == null) {
			tagView = new TagView(tagger, appView, this);
		}
		return tagView;
	}

	public boolean isCollapsable() {
		return collapsable;
	}

	public boolean isCollapsed() {
		return collapsed;
	}

	public boolean isInAddValue() {
		return inAddValue;
	}

	public boolean isInEdit() {
		return inEdit;
	}

	public boolean isFirstEdit() {
		return firstEdit;
	}

	public boolean isMissing() {
		return missing;
	}

	/**
	 * Attempts to toggle this tag with the groups with the groups currently
	 * selected for tagging.
	 */
	public void requestToggleTag() {
		requestToggleTag(appView.selectedGroups);
	}

	/**
	 * Attempts to toggle this tag with the groups with the given IDs.
	 * 
	 * @param groupIds
	 */
	public void requestToggleTag(Set<Integer> groupIds) {
		if (groupIds.isEmpty()) {
			appView.showTaggerMessageDialog(MessageConstants.NO_EVENT_SELECTED,
					"Okay", null, null);
			return;
		}
		if (isChildRequired()) {
			appView.showTaggerMessageDialog(
					MessageConstants.SELECT_CHILD_ERROR, "Okay", null, null);
			return;
		}
		ToggleTagMessage message = tagger.toggleTag(this, groupIds);
		if (message != null) {
			if (message.rrError) {
				appView.showTaggerMessageDialog(
						MessageConstants.ASSOCIATE_RR_ERROR, "Okay", null, null);
			} else if (message.descendants.size() > 0) {
				appView.showDescendantDialog(message);
			} else if (message.uniqueValues.size() > 0) {
				appView.showUniqueDialog(message);
			} else {
				appView.showAncestorDialog(message);
			}
		}
		// appView.updateTags();
		appView.updateEgt();
	}

	public void setAppView(AppView appView) {
		this.appView = appView;
	}

	public void setCollapsable(boolean collapsable) {
		this.collapsable = collapsable;
	}

	public void setCollapsed(boolean collapsed) {
		this.collapsed = collapsed;
	}

	public void setHighlight(Highlight highlight) {
		this.highlight = highlight;
	}

	public void setInAddValue(boolean addTransient) {
		this.inAddValue = addTransient;
	}

	public void setInEdit(boolean inEdit) {
		this.inEdit = inEdit;
	}

	public void setFirstEdit(boolean firstEdit) {
		this.firstEdit = firstEdit;
	}

	public void setMissing(boolean missing) {
		this.missing = missing;
	}

	/**
	 * Updates whether the tag is missing from the hierarchy.
	 */
	public void updateMissing() {
		tagger.updateMissing(this);
	}
}
