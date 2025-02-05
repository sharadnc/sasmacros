/**************************************************************************************************************                         
* Macro_Name: records_in_table                                                                                                          
*                                                                                                                                       
* Purpose: Returns the number of records in a table as macro variable nobs.                                                             
*          If the table cannot be accessed, nobs is set to -1.                                                                          
*                                                                                                                                       
*          In the case of a sas data set, the attrn function is used to                                                                 
*          retrieve the number of records. For views, proc sql with the                                                                 
*          count(*) function is used.                                                                                                   
*                                                                                                                                       
* Usage:  %records_in_table(dataset);                                                                                                   
*                                                                                                                                       
* Input_parameters: dataset                                                                                                             
*                    Data set for which the number of records will be returned.                                                         
*                                                                                                                                       
* Outputs: None.                                                                                                                        
*                                                                                                                                       
* Returns:  nobs                                                                                                                        
*            Number of data set records.                                                                                                
* Example:                                                                                                                              
*                                                                                                                                       
* Modules_called: %dataset_name_nliteral if proc sql used.                                                                              
*                                                                                                                                       
* Maintenance_History:                                                                                                                  
*-------------------------------------------------------------------------------------------------------------*                         
*  Date:      |   Who:        |  Description:                                                                 *                         
*-------------------------------------------------------------------------------------------------------------*                         
* 24/02/2012  | Michael Gilman|  | Initial creation.                                                          *                         
*-------------------------------------------------------------------------------------------------------------*                         
* HeaderEnd:                                                                                                  *                         
**************************************************************************************************************/                         
                                                                                                                                        
%macro records_in_table(dataset);                                                                                                       
                                                                                                                                        
 %local dsid mtype anobs arand;                                                                                                         
                                                                                                                                        
 %global nobs;                                                                                                                          
                                                                                                                                        
 %let nobs=-1;                                                                                                                          
                                                                                                                                        
 %let dataset=%dataset_name_nliteral(dataset=%bquote(&dataset),returnType=noquotes);                                                    
                                                                                                                                        
 %let dsid=%sysfunc(open(&dataset));                                                                                                    
                                                                                                                                        
 %if &dsid=0 %then                                                                                                                      
 %do;                                                                                                                                   
                                                                                                                                        
     %put ERROR: Data set &dataset could not be opened. Check the Log;                                                                  
                                                                                                                                        
     %goto EXIT;                                                                                                                        
                                                                                                                                        
 %end;                                                                                                                                  
                                                                                                                                        
 %let mtype=%sysfunc(attrc(&dsid,MTYPE));                                                                                               
 %let anobs=%sysfunc(attrn(&dsid,ANOBS));                                                                                               
 %let arand=%sysfunc(attrn(&dsid,ARAND));                                                                                               
                                                                                                                                        
 %if &anobs=1 and &arand=1 %then                                                                                                        
 %do;                                                                                                                                   
                                                                                                                                        
    %let nobs=%sysfunc(attrn(&dsid,NLOBS));                                                                                             
                                                                                                                                        
    %let dsid=%sysfunc(close(&dsid));                                                                                                   
                                                                                                                                        
    %goto EXIT;                                                                                                                         
                                                                                                                                        
 %end;                                                                                                                                  
                                                                                                                                        
 %let dsid=%sysfunc(close(&dsid));                                                                                                      
                                                                                                                                        
 %let dataset=%dataset_name_nliteral(dataset=%bquote(&dataset),returnType=nliteral);                                                    
                                                                                                                                        
 proc sql noprint;                                                                                                                      
  select left(put(count(*),best32.)) into : nobs                                                                                        
  from &dataset                                                                                                                         
  ;                                                                                                                                     
 quit;                                                                                                                                  
                                                                                                                                        
%EXIT:                                                                                                                                  
                                                                                                                                        
%mend records_in_table;
