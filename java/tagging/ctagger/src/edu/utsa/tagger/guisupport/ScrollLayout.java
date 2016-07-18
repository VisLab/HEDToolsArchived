package edu.utsa.tagger.guisupport;

import java.awt.Color;
import java.awt.Component;
import java.awt.Container;
import java.awt.Dimension;
import java.awt.LayoutManager;

import javax.swing.JComponent;
import javax.swing.JLayeredPane;
import javax.swing.JScrollPane;

public class ScrollLayout implements LayoutManager {

	private JLayeredPane scrollContainer;
	private JComponent content;

	private JScrollPane scrollbar;

	public ScrollLayout(JLayeredPane scrollContainerArg, JComponent contentArg) {
		scrollContainer = scrollContainerArg;
		content = contentArg;
		if (scrollContainer.getComponentCount() != 0) {
			throw new RuntimeException("ScrollLayout requires empty JLayeredPane.");
		}
		scrollbar = new JScrollPane(content);
		scrollbar.setVerticalScrollBarPolicy(JScrollPane.VERTICAL_SCROLLBAR_AS_NEEDED);
		scrollContainer.add(scrollbar);
		scrollbar.setBorder(null);
		scrollbar.getVerticalScrollBar().setUnitIncrement(20);
		scrollbar.setBackground(Color.gray);
		scrollbar.setOpaque(false);
	}

	@Override
	public void addLayoutComponent(String str, Component comp) {
		throw new RuntimeException("ScrollLayout can only have content and scrollBar.");
	}

	public JComponent getContentPane() {
		return content;
	}

	@Override
	public void layoutContainer(Container target) {
		scrollbar.setSize(target.getWidth(), scrollContainer.getHeight());
		scrollbar.setLocation(0, 0);
	}

	@Override
	public Dimension minimumLayoutSize(Container target) {
		return null;
	}

	public void pageDown() {
		scroll((int) (content.getHeight()));
	}

	public void pageUp() {
		scroll((int) (content.getHeight()));
	}

	@Override
	public Dimension preferredLayoutSize(Container target) {
		return null;
	}

	@Override
	public void removeLayoutComponent(Component comp) {
		throw new RuntimeException("Cannot remove elements from ScrollLayout.");
	}

	public void scroll(int y) {
		scrollbar.getVerticalScrollBar().setValue(y);
	}

	public void scrollTo(int y) {
		scrollbar.getVerticalScrollBar().setValue(y);
	}
}
