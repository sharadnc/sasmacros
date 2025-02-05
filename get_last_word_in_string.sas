/**************************************************************************************************************                                                                                                                                                 
* Macro_Name: get_last_word_in_string                                                                                                    
*                                                                                                                                                                                                                                                               
* Purpose: Get the last word in a macro string.                                                                                                                                                                          
*                                                                                                                                                                                                                                                               
* Usage: %get_last_word_in_string(a1 b2 c3)                                                                                                                                                                                                     
*                                                                                                                                                                                                                                                               
* Input_parameters: string                                                                                                                                                                                                                                    
*                                                                                                                                                                                                                                                               
* Outputs:  None                                                                                                                                                                                                                                             
*                                                                                                                                                                                                                                                               
* Returns:  Last word in a string.                                                                                                                                                                                                                             
*                                                                                                                                                                                                                                                               
* Example:                                                                                                                                                                                                                             
*                                                                                                                                                                                                                                                               
* Modules_called: None                                                                                                                                                                                                                                          
*                                                                                                                                                                                                                                                               
* Maintenance_History:                                                                                                                                                                                                                                          
*-------------------------------------------------------------------------------------------------------------*                                                                                                                                                 
*  Date:      |   Who:        |  Description:                                                                 *                                                                                                                                                 
*-------------------------------------------------------------------------------------------------------------*                                                                                                                                                 
* 05/20/2012  | Michael Gilman| Initial creation                                                              *                                                                                                                                                 
*-------------------------------------------------------------------------------------------------------------*                                                                                                                                                 
* HeaderEnd:                                                                                                  *                                                                                                                                                 
**************************************************************************************************************/     

%macro get_last_word_in_string(string);

 %local c;

 %let c=%sysfunc(reverse(%superq(string)));

 %let c=%scan(%superq(c),1,%str( ,/\*!:`~^|));

 %let c=%sysfunc(reverse(%superq(c)));

 &c

%mend get_last_word_in_string;

