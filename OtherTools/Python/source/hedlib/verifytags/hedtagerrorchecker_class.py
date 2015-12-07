from .hedtagverifier_class import HEDTagVerifier
from .hedtagreader_class import HEDTagReader
from collections import deque

#A class for checking for hed tag errors
class HEDTagErrorChecker(HEDTagVerifier):
    #all error or warning messages need to start with a '\t'
    commaError = "\t{0} may contain a comma when no commas are allowed in tags"
    capsWarning = "\tEach slash-separated string in {0} should have the first letter capitalized only"

    def __init__(self,hed_in):
        super().__init__(hed_in)
        self.reader = None
        return

    def __commaErrorCheck__(self,tag,tagGroup):
        tagQue = deque([partialTag for partialTag in tag.split(',')])
        first = tagQue.popleft()
        
        breakInd = 0
        for t in tagQue:
            if(self.inDict((t.strip()).capitalize())):
                break
            
            breakInd += 1
       
        if(breakInd > 0):
            first += ',' + ','.join([tagQue.popleft() for i in range(0,breakInd)])
            self.tagErrors.append(self.commaError.format(first))

        tagGroup.append(first)

        #append remaining tags
        for t in tagQue:
            tagGroup.append(t.strip())

        return

    def __capTag__(tag):
        btag = bytearray(tag,'utf8')
        nbtag = []
        capnext = True
        for b in btag:
            cb = chr(b)
            if(capnext):
                capnext = False
                nbtag.append(cb.upper())

            else:
                capnext = cb == '/'
                nbtag.append(cb.lower())

        return ''.join(nbtag)

    def __capsWarningCheck__(self,tag,tagGroup):
        capsWarning = False
        capTag = HEDTagErrorChecker.__capTag__(tag)
        lastInd = capTag.rfind('/')
        
        if(lastInd == -1 or self.inDict(capTag)):
            capsWarning = capTag != tag
        
        else:
            capsWarning = capTag[0:lastInd] != tag[0:lastInd]

        if(capsWarning):
            self.tagWarnings.append(self.capsWarning.format(tag))
            tagGroup.append(capTag)

        else:
            tagGroup.append(tag)

        return

    def loadReader(self,tags,columns,start,end=HEDTagReader.NOEND):
        self.reader = HEDTagReader(tags,columns,start,end_line=end)
        return

    def __destroyReader__(self):
        self.reader = None
        return

    def checkTags(self,ERRORS,WARNINGS):
        if(self.reader is None):
            #TODO maybe throw an exception?
            return

        #check tags iteratively
        for rawTagGroup in self.reader.genTagGroup():
            preTagGroup = []
            for rawTag in rawTagGroup:
                if(',' in rawTag):
                    self.__commaErrorCheck__(rawTag,preTagGroup)
                else:
                    preTagGroup.append(rawTag)

            tagGroup = []
            for preTag in preTagGroup:
                self.__capsWarningCheck__(preTag,tagGroup)
                    
            self.verifyTagGroup(tagGroup)
            self.printErrors(ERRORS)
            self.printWarnings(WARNINGS)
            self.clearErrors()
            self.clearWarnings()

        self.__destroyReader__()
        return

    def printErrors(self,OUTFILE):
        if(len(self.tagErrors) == 0):
            return

        print("Errors on line {0}:".format(self.reader.getCurrentLine()),end='\r\n',file=OUTFILE)
        super().printErrors(OUTFILE)
        print('',end='\r\n',file=OUTFILE)
        self.clearErrors()

        return

    def printWarnings(self,OUTFILE):
        if(len(self.tagWarnings) == 0):
            return

        print("Warnings on line {0}:".format(self.reader.getCurrentLine()),end='\r\n',file=OUTFILE)
        super().printWarnings(OUTFILE)
        print('',end='\r\n',file=OUTFILE)
        self.clearWarnings()

        return
