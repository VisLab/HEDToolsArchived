package edu.utsa.tagger;

/**
 * This class launches the field selector automatically to be used as a
 * stand-alone tool.
 * 
 * @author Lauren Jett, Rebecca Strautman, Thomas Rognon, Jeremy Cockfield, Kay
 *         Robbins
 */
public class FieldSelectLauncher {
	public static void main(String[] args) {
		String[] excluded = { "Apples", "Bananas", "Oranges", "Grapes", "WaterMelons", "HoneyDew", "Nectarines" };
		String[] tagged = { "Peaches", "Cantaloupes", "Figs" };
		new FieldSelectLoader("Select which fields to tag", excluded, tagged);

	}
}
