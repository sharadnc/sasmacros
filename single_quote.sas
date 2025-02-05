/**************************************************************************************************************                         
* Macro_Name: single_quote(v)                                                                                                              
*                                                                                                                                       
* Purpose: Single quote a string value.                                                                                                 
*                                                                                                                                       
* Usage: %single_quote                                                                                                                  
*                                                                                                                                       
* Input_parameters: String. Cannot contain any single quotes itself.                                                                                                              
*                                                                                                                                       
* Outputs:  None.                                                                                                                       
*                                                                                                                                       
* Returns:  Single quoted string.                                                                                                       
*                                                                                                                                       
* Example:                                                                                                                              
*                                                                                                                                       
* Modules_called: None                                                                                                                  
*                                                                                                                                       
* Maintenance_History:                                                                                                                  
*-------------------------------------------------------------------------------------------------------------*                         
*  Date:      |   Who:        |  Description:                                                                 *                         
*-------------------------------------------------------------------------------------------------------------*                         
* 01/30/2012  | Michael Gilman| Initial creation.                                                             *                         
*-------------------------------------------------------------------------------------------------------------*                         
* HeaderEnd:                                                                                                  *                         
**************************************************************************************************************/                         
                                                                                                                                        
%macro single_quote(v);                                                                                                                 
                                                                                                                                        
 %local d;                                                                                                                              
                                                                                                                                        
 %let d=%str(%'&v%');                                                                                                                   
                                                                                                                                        
 %unquote(&d)                                                                                                                           
                                                                                                                                        
%mend single_quote;
