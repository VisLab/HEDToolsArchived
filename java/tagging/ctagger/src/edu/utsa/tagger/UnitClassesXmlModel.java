package edu.utsa.tagger;

import java.util.LinkedHashSet;
import java.util.Set;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlType;

/**
 * This class is an XML model corresponding to a tag in the HED hierarchy.
 * 
 * @author Lauren Jett, Rebecca Strautman, Thomas Rognon, Jeremy Cockfield, Kay
 *         Robbins
 */
@XmlType(propOrder = {}, name = "unitClasses")
@XmlAccessorType(XmlAccessType.FIELD)
public class UnitClassesXmlModel {

	private Set<UnitClassXmlModel> unitClass = new LinkedHashSet<UnitClassXmlModel>();

	public void setUnitClasses(Set<UnitClassXmlModel> unitClass) {
		this.unitClass = unitClass;
	}

	public Set<UnitClassXmlModel> getUnitClasses() {
		return unitClass;
	}

	public void addUnitClass(UnitClassXmlModel unitClass) {
		this.unitClass.add(unitClass);
	}

}
