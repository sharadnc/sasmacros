/**************************************************************************************************************
* Macro_Name:   stop_on_error
*
* Purpose: This macro issues an ABORT statement.
*
* Usage: %stop_on_error;
*
* Input_parameters: jumptoexit
*                    If 1, ABORT statement executes.
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
*-------------------------------------------------------------------------------------------------------------*
* HeaderEnd:                                                                                                  *
**************************************************************************************************************/

%macro stop_on_error;
%put Start macro stop_on_error;

 /* When the value of &jumptoexit eq 1 then, abort the job */

 %if &jumptoexit %then
 %do;

    /*Terminate SAS*/

    data _null_;
     abort return 16;
    run;
 %end;

%put End macro stop_on_error;
%mend stop_on_error;
