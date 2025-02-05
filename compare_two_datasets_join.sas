/**************************************************************************************************************
* Macro_Name: compare_two_datasets_join
*
* Purpose: Compare 2 sas data sets using proc compare producing easy to read
*          output of the comparison.
*
* Usage: %compare_two_datasets_join(dsn1,dsn2,outfile=,equalobs=1
*                              odsOutput=1,compareVariables=1,calledFromCompareLibraries=0)
*
* Input_parameters: dsn1
*                    Data set 1 to compare
*                   dsn2
*                    Data set 2 to compare
*                   outfile=
*                    html or pdf file for the results
*                   proc_compare_match_method=
*                    The match= value for proc compare                                        .
*                    Default: match=absolute                                       .
*                   equalobs=
*                    1/0 If set to 1, data sets must have same number of records, else
*                        processing stops and a warning is put to the log. If 0,
*                        comparison proceeds regardless.
*                        Default: 1.
*                   odsOutput
*                    1/0 If set to 0, ods output is not generated.
*                        Default: 1.
*                   compareVariables
*                    1/0 If set to 1, variable differences are printed.
*                        Default: 1.
*                   calledFromCompareLibraries
*                    1/0 Set to 1 when called from %compare_two_libraries.
*                        Default: 0.
*
* Outputs: The macro creates up to 4 data sets:
*           comparison_details
*            Data set of comparision summary results.
*           in1vars
*            Variables in dsn1 but not in dsn2
*           in2vars
*            Variables in dsn2 but not in dsn1
*           diffattr
*            Variables common to the 2 data sets but have either different
*            lengths or types.
*
* Returns:  errormsg1
*
* Example:
*
* Modules_called:  %records_in_table
*
* Maintenance_History:
*-------------------------------------------------------------------------------------------------------------*
*  Date:      |   Who:        |  Description:                                                                 *
*-------------------------------------------------------------------------------------------------------------*
* 24/02/2012  | Michael Gilman| Initial creation.                                                             *
* 24/07/2012  | Michael Gilman| Added new parameter: proc_compare_match_method                                *
*             |               | This allows you to specify the match= value for proc compare. Previously,     *
*             |               | this was hard coded as match=exact.                                           *
* 10/17/2012  | Michael Gilman| Added new global returned parameter: datasets_match                           *
*-------------------------------------------------------------------------------------------------------------*
* HeaderEnd:                                                                                                  *
**************************************************************************************************************/

%macro compare_two_datasets_join(dsn1,dsn2,proc_compare_match_method=absolute,
                            outfile=,equalobs=0,
                            odsOutput=1,compareVariables=1,calledFromCompareLibraries=0
                           );
%put Start macro compare_two_datasets_join;

 %global errormsg1 datasets_match;

 %let print_differences=100;

 %let datasets_match=0;

 %let errormsg1=;

 %local dsid obs1 obs2 lib1 lib2 memname1 memname2 nvars1 nvars2 in1vars in2vars
        diffattr i
 ;

 %if %sysfunc(exist(&dsn1))=0 %then
 %do;

    %let errormsg1=ERROR: &dsn1 does not exist.;

    %put &errormsg1;

    %goto EXIT;

 %end;

 %if %sysfunc(exist(&dsn2))=0 %then
 %do;

    %let errormsg1=ERROR: &dsn2 does not exist.;

    %put &errormsg1;

    %goto EXIT;

 %end;

 %if %superq(outfile) ne %str() %then
 %do;

    %let odstype=;

    %if %upcase(%scan(&outfile,-1,%str(.)))=HTM  %then %let odstype=html;
    %if %upcase(%scan(&outfile,-1,%str(.)))=HTML %then %let odstype=html;
    %if %upcase(%scan(&outfile,-1,%str(.)))=PDF  %then %let odstype=PDF;

    %if %superq(odstype)=%str() %then
    %do;

       %let errormsg1=ERROR: Invalid file extension for outfile parameter.;

       %put;
       %put &errormsg1;
       %put;

       %goto EXIT;

    %end;

 %end;

 %let outDsn=comparison_details;

 %let dsn1=%upcase(&dsn1);
 %let dsn2=%upcase(&dsn2);

 %records_in_table(&dsn1);

 %let obs1=&nobs;

 %records_in_table(&dsn2);

 %let obs2=&nobs;

 %if &obs1 ne &obs2 %then
 %do;

    %put;
    %put WARNING: Data sets have different number of observations.;
    %put WARNING: &dsn1: &obs1 observations.;
    %put WARNING: &dsn2: &obs2 observations.;
    %put;

    %if &equalobs %then
    %do;

       %put WARNING: Comparison not done.;

       %let errormsg1=WARNING: Data sets have different number of observations. Comparison not done.;

       %goto EXIT;

    %end;

 %end;

 %if %scan(%superq(dsn1),2,%str(.))=%str() %then %let dsn1=WORK.&dsn1;
 %else %let lib1=%scan(%superq(dsn1),2,%str(.));

 %if %scan(%superq(dsn2),2,%str(.))=%str() %then %let dsn2=WORK.&dsn2;
 %else %let lib2=%scan(%superq(dsn2),2,%str(.));

 %let lib1=%scan(&dsn1,1,%str(.));
 %let lib2=%scan(&dsn2,1,%str(.));

 %if %sysfunc(libref(&lib1)) %then
 %do;

    %let errormsg1=ERROR: Libref &lib1 not assigned.;

    %put;
    %put &errormsg1;
    %put;

    %goto EXIT;

 %end;

 %if %sysfunc(libref(&lib2)) %then
 %do;

    %let errormsg1=ERROR: Libref &lib2 not assigned.;

    %put;
    %put &errormsg1;
    %put;

    %goto EXIT;

 %end;

 options compress=yes;

 %let memname1=%scan(&dsn1,2,%str(.));
 %let memname2=%scan(&dsn2,2,%str(.));

 proc sql;
 create table vars1 as
 select upcase(name) as name label='Variable', upcase(type) as type, length
 from dictionary.columns
 where libname="&lib1" and memtype in ('DATA' 'VIEW')
   and memname="&memname1"
 order by calculated name
 ;
 quit;

 %let nvars1=&sqlobs;

 proc sql;
 create table vars2 as
 select upcase(name) as name label='Variable', upcase(type) as type, length
 from dictionary.columns
 where libname="&lib2" and memtype in ('DATA' 'VIEW')
   and memname="&memname2"
 order by calculated name
 ;
 quit;

 %let nvars2=&sqlobs;

 data in1vars(rename=(type1=type) drop=type2) in2vars(rename=(type2=type) drop=type1);

  merge vars1 (in=in1 rename=(type=type1)) vars2 (in=in2 rename=(type=type2)) end=e;
  by name;

  if in1 and in2 and type1=type2 then matchvars+1;
  else
  if in1 and not in2 then output in1vars;
  else
  if in2 and not in1 then output in2vars;

  if e then call symputx('matchvars',matchvars);

  drop matchvars;

 run;

 %let dsid=%sysfunc(open(in1vars));

 %let in1vars=%sysfunc(attrn(&dsid,nlobs));

 %let dsid=%sysfunc(close(&dsid));

 %let dsid=%sysfunc(open(in2vars));

 %let in2vars=%sysfunc(attrn(&dsid,nlobs));

 %let dsid=%sysfunc(close(&dsid));


 data diffattr;

  merge vars1 (in=in1) vars2 (in=in2 rename=(type=type2 length=length2));
  by name;

  if in1 and in2;

  if type ne type2 or length ne length2 then output;

  label type="&dsn1 Type" length="&dsn1 Length" type2="&dsn2 Type" length2="&dsn2 Length";

 run;

 %let dsid=%sysfunc(open(diffattr));

 %let diffattr=%sysfunc(attrn(&dsid,nlobs));

 %let dsid=%sysfunc(close(&dsid));

 proc datasets lib=work nolist nowarn;
 delete &outDsn _alldiff_vars_ _alldiff_values_ _allvars_ _allvars1_ _allvars2_
 ;
 quit;

 %let commonvars=%get_common_vars(&dsn1,&dsn2);;

 proc sort data=&dsn1 force out=_temp1(keep=&commonvars);
 by &commonvars;
 run;


 proc sort data=&dsn2 force out=_temp2(keep=&commonvars);
 by &commonvars;
 run;

 data in1_not_in2 in2_not_in1;

  __in1=0;
  __in2=0;

  merge _temp1(in=__in1) _temp2(in=__in2) end=__e;
  by &commonvars;

  if __in1 and __in2 then __obs_in_common+1;
  else
  if __in1 and not __in2 then output in1_not_in2;
  else
  if __in2 and not __in1 then output in2_not_in1;

  if __e then call symputx('obs_in_common',__obs_in_common);

  drop __obs_in_common;

 run;

 %let dsid=%sysfunc(open(in1_not_in2));

 %let in1_not_in2_obs=%sysfunc(attrn(&dsid,nlobs));

 %let dsid=%sysfunc(close(&dsid));


 %let dsid=%sysfunc(open(in2_not_in1));

 %let in2_not_in1_obs=%sysfunc(attrn(&dsid,nlobs));

 %let dsid=%sysfunc(close(&dsid));


 data __smyTemplate;

  length Attribute $200 seq 4;

  label Attribute='Comparison details';

  seq=1;
  attribute="Total Number of records read from &dsn1";
  value=&obs1;
  output;

  seq=2;
  attribute="Total Number of records read from &dsn2";
  value=&obs2;
  output;

  seq=3;
  attribute="Number of matching records";
  value=&obs_in_common;
  output;

  seq=4;
  attribute="Number of records in &dsn1 that don't match &dsn2";
  value=&in1_not_in2_obs;
  output;

  seq=5;
  attribute="Number of records in &dsn2 that don't match &dsn1";
  value=&in2_not_in1_obs;
  output;


  seq=6;
  attribute="Number of common variables with Differing Attributes";
  value=&diffattr;
  output;

  seq=7;
  attribute="Number of variables in &dsn1";
  value=&nvars1;
  output;
  value=0;

  seq=8;
  attribute="Number of variables in &dsn2";
  value=&nvars2;
  output;

  seq=9;
  attribute="Number of variables in Common";
  value=&matchvars;
  output;

  seq=10;
  attribute="Number of variables in &dsn1 but not in &dsn2";
  value=&in1vars;
  output;

  seq=11;
  attribute="Number of variables in &dsn2 but not in &dsn1";
  value=&in2vars;
  output;

  format value comma32.;

 run;

 proc sort data=__smyTemplate;
 by seq;
 run;

 %if %superq(outfile)=%str() %then %goto EXIT;

 %let maxtitle=0;

 proc sql noprint;
  select max(number) into :maxtitle
  from dictionary.titles
  where text ne ''
  ;
 quit;

 %let maxtitle=&maxtitle;

 %if &maxtitle=%str() or &maxtitle=%str(.) %then %let maxtitle=0;

 %let maxtitle=%eval(&maxtitle+1);

 options nocenter;

 ods listing close;

 %let datetime=%sysfunc(datetime());

 %let datetime=%sysfunc(putn(&datetime,datetime.));

 %if &odsOutput %then
 %do;

    ods &odstype body="&outfile" style=styles.analysis;

 %end;

 %if &calledFromCompareLibraries %then
 %do;

    ods proclabel "%scan(&dsn1,2,%str(.))";

 %end;
 %else
 %do;

    ods proclabel "&dsn1 and &dsn2";

 %end;

 ods pdf pdftoc=1;

 title&maxtitle "Compare &dsn1 with &dsn2 &datetime";

 %if &in1_not_in2_obs=0 and &in2_not_in1_obs=0 %then
 %do;


    title%eval(&maxtitle+1) "Data sets match";

    %let datasets_match=1;

 %end;
 %else
 %do;

    title%eval(&maxtitle+1) "Data sets don't match";

    %let datasets_match=0;

 %end;

 proc print data=__smyTemplate label;
 var attribute value;
 run;

 %if &compareVariables %then
 %do;

    %if &in1vars %then
    %do;

       title%eval(&maxtitle+1) "Variables in &dsn1 but not in &dsn2";

       proc print data=in1vars;
       var name type length;
       run;

    %end;

    %if &in2vars %then
    %do;

       title%eval(&maxtitle+1) "Variables in &dsn2 but not in &dsn1";

       proc print data=in2vars;
       var name type length;
       run;

    %end;

    %if &diffattr %then
    %do;

       title%eval(&maxtitle+1) "Variables in common but with different attributes";

       proc print data=diffattr label;
       run;

    %end;

 %end;

    title%eval(&maxtitle+1) "Records in &dsn1 that don't match &dsn2 (first 100 records only)";

    proc print data=in1_not_in2(obs=&print_differences) label noobs;
    run;

    title%eval(&maxtitle+1) "Records in &dsn2 that don't match &dsn1 (first 100 records only)";

    proc print data=in2_not_in1(obs=&print_differences) label noobs;
    run;


 %if &odsOutput %then
 %do;

    ods &odstype close;

    ods listing;

 %end;

 %do i=&maxtitle %to 10;

    title&i;

 %end;


%EXIT:

%put End macro compare_two_datasets_join;
%mend compare_two_datasets_join;