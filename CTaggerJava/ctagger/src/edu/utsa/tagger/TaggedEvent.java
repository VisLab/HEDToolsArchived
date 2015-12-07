package edu.utsa.tagger;

import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Set;
import java.util.TreeMap;

import edu.utsa.tagger.gui.AppView;
import edu.utsa.tagger.gui.EventEditView;
import edu.utsa.tagger.gui.EventView;
import edu.utsa.tagger.gui.GroupView;
import edu.utsa.tagger.gui.GuiEventModel;
import edu.utsa.tagger.gui.RRTagView;
import edu.utsa.tagger.gui.TagEventView;

/**
 * This class represents a tagged event, consisting of the event model and the
 * associated groupIds and tag models.
 * 
 * @author Lauren Jett, Rebecca Strautman, Thomas Rognon, Jeremy Cockfield, Kay
 *         Robbins
 */
public class TaggedEvent implements Comparable<TaggedEvent> {
	private Tagger tagger;
	private AppView appView;
	private GuiEventModel guiEventModel;
	private TreeMap<Integer, TaggerSet<AbstractTagModel>> tagGroups;
	// Tag group used to represent tags at the event level
	private int eventGroupId;
	// Associated views
	private EventView eventView;
	private HashMap<Integer, GroupView> groupViews;
	private HashMap<AbstractTagModel, TagEventView> tagEgtViews;
	private HashMap<AbstractTagModel, RRTagView> rrTagViews;
	private EventEditView eventEditView;

	public TaggedEvent(GuiEventModel guiEventModel, Tagger tagger) {
		this.guiEventModel = guiEventModel;
		this.tagger = tagger;
		this.tagGroups = new TreeMap<Integer, TaggerSet<AbstractTagModel>>();
		this.groupViews = new HashMap<Integer, GroupView>();
		this.tagEgtViews = new HashMap<AbstractTagModel, TagEventView>();
		this.rrTagViews = new HashMap<AbstractTagModel, RRTagView>();
	}

	/**
	 * Adds a group with the given ID to the event.
	 * 
	 * @param groupId
	 * @return True if the group was added successfully, false if the group ID
	 *         already existed for this event.
	 */
	public boolean addGroup(int groupId) {
		TaggerSet<AbstractTagModel> tags = tagGroups.get(groupId);
		if (tags != null) {
			return false;
		}
		tags = new TaggerSet<AbstractTagModel>();
		tagGroups.put(groupId, tags);
		return true;
	}

	public void addGroupView(GroupView groupView) {
		groupViews.put(groupView.getGroupId(), groupView);
	}

	public GroupView getGroupViewByKey(int groupId) {
		return groupViews.get(groupId);
	}

	public void addTagEgtView(AbstractTagModel tagModel, TagEventView tagEgtView) {
		tagEgtViews.put(tagModel, tagEgtView);
	}

	public TagEventView getTagEgtViewByKey(AbstractTagModel tagModel) {
		return tagEgtViews.get(tagModel);
	}

	public void addRRTagView(AbstractTagModel tagModel, RRTagView rrTagView) {
		rrTagViews.put(tagModel, rrTagView);
	}

	public RRTagView getRRTagViewByKey(AbstractTagModel tagModel) {
		return rrTagViews.get(tagModel);
	}

	/**
	 * Attempts to add the given tag at the event level.
	 * 
	 * @param tagModel
	 * @return True if the tag was added to the event, false if it was already
	 *         present at the event level.
	 */
	public boolean addTag(AbstractTagModel tagModel) {
		return addTagToGroup(eventGroupId, tagModel);
	}

	/**
	 * Attempts to add the given tag to the group with the given ID.
	 * 
	 * @param groupId
	 * @param tagModel
	 * @return True if the tag was successfully added to the group, false if the
	 *         tag already exists in the group or the group does not exist in
	 *         the event.
	 */
	public boolean addTagToGroup(int groupId, AbstractTagModel tagModel) {
		TaggerSet<AbstractTagModel> tags = tagGroups.get(groupId);
		if (tags == null) {
			return false;
		} else {
			if ("~".equals(tagModel.getName()))
				tags.add(tagModel, true);
			else
				tags.add(tagModel);
			if (getLabel().length() > 0) {
				guiEventModel.setLabel(getLabel());
			}
			return true;
		}
	}

	/**
	 * Attempts to add the given tag to the group with the given ID.
	 * 
	 * @param groupId
	 * @param tagModel
	 * @return True if the tag was successfully added to the group, false if the
	 *         tag already exists in the group or the group does not exist in
	 *         the event.
	 */
	public boolean addTagToGroup(int groupId, AbstractTagModel tagModel,
			int index) {
		TaggerSet<AbstractTagModel> tags = tagGroups.get(groupId);
		if (tags == null) {
			return false;
		} else {
			if ("~".equals(tagModel.getName())) {
				tags.add(index, tagModel, true);
			} else {
				tags.add(tagModel);
			}
			if (getLabel().length() > 0) {
				guiEventModel.setLabel(getLabel());
			}
			return true;
		}
	}

	/**
	 * TaggedEvents are compared by their label, then eventModel.
	 */
	@Override
	public int compareTo(TaggedEvent o) {
		int result = getLabel().compareTo(o.getLabel());
		if (result != 0) {
			return result;
		}
		return getEventModel().compareTo(o.getEventModel());
	}

	/**
	 * Checks to see if the event contains the group.
	 * 
	 * @param groupId
	 *            The id of the group.
	 * @return True if the group is in the event, false if otherwise.
	 */
	public boolean containsGroup(int groupId) {
		return tagGroups.containsKey(groupId);
	}

	/**
	 * Checks whether the group with the given ID contains the given tag in this
	 * event.
	 * 
	 * @param groupId
	 *            The id of the group.
	 * @param tagModel
	 *            The tag to look for in the group.
	 * @return True if the tag was found in the specified group, false if the
	 *         tag was not found or the group does not exist.
	 */
	public boolean containsTagInGroup(int groupId, AbstractTagModel tagModel) {
		TaggerSet<AbstractTagModel> tags = tagGroups.get(groupId);
		if (tags != null) {
			return tags.contains(tagModel);
		}
		return false;
	}

	/**
	 * Checks whether the group with the given ID contains the given tag in this
	 * event.
	 * 
	 * @param groupId
	 *            The id of the group.
	 * @param tagModel
	 *            The tag to look for in the group.
	 * @return True if the tag was found in the specified group, false if the
	 *         tag was not found or the group does not exist.
	 */
	public int findTagIndex(int groupId, AbstractTagModel tagModel) {
		TaggerSet<AbstractTagModel> tags = tagGroups.get(groupId);
		if (tags != null && tags.contains(tagModel)) {
			return tags.indexOf(tagModel);
		}
		return -1;
	}

	/**
	 * TaggedEvents are equal if their underlying eventModels are equal.
	 */
	@Override
	public boolean equals(Object obj) {
		if (this == obj)
			return true;
		if (obj == null)
			return false;
		if (getClass() != obj.getClass())
			return false;
		TaggedEvent other = (TaggedEvent) obj;
		if (other.getLabel() == null)
			return false;
		return (0 == this.compareTo(other));
	}

	/**
	 * Finds the descendant of the given unique tag in the given group, if it
	 * exists.
	 * 
	 * @param groupId
	 * @param uniqueKey
	 *            Tag model of a unique tag
	 * @return The tag model for the descendant tag found, or null if no such
	 *         tag exists in this group.
	 */
	public AbstractTagModel findDescendant(int groupId,
			AbstractTagModel uniqueKey) {
		TaggerSet<AbstractTagModel> tags = tagGroups.get(groupId);
		if (tags == null) {
			return null;
		}
		String uniquePrefix = uniqueKey.getPath() + "/";
		for (AbstractTagModel tag : tags) {
			String path = tag.getPath();
			if (path.equals(uniqueKey.getPath())
					|| path.startsWith(uniquePrefix)
					|| path.equals(uniqueKey.getPath())) {
				return tag;
			}
		}
		return null;
	}

	/**
	 * Finds the tag groups that contain the tag.
	 * 
	 * @param tagName
	 *            The name of the tag.
	 * @return A Set of group ids containing the tag.
	 */
	public Set<Integer> findTagGroup(String tagName) {
		Set<Integer> groups = new HashSet<Integer>();
		TreeMap<Integer, TaggerSet<AbstractTagModel>> tagGroups = getTagGroups();
		Set<Integer> tagGroupKeys = tagGroups.keySet();
		for (Integer key : tagGroupKeys) {
			for (AbstractTagModel tag : tagGroups.get(key)) {
				if (tag.getPath().startsWith(tagName)) {
					groups.add(key);
				}
			}
		}
		return groups;
	}

	public AbstractTagModel findTagModel(String tagName) {
		TreeMap<Integer, TaggerSet<AbstractTagModel>> tagGroups = getTagGroups();
		Set<Integer> tagGroupKeys = tagGroups.keySet();
		for (Integer key : tagGroupKeys) {
			for (AbstractTagModel tag : tagGroups.get(key)) {
				if (tag.getPath().startsWith(tagName)) {
					return tag;
				}
			}
		}
		return null;
	}

	/**
	 * Finds a tag in the given group that shares a path with the given tag. The
	 * found tag could be an ancestor or descendant of <code>tagModel</code>, or
	 * could be <code>tagModel</code> itself.
	 * 
	 * @param groupId
	 * @param tagModel
	 * @return The path of the tag found, or null if no such tag exists in the
	 *         given group.
	 */
	public AbstractTagModel findTagSharedPath(int groupId,
			AbstractTagModel tagModel) {
		TaggerSet<AbstractTagModel> tags = tagGroups.get(groupId);
		if (tags != null) {
			for (AbstractTagModel tag : tags) {
				String path = tag.getPath();
				if (path.startsWith(tagModel.getPath() + "/")
						|| path.equals(tagModel.getPath())
						|| tagModel.getPath().startsWith(path + "/")) {
					return tag;
				}
			}
		}
		return null;
	}

	/**
	 * Finds the number of tildes in a event tag group.
	 * 
	 * @param groupId
	 *            The tagged event group id
	 * @return The number of tildes in the event group.
	 */
	public int findNumTildes(int groupId) {
		int count = 0;
		TaggerSet<AbstractTagModel> tags = tagGroups.get(groupId);
		if (tags != null) {
			for (AbstractTagModel tag : tags) {
				if ("~".equals(tag.getPath())) {
					count++;
				}
			}
		}
		return count;
	}

	public EventEditView getEventEditView() {
		if (eventEditView == null) {
			eventEditView = new EventEditView(tagger, appView, this);
		}
		return eventEditView;
	}

	public int getEventGroupId() {
		return eventGroupId;
	}

	public GuiEventModel getEventModel() {
		return guiEventModel;
	}

	public EventView getEventView() {
		if (eventView == null) {
			eventView = new EventView(tagger, appView, this);
		}
		return eventView;
	}

	/**
	 * Returns the number within this event for the given groupId. E.g. if the
	 * groupId represents the 3rd group in an event, it will return 3.
	 * 
	 * @param groupId
	 * @return The index within this event for the given groupId, if it exists.
	 *         Otherwise, returns -1.
	 */
	public int getGroupNumber(int groupId) {
		int count = 0;
		for (int id : tagGroups.keySet()) {
			if (id == groupId) {
				return count;
			}
			count++;
		}
		return -1;
	}

	/**
	 * Gets the label of the event.
	 * 
	 * @return The event label.
	 */
	public String getLabel() {
		String label = new String();
		for (AbstractTagModel tag : tagGroups.get(eventGroupId)) {
			if (tag.getPath().startsWith("/Event/Label/")) {
				return tag.getName();
			}
		}
		return label;
	}

	/**
	 * Finds the number of tags in the group with the given ID.
	 * 
	 * @param groupId
	 * @return The number of tags in the group, or -1 if the group ID is not
	 *         found in this event.
	 */
	public int getNumTagsInGroup(int groupId) {
		TaggerSet<AbstractTagModel> tags = tagGroups.get(groupId);
		if (tags == null) {
			return -1;
		}
		return tags.size();
	}

	public RRTagView getRRTagView(AbstractTagModel key) {
		return new RRTagView(tagger, appView, this, key);
	}

	/**
	 * Finds the descendants of the given tag in this event, if they exist, from
	 * tags at the event level.
	 * 
	 * @param tagModel
	 * @return A set of tag models for the descendant tags found, or null if no
	 *         such tags are found for this event.
	 */
	public TaggerSet<AbstractTagModel> getRRValue(AbstractTagModel tagModel) {
		TaggerSet<AbstractTagModel> desc = new TaggerSet<AbstractTagModel>();
		TaggerSet<AbstractTagModel> eventTags = tagGroups.get(eventGroupId);
		for (AbstractTagModel tag : eventTags) {
			if (tag.getPath().startsWith(tagModel.getPath() + "/")
					|| tag.getPath().equals(tagModel.getPath())) {
				desc.add(tag);
			}
		}
		if (desc.size() > 0) {
			return desc;
		}
		return null;
	}

	public TreeMap<Integer, TaggerSet<AbstractTagModel>> getTagGroups() {
		return tagGroups;
	}

	/**
	 * Finds the number of tags in a event.
	 * 
	 * @return The number of tags in a event.
	 */
	public int findNumberOfTagsInEvents() {
		int numTags = 0;
		Iterator<Integer> tagGroupIterator = tagGroups.keySet().iterator();
		while (tagGroupIterator.hasNext()) {
			numTags += getNumTagsInGroup(tagGroupIterator.next().intValue());
		}
		return numTags;
	}

	public boolean isInEdit() {
		return guiEventModel.isInEdit();
	}

	public boolean isInFirstEdit() {
		return guiEventModel.isInFirstEdit();
	}

	/**
	 * Removes the specified group from the event.
	 * 
	 * @param groupId
	 * @return A <code>TaggerSet<AbstractTagModel</code> containing the tags
	 *         that were in the removed group. Returns null if the group did not
	 *         exist.
	 */
	public TaggerSet<AbstractTagModel> removeGroup(int groupId) {
		TaggerSet<AbstractTagModel> tags = tagGroups.get(groupId);
		tagGroups.remove(groupId);
		return tags;
	}

	/**
	 * Attempts to remove the given tag from the group with the given ID.
	 * 
	 * @param groupId
	 * @param tagModel
	 * @return True if the tag was removed. False if the tag and/or group does
	 *         not exist.
	 */
	public boolean removeTagFromGroup(int groupId, AbstractTagModel tagModel) {
		TaggerSet<AbstractTagModel> tags = tagGroups.get(groupId);
		if (tags == null) {
			return false;
		}
		Iterator<AbstractTagModel> it = tags.iterator();
		while (it.hasNext()) {
			AbstractTagModel tag = it.next();
			if (tag.equals(tagModel)) {
				it.remove();
				return true;
			}
		}
		return false;
	}

	public boolean isRRTagDescendant(AbstractTagModel tagModel) {
		Iterator<AbstractTagModel> rrTags = rrTagViews.keySet().iterator();
		while (rrTags.hasNext()) {
			AbstractTagModel rrTag = rrTags.next();
			if (tagModel.getPath().startsWith(rrTag.getPath())) {
				return true;
			}
		}
		return false;
	}

	public AbstractTagModel findRRParentTag(AbstractTagModel tagModel) {
		Iterator<AbstractTagModel> rrTags = rrTagViews.keySet().iterator();
		while (rrTags.hasNext()) {
			AbstractTagModel rrTag = rrTags.next();
			if (tagModel.getPath().startsWith(rrTag.getPath())) {
				return rrTag;
			}
		}
		return null;
	}

	/**
	 * Sets the event group ID (used to identify tags at the event level) to the
	 * given parameter. Creates the group so that tags can be added.
	 * 
	 * @param groupId
	 */
	public void setEventGroupId(int groupId) {
		eventGroupId = groupId;
		addGroup(groupId);
	}

	public void setEventModel(GuiEventModel eventModel) {
		this.guiEventModel = eventModel;
	}

	public void setInEdit(boolean inEdit) {
		guiEventModel.setInEdit(inEdit);
	}

	public void setInFirstEdit(boolean inFirstEdit) {
		guiEventModel.setInFirstEdit(inFirstEdit);
	}

	public void setShowInfo(boolean showInfo) {
		guiEventModel.setShowInfo(showInfo);
	}

	public boolean showInfo() {
		return guiEventModel.showInfo();
	}

	public void setAppView(AppView appView) {
		this.appView = appView;
	}
}