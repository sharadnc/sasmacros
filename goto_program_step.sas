/**************************************************************************************************************
* Macro_Name:   goto_program_step
*
* Purpose: This macro allows the programmer to override which step a program should start at.
*          Note that this should be used only when a program is set up to run in restart mode.
*          IMPORTANT: The macro must be invoked just prior to the %goto &gotostep statement in the program.
*
*          Important exception for the input parameter:
*          Normally, the input parameter is an integer. However, there may be occassions when you
*          want to jump to processing at the %end_project_specifics macro. To do this, you would invoke
*          this macro as: %goto_program_step(StopProcessingMacro);
*
* Usage: %goto_program_step(step);
*
* Input_parameters: step
*                    Step number in the program to goto (though see exception above).
*
* Outputs:
*
* Returns:  step_count (global)
*            Internal macro variable used to keep track of the steps
*           gotostep (global)
*            Step label to go to
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
* 03/25/2012  | Michael Gilman| Initial creation.                                                             *
* 04/23/2012  | Michael Gilman| Now allow step numbers to be 3 digits long (999).                             *
* 06/20/2012  | Michael Gilman| Now when check if step=StopProcessing, set step_count=998 as we can't know    *                                        *
*             |               | what the prior successful step number is.                                     *                                        *
*-------------------------------------------------------------------------------------------------------------*
* HeaderEnd:                                                                                                  *
**************************************************************************************************************/

%macro goto_program_step(step);
%put Start macro goto_program_step;

 %local n len use_format;

 %if %lowcase(%str(&step))=stopprocessingmacro %then
 %do;

    %let step_count=998;

    %let gotostep=StopProcessingMacro;

	  %goto EXIT;

 %end;

 %let n=%sysfunc(inputn(&step,best.));

 %if %str(&n)=. %then
 %do;

    %let jumptoexit=1;

  	%let errormsg1=Step parameter is not an integer;

    %goto EXIT;

 %end;

 %if &n<1 or &n>999 %then
 %do;

    %let jumptoexit=1;

	  %let errormsg1=Step parameter must be between 1 and 999.;

    %goto EXIT;

 %end;

 %if &n<=99 %then %let use_format=z2.;
 %else %let use_format=z3.;

 %let n=%sysfunc(putn(&step,&use_format.));

 %let step_count=%eval(&n-1);

 %let gotostep=STEP&n;

 %put gotostep=&gotostep;

%EXIT:

%put End macro goto_program_step;
%mend goto_program_step;