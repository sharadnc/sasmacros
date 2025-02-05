/**************************************************************************************************************
* Macro_Name:   connect_to_db
*
* Purpose: This macro establishes a connection to a remote database.
*          The adminlib.dbinfo and homelib.dbpasswords data sets are used to retrieve the connection parameters.
*
* Usage: %connect_to_db(dbmstype,db);
*
* Input_parameters: dbmstype
*                    DB2, ORACLE, SQLSVR, ODBC, TERADATA
*                   db
*                    database name e.g. SLOT for edw SLOT database.
*
* Outputs:  None.
*
* Returns:  If error, jumptoexit=1
*
* Example: %connect_to_db(db2,SLOT);
*
* Modules_called: %chkerr
*                 %get_macro_system_options
*
* Maintenance_History:
*-------------------------------------------------------------------------------------------------------------*
*  Date:      |   Who:        |  Description:                                                                 *
*-------------------------------------------------------------------------------------------------------------*
* 12/14/2011  | Sharad           | Initial creation.                                                          *
* 12/14/2011  | Michael Gilman   | Initial creation.                                                          *
* 07/24/2011  | Sharad           | Add compress and upcase to the sql statement to pull db info.              *
* 08/28/2012  | Michael Gilman   | Added minoperator option to macro statement.                               *
* 08/28/2012  | Michael Gilman   | Now check for TERADATA.                                                    *
* 08/28/2012  | Michael Gilman   | Now use %get_macro_system_options to get macro system options.             *
* 08/28/2012  | Michael Gilman   | Removed invocation of %chk_outfile_length.                                 *
*-------------------------------------------------------------------------------------------------------------*
* HeaderEnd:                                                                                                  *
**************************************************************************************************************/
%macro connect_to_db(dbmstype,db)/minoperator;
%put Start macro connect_to_db;

 %local options;

 %if &jumptoexit %then %goto EXIT;

 %if %eval(%upcase(&dbmstype) in ORACLE SQLSVR DB2 ODBC TERADATA)=0 %then
 %do;

      %let errormsg1=Database %upcase(&dbmstype) not a valid database. Expecting ORACLE, SQLSVR, DB2, ODBC, TERADATA.;

      %put ERROR: &errormsg1;

      %let jumptoexit=1;

      %goto EXIT;

 %end;

 %let username=;

 proc sql noprint;
 select strip(a.dbtype),strip(alias),strip(username),strip(passwd),strip(a.database),strip(a.server),
        strip(dsnname),strip(spec_instruc),strip(addtnlcode)
 into   :dbtype, :alias, :username, :passwd, :database , :server , :dsnname , :spec_instruc , :addtnlcode
      from adminlib.dbinfo a left join homelib.dbpasswords b
      on a.RecordActive="Y" and compress(upcase(a.dbtype))=compress(upcase(b.dbtype)) and compress(upcase(a.database))=compress(upcase(b.database))
      where compress(upcase(a.dbtype))=compress("%upcase(&dbmstype)") and compress(upcase(a.database))=compress("%upcase(&db)")
 ;
 quit;

 /* add info to log if no match */

 %if %length(&database) eq 0 %then
 %do;

    %let errormsg1=There was an error looking up the database information for &db.. Ensure you have the right database value in the adminlib.dbinfo and a corresponding entry in homelib.dbpasswords;

    %put ERROR: &errormsg1;

    %let jumptoexit=1;

    %goto EXIT;

 %end;

 /*remove leading and trailing blanks in macro values */

 %let dbtype=&dbtype;

 %let alias=&alias;
 %let username=&username;
 %let database=&database;
 %let server=&server;
 %let dsnname=&dsnname;
 %let spec_instruc=&spec_instruc;
 %let addtnlcode=&addtnlcode;

 /*Mimicking these database parameters*/
 /*connect to db2 (user= password= database=);*/
 /*connect to sqlsvr as myodbc (noprompt= "dsn=; server=; uid=; pwd=; database=" readbuff=);*/
 /*Connect to oracle (user="" orapw="" path=""  readbuff= PRESERVE_COMMENTS);EXECUTE (SET TRANSACTION READ ONLY) by ORACLE;*/

 %if &username=%str() %then
 %do;

      %let errormsg1=%upcase(&dbmstype) database with table &db not found.;

      %put ERROR: &errormsg1..;
      %let jumptoexit=1;

      %goto EXIT;

 %end;

 %let options=%get_macro_system_options;
 
 %put DBMS Connection Established to %upcase(&dbtype) at %sysfunc(datetime(),datetime23.);

 options nosymbolgen nomprint nomprintnest nomlogic;

 proc sql feedback;
  %if %upcase(&dbtype) eq ORACLE %then
  %do;
     connect to oracle (user="&username." orapw="&passwd" path="&database"  &spec_instruc.); &addtnlcode.;
  %end;
  %else
  %if %upcase(&dbtype) in (SQLSVR ODBC) %then
  %do;
     %if %upcase(&env) eq UAT or %upcase(&env) eq PROD or %upcase(&env) eq IST %then
     %do;
        connect to odbc as &alias (dsn=&dsnname. uid=&username. pwd=&passwd.);
     %end;
     %else
     %do;
        connect to sqlsvr as &alias (dsn=&dsnname. uid=&username. pwd=&passwd.);
     %end;
  %end;
  %else
  %if %upcase(&dbtype) eq DB2 %then
  %do;
     connect to db2 (user=&username password=&passwd database=&database );
  %end;
  %else
  %if %upcase(&dbtype) eq TERADATA %then
  %do;
     connect to teradata (user=&username password=&passwd database=&database server=&server mode=teradata connection=global);
  %end;

  options &options;

  %chkerr(msg1=Error trying to connect to &dbmstype with table=&db,msg2=%superq(syserrortext));

%EXIT:

%put End macro connect_to_db;
%mend connect_to_db;