options nosource;
%macro RecsInDS(table,macvar);
   %global &macvar;
   %local handle rc;
   %let handle = %sysfunc(open(&table)); /* Open the table with open() function*/
   %if &handle %then  
       %do;
          %let &macvar = %sysfunc(attrn(&handle, nlobs)); /* get the observation count into the macvar macro variable using the function attrn() with nlobs as the option*/
           %let rc = %sysfunc(close(&handle)); /* close the dataset with the close() function */
    %end;
    %PUT RecsInDS &table: &&&macvar.    &macvar=&&&macvar.; /* write the Record count to the Log */
%mend RecsInDS;

/*Now Call the Macro...*/

%RecsInDS(sashelp.air,obs);

/*
Read more: http://sastechies.blogspot.com/2009/11/ways-to-count-number-of-obs-in-dataset.html
*/
