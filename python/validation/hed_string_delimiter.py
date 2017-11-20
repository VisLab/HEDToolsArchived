'''
This module is used to split tags in a HED string .

Created on Nov 15, 2017

@author: Jeremy Cockfield

'''


import copy;


class HedStringDelimiter:
    DELIMITER = ',';
    OPENING_GROUP_CHARACTER = '(';
    CLOSING_GROUP_CHARACTER = ')';
    TILDE = '~';

    def __init__(self, hed_string):
        """Constructor for the HedStringDelimiter class.

        Parameters
        ----------
        hed_string
            A hed string consisting of tags and tag groups.
        Returns
        -------
        HedStringDelimiter object
            A HedStringDelimiter object.

        """
        self.tag_set = set();
        self.tag_groups = [];
        self.hed_string = hed_string;
        self.split_hed_string = HedStringDelimiter.split_hed_string(hed_string);
        self._find_top_level_tags();
        self._find_group_tags(self.split_hed_string);

    def get_split_hed_string(self):
        """Gets the split_hed_string field.

        Parameters
        ----------
        Returns
        -------
        list
            A list containing the individual tags and tag groups in the hed string. Nested tag groups are not split.

        """
        return self.split_hed_string;

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
        set
            A set containing the individual tags in the hed string.

        """
        return self.tag_set;

    def get_top_level_tags(self):
        """Gets the top_level_tags field.

        Parameters
        ----------
        Returns
        -------
        set
            A set containing the individual tags and tag groups in the hed string. Nested tag groups are not split.

        """
        return self.top_level_tags;

    def get_tag_groups(self):
        """Gets the tag_groups field.

        Parameters
        ----------
        Returns
        -------
        list
            A list of a lists containing all of the tag groups in a hed string. Each list is a tag group.

        """
        return self.tag_groups;

    def _find_group_tags(self, group_tag_set):
        """Finds the tags that are in groups and put them in a set. The groups themselves are also put into a list.

        Parameters
        ----------
        group_tag_set
            A set containing the group tags.
        Returns
        -------

        """
        for tag_or_group in group_tag_set:
            if HedStringDelimiter.hed_string_is_a_group(tag_or_group):
                tag_group = HedStringDelimiter.remove_group_parentheses(tag_or_group)
                nested_group_tag_set = HedStringDelimiter.split_hed_string(tag_group);
                self._find_group_tags(nested_group_tag_set);
                self.tag_groups.append(nested_group_tag_set);
            else:
                self.tag_set.add(tag_or_group);

    def _find_top_level_tags(self):
        """Finds all of the tags at the top-level in a hed string. All group tags will be removed.

        Parameters
        ----------
        split_hed_string
            A list containing the individual tags and tag groups in the hed string. Nested tag groups are not split.
        Returns
        -------

        """
        self.top_level_tags = copy.copy(self.split_hed_string);
        for tag_or_group in self.split_hed_string:
            if HedStringDelimiter.hed_string_is_a_group(tag_or_group):
                self.top_level_tags.remove(tag_or_group);
            else:
                self.tag_set.add(tag_or_group);

    @staticmethod
    def split_hed_string(hed_string):
        """Splits the tags and non-nested groups in a hed string based on a delimiter. The default delimiter is a comma.

        Parameters
        ----------
        hed_string
            A hed string consisting of tags and tag groups.
        Returns
        -------
        list
            A list containing the individual tags and tag groups in the hed string. Nested tag groups are not split.

        """
        split_hed_string = [];
        number_of_opening_parentheses = 0;
        number_of_closing_parentheses = 0;
        current_tag = '';
        for character in hed_string:
            if character == HedStringDelimiter.OPENING_GROUP_CHARACTER:
                number_of_opening_parentheses += 1;
            if character == HedStringDelimiter.CLOSING_GROUP_CHARACTER:
                number_of_closing_parentheses += 1;
            if character == HedStringDelimiter.TILDE:
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
        """Returns true if the hed string is a group.

        Parameters
        ----------
        hed_string
            A hed string consisting of tags and tag groups.
        Returns
        -------
        boolean
            True if the hed string is a group. False, if not a group.

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