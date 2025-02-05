/**************************************************************************************************************                         
* Macro_Name:  compare_two_libraries                                                                                                    
*                                                                                                                                       
* Purpose: Compare the same-named data sets in two sas libraries using Proc Compare.                                                    
*                                                                                                                                       
* Usage: %compare_two_libraries(lib1=,lib2=,outfile=,compareVariables=1,outdata=compare_results);                                       
*                                                                                                                                       
* Input_parameters: lib1=                                                                                                               
*                    Libref 1                                                                                                           
*                   lib2=                                                                                                               
*                    Libref 2                                                                                                           
*                   outfile=                                                                                                            
*                    html or pdf file for the results                                                                                   
*                   compareVariables                                                                                                    
*                    1/0 If set to 1, variable differences are printed.                                                                 
*                        Default: 1.                                                                                                    
*                   outData=                                                                                                            
*                    Name of output sas data set that contains the results of the                                                       
*                    comparisons.                                                                                                       
*                        Default: work.compare_results.                                                                                 
*                                                                                                                                       
* Outputs:  outData                                                                                                                     
*            Output sas data set that contains the results of the comparisons.                                                          
*                                                                                                                                       
* Returns:  None.                                                                                                                       
*                                                                                                                                       
* Example:                                                                                                                              
*                                                                                                                                       
* Modules_called: %compare_two_datasets                                                                                                 
*                                                                                                                                       
* Maintenance_History:                                                                                                                  
*-------------------------------------------------------------------------------------------------------------*                         
*  Date:      |   Who:        |  Description:                                                                 *                         
*-------------------------------------------------------------------------------------------------------------*                         
* 12/14/2011  | Michael Gilman   | Initial creation.                                                          *                         
*-------------------------------------------------------------------------------------------------------------*                         
* HeaderEnd:                                                                                                  *                         
**************************************************************************************************************/                         
                                                                                                                                        
%macro compare_two_libraries(lib1=,lib2=,outfile=,compareVariables=1,outdata=compare_results);                                          
%put Start macro compare_two_libraries;                                                                                                 
                                                                                                                                        
 %local dsid obs odstype datetime;                                                                                                      
                                                                                                                                        
 %let lib1=%upcase(&lib1);                                                                                                              
 %let lib2=%upcase(&lib2);                                                                                                              
                                                                                                                                        
 %if %sysfunc(libref(&lib1)) %then                                                                                                      
 %do;                                                                                                                                   
                                                                                                                                        
    %put;                                                                                                                               
    %put ERROR: Libref &lib1 not assigned.;                                                                                             
    %put;                                                                                                                               
                                                                                                                                        
    %goto EXIT;                                                                                                                         
                                                                                                                                        
 %end;                                                                                                                                  
                                                                                                                                        
 %if %sysfunc(libref(&lib2)) %then                                                                                                      
 %do;                                                                                                                                   
                                                                                                                                        
    %put;                                                                                                                               
    %put ERROR: Libref &lib2 not assigned.;                                                                                             
    %put;                                                                                                                               
                                                                                                                                        
    %goto EXIT;                                                                                                                         
                                                                                                                                        
 %end;                                                                                                                                  
                                                                                                                                        
 %let odstype=;                                                                                                                         
                                                                                                                                        
 %if %upcase(%scan(&outfile,-1,%str(.)))=HTM  %then %let odstype=html;                                                                  
 %if %upcase(%scan(&outfile,-1,%str(.)))=HTML %then %let odstype=html;                                                                  
 %if %upcase(%scan(&outfile,-1,%str(.)))=PDF  %then %let odstype=PDF;                                                                   
                                                                                                                                        
 %if %superq(odstype)=%str() %then                                                                                                      
 %do;                                                                                                                                   
                                                                                                                                        
    %put;                                                                                                                               
    %put ERROR: Invalid file extension for outfile parameter.;                                                                          
    %put;                                                                                                                               
                                                                                                                                        
    %goto EXIT;                                                                                                                         
                                                                                                                                        
 %end;                                                                                                                                  
                                                                                                                                        
 %datasets_in_common(&lib1,&lib2,outdata=common_datasets);                                                                              
                                                                                                                                        
 %let dsid=%sysfunc(open(common_datasets));                                                                                             
                                                                                                                                        
 %let obs=%sysfunc(attrn(&dsid,nlobs));                                                                                                 
                                                                                                                                        
 %let dsid=%sysfunc(close(&dsid));                                                                                                      
                                                                                                                                        
 %if &obs=0 %then                                                                                                                       
 %do;                                                                                                                                   
                                                                                                                                        
    %put;                                                                                                                               
    %put WARNING: Libraries &lib1 and &lib2 have no data sets in common.;                                                               
    %put;                                                                                                                               
                                                                                                                                        
    %goto EXIT;                                                                                                                         
                                                                                                                                        
 %end;                                                                                                                                  
                                                                                                                                        
 %let datetime=%sysfunc(datetime());                                                                                                    
                                                                                                                                        
 %let datetime=%sysfunc(putn(&datetime,datetime.));                                                                                     
                                                                                                                                        
 ods listing close;                                                                                                                     
                                                                                                                                        
 ods &odstype body="&outfile";                                                                                                          
                                                                                                                                        
 ods proclabel "&lib1 and &lib2: Data Sets in Common";                                                                                  
                                                                                                                                        
 title1 "Compare Libraries &lib1 with &lib2 &datetime";                                                                                 
 title2 "&obs Data Sets in Common";                                                                                                     
                                                                                                                                        
 proc print data=common_datasets;                                                                                                       
 run;                                                                                                                                   
                                                                                                                                        
 %if %scan(%superq(outdata),2,%str(.))=%str() %then %let outdata=WORK.&outdata;                                                         
                                                                                                                                        
 %let outdataLib=%scan(%superq(outdata),1,%str(.));                                                                                     
 %let outdataDsn=%scan(%superq(outdata),2,%str(.));                                                                                     
                                                                                                                                        
 data nonmatchingDatasets ;                                                                                                             
  length memname $32;                                                                                                                   
                                                                                                                                        
  stop;                                                                                                                                 
                                                                                                                                        
 run;                                                                                                                                   
                                                                                                                                        
 proc datasets lib=&outdataLib nolist nowarn;                                                                                           
  delete &outdataDsn;                                                                                                                   
 quit;                                                                                                                                  
                                                                                                                                        
 %let dsid=%sysfunc(open(common_datasets));                                                                                             
                                                                                                                                        
 %do i=1 %to &obs;                                                                                                                      
                                                                                                                                        
    proc datasets lib=work nolist nowarn;                                                                                               
     delete comparison_details;                                                                                                         
    quit;                                                                                                                               
                                                                                                                                        
    %let rc=%sysfunc(fetch(&dsid));                                                                                                     
                                                                                                                                        
    %let memname=%sysfunc(getvarc(&dsid,1));                                                                                            
                                                                                                                                        
    %let dsn1=&lib1..&memname;                                                                                                          
    %let dsn2=&lib2..&memname;                                                                                                          
                                                                                                                                        
    %let exactMatch=0;                                                                                                                  
                                                                                                                                        
    %compare_two_datasets(&dsn1,&dsn2,equalobs=0,outfile=%superq(outfile),odsOutput=0,                                                  
                          compareVariables=&compareVariables,calledFromCompareLibraries=1);                                             
                                                                                                                                        
    %if %sysfunc(exist(comparison_details)) %then                                                                                       
    %do;                                                                                                                                
                                                                                                                                        
       %if &exactMatch=0 %then                                                                                                          
       %do;                                                                                                                             
                                                                                                                                        
          data temp;                                                                                                                    
           length memname $32;                                                                                                          
                                                                                                                                        
           memname="&memname";                                                                                                          
                                                                                                                                        
          run;                                                                                                                          
                                                                                                                                        
          proc append base=nonmatchingDatasets data=temp force;                                                                         
          run;                                                                                                                          
                                                                                                                                        
       %end;                                                                                                                            
                                                                                                                                        
       data temp;                                                                                                                       
        length lib1 lib2 $8 memname $32;                                                                                                
        retain lib1 "&lib1" lib2 "&lib2" memname "&memname";                                                                            
                                                                                                                                        
        set comparison_details;                                                                                                         
                                                                                                                                        
       run;                                                                                                                             
                                                                                                                                        
       proc append base=&outdata data=temp force;                                                                                       
       run;                                                                                                                             
                                                                                                                                        
    %end;                                                                                                                               
                                                                                                                                        
 %end;                                                                                                                                  
                                                                                                                                        
 %let dsid=%sysfunc(close(&dsid));                                                                                                      
                                                                                                                                        
 title2 "Data sets that don't match";                                                                                                   
 proc print data=nonmatchingDatasets;                                                                                                   
 run;                                                                                                                                   
                                                                                                                                        
 ods &odstype close;                                                                                                                    
                                                                                                                                        
%EXIT:                                                                                                                                  
                                                                                                                                        
%put End macro compare_two_libraries;                                                                                                   
%mend compare_two_libraries;                                                                                                            
                                                                                                                                        
/*                                                                                                                                      
%compare_two_libraries(lib1=test,lib2=sasuser,outfile=a.htm,compareVariables=0);                                                        
*/
