/**************************************************************************************************************
* Macro_Name:   time_hours_minutes_secs_format
*
* Purpose: Format a sas time value to hours, minutes, seconds.
*
* Usage: %time_hours_minutes_secs_format(time);
*
* Input_parameters: time
*                    sas time value
*
* Outputs:  None.
*
* Returns:  Formatted time.
*
* Example:   %let time=%sysfunc(time());
*            %let formattedTime=%time_hours_minutes_secs_format(&time);
*            %put &formattedTime;
*             Result: 10 hours, 57 minutes, 28 seconds
*
* Modules_called: None
*
* Maintenance_History:
*-------------------------------------------------------------------------------------------------------------*
*  Date:      |   Who:        |  Description:                                                                 *
*-------------------------------------------------------------------------------------------------------------*
* 12/14/2011  | Michael Gilman   | Initial creation.                                                          *
* 07/01/2012  | Michael Gilman   | Made macro variable string a local variable.                               *
*-------------------------------------------------------------------------------------------------------------*
* HeaderEnd:                                                                                                  *
**************************************************************************************************************/

%macro time_hours_minutes_secs_format(time);

 %local hours minutes seconds
        hoursc minutesc secondsc
        string
 ;

 %if %scan(%quote(&time),2,%str(:))=%str() %then %let time=%sysfunc(putn(&time,time.));

 %let hours=%scan(&time,1,%str(:));

 %let hours=%sysfunc(inputn(&hours,best.));

 %let minutes=%scan(&time,2,%str(:));

 %let minutes=%sysfunc(inputn(&minutes,best.));

 %let seconds=%scan(&time,3,%str(:));

 %let seconds=%sysfunc(inputn(&seconds,best.));

 %if %sysevalf(&hours>0) %then
 %do;

    %if %sysevalf(&hours=1) %then %let hoursc=hour;
    %else %let hoursc=hours;

    %if %sysevalf(&minutes=1) %then %let minutesc=minute;
    %else %let minutesc=minutes;

    %let string=&hours &hoursc, &minutes &minutesc, &seconds seconds;

 %end;
 %else
 %if %sysevalf(&minutes>0) %then
 %do;

    %if %sysevalf(&minutes=1) %then %let minutesc=minute;
    %else %let minutesc=minutes;

    %let string=&minutes &minutesc, &seconds seconds;

 %end;
 %else
 %do;

    %let string=&seconds seconds;

 %end;

 &string

%mend time_hours_minutes_secs_format;
