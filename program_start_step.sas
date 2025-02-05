/**************************************************************************************************************
* Macro_Name:   program_start_step
*
* Purpose: This macro retrieves the step that the program should start at.
*
* Usage: %program_start_step(PgmName);
*
* Input_parameters: PgmName
*                    Program name
*
* Outputs:  None
*
* Returns:  gotoStep (global, e.g. STEP02)
*           step_count
*            Step number of step to execute minus 1.
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
* 04/23/2012  | Michael Gilman| Now allow step numbers to be 3 digits long (999).                             *
* 05/05/2012  | Michael Gilman| Added logic to handle new macro variable program_start_step.                  *
*                                                                                                             *
* 05/11/2012  | Michael Gilman| Added env variable to rstats.program_restart_step which required minor change *
*             |               | to access rstats.program_restart_step.                                        *
* 06/20/2011  | Michael Gilman| Removed check for &program_start_step. This is now done in %check_restart_step*
* 11/28/2012  | Michael Gilman| Now check if restart_step=9999. If so, set goto=StopProcessingMacro.          *
*-------------------------------------------------------------------------------------------------------------*
* HeaderEnd:                                                                                                  *
**************************************************************************************************************/

%macro program_start_step(pgmName);
%put Start macro program_start_step;

%local _pgmName use_format;

%if %sysfunc(exist(rstats.program_restart_step))=0 %then
%do;

   data rstats.program_restart_step;
    length PgmName $80 restart_step 4 dt_prcs_data $6 env $4;
    stop;
   run;

%end;

%lock_on_member(rstats.program_restart_step);
%if &jumptoexit %then %goto EXIT;

%let _pgmName=;

%let program_step=;

proc sql noprint;
 select pgmName, restart_step into : _pgmName,  : program_step
 from rstats.program_restart_step
 where pgmName="&pgmName" and dt_prcs_data="&dt_prcs_data" and env="&env"
 ;
quit;

%lock_off_member(rstats.program_restart_step);

%if &program_step=%str() %then %let program_step=1;

%NEXT:

%if &program_step=-1 or &program_step=9999 %then %let gotoStep=StopProcessingMacro;
%else
%do;

   %let step_count=%eval(&program_step-1);

   %if &program_step<=99 %then %let use_format=z2.;
   %else %let use_format=z3.;

   %let program_step=%sysfunc(putn(&program_step,&use_format));

   %let gotoStep=STEP&program_step;

%end;

%put;
%put NOTE: Starting program from &gotoStep;
%put;

%EXIT:

%put End macro program_start_step;
%mend program_start_step;
