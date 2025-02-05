/**************************************************************************************************************
* Macro_Name:   select_sysoptions                                                                        
* 
* Purpose: this macro can be used to set the options statement for dev or prod environment globally...
*          it is an effecient use of setting the symbolgen mprint and mlogic in dev and then turn them off in prod.
*          
*                                                                                                              
* Usage: %select_sysoptions(Y);                                                                                 
*
* Input_parameters: mode
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

%macro select_sysoptions(mode=INIT);

 %if %upcase(&mode) eq Y %then
 %do;
  options ls=256 nocenter errors=0 yearcutoff=1950
       missing=0 symbolgen mprint mlogic macrogen mlogicnest mprintnest msglevel=i
    validvarname=v7 mautolocdisplay noerrorabend nosyntaxcheck dsnferr source source2
       noquotelenmax compress=yes;
 %end;
 %else %if %upcase(&mode) eq N %then
 %do;
  options ls=256 nocenter errors=0 yearcutoff=1950
    missing=0 nosymbolgen nomprint nomprintnest nomlogic nomlogicnest
     validvarname=v7 nomautolocdisplay nosyntaxcheck source nosource2
    nodmssynchk noerrorabend spool noquotelenmax compress=yes;
 %end;
 %else %if %upcase(&mode) eq INIT %then
 %do;
 options mprint nosymbolgen nomlogic;
 %end;
%mend select_sysoptions;

