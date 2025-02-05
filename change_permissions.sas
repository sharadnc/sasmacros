/**************************************************************************************************************
* Macro_Name:   change_permissions
*
* Purpose: This macro is used to change a Unix file or directory permissions.
*
* Usage: %change_permissions(path,unxfile,dir=,chmod_value=775);
*
* Input_parameters: path
*                    Unix pathname to the file
*                   unxfile
*                    Name of the file on which to chamge permissions
*                   dir=
*                    When specified, overrides path and unxfile.
*                   chmod_value=
*                    chmod value. Default is 775.
*
* Outputs:  None.
*
* Returns:  If error, jumptoexit=1
*
* Example:
*
* Modules_called: None
*
* Maintenance_History:
*-------------------------------------------------------------------------------------------------------------*
*  Date:      |   Who:        |  Description:                                                                 *
*-------------------------------------------------------------------------------------------------------------*
* 12/14/2011  | Sharad           | Initial creation.                                                          *
* 12/14/2011  | Michael Gilman   | Initial creation.                                                          *
* 07/22/2011  | Michael Gilman   | Fixed bug. %if %superq(dir) ne %str() should be %if %superq(dir)=%str()    *
* 09/20/2012  | Michael Gilman   | Now check if file exists.                                                  *
*-------------------------------------------------------------------------------------------------------------*
* HeaderEnd:                                                                                                  *
**************************************************************************************************************/

%macro change_permissions(path,unxfile,dir=,chmod_value=775);
%put Start macro change_permissions;

 %local file;

 %if %superq(dir) ne %str() %then %let file=&dir;
 %else %let file=%superq(path)/&unxfile;

 %if %sysfunc(fileexist(&file))=0 %then
 %do;

    %let errormsg1=%superq(file) does not exist;

    %let errormsg2=Could not change permissions;

    %put ERROR: &errormsg1;
    %put ERROR: &errormsg2;

    %let jumptoexit=1;

    %goto EXIT;

 %end;

 systask command "chmod -R &chmod_value %superq(file)" wait taskname=changemod status=chgmod;

 waitfor changemod;

 %if &chgmod ne 0 or &sysrc>4 %then
 %do;

    %let errormsg1=Could not change the permissions to %superq(file);

    %put ERROR: &errormsg1;

    %let jumptoexit=1;

 %end;

%EXIT:

%put End macro change_permissions;
%mend change_permissions;