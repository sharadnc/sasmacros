/**************************************************************************************************************
* Macro_Name: minimize_character_variables
*
* Purpose: Minimizes the character variables in a sas data set.
*
* Usage: %minimize_character_variables(dataset,out_dataset);
*
* Input_parameters: dataset
*                    Data set to minimize.
*                   out_dataset
*                    Optional. Name of the minimized dataset. If not specified, input
*                    data set is overwritten.
*
* Outputs:  Minimized dataset.
*
* Returns:  None.
*
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

%macro minimize_character_variables(dataset,out_dataset);
%put Start macro minimize_character_variables;

 %local i j dsid dsid_maxlens varname vartype varlen length_stmt;

 %if &out_dataset=%str() %then %let out_dataset=&dataset;

 %let nvarsc=%nvarsc(&dataset);

 %if &nvarsc=0 %then %goto EXIT;

 %let varsc=%varsc(&dataset);

 data __maxlens;

  set &dataset(keep=_CHARACTER_) end=__e;

  array __c{&nvarsc} $ &varsc;

  array __maxlen{&nvarsc} 8;

  retain __maxlen1-__maxlen&nvarsc;

  do __i=1 to dim(__c);

     if length(__c{__i})>__maxlen{__i} then __maxlen{__i}=length(__c{__i});

  end;

  if __e then output;

  keep __maxlen1-__maxlen&nvarsc;

 run;

 %let dsid=%sysfunc(open(&dataset));

 %if &dsid=0 %then
 %do;

    %put ERROR: Data set &dataset could not be opened. Check the Log.;

    %goto EXIT;

 %end;

 %let dsid_maxlens=%sysfunc(open(__maxlens));

 %if &dsid=0 %then
 %do;

    %put ERROR: Data set __maxlens could not be opened. Check the Log.;

    %goto EXIT;

 %end;

 %let rc=%sysfunc(fetch(&dsid_maxlens));

 %let j=0;

 %let length_stmt=;

 %do i=1 %to %sysfunc(attrn(&dsid,nvars));

    %let varname=%sysfunc(varname(&dsid,&i));

    %let vartype=%sysfunc(vartype(&dsid,&i));

    %let varlen=%sysfunc(varlen(&dsid,&i));

    %if &vartype=C %then
    %do;

       %let j=%eval(&j+1);

       %let varlen=$%sysfunc(getvarn(&dsid_maxlens,&j));

    %end;

    %let length_stmt=&length_stmt &varname &varlen;

 %end;

 %let dsid=%sysfunc(close(&dsid));

 %let dsid_maxlens=%sysfunc(close(&dsid_maxlens));

 data &dataset(compress=yes);
  length &length_stmt;
  set &dataset;
  format _character_;
  informat _character_;
 run;

%EXIT:

%put End macro minimize_character_variables;
%mend minimize_character_variables;
