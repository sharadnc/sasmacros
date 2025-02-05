/**************************************************************************************************************                         
* Macro_Name:   resequence_step_numbers                                                                                                 
*                                                                                                                                       
* Purpose: This macro resequences the STEP numbers in a program.                                                                        
*                                                                                                                                       
* Usage: %resequence_step_numbers(infile=,outfile=);                                                                                    
*                                                                                                                                       
* Input_parameters: infile                                                                                                              
*                    File to resequence                                                                                                 
*                   outfile                                                                                                             
*                    Resequenced file                                                                                                   
*                                                                                                                                       
* Outputs:  Resequenced file                                                                                                            
*                                                                                                                                       
* Returns:                                                                                                                              
*                                                                                                                                       
* Example:                                                                                                                              
*                                                                                                                                       
* Modules_called: None                                                                                                                  
*                                                                                                                                       
* Maintenance_History:                                                                                                                  
*-------------------------------------------------------------------------------------------------------------*                         
*  Date:      |   Who:        |  Description:                                                                 *                         
*-------------------------------------------------------------------------------------------------------------*                         
* 05/31/2012  | Michael Gilman| Initial creation.                                                             *                         
*-------------------------------------------------------------------------------------------------------------*                         
* HeaderEnd:                                                                                                  *                         
**************************************************************************************************************/                         
                                                                                                                                        
%macro resequence_step_numbers(infile=,outfile=);                                                                                       
%put Start macro resequence_step_numbers;                                                                                               
                                                                                                                                        
 %if %superq(infile)=%superq(outfile) %then %let useOutfile=%sysfunc(pathname(work))/temp.sas;                                          
                                                                                                                                        
 %if %sysfunc(fileexist(&infile))=0 %then                                                                                               
 %do;                                                                                                                                   
                                                                                                                                        
    %put;                                                                                                                               
    %put ERROR: File &infile does not exist.;                                                                                           
    %put;                                                                                                                               
                                                                                                                                        
    %goto EXIT;                                                                                                                         
                                                                                                                                        
 %end;                                                                                                                                  
                                                                                                                                        
 data _null_;                                                                                                                           
                                                                                                                                        
  infile "&infile" truncover;                                                                                                           
                                                                                                                                        
  file "&useOutfile" lrecl=256;                                                                                                         
                                                                                                                                        
  input line $char256.;                                                                                                                 
                                                                                                                                        
  if left(upcase(line))=:'%STEP' then                                                                                                   
  do;                                                                                                                                   
                                                                                                                                        
     step+1;                                                                                                                            
                                                                                                                                        
     if step<=99 then line='%STEP'!!left(put(step,z2.));                                                                                
     else line='%STEP'!!left(put(step,z3.));                                                                                            
                                                                                                                                        
     line=trim(line)!!':';                                                                                                              
                                                                                                                                        
  end;                                                                                                                                  
                                                                                                                                        
  len=length(line);                                                                                                                     
                                                                                                                                        
  put line $varying256. len;                                                                                                            
                                                                                                                                        
 run;                                                                                                                                   
                                                                                                                                        
 %if %superq(infile)=%superq(outfile) %then                                                                                             
 %do;                                                                                                                                   
                                                                                                                                        
    data _null_;                                                                                                                        
                                                                                                                                        
     infile "&useOutfile" truncover;                                                                                                    
                                                                                                                                        
     file "&outfile" lrecl=256;                                                                                                         
                                                                                                                                        
     input;                                                                                                                             
                                                                                                                                        
     put _infile_;                                                                                                                      
                                                                                                                                        
    run;                                                                                                                                
                                                                                                                                        
 %end;                                                                                                                                  
                                                                                                                                        
%EXIT:                                                                                                                                  
                                                                                                                                        
%put Start macro resequence_step_numbers;                                                                                               
%mend resequence_step_numbers;
