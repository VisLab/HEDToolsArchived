import codecs
import re
import sys
from hedlib.verifytags.hedtagerrorchecker_class import HEDTagErrorChecker
from hedlib.hedtoxml.hedtoxmllineprocessor_class import HEDToXMLLineProcessor

def HED_to_XML(hed_in, xml_out, in_encoding="utf8"):
    lines = HEDToXMLLineProcessor.get_lines(hed_in, encoded=in_encoding)
    if(lines == None):
        return
    
    HEDToXMLLineProcessor.process_lines(lines, xml_out)
    
    return

#TODO: start and end shouldn't have default values
#this should require the arguments be named
def verify_HED_tags(hed,tags,column_list,out_name,start=1,end=-1):
    #converts string list of columns to integer list
    delim_match = re.search(r'([^\d\s])',column_list)
    delimiter = ""
    if(delim_match):
        delimiter = delim_match.group(1)

    if(delimiter):
        str_list = column_list.split(delimiter)
    else:
        str_list = column_list.split()
    
    columns = []
    for tok in str_list:
        tok = tok.strip()
        try:
            columns.append(int(tok))
        except UnicodeError:
            tb = sys.exc_info()[2]
            raise UnicodeError.with_traceback(tb)
            
        except ValueError:
            err_message = tok + " is not a number"
            tb = sys.exc_info()[2]
            raise ValueError(err_message).with_traceback(tb)

    #opens outputs files
    ext_pattern = re.compile(r'(\.[a-zA-Z]{3})$')
    wrn_name = re.sub(ext_pattern,r'_wrn\1',out_name)
    if(wrn_name == out_name):
        wrn_name = out_name + "_wrn.txt"
    
    err_name = re.sub(ext_pattern,r'_err\1',out_name)
    if(err_name == out_name):
        err_name = out_name + "_err.txt"
    
    WARNINGS = codecs.open(wrn_name,'w',"utf8")
    ERRORS = codecs.open(err_name,'w',"utf8")

    errorChecker = HEDTagErrorChecker(hed)
    errorChecker.loadReader(tags,columns,start,end)
    errorChecker.checkTags(ERRORS,WARNINGS)

    ERRORS.close()
    WARNINGS.close()
    
    return
