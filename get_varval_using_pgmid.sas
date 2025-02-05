/**************************************************************************************************************
* Macro_Name: get_varval_using_pgmid
*
* Purpose: This macro gets a variable value from adminlib.programsetup based on the input pgmid.
*
* Usage: %get_varval_from_pgmid(pgmid,var);
*
* Input_parameters: pgmid
*                    Program name
*                   var
*                    Variable to retrieve a value for
*
* Outputs:  None.
*
* Returns:  varval (global)
*            Value found
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
* 06/05/2012  | Michael Gilman| Initial creation.                                                             *
* 09/23/2012  | Michael Gilman| Removed following statement at end of macro:                                  *
*             |               |  %if %superq(errormsg1) ne %str() %then %put ERROR: &errormsg1;               *
*-------------------------------------------------------------------------------------------------------------*
* HeaderEnd:                                                                                                  *
**************************************************************************************************************/

%macro get_varval_using_pgmid(pgmid,var);
%put Start macro get_varval_using_pgmid;

 %global varval;

 %local dsid varnum vartype;

 %let varval=;

 %let dsid=0;

 %let errormsg1=;

 %lock_on_member(adminlib.programsetup);
 %if &jumptoexit %then
 %do;

    %let errormsg1=Could not lock adminlib.programsetup;

    %goto EXIT;

 %end;

 %let dsid=%sysfunc(open(adminlib.programsetup(where=(pgmid="&pgmid"))));

 %if &dsid=0 %then
 %do;

    %let errormsg1=Could not open data set adminlib.programsetup;

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

 %let rc=%sysfunc(fetch(&dsid));

 %if &rc=-1 %then
 %do;

    %let jumptoexit=1;

    %let errormsg1=No record found for pgmid &pgmid;

    %goto EXIT;

 %end;

 %let vartype=%sysfunc(vartype(&dsid,&varnum));

 %if &vartype=C %then %let varval=%sysfunc(getvarc(&dsid,&varnum));
 %else %let varval=%sysfunc(getvarn(&dsid,&varnum));

%EXIT:

 %if &dsid>0 %then %let dsid=%sysfunc(close(&dsid));

 %lock_off_member(adminlib.programsetup);


%put End macro get_varval_using_pgmid;
%mend get_varval_using_pgmid;