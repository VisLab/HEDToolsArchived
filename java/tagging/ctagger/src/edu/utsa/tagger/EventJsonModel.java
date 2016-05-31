package edu.utsa.tagger;

import java.util.List;

/**
 * This class represents a JSON model for tagged events.
 * 
 * @author Lauren Jett, Rebecca Strautman, Thomas Rognon, Jeremy Cockfield, Kay
 *         Robbins
 */
public class EventJsonModel {

	// ///////////////
	// JSON fields //
	// ///////////////

	private String code = new String();
	private List<List<String>> tags;

	public String getCode() {
		return code;
	}

	public List<List<String>> getTags() {
		return tags;
	}

	public void setCode(String codeArg) {
		this.code = codeArg;
	}

	public void setTags(List<List<String>> tags) {
		this.tags = tags;
	}

}
