package edu.utsa.tagger;

import edu.utsa.tagger.gui.GuiModelFactory;

/**
 * This class is used to load the Tagger GUI with the desired parameters.
 * 
 * @author Lauren Jett, Rebecca Strautman, Thomas Rognon, Jeremy Cockfield, Kay
 *         Robbins
 */
public class Loader {
	// Tagger flags
	// place bin
	public static final int USE_JSON = (1 << 0); // 1 0001
	public static final int PRESERVE_PREFIX = (1 << 1); // 2 0010
	public static final int IGNORE_EXTENSION_RULES = (1 << 2); // 3 0100
	public static final int TAG_EDIT_ALL = (1 << 3); // 4 1000

	/**
	 * Creates a Loader that launches the Tagger GUI with the given parameters.
	 * No events or tag hierarchy is included.
	 * 
	 * @param flags
	 *            Options for running Tagger
	 * @param permissions
	 * @param frameTitle
	 *            Title of Tagger GUI window
	 * @param initialDepth
	 *            Initial depth to display tags
	 * @param factory
	 *            Factory used to create the GUI
	 */
	public static void load(int flags, int permissions, String frameTitle,
			int initialDepth, IFactory factory, boolean isPrimary,
			boolean isStandAloneVersion) {
		new Loader(flags, permissions, frameTitle, initialDepth, factory,
				isPrimary, isStandAloneVersion);
	}

	/**
	 * Creates a Loader that launches the Tagger GUI with the given parameters.
	 * The default factory is used to create the GUI.
	 * 
	 * @param xmlData
	 *            An XML string in the TaggerData format containing the events
	 *            and the HED hierarchy
	 * @param flags
	 *            Options for running Tagger
	 * @param permissions
	 * @param frameTitle
	 *            Title of Tagger GUI window
	 * @param initialDepth
	 *            Initial depth to display tags
	 * @return String containing the TaggerData XML. If the user presses "Done,"
	 *         this includes the changes the user made in the GUI. If the user
	 *         presses "Cancel," this is equal to the String passed in as a
	 *         parameter (with no changes included).
	 */
	public static String load(String xmlData, int flags, int permissions,
			String frameTitle, int initialDepth, boolean isPrimary,
			boolean isStandAloneVersion) {
		return load(xmlData, flags, permissions, frameTitle, initialDepth,
				new GuiModelFactory(), isPrimary, isStandAloneVersion);

	}

	/**
	 * Creates a Loader that launches the Tagger GUI with the given parameters.
	 * 
	 * @param xmlData
	 *            An XML string in the TaggerData format containing the events
	 *            and the HED hierarchy
	 * @param flags
	 *            Options for running Tagger
	 * @param permissions
	 * @param frameTitle
	 *            Title of Tagger GUI window
	 * @param initialDepth
	 *            Initial depth to display tags
	 * @param factory
	 *            Factory used to create the GUI
	 * @return String containing the TaggerData XML. If the user presses "Done,"
	 *         this includes the changes the user made in the GUI. If the user
	 *         presses "Cancel," this is equal to the String passed in as a
	 *         parameter (with no changes included).
	 */
	public static String load(String xmlData, int flags, int permissions,
			String frameTitle, int initialDepth, IFactory factory,
			boolean isPrimary, boolean isStandAloneVersion) {
		Loader loader = new Loader(xmlData, flags, permissions, frameTitle,
				initialDepth, factory, isPrimary, isStandAloneVersion);

		loader.waitForSubmitted();

		String returnString = "";
		if (loader.isSubmitted()) {
			returnString = loader.tagger.getXmlDataString();
		} else {
			returnString = xmlData;
		}
		return returnString;
	}

	/**
	 * Creates a Loader that launches the Tagger GUI with the given parameters.
	 * The default factory is used to create the GUI.
	 * 
	 * @param tags
	 *            HED XML String
	 * @param events
	 *            Events JSON String
	 * @param flags
	 *            Options for running Tagger
	 * @param permissions
	 * @param frameTitle
	 *            Title of Tagger GUI window
	 * @param initialDepth
	 *            Initial depth to display tags
	 * @return String array containing the HED XML (index 0) and the events JSON
	 *         (index 1). If the user presses "Done," these include the changes
	 *         the user made in the GUI. If the user presses "Cancel," these are
	 *         equal to the Strings passed in as parameters (with no changes
	 *         included).
	 */
	public static String[] load(String tags, String events, int flags,
			int permissions, String frameTitle, int initialDepth,
			boolean isPrimary, boolean isStandAloneVersion) {
		return load(tags, events, flags, permissions, frameTitle, initialDepth,
				new GuiModelFactory(), isPrimary, isStandAloneVersion);
	}

	/**
	 * Creates a Loader that launches the Tagger GUI with the given parameters.
	 * 
	 * @param tags
	 *            HED XML String
	 * @param events
	 *            Events JSON String
	 * @param flags
	 *            Options for running Tagger
	 * @param permissions
	 * @param frameTitle
	 *            Title of Tagger GUI window
	 * @param initialDepth
	 *            Initial depth to display tags
	 * @param factory
	 *            Factory used to create the GUI
	 * @return String array containing the HED XML (index 0) and the events JSON
	 *         (index 1). If the user presses "Done," these include the changes
	 *         the user made in the GUI. If the user presses "Cancel," these are
	 *         equal to the Strings passed in as parameters (with no changes
	 *         included).
	 */
	public static String[] load(String tags, String events, int flags,
			int permissions, String frameTitle, int initialDepth,
			IFactory factory, boolean isPrimary, boolean isStandAloneVersion) {
		Loader loader = new Loader(tags, events, flags, permissions,
				frameTitle, initialDepth, factory, isPrimary,
				isStandAloneVersion);

		loader.waitForSubmitted();

		String[] returnString = new String[2];
		if (loader.isSubmitted()) {
			returnString[0] = loader.tagger.getHedXmlString();
			if (loader.testFlag(Loader.USE_JSON)) {
				returnString[1] = loader.tagger.getJsonEventsString();
			} else {
				// Tab-delimited text format
				returnString[1] = loader.tagger.getTdtEventsString();
			}
		} else {
			returnString[0] = tags;
			returnString[1] = events;
		}
		return returnString;
	}

	public static String[] load(Loader loader, String tags, String events) {
		loader.waitForSubmitted();
		String[] returnString = new String[2];
		if (loader.isSubmitted()) {
			returnString[0] = loader.tagger.getHedXmlString();
			if (loader.testFlag(Loader.USE_JSON)) {
				returnString[1] = loader.tagger.getJsonEventsString();
			} else {
				// Tab-delimited text format
				returnString[1] = loader.tagger.getTdtEventsString();
			}
		} else {
			returnString[0] = tags;
			returnString[1] = events;
		}
		return returnString;
	}

	// Loader instance variables
	private String tags = new String();
	private String events = new String();
	private int initialDepth = 0;
	private String title = null;
	private int permissions = 0;
	private int flags = 0;
	private boolean submitted = false;
	private boolean notified = false;
	private Tagger tagger;

	/**
	 * Constructor launches the Tagger GUI with no events or tag hierarchy using
	 * the given factory.
	 * 
	 * @param flags
	 *            Options for running Tagger
	 * @param permissions
	 * @param frameTitle
	 *            Title of Tagger GUI window
	 * @param initialDepth
	 *            Initial depth to display tags
	 * @param factory
	 *            Factory used to create the GUI
	 */
	public Loader(int flags, int permissions, String frameTitle,
			int initialDepth, IFactory factory, boolean isPrimary,
			boolean isStandAloneVersion) {
		this.initialDepth = initialDepth;
		this.title = frameTitle;
		this.permissions = permissions;
		this.flags = flags;
		tagger = new Tagger(isPrimary, factory, this);
		factory.createApp(this, tagger, frameTitle, isStandAloneVersion);
	}

	/**
	 * Constructor launches the Tagger GUI using the given TaggerData XML String
	 * and factory.
	 * 
	 * @param xmlData
	 *            An XML string in the TaggerData format containing the events
	 *            and the HED hierarchy
	 * @param flags
	 *            Options for running Tagger
	 * @param permissions
	 * @param frameTitle
	 *            Title of Tagger GUI window
	 * @param initialDepth
	 *            Initial depth to display tags
	 * @param factory
	 *            Factory used to create the GUI
	 */
	public Loader(String xmlData, int flags, int permissions,
			String frameTitle, int initialDepth, IFactory factory,
			boolean isPrimary, boolean isStandAloneVersion) {
		this.initialDepth = initialDepth;
		this.title = frameTitle;
		this.permissions = permissions;
		this.flags = flags;
		tagger = new Tagger(xmlData, isPrimary, factory, this);
		factory.createApp(this, tagger, frameTitle, isStandAloneVersion);
	}

	/**
	 * Constructor launches the Tagger GUI using the given JSON events String
	 * and HED XML String, and the default factory.
	 * 
	 * @param tags
	 *            HED XML String
	 * @param events
	 *            Events JSON String
	 * @param flags
	 *            Options for running Tagger
	 * @param permissions
	 * @param frameTitle
	 *            Title of Tagger GUI window
	 * @param initialDepth
	 *            Initial depth to display tags
	 */
	public Loader(String tags, String events, int flags, int permissions,
			String frameTitle, int initialDepth, boolean isPrimary,
			boolean isStandAloneVersion) {
		this(tags, events, flags, permissions, frameTitle, initialDepth,
				new GuiModelFactory(), isPrimary, isStandAloneVersion);
	}

	/**
	 * Constructor launches the Tagger GUI using the given JSON events String,
	 * HED XML String, and factory.
	 * 
	 * @param tags
	 *            HED XML String
	 * @param events
	 *            Events JSON String
	 * @param flags
	 *            Options for running Tagger
	 * @param permissions
	 * @param frameTitle
	 *            Title of Tagger GUI window
	 * @param initialDepth
	 *            Initial depth to display tags
	 * @param factory
	 *            Factory used to create the GUI
	 */
	public Loader(String tags, String events, int flags, int permissions,
			String frameTitle, int initialDepth, IFactory factory,
			boolean isPrimary, boolean isStandAloneVersion) {
		this.tags = tags;
		this.events = events;
		this.initialDepth = initialDepth;
		this.title = frameTitle;
		this.permissions = permissions;
		this.flags = flags;
		tagger = new Tagger(tags, events, isPrimary, factory, this);
		factory.createApp(this, tagger, frameTitle, isStandAloneVersion);
	}

	public synchronized String[] getXMLAndEvents() {
		return Loader.load(this, tags, events);
	}

	public synchronized int getInitialDepth() {
		return initialDepth;
	}

	public synchronized int getPermissions() {
		return permissions;
	}

	public synchronized String getTitle() {
		return title;
	}

	public synchronized boolean isNotified() {
		return notified;
	}

	public synchronized boolean isSubmitted() {
		return submitted;
	}

	public synchronized void setNotified(boolean notifiedArg) {
		notified = notifiedArg;
		notify();
	}

	public synchronized void setSubmitted(boolean submittedArg) {
		submitted = submittedArg;
	}

	public synchronized boolean testFlag(int flag) {
		return ((flags & flag) == flag);
	}

	public synchronized void waitForSubmitted() {
		try {
			while (!notified)
				wait();
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
}