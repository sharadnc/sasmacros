/**************************************************************************************************************                                                                                                                                                 
* Macro_Name:   saslib_cleanup                                                                                                                                                                                                                                  
*                                                                                                                                                                                                                                                               
* Purpose: This macro deletes data sets from the &rootloc/&env/data subfolders whose process date is less than                                                                                                                                                                 
*          the input cutoff date but are NOT final output data sets as defined by the 
*          out_ macro variables.                                                                                                                                                                                            
*                                                                                                                                                                                                                                                               
*          Note that you can also use this macro to simply display all the non-final data sets
*          if you set the offset macro parameter to 0. 
*                                                                                                                                                                                                                                                               
* Usage: %saslib_cleanup(env=,cutoff_date=,offset=3,list_only=Y);                                                                                                                                                                                           
*                                                                                                                                                                                                                                                               
* Input_parameters: env                                                                                                                                                                                                                                         
*                    labs, dev, qa, prod                                                                                                                                                                                                                        
*                   cutoff_date                                                                                                                                                                                                                                 
*                    Date which acts as the cutoff date. If missing, today's date minus the                                                                                                                                                                     
*                    offset months is used.                                                                                                                                                                                                                     
*                    If input, date must be formatted as mmddyy.                                                                                                                                                                                                                     
*                   offset                                                                                                                                                                                                                                      
*                    When cutoff_date is missing, the number of months to offset today's date.                                                                                                                                                                  
*                    Default: 3                                                                                                                                                                                                                                 
*                   list_only                                                                                                                                                                                                                                   
*                    Y/N Default: Y. Specify Y if you just want to display which data sets can be deleted.                                                                                                                                                       
*                        Otherwise, specify N and the found data sets will be deleted.                                                                                                                                                                        
*                   list_all 
*                    Y/N Default: N. Specify Y if to list all data sets including final the output data sets 
*                        as defined by the out_ macro variables. Note that in this case, no data sets are deleted. 
*                   sortby                                                                                                                                                                                                                                           
*                    Sort order of printed results.                                                                                                                                                                                                                                           
*                   results_dataset                                                                                                                                                                                                                                            
*                    SAS data set containing the results. Default: work.saslib_results                                                                                                                                                                                                                                           
*                                                                                                                                                                                                                                                               
* Outputs:  None                                                                                                                                                                                                                                                
*                                                                                                                                                                                                                                                               
* Returns:  None                                                                                                                                                                                                                                                
*                                                                                                                                                                                                                                                               
* Example:                                                                                                                                                                                                                                                      
*                                                                                                                                                                                                                                                               
* Modules_called: %lock_on_member                                                                                                                                                                                                                               
*                 %lock_off_member                                                                                                                                                                                                                              
*                                                                                                                                                                                                                                                               
* Maintenance_History:                                                                                                                                                                                                                                          
*-------------------------------------------------------------------------------------------------------------*                                                                                                                                                 
*  Date:      |   Who:        |  Description:                                                                 *                                                                                                                                                 
*-------------------------------------------------------------------------------------------------------------*                                                                                                                                                 
* 04/06/2012  | Michael Gilman| Initial creation.                                                             *                                                                                                                                                 
*-------------------------------------------------------------------------------------------------------------*                                                                                                                                                 
* HeaderEnd:                                                                                                  *                                                                                                                                                 
**************************************************************************************************************/                                                                                                                                                 
                                                                                                                                                                                                                                                                
%macro saslib_cleanup(env=labs,cutoff_date=,offset=3,list_only=Y,list_all=N,
                      sortby=security_level lob subjectArea pgmname,
                      results_dataset=work.saslib_results 
                     );  
%put Start macro saslib_cleanup; 
                                                                                                                                                                                                                                                                
 %local obs memname memnames i j k ii dd len date dataset deleted dir                                                                                                                                                                                              
        dnum cutoff_datec fref did did_security_level did_lob security_level lob subjectArea                                                                                                                                                                                         
		root_data dsid obs did_subjectArea lib dataset
 ;                                                                                                                                                                                                                                                              

 %if %sysfunc(fileref(macrosEG)) %then
 %do;
    filename macrosEG "&rootloc/&env/macros";
    options mautosource mrecall sasautos=(macrosEG sasautos);
 %end;

 libname adminlib "&rootloc/&env/admin/data"; 

 %if &syslibrc ne 0 %then
 %do;
 
    %PUT ERROR: Could not assign libref adminlib to &rootloc/&env/admin/data;

	%goto ERREXIT;

 %end; 
 
 libname rstats "&rootloc/&env/runtimestats";  
 
 %if &syslibrc ne 0 %then
 %do;
 
    %PUT ERROR: Could not assign libref rstats to &rootloc/&env/runtimestats;

	%goto ERREXIT;

 %end; 

 %if %sysfunc(exist(adminlib.programsetup))=0 %then
 %do;
 
    %PUT ERROR: adminlib.programsetup does not exist.;

	%goto ERREXIT;

 %end; 

 %if %sysfunc(exist(rstats.program_output_files))=0 %then
 %do;
 
    %PUT ERROR: rstats.program_output_files does not exist.;

	%goto ERREXIT;

 %end; 
                                                                                                                                                                                                                                                                
 %if &cutoff_date=%str() %then                                                                                                                                                                                                                                  
 %do;                                                                                                                                                                                                                                                           
                                                                                                                                                                                                                                                                
    %let date=%sysfunc(intnx(month,%sysfunc(today()),-&offset));                                                                                                                                                                                                
                                                                                                                                                                                                                                                                
    %let cutoff_date=%sysfunc(putn(&date,mmddyy6));                                                                                                                                                                                                              
                                                                                                                                                                                                                                                                
 %end;                                                                                                                                                                                                                                                          
                                                                                                                                                                                                                                                                
 %let cutoff_date=%sysfunc(inputn(&cutoff_date,mmddyy));   

 %let cutoff_datec=%sysfunc(putn(&cutoff_date,worddate));  
                                                                                                                                                                                                                                                                
 %let list_only=%upcase(&list_only); 

 %let root_data=&rootloc/&env/data; 

 %let dataset=%scan(&results_dataset,2,%str(.));

 %if &dataset=%str() %then 
 %do;

    %let lib=work;

	%let dataset=&results_dataset;

 %end;
 %else
 %do;

    %let lib=%scan(&results_dataset,1,%str(.));

 %end;
                                                                                                                                                                                                                                                                
 proc datasets lib=&lib nolist nowarn;                                                                                                                                                                                                                          
 delete &dataset;                                                                                                                                                                                                                                              
 quit;  

 %if &syserr>4 %then
 %do;

    %PUT ERROR: Could not delete &results_dataset;

	%goto ERREXIT;

 %end; 

 %lock_on_member(adminlib.programsetup);                                                                                                                                                                                                                  
                                                                                                                                                                                                                                                                
 proc sql;                                                                                                                                                                                                                                                      
  create table pgmnames as                                                                                                                                                                                                                                 
  select distinct pgmid, pgmname 
  from adminlib.programsetup 
  order by pgmid 
  ;                                                                                                                                                                                                                                                             
 quit; 
                                                                                                                                                                                                                                                                 
 %lock_off_member(adminlib.programsetup);  

 %if &list_all=N %then
 %do;

    %lock_on_member(rstats.program_output_files);                                                                                                                                                                                                                  
                                                                                                                                                                                                                                                                
    proc sql;                                                                                                                                                                                                                                                      
     create table keep_datasets as                                                                                                                                                                                                                                 
     select distinct lowcase(file) as memname                                                                                                                                                                                                                               
     from rstats.program_output_files                                                                                                                                                                                                                              
     ;                                                                                                                                                                                                                                                             
    quit;                                                                                                                                                                                                                                                          
                                                                                                                                                                                                                                                                
    %lock_off_member(rstats.program_output_files);   

 %end; 
                                                                                                                                                                                                                                                                
 %do i=1 %to 4;                                                                                                                                                                                                                                                 
                                                                                                                                                                                                                                                                
    %let security_level=L&i;                                                                                                                                                                                                                                    
                                                                                                                                                                                                                                                                
    %let fref=;         

    %let dir=&root_data/&security_level; 

    %let rc=%qsysfunc(filename(fref,%bquote(&dir)));                                                                                                                                                                                        
                                                                                                                                                                                                                                                                
    %let did_security_level=%sysfunc(dopen(&fref));                                                                                                                                                                                                             
                                                                                                                                                                                                                                                                
    %if &did_security_level<=0 %then %goto NEXT_SEC; 
                                                                                                                                                                                                                                                                
    %let dnum_security_level=%sysfunc(dnum(&did_security_level));                                                                                                                                                                                               
                                                                                                                                                                                                                                                                
    %if &dnum_security_level<=0 %then %goto NEXT_SEC; 
                                                                                                                                                                                                                                                                
    %do j=1 %to &dnum_security_level;                                                                                                                                                                                                                           
                                                                                                                                                                                                                                                                
       %let lob=%qsysfunc(dread(&did_security_level,&j));                                                                                                                                                                                                       
                                                                                                                                                                                                                                                                
       %let fref=;       

       %let dir=&root_data/&security_level/&lob; 
                                                                                                                                                                                                                                                                
       %let rc=%qsysfunc(filename(fref,%bquote(&dir)));                                                                                                                                                                                
                                                                                                                                                                                                                                                                
       %let did_lob=%sysfunc(dopen(&fref));                                                                                                                                                                                                                     
                                                                                                                                                                                                                                                                
       %if &did_lob<=0 %then %goto NEXT;                                                                                                                                                                                                                        
                                                                                                                                                                                                                                                                
       %let dnum_lob=%sysfunc(dnum(&did_lob));                                                                                                                                                                                                                  
                                                                                                                                                                                                                                                                
       %if &dnum_lob<=0 %then %goto NEXT;                                                                                                                                                                                                                       
                                                                                                                                                                                                                                                                
       %do dd=1 %to &dnum_lob;                                                                                                                                                                                                                                  
                                                                                                                                                                                                                                                                
          %let subjectArea=%qsysfunc(dread(&did_lob,&dd));

          %let dir=&root_data/&security_level/&lob/&subjectArea; 

		  %let fref=;    
                                                                                                                                                                                                                                                                
          %let rc=%qsysfunc(filename(fref,%bquote(&dir)));                                                                                                                                                                                
                                                                                                                                                                                                                                                                
          %let did_subjectArea=%sysfunc(dopen(&fref));                                                                                                                                                                                                                     
                                                                                                                                                                                                                                                                
          %if &did_subjectArea<=0 %then %goto NEXT3;                                                                                                                                                                                                                        
                                                                                                                                                                                                                                                                
          %let dnum_subjectArea=%sysfunc(dnum(&did_lob));                                                                                                                                                                                                                  
                                                                                                                                                                                                                                                                
          %if &dnum_subjectArea<=0 %then %goto NEXT3;  

          libname saslib "&dir";                                                                                                                                                                                                                             
                                                                                                                                                                                                                                                                
          %if &syslibrc=0 %then                                                                                                                                                                                                                                 
          %do;                                                                                                                                                                                                                                                  
                                                                                                                                                                                                                                                                
             proc sql noprint;                                                                                                                                                                                                                                  
              select lowcase(memname) into : memnames separated by ' '                                                                                                                                                                                                   
              from dictionary.tables                                                                                                                                                                                                                            
              where libname='SASLIB' 
			  %if &list_all=N %then
			  %do;
                 and lowcase(memname) not in (select memname from keep_datasets)
              %end; 
              ;                                                                                                                                                                                                                                                 
             quit;                                                                                                                                                                                                                                              
                                                                                                                                                                                                                                                                
             %let obs=&sqlobs;                                                                                                                                                                                                                                  
                                                                                                                                                                                                                                                                
             %do k=1 %to &obs;                                                                                                                                                                                                                                  
                                                                                                                                                                                                                                                                
                %let memname=%scan(&memnames,&k,%str( ));                                                                                                                                                                                                       
                                                                                                                                                                                                                                                                
                %let date=%scan(&memname,2,%str(_));                                                                                                                                                                                                            
                                                                                                                                                                                                                                                                
                %let len=%length(&date);                                                                                                                                                                                                                        
                                                                                                                                                                                                                                                                
                %if &len=4 %then 
                %do;

                   %let date=01&date; 

				   %let date=%sysfunc(inputn(&date,ddmmyy6));  

                %end; 
                %else %let date=%sysfunc(inputn(&date,mmddyy6));                                                                                                                                                                                                     
                                                                                                                                                                                                                                                                
                %if &date>=&cutoff_date %then %goto NEXT2;                                                                                                                                                                                                      

                %let pgmid=%substr(%scan(&memname,1,%str(_)),3);
                                                                                                                                                                                                                                                                
                %let deleted=No;                                                                                                                                                                                                                                
                                                                                                                                                                                                                                                                
                %if &list_only=N or &list_all=Y %then                                                                                                                                                                                                                          
                %do;                                                                                                                                                                                                                                            
                                                                                                                                                                                                                                                                
                   proc datasets lib=saslib nolist nowarn;                                                                                                                                                                                                      
                   delete &memname;                                                                                                                                                                                                                             
                   quit;                                                                                                                                                                                                                                        
                                                                                                                                                                                                                                                                
                   %if &syserr<=4 %then %let deleted=Yes;                                                                                                                                                                                                       
                                                                                                                                                                                                                                                                
                %end;                                                                                                                                                                                                                                           
                                                                                                                                                                                                                                                                
                data temp;                                                                                                                                                                                                                                      
                  length dir $200 pgmid $3 security_level $2 lob $80 subjectArea $80 dataset $32 deleted $3;                                                                                                                                                                                                        
				  dir="&dir";
                  pgmid="&pgmid";
                  security_level="&security_level"; 
                  lob="&lob";
                  subjectArea="&subjectArea";
                  dataset="&memname";                                                                                                                                                                                                                           
                  deleted="&deleted";                                                                                                                                                                                                                           
                 run;                                                                                                                                                                                                                                           
                                                                                                                                                                                                                                                                
                 proc append base=&results_dataset data=temp force;                                                                                                                                                                                                    
                 run;                                                                                                                                                                                                                                           
                                                                                                                                                                                                                                                                
             %NEXT2:                                                                                                                                                                                                                                            
                                                                                                                                                                                                                                                                
             %end;                                                                                                                                                                                                                                              
                                                                                                                                                                                                                                                                
          %end;  

       %NEXT3: 

	      %if &did_subjectArea>0 %then %let did_subjectArea=%sysfunc(dclose(&did_subjectArea));
                                                                                                                                                                                                                                                                
       %end;                                                                                                                                                                                                                                                    
                                                                                                                                                                                                                                                                
       %NEXT:                                                                                                                                                                                                                                                   
                                                                                                                                                                                                                                                                
       %if &did_lob>0 %then %let did_lob=%sysfunc(dclose(&did_lob));                                                                                                                                                                                                        
                                                                                                                                                                                                                                                                
    %end;                                                                                                                                                                                                                                                       
                                                                                                                                                                                                                                                                
 %NEXT_SEC:    

    %if &did_security_level>0 %then %let did_security_level=%sysfunc(dclose(&did_security_level));  
                                                                                                                                                                                                                                                                
 %end;                                                                                                                                                                                                                                                          
                                                                                                                                                                                                                                                                
%EXIT:                                                                                                                                                                                                                                                          
            
 %if %sysfunc(exist(&results_dataset)) %then
 %do;

    proc sort data=&results_dataset;
    by pgmid;
    run;

    data &results_dataset;
    merge &results_dataset(in=in1) pgmnames;
    by pgmid;

    if in1;

   run;

    proc sort data=&results_dataset;
    by &sortby dataset;
    run;

    %let dsid=%sysfunc(open(&results_dataset));

    %let obs=%sysfunc(attrn(&dsid,nlobs));

    %let dsid=%sysfunc(close(&dsid));
 
    title1 "&obs data sets satisfying cutoff date &cutoff_datec";                                                                                                                                                                                                       
	title2 "Root location &root_data";
                                                                                                                                                                                                                                                                
    proc print data=&results_dataset(drop=dir pgmid) label;  
    by &sortby; 
    id &sortby; 
    label security_level='Security Level' lob='LOB' subjectArea='Subject Area'
          dataset='Data Set' deleted='Deleted' pgmname='Program'
    ;
    run;    

 %end; 
 %else
 %do;
 
    title1 "No data sets satisfying cutoff date &cutoff_datec";  
    title2 "Root location &root_data"; 

	data temp;
	 Info="No data sets satisfying cutoff date &cutoff_datec";
    run;
                                                                                                                                                                                                                                                                
    proc print data=temp noobs;                                                                                                                                                                                                                                     
    run;    

 %end; 

%ERREXIT:
                                                                                                                                                                                                                                                                
%put End macro saslib_cleanup; 
%mend saslib_cleanup;

options mprint;  
 
%let rootloc=/u04/data/cig_ebi/dmg;    

%saslib_cleanup(env=dev,offset=0);
