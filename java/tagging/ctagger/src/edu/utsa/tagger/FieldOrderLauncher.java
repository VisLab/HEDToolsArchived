package edu.utsa.tagger;

/**
 * This class launches the field selector automatically to be used as a
 * stand-alone tool.
 * 
 * @author Lauren Jett, Rebecca Strautman, Thomas Rognon, Jeremy Cockfield, Kay
 *         Robbins
 */
public class FieldOrderLauncher {
	public static void main(String[] args) {
		String[] fields = { "Apples", "Bananas", "Oranges", "Grapes", "WaterMelons", "HoneyDew", "Nectarines" };
		new FieldOrderLoader("Specify the ordering of the event fields", fields);

	}
}
