package edu.utsa.tagger.gui;

import java.awt.Color;
import java.awt.Font;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.Polygon;
import java.awt.RenderingHints;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.KeyEvent;
import java.awt.event.KeyListener;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;
import java.awt.font.TextAttribute;
import java.awt.geom.Rectangle2D;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;

import javax.swing.DefaultComboBoxModel;
import javax.swing.JComboBox;
import javax.swing.JComponent;
import javax.swing.JLabel;
import javax.swing.KeyStroke;
import javax.swing.SwingUtilities;
import javax.swing.Timer;
import javax.swing.event.DocumentEvent;
import javax.swing.event.DocumentListener;

import edu.utsa.tagger.AbstractTagModel;
import edu.utsa.tagger.Tagger;
import edu.utsa.tagger.guisupport.Constraint;
import edu.utsa.tagger.guisupport.ConstraintContainer;
import edu.utsa.tagger.guisupport.ConstraintLayout;
import edu.utsa.tagger.guisupport.ITagDisplay;
import edu.utsa.tagger.guisupport.XButton;
import edu.utsa.tagger.guisupport.XScrollTextBox;
import edu.utsa.tagger.guisupport.XTextBox;

/**
 * View allowing the user to add a value to a tag that takes values.
 * 
 * @author Lauren Jett, Rebecca Strautman, Thomas Rognon, Jeremy Cockfield, Kay
 *         Robbins
 */
@SuppressWarnings("serial")
public class AddValueView extends ConstraintContainer {

	public final static int HEIGHT = 80;
	private int top = 15;
	private final Tagger tagger;
	private final AppView appView;
	private final GuiTagModel tagModel;
	private boolean highlight = false;
	private final ITagDisplay alternateView;

	public AddValueView(Tagger tagger, AppView appView,
			ITagDisplay alternateView, GuiTagModel guiTagModel) {
		this.tagger = tagger;
		this.appView = appView;
		this.tagModel = guiTagModel;
		this.alternateView = alternateView;
		addGuiComponents();
	}

	private class ValueFieldListener implements DocumentListener {

		@Override
		public void changedUpdate(DocumentEvent e) {
			if (valueField.getJTextArea().getText().equals(new String())) {
				okButton.setEnabled(false);
				okButton.setVisible(false);
			} else {
				okButton.setEnabled(true);
				okButton.setVisible(true);
			}
		}

		@Override
		public void insertUpdate(DocumentEvent e) {
			okButton.setEnabled(true);
			okButton.setVisible(true);
		}

		@Override
		public void removeUpdate(DocumentEvent e) {
			if (valueField.getJTextArea().getText().equals("")) {
				okButton.setEnabled(false);
				okButton.setVisible(false);
			}
		}

	}

	private final XButton okButton = new XButton("OK") {
		@Override
		public Font getFont() {
			Map<TextAttribute, Integer> fontAttributes = new HashMap<TextAttribute, Integer>();
			fontAttributes.put(TextAttribute.UNDERLINE,
					TextAttribute.UNDERLINE_ON);
			return FontsAndColors.contentFont.deriveFont(fontAttributes);
		}
	};

	final XScrollTextBox valueField = new XScrollTextBox(new XTextBox()) {
		@Override
		public Font getFont() {
			return FontsAndColors.contentFont;
		}
	};

	@SuppressWarnings({ "unchecked", "rawtypes" })
	final JComboBox units = new JComboBox(new String[] {}) {

	};

	final JLabel unitsLabel = new JLabel("units", JLabel.LEFT) {
		@Override
		public Font getFont() {
			return FontsAndColors.contentFont;
		}
	};

	public AddValueView(final Tagger tagger, final AppView appView,
			final GuiTagModel guiTagModel) {
		this.tagger = tagger;
		this.appView = appView;
		this.tagModel = guiTagModel;
		this.alternateView = null;
		addGuiComponents();
	}

	@Override
	protected void paintComponent(Graphics g) {
		Graphics2D g2d = (Graphics2D) g;
		g2d.setRenderingHint(RenderingHints.KEY_ANTIALIASING,
				RenderingHints.VALUE_ANTIALIAS_ON);
		double scale = ConstraintLayout.scale;
		g2d.setColor(FontsAndColors.EDITTAG_BG);
		int indent = tagModel.getDepth() + 3;
		g2d.fill(new Polygon(new int[] { (int) (scale * 24 * indent),
				(int) (scale * 24 * indent + scale * 10),
				(int) (scale * 24 * indent + scale * 20) }, new int[] {
				(int) (scale * 10), 0, (int) (scale * 10) }, 3));
		g2d.fill(new Rectangle2D.Double(10 * scale, 10 * scale, getWidth() - 36
				* scale, getHeight() - 15 * scale));
		if (highlight) {
			g2d.setColor(FontsAndColors.TAG_FG_HOVER);
		}
	}

	/**
	 * Populates the combo box that contains the units of the unit classes.
	 * 
	 * @return The units combo box.
	 */
	@SuppressWarnings({ "unchecked", "rawtypes" })
	private void populateUnitsComboBox() {
		String[] unitClassArray = Tagger.trimStringArray(tagModel
				.getUnitClass().split(","));
		String[] unitsArray = {};
		for (int i = 0; i < unitClassArray.length; i++) {
			if (tagger.unitClasses.get(unitClassArray[i]) != null) {
				String[] units = Tagger.trimStringArray(tagger.unitClasses.get(
						unitClassArray[i]).split(","));
				unitsArray = Tagger.concat(unitsArray, units);
			}
		}
		Arrays.sort(unitsArray);
		units.setModel(new DefaultComboBoxModel(unitsArray));
		setDefaultUnit();
	}

	/**
	 * Set the units combo box to the default unit.
	 */
	private void setDefaultUnit() {
		String[] unitClassArray = Tagger.trimStringArray(tagModel
				.getUnitClass().split(","));
		String unitClassDefault = tagger.unitClassDefaults
				.get(unitClassArray[0]);
		for (int i = 0; i < units.getItemCount(); i++) {
			if (unitClassDefault.toLowerCase().equals(
					units.getItemAt(i).toString().toLowerCase())) {
				units.setSelectedIndex(i);
				break;
			}
		}
	}

	/**
	 * Adds the units combo box to the view.
	 */
	private void addUnitsComboBox() {
		int unitHeight = HEIGHT + 50;
		top += 25;
		add(unitsLabel, new Constraint("top:" + top
				+ " height:20 left:15 width:50"));
		top += 25;
		add(units,
				new Constraint("top:" + top + " height:26 left:15 right:130"));
		add(new JComponent() {
		}, new Constraint("top:0 height:" + unitHeight + " left:0 right:0"));
	}

	final XButton cancelButton = new XButton("Cancel") {
		@Override
		public Font getFont() {
			Map<TextAttribute, Integer> fontAttributes = new HashMap<TextAttribute, Integer>();
			fontAttributes.put(TextAttribute.UNDERLINE,
					TextAttribute.UNDERLINE_ON);
			return FontsAndColors.contentFont.deriveFont(fontAttributes);
		}
	};

	final JLabel valueLabel = new JLabel("value", JLabel.LEFT) {
		@Override
		public Font getFont() {
			return FontsAndColors.contentFont;
		}
	};

	private void addGuiComponents() {
		addContainer();
		addLabels();
		addButtons();
		addUnits();
		execute();
	}

	private void execute() {
		SwingUtilities.invokeLater(new Runnable() {
			@Override
			public void run() {
				valueField.getJTextArea().requestFocusInWindow();
			}
		});
	}

	private void addContainer() {
		add(new JComponent() {
		}, new Constraint("top:0 height:80 left:0 width:0"));
	}

	private void addUnits() {
		if (!tagModel.getUnitClass().isEmpty()) {
			populateUnitsComboBox();
			addUnitsComboBox();
		}
	}

	private void addLabels() {
		setLabelBackgroundColors();
		setLabelForegroundColors();
		addLabelListeners();
		valueField.getJTextArea().getDocument()
				.addDocumentListener(new ValueFieldListener());
		add(valueLabel, new Constraint("top:" + top
				+ " height:20 left:15 width:50"));
		top += 25;
		add(valueField, new Constraint("top:" + top
				+ " height:26 left:15 width:200"));
	}

	private void addButtons() {
		okButton.setEnabled(false);
		okButton.setVisible(false);
		setButtonBackgroundColors();
		setButtonForegroundColors();
		addButtonListeners();
		add(okButton, new Constraint("top:10 height:20 right:81 width:35"));
		add(cancelButton, new Constraint("top:10 height:20 right:26 width:50"));
	}

	private void addButtonListeners() {
		/**
		 * When okay button is clicked, it creates a new tag model with the
		 * value typed in and attempts to toggle the tag with the selected tag
		 * groups.
		 */
		okButton.addMouseListener(new MouseAdapter() {
			@Override
			public void mouseClicked(MouseEvent e) {
				handleValueInput();
			}
		});

		cancelButton.addMouseListener(new MouseAdapter() {
			@Override
			public void mouseClicked(MouseEvent e) {
				handleCancel();
			}
		});
	}

	private void addLabelListeners() {
		valueField.getJTextArea().getDocument()
				.putProperty("filterNewlines", Boolean.TRUE);
		valueField.getJTextArea().getInputMap()
				.put(KeyStroke.getKeyStroke("ENTER"), "doNothing");
		valueField.getJTextArea().getInputMap()
				.put(KeyStroke.getKeyStroke("TAB"), "doNothing");
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
					handleValueInput();
				}
				if (e.getKeyCode() == KeyEvent.VK_ESCAPE) {
					handleCancel();
				}
			}

		});
	}

	private void setLabelBackgroundColors() {
		valueLabel.setBackground(FontsAndColors.EDITTAG_BG);
	}

	private void setButtonBackgroundColors() {
		okButton.setNormalBackground(FontsAndColors.TRANSPARENT);
		okButton.setHoverBackground(FontsAndColors.TRANSPARENT);
		okButton.setPressedBackground(FontsAndColors.TRANSPARENT);
		cancelButton.setPressedBackground(FontsAndColors.TRANSPARENT);
		cancelButton.setNormalBackground(FontsAndColors.TRANSPARENT);
		cancelButton.setHoverBackground(FontsAndColors.TRANSPARENT);
	}

	private void setLabelForegroundColors() {
		valueField.setForeground(FontsAndColors.GREY_DARK);
	}

	private void setButtonForegroundColors() {
		okButton.setPressedForeground(FontsAndColors.SOFT_BLUE);
		okButton.setNormalForeground(FontsAndColors.SOFT_BLUE);
		okButton.setHoverForeground(Color.BLACK);
		cancelButton.setNormalForeground(FontsAndColors.SOFT_BLUE);
		cancelButton.setHoverForeground(Color.BLACK);
		cancelButton.setPressedForeground(FontsAndColors.SOFT_BLUE);
	}

	private void handleCancel() {
		tagModel.setInAddValue(false);
		if (alternateView != null) {
			alternateView.valueAdded(null);
		}
		appView.updateTags();
	}

	private void handleValueInput() {
		if (okButton.isEnabled()) {
			String valueStr = valueField.getJTextArea().getText();
			valueField.getJTextArea().setText(new String());
			if (tagModel.isNumeric()) {
				String unitString = new String();
				if (units.getSelectedItem() != null) {
					unitString = units.getSelectedItem().toString();
				}
				valueStr = validateNumericValue(valueStr.trim(), unitString);
				if (valueStr == null) {
					appView.showTaggerMessageDialog(
							MessageConstants.TAG_UNIT_ERROR, "Okay", null, null);
					return;
				}
			}
			AbstractTagModel newTag = tagger.createTransientTagModel(tagModel,
					valueStr);
			GuiTagModel gtm = (GuiTagModel) newTag;
			gtm.setAppView(appView);
			tagModel.setInAddValue(false);
			if (alternateView != null) {
				alternateView.valueAdded(newTag);
			} else {
				gtm.requestToggleTag();
				appView.updateTags();
				appView.updateEventsPanel();
			}
			appView.scrollToEventTag((GuiTagModel) newTag);
		}
	}

	/**
	 * Validates numerical value
	 * 
	 * @param numericValue
	 *            A numerical value
	 * @param unit
	 *            Unit The unit associated with numerical value
	 * @return Null if invalid, numerical value with unit appended if valid
	 */
	private String validateNumericValue(String numericValue, String unit) {
		if (numericValue.matches("^[0-9]+(\\.[0-9]+)?$")
				|| numericValue.matches("^\\.[0-9]+$"))
			numericValue = numericValue + " " + unit;
		else
			numericValue = null;
		return numericValue;
	}

	ActionListener taskPerformer = new ActionListener() {
		public void actionPerformed(ActionEvent evt) {
			highlight = false;
			repaint();
		}
	};

	/**
	 * Updates the information shown in the view to match the underlying tag
	 * model.
	 */
	public void highlight() {
		highlight = true;
		SwingUtilities.invokeLater(new Runnable() {
			@Override
			public void run() {
				Timer timer = new Timer(2000, taskPerformer);
				timer.setRepeats(false);
				timer.start();
			}
		});
	}

}
