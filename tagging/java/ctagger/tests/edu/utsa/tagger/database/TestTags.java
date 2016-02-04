package edu.utsa.tagger.database;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;

import java.net.URLDecoder;
import java.sql.Connection;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.UUID;

import org.junit.AfterClass;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;

public class TestTags {

	private static Connection dbCon;
	private static String dbname = "testtagsdb";
	private static String hostname = "localhost";
	private static ManageDB md;
	private static Tags parentTag;
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
	}

	@AfterClass
	public static void classTeardown() throws Exception {
		md.close();
		ManageDB.deleteDatabase(dbname, hostname, 5432, user, password);
	}

	@Test
	public void testRetrieveTagByPathname() throws Exception {
		System.out.println("It should retrieve a tag by its pathname");
		Tags retrievedTag = Tags
				.retrieveTagByPathname(dbCon, parentTagPathname);
		assertEquals(
				"Inserted tag pathname is equal to the retrieved tag pathname",
				retrievedTag.getTagPathname(), parentTagPathname);
	}

	@Test
	public void testRetrieveTagByUuid() throws Exception {
		System.out.println("It should retrieve a tag by its UUID");
		Tags retrievedTag = Tags.retrieveTagByUuid(dbCon, parentTagUuid);
		assertEquals("Inserted tag UUID is equal to the retrieved tag UUID",
				retrievedTag.getTagUuid(), parentTagUuid);
	}

	@Test
	public void testretrieveTagChildrenUuids() throws Exception {
		System.out
				.println("It should retrieve all child UUIDs of a particular tag");
		Tags insertedTag = new Tags(dbCon);
		insertedTag.reset(UUID.randomUUID(), "Student/Grad Student",
				parentTagUuid, null, 0, "test@email.com");
		insertedTag.insertTag();
		insertedTag.reset(UUID.randomUUID(), "Student/Undergrad Student",
				parentTagUuid, null, 0, "test@email.com");
		insertedTag.insertTag();
		ArrayList<UUID> childUuids = Tags.retrieveTagChildrenUuids(dbCon,
				parentTagUuid);
		assertEquals("The number of child UUIDs should be equal to 2",
				childUuids.size(), 2);
	}

	@Before
	public void testSetup() throws Exception {

	}

	@Test
	public void testUpdateCount() throws Exception {
		System.out.println("It should update the count for a particular tag");
		Tags.updateCount(dbCon, parentTagPathname);
		Tags retrievedTag = Tags.retrieveTagByUuid(dbCon, parentTagUuid);
		assertEquals("The updated tag count should be eqaul to 1",
				retrievedTag.getTagCount(), 1);
	}

	@Test
	public void testUpdateDescription() throws Exception {
		System.out
				.println("It should update the description for a particular tag");
		Tags.updateDescription(dbCon, parentTagPathname, "updated description");
		Tags retrievedTag = Tags.retrieveTagByUuid(dbCon, parentTagUuid);
		assertEquals("The tag description should be updated",
				retrievedTag.getTagDescription(), "updated description");
	}

	@Test
	public void testUpdateLastModified() throws Exception {
		System.out.println("It should update when the tag was last modified");
		Timestamp lastModified = parentTag.getTagLastModified();
		Tags.updateLastModified(dbCon, parentTagUuid);
		Tags retrievedTag = Tags.retrieveTagByUuid(dbCon, parentTagUuid);
		assertFalse("The last modified time should be updated", retrievedTag
				.getTagLastModified().equals(lastModified));
	}
}
