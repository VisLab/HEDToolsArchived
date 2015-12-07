package edu.utsa.tagger.guisupport;

import java.awt.Component;
import java.awt.Container;
import java.awt.Dimension;
import java.awt.LayoutManager2;
import java.util.ArrayList;
import java.util.List;

public class ConstraintLayout implements LayoutManager2 {
	
	class ConstraintPair {
		Component component;
		Constraint constraint;
		ConstraintPair(Component component, Constraint constraint) {
			this.component = component;
			this.constraint = constraint;
		}
	}
	
	public static double scale = 1.0;
	
	private List<ConstraintPair> constraintPairList;

	public ConstraintLayout() {
		constraintPairList = new ArrayList<ConstraintPair>();
	}

	@Override public void addLayoutComponent(Component c, Object obj) {
		if (c == null) {
			throw new NullPointerException();
		} else if (obj == null) {
			throw new NullPointerException();
		} else if (!(obj instanceof Constraint)) {
			throw new IllegalArgumentException("Object must be of type Constraint.");
		}
		
		constraintPairList.add(new ConstraintPair(c, (Constraint) obj));
	}
	
	@Override public void addLayoutComponent(String str, Component comp) {}
	
	private ConstraintPair getConstraintPair(Component component) {
		for (ConstraintPair constraintPair : constraintPairList) {
			if (constraintPair.component == component) {
				return constraintPair;
			}
		}
		return null;
	}

	@Override public float getLayoutAlignmentX(Container target) {return 0.5f;}

	@Override public float getLayoutAlignmentY(Container target) {return 0.5f;}
	@Override public void invalidateLayout(Container target) {}
	@Override public void layoutContainer(Container container) {
		
//		double scale = ((ScalableContainer) container).getScale();
//		double baseEm = ((ScalableContainer) container).getBaseEm();
//		double multiplier = scale * baseEm;
		
		for (ConstraintPair constraintPair : constraintPairList) {
			Component component = constraintPair.component;
			Constraint constraint = constraintPair.constraint;
			
			double left = 0;
			double top = 0;
			double width = container.getWidth();
			double height = container.getHeight();
			
			// horizontal layout calculations
			if (constraint.isLeftUsed() && constraint.isWidthUsed()) {
				left = scale * constraint.getLeft();
				width = scale * constraint.getWidth();
			} else if (constraint.isRightUsed() && constraint.isWidthUsed()) {
				left = container.getWidth() - scale * (constraint.getRight() + constraint.getWidth());
				width = scale * constraint.getWidth();
			} else if (constraint.isLeftUsed() && constraint.isRightUsed()) {
				left = scale * constraint.getLeft();
				width = container.getWidth() - scale * (constraint.getLeft() + constraint.getRight());
			}
			
			// vertical layout calculations
			if (constraint.isTopUsed() && constraint.isHeightUsed()) {
				top = scale * constraint.getTop();
				height = scale * constraint.getHeight();
			} else if (constraint.isBottomUsed() && constraint.isHeightUsed()) {
				top = container.getHeight() - scale * (constraint.getBottom() + constraint.getHeight());
				height = scale * constraint.getHeight();
			} else if (constraint.isTopUsed() && constraint.isBottomUsed()) {
				top = scale * constraint.getTop();
				height = container.getHeight() - scale * (constraint.getTop() + constraint.getBottom());
			}
			
			component.setLocation((int) left, (int) top);
			component.setSize((int) width, (int) height);
			
			// this is just so custom getPreferredSize code can execute
			// such a technique is useful for executing other code
			// when an invalidation occurs
			component.getPreferredSize();
		}
	}
	@Override public Dimension maximumLayoutSize(Container container) {return null;}
	@Override public Dimension minimumLayoutSize(Container target) { return null; }
	@Override public Dimension preferredLayoutSize(Container container) {
		
		double maxHeight = 0;
		double maxWidth = 0;
//		double scale = ((ScalableContainer) container).getScale();
//		double baseEm = ((ScalableContainer) container).getBaseEm();
//		double multiplier = scale * baseEm;
		
		for (ConstraintPair constraintPair : constraintPairList) {
			Constraint constraint = constraintPair.constraint;
			
			double width = 0;
			double height = 0;
			
			// horizontal layout calculations
			if (constraint.isLeftUsed() && constraint.isWidthUsed()) {
				width = scale * (constraint.getLeft() + constraint.getWidth());
			} else if (constraint.isRightUsed() && constraint.isWidthUsed()) {
				width = scale * (constraint.getRight() + constraint.getWidth());
			} else if (constraint.isLeftUsed() && constraint.isRightUsed()) {
				width = scale * (constraint.getLeft() + constraint.getRight());
			}
			
			// vertical layout calculations
			if (constraint.isTopUsed() && constraint.isHeightUsed()) {
				height = scale * (constraint.getTop() + constraint.getHeight());
			} else if (constraint.isBottomUsed() && constraint.isHeightUsed()) {
				height = scale * (constraint.getBottom() + constraint.getHeight());
			} else if (constraint.isTopUsed() && constraint.isBottomUsed()) {
				height = scale * (constraint.getTop() + constraint.getBottom());
			}
			
			if (width > maxWidth) {
				maxWidth = width;
			}
			if (height > maxHeight) {
				maxHeight = height;
			}
		}
		return new Dimension((int) maxWidth, (int) maxHeight);
	}
	@Override public void removeLayoutComponent(Component component) {
		ConstraintPair constraintPair = getConstraintPair(component);
		if (constraintPair != null) {
			constraintPairList.remove(constraintPair);
		}
	}

}
