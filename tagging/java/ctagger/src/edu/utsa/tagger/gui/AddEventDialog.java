package edu.utsa.tagger.gui;

import java.awt.Color;
import java.awt.Dimension;
import java.awt.Font;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;

import javax.swing.JDialog;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JTextField;
import javax.swing.event.DocumentEvent;
import javax.swing.event.DocumentListener;

import edu.utsa.tagger.guisupport.Constraint;
import edu.utsa.tagger.guisupport.ConstraintLayout;
import edu.utsa.tagger.guisupport.XButton;

/**
 * Dialog allowing the user to add a new event.
 * 
 * @author Lauren Jett, Rebecca Strautman, Thomas Rognon, Jeremy Cockfield, Kay
 *         Robbins
 */
@SuppressWarnings("serial")
public class AddEventDialog extends JDialog {

	private class CancelButtonListener extends MouseAdapter {
		/**
		 * Closes the dialog and sets the return value to null.
		 */
		@Override
		public void mouseClicked(MouseEvent e) {
			eventFields = null;
			AddEventDialog.this.setVisible(false);
			AddEventDialog.this.dispose();
		}
	}

	private class EventFieldListener implements DocumentListener {

		@Override
		public void changedUpdate(DocumentEvent e) {
			if (!code.getText().trim().isEmpty()) {
				saveButton.setEnabled(true);
				saveButton.setVisible(true);
			} else {
				saveButton.setEnabled(false);
				saveButton.setVisible(false);
			}
		}

		@Override
		public void insertUpdate(DocumentEvent e) {
			if (!code.getText().trim().isEmpty()) {
				saveButton.setEnabled(true);
				saveButton.setVisible(true);
			}
		}

		@Override
		public void removeUpdate(DocumentEvent e) {
			if (code.getText().trim().isEmpty()) {
				saveButton.setEnabled(false);
				saveButton.setVisible(false);
			}
		}
	}

	private class SaveButtonListener extends MouseAdapter {
		@Override
		/**
		 * If the save button is enabled, then the text from the code and label
		 * fields are stored to be returned to the user when the dialog closes.
		 * If not, the event is consumed.
		 */
		public void mouseClicked(MouseEvent e) {
			if (saveButton.isEnabled()) {
				eventFields = new String[2];
				eventFields[0] = code.getText();
				eventFields[1] = label.getText();
				AddEventDialog.this.setVisible(false);
				AddEventDialog.this.dispose();
			} else {
				e.consume();
			}
		}
	}

	// Contains the event code (index 0) and event label (index 1)
	String[] eventFields;
	private JPanel bgPanel = new JPanel();
	private JLabel codeLabel = new JLabel() {
		@Override
		public Font getFont() {
			return FontsAndColors.contentFont;
		}
	};
	JTextField code = new JTextField();
	private JLabel labelLabel = new JLabel() {
		@Override
		public Font getFont() {
			return FontsAndColors.contentFont;
		}
	};

	JTextField label = new JTextField();

	private XButton saveButton;

	private XButton cancelButton;

	public AddEventDialog(JFrame frame) {
		super(frame, true);
		bgPanel.setLayout(new ConstraintLayout());
		bgPanel.setBackground(Color.white);
		bgPanel.setPreferredSize(new Dimension(300, 200));

		codeLabel.setText("Code (required)");
		labelLabel.setText("Label");
		code = new JTextField();
		label = new JTextField();

		saveButton = TaggerView.createMenuButton("Save");
		saveButton.setEnabled(false);
		saveButton.setVisible(false);
		cancelButton = TaggerView.createMenuButton("Cancel");

		bgPanel.add(codeLabel, new Constraint(
				"top:15 height:30 left:5 width:130"));
		bgPanel.add(code, new Constraint("top:15 height:30 left:140 width:150"));
		bgPanel.add(labelLabel, new Constraint(
				"top:50 height:30 left:5 width:80"));
		bgPanel.add(label,
				new Constraint("top:50 height:30 left:140 width:150"));
		bgPanel.add(saveButton, new Constraint(
				"right:40 width:80 bottom:10 height:30"));
		bgPanel.add(cancelButton, new Constraint(
				"left:40 width:80 bottom:10 height:30"));
		getContentPane().add(bgPanel);
		pack();
		setLocationRelativeTo(frame);

		saveButton.addMouseListener(new SaveButtonListener());
		cancelButton.addMouseListener(new CancelButtonListener());
		code.getDocument().addDocumentListener(new EventFieldListener());
	}

	/**
	 * Shows the dialog to get the event code and label.
	 * 
	 * @return A String[] of size 2 containing the event code at index 0 and the
	 *         event label at index 1. Returns null if the user chose to cancel.
	 */
	public String[] showDialog() {
		setTitle("Add Event");
		setVisible(true);
		return eventFields;
	}
}