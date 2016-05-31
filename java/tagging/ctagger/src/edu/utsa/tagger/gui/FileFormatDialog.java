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
 * Dialog used to allow the user to choose a file format.
 * 
 * @author Lauren Jett, Rebecca Strautman, Thomas Rognon, Jeremy Cockfield, Kay
 *         Robbins
 */
@SuppressWarnings("serial")
public class FileFormatDialog extends JDialog {

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

	private void handlePressedButton(int buttonOption) {
		option = buttonOption;
		setVisible(false);
		dispose();
	}

	private int option = 0;
	private JPanel bgPanel = new JPanel();
	private XButton cancelButton;
	private XButton xmlButton;
	private XButton jsonButton;
	private XButton tdtButton;
	private JLabel label;

	/**
	 * Constructor sets up the dialog with the given message. The position is
	 * set relative to the given frame. It shows options for choosing the data
	 * format to load or save.
	 * 
	 * @param frame
	 * @param message
	 */
	public FileFormatDialog(JFrame frame, String message, boolean isStandalone) {
		super(frame, true);

		bgPanel.setLayout(new ConstraintLayout());
		bgPanel.setBackground(Color.white);
		bgPanel.setPreferredSize(new Dimension(750, 250));
		int top = 0;
		label = new JLabel(message, JLabel.CENTER);
		label.setFont(FontsAndColors.contentFont);
		bgPanel.add(label, new Constraint("top:0 height:30 left:0 width:750"));
		xmlButton = TaggerView.createMenuButton("Tag hierarchy in XML");
		top += 60;
		bgPanel.add(xmlButton, new Constraint("top:" + top + " height:30 left:10 right:10"));
		xmlButton.addMouseListener(new OptionButtonListener(1));
		jsonButton = TaggerView.createMenuButton("Event list as tab-delimited text");
		top += 40;
		bgPanel.add(jsonButton, new Constraint("top:" + top + " height:30 left:10 right:10"));
		jsonButton.addMouseListener(new OptionButtonListener(2));
		if (isStandalone) {
			tdtButton = TaggerView.createMenuButton("Event list and tag hierarchy in XML");
			top += 40;
			bgPanel.add(tdtButton, new Constraint("top:" + top + " height:30 left:10 right:10"));
			tdtButton.addMouseListener(new OptionButtonListener(3));
		} else {
			tdtButton = TaggerView.createMenuButton("Field map");
			top += 40;
			bgPanel.add(tdtButton, new Constraint("top:" + top + " height:30 left:10 right:10"));
			tdtButton.addMouseListener(new OptionButtonListener(4));
		}
		cancelButton = TaggerView.createMenuButton("Cancel");
		bgPanel.add(cancelButton, new Constraint("bottom:10 height:30 right:5 width:80"));
		cancelButton.addMouseListener(new OptionButtonListener(0));
		setDefaultCloseOperation(JDialog.DISPOSE_ON_CLOSE);
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
	 * @return An integer representing the option chosen (0, 1, 2, or 3), or -1
	 *         if no option was chosen.
	 */
	public int showDialog() {
		setVisible(true);
		return option;
	}
}
