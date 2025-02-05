/**************************************************************************************************************
* Macro_Name:   assign_libref_using_pgmname
*
* Purpose: This macro assigns a saslib libref using an input program name.
*
* Usage: %assign_libref_using_pgmname(libref=,pgmname=,offset=,format=,loc=data,align=B);
*
* Input_parameters: libref
*                    libref to assign.
*                   pgmname
*                    Name of program from which to obtain data library pathname.
*                   offset
*                    Optional date interval offset to calculate process date needed by calling program.
*                    Default: -1
*                   format
*                    Format to use to generate process date needed by calling program.
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
* 07/30/2011  | Michael Gilman| Initial creation.                                                             *
* 09/09/2012  | Michael Gilman| Now just access adminlib.programsetup once.                                   *
* 10/03/2012  | Michael Gilman| Fixed bug. Was wrongly invoking %error_check macro after the proc sql to      *
*             |               | check for zero records. Now check for missing pgmid.                          *
* 10/03/2012  | Michael Gilman| Added new input parameter: loc. Valid values are data, history, extract.      *
*             |               | Default is data.                                                              *
*-------------------------------------------------------------------------------------------------------------*
* HeaderEnd:                                                                                                  *
**************************************************************************************************************/

%macro assign_libref_using_pgmname(libref=,pgmname=,offset=-1,format=,loc=data,align=B);
%put Start macro assign_libref_using_pgmname;

 %local pgmid security_level lob SubjectArea pgmfreq date;

 %if &loc ne data and &loc ne history and &loc ne extract %then
 %do;

    %let errormsg1=Invalid value &loc for loc parameter for macro assign_libref_using_pgmname.;
    %let errormsg2=Valid values are data, history, extract.;

    %goto ERREXIT;

 %end;

 %assign_libref(adminlib,&rootloc/admin/data);
 %if &jumptoexit %then %goto ERREXIT;

 /* Get attributes of the program from adminlib.ProgramSetup */

 proc sql noprint;
 select pgmid, pgmfreq, lob, security_level, SubjectArea
 into :pgmid, :pgmfreq, :lob, :security_level, :SubjectArea
 from adminlib.programsetup
 where pgmname="&pgmname"
 ;
 quit;

 %chkerr(msg1=&syserrortext);
 %if &jumptoexit %then %goto ERREXIT;

 %if &pgmid=%str() %then
 %do;

    %let errormsg1=Program &pgmname not found.;

    %goto ERREXIT;

 %end;

 %let pgmid=%trim(%left(&pgmid));
 %let pgmfreq=%trim(%left(&pgmfreq));
 %let lob=%lowcase(%trim(%left(&lob)));
 %let security_level=%trim(%left(&security_level));
 %let SubjectArea=%trim(%left(&SubjectArea));
 %let SendZip=%trim(%left(&SendZip));
 %let notify_email=%trim(%left(&notify_email));

 %let SubjectArea=%sysfunc(lowcase(&SubjectArea));
 %let SubjectArea=%sysfunc(compress(&SubjectArea));
 %let lob=%sysfunc(lowcase(&lob));
 %let lob=%sysfunc(compress(&lob));

 %let SubjectArea=%sysfunc(compress(%lowcase(&SubjectArea)));

 %assign_libref(&libref,&rootloc/&loc/&security_level/&lob/&SubjectArea);
 %if &jumptoexit %then %goto ERREXIT;

 %if &format=%str() %then
 %do;

    %if &pgmfreq=Monthly %then %let format=mmyyn4;
    %else %let format=mmddyy6;

 %end;

 %let date=%dt_date(interval=&pgmfreq,format=&format,offset=&offset,alignment=&align,quote=N);

 %let dataset_prefix=&security_level&pgmid._&date._;

%ERREXIT:

%put End macro assign_libref_using_pgmname;
%mend assign_libref_using_pgmname;