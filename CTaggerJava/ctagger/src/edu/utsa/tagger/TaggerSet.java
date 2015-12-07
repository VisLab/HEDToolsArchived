package edu.utsa.tagger;

import java.util.Collection;
import java.util.Collections;
import java.util.Comparator;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.ListIterator;
import java.util.NoSuchElementException;
import java.util.SortedSet;

/**
 * This class represents an ordered set with order that can be changed
 * dynamically; can used for tags and events.
 * 
 * @author Lauren Jett, Rebecca Strautman, Thomas Rognon, Jeremy Cockfield, Kay
 *         Robbins
 */
public class TaggerSet<E extends Comparable<? super E>> implements SortedSet<E> {

	private LinkedList<E> set;

	public TaggerSet() {
		set = new LinkedList<E>();
	}

	private TaggerSet(List<E> data) {
		set = new LinkedList<E>();
		set.addAll(data);
	}

	/**
	 * Appends the specified element to the end of this ordered set if it was
	 * not already contained in the set.
	 * 
	 * @param element
	 *            The element to append to the set.
	 * @return True if the element was added to the end of the ordered set,
	 *         false if not.
	 */
	@Override
	public boolean add(E elem) {
		if (!set.contains(elem)) {
			return set.add(elem);
		}
		return false;
	}

	/**
	 * Appends the specified element to the end of this ordered set. If
	 * allowDuplicate is true, a duplicate element can be added.
	 * 
	 * @param elem
	 *            The element to add.
	 * @param allowDuplicate
	 *            True if element can be a duplicate, false if otherwise.
	 * @return
	 */
	public boolean add(E elem, boolean allowDuplicate) {
		if (!set.contains(elem) || allowDuplicate) {
			return set.add(elem);
		}
		return false;
	}

	/**
	 * Inserts the element at the specified position in this ordered set if the
	 * element was not already in the set.
	 * 
	 * @param index
	 *            Index at which to add element
	 * @param element
	 *            Element to add to ordered set
	 * @return True if the element was successfully added at the given index;
	 *         false otherwise (if the element was already part of the set)
	 */
	public boolean add(int index, E element) {
		if (!set.contains(element)) {
			ListIterator<E> it = set.listIterator(index);
			it.add(element);
			return true;
		}
		return false;
	}

	/**
	 * Inserts the element at the specified position in this ordered set if the
	 * element was not already in the set.
	 * 
	 * @param index
	 *            Index at which to add element
	 * @param element
	 *            Element to add to ordered set
	 * @param allowDuplicate
	 *            True if element can be a duplicate, false if otherwise.
	 * @return True if the element was successfully added at the given index;
	 *         false otherwise (if the element was already part of the set)
	 */
	public boolean add(int index, E element, boolean allowDuplicate) {
		if (!set.contains(element) || allowDuplicate) {
			ListIterator<E> it = set.listIterator(index);
			it.add(element);
			return true;
		}
		return false;
	}

	/**
	 * Attempts to add all items in the passed collection to this sorted set. If
	 * any items from the collection are already in the set, the add fails and
	 * none of the items are added.
	 * 
	 * @param c
	 *            Collection of elements to add to the sorted set
	 * @return True if the elements were successfully added to the list; false
	 *         otherwise (if any of the elements were already part of the set)
	 */
	@SuppressWarnings({ "rawtypes", "unchecked" })
	@Override
	public boolean addAll(Collection c) {
		for (Object o : c) {
			if (set.contains(o)) {
				return false;
			}
		}
		for (Object o : c) {
			set.add((E) o);
		}
		return true;
	}

	@Override
	public void clear() {
		set.clear();
	}

	@Override
	public Comparator<E> comparator() {
		return null;
	}

	@Override
	public boolean contains(Object o) {
		return set.contains(o);
	}

	@SuppressWarnings("rawtypes")
	@Override
	public boolean containsAll(Collection c) {
		return set.containsAll(c);
	}

	@Override
	public E first() throws NoSuchElementException {
		if (set.size() > 0) {
			return set.get(0);
		} else {
			throw new NoSuchElementException();
		}
	}

	public E get(int index) {
		return set.get(index);
	}

	/**
	 * Returns all elements that come before the given parameter in this sorted
	 * set
	 * 
	 * @param toElement
	 *            The high endpoint (exclusive) of the returned set
	 * @return a sorted set containing all elements before the passed parameter
	 */
	@Override
	public SortedSet<E> headSet(E toElement) {
		List<E> data = set.subList(0, set.indexOf((toElement)));
		return new TaggerSet<E>(data);
	}

	public int indexOf(E element) {
		return set.indexOf(element);
	}

	@Override
	public boolean isEmpty() {
		return set.isEmpty();
	}

	@Override
	public Iterator<E> iterator() {
		return set.iterator();
	}

	@Override
	public E last() {
		if (set.size() > 0) {
			return set.get(set.size() - 1);
		} else {
			throw new NoSuchElementException();
		}
	}

	@Override
	public boolean remove(Object o) {
		return set.remove(o);
	}

	@SuppressWarnings("rawtypes")
	@Override
	public boolean removeAll(Collection c) {
		return set.removeAll(c);
	}

	@SuppressWarnings("rawtypes")
	@Override
	public boolean retainAll(Collection c) {
		return set.retainAll(c);
	}

	@Override
	public int size() {
		return set.size();
	}

	public void sort(Comparator<E> comparator) {
		Collections.sort(set, comparator);
	}

	@Override
	public SortedSet<E> subSet(E fromElement, E toElement) {
		List<E> data = set.subList(set.indexOf(fromElement),
				set.indexOf(toElement));
		return new TaggerSet<E>(data);
	}

	@Override
	public SortedSet<E> tailSet(E fromElement) {
		List<E> data = set.subList(set.indexOf(fromElement), set.size());
		return new TaggerSet<E>(data);
	}

	@Override
	public Object[] toArray() {
		return set.toArray();
	}

	@SuppressWarnings("unchecked")
	@Override
	public Object[] toArray(Object[] a) {
		return set.toArray(a);
	}
}
