package edu.utsa.tagger;

import java.util.List;
import java.util.Set;

import edu.utsa.tagger.TaggerHistory.Type;
import edu.utsa.tagger.gui.GuiTagModel;

/**
 * This class represents an action performed in the Tagger that can be undone.
 * 
 * @author Lauren Jett, Rebecca Strautman, Thomas Rognon, Jeremy Cockfield, Kay
 *         Robbins
 */
public class HistoryItem {
	public Type type;
	public AbstractTagModel tagModel;
	public int tagModelPosition;
	public AbstractEventModel eventModel;
	public int eventModelPosition;
	public EventModel egtModel;
	public List<AbstractTagModel> tagList;
	public Set<EventModel> egtSet;
	public Set<Integer> groupsIds;
	public GuiTagModel tagModelCopy;
	public AbstractEventModel eventModelCopy;
	public TaggedEvent event;
	public TaggerSet<TaggedEvent> events;
	public Integer groupId;
	public TaggerSet<Integer> groupIds;
	public TaggerSet<AbstractTagModel> tags;
}
