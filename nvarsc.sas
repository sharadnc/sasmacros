/**************************************************************************************************************
* Macro_Name: nvarsc
*
* Purpose: Returns the number of character variables in a sas data set.
*
* Usage: %nvarsc(dataset);
*
* Input_parameters: Dataset
*
* Outputs:  None.
*
* Returns:  Number of character variables.
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

%macro nvarsc(dataset);

 %let dsid=%sysfunc(open(&dataset));

 %if &dsid=0 %then
 %do;

    %put ERROR: Data set &dataset could not be opened. Check the Log.;

    %let nvars=-1;

    %goto EXIT;

 %end;

 %let nvars=0;

 %do i=1 %to %sysfunc(attrn(&dsid,nvars));

    %if %sysfunc(vartype(&dsid,&i))=C %then %let nvars=%eval(&nvars+1);

 %end;

 %let dsid=%sysfunc(close(&dsid));

 &nvars

%EXIT:

%mend nvarsc;
