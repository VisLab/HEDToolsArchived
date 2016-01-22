package edu.utsa.tagger.gui;

import java.awt.Color;
import java.awt.Font;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.RenderingHints;
import java.awt.font.TextAttribute;
import java.util.Map;

import javax.swing.JLabel;
import javax.swing.JTextArea;

import edu.utsa.tagger.guisupport.Constraint;
import edu.utsa.tagger.guisupport.ConstraintContainer;
import edu.utsa.tagger.guisupport.ConstraintLayout;

/**
 * This class represents the view for a notification shown at the top of the
 * GUI.
 * 
 * @author Lauren Jett, Rebecca Strautman, Thomas Rognon, Jeremy Cockfield, Kay
 *         Robbins
 */
@SuppressWarnings("serial")
public class Notification extends ConstraintContainer {

	JLabel preview = new JLabel() {
		@Override
		public Font getFont() {
			return FontsAndColors.contentFont;
		}
	};

	JTextArea details = new JTextArea() {
		@Override
		public Font getFont() {
			return FontsAndColors.contentFont;
		}
	};

	JLabel toggleDetails = new JLabel("show details") {
		@SuppressWarnings({ "unchecked", "rawtypes" })
		@Override
		public Font getFont() {
			Font font = FontsAndColors.contentFont;
			Map attributes = font.getAttributes();
			attributes.put(TextAttribute.UNDERLINE, TextAttribute.UNDERLINE_ON);
			return font.deriveFont(attributes);
		}
	};

	JLabel close = new JLabel("close") {
		@SuppressWarnings({ "unchecked", "rawtypes" })
		@Override
		public Font getFont() {
			Font font = FontsAndColors.contentFont;
			Map attributes = font.getAttributes();
			attributes.put(TextAttribute.UNDERLINE, TextAttribute.UNDERLINE_ON);
			return font.deriveFont(attributes);
		}
	};

	public Notification() {
		preview.setHorizontalAlignment(JLabel.CENTER);
		details.setEnabled(false);
		details.setDisabledTextColor(Color.BLACK);
		details.setOpaque(false);
		toggleDetails.setForeground(FontsAndColors.BLUE_MEDIUM);
		toggleDetails.setHorizontalAlignment(JLabel.CENTER);
		close.setForeground(FontsAndColors.BLUE_MEDIUM);
		close.setHorizontalAlignment(JLabel.CENTER);
		add(preview, new Constraint("top:0 height:30 left:0 right:130"));
		add(details, new Constraint("top:40 bottom:0 left:10 right:10"));
		add(toggleDetails, new Constraint("top:0 height:30 right:40 width:90"));
		add(close, new Constraint("top:0 height:30 right:0 width:40"));
	}

	public JTextArea getDetails() {
		return details;
	}

	public JLabel getHideButton() {
		return close;
	}

	public JLabel getToggleDetailsButton() {
		return toggleDetails;
	}

	@Override
	public void paintComponent(Graphics g) {
		Graphics2D g2d = (Graphics2D) g;
		g2d.setRenderingHint(RenderingHints.KEY_TEXT_ANTIALIASING,
				RenderingHints.VALUE_TEXT_ANTIALIAS_LCD_HRGB);

		g2d.setColor(FontsAndColors.LIGHT_YELLOW);
		g2d.fillRoundRect(0, 0, getWidth() - 1, getHeight() - 1,
				(int) (10 * ConstraintLayout.scale),
				(int) (10 * ConstraintLayout.scale));

		g2d.setColor(FontsAndColors.WEIRD_YELLOW);
		g2d.drawRoundRect(0, 0, getWidth() - 1, getHeight() - 1,
				(int) (10 * ConstraintLayout.scale),
				(int) (10 * ConstraintLayout.scale));
	}

	public void setDetailsText(String text) {
		details.setText(text);
	}

	public void setPreviewText(String text) {
		preview.setText(text);
	}
}
