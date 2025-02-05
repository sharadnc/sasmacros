/**************************************************************************************************************
* Macro_Name:   cleanup_work_library                                                                        
* 
* Purpose: this macro is used to remove WORK Library datasets or views etc
*          
*                                                                                                              
* Usage: %cleanup_work_library(membertype);
*
* Input_parameters: membertype (See below)
*                                                                                                              
* Outputs:  None.                                                                                              
*                                                                                                              
* Returns:  None.   
*
* Example: 
*                                                                                                              
* Modules_called: None
* 
* Maintenance_History:                                                                                        
*-------------------------------------------------------------------------------------------------------------*
*  Date:      |   Who:        |  Description:                                                                 *
*-------------------------------------------------------------------------------------------------------------*
* 12/14/2011  | Sharad        | Initial creation.                                                             *
*-------------------------------------------------------------------------------------------------------------*
* HeaderEnd:                                                                                                  *
**************************************************************************************************************/

%macro cleanup_work_library(membertype);
 /***
 ACCESS - access descriptor files (created by SAS/ACCESS software)
 ALL - all member types
 CATALOG- SAS catalogs
 DATA - SAS data files
 FDB - financial database
 MDDB - multidimensional database
 PROGRAM - stored compiled SAS programs
 VIEW - SAS views
 ****/


 %let validvals=ACCESS ALL CATALOG DATA FDB MDDB PROGRAM VIEW;
 %if %index(&validvals,%upcase(&membertype)) gt 0 %then
   %do;
       proc datasets lib=WORK kill nolist memtype=%upcase(&membertype);
       quit;
    %end;
%mend cleanup_work_library;

