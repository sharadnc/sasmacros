/**************************************************************************************************************
* Macro_Name:   add_project_specifics
*
* Purpose: Initialize key macro variables for the run. Set sas system options.
*          Create the SAS Rearchitecture directory structure
*          Assign the homelib libref to point to the directory where the dbpasswords data set is located.
*          Assign sas librefs to all directories.
*          Create commonly used date macro variables
*          Set the FilePrefix and LibDsnPrefix macro variables.
*          Set the fmtsearch path.
*          Insert a record into RSTATS.RUNTIMESTATS
*
* Usage: %add_project_specifics;
*
* Input_parameters: Several global macro variables set by the Initialize macro.
*                   Also, variables from Adminlib.ProgramSetup data set.
*                   dt_prcs_data
*                    For monthly programs, the end_date without the day component formatted as mmyy.
*                    For weekly programs, the end_date formatted as yymmdd.
*                    For daily programs, the end_date formatted as yymmdd.
*
* Outputs:  None.
*
* Returns:  If error, jumptoexit=1
*           pgmid
*           pgmfreq
*           lob
*           security_level
*           SubjectArea
*           _reportName
*           sendZip
*           notify_email
*           EmailTurnON
*           DeliveryMethod
*           zip_extension
*           use_var_labels_for_export
*           column_headers_in_export
*           FilePrefix
*            security_level!!pgmid!!_dt_prcs_data_
*           LibDsnPrefix
*            default value is saslib.
*
* Example:
*
* Modules_called: initialize
*                 set_directory_structure
*                 assign_libref
*                 check_error_and_zero_records
*                 create_date_parameters
*                 insert_new_record_runtimestats
*                 get_macro_system_options
*                 abort_program
*                 program_info
*                 lock_on_member
*                 lock_off_member
*                 validate_program
*
* Maintenance_History:
*-------------------------------------------------------------------------------------------------------------*
*  Date:      |   Who:        |  Description:                                                                 *
*-------------------------------------------------------------------------------------------------------------*
* 12/14/2011  | Sharad        | Initial creation.                                                             *
* 12/15/2011  | Michael Gilman| Modify Logic to add new parameters                                            *
* 04/23/2012  | Michael Gilman| Added logic to invoke %validate_program                                       *
* 04/26/2012  | Michael Gilman| Now ABORT if pgmname not found.                                               *
*             |               |                                                                               *
*             |               | Now print to Log pgmsetup settings.                                           *
*             |               |                                                                               *
*             |               | Now error if &unixdatadir and &unixrptdir don't already exist.                *
*             |               |                                                                               *
* 04/28/2012  | Michael Gilman| Replace all the former email variables in adminlib.programsetup with the      *
*             |               | new notify_email variable.                                                    *
*             |               |                                                                               *
* 05/01/2012  | Michael Gilman| Replace all %let jumptoexit; %goto EXIT with %abort_program.                  *
*             |               | This means that any error found in add_project_specifics causes an ABORT.     *
*             |               |                                                                               *
* 05/05/2012  | Michael Gilman| New logic copies rstats data sets to WORK and sets RSTATS libref to WORK when *
*             |               | running from EG.                                                              *
*             |               |                                                                               *
* 05/05/2012  | Michael Gilman| When running from EG, now have rstats point to homelib instead of WORK.       *
* 06/08/2011  | Michael Gilman| Now set errormsg macro variables for all error conditions.                    *
* 06/20/2011  | Michael Gilman| Removed invocation of %program_start_step. This is now called from            *
*             |               | check_restart_step.                                                           *
* 06/30/2011  | Michael Gilman| Removed the program info block that put key macro variables to log and        *
*             |               | replaced it with a call to macro program_info.                                *
* 07/10/2012  | Michael Gilman| Retrieve new variable from programsetup: column_headers_in_export.            *
* 07/14/2012  | Michael Gilman| Now assign libref dumplib to dump directory.                                  *
* 07/14/2012  | Michael Gilman| Assign new libref hist. Points to history data sets directory.                *
* 07/14/2012  | Michael Gilman| Create new macro variable history_libref_w which contains the libref name     *
*             |               | to use for the hist library when running from prod or not. When not           *
*             |               | running from prod, history_libref_w is set to dumplib, otherwise it's set     *
*             |               | to hist.                                                                      *
* 07/19/2012  | Michael Gilman| Now assign hist libref to SubjectArea.                                        *
* 07/22/2012  | Michael Gilman| Removed setting of Flag_EmailTurnON (not needed).                             *
* 09/07/2012  | Michael Gilman| Now assign libref history to be the same as libref hist.                      *
* 09/09/2012  | Michael Gilman| Now assign extract libref as a concatenation of:                              *
*             |               | &rootloc/extract/&security_level/&lob/&SubjectArea                            *
*             |               | /home/misbatch/cig_ebi/prod/cf/mnth/data                                      *
* 09/09/2012  | Michael Gilman| Now %chkerr after second read of adminlib.programsetup.                       *
* 09/11/2012  | Michael Gilman| Re-point extract libref to &rootloc/data/extracts (for now).                  *
* 09/18/2012  | Michael Gilman| Now point extract libref to concatenation of:                                 *
*             |               |    &rootloc/extract/&security_level                                           *
*             |               |    &rootloc/data/extracts (short cut to legacy location)                      *
* 09/21/2012  | Michael Gilman| Now point extract libref to concatenation of all security levels.             *
* 12/10/2012  | Michael Gilman| Now retrieve zip_extension value from programsetup.                           *
* 02/28/2013  | Sharad        | Add support to donotzip option.                                               *
*-------------------------------------------------------------------------------------------------------------*
* HeaderEnd:                                                                                                  *
**************************************************************************************************************/

%macro add_project_specifics/minoperator;
%put Start macro add_project_specifics;

 %local pgmfile i security_directories syserr_save;

 /*Initialize key macro variables for the run. Set sas system options. */

 %initialize;

 %set_directory_structure; /* Set the Rearchitecture directory structure */
 %if &jumptoexit %then %abort_program;

 /* Assign AdminLib libref */

 %assign_libref(adminlib,&unixadmindatadir.);
 %if &jumptoexit %then %abort_program;

 /* Check if program name is defined in adminlib.ProgramSetup */

 proc sql noprint;
 create table ___temp as
 select *
 from adminlib.ProgramSetup (where=(compress(upcase(PgmName))=compress(%upcase("&PgmName"))));
 quit;

 %chkerr(msg1=&syserrortext);
 %if &jumptoexit %then %abort_program;

 %check_error_and_zero_records(dsn=___temp,msg2=Program name &PgmName not found in adminlib.ProgramSetup);
 %if &jumptoexit %then
 %do;

    %let errormsg1=Program name &PgmName not found in adminlib.ProgramSetup.;

    %abort_program;

 %end;

 /* Assign homelib libref to where dbpasswords data set resides */

  %if %lowcase(&env) eq prod %then %let home=%lowcase(/home/&userid);
  %else %let home=%lowcase(/home/&exec_user.);

 libname homelib "&home";

 %if %lowcase(&env) ne prod and %lowcase(&env) ne uat and %lowcase(&env) ne ist %then
 %do; /* Check for existence of dbpasswords data set, but only if env ne uat or prod. */

    %if %sysfunc(libref(homelib))=0 %then
    %do; /* homelib libref successfully assigned */

       %if %sysfunc(exist(homelib.dbpasswords))=0 %then
       %do; /* dbpasswords does not exist */

          %let errormsg1=Data set dbpasswords does not exist in &home;

          %abort_program;

       %end;/* dbpasswords does not exist */

    %end;/* homelib libref successfully assigned */
    %else
    %do; /* homelib libref NOT successfully assigned */

         %let errormsg1=Expecting data set dbpasswords in &home;

         %abort_program;

    %end;/* homelib libref NOT successfully assigned */

 %end;/* Check for existence of dbpasswords data set, but only if env ne uat or prod. */

 /* Get settings for mprint, mlogic, mprintnest, mlogicnest symbolgen */
 /* We do this as we want to temporarily set them to off.             */

 %let macro_system_options=%get_macro_system_options;

 options nomprint nomlogic nosymbolgen nomprintnest nomlogicnest;

 /* Get attributes of the program from adminlib.ProgramSetup */

 proc sql noprint;
 select RecordActive, pgmid, pgmfreq, lob,
        security_level, SubjectArea, SendZip, notify_email, EmailTurnON,script_report_name,use_var_labels_for_export,
        column_headers_in_export,DeliveryMethod, compress(zip_extension)
  into :RecordActive,:pgmid, :pgmfreq, :lob,
       :security_level, :SubjectArea, :SendZip, : notify_email, : EmailTurnON, : _reportName, :use_var_labels_for_export,
       :column_headers_in_export,:DeliveryMethod, : zip_extension
 from ___temp;
 quit;

 %chkerr(msg1=&syserrortext);
 %if &jumptoexit %then %abort_program;

 /* Trim the macro vars */

 %let pgmid=%trim(%left(&pgmid));
 %let pgmfreq=%trim(%left(&pgmfreq));
 %let lob=%lowcase(%trim(%left(&lob)));
 %let security_level=%trim(%left(&security_level));
 %let SubjectArea=%trim(%left(&SubjectArea));
 %let SendZip=%trim(%left(&SendZip));
 %let notify_email=%trim(%left(&notify_email));
 %let DeliveryMethod=&DeliveryMethod;
 %let zip_extension=%lowcase(&zip_extension);

 %let SubjectArea=%sysfunc(lowcase(&SubjectArea));
 %let SubjectArea=%sysfunc(compress(&SubjectArea));
 %let lob=%sysfunc(lowcase(&lob));
 %let lob=%sysfunc(compress(&lob));

 %if &EmailTurnON=%str() %then %let EmailTurnON=N;

 %let column_headers_in_export=%upcase(&column_headers_in_export);

 %if &column_headers_in_export=%str() %then %let column_headers_in_export=Y;

 %let _reportName=&_reportName;

 /* Report name cannot be missing */

 %if %length(&_reportName) eq 0 %then
 %do;

    %let errormsg1=Report Name in adminlib.programsetup is missing.;

    %put ERROR: &errormsg1;

	  %abort_program;

 %end;

 %if &zip_extension=%str() %then
 %do;

    %let errormsg1=zip_extension is missing.;

    %put ERROR: &errormsg1;

	  %abort_program;

 %end;

 /* Print key information about the program parameters to the sas log. */

 %program_info(add_project_specifics);

 /* Reset settings for mprint, mlogic, mprintnest, mlogicnest symbolgen */

 options &macro_system_options;

 /* RecordActive flag must be Y */

 %if %upcase(&RecordActive) ne Y %then
 %do;

    %let errormsg1=The RecordActive flag is not set to Y for &PgmName;

    %put ERROR: &errormsg1;

	  %abort_program;

 %end;

 /* pgmid must be greater than zero. */

 %if %sysevalf(&pgmid<=0) %then
 %do;

    %let errormsg1=Invalid PgmID: &pgmid;

    %abort_program;

 %end;

 /* Security Level cannot be missing */

 %if &security_level=%str() %then
 %do;

    %let errormsg1=Security Level cannot be missing.;

    %abort_program;

 %end;

 /* lob cannot be missing */

 %if &lob=%str() %then
 %do;

    %let errormsg1=LOB cannot be missing.;

    %abort_program;

 %end;

 /* SubjectArea cannot be missing */

 %if &SubjectArea=%str() %then
 %do;

    %let errormsg1=Program Subject Area cannot be missing.;

    %abort_program;

 %end;

 /* PgmFreq cannot be missing */

 %if &PgmFreq=%str() %then
 %do;

    %let errormsg1=Program Frequency cannot be missing.;

    %abort_program;

 %end;

 /* PgmFreq must be one of Yearly Quarterly Monthly Weekly Daily Other */

 %if %eval(&PgmFreq in Yearly Quarterly Monthly Weekly Daily Other)=0 %then
 %do;

    %let errormsg1=Program Frequency cannot be &PgmFreq..;
    %let errormsg2=It must be Yearly Quarterly Monthly, Weekly, Daily, or Other.;

    %abort_program;

 %end;

 /* Data directory */

 %let unixdatadir=&unixrootloc/data/&security_level/&lob/&SubjectArea;

 /* Report directory */

 %let unixrptdir=&unixrootloc/reports/&security_level/&lob/&SubjectArea;

 /* Check for existence of Data directory */

 %if %sysfunc(fileexist(&unixdatadir))=0 %then
 %do;

    %let errormsg1=Directory does not exist: &unixdatadir;

    %abort_program;

 %end;

 /* Check for existence of Report directory */

 %if %sysfunc(fileexist(&unixrptdir))=0 %then
 %do;

    %let errormsg1=Directory does not exist: &unixrptdir;

    %abort_program;

 %end;

 /* Assign all required librefs */

 %assign_libref(portald,&unixportaldir);
 %if &jumptoexit %then %abort_program;

 %assign_libref(rstats,&unixrstatsdir);
 %if &jumptoexit %then %abort_program;

 %assign_libref(saslib,&unixdatadir);
 %if &jumptoexit %then %abort_program;

 %assign_libref(dmgcubes,&unixdmgcubesdir.);
 %if &jumptoexit %then %abort_program;

 %assign_libref(pgmmeta,&unixpgmmetadir.);
 %if &jumptoexit %then %abort_program;

 %assign_libref(fmtlib,&unixfmtdir.);
 %if &jumptoexit %then %abort_program;

 %assign_libref(promptd,&unixstppromptdatadir.);
 %if &jumptoexit %then %abort_program;

 %assign_libref(promptd,&unixstppromptdatadir.);
 %if &jumptoexit %then %abort_program;

 %assign_libref(dumplib,&unixdumpdir);
 %if &jumptoexit %then %abort_program;

 /* If history directory exists, assign libref to it */

 %if %sysfunc(fileexist(&rootloc/history/&security_level/&lob/&SubjectArea)) %then
 %do;

    %assign_libref(hist,&rootloc/history/&security_level/&lob/&SubjectArea);
    %if &jumptoexit %then %goto EXIT;

    /* Redundantly assign history libref as programs use either hist or history */

    libname history "%sysfunc(pathname(hist))";

 %end;

 /* The following that assigns the extract libref is currently not used. */

 %get_security_levels(&rootloc/extract);

 %let security_directories=;

 %do i=1 %to &number_of_security_levels;

    %let security_directories=&security_directories %sysfunc(quote(&rootloc/extract/&&security_levels&i));

 %end;

 libname extract (&security_directories "&rootloc/data/extracts");

 %if %sysfunc(libref(extract)) %then
 %do;

    %let errormsg1=Could not assign the extract libref;
    %let errormsg2=&syserrortext;

    %let jumptoexit=1;

    %goto EXIT;

 %end;

 /* Set the format search path */

 options fmtsearch = (fmtlib fmtlib.dmg_formats);

 /* Set various macro date variables to date values commonly needed by a job. The dt_prcs macro variable is used as input. */

 %create_date_parameters;
 %if &jumptoexit %then %abort_program;

 /* %validate_program performs 3 functions. It reads in the job and checks for too long sas data set names and checks       */
 /* that %STEP labels are in sequence and each followed by a check error macro. It also validates that each saslib.&out_xxx */
 /* occurrence in the job has a corresponding %let out_xxx=.                                                                */

 %if &useEG=0 %then
 %do;

    %let pgmfile=&rootloc/code/&pgmname..sas;

    %validate_program(&pgmfile);
    %if &jumptoexit %then %abort_program;

 %end;

 /* If running from EG we want to re-assign the rstat libref to the user's homelib directory.               */
 /* We do this as we don't want to write-accesss the rstats.runtimestats data sets which otherwise could be */
 /* held open (locked) by the user's EG program.                                                            */
 /* We do however want the EG program to handle potential restarts. We therefore need to ensure that        */
 /* program_restart_step data set resides in homelib. We also want the program_output_files data set.       */

 %if &useEG %then
 %do; /* EG only */

    %if %sysfunc(exist(homelib.program_output_files))=0 %then
	  %do;

       %lock_on_member(rstats.program_output_files);
	     %if &jumptoexit %then %abort_program;

       proc sql;
        create table homelib.program_output_files like rstats.program_output_files;
       quit;

       %let syserr_save=&syserr;

       %lock_off_member(rstats.program_output_files);
     %end;
     
     

    %if %sysfunc(exist(homelib.program_out_files))=0 %then
	  %do;

       %lock_on_member(rstats.program_out_files);
	     %if &jumptoexit %then %abort_program;

       proc sql;
        create table homelib.program_out_files like rstats.program_out_files;
       quit;

       %let syserr_save=&syserr;


       %lock_off_member(rstats.program_out_files);

       %chkerr(errCaptur=&syserr_save);
       %if &jumptoexit %then %abort_program;
	  %end;

     

    %if %sysfunc(exist(homelib.program_restart_step))=0 %then
	  %do;

       %lock_on_member(rstats.program_restart_step);
	     %if &jumptoexit %then %abort_program;

       proc sql;
        create table homelib.program_restart_step like rstats.program_restart_step;
       quit;

       %let syserr_save=&syserr;


       %lock_off_member(rstats.program_restart_step);

       %chkerr(errCaptur=&syserr_save);
       %if &jumptoexit %then %abort_program;

	  %end;

    %if %sysfunc(exist(homelib.next_runtimestats))=0 %then
	  %do;

       %lock_on_member(rstats.next_runtimestats);
	     %if &jumptoexit %then %abort_program;

       proc sql;
        create table homelib.next_runtimestats like rstats.next_runtimestats;
       quit;

       %let syserr_save=&syserr;


       %lock_off_member(rstats.next_runtimestats);

       %chkerr(errCaptur=&syserr_save);
       %if &jumptoexit %then %abort_program;

	  %end;

	  /* Re-assign rstats to the user's homelib.  */

	  libname rstats "%sysfunc(pathname(homelib))";

	  %if &program_start_step_EG ne %str() %then %let program_start_step=&program_start_step_EG;

 %end;/* EG only */

 /* Set the FilePrefix macro variable. FilePrefix is used as the prefix for all output data sets and file names. */

 %let FilePrefix=%unquote(%str(&security_level)%str(&pgmid)_&dt_prcs_data)_;

 %let FilePrefix=%sysfunc(lowcase(&FilePrefix));

 /* Set LibDsnPrefix to saslib.&FilePrefix */

 %let LibDsnPrefix=saslib.&FilePrefix;

%EXIT:

 options &macro_system_options;

 /* If not running from EG, then insert a new record into rstats.runtimestats */

 %if &useEG=0 %then %insert_new_record_runtimestats;

%put End macro add_project_specifics;
%mend add_project_specifics;