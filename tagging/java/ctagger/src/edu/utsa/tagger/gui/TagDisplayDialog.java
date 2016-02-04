package edu.utsa.tagger.gui;

import java.awt.Color;
import java.awt.Dimension;
import java.awt.Font;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.RenderingHints;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;
import java.awt.geom.Rectangle2D;
import java.util.List;

import javax.swing.JComponent;
import javax.swing.JDialog;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JLayeredPane;
import javax.swing.JPanel;

import edu.utsa.tagger.EventModel;
import edu.utsa.tagger.TaggedEvent;
import edu.utsa.tagger.guisupport.Constraint;
import edu.utsa.tagger.guisupport.ConstraintLayout;
import edu.utsa.tagger.guisupport.ScrollLayout;
import edu.utsa.tagger.guisupport.XButton;

/**
 * Dialog used to show a message to the user that references specific tags of
 * specific events.
 * 
 * @author Lauren Jett, Rebecca Strautman, Thomas Rognon, Jeremy Cockfield, Kay
 *         Robbins
 */
@SuppressWarnings("serial")
public class TagDisplayDialog extends JDialog {
	/**
	 * Closes the dialog and returns false.
	 */
	private class CancelButtonListener extends MouseAdapter {
		@Override
		public void mouseClicked(MouseEvent e) {
			response = false;
			setVisible(false);
			dispose();
		}
	}

	/**
	 * Closes the dialog and returns true.
	 */
	private class OkButtonListener extends MouseAdapter {
		@Override
		public void mouseClicked(MouseEvent e) {
			response = true;
			setVisible(false);
			dispose();
		}
	}

	/**
	 * Component to display a tag's path as well as the event and group
	 * containing the tag.
	 */
	private class TagItem extends JComponent {
		private String message;

		private TagItem(String message) {
			this.message = message;
		}

		@Override
		protected void paintComponent(Graphics g) {
			Graphics2D g2d = (Graphics2D) g;
			g2d.setRenderingHint(RenderingHints.KEY_TEXT_ANTIALIASING,
					RenderingHints.VALUE_TEXT_ANTIALIAS_LCD_HRGB);

			Color fg = Color.gray;
			Color bg = Color.white;

			g2d.setColor(bg);
			g2d.fill(new Rectangle2D.Double(0, 0, getWidth(), getHeight()));
			double x = getHeight() * 0.4 + 7;
			double y = getHeight() * 0.75;

			g2d.setColor(fg);
			g2d.setFont(FontsAndColors.contentFont);
			g2d.drawString(message, (int) x, (int) y);
		}
	}

	private boolean response;
	private List<EventModel> egtList;
	private JPanel bgPanel = new JPanel();

	private JPanel tagsPanel = new JPanel();
	private XButton okButton;
	private XButton cancelButton;
	private ScrollLayout fileScrollLayout;

	private JLayeredPane fileScrollPane = new JLayeredPane();

	private JLabel topMessageLabel = new JLabel() {
		@Override
		public Font getFont() {
			return FontsAndColors.contentFont;
		}
	};

	private JLabel bottomMessageLabel = new JLabel() {
		@Override
		public Font getFont() {
			return FontsAndColors.contentFont;
		}
	};

	/**
	 * Sets up the dialog with the given parameters.
	 * 
	 * @param frame
	 *            Frame to show dialog in reference to
	 * @param egtList
	 *            List of EGT models representing the tags to display
	 * @param topMessage
	 *            Message to show above the tag list
	 * @param bottomMessage
	 *            Message to show below the tag list
	 * @param options
	 *            Whether multiple options are available ("Okay" and "Cancel"
	 *            options if true, only "Okay" option if false)
	 * @param buttonText
	 *            Text to display for the "Okay" option
	 * @param frameTitle
	 *            Title for the dialog window
	 */
	public TagDisplayDialog(JFrame frame, List<EventModel> egtList,
			String topMessage, String bottomMessage, boolean options,
			String buttonText, String frameTitle) {
		super(frame, frameTitle, true);
		this.egtList = egtList;

		bgPanel.setLayout(new ConstraintLayout());
		bgPanel.setBackground(Color.white);
		bgPanel.setPreferredSize(new Dimension(700, 300));

		topMessageLabel.setText(topMessage);
		okButton = AppView.createMenuButton(buttonText);
		okButton.addMouseListener(new OkButtonListener());
		fileScrollLayout = new ScrollLayout(fileScrollPane, tagsPanel);
		fileScrollPane.setLayout(fileScrollLayout);
		tagsPanel.setLayout(new ConstraintLayout());
		tagsPanel.setBackground(Color.white);

		bgPanel.add(topMessageLabel, new Constraint(
				"top:0 height:30 left:10 width:700"));
		if (bottomMessage != null) {
			bottomMessageLabel.setText(bottomMessage);
			bgPanel.add(fileScrollPane, new Constraint(
					"top:40 bottom:80 left:0 right:0"));
			bgPanel.add(bottomMessageLabel, new Constraint(
					"bottom:50 height:30 left:10 width:700"));
		} else {
			bgPanel.add(fileScrollPane, new Constraint(
					"top:40 bottom:80 left:0 right:0"));
		}
		bgPanel.add(okButton, new Constraint(
				"bottom:10 height:30 right:10 width:120"));
		if (options) {
			cancelButton = AppView.createMenuButton("Cancel");
			cancelButton.addMouseListener(new CancelButtonListener());
			bgPanel.add(cancelButton, new Constraint(
					"bottom:10 height:30 left:10 width:80"));
		}

		addTags();

		getContentPane().add(bgPanel);
		pack();
		setLocationRelativeTo(frame);
	}

	/**
	 * Adds the tag views to the dialog.
	 */
	private void addTags() {
		int top = 0;
		for (EventModel egt : egtList) {
			String message = createMessage(egt);
			tagsPanel.add(new TagItem(message), new Constraint("top:" + top
					+ " height:30"));
			top += 30;
		}
	}

	/**
	 * Creates the message to display for each tag. The message contains the
	 * event code and label, the group number that the tag is in (if the tag is
	 * in a group), and the tag path.
	 * 
	 * @param egt
	 * @return The message created
	 */
	private String createMessage(EventModel egt) {
		TaggedEvent taggedEvent = (TaggedEvent) egt.getTaggedEvent();
		String eventString = taggedEvent.getEventModel().getCode() + ": "
				+ taggedEvent.getLabel();
		String message = egt.getTagModel().getPath() + " in";
		if (egt.getGroupId() != taggedEvent.getEventGroupId()) {
			int groupNumber = taggedEvent.getGroupNumber(egt.getGroupId());
			message += " group " + groupNumber + " of";
		}
		message += " event " + eventString;
		return message;
	}

	/**
	 * Shows the dialog on the screen
	 * 
	 * @return The user's response. True for the "Okay" option and false for the
	 *         "Cancel" option.
	 */
	public boolean showDialog() {
		setVisible(true);
		return response;
	}
}
