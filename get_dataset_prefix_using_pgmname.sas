/**************************************************************************************************************
* Macro_Name:   get_dataset_prefix_using_pgmname
*
* Purpose: This macro assigns a saslib libref using an input program name.
*
* Usage: %assign_libref_using_pgmname(libref=,pgmname=,offset=,format=);
*
* Input_parameters: pgmname
*                    Name of program from which to obtain prefix info.
*                   offset
*                    Optional date interval offset to calculate process date needed by calling program.
*                    Default: -1
*                   format
*                    Optional format to use to generate process date needed by calling program.
*                    If not specified, format to use is determined by the pgmfreq of pgmname.
*
* Outputs:  None.
*
* Returns:  dataset_prefix
*            Prefix to use for data sets needed by calling program.
*           If error, jumptoexit=1
*
* Example:
*
* Modules_called: None
*
* Maintenance_History:
*-------------------------------------------------------------------------------------------------------------*
*  Date:      |   Who:        |  Description:                                                                 *
*-------------------------------------------------------------------------------------------------------------*
* 09/10/2012  | Michael Gilman| Initial creation.                                                             *
*-------------------------------------------------------------------------------------------------------------*
* HeaderEnd:                                                                                                  *
**************************************************************************************************************/

%macro get_dataset_prefix_using_pgmname(pgmname=,offset=-1,format=);
%put Start macro get_dataset_prefix_using_pgmname;

 %local pgmfreq date rc;

 %let jumptoexit=0;

 %let dataset_prefix=;

 %let errormsg1=;
 %let errormsg2=;

 %let rc=%sysfunc(libname(adminlib,&rootloc/admin/data));

 %if %sysfunc(libref(adminlib)) %then
 %do;

    %let errormsg1=Could not assign adminlib to &rootloc/admin/data;
    %let errormsg2=&syserrortext;

    %let jumptoexit=1;

    %goto EXIT;

 %end;

 %let dsid=%sysfunc(open(adminlib.programsetup(where=(pgmname="&pgmname"))));

 %if &dsid=0 %then
 %do;

    %let errormsg1=Could not open data set adminlib.programsetup with search criteria pgmname="&pgmname";
    %let errormsg2=&syserrortext;

    %let jumptoexit=1;

    %goto EXIT;

 %end;

 %let rc=%sysfunc(fetch(&dsid));

 %if &rc=-1 %then
 %do;

    %let dsid=%sysfunc(close(&dsid));

    %let errormsg1=Could find pgmname="&pgmname" in adminlib.programsetup;

    %let jumptoexit=1;

    %goto EXIT;

 %end;

 %let security_level=%sysfunc(getvarc(&dsid,%sysfunc(varnum(&dsid,security_level))));

 %let pgmfreq=%sysfunc(getvarc(&dsid,%sysfunc(varnum(&dsid,pgmfreq))));

 %let pgmid=%sysfunc(getvarc(&dsid,%sysfunc(varnum(&dsid,pgmid))));

 %let dsid=%sysfunc(close(&dsid));

 %if &format=%str() %then
 %do;

    %if &pgmfreq=Monthly %then %let format=mmyyn4;
    %else %let format=mmddyy6;

 %end;

 %let date=%dt_date(interval=&pgmfreq,format=&format,offset=&offset,alignment=B,quote=N);

 %let dataset_prefix=&security_level&pgmid._&date._;

%EXIT:

 %if %superq(errormsg1) ne %str() %then %put ERROR: &errormsg1;
 %if %superq(errormsg2) ne %str() %then %put ERROR: &errormsg2;

 &dataset_prefix

%put End macro get_dataset_prefix_using_pgmname;
%mend get_dataset_prefix_using_pgmname;