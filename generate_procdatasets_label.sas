/**************************************************************************************************************                         
* Macro_Name:   generate_procdatasets_label                                                                                             
*                                                                                                                                       
* Purpose: this macro is used to a proc datasets label statement                                                                                                   
*                                                                                                                                       
*                                                                                                                                       
* Usage: %generate_procdatasets_label(dsn);                                                                                                  
*                                                                                                                                       
* Input_parameters: dsn - dataset name                                                                                                               
*                                                                                                                                       
* Outputs:  generates a proc datasets label statement                                                                                                                       
*                                                                                                                                       
* Returns:  generates a proc datasets label                                                                                                                        
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
                                                                                                                                        
%macro generate_procdatasets_label(dsn);                                                                                                
%put Start macro generate_procdatasets_label;                                                                                           
                                                                                                                                        
 %local cnt mprint symbolgen mlogic mlogicnest mprintnest;                                                                              
                                                                                                                                        
 %if %index(&dsn,.) %then                                                                                                          
 %do;                                                                                                                                   
                                                                                                                                        
    %let lib=%upcase(%scan(&dsn,1,.));                                                                                                  
                                                                                                                                        
    %let dsn=%upcase(%scan(&dsn,2,.));                                                                                                  
                                                                                                                                        
 %end;                                                                                                                                  
 %else                                                                                                                                  
 %do;                                                                                                                                   
                                                                                                                                        
    %let lib=WORK;                                                                                                                      
                                                                                                                                        
    %let dsn=%upcase(&dsn);                                                                                                             
                                                                                                                                        
 %end;                                                                                                                                  
                                                                                                                                        
 %let lib=%upcase(&lib);                                                                                                                
                                                                                                                                        
 %let dsn=%upcase(&dsn);                                                                                                                
                                                                                                                                        
 proc sql noprint;                                                                                                                      
  select count(name) into :cnt                                                                                                          
  from dictionary.columns                                                                                                               
  where memtype="DATA" and libname="&lib" and memname="&dsn"                                                                            
 ;                                                                                                                                      
 quit;                                                                                                                                  
                                                                                                                                        
 %let cnt=&cnt;                                                                                                                         
                                                                                                                                        
 proc sql noprint;                                                                                                                      
  select strip(upcase(name)),                                                                                                           
         case when label is missing then strip(upcase(name))                                                                             
              else strip(Propcase(label))                                                                                                
         end as lbl                                                                                                                      
         into :__var1-:__var&cnt, :__lbl1-:__lbl&cnt                                                                                     
  from dictionary.columns                                                                                                               
  where memtype="DATA" and libname="&lib" and memname="&dsn"                                                                            
  order by name                                                                                                                         
 ;                                                                                                                                      
 quit;                                                                                                                                  
                                                                                                                                        
 %let mprint=%sysfunc(getoption(mprint));                                                                                               
 %let symbolgen =%sysfunc(getoption(symbolgen));                                                                                        
 %let mlogic =%sysfunc(getoption(mlogic));                                                                                              
 %let mlogicnest =%sysfunc(getoption(mlogicnest ));                                                                                     
 %let mprintnest=%sysfunc(getoption(mprintnest));                                                                                       
                                                                                                                                        
 options nomprint nosymbolgen nomlogic nomlogicnest nomprintnest;                                                                        
                                                                                                                                        
 %put --------------------------------------------------------;                                                                         
 %put proc datasets lib=&lib%str(;);                                                                                                    
 %put modify &dsn.%nrstr(;);                                                                                                            
 %put label;                                                                                                                            
 %do i=1 %to &cnt;                                                                                                                      
       %put &&__var&i = "&&__lbl&i";                                                                                                    
 %end;                                                                                                                                  
 %put %str(;);                                                                                                                          
 %put quit %str(;);                                                                                                                     
 %put --------------------------------------------------------;                                                                         
                                                                                                                                        
 options &mprint &symbolgen &mlogic &mlogicnest &mprintnest;                                                                            
                                                                                                                                        
%put End macro generate_procdatasets_label;                                                                                             
%mend generate_procdatasets_label;                                                                                                      
                                                                                                                                        
/*                                                                                                                                      
proc datasets lib=PROMPTD nolist;                                                                                                       
modify ALL_DSN_PATHS;                                                                                                                   
label                                                                                                                                   
LIBDEF = "Libdef"                                                                                                                       
LIBTEXT = "Libtext"                                                                                                                     
PATH = "Path"                                                                                                                           
;                                                                                                                                       
quit ;                                                                                                                                  
*/
