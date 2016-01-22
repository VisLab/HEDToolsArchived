package edu.utsa.tagger.database;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.UUID;

/**
 * This class represents the Tags table in the database.
 * 
 * @author Lauren Jett, Rebecca Strautman, Thomas Rognon, Jeremy Cockfield, Kay
 *         Robbins
 */
public class Tags {

	/**
	 * Retrieves a tag from the database by its pathname
	 * 
	 * @param dbCon
	 *            a connection to the database
	 * @param pathname
	 *            the pathname of the tag
	 * @return a Tags object representing the tag retrieved
	 * @throws Exception
	 *             if an error occurs
	 */
	public static Tags retrieveTagByPathname(Connection dbCon, String pathname)
			throws Exception {
		Tags tagsTable = new Tags(dbCon);
		try {
			PreparedStatement stmt;
			String query = "SELECT * FROM tags WHERE tag_pathname = ?";
			stmt = dbCon.prepareStatement(query);
			stmt.setString(1, pathname);
			ResultSet rs = stmt.executeQuery();
			if (rs.next()) {
				tagsTable
						.reset((UUID) rs.getObject("tag_uuid"),
								rs.getString("tag_pathname"),
								(UUID) rs.getObject("tag_parent_uuid"),
								rs.getString("tag_description"),
								rs.getInt("tag_count"),
								rs.getString("tag_owner_email"));
			}
		} catch (Exception ex) {
			throw new Exception("Could not get record " + pathname
					+ " from database\n" + ex.getMessage());
		}
		return tagsTable;
	}

	/**
	 * Retrieves a tag from the database by its UUID
	 * 
	 * @param dbCon
	 *            a connection to the database
	 * @param uuid
	 *            the UUID of the tag
	 * @return a Tags object representing the tag retrieved
	 * @throws Exception
	 *             if an error occurs
	 */
	public static Tags retrieveTagByUuid(Connection dbCon, UUID uuid)
			throws Exception {
		Tags tagsTable = new Tags(dbCon);
		try {
			PreparedStatement selectStmt;
			String query = "SELECT * FROM tags WHERE tag_uuid = ?";
			selectStmt = dbCon.prepareStatement(query);
			selectStmt.setObject(1, uuid);
			ResultSet rs = selectStmt.executeQuery();
			if (rs.next()) {
				tagsTable
						.reset((UUID) rs.getObject("tag_uuid"),
								rs.getString("tag_pathname"),
								(UUID) rs.getObject("tag_parent_uuid"),
								rs.getString("tag_description"),
								rs.getInt("tag_count"),
								rs.getString("tag_owner_email"));
			}
		} catch (Exception ex) {
			throw new Exception("Unable to retrieve tags\n" + ex.getMessage());
		}
		return tagsTable;
	}

	/**
	 * Retrieves the tag children UUIDs from the database
	 * 
	 * @param dbCon
	 *            a connection to the database
	 * @param uuid
	 *            the UUID of the tag
	 * @return a ArrayList containing the UUIDs of the tag's children
	 * @throws Exception
	 *             if an error occurs
	 */
	public static ArrayList<UUID> retrieveTagChildrenUuids(Connection dbCon,
			UUID uuid) throws Exception {
		ArrayList<UUID> tagChildrenUuids = new ArrayList<UUID>();
		try {
			PreparedStatement selectStmt;
			if (uuid == null) {
				String query = "SELECT * FROM tags WHERE tag_parent_uuid IS NULL";
				selectStmt = dbCon.prepareStatement(query);
			} else {
				String query = "SELECT * FROM tags WHERE tag_parent_uuid = ?";
				selectStmt = dbCon.prepareStatement(query);
				selectStmt.setObject(1, uuid);
			}
			ResultSet rs = selectStmt.executeQuery();
			while (rs.next())
				tagChildrenUuids.add((UUID) rs.getObject("tag_uuid"));
		} catch (Exception ex) {
			throw new Exception("Unable to retrieve tags\n" + ex.getMessage());
		}
		return tagChildrenUuids;
	}

	/**
	 * Increments the tag count in the database
	 * 
	 * @param dbCon
	 *            a connection to the database
	 * @param pathname
	 *            the pathname of the tag
	 * @return the number of tags updated
	 * @throws Exception
	 *             if an error occurs
	 */
	public static int updateCount(Connection dbCon, String pathname)
			throws Exception {
		int updateCount = 0;
		long time = System.currentTimeMillis();
		String updateQry = "UPDATE tags SET tag_count = tag_count + 1, tag_last_modified = ? WHERE tag_pathname = ?";
		try {
			PreparedStatement stmt = dbCon.prepareStatement(updateQry);
			stmt.setTimestamp(1, new Timestamp(time));
			stmt.setString(2, pathname);
			updateCount = stmt.executeUpdate();
		} catch (Exception ex) {
			throw new Exception("Could not update tag count in database\n"
					+ ex.getMessage());
		}
		return updateCount;
	}

	/**
	 * Updates the tag description in the database
	 * 
	 * @param dbCon
	 *            a connection to the database
	 * @param pathname
	 *            the pathname of the tag
	 * @param description
	 *            the new description of the tag
	 * @return the number of tags updated
	 * @throws Exception
	 *             if an error occurs
	 */
	public static int updateDescription(Connection dbCon, String pathname,
			String description) throws Exception {
		int updateCount = 0;
		String updateQry = "UPDATE tags SET tag_description = ?, tag_last_modified = ? WHERE tag_pathname = ?";
		try {
			PreparedStatement stmt = dbCon.prepareStatement(updateQry);
			stmt.setString(1, description);
			stmt.setTimestamp(2, new Timestamp(System.currentTimeMillis()));
			stmt.setString(3, pathname);
			updateCount = stmt.executeUpdate();
		} catch (Exception ex) {
			throw new Exception("Could not update description in database\n"
					+ ex.getMessage());
		}
		return updateCount;
	}

	/**
	 * Updates when the tag was last modified
	 * 
	 * @param dbCon
	 *            a connection to the database
	 * @param uuid
	 *            the UUID of the tag
	 * @return the number of records updated
	 * @throws Exception
	 *             if an error occurs
	 */
	public static int updateLastModified(Connection dbCon, UUID uuid)
			throws Exception {
		int count = 0;
		String updateQry = "UPDATE tags SET tag_last_modified = ? WHERE tag_uuid = ?";
		try {
			PreparedStatement stmt = dbCon.prepareStatement(updateQry);
			stmt.setTimestamp(1, new Timestamp(System.currentTimeMillis()));
			stmt.setObject(2, uuid);
			count = stmt.executeUpdate();
		} catch (Exception ex) {
			System.err.println(ex.getMessage());
			throw new Exception("Could not update last modified date.");
		}
		return count;
	}

	/**
	 * A connection to the database
	 */
	private Connection dbCon;
	/**
	 * The tag count
	 */
	private int tag_count;
	/**
	 * The tag creation time
	 */
	private Timestamp tag_creation;

	/**
	 * The tag description
	 */
	private String tag_description;

	/**
	 * The time the tag was last modified
	 */
	private Timestamp tag_last_modified;

	/**
	 * The email of the person that created the tag
	 */
	private String tag_owner_email;

	/**
	 * The UUID of the tag's parent
	 */
	private UUID tag_parent_uuid;

	/**
	 * The pathname of the tag
	 */
	private String tag_pathname;

	/**
	 * The UUID of the tag
	 */
	private UUID tag_uuid;

	/**
	 * Creates Tags object
	 * 
	 * @param dbCon
	 *            a connection to the database
	 */
	public Tags(Connection dbCon) {
		this.dbCon = dbCon;
		tag_uuid = null;
		tag_pathname = null;
		tag_parent_uuid = null;
		tag_description = null;
		tag_count = 0;
		tag_creation = null;
		tag_last_modified = null;
		tag_owner_email = null;
	}

	/**
	 * Gets the UUID of the tag's parent
	 * 
	 * @return the UUID of the tag's parent
	 */
	public UUID getParentUuid() {
		return tag_parent_uuid;
	}

	/**
	 * Gets the tag count
	 * 
	 * @return the tag count
	 */
	public int getTagCount() {
		return tag_count;
	}

	/**
	 * Gets the tag creation time
	 * 
	 * @return the tag creation time
	 */
	public Timestamp getTagCreation() {
		return tag_creation;
	}

	/**
	 * Gets the tag description
	 * 
	 * @return the tag description
	 */
	public String getTagDescription() {
		return tag_description;
	}

	/**
	 * Gets time the tag was last modified
	 * 
	 * @return the time the tag was last modified
	 */
	public Timestamp getTagLastModified() {
		return tag_last_modified;
	}

	/**
	 * Gets the email of the person who created the tag
	 * 
	 * @return the email of the person who created the tag
	 */
	public String getTagOwnerEmail() {
		return tag_owner_email;
	}

	/**
	 * Gets the tag pathname
	 * 
	 * @return the pathname of the tag
	 */
	public String getTagPathname() {
		return tag_pathname;
	}

	/**
	 * Gets the tag UUID
	 * 
	 * @return the UUID of the tag
	 */
	public UUID getTagUuid() {
		return tag_uuid;
	}

	/**
	 * Inserts a tag into the database
	 * 
	 * @return the number of tags inserted in the database
	 * @throws Exception
	 *             if an error occurs
	 */
	public int insertTag() throws Exception {
		String insertQry = "INSERT INTO tags (tag_uuid, tag_pathname,  tag_parent_uuid,  tag_description,  "
				+ "tag_count, tag_creation, tag_last_modified, tag_owner_email)"
				+ " VALUES (?,?,?,?,?,?,?,?)";
		int insertCount = 0;
		try {
			PreparedStatement insert = dbCon.prepareStatement(insertQry);
			insert.setObject(1, tag_uuid);
			insert.setString(2, tag_pathname);
			insert.setObject(3, tag_parent_uuid);
			insert.setString(4, tag_description);
			insert.setInt(5, tag_count);
			insert.setTimestamp(6, tag_creation);
			insert.setTimestamp(7, tag_last_modified);
			insert.setString(8, tag_owner_email);
			insertCount = insert.executeUpdate();
		} catch (Exception ex) {
			throw new Exception("Could not save tag in database\n"
					+ ex.getMessage());
		}
		return insertCount;
	}

	/**
	 * Resets the fields of the Tags object
	 * 
	 * @param tag_uuid
	 *            the UUID of the tag
	 * @param tag_pathname
	 *            the pathname of the tag
	 * @param tag_parent_uuid
	 *            the UUID of the tag's parent
	 * @param tag_description
	 *            the description of the tag
	 * @param tag_count
	 *            the count of the tag
	 * @param tag_owner_email
	 *            the email of the person who created the tag
	 */
	public void reset(UUID tag_uuid, String tag_pathname, UUID tag_parent_uuid,
			String tag_description, int tag_count, String tag_owner_email) {
		this.tag_uuid = tag_uuid;
		this.tag_pathname = tag_pathname;
		this.tag_parent_uuid = tag_parent_uuid;
		this.tag_description = tag_description;
		this.tag_count = tag_count;
		this.tag_creation = new Timestamp(System.currentTimeMillis());
		this.tag_last_modified = new Timestamp(System.currentTimeMillis());
		this.tag_owner_email = tag_owner_email;
	}
}