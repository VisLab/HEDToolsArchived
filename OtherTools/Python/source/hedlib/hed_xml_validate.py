from __future__ import print_function
from lxml import etree
from lxml import _elementpath
import re

def xml_validate(xml_file_name,xsd_file_name):
    """
       Validates xml in xml_file_name against xml schema in xsd_file_name.
       returns list of discrepancies found by xml parser
    """
    xmltree = etree.parse(xml_file_name)
    xsdtree = etree.parse(xsd_file_name)
    schema = etree.XMLSchema(xsdtree)

    errors  = []

    if(not schema.validate(xmltree)):
        info_pattern = re.compile(r'^.*:(\d+:)\d+:ERROR:[^:]*:[^:]*:')
        
        for error in schema.error_log:
            err_line = 'line ' + re.sub(info_pattern,r'\1',str(error))
            errors.append(err_line)
        
    return errors

def x_valid_report(xml_file,xsd_file,log_file):
    "Calls xml_validate and prints errors, if any, to log_file"
    err_log = xml_validate(xml_file,xsd_file)
    
    err_out = open(log_file,"w")
    print("New error log entries:\r\nfile: " + xml_file,end='\r\n',file=err_out)
        
    for line in err_log:
        print(line,end='\r\n',file=err_out)
            
    print("\r\n",end='\r\n',file=err_out)
    err_out.close()

    return
