package edu.utsa.tagger.guisupport;

import javax.swing.JScrollPane;
import javax.swing.JTextArea;
import javax.swing.text.Document;

@SuppressWarnings("serial")
public class XScrollTextBox extends JScrollPane {

	private JTextArea jTextArea;

	public XScrollTextBox(JTextArea jTextArea) {
		super(jTextArea);
		this.jTextArea = jTextArea;
		setVerticalScrollBarPolicy(JScrollPane.VERTICAL_SCROLLBAR_NEVER);
		setHorizontalScrollBarPolicy(JScrollPane.HORIZONTAL_SCROLLBAR_NEVER);
	}

	public JTextArea getJTextArea() {
		return jTextArea;
	}

	public void setJTextArea(JTextArea jTextArea) {
		this.jTextArea = jTextArea;
	}

	public Document getJTextAreaDocument() {
		return jTextArea.getDocument();
	}
}
