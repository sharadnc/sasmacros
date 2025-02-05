/**************************************************************************************************************
* Macro_Name:   reset_macrovariable_values                                                                        
* 
* Purpose: this macro is used to reset all Global Macrovariable values
*          
*                                                                                                              
* Usage: %reset_macrovariable_values;
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
* 12/14/2011  | Sharad           | Initial creation.                                                          *
*-------------------------------------------------------------------------------------------------------------*
* HeaderEnd:                                                                                                  *
**************************************************************************************************************/

%macro reset_macrovariable_values;

/* VMACRO is a SASHELP view that contains information about currently */
/* defined macros.  Create a data set from SASHELP.VMACRO to avoid a  */
/* macro symbol table lock.                                           */

  data _null_;
    set sashelp.vmacro;
    temp=lag(name);
    if scope='GLOBAL' and substr(name,1,3) ne 'SYS' and temp ne name then
      call execute('%symdel '||trim(left(name))||';');
  run;

%mend reset_macrovariable_values;
