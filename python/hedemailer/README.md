# hedemailer

hedemailer is a Python 3 package is a webhook implementation that sends out an email whenever there is an update to the Wiki HED schema. 

For the HED schema please visit: <https://github.com/BigEEGConsortium/HED-schema/wiki/HED-Schema>

### Dependencies

* [Python 3](https://www.python.org/downloads/)
* SMTP server
* [hedconversion](../hedconversion)

### Screenshots

![Email example](screenshots/hedemailer-email.png)

### Notes
* The webhook has been implemented to ONLY accept JSON content type and Wiki page updates (gollum) events. 
* Emails may potentially be blocked without a fully-qualified domain name.  
