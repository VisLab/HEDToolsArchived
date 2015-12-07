package edu.utsa.tagger;

import java.util.LinkedHashSet;
import java.util.Set;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlType;

/**
 * This class is an XML model corresponding to a tag in the HED hierarchy.
 * 
 * @author Lauren Jett, Rebecca Strautman, Thomas Rognon, Jeremy Cockfield, Kay
 *         Robbins
 */
@XmlType(name = "unitClass")
@XmlAccessorType(XmlAccessType.FIELD)
public class UnitClassXmlModel {
	@XmlAttribute(name = "default")
	private String defaultUnit = "";
	private String name = "";
	private String units = "";
	private Set<UnitClassXmlModel> unitClass = new LinkedHashSet<UnitClassXmlModel>();

	public void addChild(UnitClassXmlModel child) {
		unitClass.add(child);
	}

	public String getDefault() {
		return defaultUnit;
	}

	public void setDefault(String defaultUnit) {
		this.defaultUnit = defaultUnit;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getUnits() {
		return units;
	}

	public void setUnits(String units) {
		this.units = units;
	}

}
