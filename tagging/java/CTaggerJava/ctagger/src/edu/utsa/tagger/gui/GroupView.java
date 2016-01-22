package edu.utsa.tagger.gui;

import java.awt.Color;
import java.awt.Component;
import java.awt.Container;
import java.awt.Dimension;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.LayoutManager;
import java.awt.RenderingHints;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.MouseEvent;
import java.awt.event.MouseListener;
import java.awt.geom.Rectangle2D;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Set;

import javax.swing.JComponent;
import javax.swing.SwingUtilities;
import javax.swing.Timer;

import edu.utsa.tagger.AbstractTagModel;
import edu.utsa.tagger.TaggedEvent;
import edu.utsa.tagger.Tagger;
import edu.utsa.tagger.gui.ContextMenu.ContextMenuAction;
import edu.utsa.tagger.guisupport.ClickDragThreshold;
import edu.utsa.tagger.guisupport.ConstraintLayout;
import edu.utsa.tagger.guisupport.XCheckBox;
import edu.utsa.tagger.guisupport.XCheckBox.StateListener;

/**
 * This class represents the view for a tag group.
 * 
 * @author Lauren Jett, Rebecca Strautman, Thomas Rognon, Jeremy Cockfield, Kay
 *         Robbins
 * 
 */
@SuppressWarnings("serial")
public class GroupView extends JComponent implements MouseListener,
		StateListener {

	private final int MAX_GROUP_TILDES = 2;
	private final Tagger tagger;
	private final AppView appView;
	private final Integer groupId;
	private HashMap<AbstractTagModel, TagEventView> tagEgtViews;
	private boolean highlight = false;
	private boolean selected = false;
	XCheckBox checkbox;

	public GroupView(Tagger tagger, AppView appView, Integer groupId) {
		this.tagger = tagger;
		this.appView = appView;
		this.groupId = groupId;
		this.tagEgtViews = new HashMap<AbstractTagModel, TagEventView>();
		addMouseListener(this);
		setLayout(layout);
		new ClickDragThreshold(this);
		checkbox = new XCheckBox(FontsAndColors.TRANSPARENT, Color.black,
				FontsAndColors.TRANSPARENT, Color.blue,
				FontsAndColors.TRANSPARENT, Color.blue) {
			@Override
			public Dimension getPreferredSize() {
				return new Dimension((int) (ConstraintLayout.scale * 20),
						(int) (ConstraintLayout.scale * 20));
			}
		};
		add(checkbox);
		checkbox.addStateListener(this);
	}

	LayoutManager layout = new LayoutManager() {
		@Override
		public void addLayoutComponent(String s, Component c) {
		}

		@Override
		public void layoutContainer(Container target) {
			Component c = target.getComponent(0);
			c.setBounds(0,
					(target.getHeight() - c.getPreferredSize().height) / 2,
					c.getPreferredSize().width, c.getPreferredSize().height);
		}

		@Override
		public Dimension minimumLayoutSize(Container target) {
			return null;
		}

		@Override
		public Dimension preferredLayoutSize(Container target) {
			return null;
		}

		@Override
		public void removeLayoutComponent(Component c) {
		}

	};

	public Integer getGroupId() {
		return groupId;
	}

	public void addTagEgtView(AbstractTagModel tagModel, TagEventView tagEgtView) {
		tagEgtViews.put(tagModel, tagEgtView);
	}

	public TagEventView getTagEgtViewByKey(AbstractTagModel tagModel) {
		return tagEgtViews.get(tagModel);
	}

	@Override
	public void mouseClicked(MouseEvent e) {
		if (SwingUtilities.isLeftMouseButton(e)) {
			appView.selectedGroups.clear();
			appView.selectedGroups.add(groupId);
			appView.updateEgt();
		} else if (SwingUtilities.isRightMouseButton(e)) {
			Map<String, ContextMenuAction> map = new LinkedHashMap<String, ContextMenuAction>();
			map.put("add ~", new ContextMenuAction() {
				@Override
				public void doAction() {
					TaggedEvent taggedEvent = tagger.getEventByGroupId(groupId);
					int numTags = taggedEvent.getNumTagsInGroup(groupId);
					addTilde(numTags);
				}
			});
			map.put("remove group", new ContextMenuAction() {
				@Override
				public void doAction() {
					tagger.removeGroup(groupId);
					appView.updateEgt();
				}
			});
			appView.showContextMenu(map, 105);
		}
	}

	private void addTilde(int index) {
		int numTildes = 0;
		TaggedEvent taggedEvent = tagger.getEventByGroupId(groupId);
		if (taggedEvent != null) {
			numTildes = taggedEvent.findNumTildes(groupId);
		}
		if (numTildes < MAX_GROUP_TILDES) {
			GuiTagModel newTag = (GuiTagModel) tagger.getFactory()
					.createAbstractTagModel(tagger);
			newTag.setPath("~");
			newTag.setAppView(appView);
			Set<Integer> groupSet = new HashSet<Integer>();
			groupSet.add(groupId);
			tagger.associate(newTag, index, groupSet);
			appView.updateEgt();
			appView.scrollToEventTag(newTag);
		} else {
			appView.showTaggerMessageDialog(MessageConstants.TILDE_ERROR,
					"Okay", null, null);
		}
	}

	@Override
	public void mouseEntered(MouseEvent e) {
		repaint();
	}

	@Override
	public void mouseExited(MouseEvent e) {
		repaint();
	}

	@Override
	public void mousePressed(MouseEvent e) {
		repaint();
	}

	@Override
	public void mouseReleased(MouseEvent e) {
		repaint();
	}

	@Override
	protected void paintComponent(Graphics g) {

		Graphics2D g2d = (Graphics2D) g;
		g2d.setRenderingHint(RenderingHints.KEY_TEXT_ANTIALIASING,
				RenderingHints.VALUE_TEXT_ANTIALIAS_LCD_HRGB);

		if (selected) {
			g2d.setColor(FontsAndColors.GROUP_SELECTED);
		} else {
			g2d.setColor(Color.white);
		}
		g2d.fill(SwingUtilities.calculateInnerArea(this, null));

		if (highlight) {
			g2d.setColor(FontsAndColors.BLUE_DARK);
		} else {
			g2d.setColor(Color.BLACK);
		}

		double scale = ConstraintLayout.scale;

		g2d.fill(new Rectangle2D.Double(getWidth() - 10 * scale, 0, 1 * scale,
				getHeight() - 1 * scale - 1));
		g2d.fill(new Rectangle2D.Double(getWidth() - 10 * scale, 0, 10 * scale,
				1 * scale));
		g2d.fill(new Rectangle2D.Double(getWidth() - 10 * scale, getHeight()
				- 1 * scale - 1, 10 * scale, 1 * scale));
	}

	public void setSelected(boolean selected) {
		this.selected = selected;
		checkbox.setChecked(selected);
		repaint();
	}

	@Override
	public void stateChanged() {
		if (appView.selectedGroups.contains(groupId)) {
			appView.selectedGroups.remove(groupId);
			setSelected(false);
		} else {
			appView.selectedGroups.add(groupId);
			setSelected(true);
		}
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