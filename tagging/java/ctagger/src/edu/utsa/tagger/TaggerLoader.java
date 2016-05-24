package edu.utsa.tagger;

import java.io.IOException;

import edu.utsa.tagger.gui.GuiModelFactory;

/**
 * This class is used to load the TaggerView with the desired parameters.
 * 
 * @author Lauren Jett, Rebecca Strautman, Thomas Rognon, Jeremy Cockfield, Kay
 *         Robbins
 */
public class TaggerLoader {
	public static final int USE_JSON = (1 << 0); // 1 0001
	public static final int PRESERVE_PREFIX = (1 << 1); // 2 0010
	public static final int IGNORE_EXTENSION_RULES = (1 << 2); // 3 0100
	public static final int TAG_EDIT_ALL = (1 << 3); // 4 1000

	/**
	 * Creates a Loader that launches the TaggerViewwith the given parameters.
	 * No events or tag hierarchy is included.
	 * 
	 * @param flags
	 *            Options for running TaggerView.
	 * @param permissions
	 *            Permissions of the TaggerView.
	 * @param frameTitle
	 *            Title of TaggerView.
	 * @param initialDepth
	 *            Initial depth to display tags.
	 * @param factory
	 *            Factory used to create the TaggerView.
	 */
	public static void load(int flags, int permissions, String frameTitle, int initialDepth, IFactory factory,
			boolean isPrimary, boolean isStandAloneVersion) {
		new TaggerLoader(flags, permissions, frameTitle, initialDepth, factory, isPrimary, isStandAloneVersion);
	}

	/**
	 * Creates a Loader that launches the TaggerView with the given parameters.
	 * 
	 * @param xmlData
	 *            An XML string in the TaggerData format containing the events
	 *            and the HED hierarchy.
	 * @param flags
	 *            Options for running the TaggerView.
	 * @param permissions
	 *            The permissions of the TaggerView.
	 * 
	 * @param frameTitle
	 *            Title of TaggerView.
	 * @param initialDepth
	 *            Initial depth to display tags.
	 * @return String containing the TaggerData XML. If the user presses
	 *         "Proceed," this includes the changes the user made in the GUI. If
	 *         the user presses "Cancel," this is equal to the String passed in
	 *         as a parameter (with no changes included).
	 */
	public static String load(String xmlData, int flags, int permissions, String frameTitle, int initialDepth,
			boolean isPrimary, boolean isStandAloneVersion) {
		return load(xmlData, flags, permissions, frameTitle, initialDepth, new GuiModelFactory(), isPrimary,
				isStandAloneVersion);

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
	public static String load(String xmlData, int flags, int permissions, String frameTitle, int initialDepth,
			IFactory factory, boolean isPrimary, boolean isStandAloneVersion) {
		TaggerLoader loader = new TaggerLoader(xmlData, flags, permissions, frameTitle, initialDepth, factory,
				isPrimary, isStandAloneVersion);
		loader.waitForSubmitted();
		String returnString = new String();
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
	 * @throws IOException
	 */
	public static String[] load(String tags, String events, int flags, int permissions, String frameTitle,
			int initialDepth, boolean isPrimary, boolean isStandAloneVersion) throws IOException {
		return load(tags, events, flags, permissions, frameTitle, initialDepth, new GuiModelFactory(), isPrimary,
				isStandAloneVersion);
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
	 * @throws IOException
	 */
	public static String[] load(String tags, String events, int flags, int permissions, String frameTitle,
			int initialDepth, IFactory factory, boolean isPrimary, boolean isStandAloneVersion) throws IOException {
		TaggerLoader loader = new TaggerLoader(tags, events, flags, permissions, frameTitle, initialDepth, factory,
				isPrimary, isStandAloneVersion);
		loader.waitForSubmitted();
		String[] returnString = new String[2];
		if (loader.isSubmitted()) {
			returnString[0] = loader.tagger.getHedXmlString();
			if (loader.checkFlags(TaggerLoader.USE_JSON)) {
				returnString[1] = loader.tagger.getJsonEventsString();
			} else {
				returnString[1] = loader.tagger.createTSVString();
			}
		} else {
			returnString[0] = tags;
			returnString[1] = events;
		}
		return returnString;
	}

	public static String[] load(TaggerLoader loader, String tags, String events) throws IOException {
		String[] returnString = new String[2];
		returnString[0] = loader.tagger.getHedXmlString();
		if (loader.checkFlags(TaggerLoader.USE_JSON)) {
			returnString[1] = loader.tagger.getJsonEventsString();
		} else {
			returnString[1] = loader.tagger.createTSVString();
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
	private boolean fMapLoaded = false;
	private boolean fMapSaved = false;
	private String fMapPath = new String();
	private boolean startOver = false;

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
	public TaggerLoader(int flags, int permissions, String frameTitle, int initialDepth, IFactory factory,
			boolean isPrimary, boolean isStandAloneVersion) {
		this.initialDepth = initialDepth;
		this.title = frameTitle;
		this.permissions = permissions;
		this.flags = flags;
		tagger = new Tagger(isPrimary, factory, this);
		factory.createTaggerView(this, tagger, frameTitle, isStandAloneVersion);
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
	public TaggerLoader(String xmlData, int flags, int permissions, String frameTitle, int initialDepth,
			IFactory factory, boolean isPrimary, boolean isStandAloneVersion) {
		this.initialDepth = initialDepth;
		this.title = frameTitle;
		this.permissions = permissions;
		this.flags = flags;
		tagger = new Tagger(xmlData, isPrimary, factory, this);
		factory.createTaggerView(this, tagger, frameTitle, isStandAloneVersion);
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
	public TaggerLoader(String tags, String events, int flags, int permissions, String frameTitle, int initialDepth,
			boolean isPrimary, boolean isStandAloneVersion) {
		this(tags, events, flags, permissions, frameTitle, initialDepth, new GuiModelFactory(), isPrimary,
				isStandAloneVersion);
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
	public TaggerLoader(String tags, String events, int flags, int permissions, String frameTitle, int initialDepth,
			IFactory factory, boolean isPrimary, boolean isStandAloneVersion) {
		this.tags = tags;
		this.events = events;
		this.initialDepth = initialDepth;
		this.title = frameTitle;
		this.permissions = permissions;
		this.flags = flags;
		tagger = new Tagger(tags, events, isPrimary, factory, this);
		factory.createTaggerView(this, tagger, frameTitle, isStandAloneVersion);
	}

	public synchronized String[] getXMLAndEvents() throws IOException {
		return TaggerLoader.load(this, tags, events);
	}

	/**
	 * Gets the initial depth of the TaggerView.
	 * 
	 * @return The initial depth of the TaggerView.
	 */
	public synchronized int getInitialDepth() {
		return initialDepth;
	}

	/**
	 * Gets the permissions of the TaggerView.
	 * 
	 * @return The permissions of the TaggerView.
	 */
	public synchronized int getPermissions() {
		return permissions;
	}

	/**
	 * Gets the title of the TaggerView.
	 * 
	 * @return The title of the TaggerView.
	 */
	public synchronized String getTitle() {
		return title;
	}

	/**
	 * Checks if the TaggerView flags are equal to the flags passed in.
	 * 
	 * @param flags
	 *            The flags for the TaggerView.
	 * @return True if the flags are equal to the flags passed in, false if
	 *         otherwise.
	 */
	public synchronized boolean checkFlags(int flags) {
		return ((this.flags & flags) == flags);
	}

	/**
	 * Checks if the TaggerView is notified.
	 * 
	 * @param notified
	 *            True if the TaggerView is notified, false if otherwise.
	 */
	public synchronized boolean isNotified() {
		return notified;
	}

	/**
	 * Checks if the TaggerView is submitted.
	 * 
	 * @param notified
	 *            True if the TaggerView is submitted, false if otherwise.
	 */
	public synchronized boolean isSubmitted() {
		return submitted;
	}

	/**
	 * Sets if the TaggerView is notified.
	 * 
	 * @param notified
	 *            True if the TaggerView is notified, false if otherwise.
	 */
	public synchronized void setNotified(boolean notified) {
		this.notified = notified;
		notify();
	}

	/**
	 * Sets if the field map has been loaded in the TaggerView.
	 * 
	 * @param fMapLoaded
	 *            True if the TaggerView has loaded a field map, false if
	 *            otherwise.
	 */
	public synchronized void setFMapLoaded(boolean fMapLoaded) {
		this.fMapLoaded = fMapLoaded;
	}

	/**
	 * Sets if the field map has been saved in the TaggerView.
	 * 
	 * @param fMapSaved
	 *            True if the TaggerView has saved a field map, false if
	 *            otherwise.
	 */
	public synchronized void setFMapSaved(boolean fMapSaved) {
		this.fMapSaved = fMapSaved;
	}

	/**
	 * Sets the TaggerView field map path.
	 * 
	 * @param fMapPath
	 *            The TaggerView field map path.
	 */
	public synchronized void setFMapPath(String fMapPath) {
		this.fMapPath = fMapPath;
	}

	/**
	 * Sets if the TaggerView should start over.
	 * 
	 * @param startOver
	 *            True if the TaggerView should start over, false if otherwise.
	 */
	public synchronized void setStartOver(boolean startOver) {
		this.startOver = startOver;
	}

	/**
	 * Sets if the TaggerView is submitted.
	 * 
	 * @param submitted
	 *            True if the TaggerView is submitted, false if otherwise.
	 */
	public synchronized void setSubmitted(boolean submitted) {
		this.submitted = submitted;
	}

	/**
	 * Checks if TaggerView should be started over.
	 * 
	 * @return True if the TaggerView should be started over, false if
	 *         otherwise.
	 */
	public synchronized boolean isStartOver() {
		return startOver;
	}

	/**
	 * Checks to see if a field map has been loaded in the TaggerView.
	 * 
	 * @return True if a field map has been loaded in the TaggerView, false if
	 *         otherwise.
	 */
	public synchronized boolean fMapLoaded() {
		return fMapLoaded;
	}

	/**
	 * Checks to see if a field map has been saved in the TaggerView.
	 * 
	 * @return True if a field map has been saved, false if otherwise.
	 */
	public synchronized boolean fMapSaved() {
		return fMapSaved;
	}

	/**
	 * Gets the field map path in the TaggerView if there is one.
	 * 
	 * @return The field map path if there is one available in the TaggerView.
	 */
	public synchronized String getFMapPath() {
		return fMapPath;
	}

	/**
	 * Waits for the TaggerView to send a notification.
	 */
	public synchronized void waitForSubmitted() {
		try {
			while (!notified)
				wait();
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
}