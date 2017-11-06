'''
This module is used to validate the HED tags as strings.

Created on Oct 2, 2017

@author: Jeremy Cockfield

'''

from validation import error_reporter, hed_dictionary;
from itertools import compress;
import re;
from validation.hed_dictionary import HedDictionary


class TagValidator:

    REQUIRE_CHILD_ERROR_TYPE = 'requireChild';
    REQUIRED_ERROR_TYPE = 'required';
    TAG_DICTIONARY_KEY = 'tags';
    TILDE_ERROR_TYPE = 'tilde';
    UNIQUE_ERROR_TYPE = 'unique';
    VALID_ERROR_TYPE = 'valid';
    EXTENSION_ALLOWED_ATTRIBUTE = 'extensionAllowed';
    TAKES_VALUE_ATTRIBUTE = 'takesValue';
    IS_NUMERIC_ATTRIBUTE = 'isNumeric';
    UNIT_CLASS_ATTRIBUTE = 'unitClass';
    hed_dictionary = None;
    hed_dictionary_dictionaries = None;

    def __init__(self, hed_dictionary):
        """Constructor for the Tag_Validator class.

        Parameters
        ----------
        hed_dictionary: Hed_Dictionary
            A Hed_Dictionary object.

        Returns
        -------
        TagValidator
            A Tag_Validator object.

        """
        self.hed_dictionary = hed_dictionary;
        self.hed_dictionary_dictionaries = hed_dictionary.get_dictionaries();

    def check_if_tag_is_valid(self, original_tag, formatted_tag):
        """Reports a validation error if the tag provided is not a valid tag or doesn't take a value.

        Parameters
        ----------
        original_tag: string
            The original tag that is used to report the error.
        formatted_tag: string
            The tag that is used to do the validation.
        Returns
        -------
        string
            A validation error string. If no errors are found then an empty string is returned.

        """
        validation_error = '';
        if self.is_extension_allowed_tag(formatted_tag) or self.tag_takes_value(formatted_tag):
            pass;
        elif not self.hed_dictionary_dictionaries[TagValidator.TAG_DICTIONARY_KEY].get(formatted_tag):
            validation_error = error_reporter.report_error_type(TagValidator.VALID_ERROR_TYPE, tag=original_tag);
        return validation_error;

    def is_extension_allowed_tag(self, formatted_tag):
        """Checks to see if the tag has the 'extensionAllowed' attribute. It will strip the tag until there are no more
        slashes to check if its ancestors have the attribute.

        Parameters
        ----------
        formatted_tag: string
            The tag that is used to do the validation.
        Returns
        -------
        boolean
            True if the tag has the 'extensionAllowed' attribute. False, if otherwise.

        """
        tag_slash_indices = self.get_tag_slash_indices(formatted_tag);
        for tag_slash_index in tag_slash_indices:
            tag_substring = self.get_tag_substring_by_end_index(formatted_tag, tag_slash_index);
            if self.hed_dictionary.tag_has_attribute(tag_substring,
                                                     TagValidator.EXTENSION_ALLOWED_ATTRIBUTE):
                return True;
        return False;

    def tag_takes_value(self, formatted_tag):
        """Checks to see if the tag has the 'takesValue' attribute.

        Parameters
        ----------
        formatted_tag: string
            The tag that is used to do the validation.
        Returns
        -------
        boolean
            True if the tag has the 'takesValue' attribute. False, if otherwise.

        """
        last_tag_slash_index = formatted_tag.rfind('/');
        if last_tag_slash_index != -1:
            takes_value_tag = formatted_tag[:last_tag_slash_index] + '/#';
            return self.hed_dictionary.tag_has_attribute(takes_value_tag,
                                                         TagValidator.TAKES_VALUE_ATTRIBUTE);
        return False;

    def is_unit_class_tag(self, formatted_tag):
        """Checks to see if the tag has the 'unitClass' attribute.

        Parameters
        ----------
        formatted_tag: string
            The tag that is used to do the validation.
        Returns
        -------
        boolean
            True if the tag has the 'unitClass' attribute. False, if otherwise.

        """
        last_tag_slash_index = formatted_tag.rfind('/');
        if last_tag_slash_index != -1:
            takes_value_tag = formatted_tag[:last_tag_slash_index] + '/#';
            return self.hed_dictionary.tag_has_attribute(takes_value_tag,
                                                                      TagValidator.UNIT_CLASS_ATTRIBUTE);
        return False;

    def is_numeric_tag(self, formatted_tag):
        """Checks to see if the tag has the 'isNumeric' attribute.

        Parameters
        ----------
        formatted_tag: string
            The tag that is used to do the validation.
        Returns
        -------
        boolean
            True if the tag has the 'isNumeric' attribute. False, if otherwise.

        """
        last_tag_slash_index = formatted_tag.rfind('/');
        if last_tag_slash_index != -1:
            numeric_tag = formatted_tag[:last_tag_slash_index] + '/#';
            print(numeric_tag);
            return self.hed_dictionary.tag_has_attribute(numeric_tag, TagValidator.IS_NUMERIC_ATTRIBUTE);
        return False;

    def check_number_of_group_tildes(self, group_tag_string):
        """Reports a validation error if the tag group has too many tildes.

        Parameters
        ----------
        group_tag_string: string
            A group tag string.
        Returns
        -------
        string
            A validation error string. If no errors are found then an empty string is returned.

        """
        validation_error = '';
        if group_tag_string.count('~') > 2:
            validation_error = error_reporter.report_error_type(TagValidator.TILDE_ERROR_TYPE, group_tag_string);
        return validation_error;


    def check_if_tag_requires_child(self, original_tag, formatted_tag):
        """Reports a validation error if the tag provided has the 'requireChild' attribute.

        Parameters
        ----------
        original_tag: string
            The original tag that is used to report the error.
        formatted_tag: string
            The tag that is used to do the validation.
        Returns
        -------
        string
            A validation error string. If no errors are found then an empty string is returned.

        """
        validation_error = '';
        if self.hed_dictionary_dictionaries[TagValidator.REQUIRE_CHILD_ERROR_TYPE].get(formatted_tag):
            validation_error = error_reporter.report_error_type(TagValidator.REQUIRE_CHILD_ERROR_TYPE,
                                                                tag=original_tag);
        return validation_error;


    def check_for_required_tags(self, formatted_tag_list):
        """Reports a validation error if the required tags aren't present.

        Parameters
        ----------
        original_tag: string
            The original tag that is used to report the error.
        formatted_tag: string
            The tag that is used to do the validation.
        Returns
        -------
        string
            A validation error string. If no errors are found then an empty string is returned.

        """
        validation_error = '';
        required_tag_prefixes = self.hed_dictionary_dictionaries[TagValidator.REQUIRED_ERROR_TYPE];
        for required_tag_prefix in required_tag_prefixes:
            if sum([x.startswith(required_tag_prefix) for x in formatted_tag_list]) < 1:
                validation_error += error_reporter.report_error_type(TagValidator.REQUIRED_ERROR_TYPE,
                                                                     tag_prefix=required_tag_prefix);
        return validation_error;

    def check_if_multiple_unique_tags_exist(self, original_tag_list, formatted_tag_list):
        """Reports a validation error if two or more tags start with a tag prefix that has the 'unique' attribute.

        Parameters
        ----------
        original_tag_list: list
            A list containing tags that are used to report the error.
        formatted_tag_list: list
            A list containing tags that are used to do the validation.
        Returns
        -------
        string
            A validation error string. If no errors are found then an empty string is returned.

        """
        validation_error = '';
        unique_tag_prefixes = self.hed_dictionary_dictionaries[TagValidator.UNIQUE_ERROR_TYPE];
        for unique_tag_prefix in unique_tag_prefixes:
            unique_tag_prefix_boolean_mask = [x.startswith(unique_tag_prefix) for x in formatted_tag_list];
            if sum(unique_tag_prefix_boolean_mask) > 1:
                unique_original_tag_list = list(compress(original_tag_list, unique_tag_prefix_boolean_mask));
                for unique_original_tag in unique_original_tag_list:
                    validation_error += error_reporter.report_error_type(TagValidator.UNIQUE_ERROR_TYPE,
                                                                         tag=unique_original_tag,
                                                                         tag_prefix=unique_tag_prefix);
        return validation_error;

    def get_tag_slash_indices(self, tag, slash='/'):
        """Gets all of the indices in a tag that are slashes.

        Parameters
        ----------
        tag: string
            A tag.
        slash: string
            The slash character. By default it is a forward slash.
        Returns
        -------
        list
            A list containing the indices of the tag slashes.

        """
        return [s.start() for s in re.finditer(slash, tag)];

    def get_tag_substring_by_end_index(self, tag, end_index):
        """Gets a tag substring from the start until the end index.

        Parameters
        ----------
        tag: string
            A tag.
        end_index: int
            A index for the tag substring to end.
        Returns
        -------
        string
            A tag substring.

        """
        if end_index != 0:
            return tag[:end_index]
        return tag;

if __name__ == '__main__':
    print('yes')
    # hed_xml = '../tests/data/HED.xml';
    # tag_dictionaries = tag_dictionary.populate_tag_dictionaries(hed_xml);
