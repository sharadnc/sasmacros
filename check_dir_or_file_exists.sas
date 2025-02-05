/**************************************************************************************************************
* Macro_Name:   check_dir_or_file_exists
*
* Purpose: This macro checks if a directory or file exists.
*
* Usage: %check_dir_or_file_exists(dirfile,set_jumptoexit=1);
*
* Input_parameters: dirfile
*                    Name of directory or file to check.
*                   set_jumptoexit
*                    If 1 and directory or file does not exist, jumptoexit is set to 1.
*
* Outputs:  None.
*
* Returns:  1 if directory or file exists, otherwise 0.
*           If set_jumptoexit is 1 and directory or file does not exist, jumptoexit is set to 1.
*
* Example:
*
* Modules_called: None
*
* Maintenance_History:
*-------------------------------------------------------------------------------------------------------------*
*  Date:      |   Who:        |  Description:                                                                 *
*-------------------------------------------------------------------------------------------------------------*
* 04/26/2011  | Sharad           | Initial creation.                                                          *
* 06/08/2011  | Michael Gilman   | Now set errormsg1 when directory does not exist.                           *
*-------------------------------------------------------------------------------------------------------------*
* HeaderEnd:                                                                                                  *
**************************************************************************************************************/

%macro check_dir_or_file_exists(dirfile,set_jumptoexit=1);

 %let rc=%sysfunc(fileexist(&dirfile));

 %if &set_jumptoexit and &rc=0 %then
 %do;

    %let jumptoexit=1;

	  %let errormsg1=Directory &dirfile does not exist;

 %end;

 &rc

%mend check_dir_or_file_exists;
