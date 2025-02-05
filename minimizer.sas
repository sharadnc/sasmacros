/**************************************************************************************************************
* Macro_Name:   Minimizer
*
* Purpose: Determine which variables can be shortened in length.
*
* Usage: %%minimizer(dataset=, MaxNumberOfRecordsToAnalyze=MAX, resultsDataset=results, resultsSummaryDataset=resultsSmy, resultsFile= );
*
* Input_parameters: dataset=,                         /* Data set to analyze */                       
*                   MaxNumberOfRecordsToAnalyze=MAX,  /* Maximum # of records to read in */           
*                   resultsDataset=results,           /* Results output data set */                   
*                   resultsSummaryDataset=resultsSmy, /* Results summary output data set */           
*                   resultsFile=                      /* Pathname of output file. e.g.: results.pdf */
*
* Outputs:  None.
*
* Returns:  
*
* Example: 
*          
*
* Modules_called: None
*
* Maintenance_History:
*-------------------------------------------------------------------------------------------------------------*
*  Date:      |   Who:           |  Description:                                                              *
*-------------------------------------------------------------------------------------------------------------*
* 09/18/2012  | Michael Gilman   | Initial creation.                                                          *
*-------------------------------------------------------------------------------------------------------------*
* HeaderEnd:                                                                                                  *
**************************************************************************************************************/


%macro Minimizer(dataset=,                         /* Data set to analyze */
                 MaxNumberOfRecordsToAnalyze=MAX,  /* Maximum # of records to read in */
                 resultsDataset=results,           /* Results output data set */
                 resultsSummaryDataset=resultsSmy, /* Results summary output data set */
                 resultsFile=                      /* Pathname of output file. e.g.: results.pdf */
);

%put Start macro Minimizer;

 %global numberOfActualRecords recordsToReadIn totalBytesCurrent;

 %if %sysfunc(exist(&dataset))=0 %then
 %do;

    %put ERROR: Data set &dataset does not exist.;

    %goto EXIT;

 %end;

 %let odsType=%sysfunc(scan(%superq(resultsFile),-1,'.'));

 %let odsType=%sysfunc(lowcase(&odsType));

 %if &odsType=pdf %then %let odsType=pdf;
 %else
 %if &odsType=doc %then %let odsType=rtf;
 %else
 %if &odsType=htm %then %let odsType=html;
 %else
 %if &odsType=html %then %let odsType=html;
 %else
 %do;

    %put ERROR: Unrecognized file extension for parameter resultsFile: &resultsFile.;

    %goto EXIT;

 %end;

 options validvarname=any;

 %let MaxNumberOfRecordsToAnalyze=%upcase(&MaxNumberOfRecordsToAnalyze);

 %Analyze;

 %CreateMinimizerTemplateDataset;

 %if &MaxNumberOfRecordsToAnalyze ne MAX %then %let testFullRatio=%sysevalf(&numberOfActualRecords/&recordsToReadIn);
 %else %let testFullRatio=1;

 %let original=1;

 %let outData=__TEST0;

 %let compress=;

 %Test;

 %let original=0;

 %let outData=__TEST1;

 %let compress=;

 %Test;

 %let outData=__TEST2;

 %let compress=COMPRESS=CHAR;

 %Test;

 %let outData=__TEST3;

 %let compress=COMPRESS=BINARY;

 %Test;

 %ResultsSummary;

 %if %quote(&resultsFile) ne %str() %then %output_results_file;

%EXIT:

%put End macro Minimizer;
%mend Minimizer;


%macro output_results_file;

 ods listing close;

 ods &odsType body="&resultsFile" style=analysis;

 ods results=on;

 options center;

 title1 "Minimizer: &dataset";

 %let numberOfActualRecordsc=%sysfunc(putn(&numberOfActualRecords,comma32.));

 %let numberOfActualRecordsc=%left(%quote(&numberOfActualRecordsc));

 %let numberOfActualRecordsc=%trim(%quote(&numberOfActualRecordsc));

 %if &recordsToReadIn<&numberOfActualRecords %then
 %do;

    %let recordsToReadIn=%sysfunc(putn(&recordsToReadIn,comma32.));

    %let recordsToReadIn=%left(%quote(&recordsToReadIn));

    %let recordsToReadIn=%trim(%quote(&recordsToReadIn));

    title2 "First &recordsToReadIn records analyzed (&numberOfActualRecordsc in data set)";

 %end;
 %else
 %do;

    title2 "All records analyzed (&numberOfActualRecordsc)";

 %end;

 title3 'Analysis of Variables';

 proc print data=&resultsDataset split='~';
 var varname type clength nlength saved float allMissing label;
 sum clength nlength saved;
 run;

 title3 'Result Summary';

 proc print data=&resultsSummaryDataset split='~' noobs;
 run;

 ods &odsType close;
 ods listing;
 ods results=on;

%mend output_results_file;


%macro Analyze;

 %let lib=%upcase(%scan(&dataset,1,%str(.)));

 %let memname=%upcase(%scan(&dataset,2,%str(.)));

 %if &memname=%str() %then
 %do;

    %let memname=&lib;

    %let lib=WORK;

 %end;

 %if %upcase(&MaxNumberOfRecordsToAnalyze)=%str() %then %let MaxNumberOfRecordsToAnalyze=MAX;

 proc sql noprint;
 select left(put(nlobs,32.)), left(put(filesize,32.)) into : numberOfActualRecords, : totalBytesCurrent
 from dictionary.tables
 where libname="&lib" and memname="&memname"
 ;
 quit;

 %let numberOfActualRecords=%trim(%left(&numberOfActualRecords));
 %let totalBytesCurrent=%trim(%left(&totalBytesCurrent));

 %if &MaxNumberOfRecordsToAnalyze=MAX %then %let recordsToReadIn=MAX;
 %else
 %do;

    %if &numberOfActualRecords=. %then %let recordsToReadIn=&MaxNumberOfRecordsToAnalyze;
    %else %let recordsToReadIn=%sysfunc(min(&numberOfActualRecords,&MaxNumberOfRecordsToAnalyze));

 %end;

 data &resultsDataset;
 length varname $80 label $200 type $1 clength nlength 4 Saved 4 float 3 allMissing order 3;
 label varname='Variable'
       label='Label'
       type='Type'
       clength='Current~Length'
       nlength='Possible~Minimum~Length'
       float='Floating~Point'
       allMissing='All~Missing'
       saved='Bytes~Saved'
 ;

 format clength nlength comma12.;

 %let numericVarsN=0;

 %let charVarsN=0;

 %let varlenTotal=0;

 %let dsid=%sysfunc(open(&dataset));

 %let nvars=%sysfunc(attrn(&dsid,nvars));

 %do i=1 %to &nvars;

    %let varname=%bquote(%sysfunc(varname(&dsid,&i)));
    %let varlabel=%sysfunc(varlabel(&dsid,&i));
    %let vartype=%sysfunc(vartype(&dsid,&i));
    %let varlen=%sysfunc(varlen(&dsid,&i));

    %if &vartype=N %then %let numericVarsN=%eval(&numericVarsN+1);
    %else %let charVarsN=%eval(&charVarsN+1);

    varname="%unquote(&varname)";
    label="&varlabel";
    type="&vartype";
    clength=&varlen;
    nlength=.;
    order=&i;
    output;

 %end;

 %let dsid=%sysfunc(close(&dsid));

 run;

 data _calc(rename=(__varname=varname __nlength=nlength __float=float __allMissing=AllMissing));

 retain;

 set &dataset end=__e;

 %if &numericVarsN>0 %then
 %do;

    array __n{*} _NUMERIC_;
    array __lenNum{&numericVarsN} _temporary_;
    array __nv{&numericVarsN} _temporary_;
    array __fv{&numericVarsN} _temporary_;
    array __mv{&numericVarsN} _temporary_;

    do __i=1 to dim(__n);

       if .<=__n{__i}<=.Z then continue;

       __mv{__i}=0;

       if not __fv{__i} then
          if indexc(put(__n{__i},best.),'.') then __fv{__i}=1;

       __found=0;

       do __j=7 to 3 by -1 while(not __found);;

          if __n{__i} ne trunc(__n{__i},__j) then
          do;

             __lenNum{__i}=max(__lenNum{__i},__j+1);

             __nv{__i}=__n{__i};

             __found=1;

          end;

       end;

    end;

 %end;

 %if &charVarsN>0 %then
 %do;

    array __c{*} _CHARACTER_;
    array __lenChar{&charVarsN} _temporary_;
    array __mvc{&charVarsN} _temporary_;

    do __i=1 to dim(__c);

       if __mvc{__i}=. then if __c{__i} ne ' ' then __mvc{__i}=0;

       if length(__c{__i})>__lenChar{__i} then __lenChar{__i}=length(__c{__i});

    end;

 %end;

 length __varname $32;

 if __e then
 do;

    call symputx('numberOfActualRecords',_N_);

 end;

 %if &numericVarsN>0 %then
 %do;

    if __e then
    do;

       do __i=1 to dim(__n);

          call vname(__n{__i},__varname);

          __nlength=max(3,__lenNum{__i});

          if __fv{__i} then __float=1;
          else __float=0;

          if __mv{__i}=. then __allMissing=1;
          else __allMissing=0;

          output;

       end;

    end;

 %end;

 %if &charVarsN>0 %then
 %do;

    if __e then
    do;

       __float=.A;

       do __i=1 to dim(__c);

          call vname(__c{__i},__varname);

          if __mvc{__i}=. then __allMissing=1;
          else __allMissing=0;

          __nlength=__lenChar{__i};

          output;

       end;

    end;

 %end;

 keep __varname __nlength __float __allMissing;

 run;

 proc sort data=_calc;
 by varname;
 run;

 proc sort data=&resultsDataset;
 by varname;
 run;

 data &resultsDataset;
 merge &resultsDataset _calc;
 by varname;

 saved=clength-nlength;

 format saved comma32.;

 run;

 data &resultsDataset(rename=(floatc=float allMissingc=allMissing));

  set &resultsDataset;

  length floatc allMissingc $3;

  if float=. then floatc=' ';
  else
  if float=.A then floatc='N/A';
  else
  if float=0 then floatc='No';
  else
  if float=1 then floatc='Yes';

  if allMissing=. then allMissingc=' ';
  else
  if allMissing=0 then allMissingc='No';
  else
  if allMissing=1 then allMissingc='Yes';

  drop float allMissing;

  label floatc='Floating~Point' allMissingc='All~Missing';

 run;

%mend Analyze;

%macro CreateMinimizerTemplateDataset;

 data __minimizedTemplate;

 length

 %let dsid=%sysfunc(open(&resultsDataset));

 %let nvars=%sysfunc(attrn(&dsid,nlobs));

 %do i=1 %to &nvars;

    %let rc=%sysfunc(fetch(&dsid));

    %let varname=%bquote(%sysfunc(getvarc(&dsid,%sysfunc(varnum(&dsid,varname)))));
    %let vartype=%sysfunc(getvarc(&dsid,%sysfunc(varnum(&dsid,type))));
    %let clength=%sysfunc(getvarn(&dsid,%sysfunc(varnum(&dsid,clength))));
    %let nlength=%sysfunc(getvarn(&dsid,%sysfunc(varnum(&dsid,nlength))));

    %let varname=%sysfunc(quote(%qtrim(&varname)))n;

    %if &vartype=C %then
    %do;

       %let typec=$;

       %let useLength=&clength;

    %end;
    %else
    %do;

       %let typec=;

       %let useLength=&nlength;

    %end;

       &varname &typec &useLength

 %end;

 ;
 run;

 %let dsid=%sysfunc(close(&dsid));

%mend CreateMinimizerTemplateDataset;


%macro Test;

 data &outData(&compress);

  %if &original=0 %then
  %do;

     if _N_=0 then set __minimizedTemplate;

  %end;

  set &dataset(obs=&recordsToReadIn);

 run;

%mend Test;

%macro ResultsSummary;

 proc sql;
 create table __temp as
 select memname,
        filesize as bytes label='Total Bytes' format=comma32.,
        bufsize
 from dictionary.tables
 where libname="WORK" and
       memname in ('__TEST0' '__TEST1' '__TEST2' '__TEST3') and memtype='DATA'
 ;
 quit;

 data &resultsSummaryDataset;

 length Best $4 Test $80 originalBytes bytes 8 compressMethod $8 bestTest $80;
 retain minBytes compressMethod bestTest bestBufsize bestObs;
 retain originalBytes &totalBytesCurrent;

 set __temp end=e;

 if memname='__TEST0' then Test='No Minimization, no compression';
 if memname='__TEST1' then Test='Minimization, no compression';
 if memname='__TEST2' then Test='Minimization, compression=CHAR';
 if memname='__TEST3' then Test='Minimization, compression=BINARY';

 testBytes=&testFullRatio*bytes;

 if bytes<minBytes or _N_=1 then
 do;

     if _N_=1 then compressMethod='NO';
     if _N_=2 then compressMethod='NO';
     if _N_=3 then compressMethod='CHAR';
     if _N_=4 then compressMethod='BINARY';

     bestObs=_N_;

     minBytes=bytes;

     bestTest=test;

     bestBufsize=bufsize;

 end;

 %if &recordsToReadIn<&numberOfActualRecords %then
 %do;

    bytes=bytes*&testFullRatio;

 %end;

 bytesSaved=originalBytes -bytes;

 pctSaved=bytesSaved/originalBytes;

 if e then
 do;

    call symputx('__bestObs',bestObs);
    call symputx('__COMPRESSMETHOD',compressMethod);
    call symputx('__MINBYTES',minbytes);
    call symputx('__BESTTEST',bestTest);
    call symputx('__BUFSIZE',bestBufsize);

 end;

 %if &recordsToReadIn<&numberOfActualRecords %then
 %do;

    label bytes='Test data set~estimated bytes~using all records';

 %end;
 %else
 %do;

    label bytes='Test data set bytes';

 %end;

 keep Best Test originalBytes bytes bytesSaved pctSaved;

 label originalBytes='Original~data set bytes' bytesSaved='Bytes saved' pctSaved='% Bytes saved';

 format originalBytes bytesSaved comma32. pctSaved percent.;

 run;

 data &resultsSummaryDataset;;
  set &resultsSummaryDataset;

  if _N_=&__bestObs then best='BEST';

 run;

%mend ResultsSummary;

/*
%Minimizer(dataset=hist.ach_coll_bdst_hist,resultsFile=&rootloc/lst/ach_coll_bdst_hist.html);
*/