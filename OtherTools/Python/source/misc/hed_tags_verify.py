from __future__ import print_function
import re
import codecs
import sys

def fill_HED_dict(hed_in):
    "Creates a dictionary containing all parts of the HED hierarchy"
    try:
        HED = codecs.open(hed_in,"r",encoding="utf8")
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
        
    HED.close()
    
    #checks for BOM an removes if there
    if(BOM_line.encode().startswith(codecs.BOM_UTF8)):
        no_BOM = BOM_line[1:len(BOM_line) - 1]
    else:
        no_BOM = BOM_line
    
    lines.insert(0, no_BOM)

    break_ind = 0
    break_pattern = re.compile(r'^\s*!#\s*start\s*hed\s*$')
    for line in lines:
        break_ind += 1
        if(break_pattern.search(line)):
            break

    has_break = (break_ind < len(lines))
    if(has_break):
        lines = lines[break_ind:len(lines)]
    
    parents = 0
    prev_ind = ""
    prev_pfix = ""
    indent = "   "
    i_len = len(indent)
    name_stack = []
    hed_dict = {}

    #uses each line to create a tree with
    #structure identical to HED hierarchy
    _quantity = "isnum" 
    line_pattern = re.compile(r'(\s*)(\*?)([^\[]*)')
    name_pattern = re.compile(r'\s*([^\({]*)\(?.*')
    quantity_pattern = re.compile(r'.*#.*')
    blank_pattern = re.compile(r'^\s*$')
    for line in lines:
        line_match = line_pattern.search(line)
        curr_ind = line_match.group(1)
        curr_pfix = line_match.group(2)
        
        name = line_match.group(3).strip()
        name = re.sub(name_pattern,r'\1',name)
        name = re.sub(quantity_pattern,_quantity,name)
        
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
        tag_string = '/'.join(name_stack)
        hed_dict[tag_string] = True

        parents += 1
        prev_ind = curr_ind
        prev_pfix = curr_pfix
        
    return hed_dict

#NOTE: first column is column number one
def fill_tag_list(tags_in,column_list):
    """
       Creates list of HED tags from tab-separated value file,
       in the columns given by column_list, which is a list of
       positive integers, indicating valid columns in the tag file. 
       Note: the first column of the file is column number one!
       returns a list of all tags extracted from given columns
       from file.
    """
    try:
        TAGS = codecs.open(tags_in,"r",encoding = "utf8")
    except FileNotFoundError:
        err_message = "{0} could not be found by system".format(tags_in)
        tb = sys.exc_info()[2]
        raise FileNotFoundError(err_message).with_traceback(tb)

    lines = []
    for line in TAGS:
        lines.append(line)

    #removes title line of file
    del lines[0]
    TAGS.close()
    tags = []
    line_num = 2
    first_col = 1 
    
    blank_pattern = re.compile(r'^\s*$')
    column_pattern = re.compile(r'^.*\"(.*)\".*$')
    parentheses_pattern = re.compile(r'\(|\)')
    slash_pattern = re.compile(r'/')
    alt_pattern = re.compile(r'\|')
    for line in lines:
        if(blank_pattern.search(line)):
            line_num += 1
            continue
        
        all_columns = line.split("\t")
        columns = []
        for ind in column_list:
            if(ind < first_col or ind >= (len(all_columns) + first_col)):
                raise ValueError("{0} is invalid column number".format(ind))

            columns.append(all_columns[ind - first_col])
        
        pre_tags = []
        for column in columns:
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
                        last = len(pre_tags) - 1
                        pre_tags[last] = pre_tags[last] + "," + col_tag

                    tagno += 1
        
        for pre_tag in pre_tags:
            pre_tag = pre_tag.strip()
            if(alt_pattern.search(pre_tag)):
                names = pre_tag.split("/")
                childstr = names.pop()
                parentstr = "/".join(names)
                
                children = childstr.split("|")
                for child in children:
                    appstr = parentstr + "/" + child
                    tags.append(str(line_num) + "#:" +appstr.strip())
                    
            else:
                tags.append(str(line_num) + "#:" + pre_tag.strip())
                
        line_num += 1
        
    return tags

#helper function for tags_report, will verify a tag and return 
#a list of positive integers denoting the verification status of the tag
def _verify_tag(tag,hed_dict):
    #verified or not or partial
    verified = 0 
    partial = 1
    notverified = 2
    #specific error codes
    #note: these will be given if a particular error can be
    #identified, otherwise, this will return 'notverified'
    comma_error = 3
    caps_error = 4

    status = None
    comma_err_tag = ""
    putbacks = []
    if(tag in hed_dict):
        status = verified
        return (status,putbacks,comma_err_tag)
    
    #check for comma errors
    if(re.search(r',',tag)):
        comma_tags = tag.split(",")
        ctag_no = 0;
        for ctag in comma_tags:
            ctag_no += 1
            ctag_strip = ctag.strip()
            if(ctag_strip in hed_dict):
                putbacks.extend(comma_tags[ctag_no:len(comma_tags)])
                break
            
        if(ctag_no > 2):
            comma_err_tag = ",".join(comma_tags[0:ctag_no-1])
            status = comma_error
        elif(ctag_no == 2):
            putbacks.append(comma_tags[0])
        
        return (status,putbacks,comma_err_tag)


    #remove last tag and check again
    lineage = tag.split("/")
    last_string = len(lineage) - 1
    no_last_string = '/'.join(lineage[0:last_string])
    if(no_last_string in hed_dict):
        status = partial
        return (status,putbacks,comma_err_tag)
    
    #check for capitalization errors
    case_correct_lin = []
    for tag in lineage:
        case_correct_lin.append(tag.capitalize())
        
    full_check = '/'.join(case_correct_lin) in hed_dict
    tail = len(case_correct_lin) - 1
    no_tail_check = '/'.join(case_correct_lin[0:tail]) in hed_dict
    if(full_check or no_tail_check):
        status = caps_error
        return (status,putbacks,comma_err_tag)

    status = notverified
    return (status,putbacks,comma_err_tag)

def tags_report(out_name,hed_dict,tags):
    """
       Prints two reports, one outname+'_wrn.txt', the other
       outname+'_err.txt'. '_wrn.txt' tags are not necessarily
       incorrect, but could not be verified here. '_err.txt'
       tags are certainly incorrect. returns None
    """
    
    _win_newline = '\r\n'

    ext_pattern = re.compile(r'(\.[a-zA-Z]{3})$')
    wrn_name = re.sub(ext_pattern,r'_wrn\1',out_name)
    if(wrn_name == out_name):
        wrn_name = out_name + "_wrn.txt"
    
    err_name = re.sub(ext_pattern,r'_err\1',out_name)
    if(err_name == out_name):
        err_name = out_name + "_err.txt"
    
    WARNING = codecs.open(wrn_name,'w',"utf8")
    ERROR = codecs.open(err_name,'w',"utf8")
    
    #message for warning report
    wrn_hdr = "Following tags match given HED hierarchy up until last '/' separated string.\r\n"
    wrn_hdr += "Note: this does not mean that last string is incorrect, it may simply be something that cannot be easily verified given the hierarchy.\r\n"
    print(wrn_hdr,end=_win_newline,file=WARNING)
    
    #message for error report
    err_hdr = "Following tags do not match HED hierarchy in at least one '/' separated string before the last.\r\n"
    err_hdr += "These are certainly incorrect, unlike in the warning report.\r\n"
    err_hdr += "Some common errors: spelling, incorrect case, extra commas, missing one or more parts of hierarchy.\r\n"
    print(err_hdr,end=_win_newline,file=ERROR)
    
    #verifies lines, otherwise prints out in appropriate report
    #verified or not or partial
    verified = 0 
    partial = 1
    notverified = 2
    #specific error codes
    #note: these will be given if a particular error can be
    #identified, otherwise, this will return 'notverified'
    comma_error = 3
    caps_error = 4
    
    line_no_pattern = re.compile(r'#:.*$')
    tag_pattern = re.compile(r'^\d*#:')
    empty_pattern = re.compile(r'^\s*$')

    #warnings
    generic = []
   
    #errors
    unidentified = []
    commas = []
    case = []
    
    for tag in tags:
        line_no = re.sub(line_no_pattern,"",tag)
        tag = re.sub(tag_pattern,"",tag)
        tag = tag.strip()
     
        if(len(tag) > 0 and tag[0] == '/'):
                tag = tag[1:]

        if(re.search(empty_pattern,tag)):
            continue

        status, putbacks, comma_err_tag = _verify_tag(tag,hed_dict)
        if(putbacks):
            for putback in putbacks:
                putback = line_no + "#:" + putback
                tags.append(putback)

        if(status == verified):
            continue
        elif(status == partial):
            generic.append((line_no,tag))
        elif(status == comma_error):
            commas.append((line_no,comma_err_tag))
        elif(status == caps_error):
            case.append((line_no,tag))
        elif(status == notverified):
            unidentified.append((line_no,tag))

    report_msg = "Line number {0}:     {1}\r\n"
    for warning in generic:
        print(report_msg.format(warning[0],warning[1]),end=_win_newline,file=WARNING)
    for error in unidentified:
        print(report_msg.format(error[0],error[1]),end=_win_newline,file=ERROR)
    if(commas):
        print("The following are tags that most likely have commas in them\r\n",end=_win_newline,file=ERROR)
        for error in commas:
            print(report_msg.format(error[0],error[1]),end=_win_newline,file=ERROR)
    if(case):
        print("The following are tags that have capitalization errors\r\n",end=_win_newline,file=ERROR)
        for error in case:
            print(report_msg.format(error[0],error[1]),end=_win_newline,file=ERROR)
            
    WARNING.close()
    ERROR.close()
    return

def verify_tags(hed_in,tags_in,column_list,out_name):
    "Just calls above functions, column_list is a list of integers"
    hed_dict = fill_HED_dict(hed_in)
    tags = fill_tag_list(tags_in, column_list)
    
    tags_report(out_name,hed_dict,tags)

def verify_tags2(hed_in,tags_in,column_list,out_name):
    """
       Parses column_list, which is a string in the format of
       numbers separated by a common delimiter, then calls
       verify_tags to run above functions.
    """

    delim_match = re.search(r'([^\d\s])',column_list)
    delimiter = ""
    if(delim_match):
        delimiter = delim_match.group(1)

    if(delimiter):
        str_list = column_list.split(delimiter)
    else:
        str_list = column_list.split()
    
    col_list = []
    for tok in str_list:
        tok = tok.strip()
        try:
            col_list.append(int(tok))
        except UnicodeError:
            tb = sys.exc_info()[2]
            raise UnicodeError.with_traceback(tb)
            
        except ValueError:
            err_message = tok + " is not a number"
            tb = sys.exc_info()[2]
            raise ValueError(err_message).with_traceback(tb)
        
    verify_tags(hed_in,tags_in,col_list,out_name)
