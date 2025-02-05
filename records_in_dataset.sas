/**************************************************************************************************************
* Macro_Name:   records_in_dataset                                                                        
* 
* Purpose: Returns the number of records in a sas data set. 
*                                                                                                              
* Usage: %records_in_dataset(dataset);
*
* Inputs: Data set on which to count the number of records.                                
*                                                                             
* Outputs:  None.                                                             
*                                                                             
* Returns:  Number of data set records.                                        
*           If error, jumptoexit=1 
*
* Example: %let nobs=%records_in_dataset(dataset);
*                                                                                                              
* Modules_called: None
* 
* Maintenance_History:                                                                                        
*-------------------------------------------------------------------------------------------------------------*
*  Date:      |   Who:        |  Description:                                                                 *
*-------------------------------------------------------------------------------------------------------------*
* 12/14/2011  | Michael Gilman   | Initial creation.                                                          *
*-------------------------------------------------------------------------------------------------------------*
* HeaderEnd:                                                                                                  *
**************************************************************************************************************/

%macro records_in_dataset(dataset);
 %local nobs dsid mtype;

 %let nobs=-1;

 %let dsid=%sysfunc(open(&dataset));

 %if &dsid=0 %then
 %do;

    %let errormsg1=Data set &dataset could not be opened. Check the Log;

    %let jumptoexit=1;

    %goto EXIT;

 %end;

 %let mtype=%sysfunc(attrc(&dsid,MTYPE));
 %let anobs=%sysfunc(attrn(&dsid,ANOBS));
 %let arand=%sysfunc(attrn(&dsid,ARAND));

 %if &anobs ne 1 or &arand ne 1 %then
 %do;

    %let dsid=%sysfunc(close(&dsid));

    %let errormsg1=Cannot determine number of records for data set &dataset;

    %let jumptoexit=1;

    %goto EXIT;

 %end;

 %let nobs=%sysfunc(attrn(&dsid,NLOBS));

 %let dsid=%sysfunc(close(&dsid));

%EXIT:

 &nobs

%mend records_in_dataset;

