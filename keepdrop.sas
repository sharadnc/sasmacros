/**************************************************************************************************************
* Macro_Name:   keepdrop.sas                                                                        
* 
* Purpose: this macro is used to mention the keep and drop variables for a dataset.
*          
*                                                                                                              
* Usage: %keepdrop;
*
* Input_parameters: None
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

%macro keepdrop;
	%global keepdrop1;
	%if %length(&keepvars) ge 1 %then 
	%do;
		%let keepdrop1=&keepdrop1 %str(keep=&keepvars) ;
	%end;
	
	%if %length(&dropvars) ge 1 %then 
	%do;
		%let keepdrop1=&keepdrop1 %str(drop=&dropvars);	
	%end;
%mend keepdrop;