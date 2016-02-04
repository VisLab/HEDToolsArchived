package edu.utsa.tagger.guisupport;

import java.awt.Component;
import java.awt.Container;
import java.awt.Dimension;
import java.awt.Graphics;
import java.awt.LayoutManager;
import java.awt.Point;
import java.awt.event.MouseEvent;
import java.awt.event.MouseListener;
import java.awt.event.MouseMotionListener;

import javax.swing.JComponent;
import javax.swing.JLayeredPane;

import edu.utsa.tagger.gui.FontsAndColors;

public class VerticalSplitLayout implements LayoutManager {
	
	@SuppressWarnings("serial")
	public class Splitter extends JComponent implements MouseListener, MouseMotionListener {
		
		private boolean hover = false;
		private boolean pressed = false;
		
		public Splitter() {
			addMouseListener(this);
			addMouseMotionListener(this);
		}

		@Override public void mouseClicked(MouseEvent e) {}

		@Override public void mouseDragged(MouseEvent e) {
			Point p = container.getMousePosition(true);
			if (p == null) {
				return;
			}
			setX(p.x);
		}

		@Override public void mouseEntered(MouseEvent e) {
			hover = true;
			repaint();
		}

		@Override public void mouseExited(MouseEvent e) {
			hover = false;
			repaint();
		}

		@Override public void mouseMoved(MouseEvent e){}

		@Override public void mousePressed(MouseEvent e) {
			pressed = true;
			repaint();
		}

		@Override public void mouseReleased(MouseEvent e) {
			pressed = false;
			repaint();
		}
		
		@Override protected void paintComponent(Graphics g) {
			if (hover || pressed) {
				g.setColor(FontsAndColors.BLUE_MEDIUM);
				g.fillRect(getWidth() / 2 - 1, 0, 2, getHeight());
			}
		}
	}
	private JLayeredPane container;
	private JComponent leftComponent;
	private JComponent rightComponent;
	private Splitter splitter;

	private int x;
	
	public VerticalSplitLayout(JLayeredPane containerArg, JComponent leftComponentArg, JComponent rightComponentArg, int initialX) {
		container = containerArg;
		leftComponent = leftComponentArg;
		rightComponent = rightComponentArg;
		splitter = new Splitter();
		x = initialX;
		
		if (container.getComponentCount() != 0) {
			throw new RuntimeException("VerticalSplitLayout requires empty JLayeredPane.");
		}
		
		container.add(leftComponent);
		container.add(rightComponent);
		container.add(splitter);
		container.setLayer(splitter, 1);
	}
	
	@Override public void addLayoutComponent(String str, Component comp) {
		throw new RuntimeException("VerticalSplitLayout can only have content and scrollBar.");
	}
	
	public JComponent getLeftComponent() {
		return leftComponent;
	}

	public JComponent getRightComponent() {
		return rightComponent;
	}

	@Override public void layoutContainer(Container target) {
		
		int h = target.getHeight();
		int splitterWidth = 10;
		
		if (x < 100) {
			x = 100;
		}
		if (x > target.getWidth() - 100) {
			x = target.getWidth() - 100;
		}
		
		leftComponent.setLocation(0, 0);
		leftComponent.setSize(x - splitterWidth / 2, h);
		
		splitter.setLocation(x - splitterWidth / 2, 0);
		splitter.setSize(splitterWidth, h);
		
		rightComponent.setLocation(x + splitterWidth / 2, 0);
		rightComponent.setSize(target.getWidth() - (x + splitterWidth / 2), h);
	}
	@Override public Dimension minimumLayoutSize(Container target) { return null; }
	@Override public Dimension preferredLayoutSize(Container target) { return null; }
	@Override public void removeLayoutComponent(Component comp) {
		throw new RuntimeException("Cannot remove elements from VerticalSplitLayout.");
	}
	
	public void setX(int xArg) {
		x = xArg;
		container.revalidate();
	}
}
