package edu.utsa.tagger.gui;

import java.awt.Color;
import java.awt.Dimension;
import java.awt.Font;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.RenderingHints;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;
import java.awt.event.MouseListener;
import java.awt.geom.Rectangle2D;

import javax.swing.JComponent;
import javax.swing.SwingUtilities;

import edu.utsa.tagger.Tagger;
import edu.utsa.tagger.guisupport.ClickDragThreshold;

/**
 * View used to display a tag as a search result.
 * 
 * @author Lauren Jett, Rebecca Strautman, Thomas Rognon, Jeremy Cockfield, Kay
 *         Robbins
 */
@SuppressWarnings("serial")
public class TagSearchView extends JComponent implements MouseListener {

	private boolean hover = false;
	private boolean pressed = false;

	private final GuiTagModel model;

	public TagSearchView(final Tagger tagger, final AppView appView, final GuiTagModel model) {

		this.model = model;

		setLayout(null);
		addMouseListener(this);
		new ClickDragThreshold(this);

		/**
		 * When the mouse is clicked, it scrolls to and highlights the tag in
		 * the hierarchy, and cancels the search.
		 */
		addMouseListener(new MouseAdapter() {
			@Override
			public void mouseClicked(MouseEvent e) {
				if (SwingUtilities.isLeftMouseButton(e)) {
					tagger.openToClosest(model);
					appView.cancelSearch();
					appView.updateTags();
					appView.scrollToTag(model);
				}
			}
		});
	}

	@Override
	public Dimension getPreferredSize() {
		return new Dimension(0, (int) (FontsAndColors.contentFont.getSize2D() * 1.5));
	}

	@Override
	public void mouseClicked(MouseEvent e) {
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
		g2d.setRenderingHint(RenderingHints.KEY_TEXT_ANTIALIASING, RenderingHints.VALUE_TEXT_ANTIALIAS_LCD_HRGB);

		Color fg;
		Color bg;
		Font font;

		if (pressed && hover) {
			fg = FontsAndColors.SEARCHTAG_FG_PRESSED;
			bg = FontsAndColors.SEARCHTAG_BG_PRESSED;
		} else if (!pressed && hover) {
			fg = FontsAndColors.SEARCHTAG_FG_HOVER;
			bg = FontsAndColors.SEARCHTAG_BG_HOVER;
		} else {
			fg = FontsAndColors.SEARCHTAG_FG_NORMAL;
			bg = FontsAndColors.SEARCHTAG_BG_NORMAL;
		}
		font = FontsAndColors.contentFont;

		if (bg != null) {
			g2d.setColor(bg);
			g2d.fill(new Rectangle2D.Double(6, 0, getWidth(), getHeight()));
		}

		if (fg != null) {
			double x = getHeight() / 2;
			double y = getHeight() * 0.75;

			x = getHeight() * 3;

			g2d.setColor(fg);
			g2d.setFont(font);
			g2d.drawString(model.getName() + " ", (int) x, (int) y);

			x += g2d.getFontMetrics().stringWidth(model.getName() + " ");
			g2d.drawString(" \u2015 " + model.getPath(), (int) x, (int) y);
		}

		g2d.setColor(new Color(200, 200, 200));
	}
}
