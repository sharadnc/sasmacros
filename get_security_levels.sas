/**************************************************************************************************************
* Macro_Name: get_security_levels
*
* Purpose: This macro searches a directory for the names of the security level directories contained within it.
*          Security level directories are defined as a directory 2 characters and begins with the letter L.
*
* Usage: %get_security_levels(dir);
*
* Input_parameters: dir
*                    Directory that contains the security level directories
*
* Outputs:  None
*
* Returns:  number_of_security_levels (global)
*           security_levels1-security_levelsn (global)
*            The names of the security level directories
*
* Example:
*
* Modules_called: None
*
* Maintenance_History:
*-------------------------------------------------------------------------------------------------------------*
*  Date:      |   Who:        |  Description:                                                                 *
*-------------------------------------------------------------------------------------------------------------*
* 09/22/2012  | Michael Gilman| Initial creation.                                                             *
*-------------------------------------------------------------------------------------------------------------*
* HeaderEnd:                                                                                                  *
**************************************************************************************************************/

%macro get_security_levels(dir);
%put Start macro get_security_levels;

 %local fref did dnum more security_level;

 %let fref=;

 %let rc=%qsysfunc(filename(fref,%bquote(&dir)));

 %let did=%sysfunc(dopen(&fref));

 %if &did<=0 %then
 %do;

    %put ERROR: Could not open directory &dir;

    %let jumptoexit=1;

    %goto EXIT;

 %end;

 %let dnum=%sysfunc(dnum(&did));

 %if &dnum<=0 %then
 %do;

    %put ERROR: No Security Level directories under &dir;

    %let did=%sysfunc(dclose(&did));

    %let jumptoexit=1;

    %goto EXIT;

 %end;

 %let number_of_security_levels=0;

 %let more=1;

 %do i=1 %to &dnum;

    %let security_level=%qsysfunc(dread(&did,&i));

    %if %length(&security_level)=2 and %substr(&security_level,1,1)=L %then
    %do;

       %let number_of_security_levels=%eval(&number_of_security_levels+1);

       %global security_levels&number_of_security_levels;

       %let security_levels&number_of_security_levels=&security_level;

    %end;

 %end;

 %let did=%sysfunc(dclose(&did));

%EXIT:

%put End macro get_security_levels;
%mend get_security_levels;
