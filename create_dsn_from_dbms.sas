/**************************************************************************************************************
* Macro_Name:   create_dsn_from_dbms
*
* Purpose: Generate an sql create table statement with related connection to string.
*
* Usage: %create_dsn_from_dbms(dsn,table_type)
*
* Input_parameters: dsn
*                    Name of sas data set to create
*                   table_type
*                    Type of table to create, data or view
*                    Default: data
*                   dbtype
*                    Global macro variable that is set by the %connect_to_db macro
*                   alias
*                    Used for sqlsvr. Global macro variable currently set to myodbc
*
* Outputs:  None.
*
* Returns:  None
*
* Example:
*
* Modules_called: None
*
* Maintenance_History:
*-------------------------------------------------------------------------------------------------------------*
*  Date:      |   Who:        |  Description:                                                                 *
*-------------------------------------------------------------------------------------------------------------*
* 12/14/2011  | Sharad           | Initial creation.                                                          *
* 12/14/2011  | Michael Gilman   | Initial creation.                                                          *
* 09/21/2012  | Michael Gilman   | Added TERADATA.                                                            *
* 12/15/2012  | Michael Gilman   | Added new parameter: table_type. Add the ability to create view.           *
*-------------------------------------------------------------------------------------------------------------*
* HeaderEnd:                                                                                                  *
**************************************************************************************************************/

%macro create_dsn_from_dbms(dsn,table_type);
%put Start macro create_dsn_from_dbms;

 %if &jumptoexit %then %goto EXIT;

 %if &table_type=%str() %then %let table_type=table;

 %if %upcase(&dbtype) eq ORACLE   %then %let dbmstype=oracle;
 %else
 %if %upcase(&dbtype) eq SQLSVR   %then %let dbmstype=&alias;
 %else
 %if %upcase(&dbtype) eq DB2      %then %let dbmstype=db2;
 %else
 %if %upcase(&dbtype) eq TERADATA %then %let dbmstype=teradata;

 create &table_type &dsn as select * from connection to &dbmstype

%EXIT:

%put End macro create_dsn_from_dbms;
%mend create_dsn_from_dbms;
