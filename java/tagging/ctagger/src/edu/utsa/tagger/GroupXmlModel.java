package edu.utsa.tagger;

import java.util.LinkedHashSet;
import java.util.Set;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;

/**
 * This class is an XML model corresponding to the tag "tagGroup" in the
 * TaggerData XML format.
 * 
 * @author Lauren Jett, Rebecca Strautman, Thomas Rognon, Jeremy Cockfield, Kay
 *         Robbins
 */
@XmlAccessorType(XmlAccessType.FIELD)
public class GroupXmlModel {

	@XmlElement
	private Set<String> tag = new LinkedHashSet<String>();

	public void addTag(String tagPath) {
		this.tag.add(tagPath);
	}

	public Set<String> getTags() {
		return tag;
	}

	public void setTags(Set<String> tags) {
		this.tag = tags;
	}
}
