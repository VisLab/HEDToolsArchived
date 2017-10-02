'''
This module is used to report errors found in the validation.

Created on Oct 2, 2017

@author: Jeremy Cockfield

'''
def report_error_type(error_type, error_line=1, tag='', tag_prefix='', unit_class_units=''):
    error_types = {
        'isNumeric': '\tERROR: Invalid numeric tag - \"%s\"\n' % tag,
        'line': 'Errors on line %s:\n' % str(error_line),
        'required': '\tERROR: Tag with prefix \"%s\" is required\n' % tag,
        'requireChild':'\tERROR: Descendant tag required - \"%s\"\n' % tag,
        'tilde': '\tERROR: Too many tildes - group \"%s\"\n' % tag,
        'unique': '\tERROR: Multiple unique tags (prefix \"%s\") - \"%s\"\n' % (tag_prefix, tag),
        'unitClass': '\tERROR: Invalid unit - \"%s\" (valid units are "%s")\n' % (tag, unit_class_units),
        'valid': '\tERROR: Invalid HED tag - \"%s\"\n' % tag

    }
    return error_types.get(error_type, None);


if __name__ == '__main__':
    print(report_error_type('valid', 'Event/Label'));