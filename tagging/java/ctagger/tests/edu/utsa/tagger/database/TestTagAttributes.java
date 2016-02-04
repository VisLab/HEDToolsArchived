package edu.utsa.tagger.database;

import static org.junit.Assert.assertEquals;

import java.net.URLDecoder;
import java.sql.Connection;
import java.util.ArrayList;
import java.util.UUID;

import org.junit.AfterClass;
import org.junit.BeforeClass;
import org.junit.Test;

public class TestTagAttributes {

	private static Connection dbCon;
	private static String dbname = "testtagattributesdb";
	private static String hostname = "localhost";
	private static ManageDB md;
	private static Tags parentTag;
	private static TagAttributes parentTagAttributes;
	private static String parentTagPathname;
	private static UUID parentTagUuid;
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
		System.out.println("database setup - now on to get the connection");
		parentTag = new Tags(dbCon);
		parentTagUuid = UUID.randomUUID();
		parentTagPathname = "Student";
		parentTag.reset(parentTagUuid, parentTagPathname, null, null, 0,
				"test@email.com");
		parentTag.insertTag();
		parentTagAttributes = new TagAttributes(dbCon);
		parentTagAttributes.reset(UUID.randomUUID(), parentTagUuid,
				"attribute 1", "false");
		parentTagAttributes.insertTagAttribute();
		parentTagAttributes.reset(UUID.randomUUID(), parentTagUuid,
				"attribute 2", "true");
		parentTagAttributes.insertTagAttribute();
	}

	@AfterClass
	public static void classTeardown() throws Exception {
		md.close();
		ManageDB.deleteDatabase(dbname, hostname, 5432, user, password);
	}

	@Test
	public void testRetrieveAttributesByTagUuid() throws Exception {
		System.out
				.println("It should retrieve the tag attribute by the tag UUID");
		ArrayList<TagAttributes> retrievedTagAttributes = TagAttributes
				.retrieveAttributesByTagUuid(dbCon, parentTagUuid);
		assertEquals("There should be 2 attributes for the retrieved tag",
				retrievedTagAttributes.size(), 2);
	}

}
