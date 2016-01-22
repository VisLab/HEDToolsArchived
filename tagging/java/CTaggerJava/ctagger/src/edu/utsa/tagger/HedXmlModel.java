package edu.utsa.tagger;

import java.util.LinkedHashSet;
import java.util.Set;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;

/**
 * This class is an XML model corresponding to the HED hierarchy XML format.
 * 
 * @author Lauren Jett, Rebecca Strautman, Thomas Rognon, Jeremy Cockfield, Kay
 *         Robbins
 */
@XmlRootElement(name = "HED")
@XmlAccessorType(XmlAccessType.FIELD)
public class HedXmlModel {

	@XmlAttribute
	private String version;
	@XmlElement
	private Set<TagXmlModel> node;
	@XmlElement
	private UnitClassesXmlModel unitClasses;

	public HedXmlModel() {
		version = new String();
		node = new LinkedHashSet<TagXmlModel>();
		unitClasses = new UnitClassesXmlModel();
	}

	public Set<TagXmlModel> getTags() {
		return node;
	}

	public String getVersion() {
		return version;
	}

	public UnitClassesXmlModel getUnitClasses() {
		return unitClasses;
	}

	public void setTags(Set<TagXmlModel> tags) {
		this.node = tags;
	}

	public void setUnitClasses(UnitClassesXmlModel unitClasses) {
		this.unitClasses = unitClasses;
	}

	public void setVersion(String version) {
		this.version = version;
	}

	@Override
	public String toString() {
		String s = "";
		for (TagXmlModel tagModel : node) {
			s += tagModel.toString() + "\n";
		}
		return s;
	}
}
