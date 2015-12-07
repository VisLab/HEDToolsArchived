from tkinter import *
from tkinter import ttk,filedialog,messagebox
from hedlib.hed_xml_validate import x_valid_report
from hedlib.map_hed import print_map
from hedguiutillib import *
import os
import re

#All of the following functions, up to main
#are functions to be called by the various
#tkinter widgets that comprise the GUI.

#input selection functions
def select_hed(ifile,ofile):
    ifile.set(filedialog.askopenfilename())
    
    if(not os.path.isdir(ofile.get()) and ifile.get() != ""):
        ofile_default = re.sub(r'\.txt$','.xml',ifile.get())
        ofile.set(ofile_default)

    return

def select_xsd(schema):
    schema.set(filedialog.askopenfilename())
    return

def select_xml(xml_in,log_out):
    xml_in.set(filedialog.askopenfilename())
    
    if(not os.path.isdir(log_out.get()) and xml_in.get() != ""):
        err_default = ''

        if(re.search(r'\.xml$',xml_in.get())):
            err_default = re.sub(r'\.xml$','_validate_err.txt',xml_in.get())
        elif(re.search(r'\.txt$',xml_in.get())):
            err_default = re.sub(r'\.txt$','_validate_err.txt',xml_in.get())


        log_out.set(err_default)

    return
        
def select_verify_hed(verify_hed):
    verify_hed.set(filedialog.askopenfilename())
    return

def select_tags(tag_file,report_path):
    tag_file.set(filedialog.askopenfilename())
    if(not os.path.isdir(report_path.get()) and tag_file.get() != ""):
        report_path.set(tag_file.get())
    return

def select_map_hed(map_hed):
    map_hed.set(filedialog.askopenfilename())
    return

def select_map_in(map_in,map_out):
    map_in.set(filedialog.askopenfilename())
    if(not os.path.isdir(map_out.get()) and map_in.get() != ""):
        m_out_default = re.sub(r'(\.txt)$',r'_out\1',map_in.get())
        map_out.set(m_out_default)
    return

#output selection functions
def select_convert_out(ofile,ifile):
    my_dir= filedialog.askdirectory()
    if(not os.path.isdir(ofile.get()) and ofile.get() != ""):
        out_name = re.sub(r'.*/([^/]*)$',r'\1',ofile.get())
        ofile.set(my_dir + "/" + out_name)

    elif(os.path.isfile(ifile.get())):
        ofile_default = re.sub(r'\.txt$','.xml',ifile.get())
        ofile_default = re.sub(r'.*/([^/]*)$',r'\1',ofile_default)
        ofile.set(my_dir + "/" + ofile_default)

    else:
        ofile.set(my_dir)
    
    return

def validate_err_out(log_out,xml_in):
    my_dir = filedialog.askdirectory()
    if(not os.path.isdir(log_out.get()) and log_out.get() != ""):
        err_name = re.sub(r'.*/([^/]*)$',r'\1',log_out.get())
        log_out.set(my_dir + "/" + err_name)

    elif(os.path.isfile(xml_in.get())):
        err_default = re.sub(r'\.txt$','_err.txt',xml_in.get())
        err_default = re.sub(r'.*/([^/]*)$',r'\1',err_default)
        log_out.set(my_dir + "/" + err_default)

    return

def select_report(report_path):
    report_dir = filedialog.askdirectory()
    
    if(not os.path.isdir(report_path.get()) and report_path.get() != ""):
        report_name = re.sub(r'.*/([^/]*)$',r'\1',report_path.get())
        report_path.set(report_dir + "/"  + report_name)
    else:
        report_path.set(report_dir)

    return

def select_map_out(map_out):
    map_out_dir = filedialog.askdirectory()

    if(not os.path.isdir(map_out.get()) and map_out.get() != ""):
        map_out_name = re.sub(r'.*/([^/]*)$',r'\1',map_out.get())
        map_out.set(map_out_dir + "/" + map_out_name)
    else:
        map_out.set(map_out_dir)

    return

#help button functions
def _alt_help(args,has_help):
    if(has_help.get()):
        has_help.set(False)
    return

def _make_help_win(root,has_help):
    help_win = Toplevel(root)
    help_win.bind(sequence='<Destroy>',func=lambda args, has_help=has_help : _alt_help(args,has_help) )
    help_win.resizable(False,False)

    win_frame = ttk.Frame(help_win)
    win_frame.grid(column=0,row=0)

    lines = []
    rows = 0
    HELP = open('HED_help.txt','r')
    for line in HELP:
        lines.append(line)
        rows += 1

    HELP.close()

    help_str = ''.join(lines).strip()
    vis_rows = rows//2

    help_msg = Text(win_frame,width=64,height=vis_rows)
    help_msg.insert(1.0,help_str)
    help_msg.grid(column=1,row=1,sticky=W,padx=4,pady=2)

    scroll = ttk.Scrollbar(win_frame,orient=VERTICAL,command=help_msg.yview)
    scroll.grid(column=2,row=1,sticky=(N,S))

    help_msg.configure(state='disabled',yscrollcommand=scroll.set)

    return help_win

def help_win(root,has_help):
    if(not has_help.get()):
        help_win = _make_help_win(root,has_help)
        has_help.set(True)
    return

#library function calls
def HED_to_XML_out(ifile,ofile):
    try:
        HED_to_XML(ifile.get(),ofile.get())
    except FileNotFoundError:
        file_err_str = ''
        if(not os.path.isfile(ifile.get())):
            file_err_str = "File not found!!!\n" + ifile.get() + " does not exist"
        else:
            file_err_str = "Directory for output not found!!!:\n" + ofile.get()
            
        messagebox.showinfo(message=file_err_str)
    except Exception as inst:
        unknown_err = "Unexpected error occured:\n" + str(inst)
        messagebox.showinfo(message=unknown_err)
    
    return
    
def validate_xml(schema,xml_in,log_out):
    try:
        x_valid_report(xml_in.get(),schema.get(),log_out.get())
    except FileNotFoundError:
        file_err_str = ''
        if(os.path.isfile(schema.get())):
            file_err_str = "File not found: " + xml_in.get()
        else:
            file_err_str = "File not found: " + schema.get()
            
        messagebox.showinfo(message=file_err_str)
    except Exception as inst:
        unknown_err = "Unexpected error occured:\n" + str(inst)
        messagebox.showinfo(message=unknown_err)

    return
        
def tags_verify(verify_hed,tag_file,col_str,report_path):
    no_num = re.search(r'^\D*$',col_str.get())
    if(no_num):
        messagebox.showinfo(message="No numbers in column list")
        return
    
    try:
       verify_HED_tags(verify_hed.get(),tag_file.get(),col_str.get(),report_path.get())
    except ValueError as err:
        err_message = str(err)
        messagebox.showinfo(message=err_message)
    except FileNotFoundError as err:
        err_message = str(err)
        messagebox.showinfo(message=err_message)
    except Exception as err:
        err_message = str(err)
        messagebox.showinfo(message=err_message)

    return

def create_map(map_out,map_hed,map_in):
    try:
        print_map(map_out.get(),map_hed.get(),map_in.get())
    except Exception as err:
        err_message = str(err)
        messagebox.showinfo(message=err_message)

    return

#Function that creates GUI
def main():
    "Function that calls functions to creates GUI"

    x_pad = 2
    y_pad = 4
    default_entry_width = 96

    root = Tk()
    root.title("HED conversion utilities")
    root.resizable(False, False)
    
    tabs = ttk.Notebook(root)
    tabs.grid(column=0,row=0,sticky=(N,S,E,W))
    
    txtTOxml = ttk.Frame(tabs)
    xsdVal = ttk.Frame(tabs)
    verify = ttk.Frame(tabs)
    HED_map = ttk.Frame(tabs)
    
    tabs.add(txtTOxml, text='HED txt to xml')
    tabs.add(xsdVal, text='Validate HED xml')
    tabs.add(verify, text='Verify tags')
    tabs.add(HED_map, text='HED mapping')

    #variable to check if user already has help window up
    #user should not have more than one help window up at a time
    has_help = BooleanVar()
    has_help.set(False)
    def get_help(root=root,has_help=has_help): return help_win(root,has_help)
    
    #convert plain text HED to xml
    #select input HED file
    hed_in = StringVar()
    xml_out = StringVar()

    ttk.Label(txtTOxml,text="HED input",justify="left").grid(column=1,row=1,sticky=W,padx=x_pad,pady=y_pad)
  
    ttk.Entry(txtTOxml,textvariable=hed_in,width=default_entry_width).grid(column=2,row=1,padx=x_pad,pady=y_pad)
    
    def sel_hed(ifile=hed_in,ofile=xml_out): return select_hed(ifile,ofile)
    ttk.Button(txtTOxml,text="Browse",command=sel_hed).grid(column=3,row=1,padx=x_pad,pady=y_pad)
    
    #select output directory
    ttk.Label(txtTOxml,text="Output file",justify="left").grid(column=1,row=2,sticky=W,padx=x_pad,pady=y_pad)
    
    ttk.Entry(txtTOxml,textvariable=xml_out,width=default_entry_width).grid(column=2,row=2,padx=x_pad,pady=y_pad)
    
    def sel_con(ofile=xml_out,ifile=hed_in): return select_convert_out(ofile,ifile)
    ttk.Button(txtTOxml,text="Browse",command=sel_con).grid(column=3,row=2,padx=x_pad,pady=y_pad)
    
    #convert button
    def con_hed(ifile=hed_in,ofile=xml_out): return HED_to_XML_out(ifile,ofile)
    ttk.Button(txtTOxml,text="Convert",command=con_hed).grid(column=3,row=4,padx=x_pad,pady=y_pad)
    
    #help button
    ttk.Button(txtTOxml,text="Help",command=get_help).grid(column=3,row=5,padx=x_pad,pady=y_pad)

    #validate an xml against a schema
    #select XML schema
    xsd_in = StringVar()
    xml_in = StringVar()
    validate_err_log = StringVar()

    ttk.Label(xsdVal,text="XML schema",justify="left").grid(column=1,row=1,sticky=W,padx=x_pad,pady=y_pad)
    
    ttk.Entry(xsdVal,textvariable=xsd_in,width=default_entry_width).grid(column=2,row=1,padx=x_pad,pady=y_pad)
    
    def sel_xsd(schema=xsd_in): return select_xsd(schema)
    ttk.Button(xsdVal,text="Browse",command=sel_xsd).grid(column=3,row=1,padx=x_pad,pady=y_pad)
    
    #select XML to validate
    ttk.Label(xsdVal,text="XML",justify="left").grid(column=1,row=2,sticky=W,padx=x_pad,pady=y_pad)
    
    ttk.Entry(xsdVal,textvariable=xml_in,width=default_entry_width).grid(column=2,row=2,padx=x_pad,pady=y_pad)
    
    def sel_xml(xml_in=xml_in,log_out=validate_err_log): return select_xml(xml_in,log_out)
    ttk.Button(xsdVal,text="Browse",command=sel_xml).grid(column=3,row=2,padx=x_pad,pady=y_pad)
    
    #error log
    ttk.Label(xsdVal,text="XML error file",justify="left").grid(column=1,row=3,sticky=W,padx=x_pad,pady=y_pad)
    
    ttk.Entry(xsdVal,textvariable=validate_err_log,width=default_entry_width).grid(column=2,row=3,padx=x_pad,pady=y_pad)
    
    def sel_log(log_out=validate_err_log,xml_in=xml_in): return validate_err_out(log_out,xml_in)
    ttk.Button(xsdVal,text="Browse",command=sel_log).grid(column=3,row=3,padx=x_pad,pady=y_pad)
    
    #validate button
    def val_xml(schema=xsd_in,xml_in=xml_in,log_out=validate_err_log): return validate_xml(schema,xml_in,log_out)
    ttk.Button(xsdVal,text="Validate",command=val_xml).grid(column=3,row=4,padx=x_pad,pady=y_pad)
    
    #help button
    ttk.Button(xsdVal,text="Help",command=get_help).grid(column=3,row=5,padx=x_pad,pady=y_pad)

    #verify a tags data file
    #print reports to selected file
    verify_hed = StringVar()
    tag_file = StringVar()
    report_path = StringVar()
    col_str = StringVar()

    ttk.Label(verify,text="HED input",justify="left").grid(column=1,row=1,sticky=W,padx=x_pad,pady=y_pad)
    
    #hed hierarchy file to verify against
    ttk.Entry(verify,textvariable=verify_hed,width=default_entry_width).grid(column=2,row=1,columnspan=2,padx=x_pad,pady=y_pad)
    
    #select hed file to verify against
    def sel_ver(verify_hed=verify_hed): return select_verify_hed(verify_hed)
    ttk.Button(verify,text="Browse",command=sel_ver).grid(column=4,row=1,padx=x_pad,pady=y_pad)
    
    #select file with tags to be verified
    ttk.Label(verify,text="Tags file",justify="left").grid(column=1,row=2,sticky=W,padx=x_pad,pady=y_pad)
    
    #file with tags to be verified
    ttk.Entry(verify,textvariable=tag_file,width=default_entry_width).grid(column=2,row=2,columnspan=2,padx=x_pad,pady=y_pad)
    
    #select tags file
    def sel_tag(tag_file=tag_file,report_path=report_path): return select_tags(tag_file, report_path)
    ttk.Button(verify,text="Browse",command=sel_tag).grid(column=4,row=2,padx=x_pad,pady=y_pad)
    
    #select output path, note the file name will be somewhat different
    #the positive report will have 'pos_' appended, and
    #the negative name 'neg_'
    ttk.Label(verify,text="Output*",justify="left").grid(column=1,row=3,sticky=W,padx=x_pad,pady=y_pad)
    
    #output file(s) name
    ttk.Entry(verify,textvariable=report_path,width=default_entry_width).grid(column=2,row=3,columnspan=2,padx=x_pad,pady=y_pad)
    
    #select output path
    def sel_rep(report_path=report_path): return select_report(report_path)
    ttk.Button(verify,text="Browse",command=sel_rep).grid(column=4,row=3,padx=x_pad,pady=y_pad)
    
    #select columns to be verified
    ttk.Label(verify,text="Column list",justify="left").grid(column=1,row=4,sticky=W,padx=x_pad,pady=y_pad)
    
    #list of columns
    ttk.Entry(verify,textvariable=col_str,width=(default_entry_width//2)).grid(column=2,row=4,sticky=W, padx=x_pad,pady=y_pad)
    
    #Warning to user about output file name ending with 'pos_' and 'neg_'
    ttk.Label(verify,text="*There will be two ouput files, one suffixed with '_wrn.txt', the other with '_err.txt'",justify="left").grid(column=1,row=5,sticky=W,columnspan=3,padx=x_pad,pady=y_pad)
    
    #verify/print reports
    def tag_ver(verify_hed=verify_hed,tag_file=tag_file,col_str=col_str,report_path=report_path): return tags_verify(verify_hed,tag_file,col_str,report_path)
    ttk.Button(verify,text="Verify",command=tag_ver).grid(column=4,row=4,padx=x_pad,pady=y_pad)

    #help button
    ttk.Button(verify,text="Help",command=get_help).grid(column=4,row=5,padx=x_pad,pady=y_pad)

    #HED mapping
    #HED hierarchy input
    map_hed = StringVar()
    map_in = StringVar()
    map_out = StringVar()

    ttk.Label(HED_map,text="HED source txt",justify="left").grid(column=1,row=1,sticky=W,padx=x_pad,pady=y_pad)
    
    ttk.Entry(HED_map,textvariable=map_hed,width=default_entry_width).grid(column=2,row=1,padx=x_pad,pady=y_pad)
    
    def sel_m_h(map_hed=map_hed): return select_map_hed(map_hed)
    ttk.Button(HED_map,text="Browse",command=sel_m_h).grid(column=3,row=1,padx=x_pad,pady=y_pad)

    #Mapping input
    ttk.Label(HED_map,text="Remap HED",justify="left").grid(column=1,row=2,sticky=W,padx=x_pad,pady=y_pad)
    
    ttk.Entry(HED_map,textvariable=map_in,width=default_entry_width).grid(column=2,row=2,padx=x_pad,pady=y_pad)
    
    def sel_m_i(map_in=map_in,map_out=map_out): return select_map_in(map_in,map_out)
    ttk.Button(HED_map,text="Browse",command=sel_m_i).grid(column=3,row=2,padx=x_pad,pady=y_pad)

    #Output map
    ttk.Label(HED_map,text="Map output",justify="left").grid(column=1,row=3,sticky=W,padx=x_pad,pady=y_pad)
    
    ttk.Entry(HED_map,textvariable=map_out,width=default_entry_width).grid(column=2,row=3,padx=x_pad,pady=y_pad)

    def sel_m_o(map_out=map_out): return select_map_out(map_out)
    ttk.Button(HED_map,text="Browse",command=sel_m_o).grid(column=3,row=3,padx=x_pad,pady=y_pad)

    #Create map
    def crt_map(map_out=map_out,map_hed=map_hed,map_in=map_in): return create_map(map_out,map_hed,map_in)
    ttk.Button(HED_map,text="Create map",command=crt_map).grid(column=3,row=4,padx=x_pad,pady=y_pad)
    
    #help button
    ttk.Button(HED_map,text="Help",command=get_help).grid(column=3,row=5,padx=x_pad,pady=y_pad)

    root.mainloop()

    return

if __name__ == "__main__":
    main()
