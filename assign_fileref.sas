/**************************************************************************************************************
* Macro_Name:   assign_fileref.sas                                                                        
* 
* Purpose: this macro is used to assign a fileref to a filelocation
*          
*                                                                                                              
* Usage: %assign_fileref(filref,fileloc);                                                                                 
*
* Input_parameters: filref  - the intended fileref  
*                   fileloc - the physical file location
*                                                                                                              
* Outputs:  None.                                                                                              
*                                                                                                              
* Returns:  None   
*
* Example: %assign_fileref(abc,/u04/data/cig_ebi/dmg/dev/rpt/filename.txt);
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

%macro assign_fileref(filref,fileloc);

   %local rc fileref ; 

/*   Check if the &fileloc file location exists*/
   %let rc = %sysfunc(filename(fileref,&fileloc.)) ;    
   %if %sysfunc(fexist(&fileref)) %then /*if it exists then assign the fileref */
   %do;
		filename &filref. "&fileloc.";
/*		else throw an error*/
		%if %sysfunc(fileref(&filref)) ne 0 %then 
		%do; 
		  %let _ERROR= Could NOT assign &filref to &fileloc;
		  %let _STEP = Assign a Fileref &filref to &fileloc;
		  %let _StepType=Fileref Step;
		  %let jumptoexit=1;
		%end; 
   %end;
   %else
   %do;
			%let _ERROR= &fileloc Location Not Found;
			%let _STEP = Assign a Fileref &filref to &fileloc;
			%let _StepType=FileRef Step;
			%let jumptoexit=1;
   %end;
%mend assign_fileref;
