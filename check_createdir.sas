/**************************************************************************************************************
* Macro_Name:   check_createdir
*
* Purpose: This macro is used to check if a directory exists.  If not, the directory is created.
*
* Usage: %check_createdir(dir);
*
* Input_parameters: dir
*                    Directory path
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
*-------------------------------------------------------------------------------------------------------------*
* HeaderEnd:                                                                                                  *
**************************************************************************************************************/

%macro check_createdir(dir);
%put Start macro check_createdir;

 %local rc fileref ;

 %let rc=%sysfunc(filename(fileref,&dir)) ;

 %if %sysfunc(fexist(&fileref))=0 %then
 %do ;

    %sysexec mkdir -p "&dir" ;

    %if &sysrc eq 0 %then %put NOTE: The directory &dir has been created.;
    %else
    %do;

       %let errormsg1=There was a problem while creating the directory &dir;

       %let errormsg2=&syserrortext;

       %let jumptoexit=1;

       %goto EXIT;

    %end;

 %end;

%EXIT:

%put End macro check_createdir;
%mend check_createdir ;
