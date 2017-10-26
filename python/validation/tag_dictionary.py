'''
This module is used to store all HED tags, tag attributes, unit classes, and unit class attributes in a dictionary.
The dictionary is a dictionary of dictionaries.

Created on Sept 21, 2017

@author: Jeremy Cockfield

'''

from defusedxml.lxml import parse;
TAG_ATTRIBUTES = ['extensionAllowed', 'requireChild', 'takesValue', 'isNumeric', 'required', 'recommended', \
                               'position', 'unique', 'predicateType', 'default'];
DEFAULT_UNIT_ATTRIBUTE = 'default';
EXTENSION_ALLOWED_ATTRIBUTE = 'extensionAllowed';
UNIT_CLASS_TAG = 'unitClass';
UNIT_CLASS_UNITS_TAG = 'units';

def populate_tag_dictionaries(hed_xml_file_path):
    """Populates a dictionary containing all of the tags, tag attributes, unit class units, and unit class attributes.

    Parameters
    ----------
    hed_xml_file_path: string
        The path to a HED XML file.

    Returns
    -------
    dictionary
        A dictionary that contains all of the tags, tag attributes, unit class units, and unit class attributes.

    """
    tag_dictionaries = {};
    hed_root_element = get_hed_root_element(hed_xml_file_path);
    unit_class_elements = get_elements_by_tag_name(hed_root_element, UNIT_CLASS_TAG);
    tags, tag_elements = get_tags_by_attribute(hed_root_element, \
                                               DEFAULT_UNIT_ATTRIBUTE);
    tag_dictionaries['tags'] = string_list_2_lowercase_dictionary(get_all_tags(hed_root_element)[0]);
    tag_dictionaries['unitClassUnits'] = populate_unit_class_units_dictionary(unit_class_elements);
    tag_dictionaries['unitClassDefaultUnits'] = populate_unit_class_default_unit_dictionary(unit_class_elements);
    tag_dictionaries['tagDefaultUnits'] = populate_default_unit_tag_dictionary(tags, tag_elements, \
                                                                                 DEFAULT_UNIT_ATTRIBUTE);
    tag_dictionaries.update(populate_tag_attribute_dictionaries(hed_root_element));
    return tag_dictionaries;


def populate_unit_class_units_dictionary(unit_class_elements):
    """Populates a dictionary that contains unit class units.

    Parameters
    ----------
    unit_class_elements: list
        A list of unit class elements.

    Returns
    -------
    dictionary
        A dictionary that contains all the unit class units.

    """
    unit_class_units_dictionary = {};
    for unit_class_element in unit_class_elements:
        unit_class_element_name = get_element_tag_value(unit_class_element);
        unit_class_element_units = get_element_tag_value(unit_class_element, UNIT_CLASS_UNITS_TAG);
        unit_class_units_dictionary[unit_class_element_name] = unit_class_element_units.split(',');
    return unit_class_units_dictionary;

def populate_unit_class_default_unit_dictionary(unit_class_elements):
    """Populates a dictionary that contains unit class default units.

    Parameters
    ----------
    unit_class_elements: list
        A list of unit class elements.

    Returns
    -------
    dictionary
        A dictionary that contains all the unit class default units.

    """
    unit_class_default_unit_dictionary = {};
    for unit_class_element in unit_class_elements:
        unit_class_element_name = get_element_tag_value(unit_class_element);
        unit_class_default_unit_dictionary[unit_class_element_name] = unit_class_element.attrib[DEFAULT_UNIT_ATTRIBUTE];
    return unit_class_default_unit_dictionary;


def populate_tag_attribute_dictionaries(root_element):
    """Populates the dictionaries associated with tags in the attribute dictionary.

    Parameters
    ----------
    root_element: Element
        The root element of the HED XML file.

    Returns
    -------
    dictionary
        A dictionary that has been populated with dictionaries associated with tag attributes.

    """
    tag_attribute_dictionaries = {};
    for TAG_ATTRIBUTE in TAG_ATTRIBUTES:
        attribute_tag_paths, attribute_tag_elements = get_tags_by_attribute(root_element, TAG_ATTRIBUTE);
        if EXTENSION_ALLOWED_ATTRIBUTE == TAG_ATTRIBUTE:
            tag_attribute_dictionary = string_list_2_lowercase_dictionary(attribute_tag_paths);
            leaf_tags = get_all_leaf_tags(root_element);
            tag_attribute_dictionary.update(leaf_tags);
        elif DEFAULT_UNIT_ATTRIBUTE == TAG_ATTRIBUTE:
            tag_attribute_dictionary = populate_default_unit_tag_dictionary(attribute_tag_paths,
                                                                            attribute_tag_elements, TAG_ATTRIBUTE);
        else:
            tag_attribute_dictionary = string_list_2_lowercase_dictionary(attribute_tag_paths);
        tag_attribute_dictionaries[TAG_ATTRIBUTE] = tag_attribute_dictionary;
    return tag_attribute_dictionaries;

def populate_default_unit_tag_dictionary(attribute_tag_paths, attribute_tag_elements, tag_attribute_name):
    """Populates the dictionaries associated with default unit tags in the attribute dictionary.

    Parameters
    ----------
    attribute_tag_paths: string
        A list containing tag paths that have a specified attribute.
    attribute_tag_elements: Element
        The Element that contains the attribute.
    tag_attribute_name: string
        The name of the attribute associated with the tag paths.

    Returns
    -------
    dictionary
        The attribute dictionary that has been populated with dictionaries associated with tags.

    """
    default_unit_tag_dictionary = {};
    for index, attribute_tag_path in enumerate(attribute_tag_paths):
        default_unit_tag_dictionary[attribute_tag_path.lower()] = \
            attribute_tag_elements[index].attrib[tag_attribute_name];
    return default_unit_tag_dictionary;

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

def get_element_tag_value(element, tag_name='name'):
    """Gets the value of the element's tag.

    Parameters
    ----------
    element: Element
        A element in the HED XML file.
    tag_name: string
        The name of the XML element's tag. The default is 'name'.

    Returns
    -------
    string
        The value of the element's tag. If the element doesn't have the tag then it will return an empty string.

    """
    try:
        return element.find(tag_name).text;
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

def get_tag_name_from_tag_element(tag_element):
    """Gets the tag name from a given tag element.

    Parameters
    ----------
    tag_element: Element
        A tag element in the HED XML file.

    Returns
    -------
    string
        A tag. The tag and it's ancestor tags will be separated by /'s.

    """
    try:
        ancestor_tag_names = get_ancestor_tag_names(tag_element);
        ancestor_tag_names.insert(0, get_element_tag_value(tag_element));
        ancestor_tag_names.reverse();
        return '/'.join(ancestor_tag_names);
    except:
        return '';

def get_tags_by_attribute(root_element, tag_attribute_name):
    """Gets the tag that have a specific attribute.

    Parameters
    ----------
    root_element: Element
        The root element of the HED XML file.
    tag_attribute_name: string
        The name of the attribute associated with the tags.

    Returns
    -------
    tuple
        A tuple containing tags and tag elements that have a specified attribute.

    """
    attribute_tags = [];
    try:
        attribute_tag_elements = root_element.xpath('.//node[@%s]' % tag_attribute_name);
        for attribute_tag_element in attribute_tag_elements:
            attribute_tags.append(get_tag_name_from_tag_element(attribute_tag_element));
    except:
        pass;
    return attribute_tags, attribute_tag_elements;


def get_all_tags(root_element, tag_element_name='node'):
    """Gets the tags that have a specific attribute.

    Parameters
    ----------
    root_element: Element
        The root element of the HED XML file.
    tag_element_name: string
        The XML tag name of the tag elements. The default is 'node'.

    Returns
    -------
    tuple
        A tuple containing all the tags and tag elements in the XML file.

    """
    tags = [];
    try:
        tag_elements = root_element.xpath('.//%s' % tag_element_name);
        for tag_element in tag_elements:
            tags.append(get_tag_name_from_tag_element(tag_element));
    except:
        pass;
    return tags, tag_elements;

def get_elements_by_attribute(root_element, attribute_name, element_name='node'):
    """Gets the elements that have a specific attribute.

    Parameters
    ----------
    root_element: Element
        The root element of the HED XML file.
    attribute_name: string
        The name of the attribute associated with the element.
    element_name: string
        The name of the XML element tag name. The default is 'node'.

    Returns
    -------
    list
        A list containing elements that have a specified attribute.

    """
    attribute_elements = [];
    try:
        attribute_elements = root_element.xpath('.//%s[@%s]' % (element_name, attribute_name));
    except:
        pass;
    return attribute_elements;

def get_elements_by_tag_name(root_element, tag_name):
    """Gets the elements that have a specific element name.

    Parameters
    ----------
    root_element: Element
        The root element of the HED XML file.
    tag_name: string
        The name of the element.

    Returns
    -------
    list
        A list containing elements that have a specific element name.

    """
    elements = [];
    try:
        elements = root_element.xpath('.//%s' % tag_name);
    except:
        pass;
    return elements;

def get_all_leaf_tags(root_element, tag_element_name='node', exclude_take_value_tags=True):
    """Gets the tag elements that are leaf nodes.

    Parameters
    ----------
    root_element: Element
        The root element of the HED XML file.
    tag_element_name: string
        The name of the XML tag elements. The default is 'node'.
    exclude_take_value_tags: boolean
        True if to exclude tags that take values. False, if otherwise. The default is True.

    Returns
    -------
    dictionary
        A dictionary containing the tags that are leaf nodes.

    """
    leaf_tags = {};
    tag_elements = get_elements_by_tag_name(root_element, tag_element_name);
    for tag_element in tag_elements:
        if len(get_elements_by_tag_name(tag_element, tag_element_name)) == 0:
            tag_name = get_tag_name_from_tag_element(tag_element);
            if exclude_take_value_tags and tag_name[-1] == '#':
                continue;
            leaf_tags[tag_name.lower()] = tag_name;
    return leaf_tags;

def tag_has_attribute(tag_dictionaries, tag, tag_attribute):
    """Checks to see if the tag has a specific attribute.

    Parameters
    ----------
    tag_dictionaries
        A dictionary that contains all of the tags, tag attributes, unit class units, and unit class attributes.
    tag: string
        A tag.
    tag_attribute: string
        A tag attribute.
    Returns
    -------
    boolean
        True if the tag has the specified attribute. False, if otherwise.

    """
    if tag.lower() in tag_dictionaries[tag_attribute]:
            return True;
    return False;

if __name__ == '__main__':
    root_element = get_hed_root_element('../tests/data/HED.xml');
    leaf_tags = get_all_leaf_tags(root_element, tag_element_name='node', exclude_take_value_tags=False);
    print(len(leaf_tags));
