/**************************************************************************************************************
* Macro_Name: varsc
*
* Purpose: Returns a list of the character variables in a sas data set.
*
* Usage: %varsc(dataset);
*
* Input_parameters: Dataset
*
* Outputs:  None.
*
* Returns:  List of character variables.
/*
* Modules_called: None
*
* Maintenance_History:
*-------------------------------------------------------------------------------------------------------------*
*  Date:      |   Who:        |  Description:                                                                 *
*-------------------------------------------------------------------------------------------------------------*
* 08/14/2012  | Michael Gilman| Initial creation.                                                             *
*-------------------------------------------------------------------------------------------------------------*
* HeaderEnd:                                                                                                  *
**************************************************************************************************************/

%macro varsc(dataset);

 %let varsc=;

 %let dsid=%sysfunc(open(&dataset));

 %if &dsid=0 %then
 %do;

    %put ERROR: Data set &dataset could not be opened. Check the Log.;

    %let nvars=-1;

    %goto EXIT;

 %end;

 %let nvars=0;

 %do i=1 %to %sysfunc(attrn(&dsid,nvars));

    %if %sysfunc(vartype(&dsid,&i))=C %then %let varsc=&varsc %sysfunc(varname(&dsid,&i));

 %end;

 %let dsid=%sysfunc(close(&dsid));

 &varsc

%EXIT:

%mend varsc;