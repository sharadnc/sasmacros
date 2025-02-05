/**************************************************************************************************************
* Macro_Name:   set_outfiles
*
* Purpose: This macro sets an _out_file&i global macro value for each out_xxx specified by the user.
*          The _out_file&i macro values are suffixed with the out_xxx type.
*          The number of out_xxx files specified by the user is returned.
*
* Usage: %set_outfiles;
*
* Input_parameters: None
*
* Outputs:  None.
*
* Returns:  number_of_output_files
*
* Example:
*
* Modules_called: None
*
* Maintenance_History:
*----------------------------------------------------------------------------------------------------------------*
*  Date:      |   Who:           |  Description:                                                                 *
*----------------------------------------------------------------------------------------------------------------*
* 07/26/2012  | Michael Gilman   | Initial creation.                                                             *
* 08/15/2012  | Michael Gilman   | Now check for split_xxx value.                                                *
* 08/28/2012  | Michael Gilman   | Now support out_html                                                          *
* 09/10/2012  | Sharad           | All outputs should be clearcase for consistency                               *
* 10/03/2012  | Michael Gilman   | Now support out_rtf                                                           *
* 11/28/2012  | Michael Gilman   | Added out_zipsas                                                              *
*----------------------------------------------------------------------------------------------------------------*
* HeaderEnd:                                                                                                     *
**************************************************************************************************************/

%macro set_outfiles;
%put Start macro set_outfiles;

 %local i;

 %let number_of_output_files=0;

 %do i=1 %to &max_number_of_output_files;

    %if %symexist(out_txt&i)   or
        %symexist(out_csv&i)   or
        %symexist(out_tab&i)   or
        %symexist(out_sas&i)   or
        %symexist(out_xls&i)   or
        %symexist(out_dat&i)   or
        %symexist(out_html&i)  or
        %symexist(out_rtf&i)   or
        %symexist(out_zipsas&i)or
        %symexist(split_txt&i) or
        %symexist(split_csv&i) or
        %symexist(split_tab&i) or
        %symexist(split_sas&i) or
        %symexist(split_xls&i) or
        %symexist(split_dat&i) or
        %symexist(split_html&i) or
        %symexist(split_rtf&i) %then
    %do;

       %let number_of_output_files=%eval(&number_of_output_files+1);

       %global reccnt&i _out_file&i;

       %if %symexist(out_txt&i) %then %let _out_file&i=%lowcase(&&out_txt&i...txt);
       %if %symexist(out_csv&i) %then %let _out_file&i=%lowcase(&&out_csv&i...csv);
       %if %symexist(out_tab&i) %then %let _out_file&i=%lowcase(&&out_tab&i...tab);
       %if %symexist(out_sas&i) %then %let _out_file&i=%lowcase(&&out_sas&i...sas);
       %if %symexist(out_xls&i) %then %let _out_file&i=%lowcase(&&out_xls&i...xls);
       %if %symexist(out_dat&i) %then %let _out_file&i=%lowcase(&&out_dat&i...dat);
       %if %symexist(out_html&i) %then %let _out_file&i=%lowcase(&&out_html&i...html);
       %if %symexist(out_rtf&i) %then %let _out_file&i=%lowcase(&&out_rtf&i...rtf);
       %if %symexist(out_zipsas&i) %then %let _out_file&i=%lowcase(&&out_zipsas&i...zipsas);

       %if %symexist(split_txt&i) %then %let _out_file&i=%lowcase(&&split_txt&i...split_txt);
       %if %symexist(split_csv&i) %then %let _out_file&i=%lowcase(&&split_csv&i...split_csv);
       %if %symexist(split_tab&i) %then %let _out_file&i=%lowcase(&&split_tab&i...split_tab);
       %if %symexist(split_sas&i) %then %let _out_file&i=%lowcase(&&split_sas&i...split_sas);
       %if %symexist(split_xls&i) %then %let _out_file&i=%lowcase(&&split_xls&i...split_xls);
       %if %symexist(split_dat&i) %then %let _out_file&i=%lowcase(&&split_html&i...split_dat);
       %if %symexist(split_html&i) %then %let _out_file&i=%lowcase(&&split_html&i...split_html);
       %if %symexist(split_rtf&i) %then %let _out_file&i=%lowcase(&&split_rtf&i...split_rtf);

    %end;
    %else %goto EXIT;

 %end;

%EXIT:

 &number_of_output_files

%put End macro set_outfiles;
%mend set_outfiles;