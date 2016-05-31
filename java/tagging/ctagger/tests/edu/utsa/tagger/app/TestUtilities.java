package edu.utsa.tagger.app;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.net.URISyntaxException;
import java.net.URL;
import java.util.Scanner;

public abstract class TestUtilities {

	public static final String HedFileName = "data/HED.xml";
	public static final String HedRequiredRecommended = 
			"data/testHedRequired.xml";
	public static final String JsonEventsArrays = 
			"data/JSON Events Tag Arrays.txt";
	public static final String saveFileTest = "data/saveFileTest.xml";
	public static final String XmlDataFile = "data/xmlData.xml";
	public static final String DelimitedString = "data/TabDelimitedText.txt";
	public static final String DelimitedString2 = "data/TabDelimitedText2.txt";
	
	public static File getResourceAsFile(String relativePath) 
			throws URISyntaxException {
		URL url = Thread.currentThread().getContextClassLoader()
				.getResource(relativePath);
		File file = new File(url.toURI());
		return file;
	}
	
	public static String getResourceAsString(String relativePath) {
		InputStream inputStream = Thread.currentThread().getContextClassLoader()
				.getResourceAsStream(relativePath);
		Scanner s = new Scanner(inputStream, "UTF-8");
		Scanner s2 = s.useDelimiter("\\A");
		String result = s2.hasNext() ? s2.next() : "";
		s.close();
		s2.close();
		try {
			inputStream.close();
		} catch (IOException e) {
			e.printStackTrace();
		}
		return result;
	}
}
