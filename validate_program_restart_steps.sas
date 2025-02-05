/**************************************************************************************************************
* Macro_Name:   validate_program_restart_steps
*
* Purpose: This macro checks that a program that uses the restart capability has programming statements
*          that the restart logic expects. Specifically, the macro parses the program code and looks for
*          matching occurrences of the %STEPnn macro labelled section and the invocation of either the
*          %check_error_and_zero_records or %chkerr or %error_check macro.
*
*          The macro also checks for valid %STEPnn names.
*
*          The macro also checks that the step= value is valid for the %check_error_and_zero_records,
*          %chkerr and %error_check macros.
*
* Usage: %validate_program_restart_steps(program_file);
*
* Input_parameters: program_file
*                    Full pathname of the program file to check.
*                   useEG (global)
*
* Outputs:  None
*
* Returns:  If error, jumptoexit=1 and errormsg1-3 macro variables are set.
*
* Example:
*
* Modules_called: None
*
* Maintenance_History:
*-------------------------------------------------------------------------------------------------------------*
*  Date:      |   Who:        |  Description:                                                                 *
*-------------------------------------------------------------------------------------------------------------*
* 04/15/2012  | Michael Gilman| Initial creation.                                                             *
* 05/04/2012  | Michael Gilman| Now handle 3 digit STEP values.                                               *
* 05/14/2012  | Michael Gilman| Removed the text "ERROR:" from an assignment to variable msg.                 *
* 05/16/2012  | Michael Gilman| Remove potential tab characters from input line.                              *
* 06/30/2012  | Michael Gilman| Added creation of new macro variable _LastStepNumber. This records the        *
*             |               | last Step Number of a program.                                                *
* 09/06/2012  | Michael Gilman| Now check for %error_check in addition to %check_error_and_zero_records and   *
*             |               | %chkerr macros.                                                               *
* 10/22/2012  | Michael Gilman| Now look for string "%macro main" before starting to check statements.        *
* 12/18/2012  | Michael Gilman| Now look for first occurrence of %STEP before starting to check statements.   *
*-------------------------------------------------------------------------------------------------------------*
* HeaderEnd:                                                                                                  *
**************************************************************************************************************/

%macro validate_program_restart_steps(program_file);
%put Start macro validate_program_restart_steps;

 %local msg linenum step;

 %let msg=;

 %if &useEG %then %goto EXIT;

data _null_;

 length step $8 msg $200;

 retain step_found_num step;

 infile "&program_file" truncover end=eof;

 input line $256.;

 line=translate(line,'','09'x);

 line=left(line);

 if find(upcase(substr(line,1,5)),'%STEP') then found+1;

 if not found then return;

 if find(upcase(substr(line,1,5)),'%STEP')  then
 do;

    step=scan(line,1,':');

    if not (7<=length(step)<=8) then
    do;

       msg='Step name '!!step!!' invalid.';

       goto STOP;

    end;

    step_found_numc=substr(step,6);

    if not (2<=length(step_found_numc)<=3) then
    do;

       msg='Step name '!!step!!' invalid.';

       goto STOP;

    end;

    step_found_num=input(step_found_numc,??best.);

    if step_found_num=. then
    do;

       msg='Step name '!!step!!' invalid.';

       goto STOP;

    end;

    step_name_count+1;

    if step_name_count>step_count+1 then
    do;

       msg='Two consecutive occurrences of the %STEP macro labelled section before %check_error_and_zero_records or %chkerr or %error_check macro '!!
           'invocation encountered.';

       goto STOP;

    end;

    call symputx('_LastStepNumber',step_name_count);

 end;

 if find(lowcase(line),'%check_error_and_zero_records') or find(lowcase(line),'%chkerr') or find(lowcase(line),'%error_check') then
 do;

    step_count+1;

    if step_count ne step_found_num then
    do;

       msg='Step '!!step!!' is out of order or you are missing a %STEPnn macro labelled section.';

       goto STOP;

    end;

    pos=find(lowcase(line),'step=');

    if not pos then
    do;

       pos1=find(lowcase(line),'%check_error_and_zero_records');

       pos2=find(lowcase(line),'%chkerr');

       pos3=find(lowcase(line),'%error_check');

       if pos1 then
          msg='The "step=" parameter must be specified on the %check_error_and_zero_records macro invocation.';
       else
       if pos2 then
          msg='The "step=" parameter must be specified on the %cherr macro invocation.';
       else
          msg='The "step=" parameter must be specified on the %error_check macro invocation.';

       goto STOP;

    end;

    c=scan(substr(line,pos+5),1,',);');

    if c='' then
    do;

       msg='The "step=" parameter must have a value.';

       goto STOP;

    end;

 end;

 if eof then
 do;

    if step_name_count ne step_count then
    do;

       if step_name_count>step_count then
       do;

          msg='There is one or more missing occurrences of %check_error_and_zero_records or %chkerr or %error_check or '!!
              'you have a duplicate step names.';

       end;
       else
       do;

          msg='There is one or missing occurrences of the %STEPnn macro labelled section.';

       end;

    end;

 end;

STOP:

 if msg ne '' then
 do;

    msg=compbl(msg);

    call symputx('msg',msg);

    call symputx('linenum',_N_);

    call symputx('step',step);

    stop;

  end;

 run;

 %if %superq(msg) ne %str() %then
 %do;

    %put ERROR: %superq(msg);

    %let errormsg1=%superq(msg);

    %put ERROR: Last step name encountered: %superq(step);

    %let errormsg2=Last step name encountered: %superq(step);

    %put ERROR: Last program line read in: &linenum;

    %let errormsg3=Last program line read in: &linenum;

    %let jumptoexit=1;

 %end;

%EXIT:

%put End macro validate_program_restart_steps;
%mend validate_program_restart_steps;