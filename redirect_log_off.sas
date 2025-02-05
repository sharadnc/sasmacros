/**************************************************************************************************************
* Macro_Name:   redirect_log_off                                                                        
* 
* Purpose: Macro to stop re-routing the Log to an external file 
*          
*                                                                                                              
* Usage: %redirect_log_off;
*
* Input_parameters: None.
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



%macro redirect_log_off(PrintLoc);
	proc printto; run;
%mend redirect_log_off;
