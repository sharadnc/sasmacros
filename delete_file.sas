/**************************************************************************************************************                         
* Macro_Name:   delete_file                                                                                                     
*                                                                                                                                       
* Purpose: This macro is used to delete file from a directory.
*                                                                                                                                       
* Usage: %delete_file(dirs,filenms)                                                                                 
*                                                                                                                                       
* Input_parameters: file                                                                                                              
*                    file on the directory
*                   dirs                                                                                                              
*                    path to the directory*                                                                                                                                       
* Outputs:  None.                                                                                                                       
*                                                                                                                                       
* Returns:  If error, jumptoexit=1                                                                                                      
*                                                                                                                                       
* Example: %delete_file(dirs,filenms)                                                                                              
*                                                                                                                                       
* Modules_called: None                                                                                                                  
*                                                                                                                                       
* Maintenance_History:                                                                                                                  
*-------------------------------------------------------------------------------------------------------------*                         
*  Date:      |   Who:        |  Description:                                                                 *                         
*-------------------------------------------------------------------------------------------------------------*                         
* 01/31/2013  | Sharad        | Initial creation.                                                             *                         
*-------------------------------------------------------------------------------------------------------------*                         
* HeaderEnd:                                                                                                  *                         
**************************************************************************************************************/                         
                                                                                                                                        
%macro delete_file(dirs,filenms); 
%put Start macro delete_file;

%let filenms=%lowcase(&filenms);
	
 /* remove the .txt file on the reports dir if it exists */
 %let filrf=myRef1;

%let rc=%sysfunc(filename(filrf,%superq(dirs)/%superq(filenms)));
%if &rc eq 0 and %sysfunc(fileexist(%superq(dirs)/%superq(filenms))) %then 
%do;
	%if %sysfunc(fdelete(&filrf)) %then 
	%do;
    %let errormsg1=Could not delete file %superq(dirs)/%superq(filenms);
    %let errormsg2=&syserrortext;                                                                                                       
    %put ERROR: &errormsg1; 
    %put ERROR: &errormsg2;                                                                                                                                         
    %let jumptoexit=1;                                                                                                                      
  %end;
	%else %put Deleting file %superq(dirs)/%superq(filenms);
%end; 
%else
%do;
	%put File %superq(dirs)/%superq(filenms) does not exist;
%end; 
                                                                                                                                        
%put End macro delete_file; 
%mend delete_file; 
