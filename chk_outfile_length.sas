/**************************************************************************************************************
* Macro_Name:   chk_outfile_length
*
* Purpose: This macro checks that the length of all user-specified out_xxx files are not greater than 32 characters in length.
*
* Usage: %chk_outfile_length;
*
* Input_parameters: number_of_output_files (global)
*
* Outputs:  None.
*
* Returns:  If error, jumptoexit=1
*
* Example:
*
* Modules_called: get_outfile_attrs
*
* Maintenance_History:
*-------------------------------------------------------------------------------------------------------------*
*  Date:      |   Who:        |  Description:                                                                 *
*-------------------------------------------------------------------------------------------------------------*
* 21/02/2012  | Michael Gilman   | Initial creation.                                                          *
* 06/30/2012  | Michael Gilman   | Added new output type to check: sas (out_sas&p, out_sas_n&p)               *
* 07/10/2012  | Michael Gilman   | Now use %get_outfile_attrs to retrieve name of output file to check.       *
* 07/27/2012  | Michael Gilman   | Removed the determining of the number of out_xxx files (now done by        *
*             |                  | %set_outfiles).                                                            *
*-------------------------------------------------------------------------------------------------------------*
* HeaderEnd:                                                                                                  *
**************************************************************************************************************/

%macro chk_outfile_length;
%put Start macro chk_outfile_length;

 %local i;

 %do i=1 %to &number_of_output_files;

    %get_outfile_attrs(&i);

    %if %superq(outfile)=%str() %then %goto EXIT;

    %if %length(&outfile)>32 %then
    %do;

       %let errormsg&i=Length of output file &outfile is greater than 32 characters.;

       %put ERROR: &&errormsg&i;

       %let jumptoexit=1;

       %goto EXIT;

    %end;

 %end;

%EXIT:

%put End macro chk_outfile_length;
%mend chk_outfile_length;