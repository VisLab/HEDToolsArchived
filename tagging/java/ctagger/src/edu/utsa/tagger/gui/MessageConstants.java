package edu.utsa.tagger.gui;

/**
 * This class contains various messages displayed throughout the Tagger GUI.
 * 
 * @author Lauren Jett, Rebecca Strautman, Thomas Rognon, Jeremy Cockfield, Kay
 *         Robbins
 */
public final class MessageConstants {
	private static final int MAX_GROUP_TILDES = 2;
	public static final String ANCESTOR = "The following ancestor tags will be replaced:";
	public static final String DESCENDANT = "Cannot add tag - the selected groups contain the following descendant tags:";
	public static final String UNIQUE = "Cannot add tag - the selected groups contain the following tags under the unique tag ";
	public static final String REPLACE_TAGS_Q = "Would you like to replace these tags?";
	public static final String MISSING_REQUIRED = "The following required tags are missing:";
	public static final String EXIT_Q = "Exit anyway?";
	public static final String CHOOSE_JSON = "Choose JSON events file:";
	public static final String CHOOSE_XML = "Choose HED XML file:";
	public static final String CHOOSE_FILE = "Choose a file to load:";
	public static final String SAVE_JSON = "Choose folder to save JSON events to:";
	public static final String SAVE_XML = "Choose folder to save HED XML to:";
	public static final String SAVE_FILE = "Choose folder to save file to:";
	public static final String LOAD_ERROR = "Unable to load data: invalid format";
	public static final String SAVE_ERROR = "Unable to save data to: invalid format";
	public static final String OPEN_DATA_TYPE_Q = "What kind of data would you like to load?";
	public static final String EXIT_SAVE_Q = "Would you like to save before exiting?";
	public static final String HED_XML_SAVE_Q = "The HED XML has been modified, would you like to save?";
	public static final String CANCEL_Q = "Are you sure you want to cancel?";
	public static final String SAVE_DATA_TYPE_Q = "In which format would you like to save the data?";
	public static final String TAKES_VALUE = "Click to enter a value. The value will replace the '#' character.";
	public static final String TAKES_VALUE_ERROR = "Please specify # for a tag that takes a value.";
	public static final String TAG_DELETE_WARNING = "Warning: All of this tag's descendants will be deleted. Delete tag?";
	public static final String TAG_NAME_INVALID = "Tag names cannot contain '/' character.";
	public static final String TAG_NAME_DUPLICATE = "Duplicate tags are not allowed in the hierarchy.";
	public static final String TAG_RR_ERROR = "Tag cannot be both required and recommended.";
	public static final String TAG_POSITION_ERROR = "Tag position must be an integer.";
	public static final String TAG_UNIT_ERROR = "Tag value must be numerical.";
	public static final String TILDE_ERROR = "There can be at most " + MAX_GROUP_TILDES + " tildes in a group.";
	public static final String ADD_EVENT_ERROR = "Duplicate event - unable to add";
	public static final String ASSOCIATE_RR_ERROR = "Unable to add tag: Required and recommended tags can only be added at the event level.";
	public static final String NO_EVENT_SELECTED = "Please select a event or tag group before tagging";
	public static final String SELECT_CHILD_ERROR = "Please select a descendant of this tag";
	public static final String TAG_PATH_SPECIFY_CHILD_ERROR = "Please specify a descendant of this tag";
	public static final String TAG_PATH_NOT_EXIST_ERROR = "The tag path does not exist";
}
