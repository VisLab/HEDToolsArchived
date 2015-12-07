from __future__ import print_function
import re
import codecs
import os
import sys

def xml_special_adjust(xml_str):
    """
        Finds and replaces all xml special characters in a string.
        returns xml_str with xml special characters replaced with
        appropriate character entities.
    """
    
    _gt = r'>'
    _lt = r'<'
    _amp = r'\s&\s'
    _apos = r'\''
    _quot = r'"'

    _xml_special = {_gt : "&gt;",
                    _lt : "&lt;",
                    _amp : "&amp;",
                    _apos : "&apos;",
                    _quot : "&quot;"
                   }

    for char in (_xml_special.keys()):
        xml_str = re.sub(char,_xml_special[char],xml_str)
            
    return xml_str

def get_lines(hed_in, encoded="utf8"):
    "Gets all lines from HED hierarchy file. returns list of lines from hed_in"

    try:
        HED = codecs.open(hed_in,"r",encoding=encoded)
    except FileNotFoundError:
        err_message = "{0} could not be found by system".format(hed_in)
        tb = sys.exc_info()[2]
        raise FileNotFoundError(err_message).with_traceback(tb)

    
    BOM_line = HED.readline()
    #DO NOT CHANGE BELOW TO readlines() METHOD!!!
    #EXECUTABLE WILL NOT COMPILE CORRECTLY!!!
    lines = []
    for line in HED:
        lines.append(line)
    
    #checks for BOM and removes if there
    if(BOM_line.encode().startswith(codecs.BOM_UTF8)):
        no_BOM = BOM_line[1:len(BOM_line) - 1]
    else:
        no_BOM = BOM_line

    lines.insert(0, no_BOM)
                
    HED.close()
    
    break_ind = 0
    break_pattern = re.compile(r'^\s*!#\s*start\s*hed\s*$',flags=re.IGNORECASE)
    for line in lines:
        break_ind += 1
        if(break_pattern.search(line)):
            break
    
    has_break = (break_ind < len(lines))
    if(has_break):
        lines = lines[break_ind:len(lines)]
    
    return lines

class hedToXMLLineProcessor:
    _win_newline = '\r\n'
    indent = "   "

    #for printing hed nodes
    beg_node = "<node"
    end_node = "</node>"
    beg_des = "<description>"
    end_des = "</description>"
    has_att = "true"
    no_name = "NA"

    #for printing unitclasses
    unitClassesStart = "<unitClasses>"
    unitClassesEnd = "</unitClasses>"
    beg_uClass = "<unitClass>"
    end_uClass = "</unitClass>"
    beg_unit = "<units>"
    end_unit = "</units>"

    #for any functions
    beg_name = "<name>" 
    end_name = "</name>"
    
    bullets = {
            "" : 0,       #-> Empty
            "\u25CF" : 1, #-> "BLACK CIRCLE"
            "\u25CB" : 2, #-> "WHITE CIRCLE"
            "\u25A0" : 3, #-> "BLACK SQUARE"
            "\u25AA" : 4, #-> "BLACK SMALL SQUARE"
            "\u25CA" : 5, #-> "LOZENGE"
            "\u25B2" : 6, #-> "BLACK UP-POINTING TRIANGLE"
            "\u25BC" : 7, #-> "BLACK DOWN-POINTING TRIANGLE"
            "\u25C4" : 8, #-> "BLACK LEFT-POINTING POINTER"
            "\u25BA" : 9  #-> "BLACK RIGHT-POINTING POINTER"
            }


    def lines_to_hed_nodes(lines,XML):
        this = hedToXMLLineProcessor

        line_pattern = re.compile(r'\s*(\W?)([^\[]*)(\[?)')
        att_pattern = re.compile(r'\{(.*)\}')
        attval_pattern = re.compile(r'^(\w+)=(\w+)$')
        name_pattern = re.compile(r'\s*\{.*')
        des_pattern = re.compile(r'\[\s*(.*)\.?\s*\]\s*$')

        end_nodes = 0
        prev_ind = -1
        for line in lines:
            if(re.search(r'^\s*$',line)):
                continue
            
            line_match = line_pattern.search(line)
            curr_ind = this.bullets[line_match.group(1).strip()]
            name = line_match.group(2).strip()
            is_des = line_match.group(3)
         
            #clears end nodes from last subtree
            if(curr_ind <= prev_ind and prev_ind >= 0):
                for i in reversed(range(curr_ind,prev_ind + 1)):
                    print(this.indent*i + this.end_node,end=this._win_newline,file=XML)
                    end_nodes -= 1

            #add an elif(curr_ind > prev_ind + 1): for error trapping?

            #checks for attributes and constructs list 
            #of attributes to be printed
            att_match = att_pattern.search(name)
            if(att_match):
                name = re.sub(name_pattern,r'',name)
                attributes_str = att_match.group(1)
                attributes = attributes_str.split(",")
                
                att_dict = {}
                att_val = this.has_att
                for attribute in attributes:
                    attribute = attribute.strip()

                    attval_match = attval_pattern.search(attribute)
                    if(attval_match == None):
                        att_val = this.has_att 
                    else:
                        attribute = attval_match.group(1)
                        att_val = attval_match.group(2)
                        
                    if(attribute in att_dict):
                        att_dict[attribute] = att_dict[attribute] + ", " + att_val
                    else:
                        att_dict[attribute] = att_val
                
                att_str = ""
                for attribute in att_dict:
                    att_str = att_str + " " + attribute + "=" + '"' + att_dict[attribute] + '"'

                print(this.indent*curr_ind + this.beg_node + att_str + ">",end=this._win_newline,file=XML)
                    
            else:
                print(this.indent*curr_ind + this.beg_node + ">",end=this._win_newline,file=XML)
            
            if(name):
                name = xml_special_adjust(name)
            else:
                name = this.no_name
                
            print(this.indent*(curr_ind + 1) + this.beg_name + name + this.end_name,end=this._win_newline,file=XML)
                
            #checks for description, and if there
            #prints appropriately
            if(is_des):
                match_des = des_pattern.search(line)
                
                if(match_des):
                    description = match_des.group(1)
                    description = xml_special_adjust(description)
                    print(this.indent*(curr_ind + 1) + this.beg_des + description.capitalize() + "." + this.end_des,end=this._win_newline,file=XML)
            
            end_nodes += 1
            prev_ind = curr_ind
        
        #prints out any remaining node-ends
        for i in reversed(range(0,end_nodes)):
            print(this.indent*i + this.end_node,end=this._win_newline,file=XML)
            end_nodes -= 1

    def lines_to_unitClass_nodes(lines,XML):
        this = hedToXMLLineProcessor
        unitClassLevel = 1
        unitsLevel = 2
        line_pattern = re.compile(r'^\s*(\W?)(.*)$')

        start = lines.pop(0)
        if(re.search(r'^\s*Unit Classes\s*$',start)):
            print(this.unitClassesStart,end=this._win_newline,file=XML)
        #else throw an exception for not having the unit class line

        prev_ind = 0
        for line in lines:
            if(re.search(r'^\s*$',line)):
                continue
            
            line_match = line_pattern.search(line)
            curr_ind = this.bullets[line_match.group(1).strip()]
            name = line_match.group(2).strip()
         
            #clears end nodes from last subtree
            if(curr_ind <= prev_ind and curr_ind == unitClassLevel):
                print(this.indent*(curr_ind - 1) + this.end_uClass,end=this._win_newline,file=XML)

            name = xml_special_adjust(name)
            if(curr_ind == unitClassLevel):
                print(this.indent*(curr_ind - 1) + this.beg_uClass,end=this._win_newline,file=XML)
                print(this.indent*curr_ind + this.beg_name + name + this.end_name,end=this._win_newline,file=XML)
            else:
                print(this.indent*curr_ind + this.beg_unit + name + this.end_unit,end=this._win_newline,file=XML)
                
            prev_ind = curr_ind
        
        #prints out end of unit class segment
        print(this.end_uClass,end=this._win_newline,file=XML)
        print(this.unitClassesEnd,end=this._win_newline,file=XML)


    def process_lines(lines, xml_out):
        """
            Converts list of lines of HED hierarchy into XML
            and writes resulting XML into xml_out. 
            returns None
        """

        noUnitClasses = -1
        _win_newline = '\r\n'
        version = "2.0"
        my_encoding = "utf8"
        indent = "   "

        xml_line = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
        HED_line = "<HED version=\"" + version + "\">"

        XML = codecs.open(xml_out,"w",encoding=my_encoding)
        
        print(xml_line,end=_win_newline,file=XML)
        print(HED_line,end=_win_newline,file=XML)


        unitClassIndex = lines.index("Unit Classes\r\n")
        #prints out hed node lines
        hedToXMLLineProcessor.lines_to_hed_nodes(lines[0:unitClassIndex],XML)

        #prints out unit class information if there
        if(unitClassIndex != noUnitClasses):
            hedToXMLLineProcessor.lines_to_unitClass_nodes(lines[unitClassIndex:len(lines)],XML)

        print("</HED>",end=_win_newline,file=XML)
        
        XML.close()
        return

#not sure if I need to have encoding option here, encoding will only ever be in utf8
def HED_to_XML(hed_in, xml_out, in_encoding="utf8"):
    "Calls above functions. returns None"

    lines = get_lines(hed_in, encoded=in_encoding)
    if(lines == None):
        return
    
    hedToXMLLineProcessor.process_lines(lines, xml_out)
    
    return
