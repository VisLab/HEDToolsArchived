package edu.utsa.tagger;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;

/**
 * This class is an XML model corresponding to the TaggerData XML format at the
 * root level.
 * 
 * @author Lauren Jett, Rebecca Strautman, Thomas Rognon, Jeremy Cockfield, Kay
 *         Robbins
 */
@XmlRootElement(name = "TaggerData")
@XmlAccessorType(XmlAccessType.FIELD)
public class TaggerDataXmlModel {

	@XmlElement
	private EventSetXmlModel eventSet;

	@XmlElement
	private HedXmlModel HED;

	public EventSetXmlModel getEgtSetXmlModel() {
		return eventSet;
	}

	public HedXmlModel getHedXmlModel() {
		return HED;
	}

	public void setEventSetXmlModel(EventSetXmlModel egtSet) {
		this.eventSet = egtSet;
	}

	public void setHedXmlModel(HedXmlModel hed) {
		this.HED = hed;
	}
}
