/**************************************************************************************************************
* Macro_Name:   validate_out_files
*
* Purpose: This macro checks that a program has a corresponding %let out_xxx statement for
*          each found occurrence of &out_xxx in the user's program.
*
* Usage: %validate_out_files(program_file);
*
* Input_parameters: program_file
*                    Full pathname of the program file to check.
*
* Outputs:  None
*
* Returns:  If error, jumptoexit=1 and errormsg1-n macro variables are set.
*
* Example:
*
* Modules_called: None
*
* Maintenance_History:
*-------------------------------------------------------------------------------------------------------------*
*  Date:      |   Who:        |  Description:                                                                 *
*-------------------------------------------------------------------------------------------------------------*
* 12/10/2012  | Michael Gilman| Initial creation.                                                             *
* 12/14/2012  | Michael Gilman| Now convert potential tab characters to blanks.                               *
*-------------------------------------------------------------------------------------------------------------*
* HeaderEnd:                                                                                                  *
**************************************************************************************************************/

%macro validate_out_files(program_file);
%put Start macro validate_out_files;

 %let error=0;

 data _null_;

  infile "&program_file" truncover end=e;

  array out_files{999} $32 _temporary_;

  input line $256.;

  line=lowcase(line);

  line=translate(line,' ','09'x);

  if line='' then return;

  line=compbl(line);

  line=left(line);

  if line=:'%let out_'  then
  do;

     c=scan(substr(line,6),1,' =');

     if c ne '' then
     do;

        c2=scan(c,2,'_');

        file_count+1;

        out_files{file_count}=c2;

     end;

  end;

  pos=find(line,'saslib.&out_');

  if pos then
  do;

     line=substr(line,pos+12);

     c=scan(line,1);

     found=0;

     do i=1 to file_count while(not found);

        if c=out_files{i} then found=1;

     end;

     if not found then
     do;

        text='saslib.&out_'!!trim(c)!!' on program line '!!trim(left(put(_N_,best.)))!!' not defined with a corresponding %let out_'!!trim(c)!!'= statement.';

        error+1;

        call symputx('errormsg'!!left(put(error,best.)),trim(text));

     end;

  end;

  if e then call symputx('error',error);

 run;

 %if &error %then
 %do;

    %let jumptoexit=1;

 %end;

%put End macro validate_out_files;
%mend validate_out_files;
