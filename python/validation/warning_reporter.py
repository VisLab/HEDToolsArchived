'''
This module is used to report warnings found in the validation.

Created on Oct 2, 2017

@author: Jeremy Cockfield

'''


def report_warning_type(warning_type, tag='', units=''):
    """Reports the validation warning based on the type of warning.

    Parameters
    ----------
    warning_type: string
        The type of validation warning.
    tag: string
        The tag that generated the warning. The original tag not the formatted one.
    units: string
        The unit class units that are associated with the warning.
    Returns
    -------
    string
        A warning message related to a particular type of warning.

    """
    warning_types = {
        'cap': '\tWARNING: First word not capitalized or camel case - "%s"\n' % tag,
        'unitClass': '\tWARNING: No unit specified. Using "%s" as the default - "%s"' % (units, tag)
    }
    return warning_types.get(warning_type, None);

if __name__ == '__main__':
    print(report_warning_type('valid', 'Event/Label'));