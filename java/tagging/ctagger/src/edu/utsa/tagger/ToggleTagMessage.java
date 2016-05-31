package edu.utsa.tagger;

import java.util.ArrayList;
import java.util.Set;

/**
 * This class contains information about conflicting ancestor, descendant, and
 * unique values when attempting to toggle tags.
 * 
 * @author Lauren Jett, Rebecca Strautman, Thomas Rognon, Jeremy Cockfield, Kay
 *         Robbins
 */
public class ToggleTagMessage {
	public ArrayList<EventModel> ancestors = new ArrayList<EventModel>();
	public ArrayList<EventModel> descendants = new ArrayList<EventModel>();
	public ArrayList<EventModel> uniqueValues = new ArrayList<EventModel>();
	public AbstractTagModel uniqueKey;
	public AbstractTagModel tagModel;
	public Set<Integer> groupIds;
	public boolean rrError = false;

	public ToggleTagMessage(AbstractTagModel tagModel, Set<Integer> groupIds) {
		this.tagModel = tagModel;
		this.groupIds = groupIds;
	}

	public void addAncestor(TaggedEvent taggedEvent, int groupNumber,
			AbstractTagModel tagModel) {
		ancestors.add(new EventModel(taggedEvent, groupNumber, tagModel));
	}

	public void addDescendant(TaggedEvent taggedEvent, int groupId,
			AbstractTagModel tagModel) {
		descendants.add(new EventModel(taggedEvent, groupId, tagModel));
	}

	public void addUniqueValue(TaggedEvent taggedEvent, int groupNumber,
			AbstractTagModel tagModel) {
		uniqueValues.add(new EventModel(taggedEvent, groupNumber, tagModel));
	}
}
