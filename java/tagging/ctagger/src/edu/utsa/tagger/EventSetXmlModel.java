package edu.utsa.tagger;

import java.util.LinkedHashSet;
import java.util.Set;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;

/**
 * This class is an XML model corresponding to the tag "eventSet" in the
 * TaggerData XML format.
 * 
 * @author Lauren Jett, Rebecca Strautman, Thomas Rognon, Jeremy Cockfield, Kay
 *         Robbins
 */
@XmlRootElement(name = "eventSet")
@XmlAccessorType(XmlAccessType.FIELD)
public class EventSetXmlModel {

	@XmlElement
	private Set<EventXmlModel> event = new LinkedHashSet<EventXmlModel>();

	public void addEvent(EventXmlModel event) {
		this.event.add(event);
	}

	public Set<EventXmlModel> getEventXmlModels() {
		return event;
	}

	public void setEventXmlModels(Set<EventXmlModel> events) {
		this.event = events;
	}
}
