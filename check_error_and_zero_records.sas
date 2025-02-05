/**************************************************************************************************************
* Macro_Name:   check_error_and_zero_records
*
* Purpose: This macro checks if the last step that creates a data set is in error and also
*          checks if the data set has zero records. It also increments the step_count variable
*          when the step input parameter is not missing.
*
* Usage: %check_error_and_zero_records(step=,dsn=,errCaptur=,msg1=,msg2=,msg3=,msg4=,msg5=);
*
* Input_parameters: step
*                    Optional. A descriptive name of the last sas step executed
*                   dsn
*                    The name of the sas data set to check. Default is &SYSLAST
*                    errCaptur
*                     The sas return code from the previous sas step. If not passed in errCaptur:
*                       If &sqlxrc is greater than 4, it is used
*                       else
*                       if &sqlrc is greater than 4, it is used
*                       else &syserr is used
*                   msg1-msg5
*                    Error messages to set if in error
*
* Outputs:  None
*
* Returns:  If error, jumptoexit=1.
*           If &step is not missing, &step_count is incremented.
*
* Example:
*
* Modules_called: %records_in_dataset
*
* Maintenance_History:
*-------------------------------------------------------------------------------------------------------------*
*  Date:      |   Who:           |  Description:                                                              *
*-------------------------------------------------------------------------------------------------------------*
* 12/14/2011  | Sharad           | Initial creation.                                                          *
* 12/14/2011  | Michael Gilman   | Initial creation.                                                          *
* 05/05/2011  | Michael Gilman   | Removed error message: "Probable cause: Syntax error".                     *
* 06/25/2011  | Michael Gilman   | Removed invocation of %chk_outfile_length as now being called from         *
*             |                  | check_restart_step.                                                        *
* 10/18/2012  | Michael Gilman   | Fixed bug: Errors were not detected correctly in the case where a          *
*             |                  | successful proc sql was followed by an unsuccessful data step.             *
*-------------------------------------------------------------------------------------------------------------*
* HeaderEnd:                                                                                                  *
**************************************************************************************************************/

%macro check_error_and_zero_records(step=,dsn=,errCaptur=,msg1=,msg2=,msg3=,msg4=,msg5=);
%put Start macro check_error_and_zero_records;

 %local i temp sqlxrc_n sqlrc_n syserr_n;

 %if &errCaptur=%str() %then
 %do; /* errCaptur not passed in, so set it */

    %let sqlxrc_n=0;
    %let sqlrc_n=0;
    %let syserr_n=0;

    %if %symexist(sqlxrc) %then %let sqlxrc_n=&sqlxrc;

    %if %symexist(sqlrc) %then %let sqlrc_n=&sqlrc;

    %if %symexist(syserr) %then %let syserr_n=&syserr;

    %if &sqlxrc_n>4 %then %let errCaptur=&sqlxrc_n;
    %else
    %if &sqlrc_n>4 %then %let errCaptur=&sqlrc_n;
    %else %let errCaptur=&syserr_n;

 %end;/* errCaptur not passed in, so set it */

 /* If dsn not passed in use &syslast */

 %if &dsn=%str() %then %let dsn=&syslast;

 %if &dsn=_NULL_ %then
 %do;

    %let errormsg1=Creation of data set failed.;
    %let errormsg2=&syserrortext;

    %let jumptoexit=1;

    %goto EXIT;

 %end;

 %if %sysfunc(exist(&dsn))=0 %then
 %do;

    %let errormsg1=&dsn does not exist.;

    %let jumptoexit=1;

    %goto EXIT;

 %end;

 %if &errCaptur>4 %then
 %do; /* Last step has error */

    %if %superq(msg1)=%str() %then %let errormsg1=Create &dsn failed and exited with &errCaptur;
    %else %let errormsg1=&msg1;

    %if %superq(msg2)=%str() %then %let errormsg2=&syserrortext;
    %else %let errormsg2=&msg2;

    %do i=3 %to 5;

       %let temp=&&msg&i;

       %if %superq(temp) ne %str() %then %let errormsg&i=&temp;

    %end;

    %let jumptoexit=1;

    %goto EXIT;

 %end;/* Last step has error */

 %if %records_in_dataset(&dsn)<=0 %then
 %do; /* Data set has zero records */

    %if &jumptoexit %then %goto EXIT;

    %if %superq(msg2)=%str() %then %let errormsg1=0 records in &dsn;
    %else %let errormsg1=&msg2;

    %do i=3 %to 5;

       %let temp=&&msg&i;

       %if %superq(temp) ne %str() %then %let errormsg%eval(&i-1)=&temp;

    %end;

    %let jumptoexit=1;

 %end;/* Data set has zero records */

%EXIT:

 %let syslast=;

 /* It is assumed that each STEP is followed by an invocation of this macro or the &chkerr macro. */
 /* This allows us to keep track of the step count by incrementing the step_count variable here.  */
 /* Note that this is only done when the step input parameter is not missing.                     */

 %if %superq(step) ne %str() %then
 %do; /* Increment the step_count variable */

    %put;

    %if &jumptoexit=0 %then
	  %do; /* No error */

       %let step_count=%eval(&step_count+1);

       %put NOTE: Step &step_count &step completed successfully.;

    %end;/* No error */
    %else
    %do; /* Error */

       %put ERROR: Program &PgmName has an error in Step %eval(&step_count+1) &step..;

       %do i=1 %to 5;

          %let temp=&&errormsg&i;

          %if %superq(temp) ne %str() %then %put ERROR: &temp;

       %end;

    %end;/* Error */

    %put;

 %end;/* Increment the step_count variable */

 %let sqlrc=0;

 %let sqlxrc=0;

%EXIT2:

%put End macro check_error_and_zero_records;
%mend check_error_and_zero_records;