/**************************************************************************************************************
* Macro_Name:   get_outfile_attrs
*
* Purpose: This macro retrieves the attributes of the user-specified output files.
*          The output files currently have the forms:
*           out_txt
*           out_csv
*           out_tab
*           out_sas
*           out_ftp
*           out_xls
*           out_dat
*           out_html
*           out_rtf
*
* Usage: get_outfile_attrs(i)
*
* Input_parameters: i
*                    The output file integer (e.g. out_txt1, 1 would be the integer)
*
* Outputs:  None
*
* Returns: outfile
*           The name of the output file
*          export_type
*           txt,csv,tab,sas,ftp,xls,dat,html
*          extension
*           txt,csv,xls,dat,html
*
* Example:
*
* Modules_called: None
*
* Maintenance_History:
*-------------------------------------------------------------------------------------------------------------*
*  Date:      |   Who:        |  Description:                                                                 *
*-------------------------------------------------------------------------------------------------------------*
* 03/31/2012  | Michael Gilman   | Initial creation.                                                          *
* 05/24/2012  | Sharad           | Added logic to lowercase report names                                      *
* 06/30/2012  | Michael Gilman   | Added new output type to check: sas (out_sas&p, out_sas_n&p)               *
* 07/10/2012  | Michael Gilman   | Removed setting of column_headers macro variable. This is now set by the   *
*             |                  | column_headers_in_export variable in programsetup.                         *
*             |                  | This also required the removal of all checking for the out_n macro         *
*             |                  | variables (e.g. out_txt_n).                                                *
* 07/27/2012  | Michael Gilman   | Significantly changed the macro. We now retrieve the new _out_file macro   *
*             |                  | value set up by the set_outfiles macro.                                    *
* 08/15/2012  | Michael Gilman   | Now check for split_xxx value.                                             *
* 08/28/2012  | Michael Gilman   | Now support out_html                                                       *
* 10/03/2012  | Michael Gilman   | Now support out_rtf                                                        *
* 11/28/2012  | Michael Gilman   | Added out_zipsas                                                              *
*-------------------------------------------------------------------------------------------------------------*
* HeaderEnd:                                                                                                  *
**************************************************************************************************************/

%macro get_outfile_attrs(i);

 %local ext;

 %let outfile=&&_out_file&i;

 %let ext=%scan(&outfile,-1,%str(.));

 %let outfile=%scan(&outfile,1,%str(.));

 %let outfile_rename=;

 %if &ext=txt %then
 %do;

    %let export_type=txt;

    %let extension=txt;

 %end;
 %else
 %if &ext=csv %then
 %do;

    %let export_type=csv;

    %let extension=csv;

 %end;
 %else
 %if &ext=tab %then
 %do;

    %let export_type=tab;

    %let extension=txt;

 %end;
 %else
 %if &ext=sas %then
 %do;

    %let export_type=sas;

    %let extension=sas;

 %end;
 %else
 %if &ext=ftp %then
 %do;

    %let export_type=ftp;

    %let extension=ftp;

 %end;
 %else
 %if &ext=xls %then
 %do;

    %let export_type=xls;

    %let extension=xls;

 %end;
 %else
 %if &ext=dat %then
 %do;

    %let export_type=dat;

    %let extension=dat;

 %end;
 %else
 %if &ext=html %then
 %do;

    %let export_type=html;

    %let extension=html;

 %end;
 %else
 %if &ext=rtf %then
 %do;

    %let export_type=rtf;

    %let extension=rtf;

 %end;
 %else
 %if %substr(&ext,1,5)=split %then
 %do;

    %let export_type=split;

    %let extension=%scan(&ext,-1,%str(_));

 %end;
 %else
 %if &ext=zipsas %then
 %do;

    %let export_type=zipsas;

    %let extension=sas7bdat;

 %end;

 %if %symexist(out_rename&i) %then %let outfile_rename=&&&out_rename&i;

%mend get_outfile_attrs;