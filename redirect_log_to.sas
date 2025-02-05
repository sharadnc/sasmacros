/**************************************************************************************************************                         
* Macro_Name:   redirect_log_to                                                                                                         
*                                                                                                                                       
* Purpose: Macro to re-route the Log to an external file                                                                                
*                                                                                                                                       
* Usage: %redirect_log_to(PrintLoc,mode);                                                                                               
*                                                                                                                                       
* Input_parameters: PrintLoc                                                                                                            
*                    Full pathname of the Unix file to which the log should be directed.                                                
*                   mode                                                                                                                
*                    N/M Default is N which creates a new log file                                                                      
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
* 12/14/2011  | Michael Gilman   | Initial creation.                                                          *                         
*-------------------------------------------------------------------------------------------------------------*                         
* HeaderEnd:                                                                                                  *                         
**************************************************************************************************************/                         
                                                                                                                                        
%macro redirect_log_to(PrintLoc,mode);                                                                                                  
                                                                                                                                        
 /* Log REDIRECTED TO &PrintLoc with the mode */                                                                                        
                                                                                                                                        
 %if %upcase(&mode) eq N %then %do; proc printto log="&PrintLoc" new; run; %end;                                                        
                                                                                                                                        
 %if %upcase(&mode) eq M %then %do; proc printto log="&PrintLoc" ; run; %end;                                                           
                                                                                                                                        
%mend redirect_log_to;
