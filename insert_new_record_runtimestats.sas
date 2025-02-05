/**************************************************************************************************************
* Macro_Name:   insert_new_record_runtimestats
*
* Purpose: This macro is used to insert a record into rstats.runtimestats. It is invoked when a job starts and
*          called by %add_project_specifics. When a job ends this record is updated with the job info by the
*          invocation of %update_runtimestats which is called by %end_project_specifics.
*
* Usage: %insert_new_record_runtimestats;
*
* Input_parameters: Various global macro variables.
*
* Outputs:  None.
*
* Returns:  If error, jumptoexit=1
*
* Example:
*
* Modules_called: %lock_on_member
*                 %lock_off_member
*                 %chkerr
*
* Maintenance_History:
*-------------------------------------------------------------------------------------------------------------*
*  Date:      |   Who:        |  Description:                                                                 *
*-------------------------------------------------------------------------------------------------------------*
* 12/14/2011  | Sharad           | Initial creation.                                                          *
* 12/14/2011  | Michael Gilman   | Initial creation.                                                          *
* 04/26/2012  | Michael Gilman   | Missing a semi-colon from the first proc sql.                              *
*             |                  |                                                                            *
*             |                  | Now unlock runtimestats and next_runtimestats only if previously           *
*             |                  | successfully locked.                                                       *
*             |                  |                                                                            *
*             |                  | Moved the locks to top of macro.                                           *
*             |                  |                                                                            *
*             |                  | Changed: id=input("&nextid",10.);                                          *
*             |                  | To:      id=&nextid;                                                       *
*             |                  |                                                                            *
* 04/27/2012  | Michael Gilman   | Now save current jumptoexit value at top of macro, then set it to 0. At end*
*             |                  | end of macro, reset it.                                                    *
* 10/20/2012  | Michael Gilman   | Added new variable to runtimestats:  Email_Subject                         *
* 10/22/2012  | Michael Gilman   | Added new variable to runtimestats:  dt_prcs_data                          *
*-------------------------------------------------------------------------------------------------------------*
* HeaderEnd:                                                                                                  *
**************************************************************************************************************/

%macro insert_new_record_runtimestats;
%put Start macro insert_new_record_runtimestats;

 %local current_jumptoexit;

 %let current_jumptoexit=&jumptoexit;

 %let jumptoexit=0;

 /* Each job is assigned a unique id value. We get the next available value here. */

 %lock_on_member(RSTATS.RUNTIMESTATS);
 %if &jumptoexit %then %goto EXIT;

 %lock_on_member(RSTATS.next_RUNTIMESTATS);
 %if &jumptoexit %then %goto EXIT2;

 proc sql noprint;
 select id into : nextid
 from RSTATS.next_RUNTIMESTATS
 ;
 quit;

 %let nextid=&nextid;

 %if &program_step=%str() %then %let program_step=0;

 /* Create a temporary sas data set with one record which initializes the RuntimeStats variables */

 data RuntimeStats;
 length PgmName Status $100 PeopleNotified $ 400 AttachRowCount $4000
        ErrorFound $1000 unix_prcs_id $20 program_restart_step 8 Email_Subject $200
        dt_prcs_data $10
 ;

 id=&nextid;
 userid_exec="&userid";
 unix_prcs_id="&sysjobid";
 PgmName="&PgmName";
 Status="RUNNING";
 PeopleNotified="";
 AttachRowCount="";
 Rundate=today();
 StartTime=input("&StartTime.",datetime23.);
 EndTime=.;
 ExecTime_min=.;
 ErrorFound="";
 program_restart_step=&program_step;
 dt_prcs_data="&dt_prcs_data";

 format id z10. Rundate mmddyy10. StartTime datetime23. EndTime datetime23. ExecTime_min;

 run;

 /* Insert the record into rstats.runtimestats */

 proc sql feedback;
   insert into rstats.runtimestats
   select id, userid_exec, unix_prcs_id, PgmName,put(&dt_prcs,mmddyy10.) as dt_prcs, "%superq(logfile)" as Log, Status, PeopleNotified, AttachRowCount,
          Rundate, StartTime, EndTime, ExecTime_min,ErrorFound, program_restart_step, Email_Subject, dt_prcs_data
   from RuntimeStats A;
 quit;

 %chkerr(msg1=Error inserting a record into RSTATS.RUNTIMESTATS,msg2=%superq(syserrortext));
 %if &jumptoexit %then %goto EXIT;

  /* Set next ID for RUNTIMESTATS */

  proc sql feedback;
 /* Set next ID for RUNTIMESTATS */
 update RSTATS.next_RUNTIMESTATS
 set id = id + 1;
 quit;

 %chkerr(msg1=Error updating RSTATS.next_RUNTIMESTATS,msg2=%superq(syserrortext));

 %lock_off_member(RSTATS.next_RUNTIMESTATS);

%EXIT2:

 %lock_off_member(RSTATS.RUNTIMESTATS);

%EXIT:

 %if &jumptoexit=0 %then %let jumptoexit=&current_jumptoexit;

%put End macro insert_new_record_runtimestats;
%mend insert_new_record_runtimestats;
