/**************************************************************************************************************
* Macro_Name:   record_check_export_encrypt
*
* Purpose: This macro exports and encrypts a sas data set. It also returns the number of records in the data set.
*
* Usage: %record_check_export_encrypt
*
* Input_parameters: None
*
* Outputs:  outfile
*            Exported file
*
* Returns:   recs
*             Number of records in the data set
*
* Example:
*
* Modules_called: %change_permissions
*                 %export_to_dlm_file
*                 %chkerr
*                 %encrypt_file
*                 %update_program_output_files
*                 %update_program_out_files
*                 %get_outfile_attrs
*                 %lock_on_member
*                 %lock_off_member
*
* Maintenance_History:
*-------------------------------------------------------------------------------------------------------------*
*  Date:      |   Who:        |  Description:                                                                 *
*-------------------------------------------------------------------------------------------------------------*
* 12/14/2011  | Sharad           | Initial creation.                                                          *
* 12/14/2011  | Michael Gilman   | Initial creation.                                                          *
* 06/30/2012  | Michael Gilman   | Now check for output type sas (out_sas). If present, don't create a zip.   *
* 07/10/2012  | Michael Gilman   | Removed column_headers parameter from call to %export_to_dlm_file.         *
* 07/10/2012  | Michael Gilman   | Now check if out_rename values are set. If so, use that name for the export*
* 08/01/2012  | Michael Gilman   | Now set the reccnt&i global variables in this macro (used by %send_mail).  *
* 08/23/2012  | Michael Gilman   | Now invoke macro update_program_out_files which adds records to            *
*             |                  | rstats.program_out_files containing the name of the out_ files created by  *
*             |                  | a program.                                                                 *
* 08/28/2012  | Michael Gilman   | Now support html export type.                                              *
* 09/19/2012  | Michael Gilman   | Now check if the data set named by the out_xxx exists. If not, we assume   *
*             |                  | an output file has been created by the main program itself. In this case,  *
*             |                  | we just change permissions and encrypt/zip the file.                       *
* 09/21/2012  | Michael Gilman   | Now check if data set doesn't exist, check if it exists in the extract     *
*             |                  | library.                                                                   *
* 10/03/2012  | Michael Gilman   | Now check for export_type=rtf.                                             *
* 10/10/2012  | Michael Gilman   | Fixed bug when out_sas and out_xxx specified the same file name. Now       *
*             |                  | check if the outfile already exists in the report directory and, if so,    *
*             |                  | go straight to PROCESS_FILES.                                              *
* 10/24/2012  | Michael Gilman   | Fixed bug. Record count was not being obtained when flat file already      *
*             |                  | existed. Moved the logic that checks for the existence of the flat file    *
*             |                  | after the record count is obtained.                                        *
* 11/28/2012  | Michael Gilman   | Changed:                                                                   *
*             |                  |   %if &jumptoexit %then %let step_at_program_end=1;                        *
*             |                  | To:                                                                        *
*             |                  |   %if &jumptoexit %then %let end_project_specifics_error=1;                *
* 11/28/2012  | Michael Gilman   | Now handle zipsas export type.                                             *
* 12/06/2012  | Michael Gilman   | Fixed bug when out_rename is used with out_zipsas.                         *
* 12/10/2012  | Michael Gilman   | Now use &zip_extension instead of hard-coded "zip".                        *
*-------------------------------------------------------------------------------------------------------------*
* HeaderEnd:                                                                                                  *
**************************************************************************************************************/

%macro record_check_export_encrypt;
%put Start macro record_check_export_encrypt;

 %local dsid i useOutfile file;

 /* rstats.program_out_files contains the names of the final output sas data sets that jobs create. */

 %if %sysfunc(exist(rstats.program_out_files)) %then
 %do; /* Delete occurrences of the records that may already exist from prior runs */

    %lock_on_member(rstats.program_out_files);

    proc sql;
     delete from rstats.program_out_files
     where PgmName="&PgmName" and dt_prcs_data="&dt_prcs_data";
    quit;

    %lock_off_member(rstats.program_out_files);

 %end;/* Delete occurrences of the records that may already exist from prior runs */

 /* Process each out_ specified by the job                           */
 /* number_of_output_files is determined by the %set_outfiles macro. */

 %do i=1 %to &number_of_output_files;

    /* Get the attributes of the out_ specification which include:           */
    /* outfile: name of the output file                                      */
    /* export_type: txt,csv,tab,sas,xls,dat,rtf,html,zipsas                  */
    /* extension: txt,csv,xls,dat,html,sas7bdat                              */
    /* outfile_rename: Optionally the name to use for the output file.       */

    %get_outfile_attrs(&i);

    %if %superq(outfile)=%str() %then %goto EXIT;

    /* Use outfile_rename for the file name if specified, otherwise use outfile */

    %if %superq(outfile_rename) ne %str() %then %let useOutfile=%lowcase(&outfile_rename);
    %else %let useOutfile=%lowcase(&outfile);

    /* The final data set is always created in the saslib library, with the exception of extract data sets. */
    /* We therefore first check if the data set is indeed in saslib and, if not, we check to see if it is   */
    /* in the extract libary.                                                                               */

    %let lib=saslib;

    %let dsnpath=%sysfunc(pathname(saslib));

    %let dsn=%upcase(%superq(outfile));

    %if %sysfunc(exist(&lib..&dsn))=0 %then
    %do;

       %let lib=extract;

       %if %sysfunc(exist(&lib..&dsn))=0 %then
       %do;

          %let reccnt&i=.;

          %goto PROCESS_FILES;

       %end;

       %let dsnpath=&rootloc/extract/&security_level;

    %end;

    %let dsid=%sysfunc(open(&lib..&dsn));

    %if &dsid<=0 %then
    %do;

       %let errormsg1=Could not open data set &lib..&dsn;

       %let jumptoexit=1;

       %goto EXIT;

    %end;

    /* Get the number of records in the final data set. */

    %let reccnt&i=%sysfunc(attrn(&dsid,nlobs));

    %let dsid=%sysfunc(close(&dsid));

    /* Update rstats.program_out_files with the final data set name */

    %update_program_output_files(%lowcase(&dsn),DATASET,&export_type);

    /* Change permissions of the final data set name to 775 */

    %change_permissions(%superq(dsnpath),%lowcase(&dsn..sas7bdat));
    %if &jumptoexit %then %goto EXIT;

    /* We're done if the final data set is out_sas */

    %if &export_type=sas %then %goto NEXT;

    /* zipsas is a special type intended to handle programs that want to zip a final sas data set */

    %if &export_type=zipsas %then
    %do; /* zipsas */

       /* zip/encrypt the data set */

       %encrypt_file(%superq(unixdatadir),%lowcase(%superq(outfile)),sas7bdat);
       %if &jumptoexit %then %goto EXIT;

       /* Move the zip file from the data to reports directory */

       %let command=mv %superq(unixdatadir)/%lowcase(%superq(outfile)).&zip_extension %superq(unixrptdir);

       %let command=%sysfunc(quote(&command));

       systask command &command wait taskname=moveit status=move;

       waitfor moveit;

       %if &move ne 0 %then
       %do;

          %let errormsg1=Could not move file %superq(unixdatadir)/%lowcase(%superq(outfile).&zip_extension to %superq(unixrptdir);

          %let jumptoexit=1;

          %goto EXIT;

       %end;

       %if &outfile_rename ne %str() %then
       %do; /* If out_rename is specified for the file, rename it accordingly */

          %let command=mv %superq(unixrptdir)/%lowcase(%superq(outfile)).&zip_extension %superq(unixrptdir)/%lowcase(%superq(useOutfile)).&zip_extension;

          %let command=%sysfunc(quote(&command));

          systask command &command wait taskname=moveit2 status=move;

          waitfor moveit2;

          %if &move ne 0 %then
          %do;

             %let errormsg1=Could not rename file %superq(unixrptdir)/%lowcase(%superq(outfile).&zip_extension to %superq(unixrptdir)/%lowcase(%superq(useOutfile)).&zip_extension;

             %let jumptoexit=1;

             %goto EXIT;

          %end;

       %end;/* If out_rename is specified for the file, rename it accordingly */

       %goto PROCESS_FILES2;

    %end;/* zipsas */

    /* The macro at this point usually creates the csv, txt, etc. file using the final output sas data set.  */
    /* However, the job may have already created the file itself. We therefore check for its existence here. */
    /* If it does exist, we jump to changing permissions and zipping/encrypting the file.                    */

    %if %sysfunc(fileexist(%superq(unixrptdir)/&useOutfile..&extension)) %then %goto PROCESS_FILES;

    %if &export_type=rtf %then
    %do; /* out_rtf */

       %goto PROCESS_FILES;

    %end;/* out_rtf */
    %else %if &export_type=html %then
    %do; /* out_html */

       %minimize_character_variables(saslib.&dsn);

       ods html file="%superq(unixrptdir)/%lowcase(%superq(useOutfile)).html"  frame="%superq(unixrptdir)/%lowcase(%superq(useOutfile))_frame.html"
                contents="%superq(unixrptdir)/%lowcase(%superq(useOutfile))_contents.html" style=styles.analysis;

       proc print data=saslib.&dsn noobs label;
       run;

       ods html close;

    %end;/* out_html */
    %else %if &export_type=xls %then
    %do; /* out_xls */

       %minimize_character_variables(saslib.&dsn);

       ods tagsets.excelxp file="%superq(unixrptdir)/%lowcase(%superq(useOutfile)).xls"  STYLE=PRINTER;
       ods tagsets.excelxp options(embedded_titles="yes" SHEET_INTERVAL='NONE' SHEET_NAME="&dsn");

       proc print data=saslib.&dsn noobs label;
       run;

       ods tagsets.excelxp close;

    %end;/* out_xls */
    %else
    %do; /* Export data to delimited file */

       %export_to_dlm_file(&lib..&dsn,
                           %superq(unixrptdir)/%lowcase(%superq(useOutfile)).&extension,
                           &export_type
                          );

    %end;/* Export data to delimited file */

    %chkerr(errCaptur=&syserr,msg1=Export %lowcase(%superq(useOutfile)).&extension Failed,msg2=%superq(syserrortext));
    %if &jumptoexit %then %goto EXIT;

%PROCESS_FILES:

    /* Change permissions of the file to 775 */

    %change_permissions(%superq(unixrptdir),%lowcase(%superq(useOutfile)).&extension);
    %if &jumptoexit %then %goto EXIT;

    /* Zip/encrypt the file */

    %encrypt_file(%superq(unixrptdir),%lowcase(%superq(useOutfile)),&extension);
    %if &jumptoexit %then %goto EXIT;

%PROCESS_FILES2:

    /* Insert a record with the file name into rstats.program_out_files */

    %update_program_out_files(%lowcase(%superq(useOutfile)),&extension,&&reccnt&i);

%NEXT:

 %end;

%EXIT:

 /* The end_project_specifics_error macro var keeps track if there's an error in */
 /* any macro called by %end_project_specifics.                                  */

 %if &jumptoexit %then %let end_project_specifics_error=1;

%put End macro record_check_export_encrypt;
%mend record_check_export_encrypt;