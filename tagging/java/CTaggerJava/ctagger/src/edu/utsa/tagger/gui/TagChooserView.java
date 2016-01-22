package edu.utsa.tagger.gui;

import java.awt.Color;
import java.awt.Dimension;
import java.awt.Font;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.Rectangle;
import java.awt.RenderingHints;
import java.awt.event.MouseEvent;
import java.awt.event.MouseListener;
import java.awt.geom.Rectangle2D;

import javax.swing.JComponent;
import javax.swing.SwingUtilities;

import edu.utsa.tagger.Tagger;
import edu.utsa.tagger.guisupport.ClickDragThreshold;
import edu.utsa.tagger.guisupport.ConstraintLayout;

/**
 * Tag view to be used with the file chooser dialog.
 * 
 * @author Lauren Jett, Rebecca Strautman, Thomas Rognon, Jeremy Cockfield, Kay
 *         Robbins
 */
@SuppressWarnings("serial")
public class TagChooserView extends JComponent implements MouseListener {

	private static final String UNCOLLAPSED = "\ue011";
	private static final String COLLAPSED = "\ue00f";

	protected final Tagger tagger;
	private final GuiTagModel model;
	private TagChooserDialog dialog;
	private int depth;
	private boolean collapsed;

	private boolean hover = false;
	private boolean pressed = false;

	private Color fg = null;
	private Color bg = null;
	private Font font = FontsAndColors.contentFont;
	private String toolTip;

	private Rectangle collapserBounds = new Rectangle(0, 0, 0, 0);

	private static final String TAKES_VALUE_MESSAGE = "Click to enter a value. The value will replace the '#' character.";

	public TagChooserView(Tagger tagger, GuiTagModel model) {
		this.tagger = tagger;
		this.model = model;
		setLayout(null);
		setOpaque(true);
		addMouseListener(this);
		new ClickDragThreshold(this);
		if (model.takesValue()) {
			toolTip = TAKES_VALUE_MESSAGE;
		}
		setToolTipText(toolTip);
	}

	public int getDepth() {
		return depth;
	}

	@Override
	public Dimension getPreferredSize() {
		return new Dimension(0, (int) (24 * ConstraintLayout.scale));
	}

	public boolean isCollapsed() {
		return collapsed;
	}

	/**
	 * When the mouse is clicked, if the collapse arrow was clicked, it
	 * collapses or uncollapses the view at this tag. Otherwise, it allows a
	 * value to be added for a tag that takes values, or it returns this tag as
	 * the chosen tag.
	 */
	@Override
	public void mouseClicked(MouseEvent e) {
		if (SwingUtilities.isLeftMouseButton(e)) {
			if (model.isCollapsable() && collapserBounds.contains(e.getPoint())) {
				collapsed = !collapsed;
				dialog.updateTags();
			} else if (model.takesValue()) {
				model.setInAddValue(true);
				dialog.updateTags();
			} else if (!model.isChildRequired()) {
				dialog.setTagChosen(model);
				dialog.setVisible(false);
				dialog.dispose();
			}
		}
	}

	@Override
	public void mouseEntered(MouseEvent e) {
		hover = !collapserBounds.contains(e.getPoint());
		repaint();
		dialog.repaintTagScrollPane();
	}

	@Override
	public void mouseExited(MouseEvent e) {
		hover = false;
		repaint();
		dialog.repaintTagScrollPane();
	}

	@Override
	public void mousePressed(MouseEvent e) {
		if (!SwingUtilities.isLeftMouseButton(e)) {
			return;
		}
		pressed = !collapserBounds.contains(e.getPoint());
		repaint();
		dialog.repaintTagScrollPane();
	}

	@Override
	public void mouseReleased(MouseEvent e) {
		pressed = false;
		repaint();
		dialog.repaintTagScrollPane();
	}

	@Override
	protected void paintComponent(Graphics g) {

		if (model.selectionState == GuiTagModel.SELECTION_STATE_ALL) {
			bg = FontsAndColors.TAG_BG_SELECTED;
			fg = FontsAndColors.TAG_FG_SELECTED;
		} else if (model.selectionState == GuiTagModel.SELECTION_STATE_MIXED) {
			bg = FontsAndColors.TAG_BG_SEMISELECTED;
			fg = FontsAndColors.TAG_FG_SEMISELECTED;
		} else {
			// if (model.takesValue()) {
			// fg = FontsAndColors.TAG_FG_TAKES_VALUE;
			// } else {
			fg = FontsAndColors.TAG_FG_NORMAL;
			// }
			bg = FontsAndColors.TAG_BG_NORMAL;
		}

		Graphics2D g2d = (Graphics2D) g;
		g2d.setRenderingHint(RenderingHints.KEY_TEXT_ANTIALIASING,
				RenderingHints.VALUE_TEXT_ANTIALIAS_LCD_HRGB);

		g2d.setColor(bg);
		g2d.fill(new Rectangle2D.Double(0, 0, getWidth(), getHeight()));

		double x = 0;
		double y = getHeight() * 0.75;

		x = getHeight() * (depth + 1);

		if (model.isCollapsable()) {
			g2d.setColor(fg);
			g2d.setFont(FontsAndColors.symbolFont);
			double xBound;
			if (collapsed) {
				g2d.drawString(COLLAPSED, (int) x, (int) y);
				xBound = x
						+ (g2d.getFontMetrics().stringWidth(COLLAPSED) - getHeight())
						/ 2;
			} else {
				g2d.drawString(UNCOLLAPSED, (int) x, (int) y);
				xBound = x
						+ (g2d.getFontMetrics().stringWidth(UNCOLLAPSED) - getHeight())
						/ 2;
			}
			collapserBounds
					.setBounds((int) xBound, 0, getHeight(), getHeight());
		} else {
			collapserBounds.setBounds(0, 0, 0, 0);
		}
		x += getHeight();

		if (pressed) {
			g2d.setColor(FontsAndColors.TAG_FG_PRESSED);
		} else if (hover) {
			g2d.setColor(FontsAndColors.TAG_FG_HOVER);
		} else {
			g2d.setColor(fg);
		}
		g2d.setFont(font);
		g2d.drawString(model.getName() + " ", (int) x, (int) y);

		String info = null;
		if (model.isChildRequired()) {
			info = "(child required)";
		}

		if (info != null) {
			x += g2d.getFontMetrics().stringWidth(model.getName() + " ");
			x += getHeight();
			g2d.drawString(info, (int) x, (int) y);
		}
	}

	public void setCollapsed(boolean collapsed) {
		this.collapsed = collapsed;
	}

	public void setDepth(int depth) {
		this.depth = depth;
	}

	public void setFont(Font font) {
		this.font = font;
	}

	public void setTagChooserDialog(TagChooserDialog dialog) {
		this.dialog = dialog;
	}

	public void update() {
		if (model.takesValue()) {
			toolTip = TAKES_VALUE_MESSAGE;
		}
		setToolTipText(toolTip);
	}
}
