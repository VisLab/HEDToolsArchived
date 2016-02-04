package edu.utsa.tagger.database;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Types;
import java.util.ArrayList;
import java.util.UUID;

/**
 * This class represents the Tag_Attributes table in the database.
 * 
 * @author Lauren Jett, Rebecca Strautman, Thomas Rognon, Jeremy Cockfield, Kay
 *         Robbins
 */
public class TagAttributes {

	/**
	 * Retrieves the attributes associated with a tag
	 * 
	 * @param dbCon
	 *            a connection to the database
	 * @param tagUuid
	 *            the UUID of the tag
	 * @return a TagAttributes object representing the tag attributes retrieved
	 * @throws Exception
	 *             if an error occurs
	 */
	public static ArrayList<TagAttributes> retrieveAttributesByTagUuid(
			Connection dbCon, UUID tagUuid) throws Exception {
		ArrayList<TagAttributes> tagAttributes = new ArrayList<TagAttributes>();
		String query = "SELECT * FROM tag_attributes WHERE tag_attribute_tag_uuid = ?";
		try {
			PreparedStatement selectStmt = dbCon.prepareStatement(query);
			selectStmt.setObject(1, tagUuid, Types.OTHER);
			ResultSet rs = selectStmt.executeQuery();
			while (rs.next()) {
				TagAttributes tagAttribute = new TagAttributes(dbCon);
				tagAttribute.reset((UUID) rs.getObject("tag_attribute_uuid"),
						(UUID) rs.getObject("tag_attribute_tag_uuid"),
						rs.getString("tag_attribute_name"),
						rs.getString("tag_attribute_value"));
				tagAttributes.add(tagAttribute);
			}
		} catch (Exception ex) {
			throw new Exception("Unable to retrieve tag attributes\n"
					+ ex.getMessage());
		}
		return tagAttributes;
	}

	/**
	 * A connection to the database
	 */
	private Connection dbCon;
	/**
	 * The name of the tag attribute
	 */
	private String tag_attribute_name;
	/**
	 * The UUID of the tag associated with the attribute
	 */
	private UUID tag_attribute_tag_uuid;
	/**
	 * The UUID of the tag attribute
	 */
	private UUID tag_attribute_uuid;

	/**
	 * The value of the tag attribute
	 */
	private String tag_attribute_value;

	/**
	 * Creates a TagAttributes object
	 * 
	 * @param dbCon
	 *            a connection to the database
	 */
	public TagAttributes(Connection dbCon) {
		this.dbCon = dbCon;
		tag_attribute_uuid = null;
		tag_attribute_tag_uuid = null;
		tag_attribute_name = null;
		tag_attribute_value = null;

	}

	/**
	 * Gets the tag attribute name
	 * 
	 * @return the tag attribute name
	 */
	public String getTagAttributeName() {
		return tag_attribute_name;
	}

	/**
	 * Gets the UUID of the tag associated with the attribute
	 * 
	 * @return the UUID of the tag associated with the attribute
	 */
	public UUID getTagAttributeTagUuid() {
		return tag_attribute_tag_uuid;
	}

	/**
	 * Gets the UUID of the tag attribute
	 * 
	 * @return the UUID of the tag attribute
	 */
	public UUID getTagAttributeUuid() {
		return tag_attribute_uuid;
	}

	/**
	 * Gets the value of the tag attribute
	 * 
	 * @return the value of the tag attribute
	 */
	public String getTagAttributeValue() {
		return tag_attribute_value;
	}

	/**
	 * Inserts the data from the record into the database.
	 * 
	 * @throws Exception
	 *             if an error occurs
	 */
	public int insertTagAttribute() throws Exception {
		String insertQry = "INSERT INTO tag_attributes VALUES (?,?,?,?)";
		int insertCount = 0;
		try {
			PreparedStatement insert = dbCon.prepareStatement(insertQry);
			insert.setObject(1, tag_attribute_uuid);
			insert.setObject(2, tag_attribute_tag_uuid);
			insert.setString(3, tag_attribute_name);
			insert.setString(4, tag_attribute_value);
			insertCount = insert.executeUpdate();
		} catch (Exception ex) {
			System.err.println(ex.getMessage());
			throw new Exception("Could not save to database.");
		}
		return insertCount;
	}

	/**
	 * Resets the fields of the TagAttributes object
	 * 
	 * @param tag_attribute_uuid
	 *            the UUID of the tag attribute
	 * @param tag_attribute_tag_uuid
	 *            the UUID of the tag associated with the attribute
	 * @param tag_attribute_name
	 *            the name of the tag attribute
	 * @param tag_attribute_value
	 *            the value of the tag attribute
	 */
	public void reset(UUID tag_attribute_uuid, UUID tag_attribute_tag_uuid,
			String tag_attribute_name, String tag_attribute_value) {
		this.tag_attribute_uuid = tag_attribute_uuid;
		this.tag_attribute_tag_uuid = tag_attribute_tag_uuid;
		this.tag_attribute_name = tag_attribute_name;
		this.tag_attribute_value = tag_attribute_value;
	}
}