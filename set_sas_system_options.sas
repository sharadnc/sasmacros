/**************************************************************************************************************                                    
* Macro_Name:   set_sas_system_options                                                                                                                  
*                                                                                                                                                  
* Purpose: This macro sets various sas system options.
*                                                                                                                                                  
* Usage: %set_sas_system_options;                                                                                                                       
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
* 12/14/2011  | Michael Gilman   | Initial creation.                                                          *                                    
*-------------------------------------------------------------------------------------------------------------*                                    
* HeaderEnd:                                                                                                  *                                    
**************************************************************************************************************/                                    
                                                                                                                                                   
%macro set_sas_system_options;                                                                                                                          
%put Start macro set_sas_system_options;

options ls=256 nocenter errors=0 yearcutoff=1950 msglevel=i
        validvarname=v7 mautolocdisplay nosyntaxcheck source source2
		fullstimer mprint noquotelenmax compress=yes
/*		noerrorabend*/
;

 %if %upcase(&debug) eq Y %then
 %do;

    options symbolgen mlogic mprintnest mlogicnest;

 %end;
 %else 
 %if %upcase(&debug) eq N %then
 %do;

    options nosymbolgen nomlogic nomprintnest nomlogicnest nomautolocdisplay;

 %end; 
                                                                                                                                                   
%put End macro set_sas_system_options;
%mend set_sas_system_options;