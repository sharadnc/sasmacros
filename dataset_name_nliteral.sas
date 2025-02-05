/**************************************************************************************************************                         
* Macro_Name: dataset_name_nliteral                                                                                                      
*                                                                                                                                       
* Purpose: Return data set name as either an nliteral, no quotes, or       
*          only quotes name.                                                                                                                                                                            
*                                                                                                                                                                                                       
*          This is useful when accessing non-sas databases that allow                                                                                                                                   
*          non-standard table names.                                                                                                                                                                    
*                                                                                                                                                                                                       
*          Note that the macro does NOT change the actual data set name; it                                                                                                                             
*          just returns a value which is the converted name.                                                                                                                                            
*                                                                                                                                       
* Usage: dataset_name_nliteral(dataset,returnType);
*                                                                                                                                       
* Input_parameters: dataset                                                                                                                                                            
*                     Data set name to convert. Can be libref.dataset                                                                                                                      
*                   returnType                                                                                                                                                             
*                     Return type. Valid values are:                                                                                                                                       
*                      nliteral, noquotes, onlyquotes  
* 
* Outputs: None.                                                                                        
*                                                                                                                                       
* Returns:  onverted sas data set name.                                                                                                                     
*                                                                                                                                       
* Example:                                                                                                                              
*                                                                                                                                       
* Modules_called:  None.                                                                                                  
*                                                                                                                                       
* Maintenance_History:                                                                                                                  
*-------------------------------------------------------------------------------------------------------------*                         
*  Date:      |   Who:        |  Description:                                                                 *                         
*-------------------------------------------------------------------------------------------------------------*                         
* 24/02/2012  | Michael Gilman|  | Initial creation.                                                          *                         
*-------------------------------------------------------------------------------------------------------------*                         
* HeaderEnd:                                                                                                  *                         
**************************************************************************************************************/                         

%macro dataset_name_nliteral(dataset,returnType);

 %local lib originalDataset len;

 %let validvarname=%sysfunc(getoption(validvarname));

 %if &returnType=%str() %then %let returnType=nliteral;

 %let returnType=%sysfunc(lowcase(&returnType));

 %let lib=;

 %let originalDataset=%bquote(&dataset);

 %if %qscan(%bquote(&dataset),2,%str(.)) ne %str() %then
 %do;

    %let lib=%qscan(%bquote(&dataset),1,%str(.));

    %let len=%length(&lib);

    %let dataset=%qsubstr(%bquote(&dataset),%eval(&len+2));

 %end;

 %let len=%length(%bquote(&dataset));

 %let datasetNoQuotes=%bquote(&dataset);

 %let datasetOnlyQuotes=%bquote(&dataset);

 %let datasetNliteral=%bquote(&dataset);

 %if %sysevalf(&sysver>=9) %then
 %do;

    %if %sysfunc(nvalid(%bquote(&dataset),V7)) %then
    %do;


    %end;
    %else
    %do;

       %if %bquote(%qsubstr(%qsysfunc(reverse(%qsysfunc(lowcase(%bquote(&dataset))))),1,2))=%str(n%')
          or
           %bquote(%qsubstr(%qsysfunc(reverse(%qsysfunc(lowcase(%bquote(&dataset))))),1,2))=%str(n%")
       %then
       %do;

          %let datasetNoQuotes=%substr(%bquote(&dataset),1,%eval(&len-1));

          %let datasetNoQuotes=%sysfunc(dequote(&datasetNoQuotes));

          %let datasetOnlyQuotes=%sysfunc(quote(&datasetNoQuotes));

          %let datasetNliteral=%sysfunc(quote(&datasetNoQuotes))n;

       %end;
       %else
       %if %qsubstr(%bquote(&dataset),1,1)=%str(%') and %qsubstr(%qsysfunc(reverse(&dataset)),1,1)=%str(%')
          or
           %qsubstr(%bquote(&dataset),1,1)=%str(%") and %qsubstr(%qsysfunc(reverse(&dataset)),1,1)=%str(%")
       %then
       %do;

          %let dataset=%sysfunc(dequote(&dataset));

          %let datasetNoQuotes=&dataset;

          %let datasetOnlyQuotes=%sysfunc(quote(&datasetNoQuotes));

          %let datasetNliteral=%sysfunc(quote(&dataset))n;

       %end;
       %else
       %do;

          %let datasetNliteral=%sysfunc(nliteral(%bquote(&dataset)));

          %let datasetNoQuotes=&dataset;

          %let datasetOnlyQuotes=%sysfunc(quote(&datasetNoQuotes));

       %end;

    %end;

 %end;

 %if &lib ne %str() %then
 %do;

    %let datasetNliteral=%str(&lib).&datasetNliteral;

    %let datasetNoQuotes=%str(&lib).&datasetNoQuotes;

    %let datasetOnlyQuotes=%str(&lib).&datasetOnlyQuotes;

 %end;

 %let dataset=%bquote(&originalDataset);

 %if &returnType=nliteral %then &datasetNliteral;
 %if &returnType=noquotes %then &datasetNoQuotes;
 %if &returnType=onlyquotes %then &datasetOnlyQuotes;

%mend dataset_name_nliteral;

