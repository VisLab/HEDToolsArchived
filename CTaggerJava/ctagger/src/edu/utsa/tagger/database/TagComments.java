package edu.utsa.tagger.database;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.UUID;

/**
 * This class represents the tag_comments table in the TagsDB.
 * 
 * @author Lauren Jett, Rebecca Strautman, Thomas Rognon, Jeremy Cockfield, Kay
 *         Robbins
 */
public class TagComments {

	/**
	 * Inserts a tag comment into the database by the tag pathname
	 * 
	 * @param dbCon
	 *            a connection to the database
	 * @param pathname
	 *            the pathname of the tag
	 * @param comment
	 *            a node representing a comment
	 * 
	 */
	public static int insertCommentByPathname(Connection dbCon,
			String pathname, String dateString, String author, String text)
			throws Exception {
		UUID uuid = null;
		int insertCount = 0;
		try {
			Tags tagsTable = Tags.retrieveTagByPathname(dbCon, pathname);
			uuid = tagsTable.getTagUuid();
			SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss");
			Timestamp date;
			if (dateString != null)
				date = new Timestamp(sdf.parse(dateString).getTime());
			else
				date = new Timestamp(System.currentTimeMillis());
			TagComments tagCommentsTable = new TagComments(dbCon);
			tagCommentsTable.reset(UUID.randomUUID(), uuid, date, author, text);
			insertCount = tagCommentsTable.insertTagComment();
		} catch (Exception ex) {
			throw new Exception(
					"Could not insert the comment by its tag pathname\n"
							+ ex.getMessage());
		}
		return insertCount;
	}

	/**
	 * Retrieves the comments associated with a tag
	 * 
	 * @param dbCon
	 *            a connection to the database
	 * @param tagUuid
	 *            the UUID of the tag
	 * @return a TagComments object representing the tag comments retrieved
	 * @throws Exception
	 *             if an error occurs
	 */
	public static ArrayList<TagComments> retrieveCommentsByTagUuid(
			Connection dbCon, UUID tagUuid) throws Exception {
		ArrayList<TagComments> tagComments = new ArrayList<TagComments>();
		String query = "SELECT * FROM tag_comments WHERE tag_comment_tag_uuid = ?";
		try {
			PreparedStatement pStmt = dbCon.prepareStatement(query);
			pStmt.setObject(1, tagUuid);
			ResultSet rs = pStmt.executeQuery();
			while (rs.next()) {
				TagComments tagCommentsTable = new TagComments(dbCon);
				tagCommentsTable.reset(
						UUID.fromString(rs.getString("tag_comment_uuid")),
						UUID.fromString(rs.getString("tag_comment_tag_uuid")),
						rs.getTimestamp("tag_comment_date"),
						rs.getString("tag_comment_author"),
						rs.getString("tag_comment_text"));
				tagComments.add(tagCommentsTable);
			}
		} catch (Exception ex) {
			throw new Exception(
					"Could not retrieve comments from the database\n"
							+ ex.getMessage());
		}
		return tagComments;
	}

	/**
	 * A connection to the database
	 */
	private Connection dbCon;
	/**
	 * The author of the comment
	 */
	private String tag_comment_author;
	/**
	 * The date the comment was created
	 */
	private Timestamp tag_comment_date;
	/**
	 * The UUID of the tag associated with the comment
	 */
	private UUID tag_comment_tag_uuid;

	/**
	 * The text of the comment
	 */
	private String tag_comment_text;

	/**
	 * The UUID of the comment
	 */
	private UUID tag_comment_uuid;

	/**
	 * Creates a TagComments object
	 * 
	 * @param dbCon
	 *            a connection to the database
	 */
	public TagComments(Connection dbCon) {
		this.dbCon = dbCon;
		tag_comment_uuid = null;
		tag_comment_tag_uuid = null;
		tag_comment_date = null;
		tag_comment_author = null;
		tag_comment_text = null;
	}

	/**
	 * Gets the author of the comment
	 * 
	 * @return the author of the comment
	 */
	public String getTagCommentAuthor() {
		return tag_comment_author;
	}

	/**
	 * Gets the date the comment was created
	 * 
	 * @return the date the comment was created
	 */
	public Timestamp getTagCommentDate() {
		return tag_comment_date;
	}

	/**
	 * Gets the UUID of the tag associated with the comment
	 * 
	 * @return the UUID of the tag associated with the comment
	 */
	public UUID getTagCommentTagUuid() {
		return tag_comment_tag_uuid;
	}

	/**
	 * Gets the comment text
	 * 
	 * @return the comment text
	 */
	public String getTagCommentText() {
		return tag_comment_text;
	}

	/**
	 * Gets the UUID of the comment
	 * 
	 * @return the UUID of the comment
	 */
	public UUID getTagCommentUuid() {
		return tag_comment_uuid;
	}

	/**
	 * Inserts a tag comment into the database
	 * 
	 * @return the number of tag comments inserted in the database
	 * @throws Exception
	 *             if an error occurs
	 */
	public int insertTagComment() throws Exception {
		String insertQry = "INSERT INTO tag_comments (tag_comment_uuid, tag_comment_tag_uuid,  "
				+ "tag_comment_date,  tag_comment_author,  tag_comment_text)"
				+ " VALUES (?,?,?,?,?)";
		int insertCount = 0;
		try {
			PreparedStatement insert = dbCon.prepareStatement(insertQry);
			insert.setObject(1, tag_comment_uuid);
			insert.setObject(2, tag_comment_tag_uuid);
			insert.setTimestamp(3, tag_comment_date);
			insert.setString(4, tag_comment_author);
			insert.setString(5, tag_comment_text);
			insertCount = insert.executeUpdate();
			Tags.updateLastModified(dbCon, getTagCommentTagUuid());
		} catch (Exception ex) {
			throw new Exception("Could not save comment to database\n"
					+ ex.getMessage());
		}
		return insertCount;
	}

	/**
	 * Resets the fields of the TagComments object
	 * 
	 * @param tag_comment_uuid
	 *            the UUID of the comment
	 * @param tag_comment_tag_uuid
	 *            the UUID of the tag associated with the comment
	 * @param tag_comment_date
	 *            the date the comment was created
	 * @param tag_comment_author
	 *            the author of the comment
	 * @param tag_comment_text
	 *            the text of the comment
	 */
	public void reset(UUID tag_comment_uuid, UUID tag_comment_tag_uuid,
			Timestamp tag_comment_date, String tag_comment_author,
			String tag_comment_text) {
		this.tag_comment_uuid = tag_comment_uuid;
		this.tag_comment_tag_uuid = tag_comment_tag_uuid;
		this.tag_comment_date = tag_comment_date;
		this.tag_comment_author = tag_comment_author;
		this.tag_comment_text = tag_comment_text;
	}
}
