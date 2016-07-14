package edu.utsa.tagger;

import edu.utsa.tagger.gui.FieldOrderView;
import edu.utsa.tagger.gui.GuiModelFactory;

/**
 * This class is used to load the FieldSelectView that allows the user to select
 * which fields to exclude or tag.
 * 
 * @author Jeremy Cockfield, Kay Robbins
 */
public class FieldOrderLoader {

	private boolean submitted = false;
	private boolean notified = false;
	private String[] fields = null;
	FieldOrderView fieldOrderView;

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
	public FieldOrderLoader(String frameTitle, String[] fields) {
		this(new GuiModelFactory(), frameTitle, fields);
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
	public FieldOrderLoader(IFactory factory, String frameTitle, String[] fields) {
		fieldOrderView = factory.createFieldOrderView(this, frameTitle, fields);
	}

	/**
	 * Gets the tagged fields.
	 * 
	 * @return A String array containing the tagged fields.
	 */
	public synchronized String[] getFields() {
		return fields;
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
	 * Sets the tagged fields.
	 * 
	 * @param taggedFields
	 *            A String array containing the tagged fields.
	 */
	public synchronized void setFields(String[] fields) {
		this.fields = fields;
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