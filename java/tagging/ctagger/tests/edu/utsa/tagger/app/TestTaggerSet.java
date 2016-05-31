package edu.utsa.tagger.app;

import static org.junit.Assert.assertArrayEquals;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;
import static org.junit.Assert.fail;

import java.util.Arrays;
import java.util.Iterator;
import java.util.NoSuchElementException;
import java.util.SortedSet;

import org.junit.Before;
import org.junit.Test;

import edu.utsa.tagger.TaggerSet;

public class TestTaggerSet {
	
	private TaggerSet<String> taggerSet;
	private static final String[] data = {"a", "b", "c", "e", "d"};
	
	private void printTaggerSet() {
		Iterator<String> it = taggerSet.iterator();
		while(it.hasNext()) {
			System.out.print(it.next().toString() + " ");
		}
		System.out.println();
	}
	
	@Before
	public void setUp() {
		taggerSet = new TaggerSet<String>();
	}
	
	@Test
	public void testAdd() {
		System.out.println("It should add the desired data to the set.");
		assertTrue("Add failed", taggerSet.add(data[0]));
		for (int i = 1; i < data.length; i++) {
			if (!taggerSet.add(data[i])) {
				fail("Failed to add " + data[i] + " to set");
			}
		}
		int expectedLength = data.length;
		System.out.println("Added data:");
		printTaggerSet();
		assertEquals("Element was not added to list:", expectedLength, 
				taggerSet.size());
	}
	
	@Test
	public void testAddAll() {
		System.out.println("It should add the elements of the collection only "
				+ "when all can be added, otherwise it should add none.");
		String[] singleElem = {"x"};
		String[] elemsSuccess = {"h", "i", "j"};
		String[] elemsFail = {"w", "q", "r", "b"};
		for (int i = 0; i < data.length; i++) {
			taggerSet.add(data[i]);
		}
		int expectedSize = data.length + 1;
		boolean result = taggerSet.addAll(Arrays.asList(singleElem));
		assertTrue("Add single element failed:", result);
		assertEquals("One element should have been added:", expectedSize, 
				taggerSet.size());
		assertTrue("Failed to find element x:", taggerSet.contains("x"));
		System.out.println("Added x:");
		printTaggerSet();
		expectedSize += 3;
		result = taggerSet.addAll(Arrays.asList(elemsSuccess));
		assertTrue("Add three elements failed:", result);
		assertEquals("Three elements should have been added:", expectedSize, 
				taggerSet.size());
		assertTrue("Failed to find element h:", taggerSet.contains("h"));
		assertTrue("Failed to find element i:", taggerSet.contains("i"));
		assertTrue("Failed to find element j:", taggerSet.contains("j"));
		System.out.println("Added h, i, j:");
		printTaggerSet();
		result = taggerSet.addAll(Arrays.asList(elemsFail));
		assertTrue("Add should have failed:", !result);
		assertEquals("Size should not have changed:", expectedSize, 
				taggerSet.size());
		System.out.println("Added w, q, r, b:");
		printTaggerSet();
		assertTrue("Found element w:", !taggerSet.contains("w"));
		assertTrue("Found element q:", !taggerSet.contains("q"));
		assertTrue("Found element r:", !taggerSet.contains("r"));
	}
	
	@Test
	public void testAddAtIndex() {
		System.out.println("It should add the data to the set, then add an "
				+ "element at the desired index in the set.");
		for (int i = 0; i < data.length; i++) {
			taggerSet.add(data[i]);
		}
		int expectedLength = data.length + 1;
		System.out.println("Added data:");
		printTaggerSet();
		assertTrue("Failed to add x at index 1", taggerSet.add(1, "x"));
		System.out.println("Added x at index 1:");
		printTaggerSet();
		assertEquals("Element was not added to list:", expectedLength, 
				taggerSet.size());
		boolean result = taggerSet.add("x");
		assertTrue("Element was added to set twice", !result);
	}
	
	@Test
	public void testClear() {
		System.out.println("It should clear the set.");
		for (int i = 0; i < data.length; i++) {
			taggerSet.add(data[i]);
		}
		taggerSet.clear();
		int expectedSize = 0;
		assertEquals("Set was not cleared:", expectedSize, taggerSet.size());
	}
	
	@Test
	public void testContains() {
		System.out.println("Contains should return true when the data is in "
				+ "the set and false otherwise.");
		taggerSet.add(data[0]);
		taggerSet.add(data[1]);
		assertTrue("Should contain " + data[1], taggerSet.contains(data[1]));
		assertTrue("Should not contain x", !taggerSet.contains("x"));
	}
	
	@Test
	public void testContainsAll() {
		System.out.println("It should find the desired collection of elements "
				+ "in the set");
		for (int i = 0; i < data.length; i++) {
			taggerSet.add(data[i]);
		}
		String[] setElems = {"a", "c", "d"};
		String[] otherElems = {"a", "d", "x"};
		assertTrue("Failed to find elements a, c, and d:", 
				taggerSet.containsAll(Arrays.asList(setElems)));
		assertTrue("Should not find elements a, d, and x:", 
				!taggerSet.containsAll(Arrays.asList(otherElems)));
	}
	
	@Test
	public void testFirst() {
		System.out.println("Should find the first element in the set.");
		for (int i = 0; i < data.length; i++) {
			taggerSet.add(data[i]);
		}
		String expected = "a";
		String result = taggerSet.first();
		assertEquals("First element in set:", expected, result);
	}
	
	@Test(expected=NoSuchElementException.class)
	public void testFirstException() {
		System.out.println("Should throw an exception when trying to find " 
				+ "first element of empty set.");
		taggerSet.first();
		fail("Should have thrown exception.");
	}
	
	@Test
	public void testHeadSet() {
		String toElement = "c";
		String toElementEmpty = "a";
		for (int i = 0; i < data.length; i++) {
			taggerSet.add(data[i]);
		}
		int expectedSize = 2;
		SortedSet<String> result = taggerSet.headSet(toElement);
		assertEquals("Headset size:", expectedSize, result.size());
		assertTrue("Set should contain a:", result.contains("a"));
		assertTrue("Set should contain b:", result.contains("b"));
		expectedSize = 0;
		result = taggerSet.headSet(toElementEmpty);
		assertEquals("Headset size:", expectedSize, result.size());
	}
	
	@Test
	public void testIsEmpty() {
		System.out.println("It should find the set empty before adding " + 
					"elements and not empty after adding elements.");
		assertTrue("Initial set should be empty", taggerSet.isEmpty());
		taggerSet.add(data[0]);
		assertTrue("Set should not be empty", !taggerSet.isEmpty());
	}
	
	@Test
	public void testLast() {
		System.out.println("Should find the last element in the set.");
		for (int i = 0; i < data.length; i++) {
			taggerSet.add(data[i]);
		}
		String expected = "d";
		String result = taggerSet.last();
		assertEquals("Last element in set:", expected, result);
	}
	
	@Test(expected=NoSuchElementException.class)
	public void testLastException() {
		System.out.println("Should throw an exception when trying to find " 
				+ "last element of empty set.");
		taggerSet.last();
		fail("Should have thrown exception.");
	}
	
	@Test
	public void testRemove() {
		System.out.println("It should remove the desired element and keep all "
				+ "other elements.");
		for (int i = 0; i < data.length; i++) {
			taggerSet.add(data[i]);
		}
		taggerSet.remove(data[1]);
		int expectedSize = data.length - 1;
		assertEquals("Set size should have diminished by 1:", expectedSize, 
				taggerSet.size());
		assertTrue("Set should not contain " + data[1], 
				!taggerSet.contains(data[1]));
		assertTrue("Set should contain " + data[0],
				taggerSet.contains(data[0]));
	}
	
	@Test
	public void testRemoveAll() {
		System.out.println("It should remove elements from the given set.");
		String[] removeNoChange = {"q", "r", "s"};
		String[] removeElems = {"a", "e", "d", "q"};
		for (int i = 0; i < data.length; i++) {
			taggerSet.add(data[i]);
		}
		int expectedSize = data.length;
		boolean result = taggerSet.removeAll(Arrays.asList(removeNoChange));
		assertTrue("Set should not have changed:", !result);
		assertEquals("Set should have remained the same size:", expectedSize, 
				taggerSet.size());
		expectedSize = data.length - 3;
		result = taggerSet.removeAll(Arrays.asList(removeElems));
		assertTrue("Set should have changed:", result);
		assertEquals("Set should have 3 elements removed:", expectedSize,
				taggerSet.size());
		assertTrue("Set contains element a after removal:", 
				!taggerSet.contains("a"));
		assertTrue("Set contains element e after removal:", 
				!taggerSet.contains("e"));
		assertTrue("Set contains element d after removal:", 
				!taggerSet.contains("d"));
	}
	
	@Test
	public void testRetainAll() {
		System.out.println("It should retain elements from the given set.");
		String[] retainElems = {"a", "e", "d", "q"};
		for (int i = 0; i < data.length; i++) {
			taggerSet.add(data[i]);
		}
		boolean result = taggerSet.retainAll(Arrays.asList(data));
		assertTrue("List should not have changed:", !result);
		int expectedSize = 3;
		result = taggerSet.retainAll(Arrays.asList(retainElems));
		assertTrue("Set should have changed:", result);
		assertEquals("Set should have retained expected number of elements:", 
				expectedSize, taggerSet.size());
		System.out.println("Set after retainAll:");
		printTaggerSet();
	}
	
	@Test
	public void testSubSet() {
		System.out.println("It should return a subset given the start and "
				+ "end elements.");
		String fromElem = "b";
		String toElem = "d";
		for (int i = 0; i < data.length; i++) {
			taggerSet.add(data[i]);
		}
		int expectedSize = 3;
		SortedSet<String> result = taggerSet.subSet(fromElem, toElem);
		assertEquals("Size of subset returned:", expectedSize, result.size());
		assertTrue("Set should contain b:", result.contains("b"));
		assertTrue("Set should contain c:", result.contains("c"));
		assertTrue("Set should contain e:", result.contains("e"));
	}
	
	@Test
	public void testTailSet() {
		String toElement = "c";
		String toElementEnd = "d";
		for (int i = 0; i < data.length; i++) {
			taggerSet.add(data[i]);
		}
		int expectedSize = 3;
		SortedSet<String> result = taggerSet.tailSet(toElement);
		assertEquals("Tailset size:", expectedSize, result.size());
		assertTrue("Set should contain c:", result.contains("c"));
		assertTrue("Set should contain e:", result.contains("e"));
		assertTrue("Set should contain d:", result.contains("d"));
		expectedSize = 1;
		result = taggerSet.tailSet(toElementEnd);
		assertEquals("Tailset size:", expectedSize, result.size());
	}
	
	@Test
	public void testToArray() {
		Object[] expected = (Object[]) data;
		for (int i = 0; i < data.length; i++) {
			if (!taggerSet.add(data[i])) {
				fail("Failed to add " + data[i] + " to set");
			}
		}
		Object[] result = taggerSet.toArray();
		assertArrayEquals("Array returned not equal:", expected, result);
	}
	
	@Test
	public void testToArrayParam() {
		System.out.println("It should return an array containing all of the " 
				+ "elements for short and long parameters.");
		String[] a = new String[3];
		String[] b = new String[6];
		String[] expectedA = data;
		String[] expectedB = new String[6];
		for (int i = 0; i < data.length; i++) {
			expectedB[i] = data[i];
		}
		for (int i = 0; i < data.length; i++) {
			taggerSet.add(data[i]);
		}
		String[] resultA = (String[]) taggerSet.toArray(a);
		String[] resultB = (String[]) taggerSet.toArray(b);
		assertArrayEquals("Array return not equal for short array:", expectedA, 
				resultA);
		assertArrayEquals("Array return not equal for long array:", expectedB, 
				resultB);
	}
}
