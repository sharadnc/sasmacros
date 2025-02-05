/**************************************************************************************************************
* Macro_Name:   create_symbolic_link
*
* Purpose: This macro creates a Unix symbolic link.
*
* Usage: %create_symbolic_link(file,target);
*
* Input_parameters: file
*                    Full pathname of file for which a symbolic link will be created
*                   target
*                    Symbolic link
*
* Outputs:  None.
*
* Returns:  If error, jumptoexit=1
*
* Example:
*
* Modules_called: None
*
* Maintenance_History:
*----------------------------------------------------------------------------------------------------------------*
*  Date:      |   Who:           |  Description:                                                                 *
*----------------------------------------------------------------------------------------------------------------*
* 08/28/2012  | Michael Gilman   | Initial creation.                                                             *
*----------------------------------------------------------------------------------------------------------------*
* HeaderEnd:                                                                                                     *
**************************************************************************************************************/

%macro create_symbolic_link(file,target);
%put Start macro create_symbolic_link;

 x "ln -s -f &file &target";

 %if &sysrc>0 %then
 %do;

    %let jumptoexit=1;

    %let errormsg1=Symbolic link &file to &target could not be created.;

 %end;

%put End macro create_symbolic_link;
%mend create_symbolic_link;
