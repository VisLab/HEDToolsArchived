# HEDTools - Python
HED (Hierarchical Event Descriptors) is a framework for systematically describing both laboratory and real-world events. HED tags are comma-separated path strings. The goal of HED is to describe precisely the nature of the events of interest occurring in an experiment using a common language. HED, itself, is platform-independent and data-neutral. Most people will simply annotate their events by creating a spreadsheet that associates HED tags with event codes or the events themselves. If you have such a spreadsheet, you can use the HED Online Validator (http://netdb1.cs.utsa.edu/hed/) to validate your spreadsheet without downloading any tools.

### Python functions
 - gollum_email    converts a HED schema to an XML file (python 2)
 - hedconversion   converts a HED schema to an XML file to use in validation (python 3)
 - hedemailer      implements the web hook that emails updates of HED schema to other tools
 - hedvalidation   main python code for validating hed tags
 - webinterface    contains the code to deploy the python validator as a docker module

### Examples


