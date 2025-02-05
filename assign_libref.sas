/**************************************************************************************************************
* Macro_Name:   assign_libref
*
* Purpose: This macro is used to assign a libref to a directory location.
*
* Usage: %assign_libref(libref,dir,dbmstype=,db=,schema=,libname_options=);
*
* Input_parameters: libref
*                    Intended libref
*                   dir
*                    Physical directory location
*                   dbmstype=
*                    Used when assigning to database
*                    Specify DB2, ORACLE, SQLSVR, ODBC, TERADATA
*                   db=
*                    Name of database table
*                   dsnname
*                    dsnname (used for sqlsvr and odbc)
*                   schema=
*                    Optional name of database schema
*                   libname_options=
*                    Optional libref options for database
*
* Outputs:  None.
*
* Returns:  If error, jumptoexit=1
*
* Example: %assign_libref(extract,/home/sas/data);
*          %assign_libref(prof,dbmstype=db2,db=PTPROF,schema=PROF);
*
* Modules_called: %get_macro_system_options
*
* Maintenance_History:
*-------------------------------------------------------------------------------------------------------------*
*  Date:      |   Who:        |  Description:                                                                 *
*-------------------------------------------------------------------------------------------------------------*
* 12/14/2011  | Sharad           | Initial creation.                                                          *
* 12/14/2011  | Michael Gilman   | Initial creation.                                                          *
* 07/13/2012  | Michael Gilman   | Removed invocation of %chk_outfile_length.                                 *
* 08/23/2012  | Michael Gilman   | Now suppress mprint, symbolgen, etc for db libname assignments.            *
* 08/28/2012  | Michael Gilman   | Added minoperator option to macro statement.                               *
* 08/28/2012  | Michael Gilman   | Now check for TERADATA.                                                    *
* 08/31/2012  | Michael Gilman   | Added ODBC.                                                                *
* 09/19/2011  | Sharad           | Add compress and upcase to the sql statement to pull db info.              *
* 09/19/2011  | Michael Gilman   | Changed assigning sqlsvr libref. Now expect a dsnname value. dsnname added *
*             |                  | as a new input parameter.                                                  *
*-------------------------------------------------------------------------------------------------------------*
* HeaderEnd:                                                                                                  *
**************************************************************************************************************/

%macro assign_libref(libref,dir,dbmstype=,db=,dsnname=,schema=,libname_options=)/minoperator;
%put Start macro assign_libref;

 %local schemac options;

 %let dbmstype=%upcase(&dbmstype);

 %let db=%upcase(&db);

 %let schema=%upcase(&schema);

 %if &dbmstype ne %str() %then
 %do; /* ORACLE, SQLSVR, DB2, ODBC, TERADATA */

    %if %eval(%upcase(&dbmstype) in ORACLE SQLSVR DB2 ODBC TERADATA)=0 %then
    %do;

         %let errormsg1=Database %upcase(&dbmstype) not a valid database. Expecting ORACLE, SQLSVR, DB2, ODBC, TERADATA.;

         %put ERROR: &errormsg1;

         %let jumptoexit=1;

         %goto EXIT;

    %end;

    %let username=;
    %let passwd=;
    %let database=;

    proc sql noprint;
     select strip(a.dbtype),strip(alias),strip(username),strip(passwd),strip(a.database),strip(a.server),
            strip(dsnname),strip(spec_instruc),strip(addtnlcode)
     into   :dbtype, :alias, :username, :passwd, :database , :server , :dsnname , :spec_instruc , :addtnlcode
     from adminlib.dbinfo a left join homelib.dbpasswords b
     on a.RecordActive="Y" and compress(upcase(a.dbtype))=compress(upcase(b.dbtype)) and compress(upcase(a.database))=compress(upcase(b.database))
     where compress(upcase(a.dbtype))=compress("%upcase(&dbmstype)") and compress(upcase(a.database))=compress("%upcase(&db)")
     %if &dsnname ne %str() %then
     %do;

        and upcase(a.dsnname)=upcase("&dsnname")

     %end;
     ;
    quit;

    /*remove leading and trailing blanks in macro values */

    %let dbtype=&dbtype;
    %let alias=&alias;
    %let username=&username;
    %*let passwd=&passwd;
    %let database=&database;
    %let server=&server;
    %let dsnname=&dsnname;
    %let spec_instruc=&spec_instruc;
    %let addtnlcode=&addtnlcode;

    %let options=%get_macro_system_options;

    options nomprint nomlogic nosymbolgen nomprintnest nomlogicnest;

    %if &username=%str() %then
    %do;

       %let errormsg1=Could not find required parameters for &dbmstype, &db;

       %let jumptoexit=1;

       %goto EXIT;

    %end;

    %if &schema ne %str() %then %let schemac=%str(schema=&schema);
    %else %let schemac=;

    %if &dbmstype=DB2 %then
    %do;

       libname &libref &dbmstype user=&username database=&database password=&passwd &schemac &libname_options;

    %end;

    %if %upcase(&dbtype) in (SQLSVR ODBC) %then
    %do;

       %if %upcase(&env) eq UAT or %upcase(&env) eq PROD or %upcase(&env) eq IST %then
       %do;

          libname &libref odbc user=&username datasrc=&dsnname password=&passwd &schemac &libname_options;

       %end;
       %else
       %do;

          libname &libref &dbmstype noprompt="uid=&username;pwd=&passwd;dsn=&dsnname;" &spec_instruc &libname_options;

       %end;

    %end;

    %if &dbmstype=ORACLE %then
    %do;

       libname &libref &dbmstype user="&username" orapw="&passwd" path="&database" &schemac &spec_instruc &libname_options;

    %end;

    %if &dbmstype=TERADATA %then
    %do;

        libname &libref teradata user=&username database=&database password=&passwd server="&server" &addtnlcode;

    %end;

    options &options;

    %if %sysfunc(libref(&libref)) %then
    %do;

       %let errormsg1=Could not assign &libref to &dir;
       %let errormsg2=&syserrortext;

       %let jumptoexit=1;

    %end;

    %goto EXIT;

 %end;/* ORACLE, SQLSVR, DB2, ODBC, TERADATA */

/*   Check if the &dir location exists*/

 %if %sysfunc(fileexist(&dir))=0 %then
 %do;

    %let errormsg1=&dir directory not found;

    %let jumptoexit=1;

    %goto EXIT;

 %end;

 libname &libref "&dir";

 %if %sysfunc(libref(&libref)) %then
 %do;

    %let errormsg1=Could not assign &libref to &dir;
    %let errormsg2=&syserrortext;
    %put ERROR: &dir does NOT exist;

    %let jumptoexit=1;

 %end;
 %else
 %do;

    %put;
    %put NOTE: Libref &libref assigned to %sysfunc(pathname(&libref));
    %put;

 %end;

%EXIT:

%put End macro assign_libref;
%mend assign_libref;
