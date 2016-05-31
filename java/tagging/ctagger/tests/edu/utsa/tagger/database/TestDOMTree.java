package edu.utsa.tagger.database;

import static org.junit.Assert.assertNotNull;

import java.net.URLDecoder;
import java.sql.Connection;

import org.junit.AfterClass;
import org.junit.BeforeClass;
import org.junit.Test;

public class TestDOMTree {

	private static Connection dbCon;
	private static String dbname = "testdomtree";
	private static String hostname = "localhost";
	private static ManageDB md;
	private static String password = "admin";
	private static String tablePath;
	private static DOMTree tree;
	private static String user = "postgres";
	private static String xml;

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
		dbCon = md.getConnection();
		xml = TestTools.getString("test1.xml");
		tree = new DOMTree();
		tree.buildDOMFromXML(xml);
	}

	@AfterClass
	public static void classTeardown() throws Exception {
		md.close();
		ManageDB.deleteDatabase(dbname, hostname, 5432, user, password);
	}

	@Test
	public void testBuildDOMFromDB() throws Exception {
		DOMTree newTree = new DOMTree();
		tree.buildDOMFromDB(dbCon, newTree.getRoot(), null, true);
		assertNotNull(newTree.getXMLString());
	}

	@Test
	public void testBuildDOMFromXML() throws Exception {
		DOMTree newTree = new DOMTree();
		tree.buildDOMFromXML(xml);
		assertNotNull(newTree.getXMLString());
	}

	@Test
	public void testGetRoot() throws Exception {
		assertNotNull(tree.getRoot());
	}

	@Test
	public void testGetXMLString() throws Exception {
		assertNotNull(tree.getXMLString());
	}
}