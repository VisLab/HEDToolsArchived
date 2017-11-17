'''
This module is used to split HED tags into dictionaries.

Created on Nov 15, 2017

@author: Jeremy Cockfield

'''


import copy;


class HedStringDelimiter:
    DELIMITER = ',';
    OPENING_GROUP_CHARACTER = '(';
    CLOSING_GROUP_CHARACTER = ')';

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
        self.hed_string = hed_string;
        self.tag_set = self._split_hed_string();

    def get_tag_set(self):
        """Gets the tag_set field.

        Parameters
        ----------
        Returns
        -------
        set
            A set containing the individual tags and tag groups in the hed string. Nested tag groups are not split.

        """
        return self.tag_set;

    def get_nested_group_tags(self):
        nested_group_tags = set();


    def _split_hed_string(self):
        """Splits the tags and non-nested groups in a hed string based on a delimiter. The default delimiter is a comma.

        Parameters
        ----------
        Returns
        -------
        set
            A set containing the individual tags and tag groups in the hed string. Nested tag groups are not split.

        """
        tag_set = set();
        number_of_opening_parentheses = 0;
        number_of_closing_parentheses = 0;
        current_tag = '';
        for character in self.hed_string:
            if character == HedStringDelimiter.OPENING_GROUP_CHARACTER:
                number_of_opening_parentheses += 1;
            if character == HedStringDelimiter.CLOSING_GROUP_CHARACTER:
                number_of_closing_parentheses += 1;
            if number_of_opening_parentheses == number_of_closing_parentheses and character == \
                    HedStringDelimiter.DELIMITER:
                tag_set.add(current_tag.strip());
                current_tag = '';
            else:
                current_tag += character;
        tag_set.add(current_tag.strip());
        return tag_set;

    def get_top_level_tags(self):
        """Gets the top-level tags from a hed string. All group tags will be removed.

        Parameters
        ----------
        Returns
        -------
        set
            A set containing the top level tags.

        """
        top_level_tags = copy.deepcopy(self.tag_set);
        for tag_or_group in self.tag_set:
            if HedStringDelimiter.hed_string_is_a_group(tag_or_group):
                top_level_tags.remove(tag_or_group);
        return top_level_tags;

    @staticmethod
    def hed_string_is_a_group(hed_string):
        """Returns true if

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


if __name__ == '__main__':
    # hed_string = 'tag1,(tag2,tag5,(tag1),tag6),tag2,(tag3,tag5,tag6),tag3';
    # hed_string_delimiter = HedStringDelimiter(hed_string);
    # tags = hed_string_delimiter.get_tag_set();
    is_group = HedStringDelimiter.hed_string_is_a_group(')')
    print(is_group);