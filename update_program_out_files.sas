/**************************************************************************************************************
* Macro_Name:   update_program_out_files
*
* Purpose: This macro updates the rstats.program_out_files data set with each successful creation
*          of an out_xxx file. The data set records the program name, file name, process date and
*          other attributes.
*
* Usage: %update_program_out_files(file,extension,record_count)
*
* Input_parameters: file
*                    Name of the file
*                   extension
*                    File extension
*                   record_count
*                    Record count of the associated data set
*
* Outputs:  Updated rstats.program_out_files data set.
*
* Returns:   None
*
* Example:
*
* Modules_called: %lock_on_member
*                 %lock_off_member
*
* Maintenance_History:
*-------------------------------------------------------------------------------------------------------------*
*  Date:      |   Who:        |  Description:                                                                 *
*-------------------------------------------------------------------------------------------------------------*
* 08/23/2012  | Michael Gilman| Initial creation.                                                             *
* 09/21/2012  | Michael Gilman| Do a chmod 775 on rstats.program_out_files when newly created.                *
* 10/11/2012  | Michael Gilman| Fixed bug. When flat files are created by the program itself and not          *
*             |               | end_project_specifics, the record was not being set. This caused the          *
*             |               | record_count assignment statment to fail.                                     *
*-------------------------------------------------------------------------------------------------------------*
* HeaderEnd:                                                                                                  *
**************************************************************************************************************/

%macro update_program_out_files(file,extension,record_count);
%put Start macro update_program_out_files;

data program_out_files_temp;
 length pgmid $4 PgmName $80 File $200 Extension $20
        lob $50 security_level $2 SubjectArea $100
        FilePrefix $20 dt_prcs_data $6 rundate $10
        record_count 8
 ;
 pgmid="&pgmid";
 PgmName="&PgmName";
 File="&file";
 extension="&extension";
 lob="&lob";
 security_level="&security_level";
 SubjectArea="&SubjectArea";
 FilePrefix="&FilePrefix";
 dt_prcs_data="&dt_prcs_data";
 %if &record_count ne %str() %then %str(record_count=&record_count;);
 rundate="&rundate";
run;

%if %sysfunc(exist(rstats.program_out_files))=0 %then
%do;

   data rstats.program_out_files;
    set program_out_files_temp;
	  stop;
   run;

   systask command "chmod 775 %sysfunc(pathname(rstats))/program_out_files.sas7bdat";

%end;

%lock_on_member(rstats.program_out_files);

proc append base=rstats.program_out_files data=program_out_files_temp force;
run;

%lock_off_member(rstats.program_out_files);

%put End macro update_program_out_files;
%mend update_program_out_files;