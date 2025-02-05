/**************************************************************************************************************
* Macro_Name:   create_date_parameters
*
* Purpose: This macro sets various macro date variables to commonly used date values.
*          The dt_prcs global macro variable is used as input. This variable is set in the autoexec.
*
* Usage: %create_date_parameters;
*
* Input_parameters: dt_prcs (global)
*                    The run date. If missing, today's date is used.
*                    Expected date format: mm/dd/yyyy
*
* Outputs:  None
*
* Returns: dt_prcs_sas
*           The process date as a sas date string. e.g. '12JAN2012'D
*          dt_sas
*           The process date as a sas date internal integer. e.g. 19004
*          dt_prcs_data
*           For monthly programs, the end_date without the day component formatted at mmyy.
*           For weekly programs, the end_date formatted at yymmdd.
*           For daily programs, the end_date formatted at yymmdd.
*          emaildate
*           Date shown in subject and body of emails.
*          start_date_year
*           For monthly programs, the year of the prior, previous month based on process date.
*           For weekly programs, the year of the prior, previous day based on process date.
*           For daily programs, the year of the prior, previous day based on process date.
*          start_date_month
*           For monthly programs, the month of the prior, previous month based on process date.
*           For weekly programs, the month of the prior, previous day based on process date.
*           For daily programs, the month of the prior, previous day based on process date.
*          start_date_day
*           For monthly programs always 1.
*           For weekly programs, the day of the prior, previous day based on process date.
*           For daily programs, the day of the prior, previous day based on process date.
*          end_date_year
*           For monthly programs, the year of the previous month based on process date.
*           For weekly programs, the year of the previous day based on process date.
*           For daily programs, the year of the previous day based on process date.
*          end_date_month
*           For monthly programs, the month of the previous month based on process date.
*           For weekly programs, the month of the previous day based on process date.
*           For daily programs, the month of the previous day based on process date.
*          end_date_day
*           For monthly programs always 1.
*           For weekly programs, the day of the previous day based on process date.
*           For daily programs, the day of the previous day based on process date.
*          yr_year
*           The value of &end_date_year prefixed with Yr. Example: 'Yr 2011'
*          end_date
*           A sas date value.
*           For monthly programs, the first day of the previous month based on process date.
*           For weekly programs, the previous day based on process date.
*           For daily programs, the previous day based on process date.
*          date30, date31, date60, date61, date90, date91, date120, date121
*           The start date minus n days formatted as 'mm/dd/yyyy' e.g. '01/03/2012'
*          If error, jumptoexit=1
*
* Example:
*
* Modules_called: dt_date
*
* Maintenance_History:
*-------------------------------------------------------------------------------------------------------------*
*  Date:      |   Who:        |  Description:                                                                 *
*-------------------------------------------------------------------------------------------------------------*
* 12/14/2011  | Michael Gilman   | Initial creation.                                                          *
* 04/15/2012  | Michael Gilman   | Fixed bug when setting dt_prcs_data for Daily and Weekly programs.         *
*             |                  | Now use mmyydd6 to format it.                                              *
* 04/26/2012  | Michael Gilman   | Added handling Quarterly, Yearly, Other date intervals.                    *
*             |                  |                                                                            *
*             |                  | Format for dt_prcs_data for Daily and Weekly now yymmdd6.                  *
* 07/12/2012  | Michael Gilman   | Changed report_date to emaildate.                                          *
* 07/12/2012  | Michael Gilman   | Added new macro value for program frequency: offset.                       *
* 07/26/2012  | Michael Gilman   | Changed offset value for Daily from -2 to -1.                              *
* 07/30/2012  | Michael Gilman   | Set macro variable start_date_month using z2. format.                      *
* 08/01/2012  | Michael Gilman   | Now check for valid input process date (dt_prcs).                          *
* 08/23/2012  | Michael Gilman   | Now set global macro variable rundate.                                     *
* 09/11/2012  | Michael Gilman   | Fixed bug. start_date and end_date offset were reversed.                   *
* 09/11/2012  | Michael Gilman   | Now use %squote macro to single quote values.                              *
*-------------------------------------------------------------------------------------------------------------*
* HeaderEnd:                                                                                                  *
**************************************************************************************************************/

%macro create_date_parameters;
%put Start macro create_date_parameters;

 %local offset current_dt_prcs;

 %let rundate=%sysfunc(putn(%sysfunc(today()),mmddyy10.));

 /* If dt_prcs is missing, set it to today's date. */

 %if &dt_prcs=%str() %then %let dt_prcs=%sysfunc(putn(%sysfunc(today()),mmddyy10.));

 /* Save dt_prcs in its mm/dd/yyyy form */

 %let current_dt_prcs=&dt_prcs;

 /* Convert dt_prcs to a sas date value */

 %let dt_prcs=%sysfunc(inputn(&dt_prcs,mmddyy10.));

 %if %sysfunc(notdigit(&dt_prcs)) %then
 %do; /* Invalid dt_prcs value */

    %let errormsg1=Invalid value &current_dt_prcs for input process date (dt_prcs);

    %put ERROR: &errormsg1;

    %let jumptoexit=1;

    %goto ERREXIT;

 %end;/* Invalid dt_prcs value */

 /* Set dt_prcs_sas to the process date with the form 'ddMMMyyyy'd */

 %let dt_prcs_sas=%unquote(%str(%')%sysfunc(putn(&dt_prcs,date9.))%str(%')d);

 /* Set dt_sas to the process date as a sas date value. This is same value as dt_prcs. */

 %let dt_sas=%sysfunc(int(&dt_prcs_sas));

 /* We now want to set 4 macro variables that are based on the value of PgmFreq and  */
 /* are used later in the program for the calculation of date values.                */

 %if %upcase(&pgmfreq)=DAILY %then
 %do;

    %let interval=day;

    %let offset=-1;

    %let format=mmddyy6;

    %let emaildate_format=mmddyy10;

 %end;
 %else
 %if %upcase(&pgmfreq)=WEEKLY %then
 %do;

    %let interval=day;

    %let offset=-1;

    %let format=mmddyy6;

    %let emaildate_format=mmddyy10;

 %end;
 %else
 %if %upcase(&pgmfreq)=MONTHLY %then
 %do;

    %let interval=month;

    %let offset=-1;

    %let format=mmyyn4;

    %let emaildate_format=mmyys7;

 %end;
 %else
 %if %upcase(&pgmfreq)=QUARTERLY %then
 %do;

    %let interval=qtr;

    %let offset=-1;

    %let format=mmyyn4;

    %let emaildate_format=mmddyy10;

 %end;
 %else
 %if %upcase(&pgmfreq)=YEARLY %then
 %do;

    %let interval=year;

    %let offset=-1;

    %let format=mmyyn4;

    %let emaildate_format=mmddyy10;

 %end;
 %else
 %if %upcase(&pgmfreq)=OTHER %then
 %do;

    %let interval=day;

    %let offset=-1;

    %let format=mmddyy6;

    %let emaildate_format=mmddyy10;

 %end;

 %let start_date=%sysfunc(intnx(&interval,&dt_sas,-1));

 %let end_date=%sysfunc(intnx(&interval,&dt_sas,0));

 /* Set dt_prcs_data which is primarily used as a component of the FilePrefix.  */
 /* FilePrefix is used as the prefix for all output data sets and file names.   */
 /* Note that the returned value has the form mmyy when pgmfreq is Monthly, and */
 /* mmddyy for all other pgmfreq values.                                        */

 %let dt_prcs_data=%dt_date(interval=&interval,format=&format,offset=&offset,quote=n);

 /* emaildate is used as the printed date in emails */

 %let emaildate=%dt_date(interval=&interval,format=&emaildate_format,offset=&offset,quote=n);

 /* Set various date macro variables that may be useful for jobs */

 %let start_date_year=%sysfunc(year(&start_date));

 %let start_date_month=%sysfunc(putn(%sysfunc(month(&start_date)),z2.));

 %let start_date_day=%sysfunc(day(&start_date));

 %let start_date_weekday=%sysfunc(weekday(&start_date));

 %let start_date_yearmonth=&start_date_year&start_date_month;


 %let end_date_year=%sysfunc(year(&end_date));

 %let end_date_month=%sysfunc(putn(%sysfunc(month(&end_date)),z2.));

 %let end_date_day=%sysfunc(day(&end_date));

 %let end_date_weekday=%sysfunc(weekday(&end_date));

 %let end_date_yearmonth=&end_date_year&end_date_month;

 %let yr_year=%squote(Yr &start_date_year);
 %let date30=%squote(%sysfunc(putn(&start_date-30,mmddyy10)));
 %let date31=%squote(%sysfunc(putn(&start_date-31,mmddyy10)));
 %let date60=%squote(%sysfunc(putn(&start_date-60,mmddyy10)));
 %let date61=%squote(%sysfunc(putn(&start_date-61,mmddyy10)));
 %let date90=%squote(%sysfunc(putn(&start_date-90,mmddyy10)));
 %let date91=%squote(%sysfunc(putn(&start_date-91,mmddyy10)));
 %let date120=%squote(%sysfunc(putn(&start_date-120,mmddyy10)));
 %let date121=%squote(%sysfunc(putn(&start_date-121,mmddyy10)));

%ERREXIT:

%put End macro create_date_parameters;
%mend create_date_parameters;
