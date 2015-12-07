package edu.utsa.tagger.database;

import java.io.DataInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.StringReader;
import java.net.URL;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.Properties;

import javax.xml.XMLConstants;
import javax.xml.transform.Source;
import javax.xml.transform.stream.StreamSource;
import javax.xml.validation.Schema;
import javax.xml.validation.SchemaFactory;
import javax.xml.validation.Validator;

import org.xml.sax.SAXException;

/**
 * This class is used to manage a tags database, with methods for creating and
 * initializing the database, updating records, and generating XML.
 * 
 * @author Lauren Jett, Rebecca Strautman, Thomas Rognon, Jeremy Cockfield, Kay
 *         Robbins
 * 
 */
public class ManageDB {

	/**
	 * A connection to the database
	 */
	private Connection connection;
	/**
	 * The default schema URL
	 */
	private static final String defaultSchemaURL = "http://visual.cs.utsa.edu/ctagger/xml/HedSchema.xsd";
	/**
	 * The name of the template database
	 */
	private static final String templateName = "template1";

	/**
	 * Checks for active connections.
	 * 
	 * @param dbCon
	 *            a connection to the database
	 * @throws Exception
	 *             if an error occurs
	 */
	private static void checkForActiveConnections(Connection dbCon)
			throws Exception {
		int otherConnections;
		try {
			Statement stmt = dbCon.createStatement();
			String qry = "SELECT count(pid) from pg_stat_activity WHERE datname = current_database() AND pid <> pg_backend_pid()";
			ResultSet rs = stmt.executeQuery(qry);
			rs.next();
			otherConnections = rs.getInt(1);
		} catch (Exception ex1) {
			throw new Exception(
					"Could not execute query to get active connections\n"
							+ ex1.getMessage());
		}
		if (otherConnections > 0) {
			try {
				dbCon.close();
			} catch (Exception ex2) {
				throw new Exception("Could not close the connection\n"
						+ ex2.getMessage());
			}
			throw new Exception(
					"Close all connections before dropping the database");
		}
	}

	/**
	 * Creates a property file with the given information representing database
	 * credentials.
	 * 
	 * @param filename
	 *            the name of the file to create
	 * @param dbname
	 *            the name of the database
	 * @param hostname
	 *            the host name of the database
	 * @param port
	 *            the port number of the database
	 * @param username
	 *            the username of the database
	 * @param password
	 *            the password of the database
	 * @throws IOException
	 */
	public static void createCredentials(String filename, String dbname,
			String hostname, int port, String username, String password)
			throws Exception {
		Properties prop = new Properties();
		try {
			prop.setProperty("dbname", dbname);
			prop.setProperty("hostname", hostname);
			prop.setProperty("port", Integer.toString(port));
			prop.setProperty("username", username);
			prop.setProperty("password", password);
			prop.store(new FileOutputStream(filename), null);
		} catch (Exception ex) {
			throw new Exception("Could not create credentials\n"
					+ ex.getMessage());
		}
	}

	/**
	 * Creates a database. The database must not already exist to create it. The
	 * database is created without any tables, columns, and data.
	 * 
	 * @param dbCon
	 *            the connection to the database
	 * @param dbname
	 *            the name of the database
	 * @throws Exception
	 *             if an error occurs
	 */
	private static void createDatabase(Connection dbCon, String dbname)
			throws Exception {
		String sql = "CREATE DATABASE " + dbname;
		try {
			PreparedStatement pStmt = dbCon.prepareStatement(sql);
			pStmt.execute();
		} catch (Exception ex1) {
			try {
				dbCon.close();
			} catch (Exception ex2) {
				throw new Exception("Could not close the database connection\n"
						+ ex2.getMessage());
			}
			throw new Exception("Could not create the database " + dbname
					+ "\n" + ex1.getMessage());
		}
	}

	/**
	 * 
	 * @param propFile
	 *            The pathname of the property file
	 * @param sqlFile
	 *            The pathname of the sql file
	 * @throws Exception
	 *             if an error occurs
	 */
	public static void createDatabase(String propFile, String sqlFile)
			throws Exception {
		Properties prop = new Properties();
		prop.load(new FileInputStream(propFile));
		createDatabase(prop.getProperty("dbname"),
				prop.getProperty("hostname"),
				Integer.parseInt(prop.getProperty("port")),
				prop.getProperty("username"), prop.getProperty("password"),
				sqlFile);
	}

	/**
	 * Creates and populates a database. The database must not already exist to
	 * create it. The database will be created from a valid SQL file.
	 * 
	 * @param dbname
	 *            the name of the database
	 * @param hostname
	 *            the host name of the database
	 * @param port
	 *            the port number of the database
	 * @param username
	 *            the user name of the database
	 * @param password
	 *            the password of the database
	 * @param sqlFile
	 *            the name of the sql file
	 * @throws Exception
	 *             if an error occurs
	 */
	public static void createDatabase(String dbname, String hostname, int port,
			String username, String password, String sqlFile) throws Exception {
		if (isEmpty(sqlFile))
			throw new Exception("The SQL file does not exist");
		try {
			Connection templateConnection = establishConnection(templateName,
					hostname, Integer.toString(port), username, password);
			createDatabase(templateConnection, dbname);
			templateConnection.close();
			Connection databaseConnection = establishConnection(dbname,
					hostname, Integer.toString(port), username, password);
			createTables(databaseConnection, sqlFile);
			databaseConnection.close();
		} catch (Exception ex) {
			throw new Exception("Could not create and populate the database\n"
					+ ex.getMessage());
		}
	}

	/**
	 * Creates the database tables and populates them from a valid SQL file.
	 * 
	 * @param dbCon
	 *            a connection to the database
	 * @param filename
	 *            the name of the SQL file
	 * @throws Exception
	 *             if an error occurs
	 */
	private static void createTables(Connection dbCon, String filename)
			throws Exception {
		DataInputStream in;
		byte[] buffer;
		try {
			File file = new File(filename);
			buffer = new byte[(int) file.length()];
			in = new DataInputStream(new FileInputStream(file));
			in.readFully(buffer);
			in.close();
			String result = new String(buffer);
			String[] tables = result.split("-- execute");
			Statement stmt = dbCon.createStatement();
			for (int i = 0; i < tables.length; i++)
				stmt.execute(tables[i]);
		} catch (Exception ex) {
			throw new Exception("Could not populate the database tables\n"
					+ ex.getMessage());
		}
	}

	/**
	 * Drops the database.
	 * 
	 * @param propFile
	 *            The pathname of the property file
	 * @throws Exception
	 *             if an error occurs
	 */
	public static void deleteDatabase(String propFile) throws Exception {
		Properties prop = new Properties();
		prop.load(new FileInputStream(propFile));
		deleteDatabase(prop.getProperty("dbname"),
				prop.getProperty("hostname"),
				Integer.parseInt(prop.getProperty("port")),
				prop.getProperty("username"), prop.getProperty("password"));
	}

	/**
	 * Drops the database.
	 * 
	 * @param dbname
	 *            the name of the database
	 * @param hostname
	 *            the host name of the database
	 * @param port
	 *            the port number of the database
	 * @param username
	 *            the user name of the database
	 * @param password
	 *            the password of the database
	 * @throws Exception
	 *             if an error occurs
	 */
	public static void deleteDatabase(String dbname, String hostname, int port,
			String username, String password) throws Exception {
		Connection databaseConnection = establishConnection(dbname, hostname,
				Integer.toString(port), username, password);
		checkForActiveConnections(databaseConnection);
		databaseConnection.close();
		Connection templateConnection = establishConnection(templateName,
				hostname, Integer.toString(port), username, password);
		dropDatabase(templateConnection, dbname);
		templateConnection.close();
	}

	/**
	 * Drops a database. The database must already exist to drop it. There must
	 * be no active connections to drop the database.
	 * 
	 * @param dbCon
	 *            connection to a different database
	 * @param dbname
	 *            the name of the database
	 * @throws Exception
	 *             if an error occurs
	 */
	private static void dropDatabase(Connection dbCon, String dbname)
			throws Exception {
		String sql = "DROP DATABASE IF EXISTS " + dbname;
		try {
			Statement stmt = dbCon.createStatement();
			stmt.execute(sql);
		} catch (Exception ex1) {
			try {
				dbCon.close();
			} catch (Exception ex2) {
				throw new Exception("Could not close the connection\n"
						+ ex2.getMessage());
			}
			throw new Exception("Could not drop the database" + dbname + "\n"
					+ ex1.getMessage());
		}
	}

	/**
	 * Establishes a connection to a database. The database must exist and allow
	 * connections for a connection to be established.
	 * 
	 * @param dbname
	 *            the name of the database
	 * @param hostname
	 *            the host name of the database
	 * @param username
	 *            the user name of the database
	 * @param password
	 *            the password of the database
	 * @return a connection to the database
	 * @throws Exception
	 *             if an error occurs
	 */
	private static Connection establishConnection(String dbname,
			String hostname, String port, String username, String password)
			throws Exception {
		Connection dbCon = null;
		String url = "jdbc:postgresql://" + hostname + ":" + port + "/"
				+ dbname;
		try {
			Class.forName("org.postgresql.Driver");
			dbCon = DriverManager.getConnection(url, username, password);
		} catch (Exception ex) {
			throw new Exception("Could not establish a connection to database "
					+ dbname + "\n" + ex.getMessage());
		}
		return dbCon;
	}

	/**
	 * Converts the data in TagsDB to XML in the format used for the HED
	 * hierarchy and returns the XML as a String.
	 * 
	 * @param dbCon
	 *            a Connection to the TagsDB database
	 * @param getCount
	 *            will retrieve the count from the database if true
	 * @return String containing the XML representation of the database
	 */
	public static String generateDBXML(Connection dbCon, boolean getCount)
			throws Exception {
		DOMTree tree = new DOMTree();
		tree.buildDOMFromDB(dbCon, tree.getRoot(), null, getCount);
		return tree.getXMLString();
	}

	/**
	 * Checks if an string is empty.
	 * 
	 * @param s
	 *            a string
	 * @return true if the string is empty, false if otherwise
	 */
	public static boolean isEmpty(String s) {
		boolean empty = true;
		if (s != null) {
			if (s.length() > 0)
				empty = false;
		}
		return empty;
	}

	/**
	 * Merges two XML Strings in the HED hierarchy format
	 * 
	 * @param xmlOld
	 *            XML String representing original hierarchy
	 * @param xmlNew
	 *            XML String representing hierarchy to be merged with xmlOld
	 * @return String containing merged XML if both parameters are valid; null
	 *         otherwise
	 */
	public static String mergeXML(String xmlOld, String xmlNew)
			throws Exception {
		DOMTree tree1 = new DOMTree();
		tree1.buildDOMFromXML(xmlOld);
		DOMTree tree2 = new DOMTree();
		tree2.buildDOMFromXML(xmlNew);
		tree1.mergeNodes(tree1.getRoot(), tree2.getRoot());
		return tree1.getXMLString();
	}

	/**
	 * Merges the data in the given XML string with the data currently in the
	 * database dbCon refers to.
	 * 
	 * @param dbCon
	 *            a Connection to the TagsDB database
	 * @param xml
	 *            string containing the XML for a HED hierarchy
	 * @param getCount
	 *            will retrieve the count from the database if true
	 * @return String containing merged XML of database info and given XML
	 */
	public static String mergeXMLWithDB(Connection dbCon, String xml,
			boolean getCount) throws Exception {
		DOMTree tree1 = new DOMTree();
		tree1.buildDOMFromDB(dbCon, tree1.getRoot(), null, getCount);
		DOMTree tree2 = new DOMTree();
		tree2.buildDOMFromXML(xml);
		tree1.mergeNodes(dbCon, tree1.getRoot(), tree2.getRoot());
		return tree1.getXMLString();
	}

	/**
	 * Tests whether the TagsDOMTree indicated by <code>source</code> is valid
	 * according to the XML schema passed in <code>schemaString</code>
	 * 
	 * @param source
	 *            a String containing XML representing a HED hierarchy
	 * @throws SAXException
	 *             if the schema or the XML is invalid
	 * @throws IOException
	 *             if the schema cannot be read
	 */
	public static void validateSchemaString(String source, String schemaString)
			throws IOException, SAXException {
		SchemaFactory factory = SchemaFactory
				.newInstance(XMLConstants.W3C_XML_SCHEMA_NS_URI);
		Source domSource = new StreamSource(new StringReader(source));
		Source schemaSource = new StreamSource(new StringReader(schemaString));
		Schema schema = factory.newSchema(schemaSource);
		Validator validator = schema.newValidator();
		validator.validate(domSource);
	}

	/**
	 * Checks the given XML against the HED hierarchy schema to test whether the
	 * XML is valid for a HED hierarchy.
	 * 
	 * @param xml
	 *            a String containing XML representing a HED hierarchy
	 * @throws IOException
	 * @throws SAXException
	 */
	public static void validateXML(String xml) throws IOException, SAXException {
		SchemaFactory factory = SchemaFactory
				.newInstance(XMLConstants.W3C_XML_SCHEMA_NS_URI);
		Source domSource = new StreamSource(new StringReader(xml));
		URL url = new URL(defaultSchemaURL);
		Source schemaSource = new StreamSource(url.openStream());
		Schema schema = factory.newSchema(schemaSource);
		Validator validator = schema.newValidator();
		validator.validate(domSource);
	}

	/**
	 * Constructor initializes the database name, host name, user name, and
	 * password to use for setting up the database by reading the information
	 * from the given property file
	 * 
	 * @param propFile
	 *            The pathname of the property file
	 * @throws IOException
	 * @throws FileNotFoundException
	 */
	public ManageDB(String propFile) throws Exception {
		Properties prop = new Properties();
		prop.load(new FileInputStream(propFile));
		connection = establishConnection(prop.getProperty("dbname"),
				prop.getProperty("hostname"), prop.getProperty("port"),
				prop.getProperty("username"), prop.getProperty("password"));
	}

	/**
	 * Constructor initializes the database name, host name, user name, and
	 * password to use for setting up the database.
	 * 
	 * @param dbname
	 *            the name of the database
	 * @param hostname
	 *            the host name of the database
	 * @param port
	 *            the port number of the database
	 * @param username
	 *            the username of the database
	 * @param password
	 *            the password of the database
	 */
	public ManageDB(String dbname, String hostname, int port, String username,
			String password) throws Exception {
		connection = establishConnection(dbname, hostname,
				Integer.toString(port), username, password);
	}

	/**
	 * Closes the connection to the database
	 * 
	 * @throws Exception
	 *             when close fails
	 */
	public void close() throws Exception {
		connection.close();
	}

	/**
	 * Gets a connection to the database.
	 * 
	 * @return a Connection to the database
	 * @throws Exception
	 */
	public Connection getConnection() throws Exception {
		return connection;
	}
}
