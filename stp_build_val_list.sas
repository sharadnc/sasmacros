/**************************************************************************************************************
* Macro_Name:   stp_build_val_list
*
* Purpose: This macro is used in stored processes to build a list that can be used in a SQL Where clause.
*
* Usage: %stp_build_val_list(varname);
*
* Input_parameters: varname,vals
*                    varname - name of the variable in the SQL query
*
* Outputs:  None.
*
* Returns:  None.
*
* Example:
*
* Modules_called: None.
*
* Maintenance_History:
*-------------------------------------------------------------------------------------------------------------*
*  Date:      |   Who:        |  Description:                                                                 *
*-------------------------------------------------------------------------------------------------------------*
* 06/10/2012  | Sharad        | Initial creation.                                                             *
* 06/11/2012  | Sharad        | Add condition for macro resolution                                            *
*-------------------------------------------------------------------------------------------------------------*
* HeaderEnd:                                                                                                  *
**************************************************************************************************************/

%macro stp_build_val_list(varname);
%put Start macro stp_build_val_list;

%let cnt=&&&varname._count;

%if &cnt gt 1 %then
%do;
	(
	%do i=1 %to  %eval(&cnt -1);
		%let varval=&&&varname&i.;
		"&varval.",
	%end;
		%let varval=&&&varname&cnt;
		"&varval.")
%end;
%else
%do;
		%let varval=&&&varname.;
		("&varval.")
%end;

%put End macro stp_build_val_list;
%mend stp_build_val_list;