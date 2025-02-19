%macro deletedsn(dsname);

%if %index(&dsname,.) eq 0  %then %do; %let lib=work; %let dsn=&dsname; %end;
%else %if %index(&dsname,.) gt 0  %then %do; %let lib=%scan(&dsname,1,.); %let dsn=%scan(&dsname,2,.); %end;

/* Use Proc Datasets with the Delete statement */
proc datasets lib=&lib nolist;
 delete &dsn;
quit;

%mend deletedsn;

Libname somelib "C:\";

data one somelib.one;
  input id name :$20. amount ;
  date=today();
  format amount dollar10.2 date mmddyy10.;
  label id="Customer ID Number";
datalines;
1 Grant   57.23
2 Michael 45.68
3 Tammy   53.21
;
run;

%deletedsn(one); /* delete dataset from Work library */
%deletedsn(somelib.one); /* delete dataset from a permanent library */
