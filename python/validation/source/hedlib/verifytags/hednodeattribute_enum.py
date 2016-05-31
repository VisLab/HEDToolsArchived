from enum import Enum, unique

@unique
class HEDNodeAttribute(Enum):
    requireChild = 'requireChild'
    takesValue = 'takesValue'
    isNumeric = 'isNumeric'
    required = 'required'
    recommended = 'recommended'
    position = 'position'
    unique = 'unique'
    unitClass = 'unitClass'

    def isAttribute(string):
        for attribute in HEDNodeAttribute:
            if(string == attribute.value):
                return True

        return False
