/**************************************************************************************************************                         
* Macro_Name:   clear_error_messages                                                                                                    
*                                                                                                                                       
* Purpose: This macro clears the macro variables errormsg1-errormsg10                                                                   
*                                                                                                                                       
* Usage: %clear_error_messages;                                                                                                         
*                                                                                                                                       
* Input_parameters: errormsg1-errormsg10                                                                                                
*                                                                                                                                       
* Outputs:  None.                                                                                                                       
*                                                                                                                                       
* Returns:  errormsg1-errormsg10                                                                                                        
*                                                                                                                                       
* Example:                                                                                                                              
*                                                                                                                                       
* Modules_called: None                                                                                                                  
*                                                                                                                                       
* Maintenance_History:                                                                                                                  
*-------------------------------------------------------------------------------------------------------------*                         
*  Date:      |   Who:           |  Description:                                                              *                         
*-------------------------------------------------------------------------------------------------------------*                         
* 12/14/2011  | Michael Gilman   | Initial creation.                                                          *                         
*-------------------------------------------------------------------------------------------------------------*                         
* HeaderEnd:                                                                                                  *                         
**************************************************************************************************************/                         
                                                                                                                                        
%macro clear_error_messages;                                                                                                            
%put Start macro clear_error_messages;                                                                                                  
                                                                                                                                        
 %local i;                                                                                                                                                                                                                                                                      
                                                                                                                                        
 %do i=1 %to 10;                                                                                                                        
                                                                                                                                        
    %let errormsg&i=;                                                                                                                   
                                                                                                                                        
 %end;                                                                                                                                  
                                                                                                                                        
%put End macro clear_error_messages;                                                                                                    
%mend clear_error_messages;
