import re
import codecs
import sys

#TODO: something should be done about the behavior of this class
#when it runs to the end of the input file.
class HEDTagReader:
    FIRSTCOLUMN = 1
    NOEND = -1

    def __init__(self,tags_in,column_list,start_line,end_line=NOEND):
        try:
            codecs.register_error('remove',lambda e : ('',e.end))
            self.TAGS = codecs.open(tags_in,"r",encoding = "utf8",errors='remove')
        except FileNotFoundError:
            err_message = "{0} could not be found by system".format(tags_in)
            tb = sys.exc_info()[2]
            raise FileNotFoundError(err_message).with_traceback(tb)

        #add something in here to take care of BOM if 
        #start line is the first line of the file

        #skips ahead to the start line of the tag file
        for i in range(1,start_line):
            TAGS.readline()

        self.currentLine = start_line
        #Note: column numbering starts at 1
        self.columns = column_list
        self.end = end_line

    def getCurrentLine(self):
        return self.currentLine

    def genTagGroup(self):
        blank_pattern = re.compile(r'^\s*$')
        column_pattern = re.compile(r'^.*\"(.*)\".*$')
        parentheses_pattern = re.compile(r'\(|\)')
        slash_pattern = re.compile(r'/')
        alt_pattern = re.compile(r'\|')
        
        tagGroup = []
        for line in self.TAGS:
            first_col = HEDTagReader.FIRSTCOLUMN 
        
            if(self.end != -1 and self.currentLine >= self.end):
                return tagGroup 

            #start here
            if(blank_pattern.search(line)):
                self.currentLine += 1
                continue
            
            all_columns = line.split("\t")
            inColumns = []
            for ind in self.columns:
                #this is a change from the previous version
                #here out of bouns indeces are simply ignored
                if(ind < first_col or ind >= (len(all_columns) + first_col)):
                    continue

                inColumns.append(all_columns[ind - first_col])
            
            pre_tags = []
            for column in inColumns:
                if(column):
                    column = re.sub(column_pattern,r'\1',column)
                    column = re.sub(parentheses_pattern,"",column)
                    column = re.sub(r'~', ',', column)
                    column = column.strip()
                    col_tags = column.split(',')
                    tagno = 0
                    for col_tag in col_tags:
                        slash_match = re.search(slash_pattern,col_tag)
                        if((slash_match is not None) or tagno == 0):
                            pre_tags.append(col_tag)
                        else:
                            pre_tags[-1] = pre_tags[-1] + "," + col_tag

                        tagno += 1
            
            for pre_tag in pre_tags:
                pre_tag = pre_tag.strip()
                if(alt_pattern.search(pre_tag)):
                    names = pre_tag.split("/")

                    #if the tag does have a '|' in it
                    #then it would need to be the leaf
                    #that alternates, as other level tags
                    #do not accept the same children.
                    childstr = names.pop()
                    parentstr = "/".join(names)
                    
                    children = childstr.split("|")
                    for child in children:
                        appstr = parentstr + "/" + child
                        tagGroup.append(appstr.strip())
                        
                else:
                    tagGroup.append(pre_tag.strip())
                    
            yield tagGroup
            self.currentLine += 1
            tagGroup = []
        
        #consider changing
        self.TAGS.close()
