package edu.utsa.tagger.guisupport;

import java.awt.Color;
import java.awt.Component;
import java.awt.Container;
import java.awt.Dimension;
import java.awt.LayoutManager;
import java.awt.Point;
import java.awt.event.MouseEvent;
import java.awt.event.MouseListener;
import java.awt.event.MouseMotionListener;
import java.awt.event.MouseWheelEvent;
import java.awt.event.MouseWheelListener;

import javax.swing.JComponent;
import javax.swing.JLayeredPane;
import javax.swing.JPanel;

public class ScrollLayout implements LayoutManager {

	@SuppressWarnings("serial")
	public class ScrollBar extends JPanel implements MouseListener, MouseMotionListener {

		public ScrollBar() {
			addMouseListener(this);
			addMouseMotionListener(this);
			setBackground(new Color(150, 150, 150));
		}

		@Override
		public void mouseClicked(MouseEvent e) {
		}

		@Override
		public void mouseDragged(MouseEvent e) {
			Point p = scrollContainer.getMousePosition(true);
			if (p == null) {
				return;
			}

			int new_vert_pos = (int) ((p.getY() / scrollContainer.getHeight())
					* (content.getHeight() + scrollContainer.getHeight()));
			scroll(new_vert_pos - top);
		}

		@Override
		public void mouseEntered(MouseEvent e) {
			setBackground(new Color(112, 112, 112));
		}

		@Override
		public void mouseExited(MouseEvent e) {
			setBackground(new Color(150, 150, 150));
		}

		@Override
		public void mouseMoved(MouseEvent e) {
		}

		@Override
		public void mousePressed(MouseEvent e) {
		}

		@Override
		public void mouseReleased(MouseEvent e) {
		}
	}

	private JLayeredPane scrollContainer;
	private JComponent content;
	private ScrollBar scrollBar;
	private JPanel p;

	private int top;

	public ScrollLayout(JLayeredPane scrollContainerArg, JComponent contentArg) {
		scrollContainer = scrollContainerArg;
		content = contentArg;
		scrollBar = new ScrollBar();
		top = 0;

		if (scrollContainer.getComponentCount() != 0) {
			throw new RuntimeException("ScrollLayout requires empty JLayeredPane.");
		}
		p = new JPanel();
		p.setBackground(new Color(230, 230, 230));
		scrollContainer.add(content);
		scrollContainer.add(scrollBar);
		scrollContainer.setLayer(scrollBar, 3);
		scrollContainer.add(p);
		scrollContainer.setLayer(p, 1);
		scrollContainer.addMouseWheelListener(new MouseWheelListener() {
			@Override
			public void mouseWheelMoved(MouseWheelEvent e) {
				int rotation = e.getWheelRotation();
				if (rotation < 0) {
					scroll(-40);
				} else {
					scroll(40);
				}
			}
		});
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

		double targetHeight = target.getHeight();
		double contentHeight = content.getPreferredSize().height;

		if (top > contentHeight - targetHeight + scrollBar.getHeight()) {
			top = (int) (contentHeight - targetHeight + scrollBar.getHeight());
		}
		if (top < 0) {
			top = 0;
		}
		content.setSize(target.getWidth(), (int) contentHeight);
		content.setLocation(0, -top);

		// double sb_top = (top / contentHeight) * targetHeight;
		double sb_top = (top / contentHeight) * (targetHeight - scrollBar.getHeight());
		p.setSize(15, scrollContainer.getHeight());
		p.setLocation(target.getWidth() - 15, (int) sb_top);
		scrollBar.setSize(15, 120);
		scrollBar.setLocation(target.getWidth() - 15, (int) sb_top);
	}

	@Override
	public Dimension minimumLayoutSize(Container target) {
		return null;
	}

	public void pageDown() {
		scroll((int) (scrollContainer.getHeight() * .95));
	}

	public void pageUp() {
		scroll((int) (scrollContainer.getHeight() * -.95));
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
		top += y;
		scrollContainer.revalidate();
	}

	public void scrollTo(int y) {
		top = y;
		scrollContainer.revalidate();
	}
}
