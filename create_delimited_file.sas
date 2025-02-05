/**************************************************************************************************************                         
* Macro_Name:   create_delimited_file                                                                                                         
*                                                                                                                                       
* Purpose: Macro to create a delimited file                                                                                
*                                                                                                                                       
* Usage: %create_delimited_file(dataset=,filename=,dlmr=,qtes=,header=,label=);                                                                                               
*                                                                                                                                       
* Input_parameters: dataset                                                                                                            
*                    name of the Unix dataset 
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
* 11/14/2012  | Sharad           | Initial creation.                                                          *                         
*-------------------------------------------------------------------------------------------------------------*                         
* HeaderEnd:                                                                                                  *                         
**************************************************************************************************************/                         
                                                                                                                                        
%macro create_delimited_file
  (
   dataset=_last_ ,  /* Dataset to write */ 
   filename=print ,  /* File to write to */ 
   dlmr=","       ,  /* Delimiter between values */ 
   qtes="no"      ,  /* Should SAS quote all character variables? */ 
   header="no"    ,  /* Do you want a header line w/ column names? */ 
   label="no"        /* Should labels be used instead of var names in header? */ 
  );


proc contents data=&dataset out=___out_ noprint;run;

/* Return to orig order */ 
proc sort data=___out_; 
  by varnum;       
run;

/* Build list of variable names */ 
data _null_;                           
  set ___out_ nobs=count;
  call symput("name"!!left(put(_n_,3.)),name);
  call symput("type"!!left(put(_n_,3.)),type);

  /* Use var name when label not present */ 
  if label=" " then label=name;         
  call symput("lbl"!!left(put(_n_,3.)),label);
  if _n_=1 then call symput("numvars", trim(left(put(count, best.))));
run;

/*Remove the temporary contents dataset created above*/
proc datasets lib=work nolist;
 delete ___out_;
quit;

/* Create file */ 

data _null_;
  set &dataset;
  file &filename;
  %global temp;
  %if &qtes="yes" %then %let temp='"';
  %else %let temp=' ';

%if &header="yes" %then 
%do;
    /* Conditionally add column names */ 
  if _n_=1 then 
  do;    
        put %if &label="yes" %then 
        %do;
           %do i=1 %to &numvars-1;
               &temp  "%trim(%bquote(&&lbl&i)) " +(-1) &temp &dlmr
           %end;
           &temp "%trim(%bquote(&&lbl&numvars)) " &temp;
        %end;
    %else 
    %do;
      %do i=1 %to &numvars-1;
        &temp "%trim(&&name&i) " +(-1) &temp &dlmr
      %end;
      &temp "%trim(&&name&numvars) " &temp ;
    %end;
  end;

%end;

/* Build PUT stmt to write values */ 
  put                                   
     %do i = 1 %to &numvars -1;
       %if &&type&i ne 1 and &qtes="yes" %then 
         %do;
         '"' &&name&i +(-1) '"' &dlmr
         %end;

       %else 
         %do;
            &&name&i +(-1) &dlmr
         %end;
     %end;

     %if &&type&i ne 1 and &qtes="yes" %then 
       %do;
           /* Write last varname */ 
            '"' &&name&numvars +(-1) '"';     
       %end;
     %else 
       %do;
         /* Write last varname */ 
         &&name&numvars;                   
       %end;
run;
%mend create_delimited_file;