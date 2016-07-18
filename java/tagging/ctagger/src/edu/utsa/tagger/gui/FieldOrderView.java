package edu.utsa.tagger.gui;

import java.awt.BorderLayout;
import java.awt.Color;
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
import javax.swing.DefaultListCellRenderer;
import javax.swing.DefaultListModel;
import javax.swing.ImageIcon;
import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JList;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.ListModel;
import javax.swing.SwingConstants;
import javax.swing.border.EmptyBorder;
import javax.swing.plaf.basic.BasicArrowButton;

import edu.utsa.tagger.FieldOrderLoader;

/**
 * This class creates a GUI that allows the user to select which fields to
 * exclude or tag.
 * 
 * @author Jeremy Cockfield, Kay Robbins
 *
 */
@SuppressWarnings("serial")
public class FieldOrderView extends JPanel {

	private JLabel descriptionLabel = new JLabel("", SwingConstants.CENTER);
	private JPanel parentPanel = new JPanel(new BorderLayout());
	private JList<String> fieldListBox;
	private JButton cancelButton = new JButton("Cancel");
	private JButton okayButton = new JButton("Okay");
	private JFrame jFrame = new JFrame();
	private FieldOrderLoader loader;
	private String frameTitle;
	private BasicArrowButton upButton = new BasicArrowButton(BasicArrowButton.NORTH);
	private BasicArrowButton downButton = new BasicArrowButton(BasicArrowButton.SOUTH);

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
	public FieldOrderView(FieldOrderLoader loader, String frameTitle, String[] fields) {
		this.loader = loader;
		this.frameTitle = frameTitle;
		fieldListBox = intializeJList(fields);
		DefaultListCellRenderer renderer = (DefaultListCellRenderer) fieldListBox.getCellRenderer();
		renderer.setHorizontalAlignment(JLabel.CENTER);
		layoutComponents(fields);
	}

	/**
	 * Initializes a JList.
	 * 
	 * @param elements
	 *            The elements that is used to initialize a JList.
	 */
	private JList<String> intializeJList(String[] elements) {
		if (elements != null)
			return new JList<String>(elements);
		return new JList<String>();
	}

	/**
	 * Layout the components of the GUI.
	 * 
	 * @param excluded
	 *            An array of strings containing the excluded fields.
	 * @param tagged
	 *            An array of strings containing the tagged fields.
	 */
	private void layoutComponents(String[] excluded) {
		setListeners();
		setColors();
		parentPanel.add(descriptionLabel, BorderLayout.NORTH);
		parentPanel.add(createPanelForListBoxWithLabel(fieldListBox), BorderLayout.CENTER);
		parentPanel.add(createSouthPanel(), BorderLayout.SOUTH);
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
		ImageIcon img = new ImageIcon("src\\vml_logo.png");
		jFrame.setIconImage(img.getImage());
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
		buttonPanel.add(okayButton);
		buttonPanel.add(Box.createRigidArea(new Dimension(10, 0)));
		Dimension d = okayButton.getMaximumSize();
		cancelButton.setMaximumSize(new Dimension(d));
		buttonPanel.add(cancelButton);
		return buttonPanel;
	}

	/**
	 * Sets the listeners for all of the components.
	 */
	private void setListeners() {
		upButton.addActionListener(new moveUpDownListener());
		downButton.addActionListener(new moveUpDownListener());
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
	private JPanel createPanelForListBoxWithLabel(JList<String> listBox) {
		JPanel panel = new JPanel(new BorderLayout(0, 2));
		listBox.setVisibleRowCount(20);
		JScrollPane scrollPaneForListBox = new JScrollPane(listBox);
		scrollPaneForListBox.setPreferredSize(new Dimension(20, 400));
		panel.setBorder(new EmptyBorder(new Insets(10, 40, 30, 40)));
		panel.add(scrollPaneForListBox, BorderLayout.CENTER);
		JPanel buttonPanel = new JPanel(new BorderLayout(0, 2));
		buttonPanel.setLayout(new BoxLayout(buttonPanel, BoxLayout.Y_AXIS));
		buttonPanel.add(upButton);
		buttonPanel.add(downButton);
		panel.add(buttonPanel, BorderLayout.EAST);
		return panel;
	}

	/**
	 * Gets all of the tag fields from the tag ListBox.
	 * 
	 * @return A String array containing all of the tag fields.
	 */
	public String[] getTaggedFields() {
		return listBoxToArray(fieldListBox);
	}

	/**
	 * Gets all of the excluded fields from the exclude ListBox.
	 * 
	 * @return A String array containing all of the excluded fields.
	 */
	public String[] getFields() {
		return listBoxToArray(fieldListBox);
	}

	/**
	 * Puts the JList elements in a String array.
	 * 
	 * @param listBox
	 *            The ListBox whose elements are put into a String array.
	 * @return The String array that contains all of the elements in the JList.
	 */
	public String[] listBoxToArray(JList<String> listBox) {
		ListModel<String> listBoxModel = listBox.getModel();
		int numElements = listBoxModel.getSize();
		String[] listBoxArray = new String[numElements];
		for (int i = 0; i < numElements; i++) {
			listBoxArray[i] = listBoxModel.getElementAt(i);
		}
		return listBoxArray;
	}

	/**
	 * Sets the colors for all of the components.
	 */
	private void setColors() {
		cancelButton.setBackground(Color.gray);
		cancelButton.setOpaque(false);
		okayButton.setBackground(Color.gray);
		okayButton.setOpaque(false);
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
	 * The action listener class for the Move up and Move down buttons.
	 */
	public class moveUpDownListener implements ActionListener {
		public void actionPerformed(ActionEvent e) {
			JButton sourceButton = (JButton) e.getSource();
			if (sourceButton == upButton) {
				moveUpElements(fieldListBox);
			} else if (sourceButton == downButton) {
				moveDownElements(fieldListBox);
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
				String message = MessageConstants.CANCEL_Q;
				createYesNoDialog(message);
			} else {
				loader.setNotified(true);
				loader.setSubmitted(true);
				jFrame.dispose();
			}
			loader.setFields(getFields());
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
			loader.setFields(getFields());
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