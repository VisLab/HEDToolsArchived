package edu.utsa.tagger.guisupport;

import java.awt.Color;
import java.awt.KeyboardFocusManager;
import java.awt.event.FocusEvent;
import java.awt.event.FocusListener;

import javax.swing.BorderFactory;
import javax.swing.JTextArea;
import javax.swing.border.Border;

@SuppressWarnings("serial")
public class XTextBox extends JTextArea implements FocusListener {

	private Border FOCUSED_BORDER = BorderFactory.createCompoundBorder(
			BorderFactory.createLineBorder(Color.BLACK, 1),
			BorderFactory.createEmptyBorder(3, 3, 3, 3));
	private Border UNFOCUSED_BORDER = BorderFactory.createCompoundBorder(
			BorderFactory.createLineBorder(Color.BLACK, 1),
			BorderFactory.createEmptyBorder(3, 3, 3, 3));
	private Border NO_BORDER = BorderFactory.createEmptyBorder(4, 4, 4, 4);

	public XTextBox() {
		super();
		setBorder(UNFOCUSED_BORDER);
		addFocusListener(this);
	}

	public XTextBox(int rows, int columns) {
		super(rows, columns);
		setBorder(UNFOCUSED_BORDER);
		addFocusListener(this);
	}

	@Override
	public void focusGained(FocusEvent e) {
		setBorder(FOCUSED_BORDER);
	}

	@Override
	public void focusLost(FocusEvent e) {
		setBorder(UNFOCUSED_BORDER);
	}

	public void setBorderColors(Color focused, Color unfocused) {
		FOCUSED_BORDER = BorderFactory.createCompoundBorder(
				BorderFactory.createLineBorder(focused, 1),
				BorderFactory.createEmptyBorder(3, 3, 3, 3));
		UNFOCUSED_BORDER = BorderFactory.createCompoundBorder(
				BorderFactory.createLineBorder(unfocused, 1),
				BorderFactory.createEmptyBorder(3, 3, 3, 3));
		if (this.hasFocus()) {
			setBorder(FOCUSED_BORDER);
		} else {
			setBorder(UNFOCUSED_BORDER);
		}
	}

	public void setLock(boolean lock) {
		setEditable(!lock);
		setFocusable(!lock);
		setOpaque(!lock);
		if (lock) {
			if (hasFocus()) {
				KeyboardFocusManager.getCurrentKeyboardFocusManager()
						.clearGlobalFocusOwner();
			}
			setBorder(NO_BORDER);
		} else {
			setBorder(UNFOCUSED_BORDER);
		}
	}
}
