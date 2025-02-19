%macro analyzecdwtable(table,numobs,varlist);
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
%analyzecdwtable(table,numobs,varlist);
numobs - number of observations to include in the cdw table
table - name of the cdwtable to analyze
varlist - List of Variables that you need to analyze...use _ALL_ if you want to include all the variables.
*/


/*initial connection to the Data Server.  Checks to see if the tabname exists and
drops the table if it does.  This connection is direct and uses SAS/ACCESS to get to DB2
It also uses the .sasparm file to get a valid username and password.  These are masked in
open code for security reasons*/

%macro process;
options comamid=tcp nosymbolgen nomacrogen;
data _null_;
   length rmtuser rmtpw $30.;
   infile sasparm delimiter=' ';
   input rmtuser $
         rmtpw   $
          ;
   call symput('rmtuser',trim(rmtuser));
   call symput('rmtpw',trim(rmtpw));
run;

/*This section initiates a Load using the SAS/ACCESS libname functionality*/
libname cdw &eng user="&rmtuser" using="&rmtpw" db=cdwp schema=udbadm;

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

	/* Get the List of variables in the &table dataset and put 
	   All char variables in charvarlist macro variables
	   All Num  variables in numvarlist macro variable
	*/

	%let dsid=%sysfunc(open(cdw.&table,i));
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

     proc contents data=cdw.&table;run; /* Put a Contents procedure */
	 proc print data=cdw.&table(obs=5);run; /* Print the Top 5 Records as sample */


   %if &numvars ne  %then 
   %do;
     /* Get Summary statistics of All the Numeric Variables with means procedure */
     proc means data=cdw.&table(obs=&numobs) n mean max min range; 
       var &numvars;
       title 'Summary Statistics of all Numeric variables in the dataset';
    run;
   %end;

   %if &charvars ne  %then 
   %do;
     /* Get Summary statistics of All the Character Variables with Freq procedure */
    proc freq data=cdw.&table(obs=&numobs);
      tables &charvars;
      title1 'Summary Statistics of all Character variables in the dataset';
    run;
   %end;

ods html close;

libname cdw clear;
filename files clear;
%MEND process;

/*Determine what OS and consequently what engine to use for the connections to DB2.*/
/*set variables*/
%let os=&sysscpl;
%let db2on=%sysget(DB2INSTANCE);

%put &os;
%if %substr(&os,1,2)=XP
    %then %DO;
        %let eng=ODBC;
        filename rlink '!SASROOT\core\sasmacro\start_remote_sas.scr';
        filename sasparm '!mysasfiles\sasparm';
        %end;
    %else %DO;
        %let eng=DB2;
        filename rlink '/opt/sas/dssautos/start_remote_sas.scr';
        filename sasparm '~/.sasparm';
        %end;

%IF %sysget(DB2INSTANCE) ne and &sysver=9.1 
%THEN %DO ;
%process;
%END; %ELSE %DO; %put ' *** WARNING YOUR SERVER DOES NOT SUPPORT SAS/ACCESS TO DB2 *** ';
                 %PUT ' Use an rsubmit to CONSAS first then try this macro again ';
%END;

%put " *** Procedure Complete *** ";
%mend analyzecdwtable;
