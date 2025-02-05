/**************************************************************************************************************
* Macro_Name: dt_query
*
* Purpose: This macro is used to create a date string for a particular database type.
*
* Usage: %dt_query(interval,offset,useDbtype,quote=,date=,alignment=B)
*
* Input_parameters: interval
*                    Date interval to use. Valid values are:
*                     YEAR, QTR, MONTH, WEEK, DAY
*                   offset
*                     Integer representing the number of intervals to offset.
*                   useDbtype
*                    Specify dbtype to use for formatting: db2/oracle/sqlsvr. If missing, sas date value is returned.
*                   quote=
*                     Y/N Specify Y to enclose the date string in single quotes
*                     Default: Y
*                   date=
*                      Sas date value. Default is process date.
*                   alignment
*                    Position of the dates within the interval. Valid values are:
*                     B, E, M, S
*                     Default: B
*
* Outputs:  None.
*
* Returns:  Formatted date string.
*           If error, jumptoexit=1
*
* Example: %dt_query(month,-1);
*          %dt_query(month,-1,db2);
*
* Modules_called: None
*
* Maintenance_History:
*-------------------------------------------------------------------------------------------------------------*
*  Date:      |   Who:        |  Description:                                                                 *
*-------------------------------------------------------------------------------------------------------------*
* 01/30/2012  | Michael Gilman| Initial creation   .                                                          *
* 04/17/2012  | Michael Gilman| Modified to allow intervals to have a multiplier.                             *
* 04/24/2012  | Michael Gilman| Added new input parameter: alignment.                                         *
* 07/30/2012  | Michael Gilman| Added YEARLY QUARTERLY MONTHLY WEEKLY DAILY to valid pgmgfreqs.               *
*-------------------------------------------------------------------------------------------------------------*
* HeaderEnd:                                                                                                  *
**************************************************************************************************************/

%macro dt_query(interval,offset,useDbtype,quote=,date=,alignment=B)/minoperator;
%put Start macro dt_query;

 %local useFormat useQuote sasdate d interval_temp;

 %if %superq(date)=%str() %then %let date=&dt_sas;

 %if &useDbtype=%str() %then %let useDbtype=&dbtype;

 %let useDbtype=%upcase(&useDbtype);

 %let interval=%upcase(&interval);

 %let interval_temp=%scan(&interval,1,%str(.));

 %let pos=%sysfunc(anydigit(&interval_temp));

 %if &pos %then %let interval_temp=%substr(&interval_temp,1,%eval(&pos-1));

 %if %eval(&interval_temp in YEAR QTR MONTH WEEK DAY YEARLY QUARTERLY MONTHLY WEEKLY DAILY)=0 %then
 %do;

    %let errormsg1=&interval is not a valid date interval.;

    %put ERROR: &errormsg1;

    %let jumptoexit=1;

    %let d=;

    %goto EXIT;

 %end;

 %if %sysfunc(inputn(&offset,best.))=%str() %then
 %do;

    %let errormsg1=&offset is not a valid date offset.;

    %put ERROR: &errormsg1;

    %let jumptoexit=1;

    %let d=;

    %goto EXIT;

 %end;

 %if &useDbtype=%str() %then
 %do;

    /* If useDbtype is missing, assume we need a sas date string */

    %let useFormat=date9.;

    %let useQuote=Y;

    %let sasdate=1;

 %end;
 %else
 %if %eval(&useDbtype in DB2 SQLSVR ORACLE TERADATA) %then
 %do;

       %if &useDbtype eq DB2 %then
       %do;

          /*      date format is 'mm/dd/yyyy' */

          %let useFormat=mmddyy10.;

          %let useQuote=Y;

       %end;

       %else
       %if &useDbtype eq SQLSVR %then
       %do;

          /*      date format is  'mm/dd/yyyy' */

          %let useFormat=mmddyy10.;

          %let useQuote=Y;

       %end;
       %else
       %if &useDbtype eq ORACLE %then
       %do;

          /*      date format is 01-DEC-2011*/

          %let useFormat=date11.;

          %let useQuote=Y;

       %end;
       %else
       %if &useDbtype eq TERADATA %then
       %do;

          /*      date format is '2012-01-01'*/

          %let useFormat=yymmddd10.;

          %let useQuote=Y;
       %end;

 %end;
 %else
 %do;

    %let errormsg1=Unrecognized useDbtype value &useDbtype..;
    %let errormsg2=Must be one of DB2, SQLSVR, ORACLE, TERADATA.;

    %put;
    %put ERROR: &errormsg1;
    %put ERROR: &errormsg2;
    %put;

    %let jumptoexit=1;

    %let d=;

    %goto EXIT;

 %end;

 %if &quote ne %str() %then %let useQuote=&quote;

 %let d=%dt_date(date=&date,interval=&interval,format=&useFormat,offset=&offset.,alignment=&alignment,quote=&useQuote);

 %if &sasdate=1 %then %let d=%superq(d)D;

%EXIT:

 %unquote(%superq(d))

%put End macro dt_query;
%mend dt_query;
