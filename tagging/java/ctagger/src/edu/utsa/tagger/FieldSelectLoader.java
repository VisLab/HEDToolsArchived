package edu.utsa.tagger;

import edu.utsa.tagger.gui.GuiModelFactory;

/**
 * This class is used to load the FieldSelectView that allows the user to select
 * which fields to exclude or tag.
 * 
 * @author Jeremy Cockfield, Kay Robbins
 */
public class FieldSelectLoader {

	private boolean submitted = false;
	private boolean notified = false;

	/**
	 * The constructor for the FieldSelectLoader.
	 * 
	 * @param frameTitle
	 *            The title for the FieldSelectView frame.
	 * @param excluded
	 *            The excluded fields for the FieldSelectView list box.
	 * @param tagged
	 *            The tagged fields for the FieldSelectView list box.
	 */
	public FieldSelectLoader(String frameTitle, String[] excluded, String[] tagged) {
		this(new GuiModelFactory(), frameTitle, excluded, tagged);
	}

	/**
	 * 
	 * @param factory
	 *            The Factory interface used to create a FieldSelectView object.
	 * @param frameTitle
	 *            The title for the FieldSelectView frame.
	 * @param excluded
	 *            The excluded fields for the FieldSelectView list box.
	 * @param tagged
	 *            The tagged fields for the FieldSelectView list box.
	 */
	public FieldSelectLoader(IFactory factory, String frameTitle, String[] excluded, String[] tagged) {
		factory.createFieldSelectView(this, frameTitle, excluded, tagged);
	}

	/**
	 * Checks to see if the FieldSelectView is notified.
	 * 
	 * @return True if the FieldSelectView is notified, false if otherwise.
	 */
	public synchronized boolean isNotified() {
		return notified;
	}

	/**
	 * Checks to see if the FieldSelectView is submitted.
	 * 
	 * @return True if the FieldSelectView is submitted, false if otherwise.
	 */
	public synchronized boolean isSubmitted() {
		return submitted;
	}

	/**
	 * Sets if the FieldSelectView is notified.
	 * 
	 * @param submitted
	 *            True if the FieldSelectView is notified, false if otherwise.
	 */
	public synchronized void setNotified(boolean notified) {
		this.notified = notified;
		notify();
	}

	/**
	 * Sets if the FieldSelectView is submitted.
	 * 
	 * @param submitted
	 *            True if the FieldSelectView is submitted, false if otherwise.
	 */
	public synchronized void setSubmitted(boolean submitted) {
		this.submitted = submitted;
	}

	/**
	 * Waits for the FieldSelectView to send a notification.
	 */
	public synchronized void waitForNotified() {
		try {
			while (!notified)
				wait();
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
}