package edu.utsa.tagger;

import java.util.LinkedHashSet;
import java.util.Set;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlType;

/**
 * This class is an XML model corresponding to a tag in the HED hierarchy.
 * 
 * @author Lauren Jett, Rebecca Strautman, Thomas Rognon, Jeremy Cockfield, Kay
 *         Robbins
 */
@XmlType(name = "node")
@XmlAccessorType(XmlAccessType.FIELD)
public class TagXmlModel {

	public enum PredicateType {
		PASSTHROUGH("passThrough"), PROPERTYOF("propertyOf"), SUBCLASSOF(
				"subClassOf");
		String value;

		PredicateType(String value) {
			this.value = value;
		}

		public String toString() {
			return value;
		}

		public boolean containsValue(String value) {
			for (PredicateType pt : PredicateType.values()) {
				if (pt.value.toUpperCase().equals(value.toUpperCase())) {
					return true;
				}
			}
			return false;
		}

		public boolean isPropertyOf(String value) {
			return PredicateType.PROPERTYOF.value.toUpperCase().equals(
					value.toUpperCase());
		}
	}

	// //////////////////
	// xml attributes //
	// //////////////////

	@XmlAttribute
	private boolean requireChild = false;
	@XmlAttribute
	private boolean takesValue = false;
	@XmlAttribute
	private boolean required = false;
	@XmlAttribute
	private boolean recommended = false;
	@XmlAttribute
	private int position = -1;
	@XmlAttribute
	private boolean unique = false;
	@XmlAttribute
	private boolean isNumeric = false;
	@XmlAttribute
	private String predicateType = PredicateType.SUBCLASSOF.toString();
	@XmlAttribute
	private String unitClass = new String();
	@XmlElement
	private String name = "(new tag)";
	@XmlElement
	private String description = "";
	@XmlElement
	private Set<TagXmlModel> node = new LinkedHashSet<TagXmlModel>();

	public void addChild(TagXmlModel child) {
		node.add(child);
	}

	public String getDescription() {
		return description;
	}

	// ////////////////
	// xml elements //
	// ////////////////

	public String getName() {
		return name;
	}

	public int getPosition() {
		return position;
	}

	public Set<TagXmlModel> getTags() {
		return node;
	}

	public String getPredicateType() {
		return predicateType;
	}

	public String getUnitClass() {
		return unitClass;
	}

	public boolean isChildRequired() {
		return requireChild;
	}

	public boolean isRecommended() {
		return recommended;
	}

	public boolean isRequired() {
		return required;
	}

	public boolean isUnique() {
		return unique;
	}

	public void setChildRequired(boolean requireChild) {
		this.requireChild = requireChild;
	}

	public void setDescription(String description) {
		this.description = description;
	}

	public void setName(String name) {
		this.name = name;
	}

	public void setPosition(int position) {
		this.position = position;
	}

	public void setRecommended(boolean recommended) {
		this.recommended = recommended;
	}

	public void setRequired(boolean required) {
		this.required = required;
	}

	public void setTakesValue(boolean takesValue) {
		this.takesValue = takesValue;
	}

	public void setPredicateType(String predicateType) {
		this.predicateType = predicateType;
	}

	public void setUnique(boolean unique) {
		this.unique = unique;
	}

	public void setUnitClass(String units) {
		this.unitClass = units;
	}

	public boolean takesValue() {
		return takesValue;
	}

	public void setIsNumeric(boolean isNumeric) {
		this.isNumeric = isNumeric;
	}

	public boolean isNumeric() {
		return isNumeric;
	}
}
