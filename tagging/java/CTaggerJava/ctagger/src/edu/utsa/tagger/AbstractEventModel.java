package edu.utsa.tagger;

/**
 * This class represents an event used in the Tagger.
 * 
 * @author Lauren Jett, Rebecca Strautman, Thomas Rognon, Jeremy Cockfield, Kay
 *         Robbins
 */
public abstract class AbstractEventModel implements
		Comparable<AbstractEventModel> {

	private String code;
	private String label;

	@Override
	public int compareTo(AbstractEventModel o) {
		return getCode().compareTo(o.getCode());
	}

	@Override
	public boolean equals(Object obj) {
		if (this == obj)
			return true;
		if (obj == null)
			return false;
		if (getClass() != obj.getClass())
			return false;
		AbstractEventModel other = (AbstractEventModel) obj;
		if (code == null) {
			if (other.code != null)
				return false;
		} else if (!code.equals(other.code))
			return false;
		if (label == null) {
			if (other.label != null)
				return false;
		} else if (!label.equals(other.label))
			return false;
		return true;
	}

	public String getCode() {
		return code;
	}

	public String getLabel() {
		return label;
	}

	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + ((code == null) ? 0 : code.hashCode());
		return result;
	}

	public void setCode(String code) {
		this.code = code;
	}

	public void setLabel(String label) {
		this.label = label;
	}
}