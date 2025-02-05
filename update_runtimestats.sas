/**************************************************************************************************************
* Macro_Name:   update_runtimestats
*
* Purpose: This macro is used to update the runtimestats dataset with the job completion attributes.
*
* Usage: %update_runtimestats;
*
* Input_parameters: jumptoexit (global)
*
* Outputs:  None.
*
* Returns:  jumptoexit
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
* 12/14/2011  | Sharad           | Initial creation.                                                          *
* 12/14/2011  | Michael Gilman   | Initial creation.                                                          *
* 06/08/2011  | Michael Gilman   | Changed &eto to &email_notify for PeopleNotified field.                    *
* 08/08/2012  | Michael Gilman   | Removed unused label section EndStep.                                      *
* 08/28/2012  | Michael Gilman   | Fixed bug. old_jumptoexit was incorrectly set. This caused runtimestats    *
*             |                  | data set to always indicate SUCCESS.                                       *
* 10/11/2012  | Michael Gilman   | Fixed bug: old_jumtoexit macro var was being declared as local. This       *
*             |                  | caused it to be incorrectly as it is set in end_project_specifics.         *
* 10/20/2012  | Michael Gilman   | Added new variable to update to runtimestats:  Email_Subject               *
* 10/22/2012  | Michael Gilman   | Added new variable to update to runtimestats:  dt_prcs_data                *
*-------------------------------------------------------------------------------------------------------------*
* HeaderEnd:                                                                                                  *
**************************************************************************************************************/

%macro update_runtimestats;
%put Start macro update_runtimestats;

 %local errorfound;

 %lock_on_member(RSTATS.RUNTIMESTATS); /* get a lock on the dataset */

 %if &jumptoexit %then %goto EXIT;

 %if %superq(_ERROR) ne %str() %then %let errorfound=%sysfunc(quote(&_ERROR));

 proc sql;
  update RSTATS.RUNTIMESTATS
  set %if &old_jumptoexit eq 0 %then %do; Status="SUCCESS" %end; %else %do; Status="WARN" %end;
     ,PeopleNotified="&notify_email.^&ebcc."
     ,%if &jumptoexit eq 0 %then %do; AttachRowCount="&eattachtxt." %end; %else %do; AttachRowCount="" %end;
       ,EndTime=input("%sysfunc(datetime(),datetime23.)",datetime23.)
       ,ExecTime_min=(input("%sysfunc(datetime(),datetime23.)",datetime23.) - StartTime)/60
       ,%if &jumptoexit eq 0 %then %do; ErrorFound=" " %end; %else %do; ErrorFound=&errorfound %end;
       ,Email_Subject="&Email_Subject", dt_prcs_data="&dt_prcs_data"
  where id=input("&nextid",10.)
  ;
 quit;

 proc sort data=RSTATS.RUNTIMESTATS;
  by descending starttime;
 run;

 %chkerr(msg1=Error while updating RSTATS.RUNTIMESTATS,msg2=%superq(syserrortext));

 %lock_off_member(RSTATS.RUNTIMESTATS); /* lock off the dataset */

%EXIT:

%put End macro update_runtimestats;
%mend update_runtimestats;