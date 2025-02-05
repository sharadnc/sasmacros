/**************************************************************************************************************
* Macro_Name:   initialize
*
* Purpose: Initialize key global macro variables for the run. Set sas system options.
*
* Usage: %initialize;
*
* Input_parameters: The following key macro variables are set. When run from batch, Unix Shell environment
*                   variables are used as the source and the values are set in the autoexec.
*                   When run from EG, EG set macro variables are used.
*                   env
*                    labs/dev/qa/uat/prod
*                   rootloc
*                    Unix directory root location of the project
*                   pgm
*                    Program name of the program to run
*                   dt_prcs
*                    The process date in the form mm/dd/yyyy. Note that if this missing, today's date is ultimately used.
*                   logfile
*                    Location of sas log file
*
* Outputs:  None.
*
* Returns:  Various global macro values
*
* Example:
*
* Modules_called: create_global_variables
*                 set_sas_system_options
*
* Maintenance_History:
*---------------------------------------------------------------------------------------------------------------------------------*
*  Date:      |   Who:           |  Description:                                                                                  *
*---------------------------------------------------------------------------------------------------------------------------------*
* 12/14/2011  | Sharad           | Initial creation.                                                                              *
* 12/15/2011  | Michael Gilman   | Modify Logic to add new parameters                                                             *
* 04/28/2012  | Michael Gilman   | Initialize mail_global_from=cig_sasanalytics@sharadnc.net.                                        *
* 05/05/2012  | Michael Gilman   | Initialize program_start_step from program_start_step_EG when run from EG.                     *
* 06/20/2012  | Michael Gilman   | Initialize macro variable program_start_step to missing.                                       *
* 08/18/2012  | Sharad           | Replace cig_sasanalytics@sharadnc.net to cig.sas.analytics.support@sharadnc.com                   *
* 08/23/2012  | Michael Gilman   | Now set title1 and footnote1 to blank.                                                         *
* 09/10/2012  | Michael Gilman   | Now set legacy_extract_directory=/home/misbatch/cig_ebi/prod/cf/mnth/data                      *
* 09/10/2012  | Michael Gilman   | Now suppress redirect_log_to macro                                                             *
* 09/11/2012  | Sharad           | Now set legacy_extract_directory=/u04/data/cig_ebi/dmg/uat/dump                                *
* 09/17/2012  | Michael Gilman   | New setting: attach_filesize_max=5000000                                                       *
* 12/07/2012  | Michael Gilman   | New setting: split_records_default=1000000                                                     *
* 04/09/2013  | Soma Sekhar      | Replace cig.sas.analytics.support@sharadnc.com to dabi.production.support@sharadnc.net * 
*---------------------------------------------------------------------------------------------------------------------------------*
* HeaderEnd:                                                                                                                      *
**********************************************************************************************************************************/

%macro initialize;
%put Start macro initialize;

 %create_global_variables;    /* Create all the required global variables */

 %let StartTime=%sysfunc(datetime(),datetime23.);

 %let program_start_step=; /*Initialize the value*/

 %if %symexist(_CLIENTPROJECTNAME) %then
 %do; /* Running from EG */

    %let useEG=1;
    %let env=&env_EG;
    %let rootloc=&rootloc_EG;
    %let PgmName=&PgmName_EG;
    %let dt_prcs=&dt_prcs_EG;
    %let logfile=;

	  %if %symexist(program_start_step_EG) %then %let program_start_step=&program_start_step_EG;

    %let userid=%scan(%sysget(METAUSER),1,'@'); /* for use on Windows and Unix workspace servers */


    %if %symexist(debug_EG) %then %let debug=&debug_EG;
		%else %let debug=N;

 %end;/* Running from EG */

 %set_sas_system_options;     /* Set the sas system options for the job */
 
 %let Flag_Email=SUCCESS;     /* Assume program will be successful for emailing purposes */

 %let jumptoexit=0;  /* Assume program will be successful  */

 %let step_count=0;  /* Is incremented upon successful completion of each STEP */

 %let outputLibref=WORK; /* Default output libef */

 %let program_start_step_EG=; /*Initialize the value*/

 %if %superq(logfile) ne %str() %then; /*%redirect_log_to(&logfile,n); */
 %else %let logfile=Log produced in SAS EG;

 %put;
 %put NOTE: Program execution started at &StartTime with SYSJOBID=&sysjobid;
 %put NOTE: env=&env rootloc=&rootloc logfile=&logfile debug=&debug;
 %put NOTE: %sysfunc(getoption(WORK,keyword));
 %put NOTE: userid=&userid;
 %put;

 %let email_commontext=Provided By:^Digital Analytics and Business Insights Group^Note: This is an automatically generated email.^If you have
 any questions please email dabi.production.support@sharadnc.net;

 %let email_commontext=%sysfunc(compbl(&email_commontext));

 %let email_global_from=dabi.production.support@sharadnc.net;

 %let attach_filesize_max=10000000; /* Maximum size for zip files */

 /* Number of records to split a final data set by when split_xxx is specified */

 %let split_records_default=1000000;

 title1;

 footnote1;

%put End macro initialize;
%mend initialize;