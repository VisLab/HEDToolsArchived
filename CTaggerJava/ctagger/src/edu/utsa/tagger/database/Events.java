package edu.utsa.tagger.database;

import java.sql.Connection;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;

import edu.utsa.tagger.EventJsonModel;

/**
 * This class provides methods to update the database with new tags and event
 * data.
 * 
 * @author Lauren Jett, Rebecca Strautman, Thomas Rognon, Jeremy Cockfield, Kay
 *         Robbins
 * 
 */
public class Events {

	/**
	 * A connection to the database
	 */
	private Connection dbCon;
	/**
	 * A list of tags
	 */
	private List<String> tags;

	/**
	 * Creates a Events object
	 * 
	 * @param dbCon
	 *            a connectio to the database
	 */
	public Events(Connection dbCon) {
		this.dbCon = dbCon;
	}

	/**
	 * Flattens the nested tag list from a JSON event model into a single list
	 * of tag paths.
	 * 
	 * @param tags
	 * @return A list of tag paths
	 */
	private List<String> flattenTagList(List<List<String>> tags) {
		List<String> result = new ArrayList<String>();
		for (List<String> subList : tags) {
			result.addAll(subList);
		}
		return result;
	}

	/**
	 * Finds the pathnames of all tags to be updated from the list of tags in
	 * this instance.
	 * 
	 * @return a list containing the pathnames of all the tags for which the
	 *         count should be incremented in the database
	 */
	private List<String> getAllPaths() {
		List<String> paths = new ArrayList<String>();
		List<String> temp = new ArrayList<String>();
		for (String t : tags) {
			temp = getPathsFromPath(t);
			for (String s : temp)
				paths.add(s);
		}
		return paths;
	}

	/**
	 * Finds the pathnames of all ancestors of a given tag.
	 * 
	 * @param path
	 *            the pathname of a tag to find all ancestors for
	 * @return a List of Strings representing the pathnames of all ancestors of
	 *         <code>path</code> and <code>path</code> itself
	 */
	private List<String> getPathsFromPath(String path) {
		List<String> paths = new ArrayList<String>();
		String[] tokens = path.split("/");
		String p = "";
		for (int i = tokens.length; i > 1; i--) {
			for (int j = 1; i > j; j++)
				p += "/" + tokens[j];
			paths.add(p);
			p = "";
		}
		return paths;
	}

	/**
	 * Returns a list of tags tags
	 * 
	 * @return a list of tags
	 */
	public List<String> getTags() {
		return tags;
	}

	/**
	 * Converts a list of tags to a hashmap of tags
	 * 
	 * @param list
	 *            a list of tags
	 * @return a hashmap that contains the tags in the list
	 */
	private HashMap<String, String> listToHashMap(List<String> list) {
		HashMap<String, String> hashMap = new HashMap<String, String>();
		int numElements = list.size();
		for (int i = 0; i < numElements; i++)
			hashMap.put(list.get(i), null);
		return hashMap;
	}

	/**
	 * Resets the fields of the Events object
	 * 
	 * @param tags
	 *            a list of tags
	 */
	public void reset(List<String> tags) {
		this.tags = tags;
	}

	/**
	 * Finds new tags present in the new event model
	 * 
	 * @param ev1
	 *            the original event model
	 * @param ev2
	 *            the new event model
	 * @return a list of new tags found
	 */
	private List<String> setDiff(EventJsonModel ev1, EventJsonModel ev2) {
		List<String> updates = new ArrayList<String>();
		HashMap<String, String> tagMap = listToHashMap(flattenTagList(ev1
				.getTags()));
		List<String> tags = flattenTagList(ev2.getTags());
		int numElements = tags.size();
		for (int i = 0; i < numElements; i++) {
			if (!tagMap.containsKey(tags.get(i)))
				updates.add(tags.get(i));
		}
		return updates;
	}

	/**
	 * Converts a set of event models to a hashmap of event models
	 * 
	 * @param set
	 *            a set of event models
	 * @return a hashmap that contains the event models in the set
	 */
	private HashMap<String, EventJsonModel> setToHashMap(Set<EventJsonModel> set) {
		HashMap<String, EventJsonModel> hashMap = new HashMap<String, EventJsonModel>();
		Iterator<EventJsonModel> iterator = set.iterator();
		EventJsonModel eModel;
		while (iterator.hasNext()) {
			eModel = iterator.next();
			hashMap.put(eModel.getCode(), eModel);
		}
		return hashMap;
	}

	/**
	 * Converts between the original format of events list and EventModel
	 * objects
	 * 
	 * @param eventString
	 *            a String of events in the original format
	 * @return an List of EventModel objects corresponding to the events passed
	 *         in
	 */
	private Set<EventJsonModel> stringToEventModel(String eventString) {
		String oldEv = eventString.replace("\r", "").replace("\n", "");
		String[] eventsSplit = oldEv.split(";");
		Set<EventJsonModel> events = new LinkedHashSet<EventJsonModel>();
		for (int i = 0; i < eventsSplit.length; i++) {
			String[] fields = eventsSplit[i].split(",");
			EventJsonModel event = new EventJsonModel();
			// event.setLabel(fields[0]);
			// event.setDescription(fields[1]);
			List<String> tags = new ArrayList<String>();
			for (int j = 2; j < fields.length; j++)
				tags.add(fields[j]);
			List<List<String>> tagList = new ArrayList<List<String>>();
			tagList.add(tags);
			event.setTags(tagList);
			events.add(event);
		}
		return events;
	}

	/**
	 * Converts a Json or non-Json string to a set of EventModels
	 * 
	 * @param eventString
	 *            the event string in Json or non-Json format
	 * @param useJson
	 *            true if the string is in Json, false if otherwise
	 * @return a set of EventModels that correspond to the event string
	 */
	private Set<EventJsonModel> stringToEvents(String eventString,
			boolean useJson) throws Exception {
		Set<EventJsonModel> events;
		try {
			if (useJson) {
				ObjectMapper mapper = new ObjectMapper();
				events = mapper.readValue(eventString,
						new TypeReference<LinkedHashSet<EventJsonModel>>() {
						});
			} else
				events = stringToEventModel(eventString);
		} catch (Exception ex) {
			throw new Exception(
					"Unable to get events from Json or non-Json string\n"
							+ ex.getMessage());
		}
		return events;
	}

	/**
	 * Updates the counts in the database for all tags in this instance.
	 * 
	 * @return the number of records updated
	 */
	private int updateCount() throws Exception {
		int updateCount = 0;
		List<String> paths = getAllPaths();
		for (String p : paths)
			updateCount += Tags.updateCount(dbCon, p);
		return updateCount;
	}

	/**
	 * Updates the counts for any new tags found when comparing the original
	 * events string with the updated events string.
	 * 
	 * @param dbCon
	 *            a connection the database
	 * @param originalEventString
	 *            the original event string in Json or non-Json format
	 * @param newEventString
	 *            the new event string in Json or non-Json format
	 * @param useJson
	 *            true if the string is in Json, false if otherwise
	 */
	public void updateTagCount(String originalEventString,
			String newEventString, boolean useJson) throws Exception {
		Set<EventJsonModel> originalEvents = stringToEvents(
				originalEventString, useJson);
		Set<EventJsonModel> newEvents = stringToEvents(newEventString, useJson);
		HashMap<String, EventJsonModel> eventMap = setToHashMap(originalEvents);
		Iterator<EventJsonModel> iterator = newEvents.iterator();
		EventJsonModel eModel1;
		EventJsonModel eModel2;
		List<String> updates = null;
		while (iterator.hasNext()) {
			eModel2 = iterator.next();
			if (eventMap.containsKey(eModel2.getCode())) {
				eModel1 = eventMap.get(eModel2.getCode());
				updates = setDiff(eModel1, eModel2);
			} else
				updates = flattenTagList(eModel2.getTags());
			reset(updates);
			updateCount();
		}
	}
}