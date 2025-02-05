/**************************************************************************************************************                                                               
* Macro_Name:   check_dataset_exists                                                                                                                                          
*                                                                                                                                                                             
* Purpose: This macro is used to check if a sas data set exists.                                                                                                              
*                                                                                                                                                                             
* Usage: %check_dataset_exists(dsn);                                                                                                                                          
*                                                                                                                                                                             
* Input_parameters: dsn                                                                                                                                                       
*                    Name of data set to check for                                                                                                                            
*                                                                                                                                                                             
* Outputs:  None                                                                                                                                                     
*                                                                                                                                                                             
* Returns:  If data set doesn't exist, jumptoexit=1                                                                                                                           
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
                                                                                                                                                                              
%macro check_dataset_exists(dsn);                                                                                                                                             
%put Start macro check_dataset_exists;                                                                                                                                        
                                                                                                                                                                              
 %if %sysfunc(exist(%superq(dsn)))=0 %then                                                                                                                                    
 %do;                                                                                                                                                                         
                                                                                                                                                                              
    %let jumptoexit=1;                                                                                                                                                        
                                                                                                                                                                              
    %let errormsg1=Data set &dsn does not exist.;                                                                                                                             
                                                                                                                                                                              
 %end;                                                                                                                                                                        
                                                                                                                                                                              
%put End macro check_dataset_exists;                                                                                                                                          
%mend check_dataset_exists;
