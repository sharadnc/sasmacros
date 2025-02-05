/**************************************************************************************************************
* Macro_Name:   update_history
*
* Purpose: Updates a master history data set with records from another data set. PROC APPEND is used.
*          IMPORTANT: The name of the history data set must be passed in without a libref. This macro dynamically
*          assigns the libref using the current global values of security, lob, SubjectArea.
*
* Usage: %update_history(trans_dataset=,history_dataset=);
*
* Input_parameters: trans_dataset
*                    Name of data set containing records to insert into master history data set.
*                   history_dataset
*                    Name of history data set.
*                   rootloc (global)
*                   security (global)
*                   lob (global)
*                   SubjectArea (global)
*                   rootloc (global)
*                   dt_prcs_data (global)
*                    Process date
*
* Outputs:  Updates history data set.
*
* Returns:  If error, jumptoexit set to 1.
*
* Example:
*
* Modules_called: %assign_libref
*                 %lock_on_member
*                 %lock_off_member
*                 %chkerr
*
* Maintenance_History:
*-------------------------------------------------------------------------------------------------------------*
*  Date:      |   Who:        |  Description:                                                                 *
*-------------------------------------------------------------------------------------------------------------*
* 07/16/2012  | Michael Gilman   | Initial creation.                                                          *
*-------------------------------------------------------------------------------------------------------------*
* HeaderEnd:                                                                                                  *
**************************************************************************************************************/

%macro update_history(trans_dataset=,history_dataset=);
%put Start macro update_history;

 %if %scan(&history_dataset,2,%str(.))>0 %then
 %do;

    %let jumptoexit=1;

     %let errormsg1=The history data set parameter cannot be specified with a libref.;
     %let errormsg2=The libref is dynamically assigned using the current global values of security, lob, SubjectArea.;

     %goto ERREXIT;

 %end;

 %assign_libref(history,&rootloc/history/&security_level/&lob/&SubjectArea);
 %if &jumptoexit %then %goto EXIT;

 %if %sysfunc(exist(&trans_dataset,%str(DATA)))=0 and %sysfunc(exist(&trans_dataset,%str(VIEW)))=0 %then
 %do;

    %let jumptoexit=1;

	  %let errormsg1=Transaction data set &trans_dataset does not exist.;

	  %goto ERREXIT;

 %end;

 %if %sysfunc(exist(history.&history_dataset))=0 %then
 %do;

    %let jumptoexit=1;

	  %let errormsg1=History data set &history_dataset does not exist in &rootloc/history/&security_level/&lob/&SubjectArea;

	  %goto ERREXIT;

 %end;

 %lock_on_member(history.&history_dataset);
 %if &jumptoexit %then %goto ERREXIT;

 %let dsid=%sysfunc(open(history.&history_dataset));

 %let varnum=%sysfunc(varnum(&dsid,dt_prcs_data));

 %let dsid=%sysfunc(close(&dsid));

 %if &varnum=0 %then
 %do;

    %let jumptoexit=1;

	  %let errormsg1=History data set &history_dataset does not have required variable DT_PRCS_DATA.;

	  %goto EXIT;

 %end;

 proc sql;
 delete
 from history.&history_dataset
 where dt_prcs_data="&dt_prcs_data"
 ;
 quit;

 %chkerr(msg1=Could not delete records from history.&history_dataset, msg2=&syserrortext);
 %if &jumptoexit %then %goto EXIT;

 data temp;

 length dt_prcs_data $6;
 retain dt_prcs_data "&dt_prcs_data";

 set &trans_dataset;

 run;

 proc append base=history.&history_dataset data=temp force;
 run;

 %chkerr(msg1=Could not append records to history.&history_dataset, msg2=&syserrortext);
 %if &jumptoexit %then %goto EXIT;

%EXIT:

 %lock_off_member(history.&history_dataset);

%ERREXIT:

%put End macro update_history;
%mend update_history;
