/**************************************************************************************************************
* Macro_Name:   check_restart_step
*
* Purpose: 1. Check if user has specified a %let split_xxx. If so, check that there is only 1 final output file specified.
*          2. Set number_of_output_files macro variable which is the number of %let out_xxx= specifications.
*          3. Check that the length of all user-specified out_xxx files are not greater than 32 characters in length.
*          4. Invokes %%set_outfiles which sets an _out_file&i global macro value for each out_xxx specified by the user.
*             The _out_file&i macro values are suffixed with the out_xxx type.
*          5. Determine the restart step.
*          6. Delete all files and data sets that may have been created from a previous run.
*
* Usage: %check_restart_step;
*
* Input_parameters: program_start_step (global)
*                    Optional programmer-specified override of step to start at.
*                   security_level (global)
*                   pgmname (global)
*                   pgmid (global)
*                   dt_prcs_data (global)
*                   dt_prcs (global)
*
* Outputs:  None.
*
* Returns:  number_of_output_files
*            Number of %let out_xxx= specifications
*           step_count (global)
*            Internal macro variable used to keep track of the steps
*           gotostep (global)
*            Step label to go to
*           notify_email if notify_email_override is not missing
*           If error, jumptoexit=1
*
* Example:
*
* Modules_called: chk_outfile_length
*                 goto_program_step
*                 program_start_step
*                 program_info
*                 set_outfiles
*
* Maintenance_History:
*-------------------------------------------------------------------------------------------------------------*
*  Date:      |   Who:        |  Description:                                                                 *
*-------------------------------------------------------------------------------------------------------------*
* 05/25/2012  | Sharad        | Initial creation.                                                             *
* 06/20/2012  | Michael Gilman| Now invoke %program_start_step if &program_start_step is missing.             *
* 06/22/2012  | Michael Gilman| Now, when step is STEP01, delete all saslib data sets with prefix:            *
*             |               | str(&security_level&pgmid)_%str(&dt_prcs_data)_:                              *
* 06/22/2012  | Michael Gilman| Now invoke macro chk_outfile_length.                                          *
* 06/22/2012  | Michael Gilman| Now print to log important macro values.                                      *
* 06/22/2012  | Michael Gilman| If notify_email_override not missing, set notify_email to it.                 *
* 06/30/2012  | Michael Gilman| Removed the program info block that put key macro variables to log and        *
*             |               | replaced it with a call to macro program_info.                                *
* 07/27/2012  | Michael Gilman| Now call %set_outfiles which determines number of out_xxx files set by        *
*             |               | the user and also creates the corresponding _out_files macro variables.       *
* 08/02/2012  | Michael Gilman| Now use global variable FilePrefix instead of calculating it when deleting    *
*             |               | existing saslib data sets.                                                    *
* 08/15/2012  | Michael Gilman| Now check for split_xxx values and, if present, check that only one out_      *
*             |               | parameter is specified.                                                       *
* 08/16/2012  | Michael Gilman| Now check for pre-existence of out_ files and delete them and related zip     *
*             |               | files if they exist.                                                          *
* 08/17/2012  | Michael Gilman| Now create new global macro variables: out_path_datan and out_path_rptn       *
*             |               | where n is an integer. The out_path variables contain the full pathname of    *
*             |               | the out_ files. For the out_path_datan variables, they are the concatenation  *
*             |               | of &unixdatadir with the &out_ value. For the out_path_rptn variables, they   *
*             |               | the concatenation of &unixrptdir with the &out_ value.                        *
* 09/20/2012  | Michael Gilman| Fixed small bug: When gotostep is STEP01, data sets were not being deleted.   *
* 10/11/2012  | Michael Gilman| Fixed bug caused by the fact at we now allow a pgm to create it's own out file.*
*             |               | This macro deletes all the flat files named by the out_ parameters even when  *
*             |               | a pgm is restarted. If a pgm is restarted beyond the step where the pgm       *
*             |               | creates the flat file, the pgm bombs as the file does not exist.              *
*             |               | We changed the macro so that the flat files are deleted only when the pgm     *
*             |               | starts at STEP01.                                                             *
* 12/10/2012  | Michael Gilman| Now use &zip_extension instead of hard-coded "zip".                           *
* 12/18/2012  | Michael Gilman| Completely changed how we delete pre-existing data sets and files. We now     *
*             |               | use a simpler method to detect all data sets and files having the current     *
*             |               | FilePrefix.                                                                   *
* 02/28/2013  | Sharad        | Add support to donotzip option.                                               *
*-------------------------------------------------------------------------------------------------------------*
* HeaderEnd:                                                                                                  *
**************************************************************************************************************/

%macro check_restart_step;
%put Start macro check_restart_step;

 %local prefix string dt_prcsc i split_found split_extension split_chklen
        useOutfile outfile_rename
        dsid file
 ;

 %let number_of_output_files=%set_outfiles;

 /* Check if user has specified a %let split_xxx. If so, check that there is only 1 final output file specified */

 %let split_found=0;

 %do i=1 %to &number_of_output_files;

    %get_outfile_attrs(&i);

    %if &export_type=split %then
    %do;

       %let split_found=1;

       %let split_extension=&extension;

       %let split_outfile=&outfile;

       %let split_outfile_length=%length(&outfile);

    %end;

 %end;

 %if &split_found %then
 %do; /* %let split_xxx found */

    %if &number_of_output_files>1 %then
    %do;

       %let errormsg1=Cannot have more than one out file when specifying split_&split_extension;

       %let jumptoexit=1;

       %goto ERREXIT;

    %end;

    %if %lowcase(&pgmfreq)=monthly %then %let split_chklen=19;
    %else %let split_chklen=17;

    %if &split_outfile_length>32 %then
    %do;

       %let errormsg1=When splitting an output file, the name cannot exceed &split_chklen characters.;

       %let jumptoexit=1;

       %goto ERREXIT;

    %end;

 %end;/* %let split_xxx found */

 /* Check that the length of all user-specified out_xxx files are not greater than 32 characters in length. */

 %chk_outfile_length;
 %if &jumptoexit %then %goto ERREXIT;

 /* Check if job has overriden who email should be sent to. */

 %if &notify_email_override ne %str() %then %let notify_email=&notify_email_override;

 %if &program_start_step ne %str() %then
 %do; /* If program_start_step is hard-coded specified by the job, then get the start step */

    %goto_program_step(&program_start_step);
    %if &jumptoexit %then %goto ERREXIT;

    %put;
    %put NOTE: Programmer override starting program from &gotoStep;
    %put;

    %goto NEXT;

 %end;/* If program_start_step is specified by the job, then get the start step */

 /* Get the job start step from rstats.program_restart_step */

 %program_start_step(&pgmName);

%NEXT:

 /* Print program attributes to the log */

 %program_info(check_restart_step);

 /* Set out_path_data&i and out_path_rpt&i for convenience potential use by a job. */

 %do i=1 %to &number_of_output_files;

    /* Get the attributes of the out_ specification which include:           */
    /* outfile: name of the output file                                      */
    /* export_type: txt,csv,tab,sas,xls,dat,rtf,html,zipsas                  */
    /* extension: txt,csv,xls,dat,html,sas7bdat                              */
    /* outfile_rename: Optionally the name to use for the output file.       */

    %get_outfile_attrs(&i);

    %global out_path_data&i out_path_rpt&i;

    %let out_path_data&i=%superq(unixdatadir)/%superq(outfile);

    /* If out_rename specified for a file, then use the rename name for the flat files */

    %if %superq(outfile_rename) ne %str() %then %let useOutfile=&outfile_rename;
    %else %let useOutfile=&outfile;

    %let out_path_rpt&i=%superq(unixrptdir)/%superq(useOutfile);

 %end;

 %if &gotoStep ne STEP01 %then %goto EXIT;

 /* Job is starting from STEP 1 so delete all files and data sets that may have been created from a previous run */

 /* First delete the sas data sets */

 %files_in_dir_with_search(dir=&unixdatadir,
                           subDirectories=no,
                           outputDataset=temp,
                           searchForFilename=%str(&FilePrefix)*.sas7bdat
                          );

 %if &filesFound>0 %then
 %do;

    %let all_files=;

    %let dsid=%sysfunc(open(temp));

    %do %while(%sysfunc(fetch(&dsid)) ne -1 );

       %let filename=%sysfunc(getvarc(&dsid,%sysfunc(varnum(&dsid,filename))));

       %let file=%scan(%superq(filename),1,%str(.));

       %let all_files=&all_files &file;

    %end;

    %let dsid=%sysfunc(close(&dsid));

    proc datasets lib=saslib nolist nowarn;
    delete &all_files;
    quit;

 %end;


%EXIT:

 /* Now delete the flat files and associate zips. */

 %files_in_dir_with_search(dir=&unixrptdir,
                           subDirectories=no,
                           outputDataset=temp,
                           searchForFilename=%str(&FilePrefix)*.*
                          );

 %if &filesFound>0 %then
 %do;

    %let dsid=%sysfunc(open(temp));

    %do %while(%sysfunc(fetch(&dsid)) ne -1 );

       %let filename=%sysfunc(getvarc(&dsid,%sysfunc(varnum(&dsid,filename))));

			 %delete_file(&unixrptdir.,&filename.);
				
  %end;

  %let dsid=%sysfunc(close(&dsid));

 %end;

  /* There may be files that were renamed with %let out_rename. These files do not necessarily have the FilePrefix. */
  /* Therefore, we have to get the names from rstats.program_out_files.                                             */

 %lock_on_member(rstats.program_out_files);

 proc sql;
  create table temp as
  select file, extension
  from rstats.program_out_files
  where pgmid="&pgmid" and dt_prcs_data="&dt_prcs_data"
  ;
 quit;

 %lock_off_member(rstats.program_out_files);

 %if &sqlobs>0 %then
 %do;

    %let dsid=%sysfunc(open(temp));

    %do %while(%sysfunc(fetch(&dsid)) ne -1 );

       %let file=%sysfunc(getvarc(&dsid,1));

       %let extension=%sysfunc(getvarc(&dsid,2));

				%delete_file(&unixrptdir.,&file..&extension);
				
				%if &zip_extension ne donotzip %then
				%do;
					
					%delete_file(&unixrptdir.,&file..&zip_extension);
					
					%delete_file(&unixrptdir.,&file..&extension..&zip_extension);
				%end;	

  	%end;
  	
  	%let dsid=%sysfunc(close(&dsid));

 %end;
 
  %do i=1 %to &number_of_output_files;
  	
   %let delete_flag=0; /*reset delete_flag*/

   %if %symexist(out_txt&i)    and %symexist(out_rename&i) %then %do; %let outfile=%lowcase(&&out_rename&i...txt); %let delete_flag=1; %end;
   %else %if %symexist(out_csv&i)    and %symexist(out_rename&i) %then %do; %let outfile=%lowcase(&&out_rename&i...csv); %let delete_flag=1; %end;
   %else %if %symexist(out_tab&i)    and %symexist(out_rename&i) %then %do; %let outfile=%lowcase(&&out_rename&i...tab); %let delete_flag=1; %end;
   %else %if %symexist(out_xls&i)    and %symexist(out_rename&i) %then %do; %let outfile=%lowcase(&&out_rename&i...xls); %let delete_flag=1; %end;
   %else %if %symexist(out_dat&i)    and %symexist(out_rename&i) %then %do; %let outfile=%lowcase(&&out_rename&i...dat); %let delete_flag=1; %end;
   %else %if %symexist(out_html&i)   and %symexist(out_rename&i) %then %do; %let outfile=%lowcase(&&out_rename&i...html); %let delete_flag=1; %end;
   %else %if %symexist(out_rtf&i)    and %symexist(out_rename&i) %then %do; %let outfile=%lowcase(&&out_rename&i...rtf); %let delete_flag=1; %end;
   %else %if %symexist(out_zipsas&i) and %symexist(out_rename&i) %then %do; %let outfile=%lowcase(&&out_rename&i...zipsas); %let delete_flag=1; %end;

		%if &delete_flag %then
		%do;
				%delete_file(&unixrptdir.,&outfile.);
				
				%if &zip_extension ne donotzip %then
				%do;
				
						%delete_file(&unixrptdir.,&&out_rename&i...&zip_extension);
						
						%delete_file(&unixrptdir.,&outfile..&zip_extension);
				 %end;		
		%end;
	
  %end;
 
%ERREXIT:

%put End macro check_restart_step;
%mend check_restart_step;