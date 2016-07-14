package edu.utsa.tagger;

import edu.utsa.tagger.gui.FieldSelectView;
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
	private String primaryField = new String();
	private String[] taggedFields = null;
	private String[] excludedFields = null;
	FieldSelectView fieldSelectView;

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
	public FieldSelectLoader(String frameTitle, String[] excluded, String[] tagged, String primaryField) {
		this(new GuiModelFactory(), frameTitle, excluded, tagged, primaryField);
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
	public FieldSelectLoader(IFactory factory, String frameTitle, String[] excluded, String[] tagged,
			String primaryField) {
		fieldSelectView = factory.createFieldSelectView(this, frameTitle, excluded, tagged, primaryField);
	}

	/**
	 * Gets the primary field.
	 * 
	 * @return A String containing the primary field.
	 */
	public synchronized String getPrimaryField() {
		return primaryField;
	}

	/**
	 * Gets the tagged fields.
	 * 
	 * @return A String array containing the tagged fields.
	 */
	public synchronized String[] getTagFields() {
		return taggedFields;
	}

	/**
	 * Gets the excluded fields.
	 * 
	 * @return A String array containing the excluded fields.
	 */
	public synchronized String[] getExcludeFields() {
		return excludedFields;
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
	 * Sets the primary field.
	 * 
	 * @param primaryField
	 *            Sets the primary field from the FieldSelectView.
	 */
	public synchronized void setPrimaryField(String primaryField) {
		this.primaryField = primaryField;
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
	public synchronized void setTaggedFields(String[] taggedFields) {
		this.taggedFields = taggedFields;
	}

	/**
	 * Sets the excluded fields.
	 * 
	 * @param excludedFields
	 *            A String array containing the excluded fields.
	 */
	public synchronized void setExcludedFields(String[] excludedFields) {
		this.excludedFields = excludedFields;
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