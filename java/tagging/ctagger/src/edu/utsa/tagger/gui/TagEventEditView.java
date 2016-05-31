package edu.utsa.tagger.gui;

import java.awt.Color;
import java.awt.Font;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.Polygon;
import java.awt.RenderingHints;
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
 * 
 * @author Lauren Jett, Rebecca Strautman, Thomas Rognon, Jeremy Cockfield, Kay
 *         Robbins
 *
 */
@SuppressWarnings("serial")
public class TagEventEditView extends ConstraintContainer {

	public static final int HEIGHT = 85;
	private TaggerView appView;
	private final GuiTagModel tagModel;
	private final Tagger tagger;
	private final TaggedEvent taggedEvent;

	public TagEventEditView(Tagger tagger, TaggedEvent taggedEvent,
			GuiTagModel model) {
		tagModel = model;
		this.tagger = tagger;
		this.taggedEvent = taggedEvent;

		int position = 15;
		add(nameLabel, new Constraint("top:" + position
				+ " height:20 left:15 width:150"));
		position += 23;
		add(name, new Constraint("top:" + position
				+ " height:26 left:15 right:200"));

		add(cancel, new Constraint("top:10 height:20 right:20 width:45"));
		add(save, new Constraint("top:10 height:20 right:70 width:35"));

		nameLabel.setBackground(FontsAndColors.EDITTAG_BG);
		name.setForeground(FontsAndColors.GREY_DARK);
		name.getJTextArea().getDocument()
				.putProperty("filterNewlines", Boolean.TRUE);
		name.getJTextArea().getInputMap()
				.put(KeyStroke.getKeyStroke("TAB"), "doNothing");
		name.getJTextArea().getDocument()
				.addDocumentListener(new NameFieldListener());
		name.getJTextArea().getInputMap()
				.put(KeyStroke.getKeyStroke("ENTER"), "doNothing");

		cancel.setNormalBackground(FontsAndColors.TRANSPARENT);
		cancel.setNormalForeground(FontsAndColors.SOFT_BLUE);
		cancel.setHoverBackground(FontsAndColors.TRANSPARENT);
		cancel.setHoverForeground(Color.BLACK);
		cancel.setPressedBackground(FontsAndColors.TRANSPARENT);
		cancel.setPressedForeground(FontsAndColors.SOFT_BLUE);

		save.setNormalBackground(FontsAndColors.TRANSPARENT);
		save.setNormalForeground(FontsAndColors.SOFT_BLUE);
		save.setHoverBackground(FontsAndColors.TRANSPARENT);
		save.setHoverForeground(Color.BLACK);
		save.setPressedBackground(FontsAndColors.TRANSPARENT);
		save.setPressedForeground(FontsAndColors.SOFT_BLUE);

		cancel.addMouseListener(new MouseAdapter() {
			@Override
			public void mouseClicked(MouseEvent e) {
				handleCancel();
			}
		});
		save.addMouseListener(new SaveButtonListener());

		name.getJTextArea().addKeyListener(new KeyListener() {

			@Override
			public void keyTyped(KeyEvent e) {
				// TODO Auto-generated method stub

			}

			@Override
			public void keyPressed(KeyEvent e) {

			}

			@Override
			public void keyReleased(KeyEvent e) {
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
		if (save.isEnabled()) {
			if (!name.getJTextArea().getText().isEmpty()) {
				if (!tagger.tagPathFound(name.getJTextArea().getText())) {
					appView.showTaggerMessageDialog(
							MessageConstants.TAG_PATH_NOT_EXIST_ERROR, "Okay",
							null, null);
					return;
				}
				AbstractTagModel foundTag = tagger.tagFound(name.getJTextArea()
						.getText());
				if (foundTag != null && foundTag.isChildRequired()) {
					appView.showTaggerMessageDialog(
							MessageConstants.TAG_PATH_SPECIFY_CHILD_ERROR,
							"Okay", null, null);
					return;
				}
				tagger.editTagPath(taggedEvent, tagModel, name.getJTextArea()
						.getText());
			}
			tagModel.setInEdit(false);
			appView.updateEventsPanel();
		}
	}

	private class NameFieldListener implements DocumentListener {

		@Override
		public void changedUpdate(DocumentEvent e) {
			if (!name.getJTextArea().getText().trim().isEmpty()) {
				save.setEnabled(true);
				save.setVisible(true);
			} else {
				save.setEnabled(false);
				save.setVisible(false);
			}
		}

		@Override
		public void insertUpdate(DocumentEvent e) {
			if (!name.getJTextArea().getText().trim().isEmpty()) {
				save.setEnabled(true);
				save.setVisible(true);
			}
		}

		@Override
		public void removeUpdate(DocumentEvent e) {
			if (name.getJTextArea().getText().trim().isEmpty()) {
				save.setEnabled(false);
				save.setVisible(false);
			}
		}
	}

	final JLabel nameLabel = new JLabel("name (required)", JLabel.LEFT) {
		@Override
		public Font getFont() {
			return FontsAndColors.contentFont;
		}
	};
	final XScrollTextBox name = new XScrollTextBox(new XTextBox()) {
		@Override
		public Font getFont() {
			return FontsAndColors.contentFont;
		}
	};

	public String getNameText() {
		return name.getJTextArea().getText();
	}

	private XButton cancel = new XButton("cancel") {
		@Override
		public Font getFont() {
			Map<TextAttribute, Integer> fontAttributes = new HashMap<TextAttribute, Integer>();
			fontAttributes.put(TextAttribute.UNDERLINE,
					TextAttribute.UNDERLINE_ON);
			return FontsAndColors.contentFont.deriveFont(fontAttributes);
		}
	};

	private XButton save = new XButton("save") {
		@Override
		public Font getFont() {
			Map<TextAttribute, Integer> fontAttributes = new HashMap<TextAttribute, Integer>();
			fontAttributes.put(TextAttribute.UNDERLINE,
					TextAttribute.UNDERLINE_ON);
			return FontsAndColors.contentFont.deriveFont(fontAttributes);
		}
	};

	private void handleCancel() {
		tagModel.setInEdit(false);
		appView.updateEventsPanel();
	}

	@Override
	protected void paintComponent(Graphics g) {

		Graphics2D g2d = (Graphics2D) g;
		g2d.setRenderingHint(RenderingHints.KEY_ANTIALIASING,
				RenderingHints.VALUE_ANTIALIAS_ON);

		double scale = ConstraintLayout.scale;

		g2d.setColor(FontsAndColors.EDITTAG_BG);
		g2d.fill(new Polygon(new int[] { (int) (scale * 24),
				(int) (scale * 24 + scale * 10),
				(int) (scale * 24 + scale * 20) }, new int[] {
				(int) (scale * 10), 0, (int) (scale * 10) }, 3));
		g2d.fill(new Rectangle2D.Double(5 * scale, 10 * scale, getWidth() - 10
				* scale, getHeight() - 15 * scale));

	}

	public void setAppView(TaggerView appView) {
		this.appView = appView;
	}

	/**
	 * Updates the information shown in the view to match the underlying tag
	 * model.
	 */
	public void update() {
		name.getJTextArea().setText(tagModel.getPath());
		SwingUtilities.invokeLater(new Runnable() {
			@Override
			public void run() {
				name.getJTextArea().requestFocusInWindow();
				name.getJTextArea().selectAll();
			}
		});
	}

}
