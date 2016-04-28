package edu.utsa.tagger.gui;

import java.awt.Color;
import java.awt.Component;
import java.awt.Container;
import java.awt.Dimension;
import java.awt.Font;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.LayoutManager;
import java.awt.RenderingHints;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.MouseEvent;
import java.awt.event.MouseListener;
import java.util.LinkedHashMap;
import java.util.Map;

import javax.swing.JComponent;
import javax.swing.SwingUtilities;
import javax.swing.Timer;

import edu.utsa.tagger.TaggedEvent;
import edu.utsa.tagger.Tagger;
import edu.utsa.tagger.gui.ContextMenu.ContextMenuAction;
import edu.utsa.tagger.guisupport.ClickDragThreshold;
import edu.utsa.tagger.guisupport.ConstraintLayout;
import edu.utsa.tagger.guisupport.XCheckBox;
import edu.utsa.tagger.guisupport.XCheckBox.StateListener;

/**
 * This class represents the view for an event.
 * 
 * @author Lauren Jett, Rebecca Strautman, Thomas Rognon, Jeremy Cockfield, Kay
 *         Robbins
 */
@SuppressWarnings("serial")
public class EventView extends JComponent implements MouseListener {

	private final Tagger tagger;
	private final TaggerView appView;
	private final TaggedEvent taggedEvent;
	private int groupId;
	private int currentPosition;
	private boolean highlight = false;
	private boolean pressed = false;
	private boolean hover = false;
	private boolean selected = false;
	private XCheckBox checkbox;

	public EventView(Tagger tagger, TaggerView appView, TaggedEvent taggedEvent) {
		this.tagger = tagger;
		this.appView = appView;
		this.taggedEvent = taggedEvent;
		setLayout(layout);
		checkbox = new XCheckBox(FontsAndColors.TRANSPARENT, Color.black,
				FontsAndColors.TRANSPARENT, Color.blue,
				FontsAndColors.TRANSPARENT, Color.blue) {
			@Override
			public Dimension getPreferredSize() {
				return new Dimension((int) (ConstraintLayout.scale * 20),
						(int) (ConstraintLayout.scale * 20));
			}
		};
		checkbox.addStateListener(new CheckBoxListener());
		add(checkbox);
		addMouseListener(this);
		new ClickDragThreshold(this);
	}

	private class CheckBoxListener implements StateListener {

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

	public int getCurrentPosition() {
		return currentPosition;
	}

	/**
	 * If the left mouse button is clicked, it selects the event to be tagged.
	 * If the right mouse button is clicked, it creates and displays a context
	 * menu containing options to add a group, show or hide required and
	 * recommended tags, edit the event, or delete the event.
	 */
	@Override
	public void mouseClicked(MouseEvent e) {
		if (SwingUtilities.isLeftMouseButton(e)) {
			appView.selectedGroups.clear();
			appView.selectedGroups.add(groupId);
			appView.updateEventsPanel();
		} else if (SwingUtilities.isRightMouseButton(e)) {
			Map<String, ContextMenuAction> map = new LinkedHashMap<String, ContextMenuAction>();
			map.put("add group", new ContextMenuAction() {
				@Override
				public void doAction() {
					int groupId = tagger.addNewGroup(taggedEvent);
					appView.updateEventsPanel();
					appView.scrollToNewGroup(taggedEvent, groupId);
				}
			});
			if (!taggedEvent.showInfo()) {
				map.put("show required/recommended", new ContextMenuAction() {
					@Override
					public void doAction() {
						taggedEvent.setShowInfo(true);
						appView.updateEventsPanel();
					}
				});
			} else {
				map.put("hide required/recommended", new ContextMenuAction() {
					@Override
					public void doAction() {
						taggedEvent.setShowInfo(false);
						appView.updateEventsPanel();
					}
				});
			}
			if (!taggedEvent.isInEdit()) {
				map.put("edit", new ContextMenuAction() {
					@Override
					public void doAction() {
						taggedEvent.setInEdit(true);
						appView.updateEventsPanel();
					}
				});
			}
			map.put("delete", new ContextMenuAction() {
				@Override
				public void doAction() {
					tagger.removeEvent(taggedEvent);
					appView.updateEventsPanel();
				}
			});
			appView.showContextMenu(map, 205);
		}
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

		Graphics2D g2d = (Graphics2D) g;
		g2d.setRenderingHint(RenderingHints.KEY_TEXT_ANTIALIASING,
				RenderingHints.VALUE_TEXT_ANTIALIAS_LCD_HRGB);

		Color bg;
		Color fg;

		if (!pressed && hover || highlight) {
			bg = FontsAndColors.EVENT_BG_HOVER;
			fg = FontsAndColors.EVENT_FG_HOVER;
		} else if (pressed && hover) {
			bg = FontsAndColors.EVENT_BG_PRESSED;
			fg = FontsAndColors.EVENT_FG_PRESSED;
		} else {
			bg = FontsAndColors.EVENT_BG_NORMAL;
			fg = FontsAndColors.EVENT_FG_NORMAL;
		}

		g2d.setColor(bg);
		g2d.fill(SwingUtilities.calculateInnerArea(this, null));
		if (selected) {
			g2d.setColor(FontsAndColors.EVENT_SELECTED);
			g2d.fillRect(0, 0, 30, getHeight());
		}

		double x = getHeight() / 4 + ConstraintLayout.scale * 30;
		double y = getHeight() * 0.75;

		g2d.setColor(fg);
		g2d.setFont(FontsAndColors.contentFont.deriveFont(Font.BOLD));
		g2d.drawString(taggedEvent.getEventModel().getCode() + ": "
				+ taggedEvent.getEventModel().getLabel() + " ", (int) x,
				(int) y);
	}

	public void setCurrentPosition(int position) {
		this.currentPosition = position;
	}

	public void setGroupId(int groupId) {
		this.groupId = groupId;
	}

	public void setSelected(boolean selected) {
		this.selected = selected;
		checkbox.setChecked(selected);
		repaint();
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
