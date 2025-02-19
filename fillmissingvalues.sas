/* Read more about this macro at --
   http://sastechies.blogspot.com/2009/11/sas-macro-to-split-macro-variables.html
*/
%macro splitmacroval(macvar,prefix,splitcnt,dlm=' ');
 %global &splitcnt; /*create the global variable for storing the splitcount*/ 
 %let num=1; /*initialize a counter variable*/   

 %global &prefix&num; /*create the global variable for storing the first split*/ 
 %let &prefix&num=%scan(&&&macvar,&num,&dlm); /*Scan the first value*/ 

 %do %while(&&&prefix&num ne );
    %let num=%eval(&num + 1);/*increment the counter*/         
    %global &prefix&num; /*create the global variable*/ 
    %let &prefix&num=%scan(&&&macvar,&num,&dlm); /*scan the next value*/ 
  %end;

  %let &splitcnt=%eval(&num - 1); /*Store the split count to the macro variable reqd*/ 
%mend splitmacroval; 

/**
Use the macro like this...
inpdsn- name of the input dataset
outdsn- name of the output dataset
numvars= - give the list of numeric variables to be filled in with
charvars= - give the list of character variables to be filled in with
fillnums= the numeric value to use to fill the dataset 
fillchars=the character value to use to fill the dataset 
%fill(test,out,fillnums=0,fillchars=A);
**/ 

%macro fill(inpdsn,outdsn,numvars=,charvars=,fillnums=,fillchars=);

data &outdsn; /*output dataset name*/ 
 set &inpdsn; 
 %if &numvars eq ALL %then 
   %do; 
      array nums(*) _numeric_ ; /*assign all numeric variables to the array nums */ 
   %end; 
 %else 
   %do;
       %splitmacroval(numvars,num,numcnt,dlm=' ');
       array nums(&numcnt.) %do k=1 %to &numcnt; &&num&k  %end;; /*assign all numeric variables to the array nums */ 
    %end;

 %if &charvars eq ALL %then 
    %do; 
        array chars(*) _character_ ; /*assign all character variables to the array chars */ 
     %end; 
 %else 
     %do;
         %splitmacroval(charvars,chr,chrcnt,dlm=' ');
         array chars(&chrcnt.) %do k=1 %to &chrcnt; &&chr&k  %end;; /*assign all character variables to the array chars */ 
     %end;

 /* for every numeric variable assign 0 to the variable if the value is missing */ 
 do i=1 to dim(nums);
   if nums(i)=. then nums(i)=&fillnums;
 end;

 /* for every Character variable assign A for eg. to the variable if the value is missing */ 
  do i=1 to dim(chars);
    if chars(i)='' then chars(i)="&fillchars";
  end;
run;
%mend fill;

options nosource;
data test;
input fruit $ shop $ count2 count3 count4 ;
datalines;
apple wal . 2 3
coconut . 30 3 .
. sams 40 . .
eggs . 50 .
. . . 4 5
;
run;

%fill(test,out1,numvars=ALL,charvars=ALL,fillnums=0,fillchars=A);
%fill(test,out2,numvars=count3 count4,charvars=shop ,fillnums=0,fillchars=A);
