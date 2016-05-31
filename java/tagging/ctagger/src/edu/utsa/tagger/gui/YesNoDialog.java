package edu.utsa.tagger.gui;

import java.awt.Color;
import java.awt.Dimension;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;

import javax.swing.JDialog;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JPanel;

import edu.utsa.tagger.guisupport.Constraint;
import edu.utsa.tagger.guisupport.ConstraintLayout;
import edu.utsa.tagger.guisupport.XButton;

/**
 * Dialog used to allow the user to choose a file format.
 * 
 * @author Lauren Jett, Rebecca Strautman, Thomas Rognon, Jeremy Cockfield, Kay
 *         Robbins
 */
@SuppressWarnings("serial")
public class YesNoDialog extends JDialog {

	/**
	 * Closes the dialog and returns the option.
	 */
	private class OptionButtonListener extends MouseAdapter {

		private int buttonOption;

		public OptionButtonListener(int buttonOption) {
			this.buttonOption = buttonOption;
		}

		@Override
		public void mouseClicked(MouseEvent e) {
			option = buttonOption;
			setVisible(false);
			dispose();
		}
	}

	private int option = -1;
	private JPanel bgPanel = new JPanel();
	private XButton yesButton;
	private XButton noButton;
	private JLabel label;

	/**
	 * Constructor sets up the dialog with the given message. The position is
	 * set relative to the given frame. It shows options for choosing the data
	 * format to load or save.
	 * 
	 * @param frame
	 * @param message
	 */
	public YesNoDialog(JFrame frame, String message) {
		super(frame, true);
		bgPanel.setLayout(new ConstraintLayout());
		bgPanel.setBackground(Color.white);
		bgPanel.setPreferredSize(new Dimension(400, 150));
		label = new JLabel(message, JLabel.CENTER);
		label.setFont(FontsAndColors.contentFont);
		bgPanel.add(label, new Constraint("top:0 height:30 left:0 width:400"));
		yesButton = TaggerView.createMenuButton("Yes");
		bgPanel.add(yesButton, new Constraint(
				"bottom:10 height:30 left:5 width:80"));
		yesButton.addMouseListener(new OptionButtonListener(0));
		noButton = TaggerView.createMenuButton("No");
		bgPanel.add(noButton, new Constraint(
				"bottom:10 height:30 right:5 width:80"));
		noButton.addMouseListener(new OptionButtonListener(1));
		setDefaultCloseOperation(JDialog.DISPOSE_ON_CLOSE);
		getContentPane().add(bgPanel);
		pack();
		setLocationRelativeTo(frame);
	}

	/**
	 * Displays the dialog on the screen.
	 * 
	 * @return An integer representing the option chosen (0, 1, 2, or 3), or -1
	 *         if no option was chosen.
	 */
	public int showDialog() {
		setVisible(true);
		return option;
	}
}
