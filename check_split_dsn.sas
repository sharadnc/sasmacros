/**************************************************************************************************************
* Macro_Name:   check_split_dsn
*
* Purpose: Check if job has a %let split_xxx specification. If so, split the data set according to the
*          value of the split_records_default macro variable which is set in %initialize.
*          The actual splitting is done by %split_dsn_by_obs.
*          IMPORTANT: Only one split_xxx can be specified in a job. Moreover, it must be the last out_xxx/split_xxx specified.
*
* Usage: %check_split_dsn;
*
* Input_parameters:
*
* Outputs:  Split data set.
*
* Returns: number_of_output_files
*           This macro variable is originally set by the %check_restart_step macro. However, splitting a
*           data set will increase the number of output files.
*
* Example:
*
* Modules_called: get_outfile_attrs
*                 split_dsn_by_obs
*
* Maintenance_History:
*-------------------------------------------------------------------------------------------------------------*
*  Date:      |   Who:           |  Description:                                                              *
*-------------------------------------------------------------------------------------------------------------*
* 08/10/2012  | Michael Gilman   | Initial creation.                                                          *
*-------------------------------------------------------------------------------------------------------------*
* HeaderEnd:                                                                                                  *
**************************************************************************************************************/
%macro check_split_dsn;
%put Start macro check_split_dsn;

 %global number_of_split_datasets;

 %let number_of_split_datasets=0;

 %let total_number_of_split_datasets=0;

 %do i=1 %to &number_of_output_files;

    %get_outfile_attrs(&i);

    %if &export_type ne split %then %goto NEXT;

    %let export_type=&extension;

    %split_dsn_by_obs(dsn=&outfile,split_dsn=,split_records=&split_records_default,outfile_type=&export_type);

    %let total_number_of_split_datasets=%eval(&total_number_of_split_datasets+&number_of_split_datasets);

%NEXT:

 %end;

 %if &total_number_of_split_datasets>0 %then %let number_of_output_files=&total_number_of_split_datasets;

%put End macro check_split_dsn;
%mend check_split_dsn;