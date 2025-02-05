/**************************************************************************************************************
* Macro_Name:   attrib_to_log.sas
*
* Purpose: Print the ATTRIB statements for all variables in a data set to the Log.
*
* Usage: %attrib_to_log(dataset);
*
* Input_parameters: dataset
*
* Outputs:  None.
*
* Returns:  If error, jumptoexit=1.
*
* Example:
*
* Modules_called: None
*
* Maintenance_History:
*-------------------------------------------------------------------------------------------------------------*
*  Date:      |   Who:         |  Description:                                                                *
*-------------------------------------------------------------------------------------------------------------*
* 12/20/2012  | Michael Gilman | Initial creation.                                                            *
*-------------------------------------------------------------------------------------------------------------*
* HeaderEnd:                                                                                                  *
**************************************************************************************************************/

%macro attrib_to_log(dataset);

 %local dsid nvars var varlen vartype varfmy varinfmt varlabel string;

 %if not %sysfunc(exist(&dataset)) %then
 %do;

    %let errormsg1=&dataset does not exist.;

    %put ERROR: &errormsg1;

    %let jumptoexit=1;

    %goto EXIT;

 %end;

 %let dsid=%sysfunc(open(&dataset));

 %if &dsid=0 %then
  %do;

    %let errormsg1=Could not open data set &dataset..;

    %put ERROR: &errormsg1;

    %let jumptoexit=1;

    %goto EXIT;

 %end;

 %let nvars=%sysfunc(attrn(&dsid,nvars));

 %do i=1 %to &nvars;

    %let var=%sysfunc(varname(&dsid,&i));
    %let varlen=%sysfunc(varlen(&dsid,&i));
    %let vartype=%sysfunc(vartype(&dsid,&i));
    %let varfmt=%sysfunc(varfmt(&dsid,&i));
    %let varinfmt=%sysfunc(varinfmt(&dsid,&i));
    %let varlabel=%sysfunc(varlabel(&dsid,&i));

    %if %superq(varlabel) ne %str() %then %let varlabel=%sysfunc(quote(%superq(varlabel)));
    %else %let varlabel=" ";

    %let varlenType=&varlen;

    %if &vartype=C %then %let varlenType=$&varlenType;

    %let string=Attrib &var length=&varlenType;

    %if %superq(varfmt) ne %str() %then %let string=%superq(string) format=&varfmt;

    %if %superq(varinfmt) ne %str() %then %let string=%superq(string) informat=&varinfmt ;

    %let string=%superq(string) label=&varlabel;

    %put &string%str(;);

 %end;

 %let dsid=%sysfunc(close(&dsid));

%EXIT:

%mend attrib_to_log;
