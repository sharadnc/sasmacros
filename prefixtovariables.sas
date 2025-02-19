/*
Eg... Try this Macro with an Example
*/
options nodate nosource pageno=1 linesize=80 pagesize=60;
 
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

/**

SAS Macro to add a prefix to some or all variables in a data set...

to be used like this...

%prefixvars(inpdsn,prefix,outdsn,excludevars=);

inpdsn - input dataset name libname.dsnname

prefix - prefix that you want to assign

outdsn - output dataset name libname.dsnname

excludevars - vars that you do not want to rename with the prefix

**/ 



%macro prefixvars(inpdsn,prefix,outdsn,excludevars=);   



/* split the excludevars into individual macro var names for later use*/ 

%let num=1;

%let excludevar=%scan(%upcase(&excludevars),&num,' ');

%let excludevar&num=&excludevar;



%do %while(&excludevar ne );

            %let num=%eval(&num + 1);

            %let excludevar=%scan(&excludevars,&num,' ');

            %let excludevar&num=&excludevar;

%end;

%let numkeyvars=%eval(&num - 1); /* this is number of variables given in the exclude vars */ 





 %let dsid=%sysfunc(open(&inpdsn));   /* open the dataset and get the handle */                                                                                                     

 %let numvars=%sysfunc(attrn(&dsid,nvars)); /* get the number of variables */                                                                                                

  data &outdsn;                                                                                                                            

   set &inpdsn(rename=( 

   /*rename all the variables that are not in the excludevars= */                                                                                                                  

            %do i = 1 %to &numvars;

               %let flag=N; 

               %let var&i=%sysfunc(varname(&dsid,&i));  

               %do j=1 %to &numkeyvars;

               %if %upcase(&&var&i) eq &&excludevar&j %then %let flag=Y;                            

               %end; 

               %if &flag eq N %then %do; &&var&i=&prefix&&var&i  %end; 

            %end;));                                                                                                                            



   %let rc=%sysfunc(close(&dsid));                                                                                                        

  run;                                                                                                                                  

%mend prefixvars;                                                                                                                             

                                                                                                                                        

/*Call the macro now*/                                                                                                                                        

%prefixvars(cake,me_,work.cake_prefix,excludevars=Age) 
