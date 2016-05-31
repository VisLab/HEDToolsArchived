package edu.utsa.tagger.database;

import static org.junit.Assert.assertEquals;

import java.net.URLDecoder;
import java.sql.Connection;

import org.junit.AfterClass;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;

public class TestEvents {

	private static Connection dbCon;
	private static String dbname = "testeventsdb";
	private static Events events;
	private static String hostname = "localhost";
	private static ManageDB md;
	private static String password = "admin";
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
		dbCon = md.getConnection();
		events = new Events(dbCon);
		System.out.println("database setup - now on to get the connection");
	}

	@AfterClass
	public static void classTeardown() throws Exception {
		md.close();
		ManageDB.deleteDatabase(dbname, hostname, 5432, user, password);
	}

	@Before
	public void testSetup() throws Exception {
		TestTools.clearDB(dbCon);
	}

	@Test
	public void testUpdateTagCountJson() throws Exception {
		System.out.println("It should update the database with any new tags.");

		// Set up the unit test
		String hedxml = TestTools.getString("HED2.0.xml");
		ManageDB.mergeXMLWithDB(dbCon, hedxml, true);
		String old_events_string = TestTools.TEST_EVENTS_JSON1;
		String new_events_string = TestTools.TEST_EVENTS_JSON2;
		events.updateTagCount(old_events_string, new_events_string, true);

		Tags tagsTable = Tags.retrieveTagByPathname(dbCon, "/Item");
		assertEquals("Wrong count found for /Item", 5, tagsTable.getTagCount());

		tagsTable = Tags.retrieveTagByPathname(dbCon, "/Item/Object");
		assertEquals("Wrong count found for /Item/Object", 4,
				tagsTable.getTagCount());

		tagsTable = Tags.retrieveTagByPathname(dbCon, "/Item/Object/Animal");
		assertEquals("Wrong count found for /Item/Object/Animal", 1,
				tagsTable.getTagCount());

		tagsTable = Tags.retrieveTagByPathname(dbCon, "/Item/Object/Person");
		assertEquals("Wrong count found for /Item/Object/Person", 2,
				tagsTable.getTagCount());

	}

	@Test
	public void testUpdateTagCountNonJson() throws Exception {
		System.out.println("It should update the database with any new tags.");

		// Set up the unit test
		String hedxml = TestTools.getString("HED2.0.xml");
		ManageDB.mergeXMLWithDB(dbCon, hedxml, true);
		String old_events_string = TestTools.TEST_EVENTS_NON_JSON1;
		String new_events_string = TestTools.TEST_EVENTS_NON_JSON2;
		events.updateTagCount(old_events_string, new_events_string, false);

		Tags tagsTable = Tags.retrieveTagByPathname(dbCon, "/Item");
		assertEquals("Wrong count found for /Item", 5, tagsTable.getTagCount());

		tagsTable = Tags.retrieveTagByPathname(dbCon, "/Item/Object");
		assertEquals("Wrong count found for /Item/Object", 4,
				tagsTable.getTagCount());

		tagsTable = Tags.retrieveTagByPathname(dbCon, "/Item/Object/Animal");
		assertEquals("Wrong count found for /Item/Object/Animal", 1,
				tagsTable.getTagCount());

		tagsTable = Tags.retrieveTagByPathname(dbCon, "/Item/Object/Person");
		assertEquals("Wrong count found for /Item/Object/Person", 2,
				tagsTable.getTagCount());
	}

}