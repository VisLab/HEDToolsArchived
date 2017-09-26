'''
This module is used to store all HED tag attributes in a dictionary. The dictionary is a dictionary of dictionaries.
Each dictionary pertains to a specific attribute associated with the HED tags.

Created on Sept 21, 2017

@author: Jeremy Cockfield

'''

from defusedxml.lxml import parse;
TAG_ATTRIBUTES = ['extensionAllowed', 'requireChild', 'takesValue', 'isNumeric', 'required', 'recommended', \
                               'position', 'unique', 'predicateType'];
UNIT_ATTRIBUTES = ['default'];

attribute_dictionaries = {};

def populate_unit_attribute_dictionaries(hed_xml_file_path):
    """Populates the dictionaries associated with units in the attribute dictionary.

    Parameters
    ----------
    hed_xml_file_path: string
        The path to a HED XML file.

    Returns
    -------
    dictionary
        The attribute dictionary that has been populated with dictionaries associated with units.

    """
    hed_root_element = get_hed_root_element(hed_xml_file_path);
    for UNIT_ATTRIBUTE in UNIT_ATTRIBUTES:
        attribute_tag_paths = get_tag_paths_by_attribute(hed_root_element, UNIT_ATTRIBUTE);
        tag_attribute_dictionary = string_list_2_lowercase_dictionary(attribute_tag_paths);
        attribute_dictionaries[UNIT_ATTRIBUTE] = tag_attribute_dictionary;
    return attribute_dictionaries;

def populate_tag_attribute_dictionaries(hed_xml_file_path):
    """Populates the dictionaries associated with tags in the attribute dictionary.

    Parameters
    ----------
    hed_xml_file_path: string
        The path to a HED XML file.

    Returns
    -------
    dictionary
        The attribute dictionary that has been populated with dictionaries associated with tags.

    """
    hed_root_element = get_hed_root_element(hed_xml_file_path);
    for TAG_ATTRIBUTE in TAG_ATTRIBUTES:
        attribute_tag_paths = get_tag_paths_by_attribute(hed_root_element, TAG_ATTRIBUTE);
        tag_attribute_dictionary = string_list_2_lowercase_dictionary(attribute_tag_paths);
        attribute_dictionaries[TAG_ATTRIBUTE] = tag_attribute_dictionary;
    return attribute_dictionaries;

def string_list_2_lowercase_dictionary(string_list):
    """Converts a string list into a dictionary. The keys in the dictionary will be the lowercase values of the strings
     in the list.

    Parameters
    ----------
    string_list: list
        A list containing string elements.

    Returns
    -------
    dictionary
        A dictionary containing the strings in the list.

    """
    lowercase_dictionary = {};
    for string_element in string_list:
        lowercase_dictionary[string_element.lower()] = string_element;
    return lowercase_dictionary;


def get_hed_root_element(hed_xml_file_path):
    """Parses a xml file and returns the root element.

    Parameters
    ----------
    hed_xml_file_path: string
        The path to a HED XML file.

    Returns
    -------
    RestrictedElement
        The root element of the HED XML file.

    """
    hed_tree = parse(hed_xml_file_path);
    return hed_tree.getroot();


def get_ancestor_tag_names(tag_element):
    """Gets all the ancestor tag names of a tag element.

    Parameters
    ----------
    tag_element: Element
        A tag element in the HED XML file.

    Returns
    -------
    list
        A list containing all of the ancestor tag names of a given tag.

    """
    ancestor_tags = [];
    try:
        parent_tag_name = get_parent_tag_name(tag_element);
        parent_element = tag_element.getparent();
        while parent_tag_name:
            ancestor_tags.append(parent_tag_name);
            parent_tag_name = get_parent_tag_name(parent_element);
            parent_element = parent_element.getparent();
    except:
        pass;
    return ancestor_tags;

def get_element_name(element):
    """Gets the name of the element.

    Parameters
    ----------
    element: Element
        A element in the HED XML file.

    Returns
    -------
    string
        The name of the tag element. If there is no name then an empty string is returned.

    """
    try:
        return element.find('name').text;
    except:
        return '';

def get_parent_tag_name(tag_element):
    """Gets the name of the tag parent element.

    Parameters
    ----------
    tag_element: Element
        A tag element in the HED XML file.

    Returns
    -------
    string
        The name of the tag element's parent. If there is no parent tag then an empty string is returned.

    """
    try:
        parent_tag_element = tag_element.getparent();
        return parent_tag_element.find('name').text;
    except:
        return '';

def get_tag_path(tag_element):
    """Gets the path of the given tag.

    Parameters
    ----------
    tag_element: Element
        A tag element in the HED XML file.

    Returns
    -------
    string
        The path of the tag. The tag and it's ancestor tags will be separated by /'s.

    """
    try:
        all_tag_names = get_ancestor_tag_names(tag_element);
        all_tag_names.insert(0, get_element_name(tag_element));
        all_tag_names.reverse();
        return '/'.join(all_tag_names);
    except:
        return '';

def get_tag_paths_by_attribute(hed_root_element, tag_attribute_name):
    """Gets the tag paths that have a specific attribute.

    Parameters
    ----------
    hed_root_element: Element
        The root element of the HED XML file.
    tag_attribute_name: string
        The name of the attribute associated with the tag paths.

    Returns
    -------
    list
        A list containing tag paths that have a specified attribute.

    """
    attribute_tag_paths = [];
    try:
        attribute_tags = hed_root_element.xpath('.//node[@%s]' % tag_attribute_name );
        for attribute_tag in attribute_tags:
            attribute_tag_paths.append(get_tag_path(attribute_tag));
    except:
        pass;
    return attribute_tag_paths;

if __name__ == '__main__':
    attribute_dictionary = populate_tag_attribute_dictionaries('../tests/data/HED.xml');
    print(attribute_dictionary);