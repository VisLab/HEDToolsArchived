package edu.utsa.tagger.database;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;

import java.io.FileInputStream;
import java.net.URLDecoder;
import java.util.Properties;

import org.junit.AfterClass;
import org.junit.BeforeClass;
import org.junit.Test;
import org.xml.sax.SAXException;

public class TestManageDB {

	private static String dbname = "testmanagedb";
	private static String hostname = "localhost";
	private static ManageDB md;
	private static String password = "admin";
	private static String schemaString;
	private static String tablePath;
	private static String user = "postgres";

	@BeforeClass
	public static void classSetup() throws Exception {
		try {
			tablePath = URLDecoder.decode(
					Class.class.getResource("/data/tags.sql").getPath(),
					"UTF-8");
			md = new ManageDB(dbname, hostname, 5432, user, password);
		} catch (Exception ex) {
			ManageDB.createDatabase(dbname, hostname, 5432, user, password,
					tablePath);
			md = new ManageDB(dbname, hostname, 5432, user, password);
		}
		schemaString = TestTools.getString("validSchema.xsd");
		System.out.println("database setup - now on to get the connection");
	}

	@AfterClass
	public static void classTeardown() throws Exception {
		md.close();
		ManageDB.deleteDatabase(dbname, hostname, 5432, user, password);
	}

	@Test
	public void testCreateCredentials() throws Exception {
		System.out
				.println("It should correctly create a properties file with the given information");
		String configDir = URLDecoder.decode(Class.class.getResource("/data/")
				.getPath(), "UTF-8");
		String configFile = configDir + "testconfig.properties";
		ManageDB.createCredentials(configFile, "testdb", "localhost", 5432,
				"postgres", "admin");
		Properties prop = new Properties();
		prop.load(new FileInputStream(configFile));
		String dbname = prop.getProperty("dbname");
		String hostname = prop.getProperty("hostname");
		String port = prop.getProperty("port");
		String user = prop.getProperty("username");
		String password = prop.getProperty("password");
		assertEquals("dbname should match", "testdb", dbname);
		assertEquals("hostname should match", "localhost", hostname);
		assertEquals("port should match", "5432", port);
		assertEquals("user should match", "postgres", user);
		assertEquals("password should match", "admin", password);
	}

	@Test
	public void testMergeXML() throws Exception {
		System.out
				.println("It should merge the comments into the DB XML, adding new comments but ignoring duplicates");
		String xmlNew = TestTools.getString("test1.xml").trim();
		String xmlDB = TestTools.getString("test2.xml").trim();
		String mergedXML = ManageDB.mergeXML(xmlDB, xmlNew).trim();
		assertEquals(mergedXML, TestTools.getString("test3.xml").trim());
	}

	@Test
	public void testMergeXMLEmptyHED() throws Exception {
		System.out
				.println("It should merge the XML into the DB XML, which is empty");
		String xmlNew = TestTools.getString("HED2.0.xml").trim();
		ManageDB.mergeXMLWithDB(md.getConnection(), xmlNew, false);
		String dbXml = ManageDB.generateDBXML(md.getConnection(), true);
		assertNotNull("Merged xml is null", dbXml);
	}

	 @Test
	 public void testMergeXMLComments() throws Exception {
	 System.out
	 .println("It should merge the comments into the DB XML, adding new comments but ignoring duplicates");
	 String xmlNew = TestTools.getString("comments2.xml");
	 String xmlDB = TestTools.getString("comments1.xml");
	 String mergedXML = ManageDB.mergeXML(xmlDB, xmlNew).trim();
	 assertTrue(mergedXML.contains("This is my comment1"));
	 assertTrue(mergedXML.contains("This is my comment2"));
	 assertTrue(mergedXML.contains("This is my comment3"));
	 assertTrue(mergedXML.contains("This is my comment4"));
	 assertTrue(mergedXML.contains("This is my comment5"));
	 }
	
	 @Test
	 public void testMergeXMLDescriptions() throws Exception {
	 System.out
	 .println("It should not replace the description 'This is a student1' (where the description exists). It should add"
	 +
	 " the description 'This is a grad student' (where there is no description in original XML).");
	 String xmlOld = TestTools.getString("description1.xml");
	 String xmlNew = TestTools.getString("description2.xml");
	 String mergedXML = ManageDB.mergeXML(xmlOld, xmlNew).trim();
	 System.out.println(mergedXML);
	 assertTrue(mergedXML.contains("This is a student1"));
	 assertTrue(mergedXML.contains("This is a grad student"));
	 assertFalse(mergedXML.contains("This is a student2"));
	 }
	
	 @Test(expected = Exception.class)
	 public void testMergeXMLInvalidFirstParameter() throws Exception {
	 System.out
	 .println("It should throw an exception when trying to merge an invalid XML string in the"
	 + " first parameter.");
	 String xmlOld = TestTools.getString("invalid.xml");
	 String xmlNew = TestTools.getString("test1.xml");
	 ManageDB.mergeXML(xmlOld, xmlNew);
	 }
	
	 @Test(expected = Exception.class)
	 public void testMergeXMLInvalidSecondParameter() throws Exception {
	 System.out
	 .println("It should throw an exception when trying to merge an invalid XML string in the"
	 + " second parameter.");
	 String xmlOld = TestTools.getString("test1.xml");
	 String xmlNew = TestTools.getString("invalid.xml");
	 ManageDB.mergeXML(xmlOld, xmlNew);
	 }
	
	 @Test(expected = SAXException.class)
	 public void testValidateSchemaInvalidSchema() throws Exception {
	 System.out
	 .println("It should throw a SAXException exception for invalid schema");
	 String xmlString = TestTools.getString("test1.xml");
	 String badSchemaString = TestTools.getString("invalidSchema.xsd");
	 ManageDB.validateSchemaString(xmlString, badSchemaString);
	 }
	
	 @Test(expected = SAXException.class)
	 public void testValidateSchemaInvalidXML() throws Exception {
	 System.out
	 .println("It should throw a SAXException exception for invalid xml");
	 String xmlString = TestTools.getString("invalid.xml");
	 ManageDB.validateSchemaString(xmlString, schemaString);
	 }
	
	 @Test
	 public void testValidateSchemaValidXML() throws Exception {
	 System.out
	 .println("It should not throw an exception for valid schema and xml");
	 String xmlString = TestTools.getString("HED2.0.xml");
	 ManageDB.validateSchemaString(xmlString, schemaString);
	 }
	
	 @Test(expected = SAXException.class)
	 public void testValidateXMLInvalidXML() throws Exception {
	 System.out.println("It should throw a SAXException for invalid XML.");
	 String xmlString = TestTools.getString("invalid.xml");
	 ManageDB.validateXML(xmlString);
	
	 }
	
	 @Test
	 public void testValidateXMLValidXML() throws Exception {
	 System.out.println("It should not throw an exception for valid XML"
	 + " using the default schema.");
	 String xmlString = TestTools.getString("test1.xml");
	 ManageDB.validateXML(xmlString);
	 }

}
