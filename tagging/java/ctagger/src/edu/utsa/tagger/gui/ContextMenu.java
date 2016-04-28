package edu.utsa.tagger.gui;

import java.awt.Color;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.RenderingHints;
import java.awt.event.MouseEvent;
import java.awt.event.MouseListener;
import java.awt.geom.Rectangle2D;
import java.util.Map;
import java.util.Map.Entry;

import javax.swing.JComponent;
import javax.swing.JPanel;

import edu.utsa.tagger.guisupport.ClickDragThreshold;
import edu.utsa.tagger.guisupport.Constraint;
import edu.utsa.tagger.guisupport.ConstraintLayout;

/**
 * This class represents the view for a Context Menu.
 * 
 * @author Lauren Jett, Rebecca Strautman, Thomas Rognon, Jeremy Cockfield, Kay
 *         Robbins
 */
@SuppressWarnings("serial")
public class ContextMenu extends JPanel {

	public static interface ContextMenuAction {
		void doAction();
	}

	private static class ContextMenuItem extends JComponent implements
			MouseListener {

		private final TaggerView appView;
		private final String text;
		private final ContextMenuAction action;
		private boolean hover;
		private boolean pressed;

		private ContextMenuItem(TaggerView appView, String text,
				ContextMenuAction action) {
			if (appView == null || text == null || action == null) {
				throw new NullPointerException();
			}
			this.appView = appView;
			this.text = text;
			this.action = action;
			setLayout(null);
			addMouseListener(this);
			new ClickDragThreshold(this);
		}

		@Override
		public void mouseClicked(MouseEvent e) {
			action.doAction();
			appView.hideContextMenu();
		}

		@Override
		public void mouseEntered(MouseEvent e) {
			hover = true;
			repaint();
		}

		@Override
		public void mouseExited(MouseEvent e) {
			hover = false;
			repaint();
		}

		@Override
		public void mousePressed(MouseEvent e) {
			pressed = true;
			repaint();
		}

		@Override
		public void mouseReleased(MouseEvent e) {
			pressed = false;
			repaint();
		}

		@Override
		protected void paintComponent(Graphics g) {

			Graphics2D g2d = (Graphics2D) g;
			g2d.setRenderingHint(RenderingHints.KEY_TEXT_ANTIALIASING,
					RenderingHints.VALUE_TEXT_ANTIALIAS_LCD_HRGB);

			Color fg;
			Color bg;

			if (pressed && hover) {
				fg = FontsAndColors.CONTEXTMENUITEM_FG_PRESSED;
				bg = FontsAndColors.CONTEXTMENUITEM_BG_PRESSED;
			} else if (!pressed && hover) {
				fg = FontsAndColors.CONTEXTMENUITEM_FG_HOVER;
				bg = FontsAndColors.CONTEXTMENUITEM_BG_HOVER;
			} else {
				fg = FontsAndColors.CONTEXTMENUITEM_FG_NORMAL;
				bg = FontsAndColors.CONTEXTMENUITEM_BG_NORMAL;
			}

			g2d.setColor(bg);
			g2d.fill(new Rectangle2D.Double(0, 0, getWidth(), getHeight()));

			double x = getHeight() * 0.4;
			double y = getHeight() * 0.75;

			g2d.setColor(fg);
			g2d.setFont(FontsAndColors.contentFont);
			g2d.drawString(text + " ", (int) x, (int) y);
		}

	}

	public ContextMenu(TaggerView appView, Map<String, ContextMenuAction> map) {
		setBackground(FontsAndColors.CONTEXTMENU_BG);
		setLayout(new ConstraintLayout());
		int top = 0;
		for (Entry<String, ContextMenuAction> entry : map.entrySet()) {
			add(new ContextMenuItem(appView, entry.getKey(), entry.getValue()),
					new Constraint("top:" + top + " height:30"));
			top += 30;
		}
	}

}
