/**************************************************************************************************************
* Macro_Name:   program_end_step
*
* Purpose: This macro sets the step that the program should start at next time it executes.
*          It does this by updating rstats.program_restart_step.
*
* Usage: %program_end_step(PgmName);
*
* Input_parameters: PgmName.
*                    Program name
*                   step_count (global)
*                    Step number of last successfully completed step
*
* Outputs:  rstats.program_restart_step (updated)
*
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
* 03/12/2012  | Michael Gilman| Initial creation.                                                             *
* 05/05/2012  | Michael Gilman| Renamed work.program_restart_step to work.program_restart_step_temp.          *
* 05/11/2012  | Michael Gilman| Added env variable to rstats.program_restart_step which required minor change *
*             |               | to update rstats.program_restart_step.                                        *
* 08/01/2012  | Michael Gilman| Changed length of env variable from $4 to $8.                                 *
* 09/02/2012  | Michael Gilman| Changed length of env variable from $8 to $4.                                 *
*-------------------------------------------------------------------------------------------------------------*
* HeaderEnd:                                                                                                  *
**************************************************************************************************************/

%macro program_end_step(pgmName);
%put Start macro program_end_step;

%local i j more temp datasets delete_datasets rc dsn found;

%if &jumptoexit %then
%do;

   %if &end_project_specifics_error=1 %then %let step=-1;
   %else
   %if &step_count<=0 %then %let step=1;
   %else %let step=%eval(&step_count+1);

%end;
%else
%do;

   %let step=1;

%end;

%lock_on_member(rstats.program_restart_step);

proc sql;
 delete from rstats.program_restart_step
 where env="&env" and pgmName="&pgmName" and dt_prcs_data="&dt_prcs_data"
 ;
quit;

data program_restart_step_temp;
 length env $4 PgmName $80 restart_step 4 dt_prcs_data $6;
 env="&env";
 pgmName="&pgmName";
 restart_step=&step;
 dt_prcs_data="&dt_prcs_data";
run;

proc append base=rstats.program_restart_step data=program_restart_step_temp force;
run;

%lock_off_member(rstats.program_restart_step);

%put End macro program_end_step;
%mend program_end_step;
