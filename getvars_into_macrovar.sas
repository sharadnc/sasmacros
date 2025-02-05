/**************************************************************************************************************
* Macro_Name:   getvars_into_macrovar
*
* Purpose: Get the variables names of a sas data set and assign them to a macro variable.
*
*          Optionally get just the character or numeric variables.
*
*          Optionally get the associated Lengths or Formats or Informats or Labels.
*
* Usage: %getvars_into_macrovar(dataset,charnum,stmtType);
*
* Input_parameters: dataset
*                   charnum (optional)
*                    C to get only character variables, N for only numeric
*                   stmtType (optional)
*                    L, F, I, B for Lengths, Formats, Informats, Labels respectively.
*
* Outputs:  None.
*
* Returns:  List of found variable names with optionally associated Lengths or Formats or Informats or Labels.
*
* Example: %let vars=%getvars_into_macrovar(sasuser.class); * Just the vars;
*          %let vars=%getvars_into_macrovar(sasuser.class,,L); * Vars & Length
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

%macro getvars_into_macrovar(dataset,    /* Data set                                     */
                             charnum,    /* Optional. C to get only character variables, */
                                         /*           N for only numeric                 */
                             stmtType    /* Optional. L to get Lengths                   */
                                         /*           F to get Formats                   */
                                         /*           I to get Informats                 */
                                         /*           B to get Labels                    */
);

 %local dsid i vartype varlen varfmt varinfmt stmt vars;

 %global varcount;

 %if %sysfunc(exist(&dataset))=0 %then
 %do;

    %let errormsg1=Data set &dataset does not exist.;

    %let jumptoexit=1;

    %goto EXIT;

 %end;

 %let dsid=%sysfunc(open(&dataset));

 %if &dsid<=0 %then
 %do;

    %let errormsg1=Could not open data set &dataset;

    %let jumptoexit=1;

    %goto EXIT;

 %end;

 %let charnum=%upcase(&charnum);

 %let stmtType=%upcase(&stmtType);

 %let vars=;

 %let varcount=0;

 %let stmt=;

 %do i=1 %to %sysfunc(attrn(&dsid,nvars));

     %let vartype=%sysfunc(vartype(&dsid,&i));
     %let varlen=%sysfunc(varlen(&dsid,&i));
     %let varfmt=%sysfunc(varfmt(&dsid,&i));
     %let varinfmt=%sysfunc(varinfmt(&dsid,&i));
     %let varlabel=%sysfunc(varlabel(&dsid,&i));

     %if &stmtType=L %then %let stmt=&varlen;
     %if &stmtType=F %then %let stmt=&varfmt;
     %if &stmtType=I %then %let stmt=&varinfmt;
     %if &stmtType=B %then %let stmt=&varlabel;

     %if &charnum=%str() or
         &charnum=C and &vartype=C or
         &charnum=N and &vartype=N %then
     %do;

        %if &stmtType=L %then
        %do;

           %if &vartype=C %then %let stmt=$&stmt;

        %end;

        %if &stmtType=%str() or &stmtType=B or &stmt ne %str() %then
        %do;

           %if &stmtType=B %then
           %do;

              %if %superq(stmt) ne %str() %then
                 %let vars=&vars %sysfunc(varname(&dsid,&i))=%sysfunc(quote(&stmt));
              %else
                 %let vars=&vars %sysfunc(varname(&dsid,&i))=' ';


           %end;
           %else %let vars=&vars %sysfunc(varname(&dsid,&i)) &stmt;

           %let varcount=%eval(&varcount+1);

        %end;

     %end;

 %end;

 %if &dsid %then %let dsid=%sysfunc(close(&dsid));

 &vars

%EXIT:

%mend getvars_into_macrovar;
