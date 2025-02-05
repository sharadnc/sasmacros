/**************************************************************************************************************
* Macro_Name:   send_email
*
* Purpose: Send e-mail stating completion condition of the program.
*
* Usage: %send_email(Email_Condition);
*
* Input_parameters: Email_Condition
*                    Expected values are SUCCESS and WARN and EMAILWARN
*                   EmailTurnON (global)
*                    Y/N Indicates whether to send the e-mail.
*                    Note that an e-mail is sent if the program finishes in error even when value is N.
*                   PgmName (global)
*                   number_of_output_files (global)
*                   export_type (global)
*                   sendzip (global)
*
* Outputs:  None.
*
* Returns:  send_email_rc
*            1/0 Set to 0 if e-mailing completes successfully, else 1.
*
* Example:
*
* Modules_called: get_outfile_attrs
*
* Maintenance_History:
*-------------------------------------------------------------------------------------------------------------*
*  Date:      |   Who:        |  Description:                                                                 *
*-------------------------------------------------------------------------------------------------------------*
* 12/14/2011  | Sharad           | Initial creation.                                                          *
* 12/14/2011  | Michael Gilman   | Initial creation.                                                          *
* 04/13/2012  | Michael Gilman   | Added _ERROR macro value to error text to appear in emails.                *
*             |                  | Also added last successfully completed step numer.                         *
* 04/27/2012  | Michael Gilman   | Removed RecordActive="Y" from where clause.                                *
*             |                  | Now check if &dt_sas is missing when setting emaildate.                    *
* 04/28/2012  | Michael Gilman   | Changed email logic to handle the new notify_email variable which replaces *
*             |                  | all the former email variables in adminlib.programsetup.                   *
* 05/02/2012  | Michael Gilman   | Now put value of &env in email body when env not prod or uat.              *
* 06/11/2012  | Sharad           | Add distinct to the emails                                                 *
* 06/22/2012  | Michael Gilman   | Now check if &notify_email_override is not missing and, if not, do not     *
*             |                  | email bcc.                                                                 *
* 06/30/2012  | Michael Gilman   | Now check for output type sas (out_sas).                                   *
* 07/04/2012  | Michael Gilman   | Removed setting of emaildate which is now set in %create_date_parameters   *
* 07/04/2012  | Michael Gilman   | Restructured the code to remove unneeded data steps.                       *
* 07/06/2012  | Michael Gilman   | Fixed bug: Zip files were being wrongly attached when out type was sas.    *
* 07/06/2012  | Michael Gilman   | Changed email body text to conform to legacy.                              *
* 07/10/2012  | Michael Gilman   | Now check if out_rename values are set. If so, use that name for the export*
* 07/12/2012  | Michael Gilman   | Changed report_date to emaildate.                                          *
* 07/22/2012  | Michael Gilman   | Replaced Email_ConditionTurnON with EmailTurnON.                           *
* 07/29/2012  | Michael Gilman   | Now check for existence of macro variable email_body_text. If it exists,   *
*             |                  | we use it for the body text of the email.                                  *
* 08/01/2012  | Michael Gilman   | Now support macro variable email_body_text having multiple lines.          *
* 08/01/2012  | Michael Gilman   | Now only print out FTP message is program is successful.                   *
* 08/01/2012  | Michael Gilman   | Left align the record count text in email body.                            *
* 09/06/2012  | Michael Gilman   | Now set notify_email to notify_email_override if notify_email_override if  *
*             |                  | it is set.                                                                 *
* 09/13/2012  | Michael Gilman   | if export_type=sas and deliveryMethod ne FTP then don't print record count *
*             |                  | in email body.                                                             *
* 09/17/2012  | Michael Gilman   | Major rewriting of the macro. Now check for maximum size of attachments.   *
*             |                  | If total attachment file size is greater than attach_filesize_max (set in  *
*             |                  | Initialize macro), then send separate emails with separate attachments.    *
* 09/20/2012  | Michael Gilman   | Now check if reccnt&i is missing. If so, don't write Record Count text     *
*             |                  | in email body.                                                             *
* 10/08/2012  | Michael Gilman   | Minor enhancement: If not prod, then print program name in email body.     *
* 10/11/2012  | Michael Gilman   | Added %symexist(reccnt&i) to %if when checking whether to print Record count*
* 10/15/2012  | Sharad           | Use a lowcase function for the output files                                *
* 10/20/2012  | Michael Gilman   | New macro variable email_subject_override allows user to override default  *
*             |                  | email subject line.                                                        *
* 10/20/2012  | Michael Gilman   | Now set new global macro variable email_subject to be value of the         *
*             |                  | email subject line.                                                        *
* 10/25/2012  | Michael Gilman   | Fixed small bug. The %if &deliverMethod eq FTP was failing as              *
*             |                  | deliverMethod was resolving Portal and Email in some cases. The "and"      *
*             |                  | was causing the problem.                                                   *
* 12/06/2012  | Michael Gilman   | Changed name of export_file_count macro var to zip_file_count.             *
* 12/10/2012  | Michael Gilman   | Now use &zip_extension instead of hard-coded "zip".                        *
* 12/20/2012  | Michael Gilman   | Removed the %upcase from %if %upcase(%superq(DeliveryMethod)) eq FTP %then *
* 02/28/2013  | Sharad           | Add support to donotzip option.                                            *
*-------------------------------------------------------------------------------------------------------------*
* HeaderEnd:                                                                                                  *
**************************************************************************************************************/

%macro send_email(Email_Condition);
%put Start macro send_email;

 %local temp i ii ext zip_file_count more c emailn;

 %let ebcc=;

 %let success_bcc=;

 %let send_email_rc=0;

 %let attach1=;

 %let attach_text1=;

 %let attach_count1=0;

 %let emailn=1;

 %let zip_file_count1=0;

 %let attach_filesize_total=0;

 %if &jumptoexit=0 %then
 %do; /* Program completed successfully */

    %do i=1 %to &number_of_output_files; /* For each out_ specification  */

       /* Get the attributes of the out_xxx specification which include:        */
       /* outfile: name of the output file                                      */
       /* export_type: txt,csv,tab,sas,xls,dat,rtf,html,zipsas                  */
       /* extension: txt,csv,xls,dat,html,sas7bdat                              */
       /* outfile_rename: Optionally the name to use for the output file.       */

       %get_outfile_attrs(&i);

       /* Use outfile_rename for the file name if specified, otherwise use outfile */

       %if %superq(outfile_rename) ne %str() %then %let useOutfile=%lowcase(&outfile_rename);
       %else %let useOutfile=%lowcase(&outfile);
       
       %if &sendzip=Y and &export_type ne sas %then
       %do; /* If attachment to be sent, determine its file size */
          %if &zip_extension eq donotzip %then %let temp=%superq(unixrptdir)%str(/)&useOutfile..&extension;
          %else %if &zip_extension eq gz %then %let temp=%superq(unixrptdir)%str(/)&useOutfile..&extension..&zip_extension;
          %else %let temp=%superq(unixrptdir)%str(/)&useOutfile..&zip_extension;

          %let fileref=_ftemp;

          %let rc=%sysfunc(filename(fileref,&temp));

          %let _fid=%sysfunc(fopen(_ftemp));

          %let filesize=%sysfunc(finfo(&_fid,File Size (bytes)));

          %let _fid=%sysfunc(fclose(&_fid));

       %end;/* If attachment to be sent, determine its file size */
       %else %let filesize=0;

       /* If file size > attach_filesize_max (set in initialize macro), then error */

       %if &filesize>&attach_filesize_max %then
       %do; /* File size > attach_filesize_max (set in initialize macro), so error */

          %let errormsg1=Cannot send attachment &useOutfile as it too large (&filesize bytes);

          %let _ERROR=&errormsg1;

          %let Email_Condition=WARN;

          %goto NEXT;

       %end;/* File size > attach_filesize_max (set in initialize macro), so error */

       /* Normally, one email is sent containing 1 or more zip file attachments.                                    */
       /* Add up the file sizes for the attachments files so far. If the total is greater than attach_filesize_max, */
       /* increment emailn which is a counter for the number of emails that will be sent.                           */

       %let attach_filesize_total=%eval(&attach_filesize_total+&filesize);

       %if &attach_filesize_total>&attach_filesize_max %then
       %do; /* Attachment file size total > attach_filesize_max, so increment emailn */

          %let attach_filesize_total=0;

          %let emailn=%eval(&emailn+1);

          %let zip_file_count&emailn=0;

          %let attach_text&emailn=;

          %let attach&emailn=;

       %end;/* Attachment file size total > attach_filesize_max, so increment emailn */

       /* If export_type=sas, there is no zip file */

       %if &export_type=sas %then %let ext=;
       %else
       %do; /* Increment the zip file count for this (emailn) email */

          %let zip_file_count&emailn=%eval(&&zip_file_count&emailn+1);
          
					%if &zip_extension eq donotzip %then %let ext=.&extension;
					%else %if &zip_extension eq gz %then %let ext=.&extension..&zip_extension;
          %else %let ext=.&zip_extension;

       %end;/* Increment the zip file count for this (emailn) email */

       /* Set the text that will be used in the email body consisting of the file name with its record count. */
       /* Only do this if export_type ne sas or (export_type=sas and deliveryMethod=FTP).                     */

       %if &export_type ne sas or (&export_type=sas and %superq(deliveryMethod)=FTP) %then
       %do; /* Set email body text */

          %let temp=&&attach_text&emailn;

          %if %superq(temp) ne %str() %then %let separator=^;
          %else %let separator=;

          %if %symexist(reccnt&i) and %str(&&reccnt&i)>=0 %then
             %let attach_text&emailn=%superq(temp) %str(&separator)&useOutfile.&ext, Record count %left(%qsysfunc(putn(&&reccnt&i,comma32.)));
          %else
             %let attach_text&emailn=%superq(temp) %str(&separator)&useOutfile.&ext;

          %let attach_text&emailn=%unquote(&&attach_text&emailn);

       %end;/* Set email body text */

       /* If attachment to be sent, set attach&emailn to full pathname of the zip file. */
       /* Note that attach&emailn may contain more than one zip file name.              */

       %if &sendzip=Y and &export_type ne sas %then
       %do; /* Set attach&emailn to full pathname of the zip file */

          %let temp=&&attach&emailn;

          %if %superq(temp) ne %str() %then %let separator=^;
          %else %let separator=;
                    
          %if &zip_extension eq donotzip %then %let attach&emailn=%superq(temp)%str(&separator)%superq(unixrptdir)%str(/)&useOutfile..&extension;
          %else %if &zip_extension eq gz %then %let attach&emailn=%superq(temp)%str(&separator)%superq(unixrptdir)%str(/)&useOutfile..&extension..&zip_extension;
          %else %let attach&emailn=%superq(temp)%str(&separator)%superq(unixrptdir)%str(/)&useOutfile..&zip_extension;

          %let attach&emailn=%unquote(&&attach&emailn);

       %end;/* Set attach&emailn to full pathname of the zip file */

    %end; /* For each out_xxx specification */

 %end;/* Program completed successfully */

%NEXT:

 /* The emaildate displayed in the email is normally generated by the Toolkit. However, the user */
 /* may override it in their program.                                                            */

 %if %symexist(email_emaildate_override) %then
 %do;

    %if %superq(email_emaildate_override) ne %str() %then %let emaildate=&email_emaildate_override;

 %end;

 /* Get the email addresses of all end-users that will receive the email. */

 proc sql noprint;
  select distinct email into : success_bcc separated by '^'
  from adminlib.programsetup_emails_bcc
  where pgmname="&PgmName"
 ;
 quit;

 /* Set up macro variables to be used in email body when there is a program error. */

 %let warn_attach=;

 %if &useEG=0 %then %let warn_attach=&logfile;
 %let warn_subject=ERROR : &_reportName for &emaildate completed unsuccessfully;
 %let warn_email_text=^^ERROR : &_reportName for &emaildate completed unsuccessfully;
 %let warn_email_text=%superq(warn_email_text)^^%superq(_ERROR);
 %let warn_email_text=%superq(warn_email_text)^^Last successfully completed Step Number: &step_count;

 /* Set up macro variables to be used in email body when an email cannot be sent. */

 %let emailerr_attach=&logfile.;
 %let emailerr_subject=ERROR : Email not sent for &_reportName - &emaildate;
 %let emailerr_email_text=^^ERROR : Email not sent for &_reportName - &emaildate^^Note: This is an automatically generated email.;

 %do ii=1 %to &emailn; /* For each email to be sent ... */

    %let temp=&&attach&ii; /* zip file name */

    %if %superq(temp) ne %str() %then %let success_attach=&&attach&ii;
    %else %let success_attach=;

    %let temp=&&attach_text&ii; /* Attachment text in email body */

    %if %superq(temp) ne %str() %then %let success_attach_text=&&attach_text&ii;
    %else %let success_attach_text=;

    %let success_subject=&_reportName for &emaildate;
    %let success_email_text=&_reportName for &emaildate completed successfully.%str(^^);

    /* There are 3 conditions in which an email is sent which is specified by the input parameter Email_Condition:   */
    /* 1. SUCCESS:   Program completed successfully.                                                                 */
    /* 2. WARN:      Program failed.                                                                                 */
    /* 3. EMAILWARN: email could not be sent for some reason.                                                        */

    /* Set up various macro variables that correspond to the 3 values for Email_Condition. */

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
     success_email_text="&success_email_text";
     success_bcc="&success_bcc";

     warn_attach="&warn_attach";
     warn_subject="&warn_subject";
     warn_email_text="&warn_email_text";

     emailerr_attach="&emailerr_attach";
     emailerr_subject="&emailerr_subject";
     emailerr_email_text="&emailerr_email_text";

     success_email_text=strip(success_email_text);
     warn_email_text=strip(warn_email_text);
     emailerr_email_text=strip(emailerr_email_text);

     scnt=count(success_attach_text,"^")+1;
     sbcccnt=count(success_bcc,"^")+1;

     if compress(success_attach) eq "" then sattachcnt=0;
     else sattachcnt=count(success_attach,"^")+1;

     wcnt=count(warn_email_text,"^")+1;
     wbcccnt=count(warn_bcc,"^")+1;
     wattachcnt=count(warn_attach,"^")+1;

     if compress(warn_attach) eq "" then wattachcnt=0;
     else wattachcnt=count(warn_attach,"^")+1;

     ecnt=count(emailerr_email_text,"^")+1;
     ebcccnt=count(emailerr_bcc,"^")+1;

     if compress(emailerr_attach) eq "" then eattachcnt=0;
     else eattachcnt=count(emailerr_attach,"^")+1;

     call symputx('efrom',"&email_global_from");

     %if %upcase(&Email_Condition)=SUCCESS %then
     %do;
        call symputx('ecnt',strip(scnt));
        call symputx('ebcc',success_bcc);
        call symputx('eattach',success_attach);
        call symputx('esubj',success_subject);
        call symputx('etext',success_attach_text);
        call symputx('ebcccnt',sbcccnt);
        call symputx('eattachcnt',sattachcnt);
        call symputx('eattachtxt',success_attach_text);
     %end;
     %else
     %if %upcase(&Email_Condition)=WARN %then
     %do;
        call symputx('ecnt',strip(wcnt));
        call symputx('eattach',warn_attach);
        call symputx('esubj',warn_subject);
        call symputx('etext',warn_email_text);
        call symputx('ebcccnt',wbcccnt);
        call symputx('eattachcnt',wattachcnt);

    %end;
    %else
    %if %upcase(&Email_Condition)=EMAILWARN %then
    %do;
       call symputx('ecnt',strip(ecnt));
       call symputx('eattach',emailerr_attach);
       call symputx('esubj',emailerr_subject);
       call symputx('etext',emailerr_email_text);
       call symputx('ebcccnt',ebcccnt);
       call symputx('eattachcnt',eattachcnt);

    %end;

    run;

    /* If notify_email_override is set by the job, override the notify_email value. */

    %if %superq(notify_email_override) ne %str() %then %let notify_email=&notify_email_override;

    /* If email subject is overriden by the job, override it. */

    %if %symexist(email_subject_override) and &Email_Condition=SUCCESS %then %let esubj=&email_subject_override;

    %let email_subject=&esubj;

    /* to_count is the number of "to" email addresses */

    %let to_count=%eval(%sysfunc(count(%trim(&notify_email),%str( ))))+1;

    /* email_global_from is set in the initialize macro */

    filename outbox email "&email_global_from";

    data _null_;

     file outbox from=("&email_global_from") subject= ("&esubj")

       /* notify_email should always receive an email*/

       to=(%do i=1 %to &to_count; "%scan(&notify_email,&i,%str( ))" %str( ) %end;)

       /* bcc (End Users) get email only when EmailTurnON is Y and Email_Condition eq SUCCESS and no notify_email_override */

       %if &EmailTurnON=Y and &Email_Condition=SUCCESS and %superq(notify_email_override)=%str() %then
       %do;

          %if %superq(ebcc) ne %str() %then
          %do;

          bcc=(%do i=1 %to &ebcccnt; "%scan(&ebcc,&i,^,m)" %str( ) %end;)

          %end;

       %end;

       %if &eattachcnt>0 %then
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

     %if &Email_Condition=SUCCESS %then
     %do;

        %if &sendZip=Y and &&zip_file_count&ii>0 %then
        %do;

           put "See attached &_reportName for &emaildate.";

        %end;
        %else
        %do;

           put "&_reportName for &emaildate completed successfully.";

        %end;

        put "<br />";
        put "<br />";

        %if %superq(DeliveryMethod) eq FTP %then
        %do;

              put "&_reportName for &emaildate is ready to FTP";
              put "<br /><br />";

        %end;

     %end;

     %do i=1 %to &ecnt;

        %let scanned=%scan(%superq(etext),&i,^,m);

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

     %if &Email_Condition=SUCCESS %then
     %do;

        %if %symexist(email_body_text) %then
        %do; /* Job has specified its own email body text */

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

        %end;/* Job has specified its own email body text */

     %end;

     put "<br />";
     put "<br />";

     %if &env ne prod %then
     %do;

        put "Environment: %upcase(&env)";
        put "<br />";
        put "Program: &pgmname";
        put "<br />";

     %end;

     /* Print the standard email footer text (set in the initialize macro): "Provided By: Analytics Services and Reporting ... " */

     %let more=1;

     %let i=0;

     %do %while(&more);

        %let i=%eval(&i+1);

        %let scanned=%scan(%superq(email_commontext),&i,^,m);

        %if %superq(scanned)=%str() %then %let more=0;

        %if &more %then
        %do;
           put "%superq(scanned)";
           put "<br />";
        %end;

     %end;

     put '</body>';
     put '</html>';

    run;

    %let send_email_rc=&syserr;

    %if &send_email_rc>4 %then %goto EXIT;

 %end;/* For each email to be sent */

%EXIT:

 filename outbox clear;

%put End macro send_email;
%mend send_email;