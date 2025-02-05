/**************************************************************************************************************
* Macro_Name:   set_directory_structure
*
* Purpose: This macro sets global macro variables that define the SAS Rearchitecture directories. It then ensures
*          that each of these directories exists.
*
* Usage: %set_directory_structure;
*
* Input_parameters: rootloc (global)
*                    SAS Rearchitecture Unix directory root location. This global macro variable is
*                    set by the autoexec.
*
* Outputs:  None.
*
* Returns:  Several global macro variables
*
* Example:
*
* Modules_called: check_dir_or_file_exists
*
* Maintenance_History:
*-------------------------------------------------------------------------------------------------------------*
*  Date:      |   Who:           |  Description:                                                              *
*-------------------------------------------------------------------------------------------------------------*
* 12/14/2011  | Sharad           | Initial creation.                                                          *
* 12/15/2011  | Michael Gilman   | Modify Logic to add new directories                                        *
* 09/07/2012  | Michael Gilman   | Removed assignment of unixextractdir.                                      *
*-------------------------------------------------------------------------------------------------------------*
* HeaderEnd:                                                                                                  *
**************************************************************************************************************/

%macro set_directory_structure;
%put Start macro set_directory_structure;

 /* sets global macro variables that define the SAS Rearchitecture directories. */
 /* NOTE: Please do not move this code location. These macro variables are used by subsequent macros. */

 %let unixrootloc = &rootloc.;
 %let unixcodedir = &unixrootloc./code;
 %let unixshldir = &unixrootloc./shl;
 %let unixfmtdir = &unixrootloc./formats;
 %let unixlogdir = &unixrootloc./log;
 %let unixmacrdir = &unixrootloc./macros;
 %let unixstpdir = &unixrootloc./stp;
 %let unixstpsasdir = &unixstpdir./code;
 %let unixstppromptdir = &unixstpdir./prompts;
 %let unixstppromptdatadir = &unixstpdir./promptdata;

 %let unixhistdir = &unixrootloc./history;
 %let unixdumpdir = &unixrootloc./dump;
 %let unixadmindir =&unixrootloc./admin;
 %let unixportaldir =&unixadmindir/portal/data;
 %let unixadmindatadir =&unixadmindir/data;
 %let unixrstatsdir =&unixrootloc./runtimestats;
 %let unixdmgcubesdir =&unixrootloc./cubes;
 %let unixmetadatadir =&unixrootloc./metadata;
 %let unixpgmmetadir =&unixmetadatadir./program;

 /*Check if Unix directories exist. */

 %let rc=%check_dir_or_file_exists(&unixrootloc.);
 %if &jumptoexit %then %goto EXIT;

 %let rc=%check_dir_or_file_exists(&unixcodedir.);
 %if &jumptoexit %then %goto EXIT;

 %let rc=%check_dir_or_file_exists(&unixshldir.);
 %if &jumptoexit %then %goto EXIT;

 %let rc=%check_dir_or_file_exists(&unixfmtdir.);
 %if &jumptoexit %then %goto EXIT;

 %let rc=%check_dir_or_file_exists(&unixlogdir.);
 %if &jumptoexit %then %goto EXIT;

 %let rc=%check_dir_or_file_exists(&unixmacrdir.);
 %if &jumptoexit %then %goto EXIT;

 %let rc=%check_dir_or_file_exists(&unixstpdir.);
 %if &jumptoexit %then %goto EXIT;

 %let rc=%check_dir_or_file_exists(&unixstpsasdir.);
 %if &jumptoexit %then %goto EXIT;

 %let rc=%check_dir_or_file_exists(&unixstppromptdir.);
 %if &jumptoexit %then %goto EXIT;

 %let rc=%check_dir_or_file_exists(&unixstppromptdatadir.);
 %if &jumptoexit %then %goto EXIT;

 %let rc=%check_dir_or_file_exists(&unixhistdir.);
 %if &jumptoexit %then %goto EXIT;

 %let rc=%check_dir_or_file_exists(&unixdumpdir.);
 %if &jumptoexit %then %goto EXIT;

 %let rc=%check_dir_or_file_exists(&unixportaldir.);
 %if &jumptoexit %then %goto EXIT;

 %let rc=%check_dir_or_file_exists(&unixadmindatadir.);
 %if &jumptoexit %then %goto EXIT;

 %let rc=%check_dir_or_file_exists(&unixrstatsdir.);
 %if &jumptoexit %then %goto EXIT;

 %let rc=%check_dir_or_file_exists(&unixdmgcubesdir.);
 %if &jumptoexit %then %goto EXIT;

 %let rc=%check_dir_or_file_exists(&unixmetadatadir.);
 %if &jumptoexit %then %goto EXIT;

 %let rc=%check_dir_or_file_exists(&unixpgmmetadir.);
 %if &jumptoexit %then %goto EXIT;

%EXIT:

%put End macro set_directory_structure;
%mend set_directory_structure;
