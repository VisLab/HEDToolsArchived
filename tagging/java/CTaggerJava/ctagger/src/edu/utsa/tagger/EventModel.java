package edu.utsa.tagger;

/**
 * This class contains an event, group, and tag to represent a tag association.
 * 
 * @author Lauren Jett, Rebecca Strautman, Thomas Rognon, Jeremy Cockfield, Kay
 *         Robbins
 */
public class EventModel implements Comparable<EventModel> {

	TaggedEvent taggedEvent;
	int groupId;
	AbstractTagModel tagModel;

	public EventModel(TaggedEvent taggedEvent, int groupId,
			AbstractTagModel tagModel) {
		this.taggedEvent = taggedEvent;
		this.groupId = groupId;
		this.tagModel = tagModel;
	}

	@Override
	public int compareTo(EventModel o) {
		int result;

		result = getTaggedEvent().compareTo(o.getTaggedEvent());
		if (result != 0) {
			return result;
		}

		result = getGroupId().compareTo(o.getGroupId());
		if (result != 0) {
			return result;
		}

		if (getTagModel() == null) {
			return -1;
		}
		if (o.getTagModel() == null) {
			return 1;
		}

		return getTagModel().compareTo(o.getTagModel());
	}

	@Override
	public boolean equals(Object obj) {
		if (this == obj)
			return true;
		if (obj == null)
			return false;
		if (getClass() != obj.getClass())
			return false;
		EventModel other = (EventModel) obj;
		if (taggedEvent == null) {
			if (other.taggedEvent != null)
				return false;
		} else if (!taggedEvent.equals(other.taggedEvent))
			return false;
		if (groupId != other.groupId)
			return false;
		if (tagModel == null) {
			if (other.tagModel != null)
				return false;
		} else if (!tagModel.equals(other.tagModel))
			return false;
		return true;
	}

	public Integer getGroupId() {
		return groupId;
	}

	public TaggedEvent getTaggedEvent() {
		return taggedEvent;
	}

	public AbstractTagModel getTagModel() {
		return tagModel;
	}

	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result
				+ ((taggedEvent == null) ? 0 : taggedEvent.hashCode());
		result = prime * result + groupId;
		result = prime * result
				+ ((tagModel == null) ? 0 : tagModel.hashCode());
		return result;
	}
}