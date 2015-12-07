HED conversion utilites
===============

Contains various python subprojects for tagging and other text manipulation.

###This is a GUI that contains the following functionality
1. Convert an HED hierarchy from formatted .txt to an xml formatted file.
2. Verify the HED hierarchy in xml form against an xml schema.
3. Verify formatted tags against an HED hierarchy.
4. Create a file that shows a mapping from one HED hierarchy to another.

##Installation
###Windows users
* You do _not_ need to have a python interpreter installed in order to run this
* In order to run the GUI, all you need to do is the following:
 1. Download HEDUtils.zip from the github page,(this will be under builds)
 2. Right click and choose the 'extract all' option,(or unzip as you'd like)
 3. Select an appropriate destination for the directory
 4. Find the file 'HEDConversionUtilities', under the directory you extracted into,(in the 'HEDUtils' directory)
 5. Double-click on the icon
 6. You can optionally right-click and create a shortcut to the desktop as you'd like, this will be fairly helpful as you will no longer need to look for where you put the program, you can just access it from the desktop via the shortcut.

###Linux users
 * In the 'builds' directory is the linux build wrapped up in 'HEDUtils.tar.gz'
 * Run <pre><code>tar -xzvf HEDUtilities.tar.gz</code></pre> in the containing directory
 * The executable will be named HEDConversionUtility.

##Some technical notes about this GUI
###All users
* The scripts will run with Python 3.4+.
* If you will run from the Python interpreter, you will need the lxml library, which can be obtained at www.lfd.uci.edu/~gohlke/pythonlibs/#lxml

###Windows users
* The exe version can be run from 64 bit Windows 7.
* The executable and all other files in it's directory must be left there for the executable to work properly.  
 However, the directory may be moved wherever your system allows.

###Linux users
* You may need to change the permissions of the executable before running it on your machine.
* The executable can be run from 64 bit Ubuntu, running on an x86_64 machine.

##Help
###HED txt to xml
 This utility is meant to convert an HED hierarchy in plain text
 form into an XML tree. 'HED input' is a .txt file. This should
 be obtained by converting the HED hierarchy from google docs to
 plain text. No modifications to the plain text converted over
 from google docs is necessary. 'Output file'is a pathname, with
 the filename at the end that you would like the resulting
 xml file to have. If you are on Windows and you do not wish to
 use an xml viewer to look at the output, simply change the '.xml
 file extension to '.txt'.

###Validate HED xml
 This utility is used to validate the xml form of the HED
 hierarchy against an appropriate xml schema. 'XML schema'
 is of course the file which contains the xml schema you would 
 like to verify against. 'XML' is the file which contains the
 HED hierarchy in xml form. 'XML error file' is the file which
 will contain the result of the validation of the hierarchy
 against the given schema. If there are no errors, the file
 will contain the usual header, but with no errors reported.

###Verify tags
 This utility is used to check tags against a given HED
 hierarchy. 'HED input' is the plain text file containing 
 the HED hierarchy, as converted from the HED google doc
 to plain text. 'Tags file' is a tab-separated-value file,
 which contains the tags to be verified. 'Output' will 
 be the path for the output files with the name of the 
 beginning of the output file names at the end. Note: there
 will always be two output files, one called a positive 
 report, another a negative report. Items in the positive 
 report may be correct, but require further inspection. 
 Items in the negative report are certainly incorrect. 
 'Column list' is a list of integers which correspond to
 the columns in the 'Tags file' which contain the tags to
 be tested. The first column of the 'Tags file' is column
 number one. So, column numbers cannnot be less than one,
 and no greater than the maximum number of columns in each
 line. Note: any single character can be used as a delimiter
 for the column list, and separating white space will be 
 ignored.

###HED mapping
 This utility prints out the full mapping, with comments, from 
 one HED hierarchy to another. 'HED source txt' is the HED
 hierarchy taken from a google doc, by converting from the google
 doc to plain text. 'Remap HED' is the file which contains the
 mapping itself. 'Map output' is the output file which contains
 the full mapping from the given HED to the other given by 
 'Remap HED'. The purpose of this utility is to check what has
 and has not been mapped, and to examine everything that has 
 been mapped between the two hierarchies.
