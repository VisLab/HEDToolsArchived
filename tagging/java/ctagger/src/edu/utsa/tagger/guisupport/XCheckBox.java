package edu.utsa.tagger.guisupport;

import java.awt.Color;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.RenderingHints;
import java.awt.event.MouseEvent;
import java.awt.event.MouseListener;
import java.awt.geom.Line2D;
import java.awt.geom.Rectangle2D;
import java.util.ArrayList;
import java.util.List;

import javax.swing.JComponent;

@SuppressWarnings("serial")
public class XCheckBox extends JComponent implements MouseListener {

	public interface StateListener {
		public void stateChanged();
	}
	private boolean checked;
	private boolean hover;

	private boolean pressed;
	private Color normalBg;
	private Color normalFg;
	private Color hoverBg;
	private Color hoverFg;
	private Color pressedBg;

	private Color pressedFg;

	List<StateListener> listeners = new ArrayList<StateListener>();

	public XCheckBox(Color normalBgArg, Color normalFgArg, Color hoverBgArg,
			Color hoverFgArg, Color pressedBgArg, Color pressedFgArg) {
		checked = false;
		hover = false;
		pressed = false;

		normalBg = normalBgArg;
		normalFg = normalFgArg;
		hoverBg = hoverBgArg;
		hoverFg = hoverFgArg;
		pressedBg = pressedBgArg;
		pressedFg = pressedFgArg;

		addMouseListener(this);
	}

	public void addStateListener(StateListener listener) {
		listeners.add(listener);
	}

	public void fireStateChanged() {
		for (StateListener listener : listeners) {
			listener.stateChanged();
		}
	}

	public boolean isChecked() {
		return checked;
	}

	@Override
	public void mouseClicked(MouseEvent e) {
		checked = !checked;
		repaint();
		fireStateChanged();
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

	// //////////////////
	// StateListener //
	// //////////////////

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

		Color bg;
		Color fg;

		if (pressed && hover) {
			bg = pressedBg;
			fg = pressedFg;
		} else if (!pressed && hover) {
			bg = hoverBg;
			fg = hoverFg;
		} else {
			bg = normalBg;
			fg = normalFg;
		}

		double x, y, w, h;
		h = getHeight() * 0.5;
		w = h;
		y = (getHeight() - h) / 2;
		x = (getWidth() - w) / 2;

		if (bg != null) {
			g2d.setColor(bg);
			g2d.fill(new Rectangle2D.Double(x, y, w, h));
		}

		if (fg != null) {
			g2d.setColor(fg);
			g2d.draw(new Rectangle2D.Double(x, y, w, h));
			if (checked) {
				g2d.draw(new Line2D.Double(x + w * 0.2, y + h * 0.6, x + w
						* 0.4, y + h * 0.8));
				g2d.draw(new Line2D.Double(x + w * 0.4, y + h * 0.8, x + w
						* 0.8, y + h * 0.2));
			}
		}
	}

	public void removeStateListener(StateListener listener) {
		listeners.remove(listener);
	}

	public void setChecked(boolean checkedArg) {
		checked = checkedArg;
	}
}
