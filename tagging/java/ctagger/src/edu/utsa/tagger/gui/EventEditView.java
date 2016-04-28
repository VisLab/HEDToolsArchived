package edu.utsa.tagger.gui;

import java.awt.Color;
import java.awt.Font;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.Polygon;
import java.awt.RenderingHints;
import java.awt.event.FocusEvent;
import java.awt.event.FocusListener;
import java.awt.event.KeyEvent;
import java.awt.event.KeyListener;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;
import java.awt.font.TextAttribute;
import java.awt.geom.Rectangle2D;
import java.util.HashMap;
import java.util.Map;

import javax.swing.JLabel;
import javax.swing.KeyStroke;
import javax.swing.SwingUtilities;
import javax.swing.event.DocumentEvent;
import javax.swing.event.DocumentListener;

import edu.utsa.tagger.AbstractTagModel;
import edu.utsa.tagger.TaggedEvent;
import edu.utsa.tagger.Tagger;
import edu.utsa.tagger.guisupport.Constraint;
import edu.utsa.tagger.guisupport.ConstraintContainer;
import edu.utsa.tagger.guisupport.ConstraintLayout;
import edu.utsa.tagger.guisupport.XButton;
import edu.utsa.tagger.guisupport.XScrollTextBox;
import edu.utsa.tagger.guisupport.XTextBox;

/**
 * This class represents view for editing an event.
 * 
 * @author Lauren Jett, Rebecca Strautman, Thomas Rognon, Jeremy Cockfield, Kay
 *         Robbins
 */
@SuppressWarnings("serial")
public class EventEditView extends ConstraintContainer {

	public static final int HEIGHT = 135;
	private static final String LabelTag = "Event/Label/";
	private final TaggedEvent taggedEvent;
	private final TaggerView appView;
	private final Tagger tagger;

	public EventEditView(Tagger tagger, TaggerView appView, TaggedEvent taggedEvent) {
		this.tagger = tagger;
		this.appView = appView;
		this.taggedEvent = taggedEvent;

		int position = 15;
		add(codeLabel, new Constraint("top:" + position + " height:20 left:15 width:150"));
		position += 23;
		add(code, new Constraint("top:" + position + " height:26 left:15 right:200"));
		position += 31;
		add(eventLabel, new Constraint("top:" + position + " height:20 left:15 width:80"));
		position += 23;
		add(label, new Constraint("top:" + position + " height:26 left:15 right:200"));

		add(cancel, new Constraint("top:10 height:20 right:26 width:45"));
		add(saveButton, new Constraint("top:10 height:20 right:76 width:35"));

		codeLabel.setBackground(FontsAndColors.EDITTAG_BG);
		code.setForeground(FontsAndColors.GREY_DARK);
		code.getJTextArea().getDocument().putProperty("filterNewlines", Boolean.TRUE);
		code.getJTextArea().getInputMap().put(KeyStroke.getKeyStroke("TAB"), "doNothing");
		code.getJTextArea().getInputMap().put(KeyStroke.getKeyStroke("ENTER"), "doNothing");
		code.getJTextArea().getDocument().addDocumentListener(new CodeFieldListener());

		eventLabel.setBackground(FontsAndColors.EDITTAG_BG);
		label.setForeground(FontsAndColors.GREY_DARK);
		label.getJTextArea().getDocument().putProperty("filterNewlines", Boolean.TRUE);
		label.getJTextArea().getInputMap().put(KeyStroke.getKeyStroke("TAB"), "doNothing");
		label.getJTextArea().getInputMap().put(KeyStroke.getKeyStroke("ENTER"), "doNothing");
		cancel.setNormalBackground(FontsAndColors.TRANSPARENT);
		cancel.setNormalForeground(FontsAndColors.SOFT_BLUE);
		cancel.setHoverBackground(FontsAndColors.TRANSPARENT);
		cancel.setHoverForeground(Color.BLACK);
		cancel.setPressedBackground(FontsAndColors.TRANSPARENT);
		cancel.setPressedForeground(FontsAndColors.SOFT_BLUE);

		saveButton.setNormalBackground(FontsAndColors.TRANSPARENT);
		saveButton.setNormalForeground(FontsAndColors.SOFT_BLUE);
		saveButton.setHoverBackground(FontsAndColors.TRANSPARENT);
		saveButton.setHoverForeground(Color.BLACK);
		saveButton.setPressedBackground(FontsAndColors.TRANSPARENT);
		saveButton.setPressedForeground(FontsAndColors.SOFT_BLUE);
		saveButton.setEnabled(false);
		saveButton.setVisible(false);

		code.getJTextArea().addFocusListener(new FocusListener() {
			@Override
			public void focusGained(FocusEvent e) {
				code.getJTextArea().selectAll();
			}

			@Override
			public void focusLost(FocusEvent e) {
			}
		});

		label.getJTextArea().addFocusListener(new FocusListener() {
			@Override
			public void focusGained(FocusEvent e) {
				label.getJTextArea().selectAll();
			}

			@Override
			public void focusLost(FocusEvent e) {
			}
		});

		cancel.addMouseListener(new MouseAdapter() {
			@Override
			public void mouseClicked(MouseEvent e) {
				handleCancel();
			}
		});
		saveButton.addMouseListener(new SaveButtonListener());
		code.getJTextArea().requestFocus();

		code.getJTextArea().addKeyListener(new KeyListener() {

			@Override
			public void keyTyped(KeyEvent e) {
				// TODO Auto-generated method stub

			}

			@Override
			public void keyPressed(KeyEvent e) {

			}

			@Override
			public void keyReleased(KeyEvent e) {
				if (e.getKeyCode() == KeyEvent.VK_TAB) {
					code.getJTextArea().transferFocus();
				}
				if (e.getKeyCode() == KeyEvent.VK_ENTER) {
					handleSave();
				}
				if (e.getKeyCode() == KeyEvent.VK_ESCAPE) {
					handleCancel();
				}
			}

		});

		label.getJTextArea().addKeyListener(new KeyListener() {

			@Override
			public void keyTyped(KeyEvent e) {
				// TODO Auto-generated method stub

			}

			@Override
			public void keyPressed(KeyEvent e) {

			}

			@Override
			public void keyReleased(KeyEvent e) {
				if (e.getKeyCode() == KeyEvent.VK_TAB) {
					code.getJTextArea().requestFocus();
				}
				if (e.getKeyCode() == KeyEvent.VK_ENTER) {
					handleSave();
				}
				if (e.getKeyCode() == KeyEvent.VK_ESCAPE) {
					handleCancel();
				}
			}

		});

	}

	/**
	 * Used to save the data entered in this view to the event.
	 */
	private class SaveButtonListener extends MouseAdapter {
		@Override
		public void mouseClicked(MouseEvent e) {
			handleSave();
		}
	}

	public void handleSave() {
		if (saveButton.isEnabled()) {
			if (!code.getJTextArea().getText().isEmpty()) {
				AbstractTagModel tagModel = taggedEvent.findTagModel(LabelTag + taggedEvent.getLabel());
				tagger.editEventCodeLabel(taggedEvent, tagModel, code.getJTextArea().getText(),
						label.getJTextArea().getText());
			}
			taggedEvent.setInEdit(false);
			taggedEvent.setInFirstEdit(false);
			appView.updateEventsPanel();
			appView.scrollToEvent(taggedEvent);
		}
	}

	private class CodeFieldListener implements DocumentListener {

		@Override
		public void changedUpdate(DocumentEvent e) {
			if (!code.getJTextArea().getText().trim().isEmpty()) {
				saveButton.setEnabled(true);
				saveButton.setVisible(true);
			} else {
				saveButton.setEnabled(false);
				saveButton.setVisible(false);
			}
		}

		@Override
		public void insertUpdate(DocumentEvent e) {
			if (!code.getJTextArea().getText().trim().isEmpty()) {
				saveButton.setEnabled(true);
				saveButton.setVisible(true);
			}
		}

		@Override
		public void removeUpdate(DocumentEvent e) {
			if (code.getJTextArea().getText().trim().isEmpty()) {
				saveButton.setEnabled(false);
				saveButton.setVisible(false);
			}
		}
	}

	private JLabel codeLabel = new JLabel("code (required)") {
		@Override
		public Font getFont() {
			return FontsAndColors.contentFont;
		}
	};

	private JLabel eventLabel = new JLabel("label") {
		@Override
		public Font getFont() {
			return FontsAndColors.contentFont;
		}
	};

	private XScrollTextBox code = new XScrollTextBox(new XTextBox()) {
		@Override
		public Font getFont() {
			return FontsAndColors.contentFont;
		}
	};

	private XScrollTextBox label = new XScrollTextBox(new XTextBox()) {
		@Override
		public Font getFont() {
			return FontsAndColors.contentFont;
		}
	};

	private XButton cancel = new XButton("cancel") {
		@Override
		public Font getFont() {
			Map<TextAttribute, Integer> fontAttributes = new HashMap<TextAttribute, Integer>();
			fontAttributes.put(TextAttribute.UNDERLINE, TextAttribute.UNDERLINE_ON);
			return FontsAndColors.contentFont.deriveFont(fontAttributes);
		}
	};

	private XButton saveButton = new XButton("save") {
		@Override
		public Font getFont() {
			Map<TextAttribute, Integer> fontAttributes = new HashMap<TextAttribute, Integer>();
			fontAttributes.put(TextAttribute.UNDERLINE, TextAttribute.UNDERLINE_ON);
			return FontsAndColors.contentFont.deriveFont(fontAttributes);
		}
	};

	private void handleCancel() {
		taggedEvent.setInEdit(false);
		if (taggedEvent.isInFirstEdit()) {
			tagger.removeEvent(taggedEvent);
		}
		appView.updateEventsPanel();
	}

	@Override
	protected void paintComponent(Graphics g) {

		Graphics2D g2d = (Graphics2D) g;
		g2d.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);

		double scale = ConstraintLayout.scale;

		g2d.setColor(FontsAndColors.EDITTAG_BG);
		g2d.fill(new Polygon(
				new int[] { (int) (scale * 24), (int) (scale * 24 + scale * 10), (int) (scale * 24 + scale * 20) },
				new int[] { (int) (scale * 10), 0, (int) (scale * 10) }, 3));
		g2d.fill(new Rectangle2D.Double(5 * scale, 10 * scale, getWidth() - 26 * scale, getHeight() - 15 * scale));

	}

	public void update() {
		code.getJTextArea().setText(taggedEvent.getEventModel().getCode());
		label.getJTextArea().setText(taggedEvent.getEventModel().getLabel());
		SwingUtilities.invokeLater(new Runnable() {
			@Override
			public void run() {
				code.getJTextArea().requestFocusInWindow();
				code.getJTextArea().selectAll();
			}
		});
	}
}
