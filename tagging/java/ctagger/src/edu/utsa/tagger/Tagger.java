package edu.utsa.tagger;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.StringReader;
import java.io.StringWriter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Set;
import java.util.SortedSet;
import java.util.TreeMap;

import javax.xml.bind.JAXBContext;
import javax.xml.bind.JAXBException;
import javax.xml.bind.Marshaller;

import com.fasterxml.jackson.core.JsonGenerationException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.JsonMappingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.ObjectWriter;

import edu.utsa.tagger.gui.GuiEventModel;
import edu.utsa.tagger.gui.GuiTagModel;
import edu.utsa.tagger.gui.GuiTagModel.Highlight;
import edu.utsa.tagger.TagXmlModel.PredicateType;

/**
 * This class keeps track of the tags, events, and associations, and provides
 * methods to edit them.
 * 
 * @author Lauren Jett, Rebecca Strautman, Thomas Rognon, Jeremy Cockfield, Kay
 *         Robbins
 */
public class Tagger {

	/**
	 * Concatenates two string arrays.
	 * 
	 * @param s1
	 *            The first string array.
	 * @param s2
	 *            The second string array.
	 * @return A string array consisting of the concatenated arrays.
	 */
	public static String[] concat(String[] s1, String[] s2) {
		String[] concat = new String[s1.length + s2.length];
		System.arraycopy(s1, 0, concat, 0, s1.length);
		System.arraycopy(s2, 0, concat, s1.length, s2.length);
		return concat;
	}

	/**
	 * Splits a path on the separator "/" and returns it as a list.
	 * 
	 * @param path
	 *            the tag's path
	 * @return A List containing the tag's path.
	 */
	private static List<String> splitPath(String path) {
		String pathTokens[] = path.split("[/]");
		// if (pathTokens.length < 1 && !"~".equals(pathTokens[0])) {
		// System.err.println("invalid path: [" + path + "]");
		// return null;
		// }
		List<String> pathAsList = new ArrayList<String>();
		if (pathTokens.length > 0) {
			for (int i = 1; i < pathTokens.length; i++) {
				pathAsList.add(pathTokens[i]);
			}
		}
		return pathAsList;
	}

	/**
	 * Trims each element in the string array.
	 * 
	 * @param array
	 *            The string array to trim.
	 * @return A string array with trimmed elements.
	 */
	public static String[] trimStringArray(String[] array) {
		String[] trimmedArray = new String[array.length];
		for (int i = 0; i < array.length; i++) {
			trimmedArray[i] = array[i].trim();
		}
		return trimmedArray;
	}

	private IFactory factory;
	private Loader loader;
	// Set of tags in the HED hierarchy
	private TaggerSet<AbstractTagModel> tagList = new TaggerSet<AbstractTagModel>();
	// Set of events and their associated tags
	private TaggerSet<TaggedEvent> taggedEventSet = new TaggerSet<TaggedEvent>();
	// Counter to create unique group IDs
	private static int groupIdCounter = 0;
	private static final String LabelTag = "Event/Label/";
	private String version = "2.01";
	// Lists of required, recommended, and unique tags from the hierarchy
	private TaggerSet<AbstractTagModel> requiredTags = new TaggerSet<AbstractTagModel>();
	private TaggerSet<AbstractTagModel> recommendedTags = new TaggerSet<AbstractTagModel>();
	private TaggerSet<AbstractTagModel> uniqueTags = new TaggerSet<AbstractTagModel>();
	// Highlighted tag in a GUI
	public GuiTagModel highlightTag;
	public Highlight currentHighlightType;
	public Highlight previousHighlightType;
	// HashMap containing unit classes
	public HashMap<String, String> unitClasses = new HashMap<String, String>();
	public HashMap<String, String> unitClassDefaults = new HashMap<String, String>();

	// History of actions performed that can be undone
	private TaggerHistory history;
	private boolean isPrimary = true;
	private int tagLevel = 0;
	private boolean hedEdited = false;
	private boolean editTags = false;

	/**
	 * Constructor creates the Tagger with no data loaded.
	 * 
	 * @param factory
	 *            interface for a factory
	 * @param loader
	 *            loads the tagger GUI
	 */
	public Tagger(boolean isPrimary, IFactory factory, Loader loader) {
		this.isPrimary = isPrimary;
		this.factory = factory;
		this.loader = loader;
		history = new TaggerHistory(this);
		editTags = loader.testFlag(Loader.TAG_EDIT_ALL);
	}

	/**
	 * Constructor initializes the tagger by reading the XML string containing
	 * the event data and the HED hierarchy in the TaggerData format.
	 * 
	 * @param xmlData
	 *            xml string that the tagger reads in
	 * @param factory
	 *            interface for a factory
	 * @param loader
	 *            loads the tagger GUI
	 */
	public Tagger(String xmlData, boolean isPrimary, IFactory factory, Loader loader) {
		this.isPrimary = isPrimary;
		this.factory = factory;
		this.loader = loader;
		history = new TaggerHistory(this);
		editTags = loader.testFlag(Loader.TAG_EDIT_ALL);

		if (xmlData.isEmpty()) {
			throw new RuntimeException("XML data is empty.");
		}
		// Unmarshal XML String
		TaggerDataXmlModel savedDataXmlModel = null;
		try {
			JAXBContext context = JAXBContext.newInstance(TaggerDataXmlModel.class);
			savedDataXmlModel = (TaggerDataXmlModel) context.createUnmarshaller().unmarshal(new StringReader(xmlData));
		} catch (JAXBException e) {
			throw new RuntimeException("Unable to read XML data: " + e.getMessage());
		}
		if (savedDataXmlModel == null) {
			throw new RuntimeException("Unable to read XML data");
		}
		processXmlData(savedDataXmlModel);
	}

	/**
	 * Constructor initializes the tagger by reading the HED XML string and the
	 * tagged event string.
	 * 
	 * @param hedXmlString
	 *            HED XML string that the tagger reads in
	 * @param egtString
	 *            Tagged event string, either in JSON format, or tab-delimited
	 *            text
	 * @param factory
	 *            interface for a factory
	 * @param loader
	 *            loads the tagger GUI
	 */
	public Tagger(String hedXmlString, String egtString, boolean isPrimary, IFactory factory, Loader loader) {
		this.factory = factory;
		this.loader = loader;
		this.isPrimary = isPrimary;
		history = new TaggerHistory(this);
		editTags = loader.testFlag(Loader.TAG_EDIT_ALL);
		tagList = new TaggerSet<AbstractTagModel>();
		taggedEventSet = new TaggerSet<TaggedEvent>();
		try {
			HedXmlModel hedXmlModel = readHedXmlString(hedXmlString);
			populateTagList(hedXmlModel);
			if (loader.testFlag(Loader.USE_JSON)) {
				Set<EventJsonModel> eventJsonModels = readEventJsonString(egtString);
				populateEventsFromJson(eventJsonModels);
			} else {
				BufferedReader egtReader = new BufferedReader(new StringReader(egtString));
				populateEventsFromTabDelimitedText(egtReader);
			}
		} catch (Exception e) {
			System.err.println("Unable to create tagger:\n" + e.getMessage());
		}
	}

	/**
	 * Adds an event to a particular index.
	 * 
	 * @param index
	 *            The index that the event is inserted at.
	 * @param event
	 *            The new event being added.
	 * @return True if the event has been added, false if otherwise.
	 */
	public boolean addEventBase(int index, TaggedEvent event) {
		return taggedEventSet.add(index, event);
	}

	/**
	 * Adds an event to the event list.
	 * 
	 * @param event
	 *            The event to add to the event list.
	 * @return The TaggedEvent created if the add was successful, null
	 *         otherwise.
	 */
	public boolean addEventBase(TaggedEvent event) {
		return taggedEventSet.add(event);
	}

	/**
	 * 
	 * @return True if the HED XML has been modified, false if otherwise.
	 */
	public boolean hedEdited() {
		return hedEdited;
	}

	/**
	 * Checks to see if the Tagger events and tags are associated with a primary
	 * field.
	 * 
	 * @return True if the Tagger events and tags are associated with a primary,
	 *         false if otherwise.
	 */
	public boolean isPrimary() {
		return isPrimary;
	}

	/**
	 * Sets the isPrimary field. True if the Tagger events and tags are
	 * associated with a primary, false if otherwise.
	 * 
	 * @param isPrimary
	 *            True if the Tagger events and tags are associated with a
	 *            primary, false if otherwise.
	 */
	public void setIsPrimary(boolean isPrimary) {
		this.isPrimary = isPrimary;
	}

	/**
	 * Sets to true if the HED XML has been modified, false if otherwise.
	 * 
	 * @param hedEdited
	 *            True if the HED XML has been modified, false if otherwise.
	 */
	public void setHedEdited(boolean hedEdited) {
		this.hedEdited = hedEdited;
	}

	/**
	 * Adds a group with the given group ID and tags to the given event.
	 * 
	 * @param taggedEvent
	 *            The TaggedEvent that represents the event.
	 * @param groupId
	 *            The group ID.
	 * @param tags
	 *            The set of tags to add to the event.
	 * @return True if the add was successful, false otherwise.
	 */
	public boolean addGroupBase(TaggedEvent taggedEvent, Integer groupId, TaggerSet<AbstractTagModel> tags) {
		if (!taggedEvent.addGroup(groupId)) {
			return false;
		}
		for (AbstractTagModel tag : tags) {
			taggedEvent.addTagToGroup(groupId, tag);
		}
		return true;
	}

	/**
	 * Adds an event and creates an entry in the history.
	 * 
	 * @param code
	 *            The event code.
	 * @param label
	 *            The event label.
	 * @return The TaggedEvent created.
	 */
	public TaggedEvent addNewEvent(String code, String label) {
		GuiEventModel eventModel = (GuiEventModel) factory.createAbstractEventModel(this);
		eventModel.setCode(code);
		eventModel.setLabel(label);
		TaggedEvent taggedEvent = new TaggedEvent(eventModel, this);
		int groupId = groupIdCounter++;
		taggedEvent.setEventGroupId(groupId);
		if (!label.trim().isEmpty()) {
			AbstractTagModel labelTag = getTagModel("/Event/Label/" + label);
			taggedEvent.addTag(labelTag);
		}
		if (addEventBase(taggedEvent)) {
			HistoryItem historyItem = new HistoryItem();
			historyItem.type = TaggerHistory.Type.EVENT_ADDED;
			historyItem.event = taggedEvent;
			history.add(historyItem);
		}
		return taggedEvent;
	}

	/**
	 * Adds a group to the event and creates an entry in the history.
	 * 
	 * @param taggedEvent
	 *            The TaggedEvent representing the event to add the group to.
	 * @return The group ID.
	 */
	public int addNewGroup(TaggedEvent taggedEvent) {
		int groupId = groupIdCounter++;
		if (taggedEvent.addGroup(groupId)) {
			HistoryItem historyItem = new HistoryItem();
			historyItem.type = TaggerHistory.Type.GROUP_ADDED;
			historyItem.event = taggedEvent;
			historyItem.groupId = groupId;
			historyItem.tags = taggedEvent.getTagGroups().get(groupId);
			history.add(historyItem);
		}
		return groupId;
	}

	/**
	 * Adds a group to the events and creates an entry in the history.
	 * 
	 * @param taggedEvent
	 *            The TaggedEvent representing the event to add the group to.
	 * @return The group ID.
	 */
	public Set<Integer> addNewGroups(Set<Integer> selectedGroups) {
		TaggerSet<Integer> newEventGroupIds = new TaggerSet<Integer>();
		TaggerSet<TaggedEvent> selectedEvents = new TaggerSet<TaggedEvent>();
		TaggerSet<AbstractTagModel> tags = new TaggerSet<AbstractTagModel>();
		boolean eventSelected = false;
		for (Integer selectedGroup : selectedGroups) {
			for (TaggedEvent event : taggedEventSet) {
				if (selectedGroup.intValue() == event.getEventGroupId()) {
					selectedEvents.add(event);
					groupIdCounter++;
					event.addGroup(groupIdCounter);
					newEventGroupIds.add(Integer.valueOf(groupIdCounter));
					eventSelected = true;
				}
			}
		}
		if (eventSelected) {
			HistoryItem historyItem = new HistoryItem();
			historyItem.type = TaggerHistory.Type.GROUPS_ADDED;
			historyItem.events = selectedEvents;
			historyItem.groupIds = newEventGroupIds;
			historyItem.tags = tags;
			history.add(historyItem);
		}
		return newEventGroupIds;
	}

	/**
	 * Creates a new tag model with the given parent and given name, and adds it
	 * to the hierarchy. Creates an entry in the history.
	 * 
	 * @param parent
	 *            The AbstractTagModel representing the parent tag for the new
	 *            tag (may be null if the tag is at the top level of the
	 *            hierarchy).
	 * @param name
	 *            The name of the new tag.
	 * @return The tag model if the add was successful, null otherwise
	 *         (duplicate tags).
	 */
	public AbstractTagModel addNewTag(AbstractTagModel parent, String name) {
		GuiTagModel newTag = (GuiTagModel) factory.createAbstractTagModel(this);
		GuiTagModel parentTag = (GuiTagModel) parent;
		String parentPath = new String();
		Highlight[] highlights = GuiTagModel.Highlight.values();
		if (parent != null) {
			parentPath = parent.getPath();
			int parentHighlightPosition = findHighlightPosition(highlights, parentTag.getHighlight());
			if (parentHighlightPosition >= 0) {
				int childHighlightPosition = parentHighlightPosition + 1;
				newTag.setHighlight(highlights[childHighlightPosition]);
			}
		} else {
			newTag.setHighlight(Highlight.GREY_VERY_VERY_LIGHT);
		}
		newTag.setPath(parentPath + "/" + name);
		newTag.setInEdit(true);
		if (addTagModelBase(newTag)) {
			HistoryItem historyItem = new HistoryItem();
			historyItem.type = TaggerHistory.Type.TAG_ADDED;
			historyItem.tagModel = newTag;
			history.add(historyItem);
			return newTag;
		}
		return null;
	}

	/**
	 * Adds the tag model to the correct place in the tag list. If it has a
	 * parent tag, it will be added following its parent. If not, it will be
	 * added to the end of the list.
	 * 
	 * @param newTagModel
	 *            The AbstractTagModel that represents the tag to be associated.
	 */
	public boolean addTagModelBase(AbstractTagModel newTagModel) {
		if (newTagModel.getParentPath() == null) {
			return tagList.add(newTagModel);
		}
		String parentPath = newTagModel.getParentPath();
		int i = 0;
		for (; i < tagList.size(); i++) {
			AbstractTagModel tagModel = tagList.get(i);
			if (tagModel.getPath().equals(parentPath)) {
				break;
			}
		}
		for (; i < tagList.size(); i++) {
			AbstractTagModel tagModel = tagList.get(i);
			if (!tagModel.getPath().startsWith(parentPath)) {
				break;
			}
		}
		if (tagList.add(i, newTagModel)) {
			updateTagLists();
			sortRRTags();
			return true;
		}
		return false;
	}

	public boolean addTagModelBase(int index, AbstractTagModel newTagModel) {
		if (tagList.add(index, newTagModel)) {
			updateTagLists();
			sortRRTags();
			return true;
		}
		return false;
	}

	/**
	 * Associates the tag to the group ids. Adds an entry in the history.
	 * 
	 * @param tagModel
	 *            The AbstractTagModel that represents the tag to be associated.
	 * @param groupIds
	 *            The set of group IDs to associate the tag to.
	 */
	public void associate(AbstractTagModel tagModel, Set<Integer> groupIds) {
		Set<Integer> affectedGroups = associateBase(tagModel, groupIds);
		if (!affectedGroups.isEmpty()) {
			HistoryItem historyItem = new HistoryItem();
			historyItem.type = TaggerHistory.Type.ASSOCIATED;
			historyItem.groupsIds = affectedGroups;
			historyItem.tagModel = tagModel;
			history.add(historyItem);
		}
	}

	/**
	 * Associates the tag to the group ids. Adds an entry in the history.
	 * 
	 * @param tagModel
	 *            The AbstractTagModel that represents the tag to be associated.
	 * @param index
	 *            The index to add the tag in the event group.
	 * @param groupIds
	 *            The set of group IDs to associate the tag to.
	 */
	public void associate(AbstractTagModel tagModel, int index, Set<Integer> groupIds) {
		Set<Integer> affectedGroups = associateBase(tagModel, index, groupIds);
		if (!affectedGroups.isEmpty()) {
			HistoryItem historyItem = new HistoryItem();
			historyItem.type = TaggerHistory.Type.ASSOCIATED;
			historyItem.groupsIds = affectedGroups;
			historyItem.tagModel = tagModel;
			history.add(historyItem);
		}
	}

	/**
	 * Associates the tag to the group IDs. Adds an entry in the history.
	 * 
	 * @param historyItem
	 *            The HistoryItem containing the history.
	 * @param tagModel
	 *            The AbstractTagModel that represents the tag to be associated.
	 * @param groupIds
	 *            The set of group IDs to associate the tag to.
	 */
	public void associate(HistoryItem historyItem, AbstractTagModel tagModel, Set<Integer> groupIds) {
		Set<Integer> affectedGroups = associateBase(tagModel, groupIds);
		if (!affectedGroups.isEmpty()) {
			historyItem.type = TaggerHistory.Type.ASSOCIATED;
			historyItem.groupsIds = affectedGroups;
			historyItem.tagModel = tagModel;
			history.add(historyItem);
		}
	}

	/**
	 * Associates the tag to the group IDs.
	 * 
	 * @param tagModel
	 *            The AbstractTagModel that represents the tag to be associated.
	 * @param index
	 *            The index to add the tag in the event group.
	 * @param groupIds
	 *            The set of group IDs to associate the tag to.
	 */
	public Set<Integer> associateBase(AbstractTagModel tagModel, int index, Set<Integer> groupIds) {
		Set<Integer> affectedGroups = new HashSet<Integer>();
		for (Integer groupId : groupIds) {
			TaggedEvent taggedEvent = getTaggedEventFromGroupId(groupId);
			if (taggedEvent.addTagToGroup(groupId, tagModel, index)) {
				affectedGroups.add(groupId);
			}
		}
		return affectedGroups;
	}

	/**
	 * Associates the tag to the group IDs.
	 * 
	 * @param tagModel
	 *            The AbstractTagModel that represents the tag to be associated.
	 * @param groupIds
	 *            The set of group IDs to associate the tag to.
	 */
	public Set<Integer> associateBase(AbstractTagModel tagModel, Set<Integer> groupIds) {
		Set<Integer> affectedGroups = new HashSet<Integer>();
		for (Integer groupId : groupIds) {
			TaggedEvent taggedEvent = getTaggedEventFromGroupId(groupId);
			if (taggedEvent.addTagToGroup(groupId, tagModel)) {
				affectedGroups.add(groupId);
			}
		}
		return affectedGroups;
	}

	/**
	 * Builds the event JSON models from the current state of the egtSet.
	 * 
	 * @return <code>Set<EventJsonModel></code> constructed
	 */
	private Set<EventJsonModel> buildEventJsonModels() {
		Set<EventJsonModel> result = new LinkedHashSet<EventJsonModel>();
		for (TaggedEvent event : taggedEventSet) {
			EventJsonModel jsonEvent = new EventJsonModel();
			jsonEvent.setCode(event.getEventModel().getCode());
			List<List<String>> tags = new ArrayList<List<String>>();
			for (Map.Entry<Integer, TaggerSet<AbstractTagModel>> entry : event.getTagGroups().entrySet()) {
				if (entry.getKey() == event.getEventGroupId()) {
					// Event level tags
					for (AbstractTagModel tag : entry.getValue()) {
						ArrayList<String> eventTags = new ArrayList<String>();
						eventTags.add(tag.getPath());
						tags.add(eventTags);
					}
				} else {
					// Tag groups
					ArrayList<String> groupTags = new ArrayList<String>();
					for (AbstractTagModel tag : entry.getValue()) {
						groupTags.add(tag.getPath());
					}
					tags.add(groupTags);
				}
			}
			jsonEvent.setTags(tags);
			result.add(jsonEvent);
		}
		return result;
	}

	/**
	 * Builds the XML model of the data.
	 * 
	 * @return An XML model representing the data.
	 */
	private TaggerDataXmlModel buildSavedDataModel() {
		TaggerDataXmlModel savedDataModel = new TaggerDataXmlModel();
		savedDataModel.setEventSetXmlModel(eventToXmlModel());
		HedXmlModel hedModel = new HedXmlModel();
		TagXmlModel dummy = tagsToXmlModel();
		hedModel.setTags(dummy.getTags());
		hedModel.setVersion(version);
		savedDataModel.setHedXmlModel(hedModel);
		savedDataModel.getHedXmlModel().setUnitClasses(unitClassesToXmlModel());
		return savedDataModel;
	}

	/**
	 * Checks whether tags can be edited given the load options.
	 * 
	 * @return True if tags can be edited, false if editing is not allowed.
	 */
	public boolean canEditTags() {
		return editTags;
	}

	/**
	 * Combines the columns represented in an array.
	 * 
	 * @param delimiter
	 *            The delimiter used to separate the elements in the array.
	 * @param cols
	 *            The column values.
	 * @param colNums
	 *            The indecies used to combine the column values.
	 * @return A string representing the column values combined.
	 */
	private String combineColumns(String delimiter, String[] cols, int[] colNums) {
		String combinedCols = new String();
		for (int i = 0; i < colNums.length; i++) {
			try {
				if (!cols[colNums[i] - 1].trim().isEmpty())
					combinedCols += delimiter + cols[colNums[i] - 1].trim().replaceAll("~", ",~,");
			} catch (Exception ex) {
				continue;
			}
		}
		combinedCols = combinedCols.replaceFirst(delimiter, "");
		return combinedCols;
	}

	/**
	 * Creates a new TaggedEvent with the given code. The event returned has its
	 * code and tag groupID set.
	 * 
	 * @param code
	 *            The event code.
	 * @return TaggedEvent with code and tag groupID set.
	 */
	private TaggedEvent createNewEvent(String code) {
		GuiEventModel eventModel = (GuiEventModel) factory.createAbstractEventModel(this);
		eventModel.setCode(code);
		eventModel.setLabel(new String());
		TaggedEvent taggedEvent = new TaggedEvent(eventModel, this);
		int groupId = groupIdCounter++;
		taggedEvent.setEventGroupId(groupId);
		return taggedEvent;
	}

	/**
	 * Creates the tag set to be used in the Tagger from the given XML model.
	 * 
	 * @param tagXmlModels
	 *            A set of TagXmlModels that represent tags.
	 */
	private void createTagSetFromXml(Set<TagXmlModel> tagXmlModels) {
		tagLevel = 0;
		createTagSetRecursive(new String(), tagXmlModels, -1);
		sortRRTags();
	}

	/**
	 * Creates the tag set from the given XML models by recursively traversing
	 * the hierarchy for each top-level tag model. It also builds lists of
	 * required, recommended, and unique tags in the hierarchy.
	 * 
	 * @param path
	 *            The tag path.
	 * @param tagXmlModels
	 *            A set of TagXmlModels that represent tags.
	 * @param level
	 *            The level of the tag.
	 */
	private int createTagSetRecursive(String path, Set<TagXmlModel> tagXmlModels, int level) {
		tagLevel = Math.max(tagLevel, level);
		level++;
		Object[] highlights = Arrays.copyOfRange(GuiTagModel.Highlight.values(), 4,
				GuiTagModel.Highlight.values().length);
		AbstractTagModel parentTag = tagFound(path);
		for (TagXmlModel tagXmlModel : tagXmlModels) {
			AbstractTagModel tagModel = factory.createAbstractTagModel(this);
			if (path.isEmpty())
				tagModel.setPath(tagXmlModel.getName());
			else
				tagModel.setPath(path + "/" + tagXmlModel.getName());
			tagModel.setDescription(tagXmlModel.getDescription());
			tagModel.setChildRequired(tagXmlModel.isChildRequired());
			tagModel.setTakesValue(tagXmlModel.takesValue());
			tagModel.setRecommended(tagXmlModel.isRecommended());
			tagModel.setRequired(tagXmlModel.isRequired());
			tagModel.setUnique(tagXmlModel.isUnique());
			if (parentTag != null && PredicateType.PROPERTYOF.equals(parentTag.getPredicateType())) {
				tagModel.setPredicateType(PredicateType.PROPERTYOF);
			} else {
				tagModel.setPredicateType(PredicateType.valueOf(tagXmlModel.getPredicateType().toUpperCase()));
			}
			tagModel.setPosition(tagXmlModel.getPosition());
			tagModel.setIsNumeric(tagXmlModel.isNumeric());
			tagModel.setUnitClass(tagXmlModel.getUnitClass());
			tagList.add(tagModel);
			GuiTagModel guiTagModel = (GuiTagModel) tagModel;
			guiTagModel.setHighlight((Highlight) highlights[level]);
			if (tagModel.isRequired()) {
				requiredTags.add(tagModel);
			} else if (tagModel.isRecommended()) {
				recommendedTags.add(tagModel);
			}
			if (tagModel.isUnique()) {
				uniqueTags.add(tagModel);
			}
			if (path.isEmpty())
				createTagSetRecursive(tagXmlModel.getName(), tagXmlModel.getTags(), level);
			else
				createTagSetRecursive(path + "/" + tagXmlModel.getName(), tagXmlModel.getTags(), level);
		}
		return level;
	}

	/**
	 * Creates a tag model that is an instance of a tag that takes values. It
	 * sets the name according to the value string.
	 * 
	 * @param valueTag
	 *            The AbstractTagModel representing the tag used to create a
	 *            transient tag.
	 * @param value
	 *            The value associated with the tag.
	 * @return A AbstractTagModel representing the transient tag.
	 */
	public AbstractTagModel createTransientTagModel(AbstractTagModel valueTag, String value) {
		AbstractTagModel tag = factory.createAbstractTagModel(this);
		String valueStr = valueTag.getName().replace("#", value);
		tag.setPath(valueTag.getParentPath() + "/" + valueStr);
		return tag;
	}

	/**
	 * Stores the tag unit classes in a HashMap.
	 * 
	 * @param unitClassesXmlModels
	 *            A UnitClassesXmlModel that represents the tag unit classes.
	 */
	private void createUnitClassHashMapFromXml(UnitClassesXmlModel unitClassesXmlModels) {
		for (UnitClassXmlModel unitClassXmlModel : unitClassesXmlModels.getUnitClasses()) {
			unitClasses.put(unitClassXmlModel.getName(), unitClassXmlModel.getUnits());
			unitClassDefaults.put(unitClassXmlModel.getName(), unitClassXmlModel.getDefault());
		}
	}

	public IFactory getFactory() {
		return factory;
	}

	/**
	 * Deletes the given tag and all of its descendants. Creates an entry in the
	 * history.
	 * 
	 * @param tag
	 *            The AbstractTagModel representing the tag to delete.
	 */
	public void deleteTag(AbstractTagModel tag) {
		int tagPosition = tagList.indexOf(tag);
		TaggerSet<AbstractTagModel> removedTags = deleteTagBase(tag);
		HistoryItem historyItem = new HistoryItem();
		historyItem.type = TaggerHistory.Type.TAG_REMOVED;
		historyItem.tagModel = tag;
		historyItem.tagModelPosition = tagPosition;
		historyItem.tags = removedTags;
		history.add(historyItem);
	}

	/**
	 * Deletes the given tag and all of its descendants.
	 * 
	 * @param The
	 *            The AbstractTagModel representing the tag to delete.
	 * @return A set of the tags deleted.
	 */
	public TaggerSet<AbstractTagModel> deleteTagBase(AbstractTagModel tag) {
		TaggerSet<AbstractTagModel> removedTags = new TaggerSet<AbstractTagModel>();
		String path = tag.getPath();
		tagList.remove(tag);
		removedTags.add(tag);
		String prefix = path + "/"; // Prefix for descendants
		Iterator<AbstractTagModel> it = tagList.iterator();
		while (it.hasNext()) {
			AbstractTagModel currentTag = it.next();
			if (currentTag.getPath().startsWith(prefix)) {
				it.remove();
				removedTags.add(currentTag);
			}
		}
		updateTagLists();
		return removedTags;
	}

	/**
	 * Edits the event code for an event. Saves the original event code to
	 * history.
	 * 
	 * @param event
	 *            The AbstractEventModel representing the event to edit.
	 * @param code
	 *            The new event code.
	 */
	public void editEventCode(AbstractEventModel event, String code) {
		AbstractEventModel copy = editEventCodeBase(event, code);
		HistoryItem historyItem = new HistoryItem();
		historyItem.type = TaggerHistory.Type.EVENT_EDITED;
		historyItem.eventModel = event;
		historyItem.eventModelCopy = copy;
		history.add(historyItem);
	}

	/**
	 * Edits the event code for an event.
	 * 
	 * @param event
	 *            The AbstractEventModel representing the event to edit.
	 * @param code
	 *            The new event code.
	 * @return A copy of the event model with the original (replaced) event
	 *         code.
	 */
	public AbstractEventModel editEventCodeBase(AbstractEventModel event, String code) {
		AbstractEventModel copy = factory.createAbstractEventModel(this);
		copy.setCode(event.getCode());
		event.setCode(code);
		return copy;
	}

	/**
	 * Edits the event label for an event. Saves the original event label to
	 * history.
	 * 
	 * @param taggedEvent
	 *            The TaggedEvent representing the event to edit.
	 * @param tag
	 *            The AbstractTagModel representing the tag to edit.
	 * @param code
	 *            The new event code.
	 * @param label
	 *            The new event label.
	 */
	public void editEventCodeLabel(TaggedEvent taggedEvent, AbstractTagModel tag, String code, String label) {
		AbstractEventModel copy = editEventCodeLabelBase(taggedEvent.getEventModel(), code, label);
		HistoryItem historyItem = new HistoryItem();
		historyItem.event = taggedEvent;
		historyItem.eventModel = taggedEvent.getEventModel();
		historyItem.eventModelCopy = copy;
		if (tag != null && !label.trim().isEmpty()) {
			historyItem.type = TaggerHistory.Type.EVENT_EDITED;
			historyItem.tagModel = tag;
			tag.setPath(LabelTag + label);
			historyItem.tagModelCopy = (GuiTagModel) tag;
			history.add(historyItem);
		} else if (tag != null && label.trim().isEmpty()) {
			TreeMap<Integer, TaggerSet<AbstractTagModel>> tagGroups = taggedEvent.getTagGroups();
			unassociate(historyItem, tag, tagGroups.keySet());
		} else if (tag == null && !label.trim().isEmpty()) {
			AbstractTagModel labelTag = getTagModel(LabelTag + label);
			TreeMap<Integer, TaggerSet<AbstractTagModel>> tagGroups = taggedEvent.getTagGroups();
			if (taggedEvent.isInFirstEdit()) {
				associateBase(labelTag, tagGroups.keySet());
			} else {
				associate(historyItem, labelTag, tagGroups.keySet());
			}
		}
	}

	/**
	 * Edits the event label for an event. Saves the original event label to
	 * history.
	 * 
	 * @param event
	 *            The AbstractEventModel representing the event to edit.
	 * @param code
	 *            The new event code.
	 * @param label
	 *            The new event label.
	 */
	public AbstractEventModel editEventCodeLabelBase(AbstractEventModel event, String code, String label) {
		AbstractEventModel copy = factory.createAbstractEventModel(this);
		copy.setCode(event.getCode());
		event.setCode(code);
		copy.setLabel(event.getLabel());
		event.setLabel(label);
		return copy;
	}

	/**
	 * Edits the event label for an event. Saves the original event label to
	 * history.
	 * 
	 * @param event
	 *            The AbstractEventModel representing the event to edit.
	 * @param label
	 *            The new event label.
	 */
	public void editEventLabel(AbstractEventModel event, String label) {
		AbstractEventModel copy = editEventLabelBase(event, label);
		HistoryItem historyItem = new HistoryItem();
		historyItem.type = TaggerHistory.Type.EVENT_EDITED;
		historyItem.eventModel = event;
		historyItem.eventModelCopy = copy;
		history.add(historyItem);

	}

	/**
	 * Edits the event label for an event.
	 * 
	 * @param event
	 *            The AbstractEventModel representing the event to edit.
	 * @param label
	 *            The new event label.
	 * @return A copy of the event model with the original (replaced) event
	 *         label.
	 */
	public AbstractEventModel editEventLabelBase(AbstractEventModel event, String label) {
		AbstractEventModel copy = factory.createAbstractEventModel(this);
		copy.setLabel(event.getLabel());
		event.setLabel(label);
		return copy;
	}

	/**
	 * Edits the given tag's information with the given parameters. Stores a
	 * copy of the original tag in the history.
	 * 
	 * @param tag
	 *            The GuiTagModel representing the tag.
	 * @param name
	 *            The tag name.
	 * @param description
	 *            The tag description.
	 * @param childRequired
	 *            True if the tag requires a child, false if otherwise.
	 * @param takesValue
	 *            True if the tag takes a value, false if otherwise. * @param
	 *            takesValue True if the tag takes a value, false if otherwise.
	 * @param isNumeric
	 *            True if the tag is numerical, false if otherwise.
	 * @param required
	 *            True if the tag is required, false if otherwise.
	 * @param recommended
	 *            True if the tag is recommended, false if otherwise.
	 * @param unique
	 *            True if the tag is unique, false if otherwise.
	 * @param position
	 *            The tag position.
	 */
	public void editTag(GuiTagModel tag, String name, String description, boolean childRequired, boolean takesValue,
			boolean isNumeric, boolean required, boolean recommended, boolean unique, Integer position,
			PredicateType predicateType) {
		GuiTagModel copy = editTagBase(tag, name, description, childRequired, takesValue, isNumeric, required,
				recommended, unique, position, predicateType);
		if (!tag.isFirstEdit()) {
			HistoryItem historyItem = new HistoryItem();
			historyItem.type = TaggerHistory.Type.TAG_EDITED;
			historyItem.tagModelCopy = copy;
			historyItem.tagModel = tag;
			history.add(historyItem);
		}
	}

	/**
	 * Edits the given tag's information with the given parameters.
	 * 
	 * @param tag
	 *            The GuiTagModel representing the tag.
	 * @param name
	 *            The tag name.
	 * @param description
	 *            The tag description.
	 * @param childRequired
	 *            True if the tag requires a child, false if otherwise.
	 * @param takesValue
	 *            True if the tag takes a value, false if otherwise. * @param
	 *            takesValue True if the tag takes a value, false if otherwise.
	 * @param isNumeric
	 *            True if the tag is numerical, false if otherwise.
	 * @param required
	 *            True if the tag is required, false if otherwise.
	 * @param recommended
	 *            True if the tag is recommended, false if otherwise.
	 * @param unique
	 *            True if the tag is unique, false if otherwise.
	 * @param position
	 *            The tag position.
	 * @return A copy of the tag model with the original (replaced) information.
	 */
	public GuiTagModel editTagBase(GuiTagModel tag, String name, String description, boolean childRequired,
			boolean takesValue, boolean isNumeric, boolean required, boolean recommended, boolean unique,
			Integer position, PredicateType predicateType) {
		GuiTagModel copy = (GuiTagModel) factory.createAbstractTagModel(this);
		copy.setPath(tag.getPath());
		copy.setDescription(tag.getDescription());
		copy.setChildRequired(tag.isChildRequired());
		copy.setTakesValue(tag.takesValue());
		copy.setIsNumeric(tag.isNumeric());
		copy.setRequired(tag.isRequired());
		copy.setRecommended(tag.isRecommended());
		copy.setUnique(tag.isUnique());
		copy.setPosition(tag.getPosition());
		copy.setPredicateType(tag.getPredicateType());
		if (!name.isEmpty()) {
			updateTagName(tag, name);
		}
		if (description != null) {
			tag.setDescription(description);
		}
		tag.setChildRequired(childRequired);
		tag.setTakesValue(takesValue);
		tag.setIsNumeric(isNumeric);
		tag.setRequired(required);
		tag.setRecommended(recommended);
		tag.setUnique(unique);
		tag.setPosition(position);
		tag.setPredicateType(predicateType);
		updateTagLists();
		return copy;
	}

	/**
	 * Edits the given tag's information with the given parameters.
	 * 
	 * @param tag
	 *            The GuiTagModel representing the tag.
	 * @param path
	 *            The tag path.
	 * @param name
	 *            The tag name.
	 * @param description
	 *            The tag description.
	 * @param childRequired
	 *            True if the tag requires a child, false if otherwise.
	 * @param takesValue
	 *            True if the tag takes a value, false if otherwise.
	 * @param required
	 *            True if the tag is required, false if otherwise.
	 * @param recommended
	 *            True if the tag is recommended, false if otherwise.
	 * @param unique
	 *            True if the tag is unique, false if otherwise.
	 * @param position
	 *            The tag position.
	 * @return A copy of the tag model with the original (replaced) information.
	 */
	public GuiTagModel editTagBase(GuiTagModel tag, String path, String name, String description, boolean childRequired,
			boolean takesValue, boolean required, boolean recommended, boolean unique, Integer position) {
		GuiTagModel copy = (GuiTagModel) factory.createAbstractTagModel(this);
		copy.setPath(tag.getPath());
		copy.setDescription(tag.getDescription());
		copy.setChildRequired(tag.isChildRequired());
		copy.setTakesValue(tag.takesValue());
		copy.setRequired(tag.isRequired());
		copy.setRecommended(tag.isRecommended());
		copy.setUnique(tag.isUnique());
		copy.setPosition(tag.getPosition());
		tag.setPath(path);
		if (!name.isEmpty()) {
			updateTagName(tag, name);
		}
		if (description != null) {
			tag.setDescription(description);
		}
		tag.setChildRequired(childRequired);
		tag.setTakesValue(takesValue);
		tag.setRequired(required);
		tag.setRecommended(recommended);
		tag.setUnique(unique);
		tag.setPosition(position);
		updateTagLists();
		return copy;
	}

	/**
	 * Edits the given tag's information with the given parameters. Stores a
	 * copy of the original tag in the history.
	 * 
	 * @param taggedEvent
	 *            The TaggedEvent representing the event.
	 * @param tag
	 *            The GuiTagModel representing the tag.
	 * @param path
	 *            The tag path.
	 */
	public void editTagPath(TaggedEvent taggedEvent, GuiTagModel tag, String path) {
		HistoryItem historyItem = new HistoryItem();
		historyItem.type = TaggerHistory.Type.TAG_PATH_EDITED;
		historyItem.tagModelCopy = editTagPathBase(tag, path);
		String[] paths = path.split("/");
		tag.setPath(path);
		historyItem.tagModel = tag;
		if (path.startsWith("/Event/Label/")) {
			historyItem.eventModelCopy = taggedEvent.getEventModel();
			if (path.equals("/Event/Label/")) {
				taggedEvent.getEventModel().setLabel(new String());
			} else {
				taggedEvent.getEventModel().setLabel(paths[paths.length - 1]);
			}
			historyItem.eventModel = taggedEvent.getEventModel();
		}
		history.add(historyItem);
	}

	/**
	 * Edits the given tag's information with the given parameters.
	 * 
	 * @param tag
	 *            GuiTagModel representing the tag to edit.
	 * @param path
	 *            The new path of the tag.
	 * @return A copy of the original GuiTagModel.
	 */
	public GuiTagModel editTagPathBase(GuiTagModel tag, String path) {
		GuiTagModel copy = (GuiTagModel) factory.createAbstractTagModel(this);
		copy.setPath(tag.getPath());
		tag.setPath(path);
		return copy;
	}

	/**
	 * Creates all of the XML models needed to represent the data in XML format.
	 * 
	 * @return Complete XML model containing all of the Tagger data to save,
	 *         ready to marshal with JAXB.
	 */
	private EventSetXmlModel eventToXmlModel() {
		EventSetXmlModel eventSetModel = new EventSetXmlModel();
		EventXmlModel currentEvent = null;
		GroupXmlModel currentGroup = null;
		for (TaggedEvent currentEventModel : taggedEventSet) {
			// Create event XML
			currentEvent = new EventXmlModel();
			currentEvent.setCode(currentEventModel.getEventModel().getCode());
			eventSetModel.addEvent(currentEvent);
			for (Entry<Integer, TaggerSet<AbstractTagModel>> tagGroup : currentEventModel.getTagGroups().entrySet()) {
				if (tagGroup.getKey() == currentEventModel.getEventGroupId()) {
					// Add event-level tags
					for (AbstractTagModel tag : tagGroup.getValue()) {
						currentEvent.addTag(tag.getPath());
					}
				} else {
					// Add tag groups
					currentGroup = new GroupXmlModel();
					for (AbstractTagModel tag : tagGroup.getValue()) {
						currentGroup.addTag(tag.getPath());
					}
					currentEvent.addGroup(currentGroup);
				}
			}
		}
		return eventSetModel;
	}

	public TaggedEvent findGroupInEvent(Set<Integer> groupIds) {
		TaggedEvent foundEvent = null;
		for (TaggedEvent event : taggedEventSet) {
			Iterator<Integer> groupIdIterator = groupIds.iterator();
			while (groupIdIterator.hasNext()) {
				if (event.containsGroup(groupIdIterator.next())) {
					foundEvent = event;
				}
			}
		}
		return foundEvent;
	}

	/**
	 * Finds the index containing the highlight.
	 * 
	 * @param highlights
	 *            An array containing all of the highlights.
	 * @param highlightValue
	 *            The highlight value being looked for.
	 * @return The index position containing the highlight if found, -1 if
	 *         otherwise.
	 */
	public int findHighlightPosition(Highlight[] highlights, Highlight highlightValue) {
		for (int i = 0; i < highlights.length; i++) {
			if (highlightValue.equals(highlights[i])) {
				return i;
			}
		}
		return -1;
	}

	/**
	 * Goes through the events in the Tagger to find missing required tags.
	 * 
	 * @return <code>List<EgtModel></code> containing the relevant events,
	 *         groups and tags.
	 */
	public List<EventModel> findMissingRequiredTags() {
		List<EventModel> result = new ArrayList<EventModel>();
		for (TaggedEvent event : taggedEventSet) {
			for (AbstractTagModel tag : requiredTags) {
				if (event.getRRValue(tag) == null) {
					result.add(new EventModel(event, event.getEventGroupId(), tag));
				}
			}
		}
		return result;
	}

	/**
	 * Formats the tag path.
	 * 
	 * @param tags
	 *            An array of tags.
	 * @return An array of formatted tags.
	 */
	private String[] formatTags(String[] tags) {
		List<String> tagsList = Arrays.asList(tags);
		for (int i = 0; i < tagsList.size(); i++) {
			if (tagsList.get(i) == null) {
				tagsList.remove(i);
			} else {
				tagsList.set(i, tagsList.get(i).trim().replaceAll("^/", ""));
				tagsList.set(i, tagsList.get(i).replaceAll("\"", ""));
			}
		}
		return tagsList.toArray(new String[tagsList.size()]);
	}

	/**
	 * Checks to see whether the given tag has only one child tag that takes
	 * values, and returns this child tag. It does not return a tag is the child
	 * tag does not take values or if there is more than one child tag.
	 * 
	 * @param tagModel
	 *            The AbstractTagModel representing the tag.
	 * @return A tag model of the child tag that takes values, if this exists,
	 *         or null otherwise.
	 */
	public AbstractTagModel getChildValueTag(AbstractTagModel tagModel) {
		int count = 0;
		AbstractTagModel valueTag = null;
		for (AbstractTagModel t : tagList) {
			if (t.getDepth() > tagModel.getDepth() && t.getPath().startsWith(tagModel.getPath() + "/")) {
				count++;
				if (t.takesValue()) {
					valueTag = t;
				}
			}
		}
		if (count == 1) {
			return valueTag;
		}
		return null;
	}

	public TaggerSet<TaggedEvent> getEgtSet() {
		return taggedEventSet;
	}

	/**
	 * Converts the HED hierarchy to XML and returns it as a string.
	 * 
	 * @return XML String representing the current HED hierarchy in the tagger.
	 */
	public String getHedXmlString() {
		StringWriter sw = new StringWriter();
		HedXmlModel hedModel = new HedXmlModel();
		TagXmlModel dummy = tagsToXmlModel();
		hedModel.setTags(dummy.getTags());
		try {
			JAXBContext context = JAXBContext.newInstance(HedXmlModel.class);
			Marshaller marshaller = context.createMarshaller();
			marshaller.setProperty(Marshaller.JAXB_FORMATTED_OUTPUT, true);
			marshaller.marshal(hedModel, sw);
		} catch (JAXBException e) {
			throw new RuntimeException("Unable to marshal HED XML String: " + e.getMessage());
		}
		return sw.toString();
	}

	public TaggerHistory getHistory() {
		return history;
	}

	/**
	 * Converts the tagged events to JSON format and returns the JSON as a
	 * string.
	 * 
	 * @return A string containing the current event data in the Tagger.
	 */
	public String getJsonEventsString() {
		Set<EventJsonModel> eventJsonModels = buildEventJsonModels();
		StringWriter sw = new StringWriter();
		ObjectMapper mapper = new ObjectMapper();
		ObjectWriter writer = mapper.writerWithDefaultPrettyPrinter();
		try {
			writer.writeValue(sw, eventJsonModels);
		} catch (JsonGenerationException e) {
			e.printStackTrace();
			throw new RuntimeException(e.toString());
		} catch (JsonMappingException e) {
			e.printStackTrace();
			throw new RuntimeException(e.toString());
		} catch (IOException e) {
			e.printStackTrace();
			throw new RuntimeException(e.toString());
		}
		return sw.toString();
	}

	/**
	 * Gets the recommended tags.
	 * 
	 * @return A set containing the recommended tags.
	 */
	public TaggerSet<AbstractTagModel> getRecommendedTags() {
		return recommendedTags;
	}

	/**
	 * Gets the message to display for the undo option.
	 * 
	 * @return message as a String
	 */
	public String getRedoMessage() {
		return history.getRedoMessage();
	}

	/**
	 * Gets the required tags.
	 * 
	 * @return A set containing the required tags.
	 */
	public TaggerSet<AbstractTagModel> getRequiredTags() {
		return requiredTags;
	}

	/**
	 * Searches the tag set for tags containing the given search text in their
	 * paths.
	 * 
	 * @param searchTextArg
	 *            The search text.
	 * @return A set of tag models matching the search parameter.
	 */
	public TaggerSet<GuiTagModel> getSearchTags(String searchTextArg) {
		TaggerSet<GuiTagModel> result = new TaggerSet<GuiTagModel>();
		if (searchTextArg.isEmpty()) {
			return null;
		}
		String searchText = searchTextArg.toLowerCase();
		for (AbstractTagModel tag : tagList) {
			if (tag.getPath().toLowerCase().indexOf(searchText) != -1) {
				result.add((GuiTagModel) tag);
			}
		}
		return result;
	}

	/**
	 * Finds the set of tag models representing the sub-hierarchy based at the
	 * given path.
	 * 
	 * @param baseTagPath
	 *            Path of tag to the be the base of the returned sub-hierarchy.
	 * @return A <code>TaggerSet</code> of the tag models in the sub-hierarchy
	 *         based at the given tag.
	 */
	public TaggerSet<AbstractTagModel> getSubHierarchy(String baseTagPath) {
		AbstractTagModel atm = factory.createAbstractTagModel(this);
		atm.setPath(baseTagPath);
		int startIdx = tagList.indexOf(atm);
		TaggerSet<AbstractTagModel> result = new TaggerSet<AbstractTagModel>();
		for (int i = startIdx; i < tagList.size(); i++) {
			AbstractTagModel currentTag = tagList.get(i);
			if (!currentTag.getPath().startsWith(baseTagPath)) {
				break;
			}
			result.add(currentTag);
		}
		return result;
	}

	/**
	 * Finds the evenandt that the given group ID belongs to, if it exists.
	 * 
	 * @param groupId
	 *            The group ID.
	 * @return The TaggedEvent with the given group ID.
	 */
	public TaggedEvent getTaggedEventFromGroupId(int groupId) {
		for (TaggedEvent tem : taggedEventSet) {
			if (tem.containsGroup(groupId)) {
				return tem;
			}
		}
		throw new RuntimeException("Unable to get event from groupid");
	}

	public int getTagLevel() {
		return tagLevel;
	}

	/**
	 * Finds and returns the tag model for the given path in the tag set. If
	 * there is no such tag model, it creates a new tag model and marks it as
	 * missing from the hierarchy.
	 * 
	 * @param path
	 *            The path of the tag.
	 * @return A tag model from the hierarchy with the given path or a tag model
	 *         not in the hierarchy with "missing" set to true.
	 */
	private AbstractTagModel getTagModel(String path) {
		AbstractTagModel valueTag = null;
		if (!"~".equals(path)) {
			List<String> pathAsList = splitPath(path);

			if (pathAsList.size() > 0) {
				// throw new RuntimeException("invalid path: " + path);
				String parentPath = path.substring(0, path.lastIndexOf('/'));
				for (AbstractTagModel tagModel : tagList) {
					if (tagModel.getPath().equals(path)) {
						return tagModel;
					} else if (tagModel.takesValue() && tagModel.getParentPath().equals(parentPath)) {
						if (matchTakesValueTag(tagModel.getName(), path.substring(path.lastIndexOf('/')))) {
							valueTag = tagModel;
							break;
						}
					}
				}
			}
		}
		// Missing tag model
		AbstractTagModel tagModel = factory.createAbstractTagModel(this);
		tagModel.setPath(path);
		if (valueTag == null) {
			((GuiTagModel) tagModel).setMissing(true);
		}
		return tagModel;
	}

	/**
	 * Returns the tag set sorted.
	 * 
	 * @return A sorted tag set.
	 */
	public SortedSet<AbstractTagModel> getTagSet() {
		return tagList;
	}

	/**
	 * Constructs the tab-delimited text string from the current state of the
	 * Tagger.
	 * 
	 * @return String containing tab-delimited text format of events.
	 */
	public String getTdtEventsString() {
		StringWriter sw = new StringWriter();
		BufferedWriter br = new BufferedWriter(sw);
		writeTabDelimitedTextFromEgt(br);
		try {
			br.close();
		} catch (IOException e) {
			System.err.println("Error writing events to string: " + e.getMessage());
			return null;
		}
		return sw.toString();
	}

	/**
	 * Gets the message to display for the undo option.
	 * 
	 * @return message as a String.
	 */
	public String getUndoMessage() {
		return history.getUndoMessage();
	}

	/**
	 * Finds a unique tag that is an ancestor of the given tag, if such a tag
	 * exists.
	 * 
	 * @param tag
	 *            The AbstractTagModel representing the tag.
	 * @return An ancestor tag that is unique, or null if there is no such tag.
	 */
	public AbstractTagModel getUniqueKey(AbstractTagModel tag) {
		for (AbstractTagModel currentTag : uniqueTags) {
			String currentPrefix = currentTag.getPath() + "/";
			if (tag.getPath().startsWith(currentPrefix)) {
				return currentTag;
			}
		}
		return null;
	}

	/**
	 * Gets the unique tags.
	 * 
	 * @return A set containing the unique tags.
	 */
	public TaggerSet<AbstractTagModel> getUniqueTags() {
		return uniqueTags;
	}

	/**
	 * Builds the XML model of the data and returns it as a string.
	 * 
	 * @return A XML String of the current data.
	 */
	public String getXmlDataString() {
		StringWriter sw = new StringWriter();
		TaggerDataXmlModel savedDataModel = buildSavedDataModel();
		try {
			JAXBContext context = JAXBContext.newInstance(TaggerDataXmlModel.class);
			Marshaller marshaller = context.createMarshaller();
			marshaller.setProperty(Marshaller.JAXB_FORMATTED_OUTPUT, true);
			marshaller.marshal(savedDataModel, sw);
		} catch (JAXBException e) {
			throw new RuntimeException("Unable to marshal XML data: " + e.getMessage());
		}
		return sw.toString();
	}

	/**
	 * Checks whether the given tag has any child tags.
	 * 
	 * @param tagModel
	 *            The AbstractTagModel representing the tag.
	 * @return True if the tag has at least one child tag, false otherwise.
	 */
	public boolean hasChildTags(AbstractTagModel tagModel) {
		for (AbstractTagModel t : tagList) {
			if (t.getDepth() > tagModel.getDepth() && t.getPath().startsWith(tagModel.getPath() + "/")) {
				return true;
			}
		}
		return false;
	}

	/**
	 * Checks whether the tagger currently contains any required or recommended
	 * tags.
	 * 
	 * @return True if required or recommended tags exist, false otherwise.
	 */
	public boolean hasRRTags() {
		return (requiredTags.size() > 0 || recommendedTags.size() > 0);
	}

	/**
	 * Checks whether a tag path already exists in the hierarchy for a tag to be
	 * edited.
	 * 
	 * @param tagPath
	 *            The new tag path for a tag to be edited.
	 * @param tagModel
	 *            The tag model being edited.
	 * @return True if the given tag path would cause a duplicate tag, false
	 *         otherwise.
	 */
	public boolean isDuplicate(String tagPath, AbstractTagModel tagModel) {
		for (AbstractTagModel tag : tagList) {
			if (tag.getPath().equals(tagPath) && !tag.equals(tagModel)) {
				return true;
			}
		}
		return false;
	}

	/**
	 * Checks whether the given tag is required or recommended.
	 * 
	 * @param tag
	 *            The AbstractTagModel representing the tag.
	 * @return True if the tag is required or recommended, false otherwise.
	 */
	public boolean isRRValue(AbstractTagModel tag) {
		for (AbstractTagModel currentTag : requiredTags) {
			String currentPrefix = currentTag.getPath() + "/";
			if (tag.getPath().startsWith(currentPrefix)) {
				return true;
			}
		}
		for (AbstractTagModel currentTag : recommendedTags) {
			String currentPrefix = currentTag.getPath() + "/";
			if (tag.getPath().startsWith(currentPrefix)) {
				return true;
			}
		}
		return false;
	}

	/**
	 * Loads the data from the given file. Data is expected in the TaggerData
	 * format, containing the XML representation of the EGT set and of the HED
	 * hierarchy.
	 * 
	 * @param savedData
	 *            A File to load saved data from.
	 * @return True if the data was loaded successfully, false otherwise.
	 */
	public boolean loadEventsAndHED(File savedData) {
		// Unmarshal saved data from file
		TaggerDataXmlModel savedDataXmlModel = null;
		try {
			JAXBContext context = JAXBContext.newInstance(TaggerDataXmlModel.class);
			savedDataXmlModel = (TaggerDataXmlModel) context.createUnmarshaller().unmarshal(savedData);
		} catch (Exception e) {
			System.err.println("Unable to read XML file: " + e.getMessage());
			return false;
		}
		if (savedDataXmlModel == null) {
			System.err.println("Unable to read XML file " + "- unmarshal returned null");
			return false;
		}
		return processXmlData(savedDataXmlModel);
	}

	public boolean loadHED(File hedFile) {
		try {
			HedXmlModel hedXmlModel = ReadHEDXml(hedFile);
			populateTagList(hedXmlModel);
		} catch (Exception e) {
			System.err.println("Unable to load HED XML:\n" + e.getMessage());
			return false;
		}
		return true;
	}

	/**
	 * Loads the data from the given files, with the EGT set represented either
	 * by JSON or by the tab-delimited text format.
	 * 
	 * @param egtFile
	 *            File containing EGT data in either JSON or the tab-delimited
	 *            text format.
	 * @param hedFile
	 *            File containing HED hierarchy XML.
	 * @return True if the data loaded successfully, false if an error occurred.
	 */
	public boolean loadJSON(File egtFile, File hedFile) {
		taggedEventSet = new TaggerSet<TaggedEvent>();
		try {
			Set<EventJsonModel> eventJsonModels = populateJSONList(egtFile);
			populateEventsFromJson(eventJsonModels);
			HedXmlModel hedXmlModel = ReadHEDXml(hedFile);
			populateTagList(hedXmlModel);
		} catch (Exception e) {
			System.err.println("Unable to load JSON:\n" + e.getMessage());
			return false;
		}
		return true;
	}

	public boolean loadTabDelimited(File egtFile, File hedFile, int header, int[] eventCodeColumn, int[] tagColumns) {
		try {
			BufferedReader egtReader = new BufferedReader(new FileReader(egtFile));
			populateEventsFromTabDelimitedText(egtReader, header, eventCodeColumn, tagColumns);
			egtReader.close();
			HedXmlModel hedXmlModel = ReadHEDXml(hedFile);
			populateTagList(hedXmlModel);
		} catch (Exception e) {
			System.err.println("Unable to read delimited file: " + egtFile.getPath() + ": " + e.getMessage());
			return false;
		}
		return true;
	}

	/**
	 * Loads the data from the given files, with the EGT set represented either
	 * by JSON or by the tab-delimited text format.
	 * 
	 * @param egtFile
	 *            File containing EGT data in either JSON or the tab-delimited
	 *            text format.
	 * @param hedFile
	 *            File containing HED hierarchy XML.
	 * @param header
	 *            The number of header lines.
	 * @param eventCodeColumn
	 *            The event code column(s).
	 * @param tagColumns
	 *            The event tag column(s).
	 * @return True if the data loaded successfully, false if an error occurred.
	 */
	public boolean loadTabDelimitedEvents(File egtFile, int header, int[] eventCodeColumn, int[] tagColumns) {
		try {
			BufferedReader egtReader = new BufferedReader(new FileReader(egtFile));
			populateEventsFromTabDelimitedText(egtReader, header, eventCodeColumn, tagColumns);
			egtReader.close();
		} catch (Exception e) {
			System.err.println("Unable to read delimited file: " + egtFile.getPath() + ": " + e.getMessage());
			return false;
		}
		return true;
	}

	/**
	 * Attempts to find a tag match in the given sub-hierarchy. Checks all tags
	 * that do not take values followed by tags that take values to find the
	 * most specific match possible.
	 * 
	 * @param parentPath
	 *            The parent path of the tag.
	 * @param tag
	 *            The AbstractTagModel representing the tag.
	 * @return The tag matched in the given sub-hierarchy if found, null if
	 *         otherwise.
	 */
	private AbstractTagModel matchSubhierarchy(String parentPath, AbstractTagModel tag) {
		TaggerSet<AbstractTagModel> takesValueTags = new TaggerSet<AbstractTagModel>();
		for (AbstractTagModel childTag : getSubHierarchy(parentPath)) {
			if (childTag.takesValue()) {
				takesValueTags.add(childTag);
				continue;
			}
			if (childTag.getPath().equals(tag.getPath())) {
				return childTag;
			}
		}
		for (AbstractTagModel takesValueTag : takesValueTags) {
			if (matchTakesValueTag(takesValueTag.getName(), tag.getName())) {
				return takesValueTag;
			}
		}
		return null;
	}

	/**
	 * Checks if the given tag name matches a tag that takes values.
	 * 
	 * @param valueString
	 *            The name of a tag that takes values to check against.
	 * @param tagName
	 *            The name of the tag to check.
	 * @return True if the tag name matches, false otherwise.
	 */
	private boolean matchTakesValueTag(String valueString, String tagName) {
		String before = valueString.substring(0, valueString.indexOf('#'));
		String after = valueString.substring(valueString.indexOf('#') + 1, valueString.length());
		if (tagName.startsWith(before) && tagName.endsWith(after)) {
			return true;
		}
		return false;
	}

	/**
	 * Opens any collapsed ancestors of the given tag so that the tag is visible
	 * in the tag panel, if it exists, and highlights the closest matched tag.
	 * 
	 * @param tag
	 *            The AbstractTagModel representing the tag.
	 * @return The tag model passed in, if it is in the tag list, or the closest
	 *         ancestor found otherwise. It returns null if the tag has no
	 *         ancestors in the tag list.
	 */
	public AbstractTagModel openToClosest(AbstractTagModel tag) {
		List<String> path = splitPath(tag.getPath());
		String currentPath = "";
		AbstractTagModel lastOpened = null;
		tagLoop: for (int i = 0, j = 0; i < path.size(); i++, j++) {
			currentPath += "/" + path.get(i);
			for (; j < tagList.size(); j++) {
				AbstractTagModel currentTag = tagList.get(j);
				// Match tag that takes value
				if (currentTag.takesValue() && i == path.size() - 1
						&& currentTag.getParentPath().equals(tag.getParentPath())) {
					AbstractTagModel match = matchSubhierarchy(currentTag.getParentPath(), tag);
					if (match != null) {
						((GuiTagModel) currentTag).setCollapsed(false);
						lastOpened = match;
						break tagLoop;
					}
				}
				// Match tag or ancestor
				if (currentTag.getPath().equals(currentPath)) {
					if (!currentPath.equals(tag.getPath())) {
						((GuiTagModel) currentTag).setCollapsed(false);
					}
					lastOpened = currentTag;
					break;
				}
			}
		}
		updateTagHighlights(false);
		highlightTag = (GuiTagModel) lastOpened;
		if (highlightTag != null) {
			previousHighlightType = highlightTag.getHighlight();
			if (highlightTag.equals(tag)) {
				currentHighlightType = Highlight.HIGHLIGHT_MATCH;
			} else if (highlightTag.takesValue()) {
				currentHighlightType = Highlight.HIGHLIGHT_TAKES_VALUE;
			} else {
				currentHighlightType = Highlight.HIGHLIGHT_CLOSE_MATCH;
			}
		}
		return lastOpened;
	}

	/**
	 * Creates the event models (depending on the factory given) to be used in
	 * the Tagger from the JSON models. Assumes the EGT set has been created and
	 * is empty. If no code is available for the event, the event label is used.
	 * 
	 * @param eventJsonModels
	 *            A set of events represented in JSON format.
	 */
	private boolean populateEventsFromJson(Set<EventJsonModel> eventJsonModels) {
		TaggerSet<TaggedEvent> taggerSetTemp = new TaggerSet<TaggedEvent>();
		for (EventJsonModel eventJsonModel : eventJsonModels) {
			// Create event model
			TaggedEvent taggedEvent = createNewEvent(eventJsonModel.getCode());
			// Add tags to event
			int groupId;
			if (eventJsonModel.getTags() != null) {
				for (List<String> tagList : eventJsonModel.getTags()) {
					if (tagList.size() > 1) {
						// Add tag group
						groupId = groupIdCounter++;
						taggedEvent.addGroup(groupId);
						for (String tag : tagList) {
							AbstractTagModel tagModel = getTagModel(tag);
							taggedEvent.addTagToGroup(groupId, tagModel);
						}
					} else if (tagList.size() == 1) {
						// Add single tag
						AbstractTagModel tagModel = getTagModel(tagList.get(0));
						taggedEvent.addTag(tagModel);
					}
				}
			}
			if (eventJsonModel.getCode() == null || eventJsonModel.getCode().isEmpty()) {
				return false;
			}
			// // Add tags given in JSON fields if not already present
			// if (!eventJsonModel.getLabel().isEmpty()) {
			// AbstractTagModel tagModel = getTagModel("/Event/Label/"
			// + eventJsonModel.getLabel());
			// taggedEvent.addTag(tagModel);
			// }
			// if (!eventJsonModel.getLongName().isEmpty()) {
			// AbstractTagModel tagModel = getTagModel("/Event/Long name/"
			// + eventJsonModel.getLongName());
			// taggedEvent.addTag(tagModel);
			// }
			// if (!eventJsonModel.getDescription().isEmpty()) {
			// AbstractTagModel tagModel = getTagModel("/Event/Description/"
			// + eventJsonModel.getDescription());
			// taggedEvent.addTag(tagModel);
			// }
			taggerSetTemp.add(taggedEvent);
		}
		taggedEventSet = taggerSetTemp;
		return true;
	}

	/**
	 * Takes a String in the tab-delimited text format for events and loads the
	 * data into the Tagger.
	 * 
	 * @param egtReader
	 *            The BufferedReader used to read in the tab-delimited events.
	 * @return True if the data loaded successfully, false otherwise.
	 */
	private boolean populateEventsFromTabDelimitedText(BufferedReader egtReader) {
		taggedEventSet = new TaggerSet<TaggedEvent>();
		String line = null;
		try {
			while ((line = egtReader.readLine()) != null) {
				if (line.isEmpty()) {
					continue;
				}
				String[] cols = line.split("\\t");
				if (cols.length < 2) {
					return false;
				}
				// Create event
				TaggedEvent event = createNewEvent(cols[0]);
				String[] tags = cols[1].split(",");
				// Add tags to event
				int groupId = event.getEventGroupId();
				boolean endGroup;
				for (String tag : tags) {
					if (tag.isEmpty()) {
						continue;
					}
					endGroup = false;
					tag = tag.trim();
					// Start new tag group
					if (tag.startsWith("(")) {
						groupId = groupIdCounter++;
						event.addGroup(groupId);
						tag = tag.substring(1);
					}
					// End tag group
					if (tag.endsWith(")")) {
						endGroup = true;
						tag = tag.substring(0, tag.length() - 1);
					}
					AbstractTagModel tagModel = getTagModel(tag);
					event.addTagToGroup(groupId, tagModel);
					if (endGroup) {
						groupId = event.getEventGroupId();
					}
				}
				taggedEventSet.add(event);
			}
		} catch (IOException e) {
			return false;
		}
		return true;
	}

	/**
	 * Takes a String in the tab-delimited text format for events and loads the
	 * data into the Tagger.
	 * 
	 * @param egtReader
	 *            The BufferedReader used to read in the tab-delimited events.
	 * @param eventCodeColumns
	 *            The event code column(s).
	 * @param tagColumns
	 *            The event tag column(s).
	 * @return True if the data loaded successfully, false otherwise.
	 */
	private boolean populateEventsFromTabDelimitedText(BufferedReader egtReader, int header, int[] eventCodeColumns,
			int[] tagColumns) {
		TaggerSet<TaggedEvent> taggerSetTemp = new TaggerSet<TaggedEvent>();
		groupIdCounter = 0;
		String line = null;
		int lineCount = 0;
		try {
			while ((line = egtReader.readLine()) != null) {
				lineCount++;
				String[] cols = line.split("\\t");
				// line check
				if (line.trim().isEmpty() || lineCount <= header)
					continue;
				// combine columns
				String eventCode = combineColumns(" ", cols, eventCodeColumns).trim();
				// event check
				if (eventCode.isEmpty())
					continue;
				// tag check
				TaggedEvent event = createNewEvent(eventCode);
				if (tagColumns[0] != 0) {
					// Add tags to event
					int groupId = event.getEventGroupId();
					boolean endGroup;
					String[] tags = formatTags(combineColumns(",", cols, tagColumns).split(","));
					for (String tag : tags) {
						if (tag.trim().isEmpty()) {
							continue;
						}
						endGroup = false;
						tag = tag.trim();
						// Start new tag group
						if (tag.startsWith("(")) {
							groupId = groupIdCounter++;
							event.addGroup(groupId);
							tag = tag.substring(1);
						}
						// End tag group
						if (tag.endsWith(")")) {
							endGroup = true;
							tag = tag.substring(0, tag.length() - 1);
						}
						AbstractTagModel tagModel = getTagModel(tag);
						event.addTagToGroup(groupId, tagModel);
						if (endGroup) {
							groupId = event.getEventGroupId();
						}
					}
				}
				taggerSetTemp.add(event);
			}
		} catch (IOException e) {
			return false;
		}
		taggedEventSet = taggerSetTemp;
		return true;
	}

	/**
	 * Creates the event models (depending on the factory given) to be used in
	 * the Tagger from the XML model. Assumes the EGT set has been created and
	 * is empty. If no code is available for the event, the event label is used.
	 * 
	 * @param egtSetXmlModel
	 *            XML representation of an EGT set.
	 */
	private boolean populateEventsFromXml(EventSetXmlModel egtSetXmlModel) {
		TaggerSet<TaggedEvent> taggerSetTemp = new TaggerSet<TaggedEvent>();
		groupIdCounter = 0; // Reset group IDs (for loading)
		for (EventXmlModel eventXmlModel : egtSetXmlModel.getEventXmlModels()) {
			// Create new event model
			TaggedEvent taggedEvent = createNewEvent(eventXmlModel.getCode());
			// Add individual tags to event
			for (String tagPath : eventXmlModel.getTags()) {
				AbstractTagModel tagModel = getTagModel(tagPath);
				taggedEvent.addTagToGroup(taggedEvent.getEventGroupId(), tagModel);
			}
			// Add tag groups for event
			int groupId;
			for (GroupXmlModel groupXmlModel : eventXmlModel.getGroups()) {
				groupId = groupIdCounter++;
				taggedEvent.addGroup(groupId);
				for (String tagPath : groupXmlModel.getTags()) {
					AbstractTagModel tagModel = getTagModel(tagPath);
					taggedEvent.addTagToGroup(groupId, tagModel);
				}
			}
			// Default code
			if (taggedEvent.getEventModel().getCode() == null || taggedEvent.getEventModel().getCode().isEmpty()) {
				return false;
			}
			taggerSetTemp.add(taggedEvent);
		}
		taggedEventSet = taggerSetTemp;
		return true;
	}

	/**
	 * Populates the events from a JSON file.
	 * 
	 * @param egtFile
	 *            The JSON file.
	 * @return A set of events represented in JSON format.
	 * @throws Exception
	 *             If an error occurs.
	 */
	private Set<EventJsonModel> populateJSONList(File egtFile) throws Exception {
		Set<EventJsonModel> eventJsonModels = new ObjectMapper().readValue(egtFile,
				new TypeReference<LinkedHashSet<EventJsonModel>>() {
				});
		return eventJsonModels;
	}

	/**
	 * Populates the tags from a HED document.
	 * 
	 * @param hedXmlModel
	 *            A XML model representing the data from the HED file.
	 */
	private void populateTagList(HedXmlModel hedXmlModel) {
		requiredTags = new TaggerSet<AbstractTagModel>();
		recommendedTags = new TaggerSet<AbstractTagModel>();
		uniqueTags = new TaggerSet<AbstractTagModel>();
		tagList = new TaggerSet<AbstractTagModel>();
		if (!hedXmlModel.getVersion().isEmpty())
			version = hedXmlModel.getVersion();
		createUnitClassHashMapFromXml(hedXmlModel.getUnitClasses());
		createTagSetFromXml(hedXmlModel.getTags());
	}

	/**
	 * Creates or resets the tag list and EGT set along with lists of required,
	 * recommended, and unique tags given the XML model.
	 * 
	 * @param xmlData
	 *            The XML data used to populate the tags and events.
	 */
	private boolean processXmlData(TaggerDataXmlModel xmlData) {
		boolean succeed = false;
		// Create egtSet from egtSet XML
		if (populateEventsFromXml(xmlData.getEgtSetXmlModel())) {
			// Create tagSet from HED XML
			tagList = new TaggerSet<AbstractTagModel>();
			requiredTags = new TaggerSet<AbstractTagModel>();
			recommendedTags = new TaggerSet<AbstractTagModel>();
			uniqueTags = new TaggerSet<AbstractTagModel>();
			createUnitClassHashMapFromXml(xmlData.getHedXmlModel().getUnitClasses());
			createTagSetFromXml(xmlData.getHedXmlModel().getTags());
			succeed = true;
		}
		return succeed;
	}

	/**
	 * Reads the given JSON event string into a JSON model.
	 * 
	 * @param egtString
	 *            JSON string containing events and associated tags.
	 * @return Set<EventJsonModel> containing a model for each event read.
	 */
	private Set<EventJsonModel> readEventJsonString(String egtString) throws Exception {
		Set<EventJsonModel> eventJsonModels = new ObjectMapper().readValue(egtString,
				new TypeReference<LinkedHashSet<EventJsonModel>>() {
				});
		return eventJsonModels;
	}

	/**
	 * Creates an HEDXMLModel from an HED file.
	 * 
	 * @param hedFile
	 *            The HED file.
	 * @return A HEDXMLModel representing the HED file.
	 * @throws Exception
	 *             If an error occurs.
	 */
	private HedXmlModel ReadHEDXml(File hedFile) throws Exception {
		JAXBContext context = JAXBContext.newInstance(HedXmlModel.class);
		HedXmlModel hedXmlModel = (HedXmlModel) context.createUnmarshaller().unmarshal(hedFile);
		return hedXmlModel;
	}

	/**
	 * Unmarshals the HED XML string and returns the resulting HedXmlModel.
	 * 
	 * @param hedXmlString
	 *            XML representation of the HED hierarchy.
	 * @return The HedXmlModel representing the given XML.
	 */
	private HedXmlModel readHedXmlString(String hedXmlString) throws Exception {
		StringReader hedStringReader = new StringReader(hedXmlString);
		JAXBContext context = JAXBContext.newInstance(HedXmlModel.class);
		HedXmlModel hedXmlModel = (HedXmlModel) context.createUnmarshaller().unmarshal(hedStringReader);
		return hedXmlModel;
	}

	/**
	 * Redo the last action that was undone.
	 */
	public HistoryItem redo() {
		return history.redo();
	}

	/**
	 * Removes the event and creates an entry in the history.
	 * 
	 * @param eventModel
	 *            The TaggedEvent representing the event to remove.
	 */
	public void removeEvent(TaggedEvent event) {
		int index = taggedEventSet.indexOf(event);
		if (removeEventBase(event)) {
			HistoryItem historyItem = new HistoryItem();
			historyItem.eventModelPosition = index;
			historyItem.type = TaggerHistory.Type.EVENT_REMOVED;
			historyItem.event = event;
			history.add(historyItem);
		}
	}

	/**
	 * Removes the event from the event list.
	 * 
	 * @param eventModel
	 *            The TaggedEvent representing the event to remove.
	 * @return True if the event is removed, false if otherwise.
	 */
	public boolean removeEventBase(TaggedEvent eventModel) {
		return taggedEventSet.remove(eventModel);
	}

	/**
	 * Removes the group and creates an entry in the history.
	 * 
	 * @param groupId
	 *            The group id to remove.
	 */
	public void removeGroup(int groupId) {
		TaggedEvent taggedEvent = getTaggedEventFromGroupId(groupId);
		TaggerSet<AbstractTagModel> tagsRemoved = removeGroupBase(taggedEvent, groupId);
		if (tagsRemoved != null) {
			HistoryItem historyItem = new HistoryItem();
			historyItem.type = TaggerHistory.Type.GROUP_REMOVED;
			historyItem.event = taggedEvent;
			historyItem.groupId = groupId;
			historyItem.tags = tagsRemoved;
			history.add(historyItem);
		}
	}

	/**
	 * Removes the group from the event.
	 * 
	 * @param event
	 *            The TaggedEvent representing the event
	 * @param groupId
	 *            The group ID to remove from the event
	 * @return The set of tags in the group removed from the event
	 */
	public TaggerSet<AbstractTagModel> removeGroupBase(TaggedEvent event, Integer groupId) {
		return event.removeGroup(groupId);
	}

	/**
	 * Saves the current event and tag data to the given files.
	 * 
	 * @param egtFile
	 *            File to save event JSON to.
	 * @param hedFile
	 *            File to save HED XML to.
	 * @param json
	 *            True if the format is in json, false if otherwise.
	 * @return True if the data was saved successfully, false otherwise.
	 */
	public boolean save(File egtFile, File hedFile, boolean json) {
		if (json) {
			// Save JSON to file
			Set<EventJsonModel> eventJsonModels = buildEventJsonModels();
			ObjectMapper mapper = new ObjectMapper();
			ObjectWriter writer = mapper.writerWithDefaultPrettyPrinter();
			try {
				FileWriter fw = new FileWriter(egtFile);
				writer.writeValue(fw, eventJsonModels);
			} catch (Exception ex) {
				System.err.println(
						"Unable to save event JSON data to file " + egtFile.getPath() + ": " + ex.getMessage());
				return false;
			}
		} else {
			// Save tab-delimited text to file
			try {
				BufferedWriter egtWriter = new BufferedWriter(new FileWriter(egtFile));
				writeTabDelimitedTextFromEgt(egtWriter);
				egtWriter.close();
			} catch (IOException e) {
				System.err.println("Error writing tab-delimited text to file: " + e.getMessage());
				return false;
			}
		}
		// Save XML to file
		HedXmlModel hedModel = new HedXmlModel();
		TagXmlModel dummy = tagsToXmlModel();
		hedModel.setTags(dummy.getTags());
		hedModel.setUnitClasses(unitClassesToXmlModel());
		try {
			JAXBContext context = JAXBContext.newInstance(HedXmlModel.class);
			Marshaller marshaller = context.createMarshaller();
			marshaller.setProperty(Marshaller.JAXB_FORMATTED_OUTPUT, true);
			marshaller.marshal(hedModel, hedFile);
		} catch (JAXBException e) {
			System.err.println("Unable to save HED XML data to file " + hedFile.getPath() + ": " + e.getMessage());
			return false;
		}
		return true;
	}

	/**
	 * Saves current event and tag data to the given file in TaggerData XML
	 * format.
	 * 
	 * @param savedData
	 *            File in which to save data.
	 * @return True if the data was saved successfully, false otherwise.
	 */
	public boolean saveEventsAndHED(File savedData) {
		TaggerDataXmlModel savedDataModel = buildSavedDataModel();
		try {
			JAXBContext context = JAXBContext.newInstance(TaggerDataXmlModel.class);
			Marshaller marshaller = context.createMarshaller();
			marshaller.setProperty(Marshaller.JAXB_FORMATTED_OUTPUT, true);
			marshaller.marshal(savedDataModel, savedData);
		} catch (JAXBException e) {
			System.err.println("Unable to save to file " + savedData.getPath() + ": " + e.getMessage());
			return false;
		}
		return true;
	}

	public boolean saveHED(File hedFile) {
		HedXmlModel hedModel = new HedXmlModel();
		TagXmlModel dummy = tagsToXmlModel();
		hedModel.setTags(dummy.getTags());
		hedModel.setUnitClasses(unitClassesToXmlModel());
		hedModel.setVersion(version);
		try {
			JAXBContext context = JAXBContext.newInstance(HedXmlModel.class);
			Marshaller marshaller = context.createMarshaller();
			marshaller.setProperty(Marshaller.JAXB_FORMATTED_OUTPUT, true);
			marshaller.marshal(hedModel, hedFile);
		} catch (JAXBException e) {
			System.err.println("Unable to save HED XML data to file " + hedFile.getPath() + ": " + e.getMessage());
			return false;
		}
		return true;
	}

	public boolean saveTabDelimitedEvents(File egtFile) {
		try {
			BufferedWriter egtWriter = new BufferedWriter(new FileWriter(egtFile));
			writeTabDelimitedTextFromEgt(egtWriter);
			egtWriter.close();
		} catch (IOException e) {
			System.err.println("Error writing tab-delimited text to file: " + e.getMessage());
			return false;
		}
		return true;
	}

	/**
	 * Sorts the required and recommended tags according to their position
	 * attributes.
	 */
	private void sortRRTags() {
		requiredTags.sort(new Comparator<AbstractTagModel>() {
			public int compare(AbstractTagModel tag1, AbstractTagModel tag2) {
				int pos1 = tag1.getPosition();
				if (pos1 == -1) {
					pos1 = requiredTags.size() + 1;
				}
				int pos2 = tag2.getPosition();
				if (pos2 == -1) {
					pos2 = requiredTags.size() + 1;
				}
				if (pos1 == pos2) {
					return 0;
				}
				return pos1 < pos2 ? -1 : 1;
			}
		});
		recommendedTags.sort(new Comparator<AbstractTagModel>() {
			public int compare(AbstractTagModel tag1, AbstractTagModel tag2) {
				int pos1 = tag1.getPosition();
				if (pos1 == -1) {
					pos1 = recommendedTags.size() + 1;
				}
				int pos2 = tag2.getPosition();
				if (pos2 == -1) {
					pos2 = recommendedTags.size() + 1;
				}
				if (pos1 == pos2) {
					return 0;
				}
				return pos1 < pos2 ? -1 : 1;
			}
		});
	}

	/**
	 * 
	 * @param tagPath
	 *            The path of the tag.
	 * @return The tag if found, null if otherwise.
	 */
	public AbstractTagModel tagFound(String tagPath) {
		for (AbstractTagModel tag : tagList) {
			if (tag.getPath().toUpperCase().equals(tagPath.toUpperCase())) {
				return tag;
			}
		}
		return null;
	}

	/**
	 * Sets child tags to property of predicate type.
	 */
	public void setChildToPropertyOf() {
		for (AbstractTagModel tag : tagList) {
			AbstractTagModel parentTag = tagFound(tag.getParentPath());
			if (parentTag != null && PredicateType.PROPERTYOF.equals(parentTag.getPredicateType())) {
				tag.setPredicateType(PredicateType.PROPERTYOF);
			}
		}
	}

	/**
	 * 
	 * @param tagPath
	 *            The path of the tag.
	 * @return True if the tag path exists, false if otherwise.
	 */
	public boolean tagPathFound(String tagPath) {
		for (AbstractTagModel tag : tagList) {
			if (tag.getPath().toUpperCase().equals(tagPath.toUpperCase())) {
				return true;
			}
		}
		return false;
	}

	/**
	 * Creates the XML model of the tag set.
	 * 
	 * @return Complete XML model containing HED hierarchy tags
	 */
	private TagXmlModel tagsToXmlModel() {
		Iterator<AbstractTagModel> iter = tagList.iterator();
		TagXmlModel dummy = new TagXmlModel();
		String prefix = "";
		tagsToXmlModelHelper(dummy, prefix, iter);
		return dummy;
	}

	/**
	 * Helper method to build hierarchical tag structure recursively.
	 */
	private AbstractTagModel tagsToXmlModelHelper(TagXmlModel parent, String prefix, Iterator<AbstractTagModel> iter) {
		if (!iter.hasNext()) {
			return null;
		}
		AbstractTagModel next = iter.next(); // Potential child node
		while (next != null && next.getPath().startsWith(prefix + "/")) {
			// Create child XML model and link to parent
			TagXmlModel child = new TagXmlModel();
			child.setName(next.getName());
			child.setDescription(next.getDescription());
			child.setChildRequired(next.isChildRequired());
			child.setTakesValue(next.takesValue());
			child.setPredicateType(next.getPredicateType().toString());
			child.setRequired(next.isRequired());
			child.setRecommended(next.isRecommended());
			child.setUnique(next.isUnique());
			child.setPosition(next.getPosition());
			parent.addChild(child);
			// Process child node and get potential next child node
			next = tagsToXmlModelHelper(child, next.getPath(), iter);
		}
		return next; // Prefix does not match
	}

	/**
	 * If the tag is not associated with all of the group IDs, the tag is
	 * associated with the remaining group ids. If the tag is associated with
	 * all of the group IDs, the tag is unassociated from all of the group ids.
	 * If there is a conflict with ancestor, descendant, or unique tags, this
	 * information is contained in the return value, and no action is taken.
	 * 
	 * @param tagModel
	 *            The tag to be toggled.
	 * @param groupIds
	 *            The set of group IDs to toggle the tag with.
	 * @return A <code>ToggleTagMessage</code> containing the ancestor and
	 *         descendant tags found in the desired tag groups. Returns null if
	 *         no ancestor or descendant tags were found, or if the preserve
	 *         prefix option is set to true.
	 */
	public ToggleTagMessage toggleTag(AbstractTagModel tagModel, Set<Integer> groupIds) {
		AbstractTagModel uniqueKey = getUniqueKey(tagModel);
		if (!loader.testFlag(Loader.PRESERVE_PREFIX) || uniqueKey != null || tagModel.isRecommended()
				|| tagModel.isRequired()) {
			return toggleTagReplacePrefix(tagModel, groupIds, uniqueKey);
		}
		boolean found;
		for (Integer groupId : groupIds) {
			found = false;
			for (TaggedEvent currentTaggedEvent : taggedEventSet) {
				if (currentTaggedEvent.containsTagInGroup(groupId, tagModel)) {
					found = true;
					break;
				}
			}
			if (!found || "~".equals(tagModel.getName())) {
				associate(tagModel, groupIds);
				return null;
			}
		}
		unassociate(tagModel, groupIds);
		return null;
	}

	/**
	 * Gets a tagged event that contains the group id.
	 * 
	 * @param groupId
	 *            The group id
	 * @return A TaggedEvent that contains the group id.
	 */
	public TaggedEvent getEventByGroupId(Integer groupId) {
		for (TaggedEvent currentEventModel : taggedEventSet) {
			if (currentEventModel.containsGroup(groupId)) {
				return currentEventModel;
			}
		}
		return null;
	}

	/**
	 * ToggleTag method for when the preserve prefix option is false. Checks all
	 * groupIds before performing the association to make sure that none already
	 * contain ancestors or descendants of the tag to add. If an ancestor,
	 * descendant, or conflicting unique tag is found in a tag group, it is
	 * added to the <code>ToggleTagMessage</code> to be returned.
	 * 
	 * @param tagModel
	 * @param groupIds
	 * @return A <code>ToggleTagMessage</code> containing the ancestor and
	 *         descendant tags found in the desired tag groups. Returns null if
	 *         no ancestor or descendant tags were found.
	 */
	private ToggleTagMessage toggleTagReplacePrefix(AbstractTagModel tagModel, Set<Integer> groupIds,
			AbstractTagModel uniqueKey) {
		ToggleTagMessage result = new ToggleTagMessage(tagModel, groupIds);
		boolean missingTag = false;
		boolean rrTag = isRRValue(tagModel);
		for (Integer groupId : groupIds) {
			for (TaggedEvent currentEventModel : taggedEventSet) {
				if (currentEventModel.containsGroup(groupId)) {
					if (rrTag && (groupId != currentEventModel.getEventGroupId())) {
						// Attempt to add required/recommended tag to group
						result.rrError = true;
						return result;
					}
					AbstractTagModel tagFound = currentEventModel.findTagSharedPath(groupId, tagModel);
					AbstractTagModel uniqueFound = null;
					if (uniqueKey != null) {
						uniqueFound = currentEventModel.findDescendant(groupId, uniqueKey);
						result.uniqueKey = uniqueKey;
					}
					if (tagFound != null || uniqueFound != null) {
						// Conflicting tags found
						if (tagFound != null) {
							String tagPathFound = tagFound.getPath();
							if (tagPathFound.compareTo(tagModel.getPath()) > 0) {
								// Descendant tag found in tag group
								result.addDescendant(currentEventModel, groupId, tagFound);
							} else if (tagPathFound.compareTo(tagModel.getPath()) < 0) {
								// Parent tag found in tag group
								result.addAncestor(currentEventModel, groupId, tagFound);
							}
						}
						if (uniqueFound != null && !uniqueFound.getPath().equals(tagModel.getPath())
								&& uniqueFound != tagFound) {
							result.addUniqueValue(currentEventModel, groupId, uniqueFound);
						}
					} else {
						// Group does not contain any conflicting tags
						missingTag = true;
					}
				}
			}
		}
		if (result.ancestors.size() > 0 || result.descendants.size() > 0 || result.uniqueValues.size() > 0) {
			return result;
		}
		if (missingTag || "~".equals(tagModel.getName())) {
			associate(tagModel, groupIds);
			return null;
		}
		unassociate(tagModel, groupIds);
		return null;
	}

	/**
	 * Unassociates the tag from the group ids. Adds an entry in the history.
	 * 
	 * @param tagModel
	 *            The AbstractTagModel representing the tag to be unassociated.
	 * @param groupIds
	 *            The set of group IDs to unassociate the tag from.
	 */
	public void unassociate(AbstractTagModel tagModel, Set<Integer> groupIds) {
		Set<Integer> affectedGroups = unassociateBase(tagModel, groupIds);
		if (!affectedGroups.isEmpty()) {
			HistoryItem historyItem = new HistoryItem();
			historyItem.type = TaggerHistory.Type.UNASSOCIATED;
			historyItem.groupsIds = affectedGroups;
			historyItem.tagModel = tagModel;
			history.add(historyItem);
		}
	}

	/**
	 * Unassociates the tag from the group ids. Adds an entry in the history.
	 * 
	 * @param eventModel
	 *            The GuiEventModel representing the event the tag belongs to.
	 * @param tagModel
	 *            The AbstractTagModel representing the tag to be unassociated.
	 * @param groupIds
	 *            The set of group IDs to unassociate the tag from.
	 */
	public void unassociate(GuiEventModel eventModel, AbstractTagModel tagModel, Set<Integer> groupIds) {
		Set<Integer> affectedGroups = unassociateBase(tagModel, groupIds);
		if (!affectedGroups.isEmpty()) {
			HistoryItem historyItem = new HistoryItem();
			historyItem.type = TaggerHistory.Type.UNASSOCIATED;
			historyItem.groupsIds = affectedGroups;
			historyItem.tagModel = tagModel;
			historyItem.eventModel = eventModel;
			history.add(historyItem);
		}
	}

	/**
	 * Unassociates the tag from the group ids. Adds an entry in the history.
	 * 
	 * @param The
	 *            The HistoryItem containing the past action(s)
	 * @param tagModel
	 *            The AbstractTagModel representing the tag to be unassociated.
	 * @param groupIds
	 *            The set of group IDs to unassociate the tag from.
	 */
	public void unassociate(HistoryItem historyItem, AbstractTagModel tagModel, Set<Integer> groupIds) {
		Set<Integer> affectedGroups = unassociateBase(tagModel, groupIds);
		if (!affectedGroups.isEmpty()) {
			historyItem.type = TaggerHistory.Type.UNASSOCIATED;
			historyItem.groupsIds = affectedGroups;
			historyItem.tagModel = tagModel;
			history.add(historyItem);
		}
	}

	/**
	 * Unassociates the tag from the group ids.
	 * 
	 * @param tagModel
	 *            The AbstractTagModel representing a tag to be unassociated.
	 * @param groupIds
	 *            The set of group IDs to unassociate the tag from.
	 * @return The set of group IDs that the tag was unassociated from
	 */
	public Set<Integer> unassociateBase(AbstractTagModel tagModel, Set<Integer> groupIds) {
		Set<Integer> affectedGroups = new HashSet<Integer>();
		for (Integer groupId : groupIds) {
			for (TaggedEvent currentTaggedEvent : taggedEventSet) {
				if (currentTaggedEvent.removeTagFromGroup(groupId, tagModel)) {
					affectedGroups.add(groupId);
					if (tagModel.getPath().startsWith("/Event/label")) {

					}
				}
			}
		}
		return affectedGroups;
	}

	/**
	 * Undo the most recent action.
	 */
	public HistoryItem undo() {
		return history.undo();
	}

	/**
	 * Creates the XML model of the EGT set. This includes events, tag groups,
	 * and tag paths.
	 * 
	 * @return Complete XML model containing EGT set information.
	 */
	private UnitClassesXmlModel unitClassesToXmlModel() {
		UnitClassesXmlModel unitClassesXml = new UnitClassesXmlModel();
		Iterator<String> unitClassKeys = unitClasses.keySet().iterator();
		while (unitClassKeys.hasNext()) {
			String key = unitClassKeys.next();
			UnitClassXmlModel unitClassXml = new UnitClassXmlModel();
			unitClassXml.setName(key);
			unitClassXml.setUnits(unitClasses.get(key));
			unitClassXml.setDefault(unitClassDefaults.get(key));
			unitClassesXml.addUnitClass(unitClassXml);
		}
		return unitClassesXml;
	}

	/**
	 * Updates the status of the tag model to indicate whether it is missing
	 * from the hierarchy or not.
	 * 
	 * @param tag
	 *            The GuiTagModel representing a missing tag status
	 */
	public void updateMissing(GuiTagModel tag) {
		if ("~".equals(tag.getName())) {
			tag.setMissing(false);
			return;
		}
		String searchPath = tag.getParentPath();
		for (AbstractTagModel currentTag : tagList) {
			if (currentTag.getPath().equals(tag.getPath())) {
				tag.setMissing(false);
				return;
			}
			if (currentTag.getPath().equals(searchPath)) {
				TaggerSet<AbstractTagModel> childTags = getSubHierarchy(searchPath);
				for (AbstractTagModel childTag : childTags) {
					if (childTag.getPath().equals(tag.getPath())) {
						tag.setMissing(false);
						return;
					}
					if (childTag.takesValue() && matchTakesValueTag(childTag.getName(), tag.getName())) {
						tag.setMissing(false);
						return;
					}
				}
			}
		}
		tag.setMissing(true);
	}

	/**
	 * * Manages the current or previous highlighting of the GUI tag models used
	 * for scrolling to a tag.
	 * 
	 * @param current
	 *            true if the current highlight, false if previous
	 */
	public void updateTagHighlights(boolean current) {
		if (highlightTag != null) {
			if (current)
				highlightTag.setHighlight(currentHighlightType);
			else
				highlightTag.setHighlight(previousHighlightType);
		}
	}

	/**
	 * Updates the required, recommended, and unique tag lists with the current
	 * state of the hierarchy.
	 */
	public void updateTagLists() {
		requiredTags = new TaggerSet<AbstractTagModel>();
		recommendedTags = new TaggerSet<AbstractTagModel>();
		uniqueTags = new TaggerSet<AbstractTagModel>();
		for (AbstractTagModel tag : tagList) {
			if (tag.isRequired()) {
				requiredTags.add(tag);
			}
			if (tag.isRecommended()) {
				recommendedTags.add(tag);
			}
			if (tag.isUnique()) {
				uniqueTags.add(tag);
			}
		}
		sortRRTags();
	}

	/**
	 * Updates the tag's name to the new name given. Also updates any descendant
	 * tags in the hierarchy and relevant transient tags (tags that are not
	 * included in the hierarchy) used on events.
	 * 
	 * @param tagModel
	 *            The tag model representing a tag
	 * @param name
	 *            The new tag name
	 */
	public void updateTagName(AbstractTagModel tagModel, String name) {
		// Prefix of all descendants of this tag
		String prefix = tagModel.getPath() + "/";
		String newPath = tagModel.getParentPath() + "/" + name;
		String newPrefix = newPath + "/";
		// Update this tag
		tagModel.setPath(newPath);
		// Update any descendants
		for (int i = tagList.indexOf(tagModel) + 1; i < tagList.size(); i++) {
			AbstractTagModel currentTag = tagList.get(i);
			String currentPath = currentTag.getPath();
			if (currentPath.startsWith(prefix)) {
				String updatedPath = currentPath.replaceFirst(prefix, newPrefix);
				currentTag.setPath(updatedPath);
			} else {
				break;
			}
		}
		// Update event tags not represented in hierarchy (i.e. transient tags)
		for (TaggedEvent taggedEvent : taggedEventSet) {
			for (TaggerSet<AbstractTagModel> tags : taggedEvent.getTagGroups().values()) {
				for (AbstractTagModel tag : tags) {
					String currentPath = tag.getPath();
					if (currentPath.startsWith(prefix)) {
						String updatedPrefix = currentPath.replaceFirst(prefix, newPrefix);
						tag.setPath(updatedPrefix);
					}
				}
			}
		}
	}

	/**
	 * Writes the tab-delimited text representing the current EGT data in the
	 * tagger to the given BufferedWriter
	 * 
	 * @param egtWriter
	 *            BufferedWriter used to write tab-delimited EGT data
	 * @return True if the write completed without errors, false otherwise
	 */
	private boolean writeTabDelimitedTextFromEgt(BufferedWriter egtWriter) {
		for (TaggedEvent event : taggedEventSet) {
			boolean first;
			try {
				// Write event code
				egtWriter.write(event.getEventModel().getCode() + "\t");
				// Write tags
				for (Map.Entry<Integer, TaggerSet<AbstractTagModel>> entry : event.getTagGroups().entrySet()) {
					first = true;
					if (entry.getKey() == event.getEventGroupId()) {
						// Event level tags
						for (AbstractTagModel tag : entry.getValue()) {
							if (first) {
								first = false;
							} else {
								egtWriter.append(',');
							}
							egtWriter.write(tag.getPath());
						}
					} else {
						// Tag group
						for (AbstractTagModel tag : entry.getValue()) {
							egtWriter.append(',');
							if (first) {
								egtWriter.append('(');
								first = false;
							}
							egtWriter.write(tag.getPath());
						}
						egtWriter.append(')');
					}
				}
			} catch (IOException e) {
				System.err.println("Error writing tab-delimited text: " + e.getMessage());
				return false;
			}
			try {
				egtWriter.newLine();
			} catch (IOException e) {
				System.err.println("Error writing tab-delimited text: " + e.getMessage());
				return false;
			}
		}
		return true;
	}
}
