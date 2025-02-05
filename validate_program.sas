/**************************************************************************************************************
* Macro_Name: validate_program
/* %validate_program performs 3 functions. It reads in the job and checks for too long sas data set names and checks      */
 /* that %STEP labels are in sequence and each followed by a check error macro. It also validates that the saslib.&out_xxx */
 /* have corresponding %let out_xxx.
*
* Purpose: This macro performs 3 functions that validate various aspects of the job code.
*          It reads in the job cdoe and:
*          1. Checks that %STEP labels are in sequence and are each followed by a check error macro invocation.
*          2. Checks for too long sas data set names.
*          3. Validates that saslib.&out_xxx have corresponding %let out_xxx=.
*
* Usage: %validate_program(program_file);
*
* Input_parameters: program_file
*                    Full pathname of the program file to check.
*
* Outputs:  None
*
* Returns:  If error, jumptoexit=1
*
* Example:
*
* Modules_called: %validate_program_restart_steps
*                 %validate_program_long_dsn_names
*                 %validate_out_files
*
* Maintenance_History:
*-------------------------------------------------------------------------------------------------------------*
*  Date:      |   Who:        |  Description:                                                                 *
*-------------------------------------------------------------------------------------------------------------*
* 04/23/2012  | Michael Gilman| Initial creation.                                                             *
* 05/01/2012  | Michael Gilman| Now put any error messages to the log.                                        *
* 05/16/2012  | Michael Gilman| Minor change to put to log second error message from                          *
*             |               | validate_program_long_dsn_names.                                              *
* 12/10/2012  | Michael Gilman| New validation check: %validate_out_files                                     *
*             |               | Checks that a program has a corresponding %let out_xxx statement for          *
*             |               | each found occurrence of &out_xxx in the user's program.                      *
*-------------------------------------------------------------------------------------------------------------*
* HeaderEnd:                                                                                                  *
**************************************************************************************************************/

%macro validate_program(program_file);
%put Start macro validate_program;

 %local i temp prev_jumptoexit error_msg_count;

 %if %sysfunc(fileexist(&program_file))=0 %then %goto EXIT;

 %let prev_jumptoexit=0;

 %let error_msg_count=0;

 /* Check that %STEP labels are in sequence and are each followed by a check error macro invocation. */

 %validate_program_restart_steps(&program_file);

 %if &jumptoexit %then
 %do;

    %do i=1 %to 10;

       %let temp=&&errormsg&i;

       %if %superq(temp) ne %str() %then
       %do;

          %let error_msg_count=%eval(&error_msg_count+1);

          %let temp_msg&error_msg_count=&temp;

       %end;

    %end;

    %let prev_jumptoexit=1;

    %let jumptoexit=0;

 %end;

 /* Check for too long sas data set names. */

 %validate_program_long_dsn_names(&program_file);

 %if &jumptoexit %then
 %do;

    %let error_msg_count=%eval(&error_msg_count+1);

    %let temp_msg&error_msg_count=&errormsg1;

    %let error_msg_count=%eval(&error_msg_count+1);

    %let temp_msg&error_msg_count=&errormsg2;

    %let prev_jumptoexit=1;

    %let jumptoexit=0;

 %end;

 %do i=1 %to 10;

    %let errormsg&i=;

 %end;

 /* Validate that saslib.&out_xxx have corresponding %let out_xxx=. */

 %validate_out_files(&program_file);

 %if &jumptoexit %then
 %do;

    %do i=1 %to 10;

       %let temp=%superq(errormsg&i);

       %if %superq(temp) ne %str() %then
       %do;

          %let error_msg_count=%eval(&error_msg_count+1);

          %let temp_msg&error_msg_count=%superq(temp);

       %end;

    %end;

    %let prev_jumptoexit=1;

    %let jumptoexit=0;

 %end;

 %let jumptoexit=&prev_jumptoexit;

 %if &jumptoexit %then
 %do;

    %do i=1 %to &error_msg_count;

       %let errormsg&i=%superq(temp_msg&i);

	     %put ERROR: &&errormsg&i;

	     %let temp=%superq(errormsg&i);

	     %let _ERROR=%superq(_ERROR) %superq(temp);

    %end;

 %end;

%EXIT:

%put End macro validate_program;
%mend validate_program;
