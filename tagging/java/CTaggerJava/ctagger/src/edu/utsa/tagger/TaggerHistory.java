package edu.utsa.tagger;

import java.util.ArrayList;
import java.util.List;

import edu.utsa.tagger.gui.GuiTagModel;

/**
 * This class represents the history of events performed in the Tagger that can
 * be undone. It keeps track of the undo and redo stacks.
 * 
 * @author Lauren Jett, Rebecca Strautman, Thomas Rognon, Jeremy Cockfield, Kay
 *         Robbins
 */
public class TaggerHistory {

	// Type of undoable action
	public enum Type {
		TAG_ADDED, TAG_REMOVED, EVENT_ADDED, EVENT_REMOVED, GROUP_ADDED, GROUPS_ADDED, GROUP_REMOVED, TAG_EDITED, TAG_PATH_EDITED, EVENT_EDITED, ASSOCIATED, UNASSOCIATED
	};

	private Tagger tagger;
	private int undoIndex = -1;
	private int redoIndex = -1;
	private int capacity = 20;
	private List<HistoryItem> undoStack = new ArrayList<HistoryItem>();
	private List<HistoryItem> redoStack = new ArrayList<HistoryItem>();

	public TaggerHistory(Tagger tagger) {
		this.tagger = tagger;
	}

	/**
	 * Adds a new history item to the history, clearing the redo stack.
	 * 
	 * @param item
	 */
	public void add(HistoryItem item) {
		addToUndo(item);
		redoStack.clear();
		redoIndex = -1;
	}

	/**
	 * Adds the history item to the redo stack.
	 * 
	 * @param item
	 */
	private void addToRedo(HistoryItem item) {
		redoStack.add(item);
		redoIndex++;
		if (redoStack.size() > capacity) {
			redoStack.remove(0);
			redoIndex--;
		}
	}

	/**
	 * Adds the history item to the undo stack.
	 * 
	 * @param item
	 */
	private void addToUndo(HistoryItem item) {
		undoStack.add(item);
		undoIndex++;
		if (undoStack.size() > capacity) {
			undoStack.remove(0);
			undoIndex--;
		}
	}

	/**
	 * Gets a message based on the item type
	 * 
	 * @param type
	 * @return String containing the message
	 */
	private String getMessage(Type type) {
		switch (type) {
		case TAG_ADDED:
			return "add tag";
		case TAG_REMOVED:
			return "delete tag";
		case EVENT_ADDED:
			return "add event";
		case EVENT_REMOVED:
			return "delete event";
		case GROUP_ADDED:
			return "add group";
		case GROUPS_ADDED:
			return "add groups";
		case GROUP_REMOVED:
			return "remove group";
		case TAG_EDITED:
			return "tag edit";
		case TAG_PATH_EDITED:
			return "tag path edit";
		case EVENT_EDITED:
			return "event edit";
		case ASSOCIATED:
			return "tag event(s)";
		case UNASSOCIATED:
			return "untag event(s)";
		}
		return "";
	}

	/**
	 * Gets the next item to redo.
	 * 
	 * @return
	 */
	private HistoryItem getNextRedo() {
		if (redoIndex == -1) {
			return null;
		}
		return redoStack.remove(redoIndex--);
	}

	/**
	 * Gets the next item to undo.
	 * 
	 * @return
	 */
	private HistoryItem getNextUndo() {
		if (undoIndex == -1) {
			return null;
		}
		return undoStack.remove(undoIndex--);
	}

	/**
	 * Returns a message to summarize the next action redo will perform.
	 * 
	 * @return String containing the messsage
	 */
	public String getRedoMessage() {
		if (redoIndex == -1) {
			return "No actions to redo.";
		}
		HistoryItem item = redoStack.get(redoIndex);
		String message = "Redo " + getMessage(item.type);
		return message;
	}

	/**
	 * Returns a message to summarize the next action undo will perform.
	 * 
	 * @return String containing the messsage
	 */
	public String getUndoMessage() {
		if (undoIndex == -1) {
			return "No actions to undo.";
		}
		HistoryItem item = undoStack.get(undoIndex);
		String message = "Undo " + getMessage(item.type);
		return message;
	}

	/**
	 * Calls a method to redo the next item.
	 */
	public HistoryItem redo() {
		HistoryItem item = getNextRedo();
		if (item == null) {
			return null;
		}
		switch (item.type) {
		case TAG_ADDED:
			redoAddTag(item);
			break;
		case TAG_REMOVED:
			redoRemoveTag(item);
			break;
		case EVENT_ADDED:
			redoAddEvent(item);
			break;
		case EVENT_REMOVED:
			redoRemoveEvent(item);
			break;
		case GROUP_ADDED:
			redoAddGroup(item);
			break;
		case GROUPS_ADDED:
			redoAddGroups(item);
			break;
		case GROUP_REMOVED:
			redoRemoveGroup(item);
			break;
		case TAG_EDITED:
			redoTagEdited(item);
			break;
		case TAG_PATH_EDITED:
			redoTagPathEdited(item);
			break;
		case EVENT_EDITED:
			redoEventEdited(item);
			break;
		case ASSOCIATED:
			redoAssociate(item);
			break;
		case UNASSOCIATED:
			redoUnassociate(item);
			break;
		}
		return item;
	}

	private void redoAddEvent(HistoryItem item) {
		if (item.event != null) {
			if (tagger.addEventBase(item.event)) {
				addToUndo(item);
			}
		}
	}

	private void redoAddGroup(HistoryItem item) {
		if (item.groupId != null && item.tags != null && item.event != null) {
			if (tagger.addGroupBase(item.event, item.groupId, item.tags)) {
				addToUndo(item);
			}
		}
	}

	private void redoAddGroups(HistoryItem item) {
		if (item.groupIds != null && item.tags != null && item.events != null) {
			TaggedEvent[] events = (TaggedEvent[]) item.events
					.toArray(new TaggedEvent[item.events.size()]);
			Integer[] groupIds = (Integer[]) item.groupIds
					.toArray(new Integer[item.groupIds.size()]);
			for (int i = 0; i < events.length; i++) {
				tagger.addGroupBase(events[i], groupIds[i], item.tags);
			}
			addToUndo(item);
		}
	}

	private void redoAddTag(HistoryItem item) {
		if (item.tagModel != null) {
			tagger.addTagModelBase(item.tagModel);
			addToUndo(item);
		}
	}

	private void redoAssociate(HistoryItem item) {
		if (item.tagModel != null && item.groupsIds != null) {
			if ("/Event/Label".equals(item.tagModel.getParentPath())
					&& item.eventModel != null) {
				item.eventModel.setLabel(item.tagModel.getPath());
			}
			tagger.associateBase(item.tagModel, item.groupsIds);
			addToUndo(item);
		}
	}

	private void redoEventEdited(HistoryItem item) {
		if (item.eventModel != null && item.eventModelCopy != null) {
			AbstractEventModel copy = tagger.editEventCodeLabelBase(
					item.eventModel, item.eventModelCopy.getCode(),
					item.eventModelCopy.getLabel());
			item.eventModelCopy = copy;
			if (item.tagModel != null)
				item.tagModel.setPath("/Event/Label/"
						+ item.eventModel.getLabel());
			addToUndo(item);
		}
	}

	private void redoRemoveEvent(HistoryItem item) {
		if (item.event != null) {
			if (tagger.removeEventBase(item.event)) {
				addToUndo(item);
			}
		}
	}

	private void redoRemoveGroup(HistoryItem item) {
		if (item.groupId != null && item.tags != null && item.event != null) {
			if (tagger.removeGroupBase(item.event, item.groupId) != null) {
				addToUndo(item);
			}
		}
	}

	private void redoRemoveTag(HistoryItem item) {
		if (item.tagModel != null && item.tags != null) {
			TaggerSet<AbstractTagModel> deleted = tagger
					.deleteTagBase(item.tagModel);
			item.tags = deleted;
			addToUndo(item);
		}
	}

	private void redoTagEdited(HistoryItem item) {
		if (item.tagModelCopy != null && item.tagModel != null) {
			GuiTagModel original = item.tagModelCopy;
			GuiTagModel copy = tagger.editTagBase((GuiTagModel) item.tagModel,
					original.getName(), original.getDescription(),
					original.isChildRequired(), original.takesValue(),
					original.isNumeric(), original.isRequired(),
					original.isRecommended(), original.isUnique(),
					original.getPosition(), original.getPredicateType());
			item.tagModelCopy = copy;
			addToUndo(item);
		}
	}

	private void redoTagPathEdited(HistoryItem item) {
		GuiTagModel original = item.tagModelCopy;
		if ("/Event/Label".equals(item.tagModelCopy.getParentPath())) {
			item.eventModel.setLabel(original.getName());
		}
		GuiTagModel copy = tagger.editTagBase((GuiTagModel) item.tagModel,
				original.getPath(), item.tagModelCopy.getName(),
				original.getDescription(), original.isChildRequired(),
				original.takesValue(), item.tagModelCopy.isRequired(),
				original.isRecommended(), original.isUnique(),
				original.getPosition());
		item.tagModelCopy = copy;
		addToUndo(item);
	}

	private void redoUnassociate(HistoryItem item) {
		if (item.tagModel != null && item.groupsIds != null) {
			if ("/Event/Label".equals(item.tagModel.getParentPath())
					&& item.eventModel != null) {
				item.eventModel.setLabel(new String());
			}
			tagger.unassociateBase(item.tagModel, item.groupsIds);
			addToUndo(item);
		}
	}

	/**
	 * Calls a method to undo the next item.
	 */
	public HistoryItem undo() {
		HistoryItem item = getNextUndo();
		if (item == null) {
			return null;
		}
		switch (item.type) {
		case TAG_ADDED:
			undoAddTag(item);
			break;
		case TAG_REMOVED:
			undoRemoveTag(item);
			break;
		case EVENT_ADDED:
			undoAddEvent(item);
			break;
		case EVENT_REMOVED:
			undoRemoveEvent(item);
			break;
		case GROUP_ADDED:
			undoAddGroup(item);
			break;
		case GROUPS_ADDED:
			undoAddGroups(item);
			break;
		case GROUP_REMOVED:
			undoRemoveGroup(item);
			break;
		case TAG_EDITED:
			undoTagEdited(item);
			break;
		case TAG_PATH_EDITED:
			undoTagPathEdited(item);
			break;
		case EVENT_EDITED:
			undoEventEdited(item);
			break;
		case ASSOCIATED:
			undoAssociate(item);
			break;
		case UNASSOCIATED:
			undoUnassociate(item);
			break;
		}
		return item;
	}

	private void undoAddEvent(HistoryItem item) {
		if (item.event != null) {
			if (tagger.removeEventBase(item.event)) {
				addToRedo(item);
			}
		}
	}

	private void undoAddGroup(HistoryItem item) {
		if (item.groupId != null && item.tags != null && item.event != null) {
			if (tagger.removeGroupBase(item.event, item.groupId) != null) {
				addToRedo(item);
			}
		}
	}

	private void undoAddGroups(HistoryItem item) {
		if (item.groupIds != null && item.events != null) {
			TaggedEvent[] events = (TaggedEvent[]) item.events
					.toArray(new TaggedEvent[item.events.size()]);
			Integer[] groupIds = (Integer[]) item.groupIds
					.toArray(new Integer[item.groupIds.size()]);
			for (int i = 0; i < events.length; i++) {
				tagger.removeGroupBase(events[i], groupIds[i]);
			}
			addToRedo(item);
		}
	}

	private void undoAddTag(HistoryItem item) {
		if (item.tagModel != null) {
			tagger.deleteTagBase(item.tagModel);
			addToRedo(item);
		}
	}

	private void undoAssociate(HistoryItem item) {
		if (item.tagModel != null && item.groupsIds != null) {
			if ("/Event/Label".equals(item.tagModel.getParentPath())
					&& item.eventModel != null) {
				item.eventModel.setLabel(item.tagModel.getPath());
			}
			tagger.unassociateBase(item.tagModel, item.groupsIds);
			addToRedo(item);
		}
	}

	private void undoEventEdited(HistoryItem item) {
		if (item.eventModel != null && item.eventModelCopy != null) {
			AbstractEventModel copy = tagger.editEventCodeLabelBase(
					item.eventModel, item.eventModelCopy.getCode(),
					item.eventModelCopy.getLabel());
			item.eventModelCopy = copy;
			if (item.tagModel != null)
				item.tagModel.setPath("/Event/Label/"
						+ item.eventModel.getLabel());
			addToRedo(item);
		}
	}

	private void undoRemoveEvent(HistoryItem item) {
		if (item.event != null) {
			int index = item.eventModelPosition;
			if (tagger.addEventBase(index, item.event)) {
				addToRedo(item);
			}
		}
	}

	private void undoRemoveGroup(HistoryItem item) {
		if (item.groupId != null && item.tags != null && item.event != null) {
			if (tagger.addGroupBase(item.event, item.groupId, item.tags)) {
				addToRedo(item);
			}
		}
	}

	private void undoRemoveTag(HistoryItem item) {
		if (item.tags != null && item.tagModel != null) {
			int index = item.tagModelPosition;
			tagger.addTagModelBase(index, item.tagModel);
			for (AbstractTagModel tag : item.tags) {
				tagger.addTagModelBase(index++, tag);
			}
			addToRedo(item);
		}
	}

	private void undoTagEdited(HistoryItem item) {
		if (item.tagModelCopy != null && item.tagModel != null) {
			GuiTagModel original = item.tagModelCopy;
			GuiTagModel copy = tagger.editTagBase((GuiTagModel) item.tagModel,
					original.getName(), original.getDescription(),
					original.isChildRequired(), original.takesValue(),
					original.isNumeric(), original.isRequired(),
					original.isRecommended(), original.isUnique(),
					original.getPosition(), original.getPredicateType());
			item.tagModelCopy = copy;
			addToRedo(item);
		}
	}

	private void undoTagPathEdited(HistoryItem item) {
		GuiTagModel original = item.tagModelCopy;
		if ("/Event/Label".equals(item.tagModelCopy.getParentPath())
				&& item.eventModel != null) {
			item.eventModel.setLabel(original.getName());
		}
		GuiTagModel copy = tagger.editTagBase((GuiTagModel) item.tagModel,
				original.getPath(), item.tagModelCopy.getName(),
				original.getDescription(), original.isChildRequired(),
				original.takesValue(), item.tagModelCopy.isRequired(),
				original.isRecommended(), original.isUnique(),
				original.getPosition());
		item.tagModelCopy = copy;
		addToRedo(item);
	}

	private void undoUnassociate(HistoryItem item) {
		if (item.tagModel != null && item.groupsIds != null) {
			if ("/Event/Label".equals(item.tagModel.getParentPath())
					&& item.eventModel != null) {
				item.eventModel.setLabel(new String());
			}
			tagger.associateBase(item.tagModel, item.groupsIds);
			addToRedo(item);
		}
	}
}
