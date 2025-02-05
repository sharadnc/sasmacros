/**************************************************************************************************************
* Macro_Name:   error_check
*
* Purpose: This macro combines the functionality of the %check_error_and_zero_records and %chkerr macros.
*          If the parameter check_zero_records=Y then macro %check_error_and_zero_records is called,
*          otherwise %chkerr is called.
*
*          The advantage of using this macro is twofold:
*          1. The programmer can use one macro for error checking.
*          2. As this macro returns the value for jumptoexit, the check for &jumptoexit can be consolidated
*             into the macro call; for example:
*              %if %error_check(step=error check,check_zero_records=Y) %then %goto StopMacroProcessing;
*
* Usage: error_check(step=, dsn=, errCaptur=,check_zero_records=N, msg1=, msg2=, msg3=, msg4=, msg5=);
*
* Input_parameters: step
*                    Optional. A descriptive name of the last sas step executed
*                   dsn
*                    The name of the sas data set to check. Default is &SYSLAST
*                   errCaptur
*                    The sas return code from the previous sas step. If not passed in:
*                      If &sqlxrc set, it is used
*                      else
*                      if &sqlrc is set, it is used
*                      else &syserr is used
*                   check_zero_records
*                    Y/N. If Y, then macro %check_error_and_zero_records is called, otherwise %chkerr is called.
*                         Default: N
*                   msg1-msg5
*                    Error messages to set if in error
*
* Outputs:  None
*
* Returns:  jumptoexit
*
* Example:
*
* Modules_called: %check_error_and_zero_records
*                 %chkerr
*
* Maintenance_History:
*-------------------------------------------------------------------------------------------------------------*
*  Date:      |   Who:           |  Description:                                                              *
*-------------------------------------------------------------------------------------------------------------*
* 09/05/2012  | Michael Gilman   | Initial creation.                                                          *
*-------------------------------------------------------------------------------------------------------------*
* HeaderEnd:                                                                                                  *
**************************************************************************************************************/

%macro error_check(step=,dsn=,errCaptur=,check_zero_records=N,msg1=,msg2=,msg3=,msg4=,msg5=);

 %if %upcase(&check_zero_records)=Y %then
    %check_error_and_zero_records(step=&step,dsn=&dsn,errCaptur=&errCaptur,msg1=&msg1,msg2=&msg2,msg3=&msg3,msg4=&msg4,msg5=&msg5);
 %else
    %chkerr(step=&step,errCaptur=&errCaptur,msg1=&msg1,msg2=&msg2,msg3=&msg3,msg4=&msg4,msg5=&msg5);

  &jumptoexit

%mend error_check;
