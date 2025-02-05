%macro global_macro_variables_dataset;
/**************************************************************************************************************                         
* Macro_Name:   global_macro_variables_dataset                                                                                                 
*                                                                                                                                       
* Purpose: This macro updates the rstats.global_macro_variables data set with the names of all the global
*          variables that are used by the Toolkit.
*                                                                                                                                                                                                                                                                             
* Usage: %global_macro_variables_dataset;                                                                                     
*                                                                                                                                       
* Input_parameters: None
*                                                                                                                                       
* Outputs:  rNome                                                                                                                                                                                                                      
*                                                                                                                                       
* Returns:  None                                                                                                                     
*                                                                                                                                       
* Example:                                                                                                                              
*                                                                                                                                       
* Modules_called: %lock_on_member  
*                 %lock_off_member                                                                                                                  
*                                                                                                                                       
* Maintenance_History:                                                                                                                  
*-------------------------------------------------------------------------------------------------------------*                         
*  Date:      |   Who:        |  Description:                                                                 *                         
*-------------------------------------------------------------------------------------------------------------*                         
* 03/12/2012  | Michael Gilman| Initial creation.                                                             *                         
*-------------------------------------------------------------------------------------------------------------*                         
* HeaderEnd:                                                                                                  *                         
**************************************************************************************************************/

 %let env_EG=labs; 

 %let rootloc_EG=/u04/data/cig_ebi/dmg/&env_EG; 
 
 %if %sysfunc(fileref(sasmacr)) and %sysfunc(fileref(macrosEG)) %then
 %do;
    filename macrosEG "&rootloc_EG/macros";
    options mautosource mrecall sasautos=(macrosEG sasautos);
 %end;
 
 %initialize;
                                                                                                                                                                                                                                                                
 %set_directory_structure; /* Set the Directory Structure*/  
 
 %assign_libref(rstats,&unixrstatsdir.);                                                                                                                                                                                                     
 
 /* Gather all Global Macro Variable Values */
 
 %lock_on_member(rstats.global_macro_variables);

 proc sql;
  create table rstats.global_macro_variables as
  select name 
  from dictionary.macros
  where scope='GLOBAL' and name not eqt '_SAS' and name not eqt '_CLIENT'
    and scan(name,-1,'_') ne 'EG'
  order by name;
 quit; 

 %lock_off_member(rstats.global_macro_variables);
 
%mend global_macro_variables_dataset;