/**************************************************************************************************************                         
* Macro_Name:  get_macro_system_options                                                                                                 
*                                                                                                                                       
* Purpose: This macro returns the system settings for mprint, mlogic, mprintnest, mlogicnest symbolgen.                                 
*                                                                                                                                       
* Usage: %get_macro_system_options;                                                                                                     
*                                                                                                                                       
* Input_parameters: None.                                                                                                               
*                                                                                                                                       
* Outputs:  None.                                                                                                                       
*                                                                                                                                       
* Returns:  System settings for mprint, mlogic, mprintnest, mlogicnest symbolgen                                                        
*                                                                                                                                       
* Example:                                                                                                                              
*                                                                                                                                       
* Modules_called: None                                                                                                                  
*                                                                                                                                       
* Maintenance_History:                                                                                                                  
*-------------------------------------------------------------------------------------------------------------*                         
*  Date:      |   Who:        |  Description:                                                                 *                         
*-------------------------------------------------------------------------------------------------------------*                         
* 04/26/2011  | Michael Gilman| Initial creation.                                                             *                         
*-------------------------------------------------------------------------------------------------------------*                         
* HeaderEnd:                                                                                                  *                         
**************************************************************************************************************/                         
                                                                                                                                        
%macro get_macro_system_options;                                                                                                        
                                                                                                                                        
 %sysfunc(compbl(                                                                                                                       
                                                                                                                                        
 %sysfunc(getoption(mprint))                                                                                                            
 %sysfunc(getoption(mlogic))                                                                                                            
 %sysfunc(getoption(symbolgen))                                                                                                         
 %sysfunc(getoption(mprintnest))                                                                                                        
 %sysfunc(getoption(mlogicnest))                                                                                                        
                                                                                                                                        
 ))                                                                                                                                     
                                                                                                                                        
%mend get_macro_system_options;
