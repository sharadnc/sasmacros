/**************************************************************************************************************
* Macro_Name:   disconnect_from_dbms
*
* Purpose: This macro is used to disconnect from the dbms
*
* Usage: %disconnect_from_dbms;
*
* Input_parameters: alias
*                    This macro variable is set by the call to %connect_to_db.
*                    Note that the macro sets alias to missing upon completion.
*
* Outputs:  None.
*
* Returns:  alias
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
* 04/14/2012  | Michael Gilman   | Removed msg1="Probably Syntax error" from %chkerr.                         *
*-------------------------------------------------------------------------------------------------------------*
* HeaderEnd:                                                                                                  *
**************************************************************************************************************/

%macro disconnect_from_dbms;

 %chkerr(msg1=%superq(syserrortext));

 disconnect from &alias;
 quit;
 
 %put DBMS Connection disconnected from %upcase(&dbtype) at %sysfunc(datetime(),datetime23.);

 %let alias=;

%mend disconnect_from_dbms;
