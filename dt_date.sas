/**************************************************************************************************************
* Macro_Name: dt_date
*
* Purpose: Offset and format a sas date value. Optionally enclose in
*          single quotes.
*
* Usage: dt_date(date=,interval=,format=,offset=-1,alignment=B,quote=Y;
*
* Input_parameters: date
*                    Sas date value. Default is process date.
*                   format
*                    Sas format to use.
*                   Interval
*                    Date interval to use. Valid values are:
*                     YEAR, QTR, MONTH, WEEK, DAY
*                   offset
*                     Integer representing the number of intervals to offset.
*                   Alignment
*                    Position of the dates within the interval. Valid values are:
*                     B, E, M, S
*                   Quote
*                     Y/N Specify Y to enclose the date string in single quotes.
*                     Default: Y
*
* Outputs:  None.
*
* Returns:   Date string value.
*
* Example:  %dt_date(interval=month,offset=-1,format=mmddyy8);
*
* Modules_called: None
*
* Maintenance_History:
*-------------------------------------------------------------------------------------------------------------*
*  Date:      |   Who:        |  Description:                                                                 *
*-------------------------------------------------------------------------------------------------------------*
* 01/01/2012  | Michael Gilman| Initial creation.                                                             *
* 04/17/2012  | Michael Gilman| Modified to allow intervals to have a multiplier.                             *
* 06/19/2012  | Michael Gilman| Now allow passing in missing format. If so, a sas date integer value is       *
*             |               | returned.                                                                     *
* 07/30/2012  | Michael Gilman| Added YEARLY QUARTERLY MONTHLY WEEKLY DAILY to valid pgmgfreqs.               *
*-------------------------------------------------------------------------------------------------------------*
* HeaderEnd:                                                                                                  *
**************************************************************************************************************/

%macro dt_date(date=,interval=,format=,offset=-1,alignment=B,quote=Y)/minoperator;
%put Start macro dt_date;

 %local interval_temp;

 %local d fmt rc dsid;

 %if %superq(date)=%str() %then %let date=&dt_sas;

 %let interval=%upcase(&interval);

 %let quote=%upcase(&quote);

 %let alignment=%upcase(&alignment);

 %if &format ne %str() %then
 %do;

    %let fmt=%upcase(%sysfunc(compress(&format,%str(.),d)));

    %let dsid=%sysfunc(open(sashelp.vformat(where=(fmtname="&fmt"))));

    %let rc=%sysfunc(fetch(&dsid));

    %let dsid=%sysfunc(close(&dsid));

    %if &rc=-1 %then
    %do;

       %let errormsg1=&format is not a valid format.;

       %let jumptoexit=1;

       %let d=;

       %goto EXIT;

    %end;

 %end;
 %else
 %do;

    %let format=best.;

    %let quote=N;

 %end;

 %let interval_temp=%scan(&interval,1,%str(.));

 %let pos=%sysfunc(anydigit(&interval_temp));

 %if &pos %then %let interval_temp=%substr(&interval_temp,1,%eval(&pos-1));

 %if %eval(&interval_temp in YEAR QTR MONTH WEEK DAY YEARLY QUARTERLY MONTHLY WEEKLY DAILY)=0 %then
 %do;

    %let errormsg1=&interval is not a valid date interval.;

    %let jumptoexit=1;

    %let d=;

    %goto EXIT;

 %end;

 %if %sysfunc(inputn(&offset, best.))=%str()  %then
 %do;

    %let errormsg1=&offset is not a valid offset.;

    %let jumptoexit=1;

    %let d=;

    %goto EXIT;

 %end;

 %if &quote ne Y and &quote ne N %then
 %do;

    %let errormsg1=&quote is not a valid Quote value. Must be Y or N.;

    %let jumptoexit=1;

    %let d=;

    %goto EXIT;

 %end;

 %if &alignment ne B and &alignment ne E and &alignment ne M and &alignment ne S %then
 %do;

    %let errormsg1=&alignment is not a valid alignment value. Must be B, E, M, S.;

    %let jumptoexit=1;

    %let d=;

    %goto EXIT;

 %end;

 %let date=%sysfunc(intnx(&interval,&date,&offset,&alignment));

 %let d=%sysfunc(putn(&date,&format));

 %if %superq(d)=%str()  %then
 %do;

    %let errormsg1=&format is not a valid format.;

    %let jumptoexit=1;

    %let d=;

    %goto EXIT;

 %end;


 %if &quote=Y %then %let d=%unquote(%str(%')&d%str(%'));

%EXIT:

 %unquote(&d)

%put End macro dt_date;
%mend dt_date;
