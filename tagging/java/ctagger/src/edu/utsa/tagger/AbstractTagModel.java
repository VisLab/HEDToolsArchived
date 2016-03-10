package edu.utsa.tagger;

import java.util.Date;

import edu.utsa.tagger.TagXmlModel.PredicateType;

/**
 * This class represents a tag used in the Tagger.
 * 
 * @author Lauren Jett, Rebecca Strautman, Thomas Rognon, Jeremy Cockfield, Kay
 *         Robbins
 */
public abstract class AbstractTagModel implements Comparable<AbstractTagModel> {

	private String path;
	private String name;
	private String parentPath;
	private int depth;
	private String description;
	private Date creationDate;
	private Date lastModified;
	private boolean childRequired;
	private boolean extensionAllowed;
	private boolean takesValue;
	private boolean isNumeric;
	private boolean required;
	private boolean recommended;
	private int position = -1;
	private boolean unique;
	private String unitClass;
	private PredicateType predicateType = PredicateType.SUBCLASSOF;

	/**
	 * Tags are compared by their paths.
	 */
	@Override
	public int compareTo(AbstractTagModel o) {
		return getPath().compareTo(o.getPath());
	}

	/**
	 * Tags are considered equal if their paths are equal.
	 */
	@Override
	public boolean equals(Object obj) {
		if (this == obj)
			return true;
		if (obj == null)
			return false;
		if (getClass() != obj.getClass())
			return false;
		AbstractTagModel other = (AbstractTagModel) obj;
		if (path == null) {
			if (other.path != null)
				return false;
		} else if (!path.equals(other.path))
			return false;
		return true;
	}

	public Date getCreationDate() {
		return creationDate;
	}

	public int getDepth() {
		return depth;
	}

	public String getDescription() {
		return description;
	}

	public Date getLastModified() {
		return lastModified;
	}

	public String getName() {
		return name;
	}

	public String getParentPath() {
		return parentPath;
	}

	public PredicateType getPredicateType() {
		return predicateType;
	}

	public String getUnitClass() {
		return unitClass;
	}

	public String getPath() {
		return path;
	}

	public int getPosition() {
		return position;
	}

	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + ((path == null) ? 0 : path.hashCode());
		return result;
	}

	public boolean isChildRequired() {
		return childRequired;
	}

	public boolean isExtensionAllowed() {
		return extensionAllowed;
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

	public void setChildRequired(boolean childRequired) {
		this.childRequired = childRequired;
	}

	public void setCreationDate(Date creationDate) {
		this.creationDate = creationDate;
	}

	public void setDescription(String description) {
		this.description = description;
	}

	public void setLastModified(Date lastModified) {
		this.lastModified = lastModified;
	}

	/**
	 * Sets the tag's path, depth, and parent path.
	 * 
	 * @param pathArg
	 */
	public void setPath(String pathArg) {
		path = pathArg;
		name = path.substring(path.lastIndexOf('/') + 1);
		depth = 2;
		for (int i = 0; i < path.length(); i++) {
			if (path.charAt(i) == '/') {
				depth++;
			}
		}
		if (depth == 2) {
			parentPath = null;
		} else {
			parentPath = path.substring(0, path.lastIndexOf('/'));
		}
	}

	public void setPosition(int position) {
		this.position = position;
	}

	public void setPredicateType(PredicateType predicateType) {
		this.predicateType = predicateType;
	}

	public void setUnitClass(String unitClass) {
		this.unitClass = unitClass;
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

	public void setExtensionAllowed(boolean extensionAllowed) {
		this.extensionAllowed = extensionAllowed;
	}

	public void setIsNumeric(boolean isNumeric) {
		this.isNumeric = isNumeric;
	}

	public void setUnique(boolean unique) {
		this.unique = unique;
	}

	public boolean takesValue() {
		return takesValue;
	}

	public boolean isNumeric() {
		return isNumeric;
	}
}
