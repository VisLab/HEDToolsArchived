package edu.utsa.tagger.guisupport;

import java.awt.Component;
import java.util.HashMap;
import java.util.Map;

import javax.swing.JLayeredPane;


@SuppressWarnings("serial")
public class ConstraintContainer extends JLayeredPane {
	
	public enum Unit {
		PX, PCT
	}
	
	private Map<Component, Constraint> map = new HashMap<Component, Constraint>();
	
	public ConstraintContainer() {
		setOpaque(false);
		setLayout(new ConstraintLayout());
		new ClickDragThreshold(this);
	}
	
	@Override public Component add(Component comp) {
		add(comp, null, -1);
		return null;
	}
	
	@Override public void add(Component comp, Object constraint) {
		add(comp, constraint, -1);
	}
	
	@Override public void add(Component comp, Object constraint, int index) {
		if (constraint == null) {
			constraint = new Constraint();
		} else if (!(constraint instanceof Constraint)) {
			throw new RuntimeException("Invalid constraint");
		}
		map.put(comp, (Constraint) constraint);
		super.add(comp, constraint, index);
	}
	
	private Constraint getConstraint(Component comp) {
		Constraint constraint = map.get(comp);
		if (constraint == null) {
			throw new RuntimeException("Child does not exist.");
		} else {
			return constraint;
		}
	}
	
	@Override public void remove(Component comp) {
		map.remove(comp);
		super.remove(comp);
	}
	
	public void setBottomHeight(Component child, double bottom, Unit bottomUnit, double height, Unit heightUnit) {
		Constraint constraint = getConstraint(child);
		constraint.clearVertical();
		constraint.setBottom(bottom);
		constraint.setHeight(height);
	}
	
	public void setLeftRight(Component child, double left, Unit leftUnit, double right, Unit rightUnit) {
		Constraint constraint = getConstraint(child);
		constraint.clearHorizontal();
		constraint.setLeft(left);
		constraint.setRight(right);
	}
	
	public void setLeftWidth(Component child, double left, Unit leftUnit, double width, Unit widthUnit) {
		Constraint constraint = getConstraint(child);
		constraint.clearHorizontal();
		constraint.setLeft(left);
		constraint.setWidth(width);
	}
	
	public void setRightWidth(Component child, double right, Unit rightUnit, double width, Unit widthUnit) {
		Constraint constraint = getConstraint(child);
		constraint.clearHorizontal();
		constraint.setRight(right);
		constraint.setWidth(width);
	}
	
	public void setTopBottom(Component child, double top, Unit topUnit, double bottom, Unit bottomUnit) {
		Constraint constraint = getConstraint(child);
		constraint.clearVertical();
		constraint.setTop(top);
		constraint.setBottom(bottom);
	}
	
	public void setTopHeight(Component child, double top, Unit topUnit, double height, Unit heightUnit) {
		Constraint constraint = getConstraint(child);
		constraint.clearVertical();
		constraint.setTop(top);
		constraint.setHeight(height);
	}
}
