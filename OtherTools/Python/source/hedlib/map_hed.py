from __future__ import print_function
import re
import codecs
import sys

def _get_lines(pathname):
    """
       Gets lines from hed file specified by pathname,
       and returns list of lines from file.
    """
    try:    
        HED = codecs.open(pathname,"r",encoding="utf8")
    except FileNotFoundError:
        err_message = "{0} could not be found by system".format(pathname)
        tb = sys.exc_info()[2]
        raise FileNotFoundError(err_message).with_traceback(tb)

    BOM_line = HED.readline()

    lines = []
    for line in HED:
            lines.append(line)

    #checks for BOM an removes if there
    if(BOM_line.encode().startswith(codecs.BOM_UTF8)):
        no_BOM = BOM_line[1:len(BOM_line) - 1]
    else:
        no_BOM = BOM_line
    
    lines.insert(0, no_BOM)
    HED.close()
    
    break_ind = 0
    break_pattern = re.compile(r'^\s*!#\s*start\s*hed\s*$')
    for line in lines:
        break_ind += 1
        if(break_pattern.search(line)):
            break

    has_break = (break_ind < len(lines))
    if(has_break):
        lines = lines[break_ind:len(lines)]
    
    return lines

def _hed_strlist(lines):
    """
       Takes list of lines from HED file and creates a list
       of all tags,(along with their descriptions, separated
       by a tab). returns a list of strings, each being a tag
       with a description separated by a tab.
    """

    parents = 0
    prev_ind = ""
    prev_pfix = ""
    indent = "   "
    i_len = len(indent)
    name_stack = []
    HED_str_list = []
    
    line_pattern = re.compile(r'(\s*)(\*?)([^\[]*)(\[.*\])?')
    name_pattern = re.compile(r'\s*([^\({]*)\(?.*')
    blank_pattern = re.compile(r'^\s*$')
    for line in lines:
        line_match = line_pattern.search(line)
        curr_ind = line_match.group(1)
        curr_pfix = line_match.group(2)
        des = line_match.group(4)
        name = line_match.group(3).strip()
        name = re.sub(name_pattern,r'\1',name).strip()
        
        if(blank_pattern.search(name)):
            continue
            
        if(parents > 0 and curr_pfix != "*"):
            name_stack.clear()
            parents = 0
            
        elif(len(curr_ind) == len(prev_ind) and prev_pfix == "*"):
            name_stack.pop()
            parents -= 1
            
        elif(len(curr_ind) < len(prev_ind)):
            p_ends = 1 + (len(prev_ind)//i_len - len(curr_ind)//i_len)
            for i in range(0,p_ends):
                name_stack.pop()
                parents -= 1
        
        name = name.strip()
        name_stack.append(name)
        name_str = ""
        
        for names in name_stack:
            name_str += "/" + names

        if(des):
            name_str += "\t" + des
    
        HED_str_list.append(name_str)    
        parents += 1
        prev_ind = curr_ind
        prev_pfix = curr_pfix
        
    return HED_str_list
    
def _get_mapping(map_pathname):
    """
       Extracts HED mapping from a file given by map_pathname
       returns a dictionary representing the mapping
    """
    MAP = codecs.open(map_pathname,encoding="utf8")
    BOM_line = MAP.readline()
    lines = MAP.readlines()
    
    #checks for BOM an removes if there
    if(BOM_line.encode().startswith(codecs.BOM_UTF8)):
        no_BOM = BOM_line[1:len(BOM_line) - 1]
    else:
        no_BOM = BOM_line
    
    lines.insert(0, no_BOM)
    MAP.close()
    
    map_dict = {}
    for line in lines:
        mapping = line.split("\t",2)
        if(len(mapping) <= 1):
            continue
        
        mapping[0] = mapping[0].strip()
        mapping[1] = re.sub(r'\"',"",mapping[1]).strip()
        map_dict[mapping[0]] = mapping[1]
        
    return map_dict
    
    
def print_map(out_path, HED_path, map_path):
    """
       Prints full HED map based on given hierarchy and
       the file containing the map. returns None
    """

    HED_str_list = _hed_strlist(_get_lines(HED_path))
    map_dict = _get_mapping(map_path)
    
    try:
        OUT = codecs.open(out_path,"w",encoding="utf8")
    except FileNotFoundError:
        err_message = "{0} could not be found by system".format(out_path)
        tb = sys.exc_info()[2]
        raise FileNotFoundError(err_message).with_traceback(tb)
    
    _win_end = '\r\n'
    hed_pattern = re.compile(r'/[^/]*$') 
    new_hed_pattern = re.compile(r'/[^/]*/\*$')
    for hed_str in HED_str_list:
        map_str = ""
        map_str += hed_str
        
        nam_des_pair = map_str.split("\t",2)
        if(len(nam_des_pair) == 2):
            hed_str = nam_des_pair[0]
        else:
            map_str += "\t"
            
        try:
            map_str += "\t" + map_dict[hed_str]
        except KeyError:
            try:
                hed_str = re.sub(hed_pattern,"/*",hed_str)
                map_str += "\t" + map_dict[hed_str]
            except KeyError:
                while(hed_str):
                    new_hed_str = re.sub(new_hed_pattern,"/*",hed_str)
                    if(hed_str != new_hed_str):
                        hed_str = new_hed_str
                        try:
                            map_str += "\t" + map_dict[hed_str]
                        except KeyError:
                            pass
                    else:
                        hed_str = ""
            
        print(map_str, end=_win_end, file=OUT)
    
    OUT.close()
