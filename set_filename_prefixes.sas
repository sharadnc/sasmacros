/**************************************************************************************************************
* Macro_Name:   set_filename_prefixes                                                                        
* 
* Purpose: this macro is used to 
*          
*                                                                                                              
* Usage: %set_filename_prefixes(pgmid);
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
* 12/14/2011  | Michael Gilman   | Initial creation.                                                          *
*-------------------------------------------------------------------------------------------------------------*
* HeaderEnd:                                                                                                  *
**************************************************************************************************************/

%macro set_filename_prefixes(pgmid);
%put Start macro set_filename_prefixes;

 %do i=0 %to 6; /* Days */

    %global FilePrefixDay_&i;

    %let FilePrefixDay_&i=%str(&pgmid)_&&dt_yymmdd_&i;

    %let FilePrefixDay_&i=%unquote(&&FilePrefixDay_&i);

 %end;

 %do i=0 %to 6; /* Months */

    %global FilePrefixMonth_&i;

    %let FilePrefixMonth_&i=%str(&pgmid)_&&dt_mmyy_&i;

    %let FilePrefixMonth_&i=%unquote(&&FilePrefixMonth_&i);

 %end;

%put End macro set_filename_prefixes;
%mend set_filename_prefixes;

