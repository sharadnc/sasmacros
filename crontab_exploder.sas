/**************************************************************************************************************
* Macro_Name:   crontab_exploder
*
* Purpose: This macro imports the cron file to a sas dataset.
*          Translate a Unix crontab file into a chronological listing of       
*          actual date/times, given as input a start and end datetime.         
*                                                                              
*          Each line of a crontab file has 5 date/time fields followed by the  
*          actual command to execute. The date/time fields have a very terse,  
*          albeit complete, definition of the date/time to run a command.      
*                                                                              
*         The time and date fields are:                                        
*                                                                              
*                    field          allowed values                             
*                    -----          --------------                             
*                    minute         0-59                                       
*                    hour           0-23                                       
*                    day of month   0-31                                       
*                    month          0-12 (or names)                            
*                    day of week    0-7 (0 or 7 is Sun, or use names)          
*                                                                              
*         A field  may  be an asterisk (*), which always stands for all values 
*         for that date/time field.                                            
*                                                                              
*         Example crontab commands:                                            
*                                                                              
*          Run five minutes after midnight, every day                          
*            5 0 * * *  command                                                
*          Run at 2:15pm on the first of every month                           
*            15 14 1 * *                                                       
*          Run at 10 pm on weekdays                                            
*            0 22 * * 1-5                                                      
*                                                                              
*         This program converts the rather obscure date/time fields to actual  
*         date/time values using as input a start and end datetime.            
*
* Usage: %crontab_exploder(startDatetime=,endDatetime=,
*                 infile=/u01/app/scheduler/crontab.current,
*                 outfile=/u04/data/cig_ebi/&env/dmg/dump/crontab.current,
*                 dataset=crontable
*
* Input_parameters: startDatetime                                                       
*            The start datetime. Example: 10apr2011:00:00:00                  
*         endDatetime                                                         
*            The end datetime.   Example: 16apr2011:23:59:00                  
*         infile                                                              
*            Name of the the crontab file to translate.                       
*         outfile                                                             
*            Name of the translated file.                                     
*         dataset                                                             
*            Name of the sas data set that also contains the translated       
*            result.                                                          
*
* Outputs:  outfile                                                           
*            Name of the translated file.                                    
*          dataset                                                           
*            Name of the sas data set that also contains the translated      
*            result.                                                         
* Returns:  None
*
* Example:
*
* Modules_called: %lock_on_member
*                 %lock_off_member
*
* Maintenance_History:
*-------------------------------------------------------------------------------------------------------------*
*  Date:      |   Who:        |  Description:                                                                 *
*-------------------------------------------------------------------------------------------------------------*
* 03/12/2012  | Sharad| Initial creation.                                                             *
*-------------------------------------------------------------------------------------------------------------*
* HeaderEnd:                                                                                                  *
**************************************************************************************************************/

%macro crontab_exploder(startDatetime=,endDatetime=,infile=,outfile=,dataset=);
	
data &dataset;

retain startDateTime "&startDateTime"dt  endDateTime "&endDateTime"dt;

retain maxLenCommand;

length c1-c5 $80 command $800;

length cc1 cc2 startc endc c char daytimeString weekdays months monthdays hours minutes $200 timetype $20;

infile "&infile" truncover lrecl=1000 end=_e;

input c1-c5 command $800.;

if c1=:'#' then delete;

if c1='*' then everyMinute=1;
else
do;

   timetype='minute';

   char=c1;

   link GetDayTimeString;

   minutes=daytimeString;

end;

if c2='*' then everyHour=1;
else
do;

   timetype='hour';

   char=c2;

   link GetDayTimeString;

   hours=daytimeString;

end;


if c3='*' then everyDayOfMonth=1;
else
do;

   timetype='monthday';

   char=c3;

   link GetDayTimeString;

   monthdays=daytimeString;

end;

if c4='*' then everyMonth=1;
else
do;

   timetype='month';

   char=c4;

   link GetDayTimeString;

   months=daytimeString;


end;

if c5='*' then everyDayOfWeek=1;
else
do;

   timetype='weekday';

   char=c5;

   link GetDayTimeString;

   weekdays=daytimeString;

end;

currentYear=year(today());

do datetime=startDateTime to endDateTime by 60;

   minute=.;
   hour=.;
   month=.;
   day=.;

   date=datepart(datetime);

   currentMinute=minute(datetime);
   currentMinutec=left(put(currentMinute,best.));

   currentHour=hour(datetime);
   currentHourc=left(put(currentHour,best.));

   currentDay=day(date);
   currentDayc=left(put(currentDay,best.));

   currentWeekDay=weekday(date);
   currentWeekDayc=left(put(currentWeekDay,best.));

   currentMonth=month(date);
   currentMonthc=left(put(currentMonth,best.));


   if everyMinute then minute=currentMinute;
   else
   if indexw(minutes,currentMinutec) then minute=currentMinute;

   if everyHour then hour=currentHour;
   else
   if indexw(hours,currentHourc) then hour=currentHour;

   if everyMonth then month=currentMonth;
   else
   if indexw(months,currentMonthc) then month=currentMonth;

   if everyDayOfMonth and everyDayOfWeek then day=currentDay;

   if everyDayOfMonth and not everyDayOfWeek then
      if indexw(weekdays,currentWeekDayc) then day=currentWeekDay;

   if not everyDayOfMonth and everyDayOfWeek then
      if indexw(monthdays,currentDayc) then day=currentDay;

   if not everyDayOfMonth and not everyDayOfWeek then
   do;

      if indexw(weekdays,currentWeekDayc) then day=currentWeekDay;

      if indexw(monthdays,currentDayc) then day=currentDay;

   end;

   if minute=. or hour=. or month=. or day=. then continue;

   outDate=mdy(month,currentDay,currentYear);

   outDatetime=dhms(outDate,hour,minute,0);

   outDatec=put(outDate,yymmdd10.);

   hourc=put(hour,z2.);
   minutec=put(minute,z2.);

   outTimec=hourc!!':'!!minutec;

   if length(command)>maxLenCommand then maxLenCommand=length(command);

   output;

   if _e then call symputx('maxLenCommand',maxLenCommand);

end;

keep outDatetime outDatec outTimec command;

format outDatetime datetime.;

return;


GetDayTimeString:

 daytimeString='';

 if input(char,??best.) ne . then
 do;

    n=input(char,best.);

    link WeekdayAdjust;

    c=left(put(n,best.));

    daytimeString=c;

    return;

 end;

 i=0;

 more=1;

 do while(more);

    i+1;

    c=scan(char,i,',');

    if c='' then return;

    if indexc(c,'/') then
    do;

       link StepValues;

    end;
    else
    if indexc(c,'-') then
    do;

       n1=input(scan(c,1,'-'),best.);
       n2=input(scan(c,2,'-'),best.);

       do j=n1 to n2;

          n=j;

          link WeekdayAdjust;

          c=left(put(n,best.));

          daytimeString=trim(daytimeString)!!' '!!c;

       end;

    end;
    else
    if lowcase(c) in ('sun' 'mon' 'tue' 'wed' 'thu' 'fri' 'sat') then
    do;

       c=lowcase(c);

       if c='sun' then n=0;
       if c='mon' then n=1;
       if c='tue' then n=2;
       if c='wed' then n=3;
       if c='thu' then n=4;
       if c='fri' then n=5;
       if c='sat' then n=6;

       link WeekdayAdjust;

       c=left(put(n,best.));

       daytimeString=trim(daytimeString)!!' '!!c;

    end;
    else
    if lowcase(c) in ('jan' 'feb' 'mar' 'apr' 'may' 'jun' 'jul' 'aug' 'sep' 'oct' 'nov' 'dec') then
    do;

       c=lowcase(c);

       if c='jan' then n=1;
       if c='feb' then n=2;
       if c='mar' then n=3;
       if c='apr' then n=4;
       if c='may' then n=5;
       if c='jun' then n=6;
       if c='jul' then n=7;
       if c='aug' then n=8;
       if c='sep' then n=9;
       if c='oct' then n=10;
       if c='nov' then n=11;
       if c='dec' then n=12;

       link WeekdayAdjust;

       c=left(put(n,best.));

       daytimeString=trim(daytimeString)!!' '!!c;

    end;
    else
    do;

       n=input(c,best.);

       link WeekdayAdjust;

       c=left(put(n,best.));

       daytimeString=trim(daytimeString)!!' '!!c;

    end;

 end;

return;  /* GetDayTimeString */


WeekdayAdjust:

 if timetype='weekday' then
 do;

    n+1;

    if n=8 then n=1;

 end;

return;  /* WeekdayAdjust */


StepValues:

 daytimeString='';

 cc1=scan(c,1,'/');
 cc2=scan(c,2,'/');

 ccn2=input(cc2,best.);

 if indexc(cc1,'-') then
 do;

    startc=scan(cc1,1,'-');
    endc=scan(cc1,2,'-');

    start=input(startc,best.);
    end=input(endc,best.);

 end;


 if cc1='*' then
 do;

    if timetype='minute' then
    do;

       start=1;

       end=59;

    end;

    if timetype='hour' then
    do;

       start=0;

       end=24;

    end;

    if timetype='month' then
    do;

       start=1;

       end=12;

    end;

    if timetype='monthday' then
    do;

       start=1;

       end=31;

    end;

    if timetype='weekday' then
    do;

       start=0;

       end=6;

    end;

 end;

 do n=start to end by ccn2;

    link WeekdayAdjust;

    c=left(put(n,best.));

    daytimeString=trim(daytimeString)!!' '!!c;

 end;

return;  /* StepValues */

run;


proc sort;
by outDatetime;

data _null_;

 file "&outfile" lrecl=1000;

 set &dataset;

 put outDatec +(-1) ':' outTimec +(-1) ':00' +1 command;

run;


data &dataset(compress=yes);

 length Program $80 outDateTime 8 outDatec $10 outTimec $8 Day $3 Command $&maxLenCommand;

 set &dataset;

 Day=left(put(datepart(outDateTime),weekdate3.));

 pos=find(command,'.ksh');

 if pos then
 do;

    program=scan(substr(command,1,pos-1),-1);

 end;

 rename outDateTime=DateTime outDatec=Date  outTimec=Time;

 drop pos;

run;

proc sort;
by program;
run;

%mend crontab_exploder;

/*
%let env=uat;

%crontab_exploder(startDatetime=01jun2012:00:00:00,
                 endDatetime=01jul2012:00:00:00,
                 infile=/u01/app/scheduler/crontab.current,
                 outfile=/u04/data/cig_ebi/&env/dmg/dump/crontab.current,
                 dataset=crontable
                 );
*/                 