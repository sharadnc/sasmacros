/**************************************************************************************************************
* Macro_Name: get_common_vars
*
* Purpose: Get the common variables from up to 10 data sets.
*
* Usage: %get_common_vars(dsn1,dsn2,etc.)
*
* Input_parameters: Up to 10 data sets.
*
* Outputs:  None
*
* Returns:  Common variables.
*
* Example:  %let commonVars=%get_common_vars(dsn1,dsn2,dsn3);
*
* Modules_called: None
*
* Maintenance_History:
*-------------------------------------------------------------------------------------------------------------*
*  Date:      |   Who:        |  Description:                                                                 *
*-------------------------------------------------------------------------------------------------------------*
* 05/20/2012  | Michael Gilman| Initial creation                                                              *
*-------------------------------------------------------------------------------------------------------------*
* HeaderEnd:                                                                                                  *
**************************************************************************************************************/

%macro get_common_vars(dsn1,dsn2,dsn3,dsn4,dsn5,dsn6,dsn7,dsn8,dsn9,dsn10);

 %local rc i j more commonVars numberOfDatasets varnum varname nvars
        dsid1 dsid2 dsid3 dsid4 dsid5 dsid6 dsid7 dsid8 dsid9 dsid10
 ;

 %let i=0;

 %let more=1;

 %let numberOfDatasets=0;

 %do %while(&more);

    %let i=%eval(&i+1);

    %if &&dsn&i=%str() %then %let more=0;

    %if &&dsn&i=%str() %then %goto NEXT;

    %let numberOfDatasets=%eval(&numberOfDatasets+1);

    %let dsid&numberOfDatasets=%sysfunc(open(&&dsn&i));

 %end;

%NEXT:

 %if &numberOfDatasets=0 %then %goto EXIT;

 %let commonVars=;

 %let nvars=%sysfunc(attrn(&dsid1,nvars));

 %do i=1 %to &nvars;

    %let varname=%sysfunc(varname(&dsid1,&i));

    %let vartype=%sysfunc(vartype(&dsid1,&i));

    %do j=2 %to &numberOfDatasets;

       %let varnum=%sysfunc(varnum(&&dsid&j,&varname));

       %if &varnum=0 %then %goto NEXT2;

       %if &vartype ne %sysfunc(vartype(&&dsid&j,&varnum)) %then %goto NEXT2;

    %end;

    %let commonVars=&commonVars &varname;

%NEXT2:

 %end;

 %do i=1 %to &numberOfDatasets;

    %let rc=%sysfunc(close(&&dsid&i));

 %end;

&commonVars

%EXIT:

%mend get_common_vars;
