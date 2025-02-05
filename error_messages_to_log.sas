/**************************************************************************************************************
* Macro_Name:   error_messages_to_log                                                                        
* 
* Purpose: If an error has occurred (jumptoexit=1), this macro will print up to 10 error messages to the sas log. 
*          
*                                                                                                              
* Usage: %error_messages_to_log;
*
* Input_parameters: jumptoexit                                                                                                                 
*          If 0, program immediately exits.                                                                                          
*         errormsg1-errormsg10                                                                                                       
*          Up to 10 error message lines                                                                                              
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
* 12/14/2011  | Michael Gilman   | Initial creation.                                                          *
*-------------------------------------------------------------------------------------------------------------*
* HeaderEnd:                                                                                                  *
**************************************************************************************************************/

                                                                                                                                       
%macro error_messages_to_log; 
%put Start macro error_messages_to_log;                                                                                                          ;
                                                                                                                                        
 %local i temp;                                                                                                                         
                                                                                                                                        
 %if &jumptoexit=0 %then %goto EXIT;                                                                                                                                                                                                                                            
                                                                                                                                        
 %put;
 %put ERROR: Program &PgmName finished in Error.;                                                                                              
 %put;                                                                                                                                  
 %put ERROR: Last sucessfully completed Step Number: &step_count;                                                                              
 %put;                                                                                                                                                                                                                                                                          
                                                                                                                                
                                                                                                                                        
 %do i=1 %to 10;                                                                                                                        
                                                                                                                                        
    %let temp=&&errormsg&i;                                                                                                             
                                                                                                                                        
    %if %superq(temp) ne %str() %then                                                                                                   
    %do;                                                                                                                                
                                                                                                                                        
       %put ERROR: &temp;                                                                                                               
                                                                                                                                        
    %end;                                                                                                                               
                                                                                                                                        
 %end;                                                                                                                                  
                                                                                                                                        
%EXIT:                                                                                                                                  
                                                                                                                                        
%put End macro error_messages_to_log;  
%mend error_messages_to_log;