package edu.utsa.tagger;

import java.util.LinkedHashSet;
import java.util.Set;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;

/**
 * This class is an XML model corresponding to the tag "event" in the TaggerData
 * XML format.
 * 
 * @author Lauren Jett, Rebecca Strautman, Thomas Rognon, Jeremy Cockfield, Kay
 *         Robbins
 */
@XmlAccessorType(XmlAccessType.FIELD)
public class EventXmlModel {

	@XmlElement
	private String label;
	@XmlElement
	private String code;
	@XmlElement
	private Set<GroupXmlModel> tagGroup = new LinkedHashSet<GroupXmlModel>();
	@XmlElement
	private Set<String> tag = new LinkedHashSet<String>();

	public void addGroup(GroupXmlModel group) {
		this.tagGroup.add(group);
	}

	public void addTag(String tag) {
		this.tag.add(tag);
	}

	public String getCode() {
		return code;
	}

	public Set<GroupXmlModel> getGroups() {
		return tagGroup;
	}

	public String getLabel() {
		return label;
	}

	public Set<String> getTags() {
		return tag;
	}

	public void setCode(String code) {
		this.code = code;
	}

	public void setGroups(Set<GroupXmlModel> groups) {
		this.tagGroup = groups;
	}

	public void setLabel(String label) {
		this.label = label;
	}

	public void setTags(Set<String> tags) {
		this.tag = tags;
	}
}
