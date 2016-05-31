package edu.utsa.tagger.database;

import java.io.DataInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.sql.Connection;
import java.sql.PreparedStatement;

public class TestTools {

	public static String TEST_EVENTS_JSON1 = "[ {" + "    \"code\" : \"1111\","
			+ "\"tags\" : [" + "[\"/Event/Label/some event 1\"],"
			+ "[\"/Event/Description/some event 1's description\"]" + "]"
			+ "}, { " + "    \"code\" : \"1123\"," + "    \"tags\" : ["
			+ "[\"/Event/Label/some event 2\"],"
			+ "[\"/Event/Description/some event 2's description\"]" + "]"
			+ "}, {  " + "   \"code\" : \"1143\"," + "    \"tags\" : ["
			+ "[\"/Event/Label/some event 3\"],"
			+ "[\"/Event/Description/some event 3's description\"],"
			+ "[\"/Item/3D shape/Box/Cube\"]" + "] " + "  } ]";

	public static String TEST_EVENTS_JSON2 = "[ {" + "\"code\" : \"1111\","
			+ "\"tags\" : [" + "[\"/Event/Label/some event 1\"],"
			+ "[\"/Event/Description/some event 1's description\"]," + "["
			+ "\"/Sensory presentation/Taste\","
			+ "\"/Item/Object/Person/Pedestrian\"" + "]]" + "}, {"
			+ "\"code\" : \"1123\"," + "\"tags\" : ["
			+ "[\"/Event/Label/some event 2\"],"
			+ "[\"/Event/Description/some event 2's description\"]," + "["
			+ "\"/Item/Object/Person/Mother-child\"," + "\"/Item/Object/Food\""
			+ "]]" + "}, {" + "\"code\" : \"1143\"," + "\"tags\" : ["
			+ "[\"/Event/Label/some event 3\"],"
			+ "[\"/Event/Description/some event 3's description\"]," + "["
			+ "\"/Item/3D shape/Sphere\"," + "\"/Item/Object/Animal\"" + "]]"
			+ "  } ]";

	public static String TEST_EVENTS_NON_JSON1 = "1111,"
			+ "/Event/Label/some event 1,/Event/Description/some event 1's description;"
			+ "1123,/Event/Label/some event 2, /Event/Description/some event 2's description;"
			+ "1143,/Event/Label/some event 3, /Event/Description/some event 3's description,Item/3D shape/Box/Cube";

	public static String TEST_EVENTS_NON_JSON2 = "1111,"
			+ "/Event/Label/some event 1,/Event/Description/some event 1's description, /Sensory presentation/Taste, /Item/Object/Person/Pedestrian;"
			+ "1123,/Event/Label/some event 2, /Event/Description/some event 2's description, /Item/Object/Person/Mother-child, /Item/Object/Food;"
			+ "1143,/Event/Label/some event 3, /Event/Description/some event 3's description,/Item/3D shape/Sphere, /Item/Object/Animal";

	/**
	 * Removes all information from all tables of the TagsDB database
	 * 
	 * @return an integer representing the number of records deleted
	 */
	public static void clearDB(Connection dbCon) {
		try {
			clearTagsTable(dbCon);
			clearTagAttributesTable(dbCon);
			clearTagCommentsTable(dbCon);
		} catch (Exception ex) {

		}
	}

	/**
	 * Removes all information from the tag_attributes table of the TagsDB
	 * database
	 * 
	 * @param dbCon
	 *            a Connection to the TagsDB database
	 * @return an integer representing the number of records deleted
	 * @throws Exception
	 *             Exception when database DELETE fails
	 */
	private static void clearTagAttributesTable(Connection dbCon)
			throws Exception {
		String deleteQry = "DELETE FROM tag_attributes";
		try {
			PreparedStatement delete = dbCon.prepareStatement(deleteQry);
			delete.executeUpdate();
		} catch (Exception ex) {
			throw new Exception(
					"Could not delete all records from attributes table\n"
							+ ex.getMessage());
		}
	}

	/**
	 * Removes all information from the tag_comments table of the TagsDB
	 * database
	 * 
	 * @param dbCon
	 *            a Connection to the TagsDB database
	 * @return an integer representing the number of records deleted
	 * @throws Exception
	 *             Exception when database DELETE fails
	 */
	private static void clearTagCommentsTable(Connection dbCon)
			throws Exception {
		String deleteQry = "DELETE FROM tag_comments";
		try {
			PreparedStatement delete = dbCon.prepareStatement(deleteQry);
			delete.executeUpdate();
		} catch (Exception ex) {
			throw new Exception(
					"Could not delete all records from comments table\n"
							+ ex.getMessage());
		}
	}

	/**
	 * Removes all information from the tags table of the TagsDB database
	 * 
	 * @param dbCon
	 *            a Connection to the TagsDB database
	 * @return an integer representing the number of records deleted
	 * @throws Exception
	 *             when database DELETE fails
	 */
	private static void clearTagsTable(Connection dbCon) throws Exception {
		String deleteQry = "DELETE FROM tags";
		try {
			PreparedStatement delete = dbCon.prepareStatement(deleteQry);
			delete.executeUpdate();
		} catch (Exception ex) {
			throw new Exception(
					"Could not delete all records from tags table\n"
							+ ex.getMessage());
		}
	}

	/**
	 * Converts a file a string for testing purposes.
	 * 
	 * @param file
	 *            pathname of file to read
	 * @return String of the file's contents
	 * @throws Exception
	 *             when unable to read file
	 */
	public static String fileToString(String file) throws Exception {
		String result = null;
		DataInputStream in = null;

		File f = new File(file);
		byte[] buffer = new byte[(int) f.length()];
		in = new DataInputStream(new FileInputStream(f));
		in.readFully(buffer);
		result = new String(buffer);
		in.close();
		return result;
	}

	/**
	 * Gets a string from a file by appending the filename to the current
	 * pathname and reading from it (for testing purposes).
	 * 
	 * @param filename
	 *            name of file to read in
	 * @return String of the file's contents
	 * @throws Exception
	 *             when unable to read file
	 */
	public static String getString(String filename) throws Exception {
		String xmlString = null;
		xmlString = fileToString("./bin/data/" + filename);
		return xmlString;
	}

}
