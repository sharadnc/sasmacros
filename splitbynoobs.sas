options nosource nomprint nomlogic nosymbolgen;

/**
Usage of the Macro-
%splitdsnbyobs(DatasetName, No ofobservation to split by)
**/

/* creating a dataset with 100000 observations*/

%macro splitdsnbyobs(dsn,splitby);

data _null_;
	set &dsn nobs=num;
	call symput('no_obs',num);
run;

%let no_obs=&no_obs; /*Get the number of observations in &dsn*/

/* keep the observations from firstobs= and obs=*/
%do i=1 %to %sysfunc(ceil(&no_obs/&splitby));
	data &dsn.&i.;
	set &dsn (firstobs=%sysfunc(floor(%eval((&i.-1)*&splitby.+1))) obs=%sysfunc(ceil(%eval(&i * &splitby.))));
	run;
%end;
%mend splitdsnbyobs;

/* Eg. Create a Dsn with 100 observations */
data loops;
do i=1 to 100;
	output;
end;
run;

/*Now call the macro to split the observations every 20 records*/
%splitdsnbyobs(loops,20);

/*
Read more: http://sastechies.blogspot.com/2009/11/sas-macro-to-split-dataset-by-number-of.html
*/
