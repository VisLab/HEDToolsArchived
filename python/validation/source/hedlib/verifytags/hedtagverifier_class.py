import re
import sys
from .hednodeattribute_enum import HEDNodeAttribute
from .heddictionary_class import HEDDictionary

#class that checks tags for membership in hierarchy
#and checks tags for attribute consistency
class HEDTagVerifier(HEDDictionary):
    #all error or warning messages need to start with a '\t'
    invalidTagError = "\t{0} is not valid HED tag"
    requireChildError = "\t{0} should have a child string"
    isNumericError = "\t{0} should have a number, and optionally a unit as the leaf string"
    unitClassError = "\t{0} should have one of {1} as a unit, or no unit"
    uniqueError = "\t{0} is part of the unique tag set starting with {1} and has appeared more than once in this tag group"
    requiredError = "\tA tag with the prefix {0} is required in every tag group but was not found in this tag group"

    def __init__(self,hed_in):
        super().__init__(hed_in)

        self.tagErrors = []
        self.tagWarnings = []

        #Constructs attribute function table
        self.attrFunctions = {
                HEDNodeAttribute.requireChild.value : self.__requireChild__,
                HEDNodeAttribute.takesValue.value : self.__takesValue__,
                HEDNodeAttribute.isNumeric.value : self.__isNumeric__,
                HEDNodeAttribute.required.value : self.__required__,
                HEDNodeAttribute.recommended.value : self.__recommended__,
                HEDNodeAttribute.position.value : self.__position__,
                HEDNodeAttribute.unique.value : self.__unique__,
                HEDNodeAttribute.unitClass.value : self.__unitClass__
        }

    #If a tag maps to this attribute then
    #it should have a child, and so, no tag
    #should map to the requireChild attribute.
    def __requireChild__(self,tag,value):
        self.tagErrors.append(HEDTagVerifier.requireChildError.format(tag))

    #If a tag maps to this, then the leaf string
    #can be any string,(which does not contain commas)
    #although comma errors are handled at a different level
    def __takesValue__(self,tag,value):
        return
    
    def __isNumeric__(self,tag,value):
        numMatch = re.search(r'/\s*\d+\s*\S*\s*$',tag)
        if(not numMatch):
            self.tagErrors.append(HEDTagVerifier.isNumericError.format(tag))

    #if no numbers are in the suffix string, then unit class is
    #not even checked as suffix will have 'isNumeric' error.
    def __unitClass__(self,tag,unitClass):
        unitMatch = re.search(r'/\s*\d+(?:\.\d+)?\s*(\S*)\s*$',tag)
        if(unitMatch):
            tagUnit = unitMatch.group(1)
            if(tagUnit != '' and tagUnit not in self.unitClasses[unitClass]):
                correctUnits = ", ".join("{0}".format(unit) for unit in self.unitClasses[unitClass])
                self.tagErrors.append(HEDTagVerifier.unitClassError.format(tag,correctUnits))

    def __required__(self,tag,value):
        tagList = tag.split('/')
        parent = ''
        for i in range(0,len(tagList)):
            parent += tagList[i]
            if(parent in self.requiredDict):
                self.requiredDict[parent] = True

            parent += '/'

    def __unique__(self,tag,value):
        tagList = tag.split('/')
        parent = ''
        for i in range(0,len(tagList)):
            parent += tagList[i]
            if(parent in self.uniqueDict and self.uniqueDict[parent]):
                self.tagErrors.append(HEDTagVerifier.uniqueError.format(tag,parent))
                return
            elif(parent in self.uniqueDict):
                self.uniqueDict[parent] = True
                return

            parent += '/'
        
        #should never actually get to here
        #consider adding an exception
        return False
    
    #this does not do anything right now
    #but may need to in the future
    def __recommended__(self,tag,value):
        return

    #this does not do anything right now
    #but may need to in the future
    def __position__(self,tag,value):
        return

    
    def __checkAttributes__(self,tag,attributes):
        for attribute in attributes:
            attributeChecker = self.attrFunctions[attribute]
            value = attributes[attribute]
            attributeChecker(tag,value)
            

    def __verifyTagInGroup__(self,tag):
        attributes = None
        modifiedTag = tag
        tag_pattern = re.compile(r'/?[^/]*$')
        error = False

        #check if raw tag is in dict
        if(tag in self.hed_dict):
            attributes = self.hed_dict[tag]
        
        #if not then turn suffix string into a '#'
        #and try again
        else:
            modifiedTag = re.sub(tag_pattern,'/#',tag)
            if(modifiedTag in self.hed_dict):
                attributes = self.hed_dict[modifiedTag]
            else:
                error = True
        
        #check attributes
        if(attributes != None):
            self.__checkAttributes__(tag,attributes)
        elif(error):
            self.tagErrors.append(HEDTagVerifier.invalidTagError.format(tag))


    def verifyTagGroup(self,tagGroup):
        self.__clearUnique__()
        self.__clearRequired__()

        #verify each tag in a group
        for tag in tagGroup:
            self.__verifyTagInGroup__(tag)

        #check that the required tags were present
        for requiredTag in self.requiredDict:
            if(not self.requiredDict[requiredTag]):
                self.tagErrors.append(HEDTagVerifier.requiredError.format(requiredTag))

    def inDict(self,tag):
        attributes = None
        modifiedTag = tag
        tag_pattern = re.compile(r'/?[^/]*$')
        inDictionary = False

        #check if raw tag is in dict
        if(tag in self.hed_dict):
            inDictionary = True

        #if not then turn suffix string into a '#'
        #and try again
        else:
            modifiedTag = re.sub(tag_pattern,'/#',tag)
            if(modifiedTag in self.hed_dict):
                inDictionary = True
        
        return inDictionary

    def printErrors(self,OUTFILE):
        print('\r\n'.join(self.tagErrors),file=OUTFILE,end='\r\n')

    def printWarnings(self,OUTFILE):
        print('\r\n'.join(self.tagWarnings),file=OUTFILE,end='\r\n')

    def clearErrors(self):
        self.tagErrors = []

    def clearWarnings(self):
        self.tagWarnings = []
