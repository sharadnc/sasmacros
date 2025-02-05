/**************************************************************************************************************
* Macro_Name:   get_varval_using_pgmname
*
* Purpose: This macro gets a variable value from adminlib.programsetup based on the input program name.
*
* Usage: %get_varval_using_pgmname(pgmname,var);
*
* Input_parameters: pgmname
*                    Program name
*                   var
*                    Variable to retrieve a value for
*
* Outputs:  None.
*
* Returns:  varval
*
* Example:
*
* Modules_called: lock_on_member
*                 lock_off_member
*
* Maintenance_History:
*-------------------------------------------------------------------------------------------------------------*
*  Date:      |   Who:        |  Description:                                                                 *
*-------------------------------------------------------------------------------------------------------------*
* 04/18/2012  | Michael Gilman| Initial creation.                                                             *
*-------------------------------------------------------------------------------------------------------------*
* HeaderEnd:                                                                                                  *
**************************************************************************************************************/

%macro get_varval_using_pgmname(pgmname,var);
%put Start macro get_varval_using_pgmname;

 %global varval;

 %local dsid varnum vartype;

 %let jumptoexit=0;

 %let varval=;

 %let errormsg1=;

 %let dsid=0;

 %lock_on_member(adminlib.programsetup);
 %if &jumptoexit %then %goto EXIT;

 %let dsid=%sysfunc(open(adminlib.programsetup(where=(pgmname="&pgmname"))));

 %if &dsid=0 %then
 %do;

    %let errormsg1=Could not open data set adminlib.programsetup;

    %let jumptoexit=1;

    %goto EXIT;

 %end;

 %let rc=%sysfunc(fetch(&dsid));

 %if &rc=-1 %then
 %do;

    %let jumptoexit=1;

    %goto EXIT;

 %end;

 %let varnum=%sysfunc(varnum(&dsid,&var));

 %if &varnum=0 %then
 %do;

    %let errormsg1=Variable &var does not exist in data set adminlib.programsetup;

    %let jumptoexit=1;

    %goto EXIT;

 %end;

 %let vartype=%sysfunc(vartype(&dsid,&varnum));

 %if &vartype=C %then %let varval=%sysfunc(getvarc(&dsid,&varnum));
 %else %let varval=%sysfunc(getvarn(&dsid,&varnum));

 %let dsid=%sysfunc(close(&dsid));

 %lock_off_member(adminlib.programsetup);

%EXIT:

 %if %superq(errormsg1) ne %str() %then %put ERROR: &errormsg1;

%put End macro get_varval_using_pgmname;
%mend get_varval_using_pgmname;