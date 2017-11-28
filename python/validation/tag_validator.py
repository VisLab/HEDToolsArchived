'''
This module is used to validate the HED tags as strings.

Created on Oct 2, 2017

@author: Jeremy Cockfield

'''

from validation import error_reporter, warning_reporter;
from itertools import compress;
import re;
from hed_dictionary import HedDictionary


class TagValidator:
    BRACKET_ERROR_TYPE = 'bracket';
    CAMEL_CASE_EXPRESSION = '([A-Z-]+\s*[a-z-]*)+';
    DEFAULT_UNIT_ATTRIBUTE = 'default';
    DIGIT_EXPRESSION = '^\d+$';
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
    UNIT_CLASS_UNITS_ELEMENT = 'units';
    TILDE = '~';
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

    def run_individual_tag_validators(self, original_tag, formatted_tag, check_for_warnings=False):
        validation_issues = '';
        validation_issues += self.check_if_tag_is_valid(original_tag, formatted_tag);
        validation_issues += self.check_if_tag_unit_class_units_are_valid(original_tag, formatted_tag);
        validation_issues += self.check_if_tag_unit_class_units_are_valid(original_tag, formatted_tag);
        validation_issues += self.check_if_tag_requires_child(original_tag, formatted_tag);
        if check_for_warnings:
            validation_issues += self.check_if_tag_unit_class_units_exist(original_tag, formatted_tag);
            validation_issues += self.check_capitalization(original_tag, formatted_tag);
        return validation_issues;

    def run_tag_group_validators(self, tag_group):
        validation_issues = '';
        validation_issues += self.check_number_of_group_tildes(tag_group);
        return validation_issues;

    def run_pre_validator(self, hed_string):
        return self.count_tag_group_brackets(hed_string);

    def run_tag_level_validators(self, original_tag_list, formatted_tag_list):
        validation_issues = '';
        validation_issues += self.check_if_multiple_unique_tags_exist(original_tag_list, formatted_tag_list);
        return validation_issues;

    def run_top_level_validators(self, formatted_top_level_tags):
        validation_issues = '';
        validation_issues += self.check_for_required_tags(formatted_top_level_tags);
        return validation_issues;

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
        if self.is_extension_allowed_tag(formatted_tag) or self.tag_takes_value(formatted_tag) or \
                        formatted_tag == TagValidator.TILDE:
            pass;
        elif not self.hed_dictionary_dictionaries[TagValidator.TAG_DICTIONARY_KEY].get(formatted_tag):
            validation_error = error_reporter.report_error_type(TagValidator.VALID_ERROR_TYPE, tag=original_tag);
        return validation_error;

    def check_capitalization(self, original_tag, formatted_tag):
        """Reports a validation warning if the tag isn't correctly capitalized.

        Parameters
        ----------
        original_tag: string
            The original tag that is used to report the warning.
        formatted_tag: string
            The tag that is used to do the validation.
        Returns
        -------
        string
            A validation warning string. If no warnings are found then an empty string is returned.

        """
        validation_warning = '';
        tag_names = original_tag.split("/");
        if not self.tag_takes_value(formatted_tag):
            for tag_name in tag_names:
                correct_tag_name = tag_name.capitalize();
                if tag_name != correct_tag_name and not re.search(self.CAMEL_CASE_EXPRESSION, tag_name):
                    validation_warning = warning_reporter.report_warning_type("cap", tag=original_tag);
                    break;
            return validation_warning;

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
        takes_value_tag = self.replace_tag_name_with_pound(formatted_tag);
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
        takes_value_tag = self.replace_tag_name_with_pound(formatted_tag);
        return self.hed_dictionary.tag_has_attribute(takes_value_tag,
                                                     TagValidator.UNIT_CLASS_ATTRIBUTE);

    def replace_tag_name_with_pound(self, formatted_tag):
        """Replaces the tag name with the pound sign.

        Parameters
        ----------
        formatted_tag: string
            The tag that is used to do the validation.
        Returns
        -------
        string
            A tag with the a pound sign in place of it's name.

        """
        pound_sign_tag = '#';
        last_tag_slash_index = formatted_tag.rfind('/');
        if last_tag_slash_index != -1:
            pound_sign_tag = formatted_tag[:last_tag_slash_index] + '/#';
        return pound_sign_tag;

    def check_if_tag_unit_class_units_are_valid(self, original_tag, formatted_tag):
        """Reports a validation error if the tag provided has a unit class and the units are incorrect.

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
        if self.is_unit_class_tag(formatted_tag):
            tag_unit_class_units = tuple(self.get_tag_unit_class_units(formatted_tag));
            tag_unit_values = self.get_tag_name(formatted_tag);
            if not re.search(TagValidator.DIGIT_EXPRESSION, tag_unit_values) and \
                    not tag_unit_values.startswith(tag_unit_class_units) and \
                    not tag_unit_values.endswith(tag_unit_class_units):
                validation_error = error_reporter.report_error_type('unitClass', tag=original_tag,
                                                                    unit_class_units=','.join(tag_unit_class_units));
        return validation_error;

    def check_if_tag_unit_class_units_exist(self, original_tag, formatted_tag):
        """Reports a validation warning if the tag provided has a unit class but no units are not specified.

        Parameters
        ----------
        original_tag: string
            The original tag that is used to report the error.
        formatted_tag: string
            The tag that is used to do the validation.
        Returns
        -------
        string
            A validation warning string. If no errors are found then an empty string is returned.

        """
        validation_warning = '';
        if self.is_unit_class_tag(formatted_tag):
            tag_unit_values = self.get_tag_name(formatted_tag);
            if re.search(TagValidator.DIGIT_EXPRESSION, tag_unit_values):
                default_unit = self.get_unit_class_default_unit(formatted_tag);
                validation_warning = warning_reporter.report_warning_type('unitClass', tag=original_tag,
                                                                          default_unit=default_unit);
        return validation_warning;

    def get_tag_name(self, tag):
        """Gets the tag name from the tag path

        Parameters
        ----------
        tag: string
            A tag which is a path.
        Returns
        -------
        string
            The tag name.

        """
        tag_name = tag;
        tag_slash_indices = self.get_tag_slash_indices(tag);
        if tag_slash_indices:
            tag_name = tag[tag_slash_indices[-1] + 1:]
        return tag_name;

    def get_tag_unit_class_units(self, formatted_tag):
        """Gets the unit class units associated with a particular tag.

        Parameters
        ----------
        formatted_tag: string
            The tag that is used to do the validation.
        Returns
        -------
        list
            A list containing the unit class units associated with a particular tag. A empty list will be returned if
            the tag doesn't have unit class units associated with it.

        """
        units = [];
        unit_class_tag = self.replace_tag_name_with_pound(formatted_tag);
        if self.is_unit_class_tag(formatted_tag):
            unit_classes = self.hed_dictionary_dictionaries[TagValidator.UNIT_CLASS_ATTRIBUTE][unit_class_tag];
            unit_classes = unit_classes.split(',');
            for unit_class in unit_classes:
                units += (self.hed_dictionary_dictionaries[TagValidator.UNIT_CLASS_UNITS_ELEMENT][unit_class]);
        return map(str.lower, units);

    def get_unit_class_default_unit(self, formatted_tag):
        """Gets the default unit class unit that is associated with the specified tag.

        Parameters
        ----------
        formatted_tag: string
            The tag that is used to do the validation.
        Returns
        -------
        string
            The default unit class unit associated with the specific tag. If the tag doesn't have a unit class then an
            empty string is returned.

        """
        default_unit = '';
        unit_class_tag = self.replace_tag_name_with_pound(formatted_tag);
        if self.is_unit_class_tag(formatted_tag):
            has_default_attribute = self.hed_dictionary.tag_has_attribute(formatted_tag,
                                                                          TagValidator.DEFAULT_UNIT_ATTRIBUTE);
            if has_default_attribute:
                default_unit = self.hed_dictionary_dictionaries[TagValidator.DEFAULT_UNIT_ATTRIBUTE][formatted_tag];
            elif unit_class_tag in self.hed_dictionary_dictionaries[TagValidator.UNIT_CLASS_ATTRIBUTE]:
                unit_classes = \
                    self.hed_dictionary_dictionaries[TagValidator.UNIT_CLASS_ATTRIBUTE][unit_class_tag].split(',');
                first_unit_class = unit_classes[0];
                default_unit = self.hed_dictionary_dictionaries[TagValidator.DEFAULT_UNIT_ATTRIBUTE][first_unit_class];
        return default_unit;

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

    def check_number_of_group_tildes(self, tag_group):
        """Reports a validation error if the tag group has too many tildes.

        Parameters
        ----------
        tag_group: list
            A list containing the tags in a group.
        Returns
        -------
        string
            A validation error string. If no errors are found then an empty string is returned.

        """
        validation_error = '';
        if tag_group.count('~') > 2:
            validation_error = error_reporter.report_error_type(TagValidator.TILDE_ERROR_TYPE, tag_group);
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

    def check_for_required_tags(self, formatted_top_level_tags):
        """Reports a validation error if the required tags aren't present.

        Parameters
        ----------
        formatted_top_level_tags: list
            A list containing the top-level tags.
        Returns
        -------
        string
            A validation error string. If no errors are found then an empty string is returned.

        """
        validation_error = '';
        required_tag_prefixes = self.hed_dictionary_dictionaries[TagValidator.REQUIRED_ERROR_TYPE];
        for required_tag_prefix in required_tag_prefixes:
            if sum([x.startswith(required_tag_prefix) for x in formatted_top_level_tags]) < 1:
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

    def count_tag_group_brackets(self, hed_string):
        """Reports a validation error if there are an unequal number of opening or closing parentheses. This is the
         first check before the tags are parsed.

        Parameters
        ----------
        hed_string: string
            A hed string.
        Returns
        -------
        string
            A validation error string. If no errors are found then an empty string is returned.

        """
        validation_error = '';
        number_of_opening_brackets = hed_string.count('(');
        number_of_closing_brackets = hed_string.count(')');
        if number_of_opening_brackets != number_of_closing_brackets:
            validation_error = error_reporter.report_error_type(TagValidator.BRACKET_ERROR_TYPE,
                                                                opening_bracket_count=number_of_opening_brackets,
                                                                closing_bracket_count=number_of_closing_brackets);
        return validation_error;

if __name__ == '__main__':
    # original_tag = 'attribute/repetition/34434';
    original_tag = 'attribute/direction/top/34434';
    hed_dictionary = HedDictionary('../tests/data/HED.xml');
    tag_validator = TagValidator(hed_dictionary);
    units_are_valid = tag_validator.count_tag_group_brackets('fdskjfdkjd,()(()())))))))');
    print(units_are_valid)