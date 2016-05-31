package edu.utsa.tagger.guisupport;

import java.awt.Component;
import java.awt.Container;
import java.awt.Dimension;
import java.awt.Insets;
import java.awt.LayoutManager;

public class ListLayout implements LayoutManager {
	
	private int topMargin = 0;
	private int leftMargin = 0;
	private int bottomMargin = 0;
	private int rightMargin = 0;
	
	public ListLayout(int topMarginArg, int leftMarginArg, int bottomMarginArg, int rightMarginArg) {
		topMargin = topMarginArg;
		leftMargin = leftMarginArg;
		bottomMargin = bottomMarginArg;
		rightMargin = rightMarginArg;
	}

	@Override public void addLayoutComponent(String str, Component comp) {}

	@Override public void layoutContainer(Container target) {
		Insets insets = target.getInsets();
		int h = 0;
		int listHeight = insets.top;
		for (Component comp : target.getComponents()) {
			
			if (!comp.isVisible()) {
				continue;
			}
			
			listHeight += topMargin;
			
			h = comp.getPreferredSize().height;
			
			comp.setBounds(
					insets.left + leftMargin, 
					listHeight, 
					target.getWidth() - insets.left - - leftMargin - insets.right - rightMargin, 
					h);
			
			listHeight += h;
			listHeight += bottomMargin;
		}
	}
	@Override public Dimension minimumLayoutSize(Container target) { return null; }
	@Override public Dimension preferredLayoutSize(Container target) {
		Insets insets = target.getInsets();
		int x = 0, y = 0;
		for (Component comp : target.getComponents()) {
			if (comp.isVisible()) {
				if (comp.getPreferredSize().width > x) {
					x = comp.getPreferredSize().width;
				}
				y += comp.getPreferredSize().height;
			}
		}
		return new Dimension(
				insets.left + leftMargin + x + insets.right + rightMargin, 
				insets.top + y + insets.bottom + (topMargin + bottomMargin) * target.getComponentCount());
	}
	@Override public void removeLayoutComponent(Component comp) {}
}
