package edu.utsa.tagger;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertTrue;

import java.io.File;
import java.io.IOException;
import java.net.URISyntaxException;
import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.Set;

import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.TemporaryFolder;

import edu.utsa.tagger.app.TestUtilities;
import edu.utsa.tagger.gui.GuiModelFactory;

public class TestTagger {

	@Rule
	public TemporaryFolder testFolder = new TemporaryFolder();

	public static final int testEgtSetSize = 3;
	public static final int[] groupsPerEvent = { 3, 1, 1 };
	public static final int[] tagGroupSizes = { 5, 3, 2, 3, 4 };
	public static final int testTagSetSize = 679;
	public static final int numRequired = 3;
	public static final int numRecommended = 1;
	public static final int numUnique = 4;
	public static final int[] groupsPerEventJson = { 3, 1, 1 };
	public static final int[] tagGroupSizesJson = { 5, 3, 2, 3, 4 };
	public static final int testTagSetSizeJson = 26;
	public static final int numRequiredJson = 5;
	public static final int numRecommendedJson = 2;
	public static final int numUniqueJson = 3;
	private Tagger testTagger;
	private File testLoadXml;
	private String hedOld;
	private String hedRR;
	private String eventsOld;
	private IFactory factory;
	private AbstractTagModel tagAncestor;
	private AbstractTagModel tagAncestor2;
	private AbstractTagModel tag;
	private AbstractTagModel tagDescendant;
	private TaggedEvent testEvent1;
	private TaggedEvent testEvent2;
	private TaggedEvent testEvent3;
	private static int[] testGroupIds = { 1000, 2000, 3000, 4000 };

	@Before
	public void setUp() throws URISyntaxException {
		testLoadXml = TestUtilities.getResourceAsFile(TestUtilities.saveFileTest);
		hedOld = TestUtilities.getResourceAsString(TestUtilities.HedFileName);
		hedRR = TestUtilities.getResourceAsString(TestUtilities.HedRequiredRecommended);
		eventsOld = TestUtilities.getResourceAsString(TestUtilities.JsonEventsArrays);
		factory = new GuiModelFactory();
		Loader loader = new Loader(hedOld, eventsOld, Loader.USE_JSON, 0, "Tagger Test - JSON Events", 2, factory, true,
				true);
		testTagger = new Tagger(hedOld, eventsOld, true, factory, loader);
		TaggerSet<TaggedEvent> egtSet = testTagger.getEgtSet();
		testEvent1 = egtSet.get(0);
		testEvent2 = egtSet.get(1);
		testEvent3 = egtSet.get(2);
		tagAncestor = factory.createAbstractTagModel(testTagger);
		tagAncestor.setPath("/a/b/c");
		tagAncestor2 = factory.createAbstractTagModel(testTagger);
		tagAncestor2.setPath("/a");
		tag = factory.createAbstractTagModel(testTagger);
		tag.setPath("/a/b/c/d");
		tagDescendant = factory.createAbstractTagModel(testTagger);
		tagDescendant.setPath("/a/b/c/d/e/f");
	}

	@Test
	public void testAddEventInvalidDuplicate() {
		System.out.println("It should not add an event that already exists.");
		TaggedEvent existingEvent = testTagger.getEgtSet().get(0);
		String existingCode = existingEvent.getEventModel().getCode();
		String existingLabel = existingEvent.getLabel();
		int numEvents = testTagger.getEgtSet().size();
		assertNotNull("Success of adding event", testTagger.addNewEvent(existingCode, existingLabel));
		assertEquals("Number of events in tagger", numEvents, testTagger.getEgtSet().size());
	}

	@Test
	public void testAddEventValid() {
		System.out.println("It should add a new event to the tagger.");
		String newCode = "Test code";
		String newLabel = "Test label";
		int numEvents = testTagger.getEgtSet().size() + 1;
		assertNotNull("Success of adding event", testTagger.addNewEvent(newCode, newLabel));
		assertEquals("Number of events in tagger", numEvents, testTagger.getEgtSet().size());
	}

	@Test
	public void testAddNewTagInvalidDuplicate() {
		System.out.println("It should not add a new tag to the tagger if it" + " is a duplicate");
		int numTags = testTagger.getTagSet().size();
		TaggerSet<AbstractTagModel> tags = (TaggerSet<AbstractTagModel>) testTagger.getTagSet();
		AbstractTagModel parentTag = tags.get(0);
		String name = tags.get(1).getName();
		assertNull("Success of adding tag", testTagger.addNewTag(parentTag, name));
		assertEquals("Number of tags in tagger", numTags, testTagger.getTagSet().size());
	}

	@Test
	public void testAddNewTagValid() {
		System.out.println("It should add a new tag (under parent /Paradigm/NA) to the tagger.");
		String name = "New tag";
		int numTags = testTagger.getTagSet().size() + 1;
		AbstractTagModel parentTag = testTagger.getTagSet().last();
		assertNotNull("Success of adding tag", testTagger.addNewTag(parentTag, name));
		assertEquals("Number of tags in tagger", numTags, testTagger.getTagSet().size());
	}

	@Test
	public void testDeleteTagMultiple() {
		System.out
				.println("It should delete the tag (/Event/Category/Technical error) and all of " + "its descendants");
		int numTags = testTagger.getTagSet().size() - 2;
		TaggerSet<AbstractTagModel> tags = (TaggerSet<AbstractTagModel>) testTagger.getTagSet();
		AbstractTagModel tagToDelete = tags.get(4);
		testTagger.deleteTag(tagToDelete);
		assertEquals("Number of tags in tagger", numTags, testTagger.getTagSet().size());
	}

	@Test
	public void testDeleteTagSingle() {
		System.out.println(
				"It should delete the tag (/Event/Category/Experiment control/Sequence/Block/#) with no descendants");
		int numTags = testTagger.getTagSet().size() - 1;
		TaggerSet<AbstractTagModel> tags = (TaggerSet<AbstractTagModel>) testTagger.getTagSet();
		AbstractTagModel tagToDelete = tags.get(50);
		testTagger.deleteTag(tagToDelete);
		assertEquals("Number of tags in tagger", numTags, testTagger.getTagSet().size());
	}

	@Test
	public void testLoad() throws URISyntaxException {
		System.out.println("It should load the correct number of tags and " + "EGT data into the Tagger using XML.");
		Loader loader = new Loader(hedRR, eventsOld, Loader.USE_JSON, 0, "Tagger Test", 2, factory, true, true);
		testTagger = new Tagger(hedRR, eventsOld, true, factory, loader);
		testTagger.loadEventsAndHED(testLoadXml);
		// Verify EGT set loaded correctly
		int groupIdx = 0;
		int tagIdx = 0;
		assertEquals("Wrong EGT set size:", testEgtSetSize, testTagger.getEgtSet().size());
		for (TaggedEvent event : testTagger.getEgtSet()) {
			assertEquals("Number of groups in the event", groupsPerEvent[groupIdx++], event.getTagGroups().size());
			for (Integer groupId : event.getTagGroups().keySet()) {
				assertEquals("Number of tags in the group", tagGroupSizes[tagIdx++], event.getNumTagsInGroup(groupId));
			}
		}
		// Verify tag set loaded correctly
		assertEquals("Wrong tag set size:", testTagSetSize, testTagger.getTagSet().size());
		assertEquals("Required tags found", numRequired, testTagger.getRequiredTags().size());
		assertEquals("Recommended tags found", numRecommended, testTagger.getRecommendedTags().size());
		assertEquals("Unique tags found", numUnique, testTagger.getUniqueTags().size());
	}

	@Test
	public void testLoadJSON() throws URISyntaxException {
		System.out.println(
				"It should load the correct number of tags and " + "EGT data into the Tagger using JSON + XML.");
		Loader loader = new Loader(hedRR, eventsOld, Loader.USE_JSON, 0, "Tagger Test", 2, factory, true, true);
		testTagger = new Tagger(hedOld, eventsOld, true, factory, loader);
		testTagger.loadJSON(TestUtilities.getResourceAsFile(TestUtilities.JsonEventsArrays),
				TestUtilities.getResourceAsFile(TestUtilities.HedRequiredRecommended));
		// Verify EGT set loaded correctly
		assertEquals("Wrong EGT set size:", testEgtSetSize, testTagger.getEgtSet().size());
		// Verify tag set loaded correctly
		assertEquals("Wrong tag set size:", testTagSetSizeJson, testTagger.getTagSet().size());
		assertEquals("Required tags found", numRequiredJson, testTagger.getRequiredTags().size());
		assertEquals("Recommended tags found", numRecommendedJson, testTagger.getRecommendedTags().size());
		assertEquals("Unique tags found", numUniqueJson, testTagger.getUniqueTags().size());
	}

	@Test
	public void testLoadTdt() throws URISyntaxException {
		System.out.println("It should load the events and tag hierarchy from "
				+ "saved files when the events are in tab-delimited text format");
		Loader loader = new Loader(hedOld, eventsOld, Loader.USE_JSON, 0, "Tagger Test - delimited string", 2, factory,
				true, true);
		testTagger = new Tagger(hedOld, eventsOld, true, factory, loader);
		int headerLines = 0;
		int[] codeColumns = { 1 };
		int[] tagColumns = { 2 };
		assertTrue("Tagger load success - tag-delimited text",
				testTagger.loadTabDelimited(TestUtilities.getResourceAsFile(TestUtilities.DelimitedString),
						TestUtilities.getResourceAsFile(TestUtilities.HedRequiredRecommended), headerLines, codeColumns,
						tagColumns));
		// Verify EGT set loaded correctly
		int groupIdx = 0;
		int tagIdx = 0;
		assertEquals("Wrong EGT set size:", testEgtSetSize, testTagger.getEgtSet().size());
		for (TaggedEvent event : testTagger.getEgtSet()) {
			assertEquals("Number of groups in the event", groupsPerEventJson[groupIdx++], event.getTagGroups().size());
			for (Integer groupId : event.getTagGroups().keySet()) {
				assertEquals("Number of tags in the group", tagGroupSizesJson[tagIdx++],
						event.getNumTagsInGroup(groupId));
			}
		}
		// Verify tag set loaded correctly
		assertEquals("Wrong tag set size:", testTagSetSizeJson, testTagger.getTagSet().size());
		assertEquals("Required tags found", numRequiredJson, testTagger.getRequiredTags().size());
		assertEquals("Recommended tags found", numRecommendedJson, testTagger.getRecommendedTags().size());
		assertEquals("Unique tags found", numUniqueJson, testTagger.getUniqueTags().size());
	}

	@Test
	public void testLoadTdtMultipleTagColumns() throws URISyntaxException {
		System.out.println("It should load the events and tag hierarchy from "
				+ "saved files when the events are in tab-delimited text format");
		int headerLines = 0;
		int[] eventCodeColumn = { 1 };
		int[] tagColumns = { 2, 3, 4 };
		Loader loader = new Loader(hedOld, eventsOld, Loader.USE_JSON, 0, "Tagger Test - delimited string", 2, factory,
				true, true);
		testTagger = new Tagger(hedOld, eventsOld, true, factory, loader);
		assertTrue("Tagger load success - tag-delimited text",
				testTagger.loadTabDelimited(TestUtilities.getResourceAsFile(TestUtilities.DelimitedString2),
						TestUtilities.getResourceAsFile(TestUtilities.HedRequiredRecommended), headerLines,
						eventCodeColumn, tagColumns));
		// Verify EGT set loaded correctly
		int groupIdx = 0;
		int tagIdx = 0;
		assertEquals("Wrong EGT set size:", testEgtSetSize, testTagger.getEgtSet().size());
		for (TaggedEvent event : testTagger.getEgtSet()) {
			assertEquals("Number of groups in the event", groupsPerEventJson[groupIdx++], event.getTagGroups().size());
			for (Integer groupId : event.getTagGroups().keySet()) {
				assertEquals("Number of tags in the group", tagGroupSizesJson[tagIdx++],
						event.getNumTagsInGroup(groupId));
			}
		}
		// Verify tag set loaded correctly
		assertEquals("Wrong tag set size:", testTagSetSizeJson, testTagger.getTagSet().size());
		assertEquals("Required tags found", numRequiredJson, testTagger.getRequiredTags().size());
		assertEquals("Recommended tags found", numRecommendedJson, testTagger.getRecommendedTags().size());
		assertEquals("Unique tags found", numUniqueJson, testTagger.getUniqueTags().size());
	}

	@Test
	public void testLoadTdtNoLabels() throws URISyntaxException {
		System.out.println("It should load the events and tag hierarchy from "
				+ "saved files when the events are in tab-delimited text format");
		int headerLines = 0;
		int[] eventCodeColumn = { 1 };
		int[] tagColumns = { 3 };
		Loader loader = new Loader(hedOld, eventsOld, Loader.USE_JSON, 0, "Tagger Test - delimited string", 2, factory,
				true, true);
		testTagger = new Tagger(hedOld, eventsOld, true, factory, loader);
		assertTrue("Tagger load success - tag-delimited text",
				testTagger.loadTabDelimited(TestUtilities.getResourceAsFile(TestUtilities.DelimitedString2),
						TestUtilities.getResourceAsFile(TestUtilities.HedRequiredRecommended), headerLines,
						eventCodeColumn, tagColumns));
		// Verify EGT set loaded correctly
		int groupIdx = 0;
		int tagIdx = 0;
		int[] groupsPerEventJson = new int[] { 2, 1, 1 };
		int[] tagGroupSizesJson = new int[] { 3, 3, 1, 2 };
		assertEquals("Wrong EGT set size:", testEgtSetSize, testTagger.getEgtSet().size());
		for (TaggedEvent event : testTagger.getEgtSet()) {
			assertEquals("Number of groups in the event", groupsPerEventJson[groupIdx++], event.getTagGroups().size());
			for (Integer groupId : event.getTagGroups().keySet()) {
				assertEquals("Number of tags in the group", tagGroupSizesJson[tagIdx++],
						event.getNumTagsInGroup(groupId));
			}
		}
		// Verify tag set loaded correctly
		assertEquals("Wrong tag set size:", testTagSetSizeJson, testTagger.getTagSet().size());
		assertEquals("Required tags found", numRequiredJson, testTagger.getRequiredTags().size());
		assertEquals("Recommended tags found", numRecommendedJson, testTagger.getRecommendedTags().size());
		assertEquals("Unique tags found", numUniqueJson, testTagger.getUniqueTags().size());
	}

	@Test
	public void testLoadTdtNoTags() throws URISyntaxException {
		System.out.println("It should load the events and tag hierarchy from "
				+ "saved files when the events are in tab-delimited text format");
		int headerLines = 0;
		int[] eventCodeColumn = { 1 };
		int[] tagColumns = { 0 };
		Loader loader = new Loader(hedOld, eventsOld, Loader.USE_JSON, 0, "Tagger Test - delimited string", 2, factory,
				true, true);
		testTagger = new Tagger(hedOld, eventsOld, true, factory, loader);
		assertTrue("Tagger load success - tag-delimited text",
				testTagger.loadTabDelimited(TestUtilities.getResourceAsFile(TestUtilities.DelimitedString2),
						TestUtilities.getResourceAsFile(TestUtilities.HedRequiredRecommended), headerLines,
						eventCodeColumn, tagColumns));
		// Verify EGT set loaded correctly
		int groupIdx = 0;
		int tagIdx = 0;
		int[] groupsPerEventTdt = new int[] { 1, 1, 1 };
		int[] tagGroupSizesTdt = new int[] { 0, 0, 0 };
		assertEquals("Wrong EGT set size:", testEgtSetSize, testTagger.getEgtSet().size());
		for (TaggedEvent event : testTagger.getEgtSet()) {
			assertEquals("Number of groups in the event", groupsPerEventTdt[groupIdx++], event.getTagGroups().size());
			for (Integer groupId : event.getTagGroups().keySet()) {
				assertEquals("Number of tags in the group", tagGroupSizesTdt[tagIdx++],
						event.getNumTagsInGroup(groupId));
			}
		}
		// Verify tag set loaded correctly
		assertEquals("Wrong tag set size:", testTagSetSizeJson, testTagger.getTagSet().size());
		assertEquals("Required tags found", numRequiredJson, testTagger.getRequiredTags().size());
		assertEquals("Recommended tags found", numRecommendedJson, testTagger.getRecommendedTags().size());
		assertEquals("Unique tags found", numUniqueJson, testTagger.getUniqueTags().size());
	}

	@Test
	public void testPreservePrefixTrue1() {
		System.out.println("It should return null even though ancestors " + "exist.");
		// Set up for preserve prefix
		Loader loader = new Loader(hedOld, eventsOld, Loader.USE_JSON | Loader.PRESERVE_PREFIX, 0,
				"Tagger Test - JSON Events", 2, factory, true, true);
		testTagger = new Tagger(hedOld, eventsOld, true, factory, loader);
		TaggerSet<TaggedEvent> egtSet = testTagger.getEgtSet();
		testEvent1 = egtSet.get(0);
		testEvent2 = egtSet.get(1);
		testEvent3 = egtSet.get(2);

		// Add groups
		testEvent1.addGroup(testGroupIds[0]);
		testEvent2.addGroup(testGroupIds[1]);
		testEvent3.addGroup(testGroupIds[2]);
		testEvent3.addGroup(testGroupIds[3]);
		// Add tag and ancestor tags to groups
		testEvent1.addTagToGroup(testGroupIds[0], tag);
		testEvent2.addTagToGroup(testGroupIds[1], tagAncestor);
		testEvent3.addTagToGroup(testGroupIds[2], tagAncestor);
		testEvent3.addTagToGroup(testGroupIds[3], tagAncestor2);
		// Attempt to add descendant
		Set<Integer> groupIds = new LinkedHashSet<Integer>();
		groupIds.add(testGroupIds[0]);
		groupIds.add(testGroupIds[1]);
		groupIds.add(testGroupIds[2]);
		groupIds.add(testGroupIds[3]);
		ToggleTagMessage result = testTagger.toggleTag(tagDescendant, groupIds);
		assertNull("ToggleTagMessage returned", result);
	}

	@Test
	public void testPreservePrefixTrue2() {
		System.out.println("It should return null even though descendants " + "exist.");
		// Set up for preserve prefix
		Loader loader = new Loader(hedOld, eventsOld, Loader.USE_JSON | Loader.PRESERVE_PREFIX, 0,
				"Tagger Test - JSON Events", 2, factory, true, true);
		testTagger = new Tagger(hedOld, eventsOld, true, factory, loader);
		TaggerSet<TaggedEvent> egtSet = testTagger.getEgtSet();
		testEvent1 = egtSet.get(0);
		testEvent2 = egtSet.get(1);
		testEvent3 = egtSet.get(2);

		// Add groups
		testEvent1.addGroup(testGroupIds[0]);
		testEvent2.addGroup(testGroupIds[1]);
		testEvent3.addGroup(testGroupIds[2]);
		testEvent3.addGroup(testGroupIds[3]);
		// Add tag and ancestor tags to groups
		testEvent1.addTagToGroup(testGroupIds[0], tag);
		testEvent2.addTagToGroup(testGroupIds[1], tagAncestor);
		testEvent3.addTagToGroup(testGroupIds[2], tagDescendant);
		testEvent3.addTagToGroup(testGroupIds[3], tag);
		// Attempt to add descendant
		Set<Integer> groupIds = new LinkedHashSet<Integer>();
		groupIds.add(testGroupIds[0]);
		groupIds.add(testGroupIds[1]);
		groupIds.add(testGroupIds[2]);
		groupIds.add(testGroupIds[3]);
		ToggleTagMessage result = testTagger.toggleTag(tagAncestor2, groupIds);
		assertNull("ToggleTagMessage returned", result);
	}

	@Test
	public void testRequiredRecommended() {
		String required0 = "/Event/Label";
		String required1 = "/Event/B";
		String required2 = "/Event/Long name";
		String required3 = "/Event/Description";
		String required4 = "/Event/Sequence group ID/A";
		String recommended0 = "/D";
		String recommended1 = "/Event/C";
		System.out.println("It should find the required and recommended tags "
				+ "in the hierarchy and add them to the correct lists, sorted" + " by their position attributes.");
		Loader loader = new Loader(hedRR, eventsOld, Loader.USE_JSON, 0, "Tagger Test", 2, factory, true, true);
		testTagger = new Tagger(hedRR, eventsOld, true, factory, loader);
		TaggerSet<AbstractTagModel> requiredTags = testTagger.getRequiredTags();
		assertEquals("First required tag (label)", requiredTags.get(0).getPath(), required0);
		assertEquals("Required tag (A)", requiredTags.get(1).getPath(), required1);
		assertEquals("Required tag (B)", requiredTags.get(2).getPath(), required2);
		assertEquals("Required tag (Description)", requiredTags.get(3).getPath(), required3);
		assertEquals("Required tag (Long name)", requiredTags.get(4).getPath(), required4);
		TaggerSet<AbstractTagModel> recommendedTags = testTagger.getRecommendedTags();
		assertEquals("First recommended tag", recommendedTags.get(0).getPath(), recommended0);
		assertEquals("Second recommended tag", recommendedTags.get(1).getPath(), recommended1);

	}

	@Test
	public void testSave() throws IOException, URISyntaxException {
		System.out.println(
				"It should, after savingto XML, be able to load " + "the same information from the saved file.");
		File testOutput = testFolder.newFile("testOutput.txt");
		testTagger.loadEventsAndHED(testLoadXml);
		// Get sizes for loaded data
		int tagSize = testTagger.getTagSet().size();
		int egtSize = testTagger.getEgtSet().size();
		ArrayList<Integer> numGroupsPerEvent = new ArrayList<Integer>();
		ArrayList<Integer> numTagsPerGroup = new ArrayList<Integer>();
		for (TaggedEvent event : testTagger.getEgtSet()) {
			numGroupsPerEvent.add(event.getTagGroups().size());
			for (Integer groupId : event.getTagGroups().keySet()) {
				numTagsPerGroup.add(event.getNumTagsInGroup(groupId));
			}
		}
		int reqSize = testTagger.getRequiredTags().size();
		int recSize = testTagger.getRecommendedTags().size();
		testTagger.saveEventsAndHED(testOutput);
		testTagger.removeEvent(testTagger.getEgtSet().first());
		testTagger.deleteTag(testTagger.getTagSet().first());
		// Verify sizes the same after saving
		testTagger.loadEventsAndHED(testOutput); // Reload from the saved output
		// Verify EGT set
		int groupIdx = 0;
		int tagIdx = 0;
		assertEquals("EGTs not loaded to XML models properly - wrong size", egtSize, testTagger.getEgtSet().size());
		for (TaggedEvent event : testTagger.getEgtSet()) {
			assertEquals("Groups per event", (int) numGroupsPerEvent.get(groupIdx++), event.getTagGroups().size());
			for (Integer groupId : event.getTagGroups().keySet()) {
				assertEquals("Tags per group", (int) numTagsPerGroup.get(tagIdx++), event.getNumTagsInGroup(groupId));
			}
		}
		// Verify tag set
		assertEquals("Tags not loaded to XML models properly - wrong size", tagSize, testTagger.getTagSet().size());
		assertEquals("Required tags", reqSize, testTagger.getRequiredTags().size());
		assertEquals("Recommended tags", recSize, testTagger.getRecommendedTags().size());
	}

	@Test
	public void testSaveJson() throws URISyntaxException, IOException {
		System.out.println("It should, after saving to JSON and XML, be able"
				+ " to load the same information from the saved files.");
		File jsonLoad = TestUtilities.getResourceAsFile(TestUtilities.JsonEventsArrays);
		File xmlLoad = TestUtilities.getResourceAsFile(TestUtilities.HedRequiredRecommended);
		File testJsonOut = testFolder.newFile("testSaveJson.txt");
		File testXmlOut = testFolder.newFile("testSaveXml.xml");
		testTagger.loadJSON(jsonLoad, xmlLoad);
		// Get sizes for loaded data
		int tagSize = testTagger.getTagSet().size();
		int egtSize = testTagger.getEgtSet().size();
		ArrayList<Integer> numGroupsPerEvent = new ArrayList<Integer>();
		ArrayList<Integer> numTagsPerGroup = new ArrayList<Integer>();
		for (TaggedEvent event : testTagger.getEgtSet()) {
			numGroupsPerEvent.add(event.getTagGroups().size());
			for (Integer groupId : event.getTagGroups().keySet()) {
				numTagsPerGroup.add(event.getNumTagsInGroup(groupId));
			}
		}
		int reqSize = testTagger.getRequiredTags().size();
		int recSize = testTagger.getRecommendedTags().size();
		int uniqueSize = testTagger.getUniqueTags().size();
		testTagger.save(testJsonOut, testXmlOut, true);
		// Change data
		testTagger.deleteTag(testTagger.getTagSet().first());
		testTagger.removeEvent(testTagger.getEgtSet().first());
		// Reload from the saved output
		testTagger.loadJSON(testJsonOut, testXmlOut);
		// Verify EGT set
		int groupIdx = 0;
		int tagIdx = 0;
		assertEquals("EGT not loaded properly - wrong size", egtSize, testTagger.getEgtSet().size());
		for (TaggedEvent event : testTagger.getEgtSet()) {
			assertEquals("Groups per event", (int) numGroupsPerEvent.get(groupIdx++), event.getTagGroups().size());
			for (Integer groupId : event.getTagGroups().keySet()) {
				assertEquals("Tags per group", (int) numTagsPerGroup.get(tagIdx++), event.getNumTagsInGroup(groupId));
			}
		}
		// Verify tag set
		assertEquals("Tags not loaded properly - wrong size", tagSize, testTagger.getTagSet().size());
		assertEquals("Required tags", reqSize, testTagger.getRequiredTags().size());
		assertEquals("Recommended tags", recSize, testTagger.getRecommendedTags().size());
		assertEquals("Unique tags", uniqueSize, testTagger.getUniqueTags().size());
	}

	@Test
	public void testSaveTabDelimitedText() throws URISyntaxException, IOException {
		System.out.println("It should, after saving to tab-delimited text "
				+ "and XML, be able to load the same information from the " + "saved files.");
		File tdtLoad = TestUtilities.getResourceAsFile(TestUtilities.DelimitedString);
		File xmlLoad = TestUtilities.getResourceAsFile(TestUtilities.HedRequiredRecommended);
		File testTdtOut = testFolder.newFile("testSaveTdt.txt");
		File testXmlOut = testFolder.newFile("testSaveXml.xml");
		int headerLines = 0;
		int[] codeColumns = { 1 };
		int[] tagColumns = { 2 };
		testTagger.loadTabDelimited(tdtLoad, xmlLoad, headerLines, codeColumns, tagColumns);
		// Get sizes for loaded data
		int tagSize = testTagger.getTagSet().size();
		int egtSize = testTagger.getEgtSet().size();
		ArrayList<Integer> numGroupsPerEvent = new ArrayList<Integer>();
		ArrayList<Integer> numTagsPerGroup = new ArrayList<Integer>();
		for (TaggedEvent event : testTagger.getEgtSet()) {
			numGroupsPerEvent.add(event.getTagGroups().size());
			for (Integer groupId : event.getTagGroups().keySet()) {
				numTagsPerGroup.add(event.getNumTagsInGroup(groupId));
			}
		}
		int reqSize = testTagger.getRequiredTags().size();
		int recSize = testTagger.getRecommendedTags().size();
		int uniqueSize = testTagger.getUniqueTags().size();
		testTagger.save(testTdtOut, testXmlOut, false);
		// Change data
		testTagger.deleteTag(testTagger.getTagSet().first());
		testTagger.removeEvent(testTagger.getEgtSet().first());
		// Reload from the saved output
		testTagger.loadTabDelimited(testTdtOut, testXmlOut, headerLines, codeColumns, tagColumns);
		// Verify EGT set
		int groupIdx = 0;
		int tagIdx = 0;
		assertEquals("EGT not loaded properly - wrong size", egtSize, testTagger.getEgtSet().size());
		for (TaggedEvent event : testTagger.getEgtSet()) {
			assertEquals("Groups per event", (int) numGroupsPerEvent.get(groupIdx++), event.getTagGroups().size());
			for (Integer groupId : event.getTagGroups().keySet()) {
				assertEquals("Tags per group", (int) numTagsPerGroup.get(tagIdx++), event.getNumTagsInGroup(groupId));
			}
		}
		// Verify tag set
		assertEquals("Tags not loaded properly - wrong size", tagSize, testTagger.getTagSet().size());
		assertEquals("Required tags", reqSize, testTagger.getRequiredTags().size());
		assertEquals("Recommended tags", recSize, testTagger.getRecommendedTags().size());
		assertEquals("Unique tags", uniqueSize, testTagger.getUniqueTags().size());
	}

	@Test
	public void testTTRPAncestor() {
		System.out.println("It should not add an ancestor of an existing tag " + "in the group");
		// Add group
		testEvent1.addGroup(testGroupIds[0]);
		// Add tag to a group
		testEvent1.addTagToGroup(testGroupIds[0], tag);
		Set<Integer> groupIds = new LinkedHashSet<Integer>();
		groupIds.add(testGroupIds[0]);
		// Attempt to add tag ancestor
		ToggleTagMessage result = testTagger.toggleTag(tagAncestor, groupIds);
		assertNotNull("ToggleTagMessage returned", result);
		int expectedDescendants = 1;
		assertEquals("Descendants returned", expectedDescendants, result.descendants.size());
		EventModel descendant = result.descendants.get(0);
		assertEquals("Returned descendant group ID", testGroupIds[0], (int) descendant.getGroupId());
		assertEquals("Returned descendant tag path", tag.getPath(), descendant.getTagModel().getPath());
	}

	@Test
	public void testTTRPAncestorMultiple() {
		System.out.println("It should return the first desendant encountered.");
		// Add groups
		testEvent1.addGroup(testGroupIds[0]);
		testEvent2.addGroup(testGroupIds[1]);
		testEvent3.addGroup(testGroupIds[2]);
		testEvent3.addGroup(testGroupIds[3]);
		// Add tag and ancestor tags to groups
		testEvent1.addTagToGroup(testGroupIds[0], tag);
		testEvent2.addTagToGroup(testGroupIds[1], tagAncestor);
		testEvent3.addTagToGroup(testGroupIds[2], tagAncestor);
		testEvent3.addTagToGroup(testGroupIds[3], tagDescendant);
		// Attempt to add ancestor
		Set<Integer> groupIds = new LinkedHashSet<Integer>();
		groupIds.add(testGroupIds[0]);
		groupIds.add(testGroupIds[1]);
		groupIds.add(testGroupIds[2]);
		groupIds.add(testGroupIds[3]);
		ToggleTagMessage result = testTagger.toggleTag(tagAncestor2, groupIds);
		assertNotNull("ToggleTagMessage returned", result);
		int expectedDescendants = 4;
		assertEquals("Number of descendants returned", expectedDescendants, result.descendants.size());
	}

	@Test
	public void testTTRPDescendant() {
		System.out.println("It should not add a descendant tag of an " + "existing tag in the group");
		// Add group
		testEvent1.addGroup(testGroupIds[0]);
		// Add tag to a group
		testEvent1.addTagToGroup(testGroupIds[0], tag);
		Set<Integer> groupIds = new LinkedHashSet<Integer>();
		groupIds.add(testGroupIds[0]);
		// Attempt to add tag descendant
		ToggleTagMessage result = testTagger.toggleTag(tagDescendant, groupIds);
		assertNotNull("ToggleTagMessage returned", result);
		int expectedAncestors = 1;
		assertEquals("Ancestors returned", expectedAncestors, result.ancestors.size());
		EventModel ancestor = result.ancestors.get(0);
		assertEquals("Returned ancestor group ID", testGroupIds[0], (int) ancestor.getGroupId());
		assertEquals("Returned ancestor tag path", tag.getPath(), ancestor.getTagModel().getPath());
	}

	@Test
	public void testTTRPDescendantMultiple() {
		System.out.println("It should return all ancestors that would be " + "replaced.");
		// Add groups
		testEvent1.addGroup(testGroupIds[0]);
		testEvent2.addGroup(testGroupIds[1]);
		testEvent3.addGroup(testGroupIds[2]);
		testEvent3.addGroup(testGroupIds[3]);
		// Add tag and ancestor tags to groups
		testEvent1.addTagToGroup(testGroupIds[0], tag);
		testEvent2.addTagToGroup(testGroupIds[1], tagAncestor);
		testEvent3.addTagToGroup(testGroupIds[2], tagAncestor);
		testEvent3.addTagToGroup(testGroupIds[3], tagAncestor2);
		// Attempt to add descendant
		Set<Integer> groupIds = new LinkedHashSet<Integer>();
		groupIds.add(testGroupIds[0]);
		groupIds.add(testGroupIds[1]);
		groupIds.add(testGroupIds[2]);
		groupIds.add(testGroupIds[3]);
		ToggleTagMessage result = testTagger.toggleTag(tagDescendant, groupIds);
		assertNotNull("ToggleTagMessage returned", result);
		int expectedAncestors = 4;
		assertEquals("Number of ancestors returned", expectedAncestors, result.ancestors.size());
	}

	@Test
	public void testTTRPMixedMultiple() {
		System.out.println("It should return the first desendant encountered.");
		// Add new groups
		testEvent1.addGroup(testGroupIds[0]);
		testEvent2.addGroup(testGroupIds[1]);
		testEvent3.addGroup(testGroupIds[2]);
		testEvent3.addGroup(testGroupIds[3]);
		// Add tag and ancestor tags to groups
		testEvent1.addTagToGroup(testGroupIds[0], tagAncestor2);
		testEvent2.addTagToGroup(testGroupIds[1], tag);
		testEvent3.addTagToGroup(testGroupIds[2], tagAncestor);
		testEvent3.addTagToGroup(testGroupIds[3], tagDescendant);
		// Attempt to add ancestor
		Set<Integer> groupIds = new LinkedHashSet<Integer>();
		groupIds.add(testGroupIds[0]);
		groupIds.add(testGroupIds[1]);
		groupIds.add(testGroupIds[2]);
		groupIds.add(testGroupIds[3]);
		ToggleTagMessage result = testTagger.toggleTag(tagAncestor, groupIds);
		assertNotNull("ToggleTagMessage returned", result);
		int expectedDescendants = 2;
		int expectedAncestors = 1;
		assertEquals("Number of ancestors returned", expectedAncestors, result.ancestors.size());
		assertEquals("Number of descendants returned", expectedDescendants, result.descendants.size());
	}

	@Test
	public void testTTRPNormalAdd() {
		System.out.println("It should return null " + "(no ancestors or descendants found) when adding tag.");
		// Add groups
		testEvent1.addGroup(testGroupIds[0]);
		testEvent2.addGroup(testGroupIds[1]);
		testEvent3.addGroup(testGroupIds[2]);
		testEvent3.addGroup(testGroupIds[3]);
		// Add tag to some groups
		testEvent1.addTagToGroup(testGroupIds[0], tag);
		testEvent2.addTagToGroup(testGroupIds[1], tag);
		testEvent3.addTagToGroup(testGroupIds[2], tag);
		// Attempt to add tag
		Set<Integer> groupIds = new LinkedHashSet<Integer>();
		groupIds.add(testGroupIds[0]);
		groupIds.add(testGroupIds[1]);
		groupIds.add(testGroupIds[2]);
		groupIds.add(testGroupIds[3]);
		ToggleTagMessage result = testTagger.toggleTag(tag, groupIds);
		assertNull("ToggleTagMessage returned", result);
	}

	@Test
	public void testTTRPNormalRemove() {
		System.out.println("It should return null " + "(no ancestors or descendants found) when removing tag.");
		// Add groups
		testEvent1.addGroup(testGroupIds[0]);
		testEvent2.addGroup(testGroupIds[1]);
		testEvent3.addGroup(testGroupIds[2]);
		testEvent3.addGroup(testGroupIds[3]);
		// Add tag to all groups
		testEvent1.addTagToGroup(testGroupIds[0], tag);
		testEvent2.addTagToGroup(testGroupIds[1], tag);
		testEvent3.addTagToGroup(testGroupIds[2], tag);
		testEvent3.addTagToGroup(testGroupIds[3], tag);
		// Attempt to add tag
		Set<Integer> groupIds = new LinkedHashSet<Integer>();
		groupIds.add(testGroupIds[0]);
		groupIds.add(testGroupIds[1]);
		groupIds.add(testGroupIds[2]);
		groupIds.add(testGroupIds[3]);
		ToggleTagMessage result = testTagger.toggleTag(tag, groupIds);
		assertNull("ToggleTagMessage returned", result);
	}
}
