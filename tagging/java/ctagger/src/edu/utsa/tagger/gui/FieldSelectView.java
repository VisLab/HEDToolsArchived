package edu.utsa.tagger.gui;

import java.awt.BorderLayout;
import java.awt.Component;
import java.awt.Dimension;
import java.awt.Insets;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;
import java.util.ArrayList;
import java.util.List;

import javax.swing.Box;
import javax.swing.BoxLayout;
import javax.swing.DefaultListModel;
import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JList;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.ListModel;
import javax.swing.SwingConstants;
import javax.swing.border.EmptyBorder;
import javax.swing.event.ListSelectionEvent;
import javax.swing.event.ListSelectionListener;

import edu.utsa.tagger.FieldSelectLoader;

/**
 * This class creates a GUI that allows the user to select which fields to
 * exclude or tag.
 * 
 * @author Jeremy Cockfield, Kay Robbins
 *
 */
@SuppressWarnings("serial")
public class FieldSelectView extends JPanel {

	private boolean isTagBox = false;
	private JLabel descriptionLabel = new JLabel(
			"Please select which event fields to tag or exclude. Set a primary field if there is one. The primary field requires a label, category, and a description.",
			SwingConstants.CENTER);
	JLabel primaryFieldLabel = new JLabel("Primary field: ", SwingConstants.CENTER);
	private JPanel parentPanel = new JPanel(new BorderLayout());
	private JPanel northPanel = new JPanel(new BorderLayout());
	private JPanel centerPanel = new JPanel(new BorderLayout());
	private JPanel southPanel = new JPanel(new BorderLayout());
	private JLabel tagBoxLabel = new JLabel("Tag fields");
	private JLabel excludeBoxLabel = new JLabel("Exclude fields");
	private JList<String> tagListBox;
	private JList<String> excludeListBox;
	private JButton removeButton = new JButton("<< Remove");
	private JButton addButton = new JButton("Add >>");
	private JButton removeAllButton = new JButton("<< Remove all");
	private JButton moveUpButton = new JButton("Move up");
	private JButton moveDownButton = new JButton("Move down");
	private JButton addAllButton = new JButton("Add all >>");
	private JButton setPrimaryButton = new JButton("Set as primary");
	private JButton removePrimaryButton = new JButton("Remove primary");
	private JButton cancelButton = new JButton("Cancel");
	private JButton okayButton = new JButton("Okay");
	private String primaryField = new String();
	private JFrame jFrame = new JFrame();
	private FieldSelectLoader loader;
	private String frameTitle;

	/**
	 * 
	 * @param loader
	 *            A FieldSelectLoader loader object.
	 * @param frameTitle
	 *            The title of the frame.
	 * @param excluded
	 *            An array of strings containing the excluded fields.
	 * @param tagged
	 *            An array of strings containing the tagged fields.
	 */
	public FieldSelectView(FieldSelectLoader loader, String frameTitle, String[] excluded, String[] tagged) {
		this.loader = loader;
		this.frameTitle = frameTitle;
		excludeListBox = new JList<String>(excluded);
		tagListBox = new JList<String>(tagged);
		layoutComponents(excluded, tagged);
	}

	/**
	 * Layout the components of the GUI.
	 * 
	 * @param excluded
	 *            An array of strings containing the excluded fields.
	 * @param tagged
	 *            An array of strings containing the tagged fields.
	 */
	private void layoutComponents(String[] excluded, String[] tagged) {
		setListeners();
		northPanel.add(descriptionLabel);
		centerPanel.add(createPanelForListBoxWithLabel(excludeListBox, excludeBoxLabel, addAllButton),
				BorderLayout.WEST);
		centerPanel.add(createCenterPanelButtons(), BorderLayout.CENTER);
		centerPanel.add(createPanelForListBoxWithLabel(tagListBox, tagBoxLabel, removeAllButton), BorderLayout.EAST);
		southPanel.add(createSouthPanel());
		parentPanel.add(northPanel, BorderLayout.NORTH);
		parentPanel.add(centerPanel, BorderLayout.CENTER);
		parentPanel.add(southPanel, BorderLayout.SOUTH);
		createFrame(parentPanel);
	}

	/**
	 * Creates a JFrame and adds a parent panel to it.
	 * 
	 * @param parentPanel
	 *            The parent panel that is added to the JFrame.
	 */
	private void createFrame(JPanel parentPanel) {
		jFrame.add(parentPanel);
		jFrame.setTitle(frameTitle);
		jFrame.pack();
		jFrame.setLocationRelativeTo(null);
		jFrame.setVisible(true);
		jFrame.setDefaultCloseOperation(JFrame.DO_NOTHING_ON_CLOSE);
	}

	/**
	 * Creates the south panel.
	 * 
	 * @return A JPanel that is added to the south region of the parent panel.
	 */
	private JPanel createSouthPanel() {
		JPanel buttonPanel = new JPanel(new BorderLayout());
		buttonPanel.add(Box.createRigidArea(new Dimension(350, 50)));
		buttonPanel.add(primaryFieldLabel, BorderLayout.WEST);
		buttonPanel.add(createSouthPanelButtons(), BorderLayout.EAST);
		return buttonPanel;
	}

	/**
	 * Creates the south panel buttons.
	 * 
	 * @return A button JPanel that is added to the south region of the parent
	 *         panel.
	 */
	private JPanel createSouthPanelButtons() {
		JPanel buttonPanel = new JPanel();
		buttonPanel.add(cancelButton);
		buttonPanel.add(Box.createRigidArea(new Dimension(10, 0)));
		Dimension d = cancelButton.getMaximumSize();
		okayButton.setMaximumSize(new Dimension(d));
		buttonPanel.add(okayButton);
		return buttonPanel;
	}

	/**
	 * Creates the center panel buttons.
	 * 
	 * @return A button JPanel that is added to the center region of the parent
	 *         panel.
	 */
	private JPanel createCenterPanelButtons() {
		JPanel buttonPanel = new JPanel();
		buttonPanel.setLayout(new BoxLayout(buttonPanel, BoxLayout.Y_AXIS));
		Dimension d = removePrimaryButton.getMaximumSize();
		addButton.setMaximumSize(new Dimension(d));
		buttonPanel.add(Box.createRigidArea(new Dimension(0, 30)));
		addButton.setAlignmentX(Component.CENTER_ALIGNMENT);
		addButton.setAlignmentY(Component.CENTER_ALIGNMENT);
		buttonPanel.add(addButton);
		removeButton.setMaximumSize(new Dimension(d));
		buttonPanel.add(Box.createRigidArea(new Dimension(0, 30)));
		removeButton.setAlignmentX(Component.CENTER_ALIGNMENT);
		removeButton.setAlignmentY(Component.CENTER_ALIGNMENT);
		buttonPanel.add(removeButton);
		moveUpButton.setMaximumSize(new Dimension(d));
		buttonPanel.add(Box.createRigidArea(new Dimension(0, 30)));
		moveUpButton.setAlignmentX(Component.CENTER_ALIGNMENT);
		moveUpButton.setAlignmentY(Component.CENTER_ALIGNMENT);
		buttonPanel.add(Box.createHorizontalGlue());
		buttonPanel.add(moveUpButton);
		moveDownButton.setMaximumSize(new Dimension(d));
		buttonPanel.add(Box.createRigidArea(new Dimension(0, 30)));
		moveDownButton.setAlignmentX(Component.CENTER_ALIGNMENT);
		moveDownButton.setAlignmentY(Component.CENTER_ALIGNMENT);
		buttonPanel.add(moveDownButton);
		setPrimaryButton.setMaximumSize(new Dimension(d));
		buttonPanel.add(Box.createRigidArea(new Dimension(0, 30)));
		setPrimaryButton.setAlignmentX(Component.CENTER_ALIGNMENT);
		setPrimaryButton.setAlignmentY(Component.CENTER_ALIGNMENT);
		buttonPanel.add(setPrimaryButton);
		removePrimaryButton.setMaximumSize(new Dimension(d));
		buttonPanel.add(Box.createRigidArea(new Dimension(0, 30)));
		removePrimaryButton.setAlignmentX(Component.CENTER_ALIGNMENT);
		buttonPanel.add(removePrimaryButton);
		return buttonPanel;
	}

	/**
	 * Sets the listeners for all of the components.
	 */
	private void setListeners() {
		removeButton.addActionListener(new addRemoveListener());
		addButton.addActionListener(new addRemoveListener());
		removeAllButton.addActionListener(new removeAddAllListener());
		addAllButton.addActionListener(new removeAddAllListener());
		moveUpButton.addActionListener(new moveUpDownListener());
		moveDownButton.addActionListener(new moveUpDownListener());
		setPrimaryButton.addActionListener(new setPrimaryListener());
		removePrimaryButton.addActionListener(new removePrimaryListener());
		tagListBox.addListSelectionListener(new SharedListSelectionHandler());
		excludeListBox.addListSelectionListener(new SharedListSelectionHandler());
		cancelButton.addActionListener(new cancelOkayListener());
		okayButton.addActionListener(new cancelOkayListener());
		jFrame.addWindowListener(new frameWindowListener());
	}

	/**
	 * Creates a JPanel that holds a list box.
	 * 
	 * @param listBox
	 *            The list box that is added to the panel.
	 * @param listBoxLabel
	 *            The label of the list box.
	 * @param jButton
	 *            The button to transfer all of the elements in the list box to
	 *            the other list box.
	 * @return
	 */
	private JPanel createPanelForListBoxWithLabel(JList<String> listBox, JLabel listBoxLabel, JButton jButton) {
		JPanel panel = new JPanel(new BorderLayout(0, 3));
		listBox.setVisibleRowCount(20);
		panel.add(listBoxLabel, BorderLayout.NORTH);
		JScrollPane scrollPaneForListBox = new JScrollPane(listBox);
		scrollPaneForListBox.setPreferredSize(new Dimension(200, 400));
		panel.setBorder(new EmptyBorder(new Insets(10, 40, 30, 40)));
		panel.add(scrollPaneForListBox, BorderLayout.CENTER);
		panel.add(jButton, BorderLayout.SOUTH);
		return panel;
	}

	/**
	 * Updates the primary field label.
	 */
	private void updatePrimaryField() {
		primaryFieldLabel.setText("Primary field: " + primaryField);
	}

	/**
	 * Transfers the selected elements in one JList to another.
	 * 
	 * @param jList1
	 *            The JList that the selected elements are transferred from.
	 * @param jList2
	 *            The JList that the selected elements from the other JList are
	 *            transferred to.
	 */
	private void transferFromBoxes(JList<String> jList1, JList<String> jList2) {
		int[] selectedIndexes = jList1.getSelectedIndices();
		List<Integer> indexes = new ArrayList<Integer>();
		for (int value : selectedIndexes) {
			indexes.add(value);
		}
		if (indexes.isEmpty())
			return;
		addElements(jList1, jList2, indexes);
		removeElements(jList1, indexes);
	}

	/**
	 * Transfers all elements in one JList to another.
	 * 
	 * @param jList1
	 *            The JList that all elements are transferred from.
	 * @param jList2
	 *            The JList that all the elements from the other JList are
	 *            transferred to.
	 */
	private void transferAllFromBoxes(JList<String> jList1, JList<String> jList2) {
		addAllElements(jList1, jList2);
		removeAllElements(jList1);
	}

	/**
	 * Moves up the selected elements in a JList.
	 * 
	 * @param jList
	 *            The JList whose selected elements are moved up.
	 */
	private void moveUpElements(JList<String> jList) {
		int[] selectedIndexes = jList.getSelectedIndices();
		List<Integer> indexes = new ArrayList<Integer>();
		for (int value : selectedIndexes) {
			indexes.add(value);
		}
		if (indexes.isEmpty())
			return;
		shiftUpElements(jList, indexes);
	}

	/**
	 * Moves down the selected elements in a JList.
	 * 
	 * @param jList
	 *            The JList whose selected elements are moved down.
	 */
	private void moveDownElements(JList<String> jList) {
		int[] selectedIndexes = jList.getSelectedIndices();
		List<Integer> indexes = new ArrayList<Integer>();
		for (int value : selectedIndexes) {
			indexes.add(value);
		}
		if (indexes.isEmpty())
			return;
		shiftDownElements(jList, indexes);
	}

	/**
	 * Shift the elements up one position in the JList.
	 * 
	 * @param jList
	 *            The JList whose elements are shifted up one position.
	 * @param indices
	 *            The indices whose elements are shifted up one position.
	 */
	private void shiftUpElements(JList<String> jList, List<Integer> indexes) {
		DefaultListModel<String> model = new DefaultListModel<String>();
		ListModel<String> lm = jList.getModel();
		List<Integer> newIndecies = new ArrayList<Integer>();
		int numElements = lm.getSize();
		int numIndexes = indexes.size();
		int start = 0;
		for (int i = 0; i < numElements; i++) {
			model.addElement(lm.getElementAt(i));
		}
		for (int i = 0; i < numIndexes; i++) {
			if (indexes.get(i) - 1 >= 0 && indexes.get(i) != start) {
				swapElements(model, indexes.get(i), indexes.get(i) - 1);
				newIndecies.add(indexes.get(i) - 1);
			} else {
				start++;
				newIndecies.add(indexes.get(i));
			}
		}
		jList.setModel(model);
		jList.setSelectedIndices(integerToInt(newIndecies));
	}

	/**
	 * Shift the elements down one position in the JList.
	 * 
	 * @param jList
	 *            The JList whose elements are shifted down one position.
	 * @param indices
	 *            The indices whose elements are shifted down one position.
	 */
	private void shiftDownElements(JList<String> jList, List<Integer> indices) {
		DefaultListModel<String> model = new DefaultListModel<String>();
		ListModel<String> lm = jList.getModel();
		List<Integer> newIndecies = new ArrayList<Integer>();
		int numElements = lm.getSize();
		int numIndexes = indices.size();
		int finish = numElements - 1;
		for (int i = 0; i < numElements; i++) {
			model.addElement(lm.getElementAt(i));
		}
		for (int i = numIndexes - 1; i >= 0; i--) {
			if (indices.get(i) + 1 <= numElements - 1 && indices.get(i) != finish) {
				swapElements(model, indices.get(i), indices.get(i) + 1);
				newIndecies.add(indices.get(i) + 1);
			} else {
				finish--;
				newIndecies.add(indices.get(i));
			}
		}
		jList.setModel(model);
		jList.setSelectedIndices(integerToInt(newIndecies));
	}

	/**
	 * Swap two indices in a DefaultListModel.
	 * 
	 * @param defaultListModel
	 *            The DefaultListModel that the two indices are swapped.
	 * @param firstIndex
	 *            The first index.
	 * @param secondIndex
	 *            The second index.
	 */
	private void swapElements(DefaultListModel<String> defaultListModel, int firstIndex, int secondIndex) {
		String oldElement = defaultListModel.getElementAt(firstIndex);
		String newElement = defaultListModel.getElementAt(secondIndex);
		defaultListModel.remove(firstIndex);
		defaultListModel.add(firstIndex, newElement);
		defaultListModel.remove(secondIndex);
		defaultListModel.add(secondIndex, oldElement);
	}

	/**
	 * Converts a Integer List to a integer array.
	 * 
	 * @param integers
	 *            A Integer List.
	 * @return A integer array.
	 */
	private int[] integerToInt(List<Integer> integers) {
		int[] ints = new int[integers.size()];
		int i = 0;
		for (int value : integers) {
			ints[i] = value;
			i++;
		}
		return ints;
	}

	/**
	 * Removes the indices from the JList.
	 * 
	 * @param jList
	 *            The JList that the indices are removed from.
	 * @param indices
	 *            The indices in the JList that are removed.
	 */
	private void removeElements(JList<String> jList, List<Integer> indices) {
		DefaultListModel<String> model = new DefaultListModel<String>();
		ListModel<String> lm = jList.getModel();
		int numElements = lm.getSize();
		for (int i = 0; i < numElements; i++) {
			if (!indices.contains(i)) {
				model.addElement(lm.getElementAt(i));
			}
		}
		jList.setModel(model);
	}

	/**
	 * Removes all of the elements from a JList.
	 * 
	 * @param jList
	 *            The JList that all of the elements are removed from.
	 */
	private void removeAllElements(JList<String> jList) {
		DefaultListModel<String> model = new DefaultListModel<String>();
		jList.setModel(model);
	}

	/**
	 * Adds the selected elements from one JList to another JList.
	 * 
	 * @param jList1
	 *            The JList that the selected elements are transferred from.
	 * @param jList2
	 *            The JList that the selected elements from the other JList are
	 *            transferred to.
	 */
	private void addElements(JList<String> jList1, JList<String> jList2, List<Integer> indexes) {
		DefaultListModel<String> model = new DefaultListModel<String>();
		ListModel<String> lm1 = jList1.getModel();
		ListModel<String> lm2 = jList2.getModel();
		int numElements = lm2.getSize();
		for (int i = 0; i < numElements; i++)
			model.addElement(lm2.getElementAt(i));
		for (int value : indexes)
			model.addElement(lm1.getElementAt(value));
		jList2.setModel(model);
	}

	/**
	 * Adds all of the elements from one JList to another JList.
	 * 
	 * @param jList1
	 *            The JList that all of the elements are transferred from.
	 * @param jList2
	 *            The JList that all of the elements from the other JList are
	 *            transferred to.
	 */
	private void addAllElements(JList<String> jList1, JList<String> jList2) {
		DefaultListModel<String> model = new DefaultListModel<String>();
		ListModel<String> lm1 = jList1.getModel();
		ListModel<String> lm2 = jList2.getModel();
		int numElements2 = lm2.getSize();
		int numElements1 = lm1.getSize();
		for (int i = 0; i < numElements2; i++)
			model.addElement(lm2.getElementAt(i));
		for (int i = 0; i < numElements1; i++)
			model.addElement(lm1.getElementAt(i));
		jList2.setModel(model);
	}

	/**
	 * The action listener class for the JList list boxes.
	 */
	public class SharedListSelectionHandler implements ListSelectionListener {
		@Override
		public void valueChanged(ListSelectionEvent e) {
			@SuppressWarnings("unchecked")
			JList<String> sourceList = (JList<String>) e.getSource();
			if (sourceList.getValueIsAdjusting()) {
				if (sourceList == tagListBox) {
					isTagBox = true;
					excludeListBox.clearSelection();
				} else {
					isTagBox = false;
					tagListBox.clearSelection();
				}
			}
		}
	}

	/**
	 * The action listener class for the Remove and Add buttons.
	 */
	public class addRemoveListener implements ActionListener {
		public void actionPerformed(ActionEvent e) {
			JButton sourceButton = (JButton) e.getSource();
			if (sourceButton == removeButton && isTagBox) {
				int currentSize = excludeListBox.getModel().getSize();
				transferFromBoxes(tagListBox, excludeListBox);
				int newSize = excludeListBox.getModel().getSize();
				int[] selectedIndexes = createArrayFromRange(currentSize, newSize);
				excludeListBox.setSelectedIndices(selectedIndexes);
				updatePrimaryField();
			} else if (sourceButton == addButton && !isTagBox) {
				int currentSize = tagListBox.getModel().getSize();
				transferFromBoxes(excludeListBox, tagListBox);
				int newSize = tagListBox.getModel().getSize();
				int[] selectedIndexes = createArrayFromRange(currentSize, newSize);
				tagListBox.setSelectedIndices(selectedIndexes);
				updatePrimaryField();
			}
		}
	}

	/**
	 * The action listener class for the Remove all and Add all buttons.
	 */
	public class removeAddAllListener implements ActionListener {
		public void actionPerformed(ActionEvent e) {
			JButton sourceButton = (JButton) e.getSource();
			if (sourceButton == removeAllButton) {
				int currentSize = excludeListBox.getModel().getSize();
				transferAllFromBoxes(tagListBox, excludeListBox);
				int newSize = excludeListBox.getModel().getSize();
				int[] selectedIndexes = createArrayFromRange(currentSize, newSize);
				excludeListBox.setSelectedIndices(selectedIndexes);
				primaryField = new String();
				updatePrimaryField();
			} else {
				int currentSize = tagListBox.getModel().getSize();
				transferAllFromBoxes(excludeListBox, tagListBox);
				int newSize = tagListBox.getModel().getSize();
				int[] selectedIndexes = createArrayFromRange(currentSize, newSize);
				tagListBox.setSelectedIndices(selectedIndexes);
				updatePrimaryField();
			}
		}
	}

	/**
	 * Creates a integer array containing elements between a range.
	 * 
	 * @param start
	 *            The start of the range.
	 * @param end
	 *            The end of the range.
	 * @return The integer array containing the elements between the range.
	 */
	private int[] createArrayFromRange(int start, int end) {
		int numElements = end - start;
		int[] array = new int[numElements];
		for (int i = 0; i < numElements; i++) {
			array[i] = start++;
		}
		return array;
	}

	/**
	 * The action listener class for the Cancel and Okay buttons.
	 */
	public class setPrimaryListener implements ActionListener {
		public void actionPerformed(ActionEvent e) {
			JButton sourceButton = (JButton) e.getSource();
			if (sourceButton == setPrimaryButton && isTagBox) {
				String selectedValue = tagListBox.getSelectedValue();
				if (selectedValue != null) {
					primaryField = selectedValue;
					updatePrimaryField();
				}
			} else {
				String selectedValue = excludeListBox.getSelectedValue();
				if (selectedValue != null) {
					isTagBox = true;
					primaryField = selectedValue;
					int primaryFieldIndex = excludeListBox.getSelectedIndex();
					excludeListBox.setSelectedIndex(primaryFieldIndex);
					transferFromBoxes(excludeListBox, tagListBox);
					tagListBox.setSelectedIndex(tagListBox.getModel().getSize() - 1);
					updatePrimaryField();
				}
			}
		}
	}

	/**
	 * The action listener class for the Move up and Move down buttons.
	 */
	public class moveUpDownListener implements ActionListener {
		public void actionPerformed(ActionEvent e) {
			JButton sourceButton = (JButton) e.getSource();
			if (sourceButton == moveUpButton && isTagBox) {
				moveUpElements(tagListBox);
				updatePrimaryField();
			} else if (sourceButton == moveUpButton && !isTagBox) {
				moveUpElements(excludeListBox);
				updatePrimaryField();
			} else if (sourceButton == moveDownButton && isTagBox) {
				moveDownElements(tagListBox);
				updatePrimaryField();
			} else if (sourceButton == moveDownButton && !isTagBox) {
				moveDownElements(excludeListBox);
				updatePrimaryField();
			}
		}
	}

	/**
	 * The action listener class for the Cancel and Okay buttons.
	 */
	public class cancelOkayListener implements ActionListener {
		public void actionPerformed(ActionEvent e) {
			JButton sourceButton = (JButton) e.getSource();
			if (sourceButton == cancelButton) {
				loader.setNotified(true);
				jFrame.dispose();
			} else {
				loader.setNotified(true);
				loader.setSubmitted(true);
				jFrame.dispose();
			}

		}
	}

	/**
	 * The action listener class for the Remove primary button.
	 */
	public class removePrimaryListener implements ActionListener {
		public void actionPerformed(ActionEvent e) {
			primaryField = new String();
			updatePrimaryField();
		}
	}

	/**
	 * A dialog that asks if the user would like to cancel the FieldSelectView.
	 * 
	 * @param message
	 *            The message that is displayed in the dialog.
	 * @return 0 if the FieldSelctView should be canceled, 1 if otherwise.
	 */
	private int createYesNoDialog(String message) {
		YesNoDialog dialog = new YesNoDialog(jFrame, message);
		int option = dialog.showDialog();
		if (option == 0) {
			loader.setNotified(true);
			jFrame.dispose();
		}
		return option;
	}

	/**
	 * The frame window listener class for the close button.
	 */
	public class frameWindowListener extends WindowAdapter {
		public void windowClosing(WindowEvent evt) {
			String message = MessageConstants.CANCEL_Q;
			createYesNoDialog(message);
		}
	}

}