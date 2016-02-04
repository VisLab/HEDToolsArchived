package edu.utsa.tagger.gui;

import java.awt.Color;
import java.awt.Dimension;
import java.awt.Font;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;

import javax.swing.JDialog;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JLayeredPane;
import javax.swing.JPanel;

import edu.utsa.tagger.AbstractTagModel;
import edu.utsa.tagger.Tagger;
import edu.utsa.tagger.TaggerSet;
import edu.utsa.tagger.guisupport.Constraint;
import edu.utsa.tagger.guisupport.ConstraintLayout;
import edu.utsa.tagger.guisupport.ITagDisplay;
import edu.utsa.tagger.guisupport.ListLayout;
import edu.utsa.tagger.guisupport.ScrollLayout;
import edu.utsa.tagger.guisupport.XButton;

/**
 * Dialog used to choose a tag from a subset of the tag hierarchy.
 * 
 * @author Lauren Jett, Rebecca Strautman, Thomas Rognon, Jeremy Cockfield, Kay
 *         Robbins
 */
@SuppressWarnings("serial")
public class TagChooserDialog extends JDialog implements ITagDisplay {
	/**
	 * Closes the dialog and sets the tag chosen to null.
	 */
	private class CancelButtonListener extends MouseAdapter {
		@Override
		public void mouseClicked(MouseEvent e) {
			setTagChosen(null);
			setVisible(false);
			dispose();
		}
	}

	private JFrame frame;
	private AppView appView;
	private Tagger tagger;
	private TaggerSet<AbstractTagModel> tags;
	private AbstractTagModel tagChosen;

	private int baseDepth;
	private boolean firstUpdate = true;

	private static final int INITIAL_DEPTH = 1;
	private JPanel bgPanel = new JPanel();
	private JPanel tagPanel = new JPanel();
	private ScrollLayout tagScrollLayout;
	private JLayeredPane tagScrollPane = new JLayeredPane();
	private JLabel message = new JLabel() {
		@Override
		public Font getFont() {
			return FontsAndColors.contentFont;
		}
	};

	private XButton cancel;

	private static final String MESSAGE_TEXT = "Choose tag(s) from the subhierarchy:";

	/**
	 * Constructor sets up the contents of the dialog. The tag view will contain
	 * the tags given as a parameter.
	 * 
	 * @param frame
	 * @param appView
	 * @param tagger
	 * @param tags
	 */

	public void repaintTagScrollPane() {
		tagScrollPane.repaint();
	}

	public TagChooserDialog(JFrame frame, AppView appView, Tagger tagger,
			TaggerSet<AbstractTagModel> tags) {
		super(frame, true);
		this.frame = frame;
		this.appView = appView;
		this.tagger = tagger;
		this.tags = tags;

		if (tags.size() > 0) {
			baseDepth = tags.get(0).getDepth();
		}

		cancel = AppView.createMenuButton("Cancel");
		cancel.addMouseListener(new CancelButtonListener());
		bgPanel.setLayout(new ConstraintLayout());
		bgPanel.setBackground(Color.white);
		bgPanel.setPreferredSize(new Dimension(400, 500));
		tagScrollLayout = new ScrollLayout(tagScrollPane, tagPanel);
		tagScrollPane.setLayout(tagScrollLayout);
		tagPanel.setLayout(new ListLayout(1, 1, 0, 1));
		tagPanel.setBackground(Color.white);
		message.setText(MESSAGE_TEXT);
		bgPanel.add(message, new Constraint("top:0 height:20"));
		bgPanel.add(tagScrollPane, new Constraint(
				"top:20 height:430 left:0 right:0"));
		bgPanel.add(cancel, new Constraint(
				"bottom:10 height:30 right:10 width:80"));
		getContentPane().add(bgPanel);
	}

	public void setTagChosen(AbstractTagModel tag) {
		this.tagChosen = tag;
	}

	/**
	 * Shows the dialog and returns the tag chosen.
	 * 
	 * @return
	 */
	public AbstractTagModel showDialog() {
		firstUpdate = true;
		updateTags();
		pack();
		setLocationRelativeTo(frame);
		setVisible(true);
		return tagChosen;
	}

	/**
	 * Refreshes the dialog's tag panel.
	 */
	public void updateTags() {
		tagPanel.removeAll();
		String lastVisibleTagPath = null;
		for (AbstractTagModel tagModel : tags) {
			GuiTagModel guiTagModel = (GuiTagModel) tagModel;
			guiTagModel.setAppView(appView);
			guiTagModel.setCollapsable(tagger.hasChildTags(guiTagModel));
			TagChooserView tcv = guiTagModel.getTagChooserView(baseDepth);
			tcv.update();
			if (guiTagModel.isCollapsable() && firstUpdate) {
				tcv.setCollapsed(tcv.getDepth() >= INITIAL_DEPTH);
			}
			if (lastVisibleTagPath != null
					&& tagModel.getPath().startsWith(lastVisibleTagPath)) {
				continue;
			}
			lastVisibleTagPath = tcv.isCollapsed() ? guiTagModel.getPath()
					: null;
			tcv.setTagChooserDialog(this);
			tagPanel.add(tcv);
			if (guiTagModel.isInEdit()) {
				tagPanel.add(guiTagModel.getTagEditView());
			}
			if (guiTagModel.isInAddValue()) {
				tagPanel.add(guiTagModel.getAlternateAddValueView(this));
			}
		}
		tagPanel.validate();
		tagPanel.repaint();
		tagScrollPane.validate();
		tagScrollPane.repaint();
		validate();
		repaint();
		firstUpdate = false;
	}

	/**
	 * Responds when a user adds a value to a tag that takes value.
	 */
	@Override
	public void valueAdded(AbstractTagModel tag) {
		if (tag != null) {
			setTagChosen(tag);
			setVisible(false);
			dispose();
		} else {
			updateTags();
		}
	}
}
