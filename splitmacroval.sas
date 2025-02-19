options nosource;

/**
Explanation of the Macro Parameters...
macvar - name of the macro variable that has info to be splitted..
prefix - prefix of the macro vars to be created in sequence order...
splitcnt - name of the macro vars to store the length of the macro variable
dlm - delimiter in the string (default is blank i.e. ' ')
e.g. %splitmacroval(str1,pre,strcnt,dlm=' '); look below for the example..
**/ 

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
  /** Remove the comment's to check the values
     %put &splitcnt=&&&splitcnt;
      %do i=1 %to %eval(&&&splitcnt + 0); 
     %put &&prefix&&&splitcnt = &&prefix&&&splitcnt;
    %end;
  */ 

%mend splitmacroval; 


%let str1=he she me to 3 "some";
%splitmacroval(str1,pre,strcnt,dlm=' ');

%put pre1=&pre1 pre2=&pre2 pre3=&pre3 pre4=&pre4 pre5=&pre5 pre6=&pre6 ;
%put strcnt=&strcnt;


