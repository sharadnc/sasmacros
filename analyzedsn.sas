/*
Data analysis is a process of inspecting, cleaning, transforming, and modelling data with the goal of highlighting useful information,
suggesting conclusions, and supporting decision making.

The first step in this process is to know about your data...
- Know what kind of data are you dealing with i.e. financial, pharmaceutical etc.
- If you have access to the data..quickly run a freq / means to get data-level information.
- Depending upon your business specific questions we might have to slice and dice / summarize the data.

Here's a simple SAS Macro that would help you to quickly find information as to 
- what are the variables available / last modification date etc.
- Give a frequency of occurences / min / max etc info depending on the type of the SAS column info...
- Produce a HTML report.


Steps to code the macro...

1. Get the type of the variables proc contents
2. Apply a Proc means with min max of numeric variables...Note: Proc Means does not generate a report for Character variables.
3. Apply a Proc Freq for Character Variables
4. Print an ODS HTML report for the results

*/

/* Explanation of the parameters of the Macro...
%analyzeSASdsn(dsn,numobs,varlist);
dsn - name of the dataset to analyze
numobs - number of observations to include in the dataset
varlist - List of Variables that you need to analyze...use _ALL_ if you want to include all the variables.
*/



%macro analyzeSASdsn(dsn,numobs,varlist);

  %let numvars=;  /* Initialize the number of numeric Variables */
  %let charvars=; /* Initialize the number of character Variables */


  %if %upcase(&varlist) eq _ALL_ %then /* If the user request for all the variables then assign appropriately */
     %do;
         %let numvars=_numeric_;
         %let charvars=_character_;
     %end;
  %else /* then find if the vars requested are numeric type or character type */
     %do;

	/* split the varlist into individual macro var names vars1 vars2 etc*/ 
	%let num=1;
	%let vars&num=%scan(&varlist,&num,' ');

	%do %while(&&vars&num ne );
	     %let num=%eval(&num + 1);
	     %let vars&num=%upcase(%scan(&varlist,&num,' '));
	%end;

	/* Get the List of variables in the &dsn dataset and put 
	   All char variables in charvarlist macro variables
	   All Num  variables in numvarlist macro variable
	*/

	%let dsid=%sysfunc(open(&dsn,i));
	%let numvarlist=;
	%let charvarlist=;
	%do i=1 %to %sysfunc(attrn(&dsid,nvars));
	  %if (%sysfunc(vartype(&dsid,&i)) = N) %then %let numvarlist=&numvarlist %upcase(%sysfunc(varname(&dsid,&i)));
	  %if (%sysfunc(vartype(&dsid,&i)) = C) %then %let charvarlist=&charvarlist %upcase(%sysfunc(varname(&dsid,&i)));
	%end;
	%let rc=%sysfunc(close(&dsid));

	%put numvarlist=&numvarlist charvarlist=&charvarlist;


	/* Now check the variables required to report in the above list and assign them to the right macro variables...
	   All char variables in charvarlist macro variables
	   All Num  variables in numvarlist macro variable
	*/

        %do i=1 %to %eval(&num - 1);
          %if %index(&numvarlist,&&vars&i)  %then %let numvars=&&vars&i &numvars; 
          %if %index(&charvarlist,&&vars&i) %then %let charvars=&&vars&i &charvars;
        %end; 

	%put numvars=&numvars charvars=&charvars;

     %end;

ods listing close;
ods html body="&htmlfilepath";

     /* Now analyze the dataset with the Specified variables */

     proc contents data=&dsn;run; /* Put a Contents procedure */

   %if &numvars ne  %then 
   %do;
     /* Get Summary statistics of All the Numeric Variables with means procedure */
     proc means data=&dsn(obs=&numobs) n mean max min range; 
       var &numvars;
       title 'Summary Statistics of all Numeric variables in the dataset';
    run;
   %end;

   %if &charvars ne  %then 
   %do;
     /* Get Summary statistics of All the Character Variables with Freq procedure */
    proc freq data=&dsn(obs=&numobs);
      tables &charvars;
      title1 'Summary Statistics of all Character variables in the dataset';
    run;
   %end;

ods html close;

%mend analyzeSASdsn;


/* Edit the Path of the Output Report */

%let htmlfilepath=C:\out.html;

options nodate pageno=1 linesize=80 pagesize=60 mprint symbolgen;
 
  data cake;
   input LastName $ 1-12 Age 13-14 PresentScore 16-17 
         TasteScore 19-20 Flavor $ 23-32 Layers 34 ;
   datalines;
Orlando     27 93 80  Vanilla    1
Ramey       32 84 72  Rum        2
Goldston    46 68 75  Vanilla    1
Roe         38 79 73  Vanilla    2
Larsen      23 77 84  Chocolate  .
Davis       51 86 91  Spice      3
Strickland  19 82 79  Chocolate  1
Nguyen      57 77 84  Vanilla    .
Hildenbrand 33 81 83  Chocolate  1
Byron       62 72 87  Vanilla    2
Sanders     26 56 79  Chocolate  1
Jaeger      43 66 74             1
Davis       28 69 75  Chocolate  2
Conrad      69 85 94  Vanilla    1
Walters     55 67 72  Chocolate  2
Rossburger  28 78 81  Spice      2
Matthew     42 81 92  Chocolate  2
Becker      36 62 83  Spice      2
Anderson    27 87 85  Chocolate  1
Merritt     62 73 84  Chocolate  1
;
 
run;


/*Eg. Analyze the dataset cake to report on all variables  */

%analyzeSASdsn(cake,max,_ALL_);

/* Eg. Analyze the dataset cake to report on particular variable Age Layers only */
%analyzeSASdsn(cake,max,Age Layers);
