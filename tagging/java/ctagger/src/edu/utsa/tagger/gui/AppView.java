package edu.utsa.tagger.gui;

import java.awt.Color;
import java.awt.Font;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.GridLayout;
import java.awt.MouseInfo;
import java.awt.Point;
import java.awt.event.FocusEvent;
import java.awt.event.FocusListener;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;
import java.awt.event.MouseListener;
import java.awt.event.WindowEvent;
import java.awt.geom.Line2D;
import java.awt.geom.Rectangle2D;
import java.io.File;
import java.util.Collections;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.swing.JComponent;
import javax.swing.JFileChooser;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JLayeredPane;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.JSeparator;
import javax.swing.JTextField;
import javax.swing.KeyStroke;
import javax.swing.SwingConstants;
import javax.swing.event.DocumentEvent;
import javax.swing.event.DocumentListener;
import javax.swing.filechooser.FileFilter;
import javax.swing.filechooser.FileNameExtensionFilter;

import edu.utsa.tagger.AbstractTagModel;
import edu.utsa.tagger.EventModel;
import edu.utsa.tagger.HistoryItem;
import edu.utsa.tagger.Loader;
import edu.utsa.tagger.TaggedEvent;
import edu.utsa.tagger.Tagger;
import edu.utsa.tagger.TaggerSet;
import edu.utsa.tagger.ToggleTagMessage;
import edu.utsa.tagger.gui.ContextMenu.ContextMenuAction;
import edu.utsa.tagger.guisupport.Constraint;
import edu.utsa.tagger.guisupport.ConstraintContainer;
import edu.utsa.tagger.guisupport.ConstraintLayout;
import edu.utsa.tagger.guisupport.DropShadowBorder;
import edu.utsa.tagger.guisupport.ListLayout;
import edu.utsa.tagger.guisupport.ScrollLayout;
import edu.utsa.tagger.guisupport.VerticalSplitLayout;
import edu.utsa.tagger.guisupport.XButton;
import edu.utsa.tagger.guisupport.XScrollTextBox;
import edu.utsa.tagger.guisupport.XTextBox;

/**
 * This class represents the main Tagger GUI view.
 * 
 * @author Lauren Jett, Rebecca Strautman, Thomas Rognon, Jeremy Cockfield, Kay
 *         Robbins
 */
@SuppressWarnings("serial")
public class AppView extends ConstraintContainer {

	/**
	 * When the load button is clicked, it shows a dialog for the user to choose
	 * the data format to load. It then shows one or more filechooser dialogs
	 * for the user to choose the file(s) to load.
	 */
	private class LoadMouseListener extends MouseAdapter {
		@Override
		public void mouseClicked(MouseEvent e) {
			int loadOption = -1;
			while (loadOption == -1) {
				loadOption = handleLoad();
			}
		}
	}

	/**
	 * Handles the loading of the data.
	 */
	private int handleLoad() {
		FileFormatDialog dialog = new FileFormatDialog(frame, MessageConstants.OPEN_DATA_TYPE_Q);
		int option = dialog.showDialog();
		switch (option) {
		case 1:
			return loadHEDXMLDialog(option);
		case 2:
			return loadTSVDialog(option);
		case 3:
			return loadTaggerDataXMLDialog(option);
		default:
			dialog.dispose();
			return 0;
		}
	}

	/**
	 * Refreshes the event and tag panels.
	 */
	private void refreshPanels() {
		selectedGroups.clear();
		updateEgt();
		autoCollapse = true;
		updateTags();
	}

	/**
	 * When the save button is clicked, it shows a dialog to get the data type
	 * to save to. It then shows one or more filechooser dialogs to get the
	 * file(s) to save to.
	 */
	private class SaveMouseListener extends MouseAdapter {
		@Override
		public void mouseClicked(MouseEvent e) {
			int saveOption = -1;
			while (saveOption == -1) {
				saveOption = handleSave();
			}
		}
	}

	/**
	 * Handles the saving of the data.
	 */
	private int handleSave() {
		// Get data type to save as
		FileFormatDialog dialog = new FileFormatDialog(frame, MessageConstants.SAVE_DATA_TYPE_Q);
		int option = dialog.showDialog();
		switch (option) {
		case 1:
			return saveHEDXMLDialog(option);
		case 2:
			return saveTSVDialog(option);
		case 3:
			return saveTaggerDataXMLDialog(option);
		default:
			dialog.dispose();
			return 0;
		}
	}

	/**
	 * Checks if the file save was successful.
	 * 
	 * @param option
	 *            The dialog option.
	 * @param saveFile
	 *            The file selected from the file chooser.
	 * @param saveSuccess
	 *            True if the file was saved successful, false if otherwise.
	 * @return -1 if a file was not selected or save failed, a different value
	 *         if otherwise.
	 */
	private int checkSaveSuccess(int option, File saveFile, boolean saveSuccess) {
		if (saveFile == null) {
			return -1;
		}
		if (!saveSuccess) {
			AppView.this.showTaggerMessageDialog(MessageConstants.SAVE_ERROR, "Okay", null, null);
			return -1;
		}
		return option;
	}

	/**
	 * Checks if the file load was successful.
	 * 
	 * @param option
	 *            The dialog option.
	 * @param loadFile
	 *            The file selected from the file chooser.
	 * @param loadSuccess
	 *            True if the file was loaded successful, false if otherwise.
	 * @return -1 if a file was not selected or load failed, a different value
	 *         if otherwise.
	 */
	private int checkLoadSuccess(int option, File loadFile, boolean loadSuccess) {
		if (loadFile == null)
			return -1;
		if (!loadSuccess) {
			AppView.this.showTaggerMessageDialog(MessageConstants.LOAD_ERROR, "Okay", null, null);
			return -1;
		}
		refreshPanels();
		return option;
	}

	/**
	 * Shows a file chooser to select a Tagger Data XML file.
	 * 
	 * @param option
	 *            The dialog option.
	 * @return The file returned from the file chooser.
	 */
	public int saveTaggerDataXMLDialog(int option) {
		boolean saveSuccess = true;
		File saveFile = showFileChooserDialog("Save Combined events + HED XML", "Save", "Save .xml file", "XML files",
				new String[] { "xml" });
		if (saveFile != null) {
			saveFile = addExtensionToFile(saveFile, "xml");
			saveSuccess = tagger.saveEventsAndHED(saveFile);
		}
		return checkSaveSuccess(option, saveFile, saveSuccess);
	}

	/**
	 * Shows a file chooser to select a Tagger Data XML file.
	 * 
	 * @param option
	 *            The dialog option.
	 * @return The file returned from the file chooser.
	 */
	public int loadTaggerDataXMLDialog(int option) {
		boolean loadSuccess = true;
		File loadFile = showFileChooserDialog("Load Combined events + HED XML", "Load", "Load .xml file", "XML files",
				new String[] { "xml" });
		if (loadFile != null)
			loadSuccess = tagger.loadEventsAndHED(loadFile);
		return checkLoadSuccess(option, loadFile, loadSuccess);
	}

	/**
	 * Shows a file chooser to select a HED XML file.
	 * 
	 * @param option
	 *            The dialog option.
	 * @return The file returned from the file chooser.
	 */
	public int saveHEDXMLDialog(int option) {
		boolean saveSuccess = true;
		File saveFile = showFileChooserDialog("Save HED XML", "Save", "Save .xml file", "XML files",
				new String[] { "xml" });
		if (saveFile != null) {
			saveFile = addExtensionToFile(saveFile, "xml");
			saveSuccess = tagger.saveHED(saveFile);
		}
		return checkLoadSuccess(option, saveFile, saveSuccess);
	}

	/**
	 * Shows a file chooser to select a Tagger Data XML file.
	 * 
	 * @param option
	 *            The dialog option.
	 * @return The file returned from the file chooser.
	 */
	public int loadHEDXMLDialog(int option) {
		boolean loadSuccess = true;
		File loadFile = showFileChooserDialog("Load HED XML", "Load", "Load .xml file", "XML files",
				new String[] { "xml" });
		if (loadFile != null)
			loadSuccess = tagger.loadHED(loadFile);
		return checkLoadSuccess(option, loadFile, loadSuccess);
	}

	/**
	 * Shows a file chooser to select a tab-delimited file.
	 * 
	 * @param option
	 *            The dialog option.
	 * @return The file returned from the file chooser.
	 */
	public int saveTSVDialog(int option) {
		boolean saveSuccess = true;
		File saveFile = showFileChooserDialog("Save Events, tab-delimited text", "Save", "Save .tsv file", "TSV files",
				new String[] { "tsv" });
		if (saveFile != null) {
			saveFile = addExtensionToFile(saveFile, "tsv");
			saveSuccess = tagger.saveTSVFile(saveFile);
		}
		return checkSaveSuccess(option, saveFile, saveSuccess);
	}

	/**
	 * Adds a specified extension to a file.
	 * 
	 * @param file
	 * @param extension
	 * @return
	 */
	private File addExtensionToFile(File file, String extension) {
		File fileWithExtension = new File(file.getAbsolutePath() + "." + extension);
		return fileWithExtension;
	}

	/**
	 * Shows a file chooser to select a Tagger Data XML file.
	 * 
	 * @param option
	 *            The dialog option.
	 * @return The file returned from the file chooser.
	 */
	public int loadTSVDialog(int option) {
		boolean loadSuccess = true;
		File loadFile = showFileChooserDialog("Load Events, tab-delimited text", "Load", "Load .tsv file", "TSV files",
				new String[] { "tsv", "txt" });
		if (loadFile != null) {
			String[] tabSeparatedOptions = showTabSeparatedOptions();
			if (tabSeparatedOptions.length == 3)
				loadSuccess = tagger.loadTabDelimitedEvents(loadFile, Integer.parseInt(tabSeparatedOptions[0].trim()),
						StringToIntArray(tabSeparatedOptions[1]), StringToIntArray(tabSeparatedOptions[2]));
		}
		return checkLoadSuccess(option, loadFile, loadSuccess);
	}

	/**
	 * This class represents the undo and redo buttons.
	 * 
	 */
	private class UndoRedoButton extends XButton implements MouseListener {

		String hoverText;
		boolean undo;

		public UndoRedoButton(String textArg, boolean undo) {
			super(textArg);
			this.undo = undo;
			setNormalBackground(FontsAndColors.MENU_NORMAL_BG);
			setNormalForeground(FontsAndColors.MENU_NORMAL_FG);
			setHoverBackground(FontsAndColors.MENU_HOVER_BG);
			setHoverForeground(FontsAndColors.MENU_HOVER_FG);
			setPressedBackground(FontsAndColors.MENU_PRESSED_BG);
			setPressedForeground(FontsAndColors.MENU_PRESSED_FG);
		}

		@Override
		public Font getFont() {
			return FontsAndColors.headerFont;
		}

		/**
		 * Performs the undo/redo action when the button is clicked.
		 */
		@Override
		public void mouseClicked(MouseEvent e) {
			super.mouseClicked(e);
			HistoryItem item = null;
			if (undo) {
				item = tagger.undo();
			} else {
				item = tagger.redo();
			}
			updateEgt();
			updateTags();
			hoverText = undo ? tagger.getUndoMessage() : tagger.getRedoMessage();
			hoverMessage.setText(hoverText);
			if (item != null) {
				historyScroll(item);
			}
		}

		private void historyScroll(HistoryItem item) {
			switch (item.type) {
			case ASSOCIATED:
				scrollToEventTag((GuiTagModel) item.tagModel);
				break;
			case EVENT_ADDED:
				scrollToEvent(item.event);
				break;
			case EVENT_EDITED:
				scrollToEvent(item.event);
				break;
			case EVENT_REMOVED:
				scrollToEvent(item.event);
				break;
			case GROUP_ADDED:
				scrollToEventGroup(item.event);
				break;
			case TAG_ADDED:
				scrollToTag(item.tagModel);
				break;
			case TAG_EDITED:
				scrollToTag(item.tagModel);
				break;
			case TAG_PATH_EDITED:
				scrollToEventTag((GuiTagModel) item.tagModel);
				break;
			case UNASSOCIATED:
				scrollToEventTag((GuiTagModel) item.tagModel);
				break;
			default:
				break;
			}
		}

		/**
		 * Shows the appropriate message when the mouse hovers over the button
		 */
		@Override
		public void mouseEntered(MouseEvent e) {
			super.mouseEntered(e);
			hoverText = undo ? tagger.getUndoMessage() : tagger.getRedoMessage();
			hoverMessage.setText(hoverText);
			Point point = this.getLocation();
			int top = point.y + 50;
			int right = AppView.this.getWidth() - point.x - 120;
			setTopHeight(hoverMessage, top, Unit.PX, 25.0, Unit.PX);
			setRightWidth(hoverMessage, right, Unit.PX, 120.0, Unit.PX);
			hoverMessage.setVisible(true);
		}

		@Override
		public void mouseExited(MouseEvent e) {
			super.mouseExited(e);
			hoverMessage.setVisible(false);
		}
	}

	public static XButton createMenuButton(String text) {
		XButton button = new XButton(text) {
			@Override
			public Font getFont() {
				return FontsAndColors.headerFont;
			}
		};
		button.setNormalBackground(FontsAndColors.MENU_NORMAL_BG);
		button.setNormalForeground(FontsAndColors.MENU_NORMAL_FG);
		button.setHoverBackground(FontsAndColors.MENU_HOVER_BG);
		button.setHoverForeground(FontsAndColors.MENU_HOVER_FG);
		button.setPressedBackground(FontsAndColors.MENU_PRESSED_BG);
		button.setPressedForeground(FontsAndColors.MENU_PRESSED_FG);

		return button;
	}

	private Loader loader;
	private Tagger tagger;

	private JFrame frame;
	private JComponent shield = new JComponent() {
	};

	private JLabel eventsTitle = new JLabel("Events") {
		@Override
		public Font getFont() {
			return FontsAndColors.headerFont;
		}
	};
	private XButton addEvent = new XButton("add event") {
		@Override
		public Font getFont() {
			return FontsAndColors.headerFont;
		}
	};

	private XButton deselectAll = new XButton("deselect all") {
		@Override
		public Font getFont() {
			return FontsAndColors.headerFont;
		}
	};

	private XButton addGroup = new XButton("add group") {
		@Override
		public Font getFont() {
			return FontsAndColors.headerFont;
		}
	};

	private XButton addTag = new XButton("add tag") {
		@Override
		public Font getFont() {
			return FontsAndColors.headerFont;
		}
	};
	private JComponent eventsPanel = new JComponent() {
	};
	private JLayeredPane eventsScrollPane = new JLayeredPane();
	private JLabel tagsTitle = new JLabel("Tags") {
		@Override
		public Font getFont() {
			return FontsAndColors.headerFont;
		}
	};
	private XScrollTextBox searchTags = new XScrollTextBox(new XTextBox()) {
		@Override
		public Font getFont() {
			return FontsAndColors.contentFont;
		}
	};
	private JPanel searchResults = new JPanel() {
		@Override
		protected void paintComponent(Graphics g) {
			Graphics2D g2d = (Graphics2D) g;
			g2d.setColor(Color.white);
			g2d.fill(new Rectangle2D.Double(0, 0, getWidth(), getHeight()));
			g2d.setColor(new Color(200, 200, 200));
			g2d.draw(new Line2D.Double(6, 0, 6, getHeight() - 5));
		}
	};
	private JPanel tagsPanel = new JPanel();
	private JLabel hoverMessage = new JLabel();

	private ScrollLayout tagsScrollLayout;

	private JLayeredPane tagsScrollPane = new JLayeredPane();
	private ContextMenu contextMenu;

	private ConstraintContainer splitPaneLeft = new ConstraintContainer();
	private ConstraintContainer splitPaneRight = new ConstraintContainer();

	private XButton okay = createMenuButton("okay");
	private XButton exit = createMenuButton("exit");
	private XButton undo = new UndoRedoButton("undo", true);

	private XButton redo = new UndoRedoButton("redo", false);
	// private JFileChooser fileChooser = new JFileChooser();
	private XButton load = createMenuButton("load");

	private XButton save = createMenuButton("save");
	private XButton zoomOut = createMenuButton("-");
	private JLabel zoomPercent = new JLabel("100%", JLabel.CENTER) {
		@Override
		public Font getFont() {
			return FontsAndColors.contentFont;
		}
	};
	private XButton zoomIn = createMenuButton("+");

	/**
	 * Creates a collapse level label.
	 */
	private JLabel collapseLabel = new JLabel("level", JLabel.CENTER) {
		@Override
		public Font getFont() {
			return FontsAndColors.headerFont;
		}
	};

	/**
	 * Creates a collapse level text box.
	 */
	private XScrollTextBox collapseLevel = new XScrollTextBox(new XTextBox()) {
		@Override
		public Font getFont() {
			return FontsAndColors.contentFont;
		}
	};

	/**
	 * Creates a collapse button.
	 */
	private XButton collapseAll = new XButton("collapse") {
		@Override
		public Font getFont() {
			return FontsAndColors.headerFont;
		}
	};

	/**
	 * Creates a expand button.
	 */
	private XButton expandAll = new XButton("expand") {
		@Override
		public Font getFont() {
			return FontsAndColors.headerFont;
		}
	};

	private Notification notification = new Notification();

	private boolean autoCollapse = true;

	private int autoCollapseDepth;

	Set<Integer> selectedGroups = new HashSet<Integer>();

	/**
	 * Constructor creates the GUI and sets up functionality of the buttons
	 * displayed.
	 * 
	 * @param loader
	 * @param tagger
	 * @param frameTitle
	 */
	public AppView(Loader loader, final Tagger tagger, String frameTitle, boolean isStandAloneVersion) {
		this.loader = loader;
		this.tagger = tagger;

		autoCollapseDepth = loader.getInitialDepth();
		createGui(isStandAloneVersion);

		frame.setTitle(frameTitle);

		okay.addMouseListener(new MouseAdapter() {
			@Override
			public void mouseClicked(MouseEvent e) {
				List<EventModel> missingReqTags = tagger.findMissingRequiredTags();
				boolean exit = true;
				if (missingReqTags != null && !missingReqTags.isEmpty()) {
					exit = AppView.this.showRequiredMissingDialog(missingReqTags);
				}
				if (exit) {
					AppView.this.loader.setSubmitted(true);
					if (tagger.hedEdited()) {
						ExitSaveDialog dialog = new ExitSaveDialog(frame, MessageConstants.HED_XML_SAVE_Q);
						int option = dialog.showDialog();
						if (option == 0)
							saveHEDXMLDialog(option);
					}
					frame.dispatchEvent(new WindowEvent(frame, WindowEvent.WINDOW_CLOSING));
				}
			}
		});
		exit.addMouseListener(new MouseAdapter() {
			@Override
			public void mouseClicked(MouseEvent e) {
				if (tagger.hedEdited()) {
					ExitSaveDialog dialog = new ExitSaveDialog(frame, MessageConstants.HED_XML_SAVE_Q);
					int option = dialog.showDialog();
					if (option == 0)
						saveHEDXMLDialog(option);
				}
				AppView.this.loader.setSubmitted(false);
				frame.dispatchEvent(new WindowEvent(frame, WindowEvent.WINDOW_CLOSING));

			}
		});
		load.addMouseListener(new LoadMouseListener());
		save.addMouseListener(new SaveMouseListener());
		zoomOut.addMouseListener(new MouseAdapter() {
			@Override
			public void mouseClicked(MouseEvent e) {
				ConstraintLayout.scale -= 0.1;
				FontsAndColors.resizeFonts(ConstraintLayout.scale);
				zoomPercent.setText((int) (ConstraintLayout.scale * 100) + "%");
			}
		});
		zoomIn.addMouseListener(new MouseAdapter() {
			@Override
			public void mouseClicked(MouseEvent e) {
				ConstraintLayout.scale += 0.1;
				FontsAndColors.resizeFonts(ConstraintLayout.scale);
				zoomPercent.setText((int) (ConstraintLayout.scale * 100) + "%");
			}
		});

		deselectAll.addMouseListener(new MouseAdapter() {
			@Override
			public void mouseClicked(MouseEvent e) {
				selectedGroups.clear();
				updateEgt();
			}
		});

		addGroup.addMouseListener(new MouseAdapter() {
			@Override
			public void mouseClicked(MouseEvent e) {
				Set<Integer> newSelectedGroups = tagger.addNewGroups(selectedGroups);
				if (newSelectedGroups.size() > 0) {
					selectedGroups.clear();
					selectedGroups.addAll(newSelectedGroups);
				}
				updateEgt();
			}
		});

		collapseLevel.getJTextArea().getDocument().addDocumentListener(new DocumentListener() {
			@Override
			public void changedUpdate(DocumentEvent e) {
			}

			@Override
			public void insertUpdate(DocumentEvent e) {
				if (!collapseLevel.getJTextArea().getText().isEmpty()) {
					int level = 0;
					try {
						level = Integer.parseInt(collapseLevel.getJTextArea().getText());
					} catch (NumberFormatException ex) {
					}
					if (level > 0) {
						autoCollapseDepth = level;
						autoCollapse = true;
						updateTags();
					}
				}
			}

			@Override
			public void removeUpdate(DocumentEvent e) {
				if (!collapseLevel.getJTextArea().getText().isEmpty()) {
					int level = 0;
					try {
						level = Integer.parseInt(collapseLevel.getJTextArea().getText());
					} catch (NumberFormatException ex) {
					}
					if (level > 0) {
						autoCollapseDepth = level;
						autoCollapse = true;
						updateTags();
					}
				}
			}
		});
		collapseAll.addMouseListener(new MouseAdapter() {
			@Override
			public void mouseClicked(MouseEvent e) {
				ScrollLayout layout = (ScrollLayout) tagsScrollPane.getLayout();
				layout.scrollTo(0);
				autoCollapseDepth = 1;
				autoCollapse = true;
				collapseLevel.getJTextArea().setText(Integer.toString(autoCollapseDepth));
				updateTags();
			}
		});
		expandAll.addMouseListener(new MouseAdapter() {
			@Override
			public void mouseClicked(MouseEvent e) {
				ScrollLayout layout = (ScrollLayout) tagsScrollPane.getLayout();
				layout.scrollTo(0);
				autoCollapseDepth = tagger.getTagLevel();
				autoCollapse = true;
				collapseLevel.getJTextArea().setText(Integer.toString(autoCollapseDepth));
				updateTags();
			}
		});

		notification.getToggleDetailsButton().addMouseListener(new MouseAdapter() {
			@Override
			public void mouseClicked(MouseEvent e) {
				if (notification.getToggleDetailsButton().getText().equals("hide details")) {
					notification.getToggleDetailsButton().setText("show details");
					setTopHeight(notification, 10.0, Unit.PX, 30.0, Unit.PX);
					setLeftRight(notification, 305.0, Unit.PX, 245.0, Unit.PX);
				} else if (notification.getToggleDetailsButton().getText().equals("show details")) {
					notification.getToggleDetailsButton().setText("hide details");
					double detailsHeight = notification.getDetails().getLineCount()
							* FontsAndColors.BASE_CONTENT_FONT.getSize2D() + 20;
					setTopHeight(notification, 10.0, Unit.PX, 30.0 + detailsHeight, Unit.PX);
				}
			}
		});
		notification.getHideButton().addMouseListener(new MouseAdapter() {
			@Override
			public void mouseClicked(MouseEvent e) {
				notification.setVisible(false);
			}
		});

		addEvent.addMouseListener(new MouseAdapter() {
			@Override
			public void mouseClicked(MouseEvent e) {
				TaggedEvent event = tagger.addNewEvent(new String(), new String());
				event.setInEdit(true);
				event.setInFirstEdit(true);
				updateEgt();
				selectedGroups.clear();
				selectedGroups.add(event.getEventGroupId());
				AppView.this.scrollToEvent(event);
			}
		});
		addTag.addMouseListener(new MouseAdapter() {
			@Override
			public void mouseClicked(MouseEvent e) {
				AbstractTagModel newTag = tagger.addNewTag(null, new String());
				GuiTagModel newGuiTag = (GuiTagModel) newTag;
				if (newGuiTag != null) {
					newGuiTag.setFirstEdit(true);
					updateTags();
					AppView.this.scrollToTag(newTag);
				}
			}
		});
		searchTags.getJTextArea().getDocument().addDocumentListener(new DocumentListener() {
			@Override
			public void changedUpdate(DocumentEvent e) {
			}

			@Override
			public void insertUpdate(DocumentEvent e) {
				updateSearch();
			}

			@Override
			public void removeUpdate(DocumentEvent e) {
				updateSearch();
			}
		});

	}

	/**
	 * Cancels the search, causing any search items displayed to disappear.
	 */
	public void cancelSearch() {
		searchTags.getJTextArea().setText(new String());
	}

	/**
	 * Creates the GUI for the application and makes it visible. Updates the tag
	 * and event panels with information from the Tagger.
	 */
	public void createGui(boolean isStandAloneVersion) {

		setLayout(new ConstraintLayout());
		setOpaque(true);
		setBackground(FontsAndColors.APP_BG);

		zoomPercent.setFont(FontsAndColors.contentFont);
		zoomPercent.setForeground(FontsAndColors.GREY_DARK);

		eventsScrollPane.setLayout(new ScrollLayout(eventsScrollPane, eventsPanel));
		tagsPanel.setBackground(Color.WHITE);
		tagsScrollLayout = new ScrollLayout(tagsScrollPane, tagsPanel);
		tagsScrollPane.setLayout(tagsScrollLayout);

		eventsTitle.setForeground(FontsAndColors.GREY_VERY_VERY_DARK);
		tagsTitle.setForeground(FontsAndColors.GREY_VERY_VERY_DARK);

		addEvent.setNormalBackground(FontsAndColors.TRANSPARENT);
		addEvent.setNormalForeground(FontsAndColors.GREY_MEDIUM);
		addEvent.setHoverBackground(FontsAndColors.TRANSPARENT);
		addEvent.setHoverForeground(Color.BLACK);
		addEvent.setPressedBackground(FontsAndColors.TRANSPARENT);
		addEvent.setPressedForeground(FontsAndColors.GREY_MEDIUM);

		deselectAll.setNormalBackground(FontsAndColors.TRANSPARENT);
		deselectAll.setNormalForeground(FontsAndColors.GREY_MEDIUM);
		deselectAll.setHoverBackground(FontsAndColors.TRANSPARENT);
		deselectAll.setHoverForeground(Color.BLACK);
		deselectAll.setPressedBackground(FontsAndColors.TRANSPARENT);
		deselectAll.setPressedForeground(FontsAndColors.GREY_MEDIUM);

		addGroup.setNormalBackground(FontsAndColors.TRANSPARENT);
		addGroup.setNormalForeground(FontsAndColors.GREY_MEDIUM);
		addGroup.setHoverBackground(FontsAndColors.TRANSPARENT);
		addGroup.setHoverForeground(Color.BLACK);
		addGroup.setPressedBackground(FontsAndColors.TRANSPARENT);
		addGroup.setPressedForeground(FontsAndColors.GREY_MEDIUM);

		addTag.setNormalBackground(FontsAndColors.TRANSPARENT);
		addTag.setNormalForeground(FontsAndColors.GREY_MEDIUM);
		addTag.setHoverBackground(FontsAndColors.TRANSPARENT);
		addTag.setHoverForeground(Color.BLACK);
		addTag.setPressedBackground(FontsAndColors.TRANSPARENT);
		addTag.setPressedForeground(FontsAndColors.GREY_MEDIUM);

		searchTags.getJTextArea().getDocument().putProperty("filterNewlines", Boolean.TRUE);
		searchTags.getJTextArea().getInputMap().put(KeyStroke.getKeyStroke("ENTER"), "doNothing");
		searchTags.getJTextArea().getInputMap().put(KeyStroke.getKeyStroke("TAB"), "doNothing");
		searchTags.getJTextArea().setText("search for tags ...");

		searchTags.getJTextArea().addFocusListener(new FocusListener() {
			@Override
			public void focusGained(FocusEvent e) {
				searchTags.getJTextArea().selectAll();
			}

			@Override
			public void focusLost(FocusEvent e) {
				searchResults.setVisible(false);
			}
		});

		searchResults.setBackground(Color.WHITE);
		searchResults.setBorder(new DropShadowBorder());
		searchResults.setLayout(new ListLayout(1, 1, 0, 1));

		JLayeredPane splitContainer = new JLayeredPane();
		VerticalSplitLayout splitLayout = new VerticalSplitLayout(splitContainer, splitPaneLeft, splitPaneRight, 400);
		splitContainer.setLayout(splitLayout);

		collapseLabel.setBackground(FontsAndColors.TRANSPARENT);
		collapseLabel.setForeground(FontsAndColors.GREY_MEDIUM);

		collapseAll.setNormalBackground(FontsAndColors.TRANSPARENT);
		collapseAll.setNormalForeground(FontsAndColors.GREY_MEDIUM);
		collapseAll.setHoverBackground(FontsAndColors.TRANSPARENT);
		collapseAll.setHoverForeground(Color.BLACK);
		collapseAll.setPressedBackground(FontsAndColors.TRANSPARENT);
		collapseAll.setPressedForeground(FontsAndColors.GREY_MEDIUM);

		expandAll.setNormalBackground(FontsAndColors.TRANSPARENT);
		expandAll.setNormalForeground(FontsAndColors.GREY_MEDIUM);
		expandAll.setHoverBackground(FontsAndColors.TRANSPARENT);
		expandAll.setHoverForeground(Color.BLACK);
		expandAll.setPressedBackground(FontsAndColors.TRANSPARENT);
		expandAll.setPressedForeground(FontsAndColors.GREY_MEDIUM);

		collapseLevel.getJTextArea().setText(Integer.toString(loader.getInitialDepth()));
		collapseLevel.getJTextArea().getDocument().putProperty("filterNewlines", Boolean.TRUE);

		splitPaneLeft.add(eventsTitle, new Constraint("top:0 height:50 left:10 width:100"));
		splitPaneLeft.add(addEvent, new Constraint("top:0 height:50 right:10 width:115"));
		splitPaneLeft.add(deselectAll, new Constraint("top:50 height:30 left:10 width:150"));
		splitPaneLeft.add(addGroup, new Constraint("top:50 height:30 right:20 width:150"));
		splitPaneLeft.add(eventsScrollPane, new Constraint("top:85 bottom:0 left:0 right:5"));

		splitPaneRight.add(tagsTitle, new Constraint("top:0 height:50 left:5 width:100"));
		splitPaneRight.add(searchTags, new Constraint("top:12 height:26 left:90 right:100"));
		splitPaneRight.add(searchResults, new Constraint("top:40 height:0 left:90 right:0"));
		splitPaneRight.add(addTag, new Constraint("top:12 height:26 right:0 width:80"));
		splitPaneRight.setLayer(searchResults, 1);
		splitPaneRight.add(collapseAll, new Constraint("top:52 height:30 left:85 width:100"));
		splitPaneRight.add(expandAll, new Constraint("top:52 height:30 left:215 width:100"));
		splitPaneRight.add(collapseLabel, new Constraint("top:50 height:30 left:315 width:115"));
		splitPaneRight.add(collapseLevel, new Constraint("top:48 height:30 left:415 width:30"));
		splitPaneRight.add(tagsScrollPane, new Constraint("top:85 bottom:0 left:5 right:0"));

		if (!isStandAloneVersion) {
			add(okay, new Constraint("top:0 height:50 left:10 width:55"));
			okay.setHoverForeground(Color.BLACK);
			add(exit, new Constraint("top:0 height:50 left:70 width:80"));
			exit.setHoverForeground(Color.BLACK);
			add(load, new Constraint("top:0 height:50 left:175 width:55"));
			load.setHoverForeground(Color.BLACK);
			add(save, new Constraint("top:0 height:50 left:235 width:80"));
			save.setHoverForeground(Color.BLACK);
		} else {
			add(exit, new Constraint("top:0 height:50 left:10 width:55"));
			exit.setHoverForeground(Color.BLACK);
			add(load, new Constraint("top:0 height:50 left:70 width:80"));
			load.setHoverForeground(Color.BLACK);
			add(save, new Constraint("top:0 height:50 left:175 width:55"));
			save.setHoverForeground(Color.BLACK);
		}
		add(undo, new Constraint("top:0 height:50 right:180 width:60"));
		undo.setHoverForeground(Color.BLACK);
		add(redo, new Constraint("top:0 height:50 right:120 width:60"));
		redo.setHoverForeground(Color.BLACK);
		add(zoomOut, new Constraint("top:0 height:50 right:80 width:30"));
		zoomOut.setHoverForeground(Color.BLACK);
		add(zoomPercent, new Constraint("top:0 height:50 right:30 width:50"));
		add(zoomIn, new Constraint("top:0 height:50 right:0 width:30"));
		zoomIn.setHoverForeground(Color.BLACK);
		add(splitContainer, new Constraint("top:60 bottom:10 left:10 right:10"));

		tagsPanel.setLayout(new ListLayout(1, 1, 0, 1));
		eventsPanel.setLayout(new ConstraintLayout());

		add(notification, new Constraint("top:10 height:30 left:305 right:245"));
		setLayer(notification, 1);
		notification.setVisible(false);

		hoverMessage.setBackground(FontsAndColors.LIGHT_YELLOW);
		hoverMessage.setOpaque(true);
		hoverMessage.setHorizontalAlignment(SwingConstants.CENTER);
		add(hoverMessage);
		setLayer(hoverMessage, 2);
		hoverMessage.setVisible(false);

		add(shield);
		setLayer(shield, 2);
		shield.setVisible(false);
		shield.addMouseListener(new MouseAdapter() {
			@Override
			public void mouseClicked(MouseEvent e) {
				hideContextMenu();
			}
		});

		frame = new JFrame() {
			@Override
			public void dispose() {
				loader.setNotified(true);
				super.dispose();
			}
		};
		frame.setDefaultCloseOperation(JFrame.DISPOSE_ON_CLOSE);
		frame.setSize(1024, 768);
		frame.getContentPane().add(this);
		frame.setVisible(true);

		updateTags();
		updateEgt();
	}

	/**
	 * Hides the context menu on the screen.
	 */
	public void hideContextMenu() {
		shield.remove(contextMenu);
		shield.setVisible(false);
	}

	/**
	 * Updates the set of groups selected for adding tags to include only groups
	 * that exist in the EGT set.
	 */
	private void pruneSelectedGroups() {
		Iterator<Integer> iter = selectedGroups.iterator();
		while (iter.hasNext()) {
			Integer groupId = iter.next();
			boolean found = false;
			for (TaggedEvent currentTaggedEvent : tagger.getEgtSet()) {
				if (currentTaggedEvent.containsGroup(groupId)) {
					found = true;
					break;
				}
			}
			if (!found) {
				iter.remove();
			}
		}
	}

	/**
	 * Scrolls to the position of the tag in the tags panel, if it exists. If
	 * the tag is null, it displays a notification that the tag is not in the
	 * hierarchy.
	 * 
	 * @param tag
	 */
	public void scrollToTag(AbstractTagModel tag) {
		int offset = 100;
		ScrollLayout layout = (ScrollLayout) tagsScrollPane.getLayout();
		updateNotification(null, null);
		AbstractTagModel parent = tagger.getTagModel(tag.getParentPath() + "/#");
		AbstractTagModel extensionAllowedAncestor = tagger.getExtensionAllowedAncestor(tag.getPath());
		GuiTagModel gtm = null;
		if (extensionAllowedAncestor != null) {
			gtm = (GuiTagModel) extensionAllowedAncestor;
		} else if (parent != null && parent.takesValue()) {
			gtm = (GuiTagModel) parent;
		} else {
			gtm = (GuiTagModel) tag;
		}
		expandToLevel(gtm.getDepth());
		TagView tagView = gtm.getTagView();
		int y = Math.max(0, tagView.getY() - offset);
		layout.scrollTo(y);
		tagView.highlight();
	}

	public void expandToLevel(int depth) {
		if (Integer.valueOf(collapseLevel.getJTextArea().getText()) < depth) {
			autoCollapseDepth = depth;
			autoCollapse = true;
			collapseLevel.getJTextArea().setText(Integer.toString(autoCollapseDepth));
			updateTags();
		}
	}

	public void scrollToLastSelectedGroup() {
		int offset = 100;
		Iterator<Integer> selectedGroupsIterator = selectedGroups.iterator();
		int lastSelectedGroup = 0;
		while (selectedGroupsIterator.hasNext()) {
			lastSelectedGroup = selectedGroupsIterator.next().intValue();
		}
		ScrollLayout layout = (ScrollLayout) eventsScrollPane.getLayout();
		updateNotification(null, null);
		TaggedEvent event = tagger.getTaggedEventFromGroupId(lastSelectedGroup);
		if (event.getEventGroupId() != lastSelectedGroup) {
			GroupView groupView = event.getGroupViewByKey(lastSelectedGroup);
			int y = Math.max(0, groupView.getY() - offset);
			layout.scrollTo(y);
			groupView.highlight();
		} else {
			EventView groupView = event.getEventView();
			int y = Math.max(0, groupView.getY() - offset);
			layout.scrollTo(y);
			groupView.highlight();
		}

	}

	public void scrollToEventTag(GuiTagModel tag) {
		if (selectedGroups.size() > 0) {
			int offset = 100;
			int lastSelectedGroup = Collections.max(selectedGroups);
			ScrollLayout layout = (ScrollLayout) eventsScrollPane.getLayout();
			updateNotification(null, null);
			TaggedEvent event = tagger.getTaggedEventFromGroupId(lastSelectedGroup);
			if (event.isRRTagDescendant(tag)) {
				AbstractTagModel rrTag = event.findRRParentTag(tag);
				RRTagView rrTagView = event.getRRTagViewByKey(rrTag);
				TagEventView tagEgtView = rrTagView.getTagEgtViewByKey(tag);
				if (rrTagView != null) {
					int y = Math.max(0, rrTagView.getY() - offset);
					layout.scrollTo(y);
					if (tagEgtView != null)
						tagEgtView.highlight();
				}
			} else if (event.getEventGroupId() != lastSelectedGroup) {
				GroupView groupView = event.getGroupViewByKey(lastSelectedGroup);
				TagEventView tagEgtView = groupView.getTagEgtViewByKey(tag);
				if (groupView != null) {
					int y = Math.max(0, groupView.getY() - offset);
					layout.scrollTo(y);
					if (tagEgtView != null)
						tagEgtView.highlight();
				}
			} else {
				TagEventView tagEgtView = event.getTagEgtViewByKey(tag);
				if (tagEgtView != null) {
					int y = Math.max(0, tagEgtView.getY() - offset);
					layout.scrollTo(y);
					tagEgtView.highlight();
				}
			}
		}
	}

	public void scrollToEvent(TaggedEvent event) {
		int offset = 100;
		ScrollLayout layout = (ScrollLayout) eventsScrollPane.getLayout();
		updateNotification(null, null);
		EventView eventView = event.getEventView();
		int y = Math.max(0, eventView.getY() - offset);
		layout.scrollTo(y);
		eventView.highlight();
	}

	public void scrollToEventGroup(TaggedEvent event) {
		int offset = event.getEventView().getHeight() + event.findNumberOfTagsInEvents() * 27;
		ScrollLayout layout = (ScrollLayout) eventsScrollPane.getLayout();
		updateNotification(null, null);
		int y = Math.max(0, event.getEventView().getY() + offset);
		layout.scrollTo(y);
	}

	public void scrollToNewGroup(TaggedEvent event, int groupId) {
		int offset = event.getEventView().getHeight() + event.findNumberOfTagsInEvents() * 27;
		ScrollLayout layout = (ScrollLayout) eventsScrollPane.getLayout();
		updateNotification(null, null);
		GroupView groupView = event.getGroupViewByKey(Integer.valueOf(groupId));
		int y = Math.max(0, groupView.getY() - offset);
		layout.scrollTo(y);
		groupView.highlight();
	}

	/**
	 * Shows a dialog for the user to enter basic event information (code and
	 * label) and has the tagger create this event.
	 */
	public void showAddEventDialog() {
		AddEventDialog dialog = new AddEventDialog(frame);
		String[] eventFields = dialog.showDialog();
		if (eventFields != null) {
			TaggedEvent event = tagger.addNewEvent(eventFields[0], eventFields[1]);
			updateEgt();
			if (event == null) {
				showTaggerMessageDialog(MessageConstants.ADD_EVENT_ERROR, "Okay", null, null);
			} else {
				ScrollLayout eventScrollLayout = (ScrollLayout) eventsScrollPane.getLayout();
				eventScrollLayout.scrollTo(event.getEventView().getCurrentPosition());
			}
		}
	}

	/**
	 * Shows a dialog to handle toggling a tag when ancestor tags are present.
	 * If the user chooses to replace these ancestor tags, it removes the
	 * ancestor tags in the tagger and toggles the tag again.
	 * 
	 * @param message
	 */
	public void showAncestorDialog(ToggleTagMessage message) {
		TagDisplayDialog dialog = new TagDisplayDialog(frame, message.ancestors, MessageConstants.ANCESTOR,
				MessageConstants.REPLACE_TAGS_Q, true, "Replace", "Warning");
		boolean replace = dialog.showDialog();
		if (replace) {
			// Remove ancestor tags
			for (EventModel ancestor : message.ancestors) {
				Set<Integer> tagIds = new HashSet<Integer>();
				tagIds.add(ancestor.getGroupId());
				tagger.unassociate(ancestor.getTagModel(), tagIds);
			}
			// Toggle tag again
			tagger.toggleTag(message.tagModel, message.groupIds);
		}
	}

	/**
	 * Shows a context menu with the given options on the screen. The menu
	 * appears where the mouse was clicked. Uses the default width of 100.
	 * 
	 * @param map
	 *            Map of option names and actions
	 */
	public void showContextMenu(Map<String, ContextMenuAction> map) {
		showContextMenu(map, 100);
	}

	/**
	 * Shows a context menu with the given options and width on the screen. The
	 * menu appears where the mouse was clicked.
	 * 
	 * @param map
	 *            Map of option names and actions
	 * @param width
	 *            Width on the screen
	 */
	public void showContextMenu(Map<String, ContextMenuAction> map, int width) {
		Point mousePoint = MouseInfo.getPointerInfo().getLocation();
		shield.setVisible(true);
		Point shieldPoint = shield.getLocationOnScreen();
		contextMenu = new ContextMenu(this, map);
		shield.add(contextMenu);
		int contextMenuHeight = contextMenu.getPreferredSize().height;
		int contextMenuWidth = (int) (ConstraintLayout.scale * width);
		int x = mousePoint.x - shieldPoint.x;
		int y = mousePoint.y - shieldPoint.y;
		if (y + contextMenuHeight > shield.getHeight()) {
			y -= contextMenuHeight;
		}
		if (x + contextMenuWidth > shield.getWidth()) {
			x -= contextMenuWidth;
		}
		contextMenu.setLocation(x, y);
		contextMenu.setSize(contextMenuWidth, contextMenuHeight);
	}

	/**
	 * Shows a dialog to handle toggling a tag when descendant tags are present.
	 * It displays all of the descendant tags present in the selected groups and
	 * identifies which event and group they are in.
	 * 
	 * @param message
	 */
	public void showDescendantDialog(ToggleTagMessage message) {
		TagDisplayDialog dialog = new TagDisplayDialog(frame, message.descendants, MessageConstants.DESCENDANT, null,
				false, "Okay", "Warning");
		dialog.showDialog();
	}

	/**
	 * Shows a file chooser dialog with the given message.
	 * 
	 * @param message
	 * @return The File chosen, or null if no file was chosen.
	 */
	public File showFileChooserDialog(String dialogTitle, String approveButton, String approveButtonToolTip,
			String fileExtensionType, String[] fileExtenstions) {
		JFileChooser fileChooser = new JFileChooser();
		fileChooser.setDialogTitle(dialogTitle);
		fileChooser.setApproveButtonText(approveButton);
		fileChooser.setApproveButtonToolTipText(approveButtonToolTip);
		FileFilter imageFilter = new FileNameExtensionFilter(fileExtensionType, fileExtenstions);
		fileChooser.setFileFilter(imageFilter);
		int returnVal = fileChooser.showOpenDialog(frame);
		if (returnVal == JFileChooser.APPROVE_OPTION) {
			File file = fileChooser.getSelectedFile();
			return file;
		}
		return null;
	}

	/**
	 * Shows a dialog with a message containing required tags that are missing
	 * from events.
	 * 
	 * @param missingReqTags
	 * @return True if the user chooses to exit anyway, and false if the user
	 *         chooses cancel.
	 */
	public boolean showRequiredMissingDialog(List<EventModel> missingReqTags) {
		TagDisplayDialog dialog = new TagDisplayDialog(frame, missingReqTags, MessageConstants.MISSING_REQUIRED,
				MessageConstants.EXIT_Q, true, "Okay", "Warning");
		return dialog.showDialog();
	}

	/**
	 * Shows a tab separated option dialog
	 * 
	 * @return A string array containing the header lines, event code column,
	 *         and the tag column
	 */
	public String[] showTabSeparatedOptions() {
		JTextField field1 = new JTextField("1");
		JTextField field2 = new JTextField("1");
		JTextField field3 = new JTextField("2");
		JPanel panel = new JPanel(new GridLayout(0, 1));
		panel.add(new JLabel("Header Lines:"));
		panel.add(field1);
		panel.add(new JLabel("Event Code Column(s):"));
		panel.add(field2);
		panel.add(new JLabel("Tag Column(s):"));
		panel.add(field3);
		String[] tabSeparatedOptions = {};
		boolean validInput = false;
		int result = 0;
		while (!validInput) {
			result = JOptionPane.showConfirmDialog(null, panel, "Tab Separated Options", JOptionPane.OK_CANCEL_OPTION,
					JOptionPane.PLAIN_MESSAGE);
			validInput = validateTabSeparatedOptions(result, field1.getText(), field2.getText(), field3.getText());
		}
		if (result == JOptionPane.OK_OPTION) {
			tabSeparatedOptions = new String[] { field1.getText(), field2.getText(), field3.getText() };
			return tabSeparatedOptions;
		}
		return tabSeparatedOptions;
	}

	/**
	 * Shows a dialog used for choosing a tag from a subset of the hierarchy.
	 * 
	 * @param baseTag
	 *            The tag at the base of the sub-hierarchy to show
	 * @return The tag model for the tag chosen, or null if no tag was chosen.
	 */
	public AbstractTagModel showTagChooserDialog(AbstractTagModel baseTag) {
		TaggerSet<AbstractTagModel> tags = tagger.getSubHierarchy(baseTag.getPath());
		TagChooserDialog dialog = new TagChooserDialog(frame, this, tagger, tags);
		AbstractTagModel result = dialog.showDialog();
		updateTags();
		updateEgt();
		return result;
	}

	/**
	 * Shows a message dialog with the given message and options setting.
	 * 
	 * @param message
	 *            The message for the dialog to display.
	 * @param options
	 *            Whether the dialog should present options. True if it should
	 *            present "okay" and "cancel," false if it should present only
	 *            "okay"
	 * @return True if the user chooses "okay," false if the user chooses
	 *         "cancel"
	 */
	/**
	 * Shows a message dialog with the given message and options for the user to
	 * choose.
	 * 
	 * @param message
	 *            Message to display to user
	 * @param opt0
	 *            Option a user can choose
	 * @param opt1
	 *            Option a user can choose (may be null)
	 * @param opt2
	 *            Option a user can choose (may be null)
	 * @return The option the user chose (0, 1, or 2), or -1 if no option was
	 *         chosen
	 */
	public int showTaggerMessageDialog(String message, String opt0, String opt1, String opt2) {
		TaggerMessageDialog dialog = new TaggerMessageDialog(frame, message, opt0, opt1, opt2);
		return dialog.showDialog();
	}

	/**
	 * Shows a dialog to handle toggling a tag when unique tag values are
	 * present. It displays all of the unique tags present in the selected
	 * groups and identifies which event and group they are in.
	 * 
	 * @param message
	 */
	public void showUniqueDialog(ToggleTagMessage message) {
		String text = MessageConstants.UNIQUE + message.uniqueKey.getPath() + ":";
		TagDisplayDialog dialog = new TagDisplayDialog(frame, message.uniqueValues, text, null, false, "Okay",
				"Warning");
		dialog.showDialog();
	}

	/**
	 * Converts a comma separated string of numbers into a integer array
	 * 
	 * @param str
	 *            comma separated string of numbers
	 * @return a integer array
	 */
	private int[] StringToIntArray(String str) {
		String[] strArray = str.split(",");
		int[] intArray = new int[strArray.length];
		for (int i = 0; i < strArray.length; i++) {
			intArray[i] = Integer.parseInt(strArray[i].trim());
		}
		return intArray;
	}

	/**
	 * Updates the EGT panel with the information currently represented by the
	 * tagger.
	 */
	public void updateEgt() {
		pruneSelectedGroups();
		eventsPanel.removeAll();
		int top = 0;
		for (TaggedEvent taggedEvent : tagger.getEgtSet()) {
			taggedEvent.setAppView(this);
			EventView ev = taggedEvent.getEventView();
			ev.setGroupId(taggedEvent.getEventGroupId());
			if (selectedGroups.contains(taggedEvent.getEventGroupId())) {
				ev.setSelected(true);
			} else {
				ev.setSelected(false);
			}
			eventsPanel.add(ev,
					new Constraint("top:" + top + " height:30 left:0 width:" + (eventsPanel.getWidth() - 15)));
			ev.setCurrentPosition(top);
			top += 31;
			if (taggedEvent.isInEdit()) {
				EventEditView eev = taggedEvent.getEventEditView();
				eev.update();
				eventsPanel.add(eev, new Constraint("top:" + top + " height:" + EventEditView.HEIGHT));
				top += EventEditView.HEIGHT;
			}
			if (tagger.isPrimary() && taggedEvent.showInfo() && tagger.hasRRTags()) {
				// Show required/recommended tags
				for (AbstractTagModel tag : tagger.getRequiredTags()) {
					RRTagView rrtv = taggedEvent.getRRTagView(tag);
					taggedEvent.addRRTagView(tag, rrtv);
					int size = rrtv.getConstraintHeight();
					eventsPanel.add(rrtv, new Constraint("top:" + top + " height:" + size));
					top += size;
				}
				for (AbstractTagModel tag : tagger.getRecommendedTags()) {
					RRTagView rrtv = taggedEvent.getRRTagView(tag);
					taggedEvent.addRRTagView(tag, rrtv);
					int size = rrtv.getConstraintHeight();
					eventsPanel.add(rrtv, new Constraint("top:" + top + " height:" + size));
					top += size;
				}
				JSeparator separator = new JSeparator();
				separator.setForeground(Color.black);
				separator.setBackground(Color.black);
				eventsPanel.add(separator, new Constraint("top:" + top + " height:1 left:15 right:20"));
				top += 5;
			}
			// Show other tags
			for (Map.Entry<Integer, TaggerSet<AbstractTagModel>> tagGroup : taggedEvent.getTagGroups().entrySet()) {
				// Show tag group
				if (tagGroup.getKey() != taggedEvent.getEventGroupId()) {
					Integer groupId = tagGroup.getKey();
					GroupView groupView = new GroupView(tagger, this, groupId);
					taggedEvent.addGroupView(groupView);
					if (selectedGroups.contains(groupId)) {
						groupView.setSelected(true);
					}
					Integer numTagsInGroup = taggedEvent.getNumTagsInGroup(groupId);
					if (numTagsInGroup == 0) {
						eventsPanel.add(groupView, new Constraint("top:" + top + " height:27 left:0 width:30"));
						top += 27;
					} else {
						eventsPanel.add(groupView,
								new Constraint("top:" + top + " height:" + numTagsInGroup * 27 + " left:0 width:30"));
					}
				}
				TaggerSet<AbstractTagModel> tags = tagGroup.getValue();
				for (AbstractTagModel tag : tags) {
					if (tagGroup.getKey() != taggedEvent.getEventGroupId() || !tagger.isRRValue(tag)
							|| !tagger.isPrimary()) {
						GuiTagModel guiTagModel = (GuiTagModel) tag;
						guiTagModel.setAppView(this);
						guiTagModel.updateMissing();
						TagEventView tagEgtView = guiTagModel.getTagEgtView(tagGroup.getKey());
						GroupView groupView = taggedEvent.getGroupViewByKey(tagGroup.getKey());
						if (groupView == null) {
							taggedEvent.addTagEgtView(tag, tagEgtView);
						} else {
							groupView.addTagEgtView(tag, tagEgtView);
						}
						eventsPanel.add(tagEgtView, new Constraint("top:" + top + " height:26 left:30 right:0"));
						top += 27;
						if (guiTagModel.isInEdit()) {
							TagEventEditView teev = guiTagModel.getTagEgtEditView(taggedEvent);
							teev.setAppView(this);
							teev.update();
							eventsPanel.add(teev, new Constraint(
									"top:" + top + " height:" + TagEventEditView.HEIGHT + " left:30 right:0"));
							top += TagEventEditView.HEIGHT;
						}
					}
				}
			}
		}
		eventsPanel.validate();
		eventsPanel.repaint();
		eventsScrollPane.validate();
		eventsScrollPane.repaint();
		validate();
		repaint();
	}

	public void repaintEventsPanel() {
		eventsPanel.validate();
		eventsPanel.repaint();
	}

	/**
	 * Updates the notification at the top of the GUI the the given preview and
	 * details
	 * 
	 * @param preview
	 *            Short message to display in notification
	 * @param details
	 *            Details to display when the notification is expanded
	 */
	public void updateNotification(String preview, String details) {
		notification.setVisible(preview != null);
		notification.setPreviewText(preview);
		notification.setDetailsText(details);
	}

	/**
	 * Updates the search items displayed to match the current text in the
	 * search bar.
	 */
	private void updateSearch() {
		searchResults.removeAll();
		Set<GuiTagModel> tagModels = tagger.getSearchTags(searchTags.getJTextArea().getText());
		if (tagModels == null || tagModels.isEmpty()) {
			searchResults.setVisible(false);
			return;
		}
		for (GuiTagModel tag : tagModels) {
			searchResults.add(tag.getTagSearchView());
		}
		searchResults.revalidate();
		splitPaneRight.setTopHeight(searchResults, 40.0, Unit.PX,
				searchResults.getPreferredSize().getHeight() / ConstraintLayout.scale, Unit.PX);
		searchResults.setVisible(true);
	}

	/**
	 * Updates the tags panel with the information currently represented by the
	 * tagger.
	 */
	public void updateTags() {
		tagger.updateTagHighlights(true);
		searchResults.setVisible(false);
		tagsPanel.removeAll();
		String lastVisibleTagPath = null;
		for (AbstractTagModel tagModel : tagger.getTagSet()) {
			GuiTagModel guiTagModel = (GuiTagModel) tagModel;
			guiTagModel.setAppView(this);
			guiTagModel.setCollapsable(tagger.hasChildTags(guiTagModel));
			if (guiTagModel.isCollapsable() && autoCollapse) {
				guiTagModel.setCollapsed(guiTagModel.getDepth() > autoCollapseDepth);
			}
			if (lastVisibleTagPath != null && tagModel.getPath().startsWith(lastVisibleTagPath)) {
				continue;
			}
			lastVisibleTagPath = guiTagModel.isCollapsed() ? guiTagModel.getPath() : null;
			guiTagModel.getTagView().update();
			tagsPanel.add(guiTagModel.getTagView());
			if (guiTagModel.isInEdit()) {
				guiTagModel.getTagEditView().update();
				tagsPanel.add(guiTagModel.getTagEditView());
			}
			if (guiTagModel.isInAddValue()) {
				tagsPanel.add(guiTagModel.getAddValueView());
			}
		}
		tagsPanel.validate();
		tagsPanel.repaint();
		tagsScrollPane.validate();
		tagsScrollPane.repaint();
		validate();
		repaint();
		autoCollapse = false;
	}

	public void repaintTagsScrollPane() {
		tagsScrollPane.repaint();
	}

	public void repaintEventsScrollPane() {
		eventsScrollPane.repaint();
	}

	/**
	 * Validates the tab separated options
	 * 
	 * @param result
	 *            the result returned from the dialog
	 * @param headerLines
	 *            the number of header lines in the file
	 * @param eventCodeColumn
	 *            the event code column in the file
	 * @param TagColumn
	 *            the tag column in the file
	 * @return true if the arguments are valid, false if otherwise
	 */
	public boolean validateTabSeparatedOptions(int result, String headerLines, String eventCodeColumn,
			String TagColumn) {
		String message = new String();
		if (!headerLines.trim().matches("\\s*[0-9]+"))
			message += "* header lines must be a single number greater than or equal to 0\n";
		if (!eventCodeColumn.trim().matches("\\s*[1-9][0-9]*(\\s*,\\s*[1-9][0-9]*)*"))
			message += "* event code column must be a single number greater than or equal to 1 or a comma-separted list of numbers\n";
		if (!TagColumn.trim().matches("0") && !TagColumn.trim().matches("\\s*[1-9][0-9]*(\\s*,\\s*[1-9][0-9]*)*"))
			message += "* tag column must be a single number greater than or equal to 0 or a comma-separted list of numbers\n";
		if (result == JOptionPane.OK_OPTION && !message.isEmpty()) {
			JOptionPane.showMessageDialog(null, "Error(s):\n" + message);
			return false;
		}
		return true;
	}
}
