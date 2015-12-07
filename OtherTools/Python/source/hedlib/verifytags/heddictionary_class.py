import re
import sys
import codecs
from lxml import etree
from .hednodeattribute_enum import HEDNodeAttribute 

class HEDDictionary:
    #constants
    #TODO : centralize constants across library
    tagdelim = b'/'
    hedencode = 'utf8'
    node = 'node'
    nametag = 'name'
    unitclasses = 'unitClasses'
    unitclass = 'unitClass'
    units = 'units'

    def __init__(self,hed_in):
        self.requiredDict = {}
        self.uniqueDict = {}
        self.uniqueAttr = HEDNodeAttribute.unique.value
        self.requiredAttr = HEDNodeAttribute.required.value
        
        #Creates a dictionary containing all parts of the HED hierarchy
        try:
            codecs.register_error('remove',lambda e : ('',e.end))
            HED = codecs.open(hed_in,"r",encoding=self.hedencode,errors='remove')
        except FileNotFoundError:
            err_message = "{0} could not be found by system".format(hed_in)
            tb = sys.exc_info()[2]
            raise FileNotFoundError(err_message).with_traceback(tb)
        
        hedtree = etree.parse(HED)
        self.__buildHEDdict__(hedtree)

        #builds unit classes
        self.unitClasses = {}
        self.__buildUnitClasses__(hedtree)

        del hedtree
        HED.close()

    def __buildHEDdict__(self,hedtree):
        self.hed_dict = {}
        lastUnique = None
        lastRequired = None

        #build tags
        tag = bytearray()
        elemstack = []
        delim = self.tagdelim
        hedencode = self.hedencode
        nametag = self.nametag
        for elem in hedtree.iter(self.node):
            #TODO : consider throwing an exception if no name is found
            name = elem.find(nametag)
            bname = bytearray(name.text,hedencode)

            parent = elem.getparent()
            if(parent is not None):
                while(len(elemstack) > 0 and elemstack[-1] is not parent):
                    del elemstack[-1]
                    leafind = tag.rfind(delim)
                    if(leafind == -1):
                        tag.clear()
                    else:
                        del tag[leafind:]
            else:
                tag.clear()
            
            if(len(tag)):
                tag.extend(delim)

            tag.extend(bname)
            elemstack.append(elem)
            tagstring = str(tag,hedencode)

            #get attributes
            attributes = dict(elem.attrib)

            #check for uniqueness attribute
            lastUnique = self.__isUnique__(attributes,lastUnique,elem,tagstring)

            #check for required attribute
            lastRequired = self.__isRequired__(attributes,lastRequired,elem,tagstring)
            
            #add tag into dictionary    
            self.hed_dict[tagstring] = attributes

        return

    def __isUnique__(self,attributes,uniqueElem,elem,tagstring):
        #check to see if this tag should inherit uniqueness
        lastunique = uniqueElem 
        if(uniqueElem is not None):
            #check if uniqueElem is an ancestor of elem
            isAncestor = False
            for ancestor in elem.iterancestors(self.node):
                if(ancestor is uniqueElem):
                    isAncestor = True
                    break

            if(isAncestor):
                attributes[self.uniqueAttr] = None
            else:
               lastunique = None 

        elif(self.uniqueAttr in attributes):
            lastunique = elem
            self.uniqueDict[tagstring] = False
        
        return  lastunique

    def __isRequired__(self,attributes,requiredElem,elem,tagstring):
        #check to see if this tag should inherit required
        lastrequired = requiredElem 
        if(requiredElem is not None):
            #check if requiredElem is an ancestor of elem
            isAncestor = False
            for ancestor in elem.iterancestors(self.node):
                if(ancestor is requiredElem):
                    isAncestor = True
                    break

            if(isAncestor):
                attributes[self.requiredAttr] = None
            else:
               lastrequired = None 

        elif(self.requiredAttr in attributes):
            lastrequired = elem
            self.requiredDict[tagstring] = False
        
        return  lastrequired


    def __buildUnitClasses__(self,hedtree):
        #build unit classes structure
        #TODO : check that the unit classes
        #referenced by hierarchy strings
        #are allowable unit classes
        self.unitClasses = {}
        unitClasses = hedtree.find(self.unitclasses)
        nametag = self.nametag
        unitstag = self.units
        for unitclasselement in unitClasses.iter(self.unitclass):
            name = unitclasselement.find(nametag)
            unitselement = unitclasselement.find(unitstag)

            unitclass = name.text
            units = frozenset(unit.strip() for unit in unitselement.text.split(','))

            self.unitClasses[unitclass] = units

        return
        
    def __clearUnique__(self):
        for uniqueTag in self.uniqueDict:
            self.uniqueDict[uniqueTag] = False

    def __clearRequired__(self):
        for requiredTag in self.requiredDict:
            self.requiredDict[requiredTag] = False

    def printHEDDictionary(self):
        print("HED dictionary:\r\n")
        print('\r\n'.join(["{0} : {1}".format(page,self.hed_dict[page]) for page in self.hed_dict]),end='\r\n')
        
        print("\r\nUnit Classes\r\n")
        print('\r\n'.join(["{0} : {1}".format(unitClass,self.unitClasses[unitClass]) for unitClass in self.unitClasses]),end='\r\n')

        print("\r\nUnique dictionary\r\n")
        print('\r\n'.join(["{0} : {1}".format(page,self.uniqueDict[page]) for page in self.uniqueDict]),end='\r\n')

        print("\r\nRequired dictionary\r\n")
        print('\r\n'.join(["{0} : {1}".format(page,self.requiredDict[page]) for page in self.requiredDict]),end='\r\n')
