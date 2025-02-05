/**************************************************************************************************************                         
* Macro_Name: compare_one_record                                                                                                        
*                                                                                                                                       
* Purpose: This macro compares the values of the common variables from one record from two data sets.                                   
*          One record is read in from two data sets using a key variable and and key value.                                             
*          Then all variables with the same name and type are compared. Output is displayed for                                         
*          those variables that don't have matching values.                                                                             
*                                                                                                                                       
* Usage: %compare_one_record(dsn1=,dsn2=,keyvar1-5=,keyval1-5=,outfile=_webout)                                                         
*                                                                                                                                       
* Input_parameters: dsn1                                                                                                                
*                    Data set 1                                                                                                         
*                   dsn2                                                                                                                
*                    Data set 3                                                                                                         
*                   keyvar1-keyvar5                                                                                                     
*                    Name of the key variables that ares used to retrieve the one record.                                               
*                   keyval1-keyval5                                                                                                     
*                    The key values that will retrieve one record from the data sets.                                                   
*                   outfile                                                                                                             
*                    _webout or html or pdf file for the results.                                                                       
*                     Default: _webout                                                                                                  
*                   fileref                                                                                                             
*                    ods path fileref for _webout                                                                                       
*                                                                                                                                       
* Outputs:  None.                                                                                                                       
*                                                                                                                                       
* Returns:  number_of_compared_variables                                                                                                
*            Total number of variables that are compared                                                                                
*           nonmatch_count                                                                                                              
*            Number of non-matching variables                                                                                           
*           match_count                                                                                                                 
*            Number of matching variables                                                                                               
*           conflicting_types_cnt                                                                                                       
*            Number of common variables that have conflicting types                                                                     
*           in1_not_in2                                                                                                                 
*            Number of variables in dsn1 not in dsn2                                                                                    
*           in2_not_in1                                                                                                                 
*            Number of variables in dsn2 not in dsn1                                                                                    
*                                                                                                                                       
* Example:                                                                                                                              
*                                                                                                                                       
* Modules_called: None                                                                                                                  
*                                                                                                                                       
* Maintenance_History:                                                                                                                  
*-------------------------------------------------------------------------------------------------------------*                         
*  Date:      |   Who:        |  Description:                                                                 *                         
*-------------------------------------------------------------------------------------------------------------*                         
* 24/02/2012  | Michael Gilman|  | Initial creation.                                                          *                         
*-------------------------------------------------------------------------------------------------------------*                         
* HeaderEnd:                                                                                                  *                         
**************************************************************************************************************/                         
                                                                                                                                        
%macro compare_one_record(dsn1=,dsn2=,keyvar1=,keyvar2=,keyvar3=,keyvar4=,keyvar5=,                                                     
                          keyval1=,keyval2=,keyval3=,keyval4=,keyval5=,                                                                 
                          outfile=_webout);                                                                                    
                                                                                                                                        
 %global number_of_compared_variables nonmatch_count match_count conflicting_types_cnt in1_not_in2 in2_not_in1;                         
                                                                                                                                        
 %let nonmatch_count=0;                                                                                                                 
                                                                                                                                        
 %let match_count=0;                                                                                                                    
                                                                                                                                        
 %let number_of_compared_variables=0;                                                                                                   
                                                                                                                                        
 %let numberOfKeyvars=0;                                                                                                                
                                                                                                                                        
 %let in1_not_in2=0;                                                                                                                    
                                                                                                                                        
 %let in2_not_in1=0;                                                                                                                    
                                                                                                                                        
 %let common_types_cnt=0;                                                                                                               
                                                                                                                                        
 %let conflicting_types_cnt=0;                                                                                                          

 %let dsid1=0;

 %let dsid2=0;
                                                                                                                                        
 %let dsn1=%upcase(&dsn1);                                                                                                              
                                                                                                                                        
 %let dsn2=%upcase(&dsn2);                                                                                                              
                                                                                                                                        
 %let errormsg=; 

%if %qupcase(%superq(outfile))=_WEBOUT %then                                                                                           
 %do;                                                                                                                                   
                                                                                                                                        
    ods html body=_webout style=seaside;
                                                                                                                                        
 %end;                                                                                                                                  
 %else                                                                                                                                  
 %do;                                                                                                                                   
                                                                                                                                        
   %let odstype=;                                                                                                                       
                                                                                                                                        
    %if %upcase(%scan(&outfile,-1,%str(.)))=HTM  %then %let odstype=html;                                                               
    %if %upcase(%scan(&outfile,-1,%str(.)))=HTML %then %let odstype=html;                                                               
    %if %upcase(%scan(&outfile,-1,%str(.)))=PDF  %then %let odstype=PDF;                                                                
                                                                                                                                        
    %if %superq(odstype)=%str() %then                                                                                                   
    %do;                                                                                                                                
                                                                                                                                        
       %let errormsg=ERROR: Invalid file extension for outfile parameter.;                                                              
                                                                                                                                        
       %goto ERREXIT;                                                                                                                   
                                                                                                                                        
    %end;                                                                                                                               
                                                                                                                                        
    ods &odstype body="&outfile";                                                                                                       
                                                                                                                                        
 %end;                                                                                                                                  

 %if %sysfunc(exist(&dsn1))=0 %then                                                                                                     
 %do;                                                                                                                                   
                                                                                                                                        
    %let errormsg=ERROR: Data set &dsn1 does not exist;                                                                                 
                                                                                                                                        
    %goto ERREXIT;                                                                                                                      
                                                                                                                                        
 %end;                                                                                                                                  
                                                                                                                                        
 %if %sysfunc(exist(&dsn2))=0 %then                                                                                                     
 %do;                                                                                                                                   
                                                                                                                                        
    %let errormsg=ERROR: Data set &dsn2 does not exist;                                                                                 
                                                                                                                                        
    %goto ERREXIT;                                                                                                                      
                                                                                                                                        
 %end;  

 %do i=1 %to 5;                                                                                                                         
                                                                                                                                        
    %if &&keyvar&i ne %str() and &&keyval&i ne %str() %then                                                                             
    %do;                                                                                                                                
                                                                                                                                        
       %let numberOfKeyvars=%eval(&numberOfKeyvars+1);                                                                                  
                                                                                                                                        
       %let keyval&i=%sysfunc(dequote(&&keyval&i));                                                                                     
       %let keyvar&i=%upcase(&&keyvar&i);                                                                                               
                                                                                                                                        
    %end;                                                                                                                               
                                                                                                                                        
 %end;                                                                                                                                  

 title1 "Compare data sets &dsn1 and &dsn2"; 
                                                                                                                                        
 data compare(keep=variable value1 value2)                                                                                              
      in1_not_in2(keep=variable)                                                                                                        
      in2_not_in1(keep=variable)                                                                                                        
      conflicting_types(keep=variable vartype1 vartype2)                                                                                
 ;  

 length Variable $32 Value1 Value2 $200;                                                                                                                                    
                                                                                                                                        
 %let dsid1=%sysfunc(open(&dsn1)); 

 %let dsid2=%sysfunc(open(&dsn2));                                                                                                      
                                                                                                                                        
 %do i=1 %to &numberOfKeyvars;                                                                                                          
                                                                                                                                        
    %let keyvar=&&keyvar&i;                                                                                                             
                                                                                                                                        
    %let keyvarnum1_&i=%sysfunc(varnum(&dsid1,&keyvar));                                                                                
                                                                                                                                        
    %let keyvarnum2_&i=%sysfunc(varnum(&dsid2,&keyvar));                                                                                
                                                                                                                                        
    %if &&keyvarnum1_&i=0 %then                                                                                                         
    %do;                                                                                                                                
                                                                                                                                        
       %let errormsg=ERROR: Key variable &keyvar does not exist in &dsn1;                                                               
                                                                                                                                        
       %goto ERREXIT;                                                                                                                   
                                                                                                                                        
    %end;                                                                                                                               
                                                                                                                                        
    %if &&keyvarnum2_&i=0 %then                                                                                                         
    %do;                                                                                                                                
                                                                                                                                        
       %let errormsg=ERROR: Key variable &keyvar does not exist in &dsn2;                                                               
                                                                                                                                        
       %goto ERREXIT;                                                                                                                   
                                                                                                                                        
    %end;                                                                                                                               
                                                                                                                                        
 %end;                                                                                                                                  
                                                                                                                                        
 %let nvars1=%sysfunc(attrn(&dsid1,nvars));                                                                                             
                                                                                                                                        
 %let nvars2=%sysfunc(attrn(&dsid2,nvars));                                                                                             
                                                                                                                                        
 %do i=1 %to &nvars1;                                                                                                                   
                                                                                                                                        
    %let varname&i=%sysfunc(varname(&dsid1,&i));                                                                                        
                                                                                                                                        
    %let varname&i=%upcase(&&varname&i);                                                                                                
                                                                                                                                        
    %let varnum1=%sysfunc(varnum(&dsid1,&&varname&i));                                                                                  
                                                                                                                                        
    %let varnum2=%sysfunc(varnum(&dsid2,&&varname&i));                                                                                  
                                                                                                                                        
    %if &varnum2=0 %then                                                                                                                
    %do;                                                                                                                                
                                                                                                                                        
       %let in1_not_in2=%eval(&in1_not_in2+1);                                                                                          
                                                                                                                                        
       Variable="&&varname&i";                                                                                                          
                                                                                                                                        
       output in1_not_in2;                                                                                                              
                                                                                                                                        
    %end;                                                                                                                               
    %else                                                                                                                               
    %do;                                                                                                                                
                                                                                                                                        
       %let common_types_cnt=%eval(&common_types_cnt+1);                                                                                
                                                                                                                                        
       %let vartype1=%sysfunc(vartype(&dsid1,&varnum1));                                                                                
                                                                                                                                        
       %let vartype2=%sysfunc(vartype(&dsid2,&varnum2));                                                                                
                                                                                                                                        
       %if &vartype1 ne &vartype2 %then                                                                                                 
       %do;                                                                                                                             
                                                                                                                                        
          %let conflicting_types_cnt=%eval(&conflicting_types_cnt+1);                                                                   
                                                                                                                                        
          Variable="&&varname&i";                                                                                                       
          vartype1="&vartype1";                                                                                                         
          vartype2="&vartype2";                                                                                                         
                                                                                                                                        
          output conflicting_types;                                                                                                     
                                                                                                                                        
       %end;                                                                                                                            
                                                                                                                                        
    %end;                                                                                                                               
                                                                                                                                        
 %end;                                                                                                                                  
                                                                                                                                        
 %if &in1_not_in2=%eval(&nvars1-1) %then                                                                                                
 %do;                                                                                                                                   
                                                                                                                                        
    %let errormsg=ERROR: &dsn1 and &dsn2 have no variables in common other than the Key variable;                                       
                                                                                                                                        
    %goto ERREXIT;                                                                                                                      
                                                                                                                                        
 %end;                                                                                                                                  
                                                                                                                                        
 %if &conflicting_types_cnt=%eval(&common_types_cnt-1) %then                                                                            
 %do;                                                                                                                                   
                                                                                                                                        
    %let errormsg=ERROR: All variables in common, other than the Key variable, have conflicting types;                                  
                                                                                                                                        
    %goto ERREXIT;                                                                                                                      
                                                                                                                                        
 %end;                                                                                                                                  
                                                                                                                                        
                                                                                                                                        
 %do i=1 %to &nvars2;                                                                                                                   
                                                                                                                                        
    %let varname&i=%sysfunc(varname(&dsid2,&i));                                                                                        
                                                                                                                                        
    %let varname&i=%upcase(&&varname&i);                                                                                                
                                                                                                                                        
    %let varnum1=%sysfunc(varnum(&dsid1,&&varname&i));                                                                                  
                                                                                                                                        
    %if &varnum1=0 %then                                                                                                                
    %do;                                                                                                                                
                                                                                                                                        
       %let in2_not_in1=%eval(&in2_not_in1+1);                                                                                          
                                                                                                                                        
       Variable="&&varname&i";                                                                                                          
                                                                                                                                        
       output in2_not_in1;                                                                                                              
                                                                                                                                        
    %end;                                                                                                                               
                                                                                                                                        
 %end;                                                                                                                                  
                                                                                                                                        
 %do i=1 %to &numberOfKeyvars;                                                                                                          
                                                                                                                                        
    %let keyvartype1_&i=%sysfunc(vartype(&dsid1,&&keyvarnum1_&i));                                                                      
                                                                                                                                        
    %let keyvartype2_&i=%sysfunc(vartype(&dsid2,&&keyvarnum2_&i));                                                                      
                                                                                                                                        
    %if &&keyvartype1_&i ne &&keyvartype2_&i %then                                                                                      
    %do;                                                                                                                                
                                                                                                                                        
       %let errormsg=ERROR: Key variable &&keyvar&i in data set &dsn1 is type &&keyvartype1_&i but is type &&keyvartype2_&i in data set 
 &dsn2;                                                                                                                                 
                                                                                                                                        
       %goto ERREXIT;                                                                                                                   
                                                                                                                                        
    %end;                                                                                                                               
                                                                                                                                        
 %end;                                                                                                                                  
                                                                                                                                        
 %let rc=%sysfunc(close(&dsid1));                                                                                                       
                                                                                                                                        
 %let rc=%sysfunc(close(&dsid2));                                                                                                       
                                                                                                                                        
 %let wcls=;                                                                                                                            
                                                                                                                                        
 %let and=;                                                                                                                             
                                                                                                                                        
 %do i=1 %to &numberOfKeyvars;                                                                                                          
                                                                                                                                        
    %if &&keyvartype1_&i=C %then %let keyvalc=%sysfunc(quote(&&keyval&i));                                                              
    %else %let keyvalc=&&keyval&i;                                                                                                      
                                                                                                                                        
    %if &i>1 %then %let and=and;                                                                                                        
                                                                                                                                        
    %let wcls=%superq(wcls) &and &&keyvar&i=&keyvalc;                                                                                   
                                                                                                                                        
 %end;                                                                                                                                  
                                                                                                                                        
 %let dsid1=%sysfunc(open(&dsn1(where=(&wcls))));                                                                                       
                                                                                                                                        
 %let dsid2=%sysfunc(open(&dsn2(where=(&wcls))));                                                                                       
                                                                                                                                        
 %let obs1=%sysfunc(attrn(&dsid1,nlobsf));                                                                                              
                                                                                                                                        
 %if &obs1=0 %then                                                                                                                      
 %do;                                                                                                                                   
                                                                                                                                        
    %let errormsg=ERROR: No record found in data set &dsn1 having a value for the key variable(s);                                      
                                                                                                                                        
    %goto ERREXIT;                                                                                                                      
                                                                                                                                        
 %end;                                                                                                                                  
                                                                                                                                        
 %if &obs1>1 %then                                                                                                                      
 %do;                                                                                                                                   
                                                                                                                                        
    %let errormsg=ERROR: Data set &dsn1 has &obs1 records for the key variable(s);                                                      
                                                                                                                                        
    %goto ERREXIT;                                                                                                                      
                                                                                                                                        
 %end;                                                                                                                                  
                                                                                                                                        
 %let obs2=%sysfunc(attrn(&dsid2,nlobsf));                                                                                              
                                                                                                                                        
 %if &obs2=0 %then                                                                                                                      
 %do;                                                                                                                                   
                                                                                                                                        
    %let errormsg=ERROR: No record found in data set &dsn2 having a value for the key variable(s);                                      
                                                                                                                                        
    %goto ERREXIT;                                                                                                                      
                                                                                                                                        
 %end;                                                                                                                                  
                                                                                                                                        
 %if &obs2>1 %then                                                                                                                      
 %do;                                                                                                                                   
                                                                                                                                        
    %let errormsg=ERROR: Data set &dsn2 has &obs2 records for the key variable(s);                                                      
                                                                                                                                        
    %goto ERREXIT;                                                                                                                      
                                                                                                                                        
 %end;                                                                                                                                  
                                                                                                                                        
                                                                                                                                        
 %let rc=%sysfunc(fetch(&dsid1));                                                                                                       
                                                                                                                                        
 %let rc=%sysfunc(fetch(&dsid2));                                                                                                       
                                                                                                                                        
 %do i=1 %to &nvars1;                                                                                                                   
                                                                                                                                        
    %let varname&i=%sysfunc(varname(&dsid1,&i));                                                                                        
                                                                                                                                        
    %let varname&i=%upcase(&&varname&i);                                                                                                
                                                                                                                                        
    %let varnum1=%sysfunc(varnum(&dsid1,&&varname&i));                                                                                  
                                                                                                                                        
    %let varnum2=%sysfunc(varnum(&dsid2,&&varname&i));                                                                                  
                                                                                                                                        
    %if &varnum2=0 %then %goto NEXT;                                                                                                    
                                                                                                                                        
    %let vartype1=%sysfunc(vartype(&dsid1,&varnum1));                                                                                   
                                                                                                                                        
    %let vartype2=%sysfunc(vartype(&dsid2,&varnum2));                                                                                   
                                                                                                                                        
    %if &vartype1 ne &vartype2 %then %goto NEXT;                                                                                        
                                                                                                                                        
    %if &vartype1=C %then                                                                                                               
    %do;                                                                                                                                
                                                                                                                                        
       %let value1=%sysfunc(getvarc(&dsid1,&varnum1));                                                                                  
                                                                                                                                        
       %let value2=%sysfunc(getvarc(&dsid2,&varnum2));                                                                                  
                                                                                                                                        
    %end;                                                                                                                               
    %else                                                                                                                               
    %if &vartype1=N %then                                                                                                               
    %do;                                                                                                                                
                                                                                                                                        
       %let value1=%sysfunc(getvarn(&dsid1,&varnum1));                                                                                  
                                                                                                                                        
       %let value2=%sysfunc(getvarn(&dsid2,&varnum2));                                                                                  
                                                                                                                                        
    %end;                                                                                                                               
                                                                                                                                        
    %if %superq(value1) ne %superq(value2) %then                                                                                        
    %do;                                                                                                                                
                                                                                                                                        
       %let value1q=%sysfunc(quote(%superq(value1)));                                                                                   
       %let value2q=%sysfunc(quote(%superq(value2)));                                                                                   
                                                                                                                                        
       Variable="&&varname&i";                                                                                                          
       value1=&value1q;                                                                                                                 
       value2=&value2q;                                                                                                                 
                                                                                                                                        
       %let nonmatch_count=%eval(&nonmatch_count+1);                                                                                    
                                                                                                                                        
       output compare;                                                                                                                  
                                                                                                                                        
    %end;                                                                                                                               
    %else %let match_count=%eval(&match_count+1);                                                                                       
                                                                                                                                        
%NEXT:                                                                                                                                  
                                                                                                                                        
 %end;                                                                                                                                  
                                                                                                                                        
 %let match_count=%eval(&match_count-1);                                                                                                
                                                                                                                                        
 %let number_of_compared_variables=%eval(&nonmatch_count+&match_count);                                                                 
                                                                                                                                        
 %let rc=%sysfunc(close(&dsid1));                                                                                                       
                                                                                                                                        
 %let rc=%sysfunc(close(&dsid2));                                                                                                       
                                                                                                                                        
 label value1="&dsn1" value2="&dsn2";                                                                                                   
                                                                                                                                        
 run;                                                                                                                                   
                                                                                                                                        
 title2 c=red "Summary for &keyval1 Record";                                                                                                                      
                                                                                                                                        
 data temp;                                                                                                                             
                                                                                                                                        
  length Message $80;                                                                                                                   
                                                                                                                                        
  Message="Total number of compared variables";Value="&number_of_compared_variables";output;                                            
  Message="Number of non-matching variables";value="&nonmatch_count";output;                                                            
  Message="Number of matching variables";value="&match_count";output;                                                                   
  Message="Number of common variables that have conflicting types";value="&conflicting_types_cnt";output;                               
  Message="Number of variables in &dsn1 not in &dsn2";value="&in1_not_in2";output;                                                      
  Message="Number of variables in &dsn2 not in &dsn1";value="&in2_not_in1";output;                                                      
                                                                                                                                        
 run;                                                                                                                                   
                                                                                                                                        
 proc print data=temp label;                                                                                                            
 run;                                                                                                                                   
                                                                                                                                        
 %if &nonmatch_count %then                                                                                                              
 %do;                                                                                                                                   
                                                                                                                                        
    title2 "Variable values that don't match";                                                                                          
                                                                                                                                        
    proc sort data=compare;                                                                                                             
    by variable;                                                                                                                        
    run;                                                                                                                                
                                                                                                                                        
    proc print data=compare label;                                                                                                      
    run;                                                                                                                                
                                                                                                                                        
 %end;                                                                                                                                  
 %else                                                                                                                                  
 %do;                                                                                                                                   
                                                                                                                                        
    %let message=All values match for variables in common;                                                                              
                                                                                                                                        
    data temp;                                                                                                                          
                                                                                                                                        
     Message="&message";                                                                                                                
                                                                                                                                        
    run;                                                                                                                                
                                                                                                                                        
    title2 "&message";                                                                                                                  
                                                                                                                                        
    proc print data=temp label noobs;                                                                                                   
    run;                                                                                                                                
                                                                                                                                        
 %end;                                                                                                                                  
                                                                                                                                        
%ERREXIT:                                                                                                                               
                                                                                                                                        
 %if &dsid1 %then %let dsid1=%sysfunc(close(&dsid1));                                                                                   
                                                                                                                                        
 %if &dsid2 %then %let dsid2=%sysfunc(close(&dsid2));                                                                                   
                                                                                                                                        
 %if %superq(errormsg) ne %str() %then                                                                                                  
 %do;                                                                                                                                   
                                                                                                                                        
    %put &errormsg;                                                                                                                     
                                                                                                                                        
    data temp;                                                                                                                          
                                                                                                                                        
     Message="&errormsg";                                                                                                               
                                                                                                                                        
    run;                                                                                                                                
                                                                                                                                        
    title2 "&errormsg";                                                                                                                 
                                                                                                                                        
    proc print data=temp label noobs;                                                                                                   
    run;                                                                                                                                
                                                                                                                                        
 %end;                                                                                                                                  
                                                                                                                                        
 %if &conflicting_types_cnt>0 %then                                                                                                     
 %do;                                                                                                                                   
                                                                                                                                        
    proc sort data=conflicting_types;                                                                                                   
    by variable;                                                                                                                        
    run;                                                                                                                                
                                                                                                                                        
    title2 "There are &conflicting_types_cnt variables in common that have conflicting types";                                          
                                                                                                                                        
    proc print data=conflicting_types label noobs;                                                                                      
    label vartype1="&dsn1" vartype2="&dsn2";                                                                                            
    run;                                                                                                                                
                                                                                                                                        
                                                                                                                                        
 %end;                                                                                                                                  
                                                                                                                                        
 %if &in1_not_in2>0 %then                                                                                                               
 %do;                                                                                                                                   
                                                                                                                                        
    proc sort data=in1_not_in2;                                                                                                         
    by variable;                                                                                                                        
    run;                                                                                                                                
                                                                                                                                        
    title2 Variables in data set &dsn1 but not in &dsn2;                                                                                
                                                                                                                                        
    proc print data=in1_not_in2 label noobs;                                                                                            
    run;                                                                                                                                
                                                                                                                                        
                                                                                                                                        
 %end;                                                                                                                                  
                                                                                                                                        
 %if &in2_not_in1>0 %then                                                                                                               
 %do;                                                                                                                                   
                                                                                                                                        
    proc sort data=in2_not_in1;                                                                                                         
    by variable;                                                                                                                        
    run;                                                                                                                                
                                                                                                                                        
    title2 Variables in data set &dsn2 but not in &dsn1;                                                                                
                                                                                                                                        
    proc print data=in2_not_in1 label noobs;                                                                                            
    run;                                                                                                                                
                                                                                                                                        
 %end;                                                                                                                                  
                                                                                                                                        
 %if %qupcase(%superq(outfile)) ne _WEBOUT %then                                                                                        
 %do;                                                                                                                                   
                                                                                                                                        
    ods &odstype close;                                                                                                                 
                                                                                                                                        
 %end;                                                                                                                                  
                                                                                                                                        
 %put;                                                                                                                                  
 %put INFO: Total number of compared variables: &number_of_compared_variables;                                                          
 %put INFO: Number of non-matching variables: &nonmatch_count;                                                                          
 %put INFO: Number of matching variables: &match_count;                                                                                 
 %put INFO: Number of common variables that have conflicting types: &conflicting_types_cnt;                                             
 %put INFO: Number of variables in &dsn1 not in &dsn2: &in1_not_in2;                                                                    
 %put INFO: Number of variables in &dsn2 not in &dsn1: &in2_not_in1;                                                                    
 %put;                                                                                                                                  
                                                                                                                                        
%mend compare_one_record;                                                                                                               
