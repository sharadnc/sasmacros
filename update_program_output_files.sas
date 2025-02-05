/**************************************************************************************************************
* Macro_Name:   update_program_output_files
*
* Purpose: This macro updates the rstats.program_output_files data set with each successful creation
*          of an out_xxx associated data set. The data set records the program name, data set name, process date and
*          other attributes.
*
* Usage: %update_program_output_files(file,filetype,export_type)
*
* Input_parameters: file
*                    Name of the data set
*                   filetype
*                    Type of the file; normally DATASET
*                   export_type
*
* Outputs:  Updated rstats.program_output_files data set.
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
* 12/03/2012  | Michael Gilman| Initial creation.                                                             *
* 05/05/2012  | Michael Gilman| Renamed work.program_output_files to work.program_output_files_temp.          *
*-------------------------------------------------------------------------------------------------------------*
* HeaderEnd:                                                                                                  *
**************************************************************************************************************/

%macro update_program_output_files(file,filetype,export_type);
%put Start macro update_program_output_files;

data program_output_files_temp;
 length pgmid $4 PgmName $80 File $200 Filetype $20
        lob $50 security_level $2 SubjectArea $100
        FilePrefix $20 dt_prcs_data $6 export_type $8
 ;
 pgmid="&pgmid";
 PgmName="&PgmName";
 File="&file";
 Filetype="&filetype";
 lob="&lob";
 security_level="&security_level";
 SubjectArea="&SubjectArea";
 FilePrefix="&FilePrefix";
 dt_prcs_data="&dt_prcs_data";
 export_type="&export_type";
run;

%if %sysfunc(exist(rstats.program_output_files))=0 %then
%do;

   data rstats.program_output_files;
    set program_output_files_temp;
	stop;
   run;

%end;

%lock_on_member(rstats.program_output_files);

proc sql;
 delete from rstats.program_output_files
 where PgmName="&PgmName" and File="&file" ;
quit;

proc append base=rstats.program_output_files data=program_output_files_temp force;
run;

%lock_off_member(rstats.program_output_files);

%put End macro update_program_output_files;
%mend update_program_output_files;