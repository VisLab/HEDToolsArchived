package edu.utsa.tagger.database;

import java.io.StringReader;
import java.io.StringWriter;
import java.sql.Connection;
import java.sql.Timestamp;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.transform.OutputKeys;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;
import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathConstants;
import javax.xml.xpath.XPathExpression;
import javax.xml.xpath.XPathFactory;

import org.w3c.dom.Attr;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NamedNodeMap;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.InputSource;

/**
 * This class represents a DOM tree with the format specific to the data in the
 * TagsDB database.
 * 
 * @author Lauren Jett, Rebecca Strautman, Thomas Rognon, Jeremy Cockfield, Kay
 *         Robbins
 */
public class DOMTree {

	private Document doc;

	/**
	 * Constructor automatically creates a new Document object and appends a
	 * node for the root element, HED.
	 */
	public DOMTree() throws Exception {
		try {
			DocumentBuilderFactory docFactory = DocumentBuilderFactory
					.newInstance();
			DocumentBuilder docBuilder = docFactory.newDocumentBuilder();
			doc = docBuilder.newDocument();
			Element rootElement = doc.createElement("HED");
			doc.appendChild(rootElement);
		} catch (Exception ex) {
			throw new Exception("Error in building DOM tree to convert XML\n"
					+ ex.getMessage());
		}
	}

	/**
	 * Adds a comment node in the correct position as a child of the given tag
	 * Node.
	 * 
	 * @param node
	 *            a Node representing a tag
	 * @param comment
	 *            a comment Node to be added for the given tag
	 */
	private void addCommentNode(Node parent, Node comment) {
		Node ref = null;
		NodeList nList = parent.getChildNodes();
		for (int i = 0; i < nList.getLength(); i++) {
			String nodeName = nList.item(i).getNodeName();
			if ("comment".equals(nodeName)) {
				ref = nList.item(i);
				break;
			}
		}
		parent.insertBefore(comment, ref);
	}

	/**
	 * Adds a comment node in the correct position as a child of the given tag
	 * Node with the date, author, and text passed in.
	 * 
	 * @param parent
	 *            a Node representing a tag
	 * @param date
	 *            a Timestamp for the time of the comment to add
	 * @param author
	 *            the author of the comment to add
	 * @param text
	 *            the text (content) of the comment to add
	 */
	private void addCommentNode(Node parent, Timestamp date, String author,
			String text) {
		Node ref = null;
		NodeList nList = parent.getChildNodes();
		Node comment = doc.createElement("comment");
		Node dateN = doc.createElement("date");
		Node authorN = doc.createElement("author");
		Node textN = doc.createElement("text");
		DateFormat format = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ssZ");
		String dt = format.format(date);
		dt = dt.substring(0, 22) + ":" + dt.substring(22);
		dateN.appendChild(doc.createTextNode(dt));
		authorN.appendChild(doc.createTextNode(author));
		textN.appendChild(doc.createTextNode(text));
		comment.appendChild(dateN);
		comment.appendChild(authorN);
		comment.appendChild(textN);
		for (int i = 0; i < nList.getLength(); i++) {
			String nodeName = nList.item(i).getNodeName();
			if (!"name".equals(nodeName) && !"description".equals(nodeName)
					&& !"count".equals(nodeName) && !"date".equals(nodeName)
					&& !"author".equals(nodeName) && !"text".equals(nodeName)) {
				ref = nList.item(i);
				break;
			}
		}
		parent.insertBefore(comment, ref);
	}

	/**
	 * Creates a new node to contain the count and appends it to the passed
	 * node.
	 * 
	 * @param parent
	 *            Node representing a tag
	 * @param count
	 *            the count for the given tag
	 */
	private void addCountNode(Node parent, int count) {
		Element countNode = doc.createElement("count");
		countNode.appendChild(doc.createTextNode(String.valueOf(count)));
		Node ref = null;
		NodeList nList = parent.getChildNodes();
		for (int i = 0; i < nList.getLength(); i++) {
			String nodeName = nList.item(i).getNodeName();
			if (!"name".equals(nodeName) && !"description".equals(nodeName)) {
				ref = nList.item(i);
				break;
			}
		}
		parent.insertBefore(countNode, ref);
	}

	/**
	 * Creates a new node to contain the description text for a tag and appends
	 * it to the parent.
	 * 
	 * @param parent
	 *            a Node representing a tag
	 * @param description
	 *            the description to add to the tag
	 */
	private void addDescriptionNode(Node parent, String description) {
		Element descNode = doc.createElement("description");
		descNode.appendChild(doc.createTextNode(description));
		Node ref = null;
		NodeList nList = parent.getChildNodes();
		for (int i = 0; i < nList.getLength(); i++) {
			String nodeName = nList.item(i).getNodeName();
			if (!"name".equals(nodeName)) {
				ref = nList.item(i);
				break;
			}
		}
		parent.insertBefore(descNode, ref);
	}

	/**
	 * Creates a new tag Node with the given name and appends it to the passed
	 * Node.
	 * 
	 * @param parent
	 *            a Node representing a tag for which a child tag must be added
	 * @param name
	 *            the name for the child tag to be added
	 * @return a reference to the new child Node
	 */
	private Node addNameNode(Node parent, String name) {
		Element node = doc.createElement("node");
		parent.appendChild(node);
		Element nameNode = doc.createElement("name");
		nameNode.appendChild(doc.createTextNode(name));
		node.appendChild(nameNode);
		return node;
	}

	/**
	 * Adds the information for the given tag to the database, including its
	 * attributes, and recursively adds the tag's children as represented in the
	 * HED hierarchy.
	 * 
	 * @param dbCon
	 *            a connection to the database
	 * @param node
	 *            a Node representing a tag to be stored in the database
	 * @param pid
	 *            the UUID of the tag's parent (or null for a tag in the first
	 *            level)
	 */
	private void addNodeToDB(Connection dbCon, Node node, UUID pid)
			throws Exception {
		Node parent = node.getParentNode();
		if (!parent.getNodeName().equals("HED")) {
			pid = Tags
					.retrieveTagByPathname(dbCon, getPathnameFromNode(parent))
					.getTagUuid();
		}
		Tags tagTable = new Tags(dbCon);
		tagTable.reset(UUID.randomUUID(), getPathnameFromNode(node), pid,
				getTagChildNode(node, "description"), 0, null);
		UUID uuid = tagTable.getTagUuid();
		tagTable.insertTag();
		NamedNodeMap attributes = getNodeAttributes(node);
		Attr currentAttribute;
		TagAttributes tagAttributesTable = new TagAttributes(dbCon);
		if (attributes != null) {
			for (int j = 0; j < attributes.getLength(); j++) {
				currentAttribute = (Attr) attributes.item(j);
				tagAttributesTable.reset(UUID.randomUUID(),
						tagTable.getTagUuid(), currentAttribute.getName(),
						currentAttribute.getValue());
				tagAttributesTable.insertTagAttribute();
			}
		}
		NodeList commentList = getCommentNodes(node);
		for (int i = 0; i < commentList.getLength(); i++)
			TagComments.insertCommentByPathname(dbCon,
					getPathnameFromNode(node),
					getCommentChildNode(commentList.item(i), "date"),
					getCommentChildNode(commentList.item(i), "author"),
					getCommentChildNode(commentList.item(i), "text"));
		NodeList childList = node.getChildNodes();
		for (int i = 0; i < childList.getLength(); i++) {
			if (isNode(childList.item(i)))
				addNodeToDB(dbCon, childList.item(i), uuid);
		}
	}

	/**
	 * Adds Nodes representing the child tags for the current tag to the DOM
	 * tree. Recursively adds children for each of these child tags.
	 * 
	 * @param dbCon
	 *            a connection to the database
	 * @param currentNode
	 *            The current node in the DOMTree
	 * @param uuid
	 *            the UUID of the current tag
	 * @param getCount
	 *            will retrieve the count from the database if true
	 */
	public void buildDOMFromDB(Connection dbCon, Node currentNode, UUID uuid,
			boolean getCount) throws Exception {
		List<Node> childNodes = new ArrayList<Node>();
		List<UUID> childIDs = new ArrayList<UUID>();
		Tags tagsTable;
		ArrayList<TagAttributes> tagAttributes;
		ArrayList<TagComments> tagComments;
		int numComments;
		int numAttributes;
		Element elementNode;
		Node node;
		UUID childID;
		try {
			ArrayList<UUID> tagChildrenUuids = Tags.retrieveTagChildrenUuids(
					dbCon, uuid);
			int numChildUuids = tagChildrenUuids.size();
			for (int i = 0; i < numChildUuids; i++) {
				tagsTable = Tags.retrieveTagByUuid(dbCon,
						tagChildrenUuids.get(i));
				node = addNameNode(currentNode,
						getNameFromPathname(tagsTable.getTagPathname()));
				childNodes.add(node);
				childID = tagsTable.getTagUuid();
				childIDs.add(childID);
				if (!ManageDB.isEmpty(tagsTable.getTagDescription()))
					addDescriptionNode(node, tagsTable.getTagDescription());
				if (getCount)
					addCountNode(node, tagsTable.getTagCount());
				elementNode = (Element) node;
				tagAttributes = TagAttributes.retrieveAttributesByTagUuid(
						dbCon, childID);
				numAttributes = tagAttributes.size();
				if (numAttributes > 0) {
					for (int j = 0; j < numAttributes; j++)
						elementNode.setAttribute(tagAttributes.get(j)
								.getTagAttributeName(), tagAttributes.get(j)
								.getTagAttributeValue());
				}
				tagComments = TagComments.retrieveCommentsByTagUuid(dbCon,
						childID);
				numComments = tagComments.size();
				if (numComments > 0) {
					for (int k = 0; k < numComments; k++)
						addCommentNode(node, tagComments.get(k)
								.getTagCommentDate(), tagComments.get(k)
								.getTagCommentAuthor(), tagComments.get(k)
								.getTagCommentText());
				}
			}
			for (int l = 0; l < childNodes.size(); l++)
				buildDOMFromDB(dbCon, childNodes.get(l), childIDs.get(l),
						getCount);
		} catch (Exception ex) {
			throw new Exception(
					"Unable to retrieve the tags from the database\n"
							+ ex.getMessage());
		}
	}

	/**
	 * Builds the DOM tree for the given XML data
	 * 
	 * @param xmlString
	 *            a String containing XML representing a HED hierarchy
	 * @throws Exception
	 */
	public void buildDOMFromXML(String xmlString) throws Exception {
		InputSource input = new InputSource();
		xmlString = xmlString.replaceAll(">\\s*<", "><");
		xmlString = xmlString.replaceAll("<unitClasses>\\s*</unitClasses>", "");
		input.setCharacterStream(new StringReader(xmlString));
		DocumentBuilderFactory dbFactory = DocumentBuilderFactory.newInstance();
		DocumentBuilder dBuilder;
		dBuilder = dbFactory.newDocumentBuilder();
		doc = dBuilder.parse(input);
		doc.getDocumentElement().normalize();
	}

	private HashMap<String, Node> createCommentNodeHashMap(NodeList nodeList) {
		HashMap<String, Node> nodeMap = new HashMap<String, Node>();
		int numNodes = nodeList.getLength();
		for (int i = 0; i < numNodes; i++)
			nodeMap.put(getCommentChildNode(nodeList.item(i), "text"),
					nodeList.item(i));
		return nodeMap;
	}

	private HashMap<String, Node> createNameNodeHashMap(NodeList nodeList) {
		HashMap<String, Node> nodeMap = new HashMap<String, Node>();
		int numNodes = nodeList.getLength();
		for (int i = 0; i < numNodes; i++)
			nodeMap.put(getTagChildNode(nodeList.item(i), "name"),
					nodeList.item(i));
		return nodeMap;
	}

	/**
	 * Returns the attribute associated with the comment.
	 * 
	 * @param node
	 *            the comment node
	 * @param child
	 *            the child of the comment node
	 * @return the string representation of the comment attribute
	 */
	private String getCommentChildNode(Node node, String child) {
		String result = null;
		NodeList children = node.getChildNodes();
		for (int i = 0; i < children.getLength(); i++) {
			if (child.equals(children.item(i).getNodeName())) {
				NodeList cText = children.item(i).getChildNodes();
				if (cText.getLength() >= 1)
					result = cText.item(0).getNodeValue();
			}
		}
		return result;
	}

	/**
	 * Returns a NodeList of comment nodes for the given tag node.
	 * 
	 * @param node
	 *            a Node representing a tag
	 * @return a NodeList containing all comment nodes for the passed tag node;
	 *         null if passed tag node has no comments
	 */
	private NodeList getCommentNodes(Node node) throws Exception {
		XPathFactory xPathfactory = XPathFactory.newInstance();
		XPath xpath = xPathfactory.newXPath();
		XPathExpression expr = xpath.compile("./comment");
		NodeList result = (NodeList) expr
				.evaluate(node, XPathConstants.NODESET);
		return result;
	}

	/**
	 * Gets the DOMSource for the current DOM tree
	 * 
	 * @return DOMSource for the current DOM tree
	 */
	private DOMSource getDOMSource() {
		return new DOMSource(doc);
	}

	/**
	 * Given a full pathname, it parses the string to get the singular name of
	 * the tag and returns it
	 * 
	 * @param pathname
	 *            the pathname for a tag
	 * @return String containing the name of the tag
	 */
	private String getNameFromPathname(String pathname) {
		if (pathname == null || pathname.lastIndexOf('/') == -1)
			return null;
		else
			return pathname.substring(pathname.lastIndexOf('/') + 1);
	}

	/**
	 * Gets the attributes for the passed Node representing a tag.
	 * 
	 * @param n
	 *            a Node in a TagsDOMTree representing a tag
	 * @return NamedNodeMap containing the attributes for <code>n</code> if n is
	 *         a valid tag; <code>null</code> otherwise
	 */
	private NamedNodeMap getNodeAttributes(Node node) {
		NamedNodeMap nameNodeMap = null;
		if (isNode(node))
			nameNodeMap = node.getAttributes();
		return nameNodeMap;
	}

	/**
	 * Finds the full pathname of the tag for the given Node
	 * 
	 * @param n
	 *            a Node representing a tag
	 * @return a String containing the full pathname for the tag
	 */
	private String getPathnameFromNode(Node n) {
		String pathName = "";
		if (n.getNodeName() != "HED") {
			Node p = n.getParentNode();
			String path = getTagChildNode(n, "name");
			path = "/" + path;
			pathName = getPathnameFromNode(p) + path;
		}
		return pathName;
	}

	/**
	 * Gets the root of the DOM tree.
	 * 
	 * @return Node representing the root of this instance of Tags
	 */
	public Node getRoot() {
		return doc.getDocumentElement();
	}

	/**
	 * Returns the attribute associated with the tag
	 * 
	 * @param node
	 *            the tag node
	 * @param attribute
	 *            the child of the tag node
	 * @return the string representation of the tag attribute
	 */
	private String getTagChildNode(Node node, String child) {
		NodeList nList = node.getChildNodes();
		String result = null;
		for (int i = 0; i < nList.getLength(); i++) {
			Node curr = nList.item(i);
			if (child.equals(curr.getNodeName())) {
				NodeList cText = curr.getChildNodes();
				if (cText.getLength() >= 1)
					result = cText.item(0).getNodeValue();
			}
		}
		return result;
	}

	/**
	 * Returns the XML String for the current DOM tree.
	 * 
	 * @return a String containing the XML for the current DOM tree;
	 *         <code>null</code> if there is an error
	 */
	public String getXMLString() throws Exception {
		TransformerFactory transformerFactory = TransformerFactory
				.newInstance();
		Transformer transformer = transformerFactory.newTransformer();
		DOMSource source = getDOMSource();
		StringWriter outText = new StringWriter();
		StreamResult res = new StreamResult(outText);
		transformer.setOutputProperty(OutputKeys.INDENT, "yes");
		transformer.setOutputProperty(
				"{http://xml.apache.org/xslt}indent-amount", "3");
		transformer.transform(source, res);
		return outText.toString();
	}

	/**
	 * Checks whether the passed Node represents a "node" tag in the HED
	 * hierarchy.
	 * 
	 * @param node
	 *            a node in a DOMTree
	 * @return true if it is a node, false if otherwise
	 */
	private boolean isNode(Node node) {
		return (node.getNodeType() == Node.ELEMENT_NODE && "node".equals(node
				.getNodeName()));
	}

	public void mergeNodes(Connection dbCon, Node node1, Node node2)
			throws Exception {
		HashMap<String, Node> nameNodeMap1 = createNameNodeHashMap(node1
				.getChildNodes());
		HashMap<String, Node> nameNodeMap2 = createNameNodeHashMap(node2
				.getChildNodes());
		Node newChild;
		for (Map.Entry<String, Node> nameEntry : nameNodeMap2.entrySet()) {
			if (nameEntry.getKey() == null) {
				continue;
			}
			if (!nameNodeMap1.containsKey(nameEntry.getKey())) {
				newChild = doc.importNode(nameEntry.getValue(), true);
				node1.appendChild(newChild);
				addNodeToDB(dbCon, newChild, null);
			} else {
				// Update description
				if (ManageDB.isEmpty(getTagChildNode(
						nameNodeMap1.get(nameEntry.getKey()), "description"))
						&& !ManageDB.isEmpty(getTagChildNode(
								nameEntry.getValue(), "description"))) {
					updateDescriptionNode(
							nameNodeMap1.get(nameEntry.getKey()),
							getTagChildNode(nameEntry.getValue(), "description"));
					Tags.updateDescription(
							dbCon,
							getPathnameFromNode(nameEntry.getValue()),
							getTagChildNode(nameEntry.getValue(), "description"));
				}
				// Merge comments
				HashMap<String, Node> commentNodeMap1 = createCommentNodeHashMap(getCommentNodes(node1));
				HashMap<String, Node> commentNodeMap2 = createCommentNodeHashMap(getCommentNodes(node2));
				Node newComment;
				for (Map.Entry<String, Node> commentEntry : commentNodeMap2
						.entrySet()) {
					if (!commentNodeMap1.containsKey(commentEntry.getKey())) {
						newComment = doc.importNode(commentEntry.getValue(),
								true);
						addCommentNode(node1, newComment);
						TagComments.insertCommentByPathname(dbCon,
								getPathnameFromNode(node1),
								getCommentChildNode(newComment, "date"),
								getCommentChildNode(newComment, "author"),
								getCommentChildNode(newComment, "text"));
					}
				}
				mergeNodes(dbCon, nameNodeMap1.get(nameEntry.getKey()),
						nameEntry.getValue());
			}
		}
	}

	/**
	 * Merges the children of the two nodes so that upon returning, node1 has as
	 * children all of the child nodes from itself and node2. The method is
	 * recursively called to merge child nodes representing the same tag as
	 * well. For nodes that are merged, the description from the first node will
	 * take priority; if there is no description, the description from the
	 * second node will be used, if it exists.
	 * 
	 * @param node1
	 *            a Node representing a tag from the current instance of
	 *            TagsDOMTree
	 * @param node2
	 *            a Node representing a tag to be merged with the current
	 *            instance of TagsDOMTree
	 */
	public void mergeNodes(Node node1, Node node2) throws Exception {
		HashMap<String, Node> nameNodeMap1 = createNameNodeHashMap(node1
				.getChildNodes());
		HashMap<String, Node> nameNodeMap2 = createNameNodeHashMap(node2
				.getChildNodes());
		Node newChild;
		for (Map.Entry<String, Node> entry : nameNodeMap2.entrySet()) {
			if (!nameNodeMap1.containsKey(entry.getKey())) {
				newChild = doc.importNode(entry.getValue(), true);
				node1.appendChild(newChild);
			} else {
				// Update description
				if (ManageDB.isEmpty(getTagChildNode(
						nameNodeMap1.get(entry.getKey()), "description"))
						&& !ManageDB.isEmpty(getTagChildNode(entry.getValue(),
								"description")))
					updateDescriptionNode(nameNodeMap1.get(entry.getKey()),
							getTagChildNode(entry.getValue(), "description"));
				// Merge comments
				HashMap<String, Node> commentNodeMap1 = createCommentNodeHashMap(getCommentNodes(node1));
				HashMap<String, Node> commentNodeMap2 = createCommentNodeHashMap(getCommentNodes(node2));
				Node newComment;
				for (Map.Entry<String, Node> commentEntry : commentNodeMap2
						.entrySet()) {
					if (!commentNodeMap1.containsKey(commentEntry.getKey())) {
						newComment = doc.importNode(commentEntry.getValue(),
								true);
						addCommentNode(node1, newComment);
					}
				}
				mergeNodes(nameNodeMap1.get(entry.getKey()), entry.getValue());
			}
		}
	}

	/**
	 * Finds the description Node in the DOM tree, if it exists, and replaces
	 * its text with the new description text. If it does not exist, a new Node
	 * for the description is created and appended to parent.
	 * 
	 * @param parent
	 *            a Node representing a tag
	 * @param description
	 *            the description to update the tag with
	 */
	private void updateDescriptionNode(Node parent, String description) {
		NodeList nList = parent.getChildNodes();
		Element descNode = null;
		for (int i = 0; i < nList.getLength(); i++) {
			Node curr = nList.item(i);
			if ("description".equals(curr.getNodeName())) {
				descNode = (Element) curr;
				descNode.setTextContent(description);
			}
		}
	}

}
