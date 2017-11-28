'''
This module is used to split tags in a HED string .

Created on Nov 15, 2017

@author: Jeremy Cockfield

'''


import copy;


class HedStringDelimiter:
    DELIMITER = ',';
    DOUBLE_QUOTE_CHARACTER = '"';
    OPENING_GROUP_CHARACTER = '(';
    CLOSING_GROUP_CHARACTER = ')';
    TILDE = '~';

    def __init__(self, hed_string):
        """Constructor for the HedStringDelimiter class.

        Parameters
        ----------
        hed_string
            A HED string consisting of tags and tag groups.
        Returns
        -------
        HedStringDelimiter object
            A HedStringDelimiter object.

        """
        self.tags = [];
        self.tag_groups = [];
        self.top_level_tags = [];
        self.hed_string = hed_string;
        self.split_hed_string_list = HedStringDelimiter.split_hed_string_into_list(hed_string);
        self._find_top_level_tags();
        self._find_group_tags(self.split_hed_string_list);
        self.formatted_tag_set = HedStringDelimiter.format_hed_tags_in_list(self.tags);
        self.formatted_top_level_tags = HedStringDelimiter.format_hed_tags_in_list(self.top_level_tags);
        self.formatted_tag_groups = HedStringDelimiter.format_hed_tags_in_list(self.tag_groups);

    def get_split_hed_string_list(self):
        """Gets the split_hed_string_list field.

        Parameters
        ----------
        Returns
        -------
        list
            A list containing the individual tags and tag groups in the HED string. Nested tag groups are not split.

        """
        return self.split_hed_string_list;

    def get_hed_string(self):
        """Gets the hed_string field.

        Parameters
        ----------
        Returns
        -------
        string
            The hed string associated with the object.

        """
        return self.hed_string;

    def get_tag_set(self):
        """Gets the tag_set field.

        Parameters
        ----------
        Returns
        -------
        list
            A list containing the individual tags in the HED string.

        """
        return self.tags;

    def get_formatted_tag_groups(self):
        """Gets the formatted_tag_groups field.

        Parameters
        ----------
        Returns
        -------
        list
            A list containing all of the groups with formatted tags.

        """
        return self.formatted_tag_groups;

    def get_formatted_tag_set(self):
        """Gets the formatted_tag_set field.

        Parameters
        ----------
        Returns
        -------
        set
            A set containing the individual formatted tags in the HED string.

        """
        return self.formatted_tag_set;

    def get_top_level_tags(self):
        """Gets the top_level_tags field.

        Parameters
        ----------
        Returns
        -------
        list
            A list containing the top-level tags in a HED string.

        """
        return self.top_level_tags;

    def get_formatted_top_level_tags(self):
        """Gets the formatted_top_level_tags field.

        Parameters
        ----------
        Returns
        -------
        list
            A list containing the top-level formatted tags in a HED string.

        """
        return self.formatted_top_level_tags;

    def get_tag_groups(self):
        """Gets the tag_groups field.

        Parameters
        ----------
        Returns
        -------
        list
            A list of a lists containing all of the tag groups in a HED string. Each list is a tag group.

        """
        return self.tag_groups;

    def _find_group_tags(self, tag_group_list):
        """Finds the tags that are in groups and put them in a set. The groups themselves are also put into a list.

        Parameters
        ----------
        tag_group_list: list
            A list containing the group tags.
        Returns
        -------

        """
        for tag_or_group in tag_group_list:
            if HedStringDelimiter.hed_string_is_a_group(tag_or_group):
                tag_group_string = HedStringDelimiter.remove_group_parentheses(tag_or_group);
                nested_group_tag_list = HedStringDelimiter.split_hed_string_into_list(tag_group_string);
                self._find_group_tags(nested_group_tag_list);
                self.tag_groups.append(nested_group_tag_list);
            elif tag_or_group not in self.tags:
                self.tags.append(tag_or_group);

    def _find_top_level_tags(self):
        """Finds all of the tags at the top-level in a HED string. All group tags will be removed.

        Parameters
        ----------
        Returns
        -------

        """
        self.top_level_tags = copy.copy(self.split_hed_string_list);
        for tag_or_group in self.split_hed_string_list:
            if HedStringDelimiter.hed_string_is_a_group(tag_or_group):
                self.top_level_tags.remove(tag_or_group);
            elif tag_or_group not in self.tags:
                self.tags.append(tag_or_group);

    @staticmethod
    def format_hed_tag(hed_tag):
        """Format a single HED tag. Slashes and double quotes in the beginning and end are removed and the tag is
           converted to lowercase.

        Parameters
        ----------
        hed_tag: string
            A HED tag
        Returns
        -------
        string
            The formatted version of the HED tag.

        """
        hed_tag = hed_tag.strip();
        if hed_tag.startswith('"'):
            hed_tag = hed_tag[1:];
        if hed_tag.endswith('"'):
            hed_tag = hed_tag[:-1];
        if hed_tag.startswith('/'):
            hed_tag = hed_tag[1:];
        if hed_tag.endswith('/'):
            hed_tag = hed_tag[:-1];
        return hed_tag.lower();

    @staticmethod
    def format_hed_tags_in_list(hed_tags_list):
        """Format the HED tags in a list. The list can be nested. Groups are represented as lists themselves.

        Parameters
        ----------
        hed_tags_list: list
            A list containing HED tags. Groups are lists inside of the list.
        Returns
        -------
        list
            A list with the HED tags formatted.

        """
        formatted_hed_tags_list = list();
        for hed_tag_or_hed_tag_group in hed_tags_list:
            if isinstance(hed_tag_or_hed_tag_group, list):
                formatted_tag_group_list = HedStringDelimiter.format_hed_tags_in_list(hed_tag_or_hed_tag_group);
                formatted_hed_tags_list.append(formatted_tag_group_list);
            else:
                formatted_hed_tag = HedStringDelimiter.format_hed_tag(hed_tag_or_hed_tag_group);
                formatted_hed_tags_list.append(formatted_hed_tag);
        return formatted_hed_tags_list;

    @staticmethod
    def format_hed_tags_in_set(hed_tags_set):
        """Format the HED tags in a set.

        Parameters
        ----------
        hed_tags_set: set
            A set containing HED tags.
        Returns
        -------
        string
            The formatted version of the HED tag.

        """
        formatted_hed_tags_set = set();
        for hed_tag in hed_tags_set:
            formatted_hed_tag = HedStringDelimiter.format_hed_tag(hed_tag);
            formatted_hed_tags_set.add(formatted_hed_tag);
        return formatted_hed_tags_set;

    @staticmethod
    def split_hed_string_into_list(hed_string):
        """Splits the tags and non-nested groups in a HED string based on a delimiter. The default delimiter is a comma.

        Parameters
        ----------
        hed_string
            A hed string consisting of tags and tag groups.
        Returns
        -------
        list
            A list containing the individual tags and tag groups in the HED string. Nested tag groups are not split.

        """
        split_hed_string = [];
        number_of_opening_parentheses = 0;
        number_of_closing_parentheses = 0;
        current_tag = '';
        for character in hed_string:
            if character == HedStringDelimiter.DOUBLE_QUOTE_CHARACTER:
                pass;
            if character == HedStringDelimiter.OPENING_GROUP_CHARACTER:
                number_of_opening_parentheses += 1;
            if character == HedStringDelimiter.CLOSING_GROUP_CHARACTER:
                number_of_closing_parentheses += 1;
            if number_of_opening_parentheses == number_of_closing_parentheses and character == HedStringDelimiter.TILDE:
                split_hed_string.append(current_tag.strip());
                split_hed_string.append(HedStringDelimiter.TILDE);
                current_tag = '';
            elif number_of_opening_parentheses == number_of_closing_parentheses and character == \
                    HedStringDelimiter.DELIMITER:
                split_hed_string.append(current_tag.strip());
                current_tag = '';
            else:
                current_tag += character;
        split_hed_string.append(current_tag.strip());
        return split_hed_string;

    @staticmethod
    def hed_string_is_a_group(hed_string):
        """Returns true if the HED string is a group.

        Parameters
        ----------
        hed_string
            A HED string consisting of tags and tag groups.
        Returns
        -------
        boolean
            True if the HED string is a group. False, if not a group.

        """
        hed_string = hed_string.strip();
        if hed_string.startswith(HedStringDelimiter.OPENING_GROUP_CHARACTER) and \
                hed_string.endswith(HedStringDelimiter.CLOSING_GROUP_CHARACTER):
            return True;
        return False;

    @staticmethod
    def remove_group_parentheses(tag_group):
        return tag_group[1:-1];


if __name__ == '__main__':
    # hed_string = 'tag1,(tag2,tag5,(tag1),tag6),tag2,(tag3,tag5,tag6),tag3';
    # hed_string_delimiter = HedStringDelimiter(hed_string);
    # tags = hed_string_delimiter.get_tag_set();
    is_group = HedStringDelimiter.hed_string_is_a_group(')')
    print(is_group);