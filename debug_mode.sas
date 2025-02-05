/**************************************************************************************************************
* Macro_Name:   debug_mode.sas                                                                        
* 
* Purpose: this macro is used to add the debug mode to the child stored process invocation.
*          
*                                                                                                              
* Usage: %sleep(sec);
*
* Input_parameters: sec - number for seconds
*                                                                                                              
* Outputs:  None.                                                                                              
*                                                                                                              
* Returns:  None   
*
* Example: 
*                                                                                                              
* Modules_called: None
* 
* Maintenance_History:                                                                                        
*-------------------------------------------------------------------------------------------------------------*
*  Date:      |   Who:        |  Description:                                                                 *
*-------------------------------------------------------------------------------------------------------------*
* 12/14/2011  | Sharad           | Initial creation.                                                          *
*-------------------------------------------------------------------------------------------------------------*
* HeaderEnd:                                                                                                  *
**************************************************************************************************************/

%macro debug_mode;
	%if &debugmode %then 
	%do;
		%let debugcmd="%nrstr(&_debug=131)";
		%let debugcmd1=%nrstr(&_debug=131);
	%end;
	%else
	%do;
			%let debugcmd=;
			%let debugcmd1=;
	%end;		
%mend;
