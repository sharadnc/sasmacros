/**************************************************************************************************************
* Macro_Name: compare_two_datasets
*
* Purpose: Compare 2 sas data sets using proc compare producing easy to read
*          output of the comparison.
*
* Usage: %compare_two_datasets(dsn1,dsn2,outfile=,equalobs=1,print_differences=100,
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
*                   print_differences
*                    Enter an integer greater than zero to print this number of
*                    record differences between the two data sets.
*                    Default: 100. Note that you normally wouldn't want to have a
*                                  larger number as the printed output would have
*                                  limited use.
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
*-------------------------------------------------------------------------------------------------------------*
* HeaderEnd:                                                                                                  *
**************************************************************************************************************/

%macro compare_two_datasets(dsn1,dsn2,proc_compare_match_method=absolute,
                            outfile=,equalobs=0,print_differences=100,
                            odsOutput=1,compareVariables=1,calledFromCompareLibraries=0
                           );
%put Start macro compare_two_datasets;

 %global errormsg1;

 %let errormsg1=;

 %local dsid obs1 obs2 lib1 lib2 memname1 memname2 nvars1 nvars2 in1vars in2vars
        matchvars diffattr i
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

 data matchvars in1vars in2vars;

  merge vars1 (in=in1) vars2 (in=in2);
  by name;

  if in1 and in2 then output matchvars;
  else
  if in1 and not in2 then output in1vars;
  else output in2vars;

 run;

 %let dsid=%sysfunc(open(matchvars));

 %let matchvars=%sysfunc(attrn(&dsid,nlobs));

 %let dsid=%sysfunc(close(&dsid));


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

 filename _dummy_ DUMMY;

 proc printto print=_dummy_;
 run;

 ods listing close;

 ods exclude all;

 ods output comparedatasets=__data
            comparesummary=__smyc
 ;

 proc compare base=&dsn1 compare=&dsn2
              outnoequal outbase outcomp outdif
              method=&proc_compare_match_method
              %if &print_differences>0 and &print_differences ne %str() %then
              %do;
              out=__out(where=(_type_ ne 'DIF'))
              %end;
 ;
 run;

 %let compareSysinfo=&sysinfo;

 ods output close;

 ods listing;

 ods select all;

 proc printto print=print;
 run;

 %let __valueDiff=-1;
 %let __obsDiff=-1;
 %let __varsDiff=0;
 %let __propDiff=-1;
 %let __commonVars=-1;
 %let __conflictingTypes=-1;
 %let __allComparedEqual=-1;
 %let __obsCommon=-1;

 data __smy;
 set __smyc(in=__smyc) __data(in=__data);
 where type='d' and batch ne '';

 batch=left(batch);

 if upcase(batch)=:'TOTAL NUMBER OF OBSERVATIONS' or
    upcase(batch)=:'NUMBER OF OBSERVATIONS' or
    upcase(batch)=:'NUMBER OF VARIABLES' then
 do;

    Attribute=scan(batch,1,':');

    Value=input(scan(batch,2,':'),best.);

    if upcase(attribute)=:'NUMBER OF VARIABLES COMPARED' then return;

    output;

    if upcase(attribute)='NUMBER OF OBSERVATIONS WITH SOME COMPARED VARIABLES UNEQUAL' then call symput('__valueDiff',value);
    if upcase(attribute)='NUMBER OF OBSERVATIONS WITH ALL COMPARED VARIABLES EQUAL' then call symput('__allComparedEqual',value);
    if upcase(attribute)=:'NUMBER OF OBSERVATIONS IN COMMON' then call symput('__obsCommon',value);
    if upcase(attribute)=:'NUMBER OF OBSERVATIONS IN' and indexw(upcase(attribute),'BUT NOT IN')  then call symput('__obsDiff',1);
    if upcase(attribute)=:'NUMBER OF VARIABLES IN' and indexw(upcase(attribute),'BUT NOT IN') then call symput('__varsDiff',1);

    if __data and upcase(attribute)=:'NUMBER OF VARIABLES IN COMMON' then call symput('__commonVars',value);
    if __data and upcase(attribute) ne :'NUMBER OF VARIABLES IN COMMON' then call symput('__propDiff',1);

    if __data and upcase(attribute)=:'NUMBER OF VARIABLES WITH CONFLICTING TYPES' then call symput('__conflictingTypes',value);

 end;

 keep attribute value;

 label Attribute='Comparison details';

 rename value=Frequency;

 format value comma20.;

 run;

 data __smyTemplate;
  length Attribute $200 Frequency 8 seq 4;

  label Attribute='Comparison details';

  retain frequency 0;

  seq=1;
  attribute="Number of Observations with Some Compared Variables Unequal";
  output;

  seq=2;
  attribute="Number of Observations with All Compared Variables Equal";
  output;

  seq=2.5;
  attribute="Number of Observations in Common";
  output;

/*
  seq=3;
  attribute="Number of Variables Compared with All Observations Equal";
  Frequency=&__commonVars-&__conflictingTypes;
  output;
  Frequency=0;

  seq=4;
  attribute="Number of Variables Compared with Some Observations Unequal";
  output;

  seq=5;
  attribute="Number of Variables Compared with Some Observations Equal";
  output;
*/

  seq=6;
  attribute="Number of Variables with Missing Value Differences";
  output;

  seq=-2;
  attribute="Total Number of Observations Read from &dsn1";
  output;

  seq=-1;
  attribute="Total Number of Observations Read from &dsn2";
  output;

  seq=9;
  attribute="Number of Observations in &dsn1 but not in &dsn2";
  output;

  seq=10;
  attribute="Number of Observations in &dsn2 but not in &dsn1";
  output;

  seq=11;
  attribute="Number of Variables with Differing Attributes";
  Frequency=&diffattr;
  output;
  Frequency=0;

  seq=12;
  attribute="Number of Variables in &dsn1";
  Frequency=&nvars1;
  output;
  Frequency=0;

  seq=13;
  attribute="Number of Variables in &dsn2";
  Frequency=&nvars2;
  output;
  Frequency=0;

  seq=14;
  attribute="Number of Variables in Common";
  Frequency=&matchvars;
  output;
  Frequency=0;

  seq=15;
  attribute="Number of Variables in &dsn1 but not in &dsn2";
  Frequency=&in1vars;
  output;
  Frequency=0;

  seq=16;
  attribute="Number of Variables in &dsn2 but not in &dsn1";
  Frequency=&in2vars;
  output;
  Frequency=0;

  format frequency comma20.;

 run;

 proc sort data=__smyTemplate;
 by attribute;
 run;

 proc sort data=__smy out=&outDsn;
 by attribute;
 run;

 data &outDsn;
 merge __smyTemplate &outDsn;
 by attribute;
 run;

 proc sort data=&outDsn;
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

 %let maxtitle=%trim(%left(&maxtitle));

 %if &maxtitle=%str() or &maxtitle=%str(.) %then %let maxtitle=0;

 %let maxtitle=%eval(&maxtitle+1);

 options nocenter;

 ods listing close;

 %let datetime=%sysfunc(datetime());

 %let datetime=%sysfunc(putn(&datetime,datetime.));

 %if &odsOutput %then
 %do;

    ods &odstype body="&outfile";

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
 title%eval(&maxtitle+1) "General Comparison Summary Results";

 %if &compareSysinfo<64 %then
 %do;

    %if &compareSysinfo=16 %then
    %do;

       title%eval(&maxtitle+2) "Data sets match, but have different number of variables";

    %end;
    %else
    %do;

       title%eval(&maxtitle+2) "Data sets match";

    %end;

 %end;
 %else
 %do;

    title%eval(&maxtitle+2) "Data sets don't match";

 %end;

 proc print data=&outDsn label;
 var attribute frequency;
 run;

 %if &compareVariables %then
 %do;

    %if &in1vars %then
    %do;

       title%eval(&maxtitle+1) "Variables in &dsn1 but not in &dsn2";

       proc print data=in1vars;
       run;

    %end;

    %if &in2vars %then
    %do;

       title%eval(&maxtitle+1) "Variables in &dsn2 but not in &dsn1";

       proc print data=in2vars;
       run;

    %end;

    %if &diffattr %then
    %do;

       title%eval(&maxtitle+1) "Variables in common but with different attributes";

       proc print data=diffattr label;
       run;

    %end;

 %end;

 %if &print_differences>0 and &print_differences ne %str() %then
 %do;

    proc sql;
     create table compareObs as
     select _obs_
     from __out
     group by _obs_
     having count(_obs_)=2
     ;
    quit;

    proc sort data=__out; by _obs_; run;
    proc sort data=compareObs; by _obs_; run;

    data baseNomatch compareNomatch baseOnly compareOnly;
     merge __out(in=in1 obs=%eval(&print_differences*2)) compareObs(in=in2);
     by _obs_;

     if in1 and in2 and _type_='BASE' then output baseNomatch;
     else
     if in1 and in2 and _type_='COMPARE' then output compareNomatch;
     else
     if _type_='BASE' then output baseOnly;
     else
     if _type_='COMPARE' then output compareOnly;

     label _obs_='Record Number';

     drop _type_;

    run;

    title%eval(&maxtitle+1) "Records in &dsn1 that don't match &dsn2";

    proc print data=baseNomatch(obs=&print_differences) label noobs;
    run;

    title%eval(&maxtitle+1) "Records in &dsn2 that don't match &dsn1";

    proc print data=compareNomatch(obs=&print_differences) label noobs;
    run;

    title%eval(&maxtitle+1) "Records in &dsn1 only";

    proc print data=baseOnly(obs=&print_differences) label noobs;
    run;


    title%eval(&maxtitle+1) "Records in &dsn2 only";

    proc print data=compareOnly(obs=&print_differences) label noobs;
    run;

 %end;

 %if &odsOutput %then
 %do;

    ods &odstype close;

    ods listing;

 %end;

 %do i=&maxtitle %to 10;

    title&i;

 %end;


%EXIT:

%put End macro compare_two_datasets;
%mend compare_two_datasets;