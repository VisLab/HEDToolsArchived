'''
This module is used to split HED tags into dictionaries.

Created on Nov 15, 2017

@author: Jeremy Cockfield

'''


class HedStringDelimiter:
    DELIMITER = ',';
    OPENING_GROUP_CHARACTER = '(';
    CLOSING_GROUP_CHARACTER = ')';

    def __init__(self, hed_string):
        self.hed_string = hed_string;
        self.top_level_tag_set = self.split_top_level_hed_string_tags();

    def split_top_level_hed_string_tags(self):
        """Splits the top-level tags and groups in a hed string based on a delimiter. The default delimiter is a comma.

        Parameters
        ----------
        hed_string: string
            A hed string.
        Returns
        -------
        set
            A set containing the individual tags and tag groups at the top-level of the hed string.

        """
        top_level_tag_set = set();
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
                top_level_tag_set.add(current_tag.strip());
                current_tag = '';
            else:
                current_tag += character;
        top_level_tag_set.add(current_tag.strip());
        return top_level_tag_set;

if __name__ == '__main__':
    hed_string = 'tag1,(tag2,tag5,(tag1),tag6),tag2,(tag3,tag5,tag6),tag3';
    hed_string_delimiter = HedStringDelimiter(hed_string);
    tags = hed_string_delimiter.split_top_level_hed_string_tags(hed_string);
    for tag in tags:
        print(tag);