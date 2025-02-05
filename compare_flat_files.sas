/**************************************************************************************************************
* Macro_Name:   compare_flat_files
*
* Purpose: This macro compares the content of two flat files.
*
* Usage: %compare_flat_files(file1=,file2=,max_lines_to_check=1000000,odstype=html,printfile=);
*
* Input_parameters: file1
*                    Full pathname of file to check
*                   file2
*                    Full pathname of file to check
*                   max_lines_to_check
*                    Maximum number of lines to check
*                    Default: 1000000
*                   odstype
*                    Optional. Specify html, pdf, rtf if you want print results to these destinations.
*                   printfile
*                    Optional. If odstype specified, full pathname of the print file.
*
* Outputs:  None.
*
* Returns:  files_match
*            1 if files match, otherwise 0
*           lines_read_in
*            Number of lines read in from each file
*
* Example:
*
* Modules_called: None
*
* Maintenance_History:
*----------------------------------------------------------------------------------------------------------------*
*  Date:      |   Who:           |  Description:                                                                 *
*----------------------------------------------------------------------------------------------------------------*
* 10/11/2012  | Michael Gilman   | Initial creation.                                                             *
*----------------------------------------------------------------------------------------------------------------*
* HeaderEnd:                                                                                                     *
**************************************************************************************************************/

%macro compare_flat_files(file1=,file2=,max_lines_to_check=1000000,odstype=html,printfile=);

 %global files_match lines_read_in;

 %let files_match=0;

 %let lines_read_in=0;

 %if &odstype ne %str() and %superq(printfile) ne %str() %then
 %do;

    ods listing close;

    ods &odstype file="&printfile" style=analysis;

 %end;

 %if %sysfunc(fileexist(&file1))=0 %then
 %do;

    %put ERROR: File &file1 does not exist.;

    data _null_;

     file print;

     put "ERROR: File &file1 does not exist.";

    run;

    %goto EXIT;

 %end;

 %if %sysfunc(fileexist(&file2))=0 %then
 %do;

    %put ERROR: File &file2 does not exist.;

    data _null_;

     file print;

     put "ERROR: File &file2 does not exist.";

    run;

    %goto EXIT;

 %end;

 %let filename1=%sysfunc(scan(%superq(file1),-1,%str(/)));

 %let filename2=%sysfunc(scan(%superq(file2),-1,%str(/)));

 filename file1 "&file1" lrecl=32767;

 filename file2 "&file2" lrecl=32767;

 data file1(compress=yes);

  infile file1 truncover;

  input line1 $char32767.;

  linenum1+1;

  output;

  call symputx('lines_1',linenum1);

  keep line1 linenum1;

 run;

 data file2(compress=yes);

  infile file2 truncover;

  input line2 $char32767.;

  linenum2+1;

  output;

  call symputx('lines_2',linenum2);

  keep line2 linenum2;

 run;

 %if &lines_1 ne &lines_2 %then
 %do;

   %put Number of lines in the two files do not match.;
   %put %qleft(%qsysfunc(putn(&lines_1,comma32.))) lines in &filename1;
   %put %qleft(%qsysfunc(putn(&lines_2,comma32.))) lines in &filename2;

   data _null_;

      file print;

    put "Compare &filename1 with &filename2";
    put 'Files do not match.';
      put "Number of lines in the two files do not match.";
      put "&filename1 has %qleft(%qsysfunc(putn(&lines_1,comma32.))) lines";
      put "&filename2 has %qleft(%qsysfunc(putn(&lines_2,comma32.))) lines";

   run;

   %goto EXIT;

 %end;

 proc sort data=file1(obs=&max_lines_to_check);
 by line1;
 run;

 proc sort data=file2(obs=&max_lines_to_check);
 by line2;
 run;

 data nomatch;

 if e then
 do;

    call symputx('files_match',1);

    call symputx('lines_read_in',_N_-1);

 end;

 merge file1 file2 end=e;

 if line1 ne line2 then
 do;

   output;

   call symputx('linenum1',linenum1);
   call symputx('linenum2',linenum2);

   put 'WARNING: Line ' linenum1 " in &filename1 does not match " linenum2 " in &filename2";

   call symputx('lines_read_in',_N_);

   stop;

 end;

 run;

 ods proclabel "Compare &filename1 with &filename2";

 data _null_;

  file print;

  put "Compare &filename1 with &filename2";

  if &files_match then put "Files match.";
  else
  do;

     put "Files do not match.";

   put "Line &linenum1 in &filename1 does not match &linenum2 in &filename2";

   set nomatch;

   put;

   put "&filename1:";
   put line1;

   put;

   put "&filename2:";
   put line2;

   put;

  end;

  put "%qleft(%qsysfunc(putn(&lines_1,comma32.))) lines in each file.";

  put "Number of lines read in: %qleft(%qsysfunc(putn(&lines_read_in,comma32.)))";

  stop;

 run;

%EXIT:

 %if &odstype ne %str() and %superq(printfile) ne %str() %then
 %do;

    ods &odstype;

 %end;

%mend compare_flat_files;

options mprint;
/*
%compare_flat_files(
file1=/u04/data/cig_ebi/dmg/uat/reports/L3/enterprise/payments/l3192_101312_f_qp_ach_returns_sn.csv,
file2=/u04/data/cig_ebi/dmg/uat/dump/qp_ach_returns_report_101312.csv
);
*/