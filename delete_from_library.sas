/**************************************************************************************************************                         
* Macro_Name:   delete_from_library                                                                                                     
*                                                                                                                                       
* Purpose: This macro is used to delete all sas data files of a specific member type from a sas library.                                
*          You can optionally delete only files whose names begin with a specified prefix.                                              
*                                                                                                                                       
* Usage: %delete_from_library(libref,membertype,prefix)                                                                                 
*                                                                                                                                       
* Input_parameters: libref                                                                                                              
*                    sas library to delete from                                                                                         
*                   membertype                                                                                                          
*                    membertype to delete                                                                                               
*                   prefix                                                                                                              
*                    Optional. Specify prefix of a sas name                                                                             
*                                                                                                                                       
* Outputs:  None.                                                                                                                       
*                                                                                                                                       
* Returns:  If error, jumptoexit=1                                                                                                      
*                                                                                                                                       
* Example: %delete_from_library(WORK,DATA)                                                                                              
*           Delete all DATA files from WORK                                                                                             
*          %delete_from_library(WORK,DATA,TEMP)                                                                                         
*           Delete all DATA files from WORK whose names begin with TEMP                                                                 
*                                                                                                                                       
* Modules_called: None                                                                                                                  
*                                                                                                                                       
* Maintenance_History:                                                                                                                  
*-------------------------------------------------------------------------------------------------------------*                         
*  Date:      |   Who:        |  Description:                                                                 *                         
*-------------------------------------------------------------------------------------------------------------*                         
* 03/03/2012  | Michael Gilman| Initial creation.                                                             *                         
*-------------------------------------------------------------------------------------------------------------*                         
* HeaderEnd:                                                                                                  *                         
**************************************************************************************************************/                         
                                                                                                                                        
%macro delete_from_library(libref,membertype,prefix)/minoperator;                                                                       
%put Start macro delete_from_library;                                                                                                   
                                                                                                                                        
 %local validvals;                                                                                                                      
                                                                                                                                        
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
                                                                                                                                        
 %let libref=%upcase(&libref);                                                                                                          
                                                                                                                                        
 %let membertype=%upcase(&membertype);                                                                                                  
                                                                                                                                        
 %if %sysfunc(libref(&libref)) %then                                                                                                    
 %do;                                                                                                                                   
                                                                                                                                        
    %let errormsg1=Library &libref is not assigned.;                                                                                    
                                                                                                                                        
    %put ERROR: &errormsg1;                                                                                                             
                                                                                                                                        
    %let jumptoexit=1;                                                                                                                  
                                                                                                                                        
    %goto EXIT;                                                                                                                         
                                                                                                                                        
 %end;                                                                                                                                  
                                                                                                                                        
 %if %eval(&membertype in &validvals)=0 %then                                                                                           
 %do;                                                                                                                                   
                                                                                                                                        
    %let errormsg1=&membertype is not a valid membertype.;                                                                              
                                                                                                                                        
    %put ERROR: &errormsg1;                                                                                                             
                                                                                                                                        
    %let jumptoexit=1;                                                                                                                  
                                                                                                                                        
    %goto EXIT;                                                                                                                         
                                                                                                                                        
 %end;                                                                                                                                  
                                                                                                                                        
 proc datasets lib=&libref nolist memtype=&membertype                                                                                   
 %if %superq(prefix)=%str() %then %str(kill);                                                                                           
 ;                                                                                                                                      
 %if %superq(prefix) ne %str() %then                                                                                                    
 %do;                                                                                                                                   
                                                                                                                                        
    delete &prefix:;                                                                                                                    
                                                                                                                                        
 %end;                                                                                                                                  
 quit;                                                                                                                                  
                                                                                                                                        
 %if %eval(&syserr in 0 4)=0 %then                                                                                                      
 %do;                                                                                                                                   
                                                                                                                                        
    %let errormsg1=Could not delete members from &libref;                                                                               
    %let errormsg2=&syserrortext;                                                                                                       
                                                                                                                                        
    %put ERROR: &errormsg1;                                                                                                             
    %put ERROR: &errormsg2;                                                                                                             
                                                                                                                                        
    %let jumptoexit=1;                                                                                                                  
                                                                                                                                        
    %goto EXIT;                                                                                                                         
                                                                                                                                        
 %end;                                                                                                                                  
                                                                                                                                        
%EXIT:                                                                                                                                  
                                                                                                                                        
%put End macro delete_from_library;                                                                                                     
%mend delete_from_library;                                                                                                              
