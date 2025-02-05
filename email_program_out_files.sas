/**************************************************************************************************************
* Macro_Name:   email_program_out_files
*
* Purpose: Send e-mail with zip file attachments associated with a specific program.
*
* Usage: %email_program_out_files
*
* Input_parameters: pgmname
*                    Name of program for which to send e-mail attachments passed in as shell var.
*
* Outputs:  None.
*
* Returns:  send_email_rc
*            1/0 Set to 0 if e-mailing completes successfully, else 1.
*
* Example:
*
* Modules_called: initialize
*                 set_directory_structure
*                 assign_libref
*                 check_error_and_zero_records
*                 chkerr
*                 create_date_parameters
*
*
* Maintenance_History:
*-------------------------------------------------------------------------------------------------------------*
*  Date:      |   Who:        |  Description:                                                                 *
*-------------------------------------------------------------------------------------------------------------*
* 08/24/2012  | Michael Gilman   | Initial creation.                                                          *
*-------------------------------------------------------------------------------------------------------------*
* HeaderEnd:                                                                                                  *
**************************************************************************************************************/

%macro email_program_out_files;
%put Start macro email_program_out_files;

 %local i dsid;

 %initialize;

 %let dsid=0;

 %let ebcc=;

 %let success_bcc=;

 %let send_email_rc=0;

 %let attach=;

 %let attach_text=;

 %let export_file_count=0;

 %if &useEG %then
 %do;

    %let errormsg1=email_program_out_files cannot be run from EG.;

    %let jumptoexit=1;

    %goto EMAIL;

 %end;

 %set_directory_structure; /*Set the Directory Structure*/
 %if &jumptoexit %then %goto EMAIL;

 %assign_libref(adminlib,&unixadmindatadir.);
 %if &jumptoexit %then %goto EMAIL;

 %assign_libref(rstats,&unixrstatsdir.);
 %if &jumptoexit %then %goto EMAIL;

 proc sql;
 create table ProgramSetup as
 select *
 from adminlib.ProgramSetup (where=(compress(upcase(PgmName))=compress(%upcase("&PgmName"))));
 quit;

 %chkerr(msg1=&syserrortext);
 %if &jumptoexit %then %goto EMAIL;

 %check_error_and_zero_records(dsn=ProgramSetup,msg2=Program name &PgmName not found in adminlib.ProgramSetup);
 %if &jumptoexit %then
 %do;

    %let errormsg1=Program name &PgmName not found in adminlib.ProgramSetup.;

    %let jumptoexit=1;

    %goto EMAIL;

 %end;

 proc sql noprint;
 select RecordActive, pgmid, pgmfreq, lob,
        security_level, SubjectArea, SendZip, notify_email, EmailTurnON,SCRIPT_REPORT_NAME,use_var_labels_for_export,
        column_headers_in_export,DeliveryMethod
  into :RecordActive,:pgmid, :pgmfreq, :lob,
       :security_level, :SubjectArea, :SendZip, : notify_email, : EmailTurnON, : _reportName, :use_var_labels_for_export,
       :column_headers_in_export,:DeliveryMethod
 from ProgramSetup;
 quit;

 %let pgmid=%trim(%left(&pgmid));
 %let pgmfreq=%trim(%left(&pgmfreq));
 %let lob=%lowcase(%trim(%left(&lob)));
 %let security_level=%trim(%left(&security_level));
 %let SubjectArea=%trim(%left(&SubjectArea));
 %let SendZip=%trim(%left(&SendZip));
 %let notify_email=%trim(%left(&notify_email));
 %let _reportName=&_reportName;

 %let SubjectArea=%sysfunc(lowcase(&SubjectArea));
 %let SubjectArea=%sysfunc(compress(&SubjectArea));
 %let lob=%sysfunc(lowcase(&lob));
 %let lob=%sysfunc(compress(&lob));

 %let unixrptdir=&rootloc/reports/&security_level/&lob/&SubjectArea;

 %create_date_parameters;
 %if &jumptoexit %then %goto EMAIL;

 %lock_on_member(rstats.program_out_files);
 %if &jumptoexit %then %goto EMAIL;

 proc sql;
 create table program_out_files as
 select file, record_count, dt_prcs_data
 from rstats.program_out_files (where=(compress(upcase(PgmName))=compress(%upcase("&PgmName"))));
 quit;

 %lock_off_member(rstats.program_out_files);

 %let number_of_output_files=&sqlobs;

 %if &number_of_output_files<=0 %then
 %do;

    %let errormsg1=No output files for &PgmName;

    %let jumptoexit=1;

    %goto EMAIL;

 %end;

 proc sql;
 create table program_out_files as
 select file, record_count, dt_prcs_data
 from program_out_files (where=(dt_prcs_data="&dt_prcs_data"));
 quit;

 %let number_of_output_files=&sqlobs;

 %if &number_of_output_files<=0 %then
 %do;

    %let errormsg1=No output files for &PgmName having process date &dt_prcs_data;

    %let jumptoexit=1;

    %goto EMAIL;

 %end;

 proc sql noprint;
  select distinct email into : success_bcc separated by '^'
  from adminlib.programsetup_emails_bcc
  where pgmname="&PgmName"
 ;
 quit;

 %chkerr(msg1=&syserrortext);
 %if &jumptoexit %then %goto EMAIL;

 %let dsid=%sysfunc(open(program_out_files));

 %do i=1 %to &number_of_output_files;

    %let rc=%sysfunc(fetch(&dsid));

    %let outfile=%sysfunc(getvarc(&dsid,%sysfunc(varnum(&dsid,file))));

    %let temp_outfile=%superq(unixrptdir)/&outfile..zip;

    %if %sysfunc(fileexist(&temp_outfile))=0 %then
    %do;

       %let errormsg1=&temp_outfile does not exist;

       %let jumptoexit=1;

       %goto EMAIL;

    %end;

    %let record_count=%sysfunc(getvarn(&dsid,%sysfunc(varnum(&dsid,record_count))));

    %if &i>1 %then %let separator=^;
    %else %let separator=;

    %let attach_text=%superq(attach_text)%str(&separator)&outfile;

    %let attach_text=%superq(attach_text), Record count %left(%qsysfunc(putn(&record_count,comma32.)));

    %let attach_text=%unquote(&attach_text);

    %if &i>1 %then %let separator=^;
    %else %let separator=;

    %let attach=%superq(attach)%str(&separator)&temp_outfile;

    %let attach=%unquote(&attach);

 %end;

 %let dsid=%sysfunc(close(&dsid));

 %lock_on_member(rstats.runtimestats);

 %let _email_subject=;

 proc sql noprint;
  select email_subject into : _email_subject
  from rstats.runtimestats
  where pgmid="&pgmid" and upcase(status)='SUCCESS' and dt_prcs_data="&dt_prcs_data"
  ;
 quit;

 %lock_off_member(rstats.runtimestats);

 %if %superq(_email_subject) ne %str() %then %let success_subject=%superq(_email_subject);

%EMAIL:

 %let success_attach=&attach;
 %let success_attach_text=&attach_text;
 %let success_subject=&_reportName;

 %if &jumptoexit %then
 %do;

   %let success_subject=ERROR: &_reportName for process data &dt_prcs_data completed unsuccessfully;

   %let success_attach_text=&errormsg1;

 %end;

 data _null_;

  length PgmName $100
         success_attach $32767 success_subject $300 success_email_text success_attach_text $32767
         warn_attach $300 warn_subject $300 warn_email_text $1000
         emailerr_attach $300 emailerr_subject $300 emailerr_email_text $1000
         success_bcc $32767
  ;

  PgmName="&PgmName";
  success_attach="&success_attach";
  success_attach_text="&success_attach_text";
  success_subject="&success_subject";
  success_bcc="&success_bcc";

  scnt=count(success_attach_text,"^")+1;
  sbcccnt=count(success_bcc,"^")+1;

  if compress(success_attach) eq "" then sattachcnt=0;
  else sattachcnt=count(success_attach,"^")+1;

  call symputx('efrom',"&email_global_from");

  call symputx('ecnt',strip(scnt));
  call symputx('ebcc',success_bcc);
  call symputx('eattach',success_attach);
  call symputx('esubj',success_subject);
  call symputx('etext',success_attach_text);
  call symputx('ebcccnt',sbcccnt);
  call symputx('eattachcnt',sattachcnt);
  call symputx('eattachtxt',success_attach_text);

 run;

 %if &notify_email_override ne %str() %then %let notify_email=&notify_email_override;

 %let to_count=%eval(%sysfunc(count(%trim(&notify_email),%str( ))))+1;

 filename outbox email "&email_global_from";

 data _null_;

  file outbox
       from=("&email_global_from")

       /* No matter what &notify_email should always receive an email*/

       to=(%do i=1 %to &to_count; "%scan(&notify_email,&i,%str( ))" %str( ) %end;)

       %if %superq(notify_email_override)=%str() %then
       %do;

          %if &env=prod and %superq(ebcc) ne %str() and &notify_email_override=%str() and &jumptoexit=0 %then
          %do;

          bcc=(%do i=1 %to &ebcccnt; "%scan(&ebcc,&i,^,m)" %str( ) %end;)

          %end;

       %end;

       subject= ("&esubj")

       %if &eattachcnt ge 1 %then
       %do;

          attach=(
          %do i=1 %to &eattachcnt;

             %let temp=%trim(%scan(%trim(%superq(eattach)),&i,^,m));
             %let temp=%sysfunc(quote(%unquote(&temp)));
             %unquote(&temp)

          %end;
          lrecl=1000)

       %end;
       CT= "text/html"
  ;

  put '<html>';
  put '<body>';

  %if &jumptoexit=0 %then %str(put "See attached &_reportName for &emaildate.";);

  put "<br />";
  put "<br />";

  %do i=1 %to &ecnt;

     %let scanned=%scan(%superq(etext),&i.,^,m);

     %if %length(%superq(scanned)) gt 0 %then
     %do;
        put "%superq(scanned)";
        put "<br />";
     %end;
     %else
     %if %length(%superq(scanned))=0 %then
     %do;
        put "<br />";
     %end;

  %end;

  %if %symexist(email_body_text) %then
  %do;

     put "<br />";

     %let i=0;

     %let more=1;

     %do %while(&more);

        %let i=%eval(&i+1);

        %let c=%scan(%superq(email_body_text),&i,%str(^));

        %if %superq(c) ne %str() %then
        %do;

           put "&c";
           put "<br />";

        %end;
        %else %let more=0;

     %end;

  %end;

  put "<br />";
  put "<br />";

  %if &env ne prod %then
  %do;

     put "Environment: %upcase(&env)";
     put "<br />";
     put "<br />";

  %end;

  put '</body>';
  put '</html>';

 run;

 %let send_email_rc=&syserr;

 filename outbox clear;

%EXIT:

 %if &dsid %then %let dsid=%sysfunc(close(&dsid));

%put End macro email_program_out_files;
%mend email_program_out_files;
