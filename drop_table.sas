/**************************************************************************************************************
* Macro_Name:   drop_table                                                                        
* 
* Purpose: this macro is used to drop a sas dataset 
*          
*                                                                                                              
* Usage: %drop_table(dsn);
*
* Input_parameters: dsn - dataset name
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
*-------------------------------------------------------------------------------------------------------------*
* HeaderEnd:                                                                                                  *
**************************************************************************************************************/

%macro drop_table(dsn);
	%if %sysfunc(exist(&dsn.)) %then 
     %do;
		 proc sql;
		    drop table &dsn.;
		 quit;	
	 %end;
%mend drop_table;
