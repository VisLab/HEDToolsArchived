package edu.utsa.tagger.gui;

import java.awt.Color;
import java.awt.Font;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.RenderingHints;
import java.awt.event.FocusEvent;
import java.awt.event.FocusListener;
import java.awt.event.KeyEvent;
import java.awt.event.KeyListener;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;
import java.awt.event.MouseListener;
import java.awt.font.TextAttribute;
import java.awt.geom.Rectangle2D;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;

import javax.swing.BorderFactory;
import javax.swing.JComponent;
import javax.swing.JLabel;
import javax.swing.JTextArea;
import javax.swing.KeyStroke;
import javax.swing.SwingUtilities;
import javax.swing.border.Border;
import javax.swing.event.DocumentEvent;
import javax.swing.event.DocumentListener;

import edu.utsa.tagger.AbstractTagModel;
import edu.utsa.tagger.TaggedEvent;
import edu.utsa.tagger.Tagger;
import edu.utsa.tagger.TaggerSet;
import edu.utsa.tagger.guisupport.Constraint;
import edu.utsa.tagger.guisupport.ConstraintLayout;
import edu.utsa.tagger.guisupport.XButton;
import edu.utsa.tagger.guisupport.XScrollTextBox;

/**
 * Class used to show the required and recommended tags of an event in the EGT
 * panel. The view contains a label showing the key that scrolls to the key's
 * place in the tag view when clicked. It also contains an RREditView used to
 * add new child tags or edit the child tag if it is unique. It includes a text
 * box to fill in values if the tag's only descendant is a tag that takes a user
 * value (e.g. /Event/Label/#). The child tag(s) of the required/recommended tag
 * are displayed within the view.
 * 
 * @author Lauren Jett, Rebecca Strautman, Thomas Rognon, Jeremy Cockfield, Kay
 *         Robbins
 */
@SuppressWarnings("serial")
public class RRTagView extends JComponent {

	private static final int BASE_SIZE = 54;
	private static final int TAG_SIZE = 27;
	private final TaggedEvent taggedEvent;
	private final Tagger tagger;
	private final AppView appView;
	private JLabel label;
	private XScrollTextBox valueField;
	private RREditView editView;
	private AbstractTagModel takesValueTag;
	private int numEditTags;
	private AbstractTagModel key;
	private TaggerSet<AbstractTagModel> values;
	private HashMap<AbstractTagModel, TagEventView> tagEgtViews;
	private boolean inAddValue = false;

	/**
	 * Constructor finds descendant tags and creates the view.
	 * 
	 * @param tagger
	 * @param appView
	 * @param taggedEvent
	 *            The event the view belongs to
	 * @param key
	 *            The required/recommended tag
	 */
	public RRTagView(Tagger tagger, AppView appView, TaggedEvent taggedEvent, AbstractTagModel key) {
		label = new JLabel(key.getPath()) {
			@Override
			public Font getFont() {
				return FontsAndColors.contentFont.deriveFont(Font.BOLD);
			}
		};
		label.addMouseListener(new LabelListener());
		this.tagger = tagger;
		this.appView = appView;
		this.taggedEvent = taggedEvent;
		this.key = key;
		this.values = taggedEvent.getRRValue(key);
		// RR tag with only takes value descendant
		this.takesValueTag = tagger.getChildValueTag(key);
		this.tagEgtViews = new HashMap<AbstractTagModel, TagEventView>();
		if (takesValueTag != null) {
			label.setText(key.getPath() + "/" + takesValueTag.getName());
		}
		valueField = new XScrollTextBox(new JTextArea());
		valueField.setBorder(normalBorder);
		valueField.getJTextArea().getDocument().putProperty("filterNewlines", Boolean.TRUE);
		valueField.getJTextArea().getInputMap().put(KeyStroke.getKeyStroke("ENTER"), "doNothing");
		valueField.getJTextArea().getInputMap().put(KeyStroke.getKeyStroke("TAB"), "doNothing");
		valueField.getJTextArea().getDocument().addDocumentListener(new valueFieldListener());
		editView = new RREditView();
		// No value(s) for this RR tag - highlight label
		if (key.isChildRequired() && values == null) {
			if (key.isRequired()) {
				label.setForeground(FontsAndColors.EVENT_TAG_REQUIRED);
			} else {
				label.setForeground(FontsAndColors.EVENT_TAG_RECOMMENDED);
			}
		}

		valueField.getJTextArea().addFocusListener(new FocusListener() {
			@Override
			public void focusGained(FocusEvent e) {
				valueField.getJTextArea().selectAll();
			}

			@Override
			public void focusLost(FocusEvent e) {
			}
		});

		save.addMouseListener(new SaveButtonListener());

		cancel.addMouseListener(new CancelButtonListener());

		save.setNormalBackground(FontsAndColors.TRANSPARENT);
		save.setNormalForeground(FontsAndColors.SOFT_BLUE);
		save.setHoverBackground(FontsAndColors.TRANSPARENT);
		save.setHoverForeground(Color.BLACK);
		save.setPressedBackground(FontsAndColors.TRANSPARENT);
		save.setPressedForeground(FontsAndColors.SOFT_BLUE);
		cancel.setNormalBackground(FontsAndColors.TRANSPARENT);
		cancel.setNormalForeground(FontsAndColors.SOFT_BLUE);
		cancel.setHoverBackground(FontsAndColors.TRANSPARENT);
		cancel.setHoverForeground(Color.BLACK);
		cancel.setPressedBackground(FontsAndColors.TRANSPARENT);
		cancel.setPressedForeground(FontsAndColors.SOFT_BLUE);

		valueField.getJTextArea().addKeyListener(new KeyListener() {

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
			}

		});

		setLayout(new ConstraintLayout());
		refreshView();

	}

	/**
	 * Used to scroll to the required/recommended tag's place in the tag panel
	 * when the label is clicked.
	 */
	private class LabelListener extends MouseAdapter {
		@Override
		public void mouseClicked(MouseEvent e) {
			if (SwingUtilities.isLeftMouseButton(e)) {
				// GuiTagModel tagMatch = (GuiTagModel)
				// tagger.openToClosest(key);
				appView.updateTags();
				appView.scrollToTag(key);
			}
		}
	}

	/**
	 * View for editing or adding required/recommended tags. For unique tags, it
	 * is used to edit (replace) the value, if it exists. If there is no value,
	 * or the required/recommended tag is not unique, it is used to add a value.
	 */
	private class RREditView extends JComponent implements MouseListener {

		boolean hover = false;
		boolean pressed = false;

		public RREditView() {
			addMouseListener(this);
		}

		/**
		 * When the mouse is clicked, it edits the value of the given tag.
		 */
		@Override
		public void mouseClicked(MouseEvent e) {
			editTag();
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
			if (!SwingUtilities.isLeftMouseButton(e)) {
				return;
			}
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
			Font font = FontsAndColors.contentFont;
			Color fg = FontsAndColors.TAG_FG_NORMAL;
			Color bg = FontsAndColors.TAG_BG_NORMAL;

			Graphics2D g2d = (Graphics2D) g;
			g2d.setRenderingHint(RenderingHints.KEY_TEXT_ANTIALIASING, RenderingHints.VALUE_TEXT_ANTIALIAS_LCD_HRGB);

			g2d.setColor(bg);
			g2d.fill(new Rectangle2D.Double(0, 0, getWidth(), getHeight()));

			double x = 5;
			double y = getHeight() * 0.75;

			if (pressed) {
				g2d.setColor(FontsAndColors.TAG_FG_PRESSED);
			} else if (hover) {
				g2d.setColor(FontsAndColors.TAG_FG_HOVER);
			} else {
				g2d.setColor(fg);
			}
			String message = "";
			String info = null;
			if (values == null || !key.isUnique()) {
				font = FontsAndColors.contentFont.deriveFont(Font.ITALIC);
				message = "Click to add tag";
			} else {
				info = "(click to edit)";
				if (takesValueTag != null) {
					message = values.get(0).getName();
				} else {
					message = values.get(0).getPath();
				}
			}
			g2d.setFont(font);
			g2d.drawString(message, (int) x, (int) y);
			if (info != null) {
				x += g2d.getFontMetrics().stringWidth(message + " ");
				x += getHeight();
				g2d.drawString(info, (int) x, (int) y);
			}
		}
	}

	private class valueFieldListener implements DocumentListener {

		@Override
		public void changedUpdate(DocumentEvent e) {
			if (!valueField.getJTextArea().getText().trim().isEmpty()) {
				save.setEnabled(true);
				save.setVisible(true);
			} else {
				save.setEnabled(false);
				save.setVisible(false);
			}
		}

		@Override
		public void insertUpdate(DocumentEvent e) {
			if (!valueField.getJTextArea().getText().trim().isEmpty()) {
				save.setEnabled(true);
				save.setVisible(true);
			}
		}

		@Override
		public void removeUpdate(DocumentEvent e) {
			if (valueField.getJTextArea().getText().trim().isEmpty()) {
				save.setEnabled(false);
				save.setVisible(false);
			}
		}
	}

	/**
	 * Used to save a value entered for a tag that takes a value.
	 */
	private class SaveButtonListener extends MouseAdapter {
		@Override
		public void mouseClicked(MouseEvent e) {
			handleSave();
		}
	}

	public void handleSave() {
		if (save.isEnabled()) {
			AbstractTagModel newTag = getNewValue();
			if (takesValueTag != null) {
				updateTakesValueTag(newTag);
			} else if (newTag != null) {
				updateValue(newTag);
			} else {
				inAddValue = false;
				refreshView();
			}
			appView.updateEventsPanel();
		}
	}

	/**
	 * Used to save a value entered for a tag that takes a value.
	 */
	private class CancelButtonListener extends MouseAdapter {
		@Override
		public void mouseClicked(MouseEvent e) {
			handleCancel();
		}
	}

	public void handleCancel() {
		inAddValue = false;
		appView.updateEventsPanel();
	}

	private XButton save = new XButton("save") {
		@Override
		public Font getFont() {
			Map<TextAttribute, Integer> fontAttributes = new HashMap<TextAttribute, Integer>();
			fontAttributes.put(TextAttribute.UNDERLINE, TextAttribute.UNDERLINE_ON);
			return FontsAndColors.contentFont.deriveFont(fontAttributes);
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

	private Border normalBorder = BorderFactory.createLineBorder(Color.black);

	/**
	 * Edits the value of the tag. If the tag has one child that takes a value,
	 * it opens a text box to get the value. Otherwise, it launches a tag
	 * chooser dialog.
	 */
	private void editTag() {
		if (takesValueTag != null) {
			inAddValue = true;
			RRTagView.this.refreshView();
		} else {
			AbstractTagModel tagChosen = appView.showTagChooserDialog(getKey());
			if (tagChosen != null) {
				updateValue(tagChosen);
			}
		}
	}

	/**
	 * Returns the height needed to add this view to a Constraint layout.
	 * 
	 * @return Desired height as an int
	 */
	public int getConstraintHeight() {
		int numTags = 0;
		if (!key.isUnique() && values != null) {
			numTags = values.size();
		}
		return BASE_SIZE + TAG_SIZE * numTags + TagEventEditView.HEIGHT * numEditTags;
	}

	public AbstractTagModel getKey() {
		return key;
	}

	/**
	 * Finds the required/recommended tag chosen.
	 * 
	 * @return The tag model for the tag chosen, if one exists. Returns null if
	 *         a tag has not been chosen (or a value has not been entered, for a
	 *         tag with a child that takes a value). For a tag with a child that
	 *         takes a value, if the text field is currently empty, but
	 *         previously contained a value, it will return the tag model for
	 *         the previous tag represented (i.e. a user cannot use the edit
	 *         field to remove an existing required/recommended tag).
	 */
	private AbstractTagModel getNewValue() {
		if (valueField != null && !valueField.getJTextArea().getText().isEmpty()) {
			String valueText = valueField.getJTextArea().getText().trim();
			return tagger.createTransientTagModel(takesValueTag, valueText);
		}
		return null;
	}

	/**
	 * Refreshes the view to show a text box for editing a tag with a single
	 * takes value descendant.
	 */
	private void refreshView() {
		removeAll();
		int top = 5;
		add(label, new Constraint("top:" + top + " height:20 left:5 right:105"));
		top += 23;
		if (inAddValue) {
			String tagText = "";
			TaggerSet<AbstractTagModel> valueTags = taggedEvent.getRRValue(key);
			if (valueTags != null && key.isUnique()) {
				tagText = valueTags.get(0).getName();
				String valueString = takesValueTag.getName();
				String before = valueString.substring(0, valueString.indexOf('#'));
				String after = valueString.substring(valueString.indexOf('#') + 1);
				tagText = tagText.replaceFirst(before, "");
				tagText = tagText.replaceFirst(after + "$", "");
			}
			if (key.isUnique()) {
				valueField.getJTextArea().setText(tagText);
			}
			add(valueField, new Constraint("top:" + top + " height:26 left:15 right:20"));
			add(cancel, new Constraint("top:5 height:20 right:20 width:45"));
			add(save, new Constraint("top:5 height:20 right:70 width:35"));
			SwingUtilities.invokeLater(new Runnable() {
				@Override
				public void run() {
					valueField.getJTextArea().requestFocusInWindow();
					valueField.getJTextArea().selectAll();
				}
			});
		} else {
			add(editView, new Constraint("top:" + top + " height:26 left:15 right:20"));
		}
		top += 29;
		// Adds existing descendant tags to view
		if (!key.isUnique() && values != null) {
			numEditTags = 0;
			for (AbstractTagModel valueTag : values) {
				GuiTagModel gtm = (GuiTagModel) valueTag;
				gtm.setAppView(appView);
				gtm.updateMissing();
				TagEventView tagEgtView = gtm.getTagEgtView(taggedEvent.getEventGroupId());
				addTagEgtView(valueTag, tagEgtView);
				add(tagEgtView, new Constraint("top:" + top + " height:26 left:30 right:0"));
				top += TAG_SIZE;
				if (gtm.isInEdit()) {
					TagEventEditView teev = gtm.getTagEgtEditView(taggedEvent);
					teev.setAppView(appView);
					teev.update();
					add(teev, new Constraint("top:" + top + " height:" + TagEventEditView.HEIGHT + " left:30 right:0"));
					top += TagEventEditView.HEIGHT;
					numEditTags++;
				}
			}
		}
		revalidate();
		repaint();
	}

	public void setKey(AbstractTagModel key) {
		this.key = key;
	}

	/**
	 * Updates the value for a required/recommended tag. Replaces the child tag
	 * if it is unique, and attempts to add the child tag otherwise.
	 * 
	 * @param newTag
	 */
	private void updateValue(AbstractTagModel newTag) {
		HashSet<Integer> idSet = new HashSet<Integer>();
		idSet.add(taggedEvent.getEventGroupId());
		// Unassociate old value if unique
		if (values != null && key.isUnique()) {
			tagger.unassociate(taggedEvent.getEventModel(), values.get(0), idSet);
		}
		// Associate new value
		GuiTagModel gtm = (GuiTagModel) newTag;
		gtm.setAppView(appView);
		gtm.requestToggleTag(idSet);
	}

	private void updateTakesValueTag(AbstractTagModel newTag) {
		// Unassociate old value if unique
		if (values != null && key.isUnique()) {
			String path = values.get(0).getParentPath() + "/" + valueField.getJTextArea().getText().trim();
			tagger.editTagPath(taggedEvent, (GuiTagModel) values.get(0), path);
		} else {
			updateValue(newTag);
		}
	}

	public void addTagEgtView(AbstractTagModel tagModel, TagEventView tagEgtView) {
		tagEgtViews.put(tagModel, tagEgtView);
	}

	public TagEventView getTagEgtViewByKey(AbstractTagModel tagModel) {
		return tagEgtViews.get(tagModel);
	}
}
