/**************************************************************************************************************
* Macro_Name:   set_date_prefixes
*
* Purpose: This macro is not currently used.
*
* Usage: %set_date_prefixes;
*
* Input_parameters: None.
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
* 12/14/2011  | Michael Gilman   | Initial creation.                                                          *
*-------------------------------------------------------------------------------------------------------------*
* HeaderEnd:                                                                                                  *
**************************************************************************************************************/

%macro set_date_prefixes;
%put Start macro set_date_prefixes;

%local dt_prcs date day month;

%let dt_prcs=%sysfunc(int(&dt_prcs_sas));

 %do i=0 %to 6; /* Days */

    %global dt_prefix_day_&i;

    %let date=%sysfunc(intnx(day,&dt_prcs,-&i));

    %let dt_prefix_day_&i=%sysfunc(putn(&date,date9.));

    %let weekday=%sysfunc(putn(&date,downame.));

    %let day=%lowcase(%substr(%superq(weekday),1,3));

    %global dt_prefix_&day;

    %let dt_prefix_&day=&&dt_prefix_day_&i;

 %end;

 %do i=0 %to 6; /* Months */

    %global dt_prefix_month_&i;

    %let date=%sysfunc(intnx(month,&dt_prcs,-&i));

    %let dt_prefix_month_&i=%sysfunc(putn(&date,mmyyn4.));

    %let month=%sysfunc(putn(&date,monname.));

    %let month=%lowcase(%substr(%superq(month),1,3));

    %global dt_prefix_&month;

    %let dt_prefix_&month=&&dt_prefix_month_&i;

 %end;

%put End macro set_date_prefixes;
%mend set_date_prefixes;

