package edu.utsa.tagger.gui;

import java.awt.Color;
import java.awt.Dimension;
import java.awt.event.KeyEvent;
import java.awt.event.KeyListener;
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
 * Dialog used to present a message to the user.
 * 
 * @author Lauren Jett, Rebecca Strautman, Thomas Rognon, Jeremy Cockfield, Kay
 *         Robbins
 */
@SuppressWarnings("serial")
public class TaggerMessageDialog extends JDialog {

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
			handlePressedButton(buttonOption);
		}
	}

	public void handlePressedButton(int buttonOption) {
		option = buttonOption;
		setVisible(false);
		dispose();
	}

	private int option = -1;
	private JPanel bgPanel = new JPanel();
	private XButton opt0Button;
	private XButton opt1Button;
	private XButton opt2Button;
	private JLabel messageLabel;

	/**
	 * Constructor sets up the dialog with the given parameters. The position is
	 * set relative to the given frame, and it displays the given message. It
	 * can show one, two, or three options for the user to choose. The text for
	 * each option is given as a parameter. If an option is not to be shown, the
	 * parameter should be null.
	 * 
	 * @param frame
	 *            The frame to display relative to
	 * @param message
	 *            The message to show in the dialog
	 * @param opt0
	 *            The text for the first option
	 * @param opt1
	 *            The text for the second option (may be null)
	 * @param opt2
	 *            The text for the third option (may be null)
	 */
	public TaggerMessageDialog(JFrame frame, String message, String opt0,
			String opt1, String opt2) {
		super(frame, true);

		bgPanel.setLayout(new ConstraintLayout());
		bgPanel.setBackground(Color.white);
		bgPanel.setPreferredSize(new Dimension(400, 200));
		messageLabel = new JLabel(message, JLabel.CENTER);
		messageLabel.setFont(FontsAndColors.contentFont);
		bgPanel.add(messageLabel, new Constraint(
				"top:0 bottom:50 left:10 width:400"));
		messageLabel.setText("<html>" + message + "</html>");
		int margin = 30;
		if (opt2 != null) {
			margin = 15;
			opt2Button = AppView.createMenuButton(opt2);
			bgPanel.add(opt2Button, new Constraint("bottom:10 height:30 "
					+ "left:100 right:100"));
			opt2Button.addMouseListener(new OptionButtonListener(2));
		}
		opt0Button = AppView.createMenuButton(opt0);
		bgPanel.add(opt0Button, new Constraint("bottom:10 height:30 right:"
				+ margin + " width:80"));
		opt0Button.addMouseListener(new OptionButtonListener(0));
		if (opt1 != null) {
			opt1Button = AppView.createMenuButton(opt1);
			bgPanel.add(opt1Button, new Constraint("bottom:10 height:30 left:"
					+ margin + " width:80"));
			opt1Button.addMouseListener(new OptionButtonListener(1));
		}

		getContentPane().add(bgPanel);
		pack();
		setLocationRelativeTo(frame);

		this.addKeyListener(new KeyListener() {

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
					handlePressedButton(0);
				}
				if (e.getKeyCode() == KeyEvent.VK_ESCAPE) {
					handlePressedButton(0);
				}
			}

		});
	}

	/**
	 * Displays the dialog on the screen.
	 * 
	 * @return An integer representing the option chosen (0, 1, or 2), or -1 if
	 *         no option was chosen.
	 */
	public int showDialog() {
		setVisible(true);
		return option;
	}
}
