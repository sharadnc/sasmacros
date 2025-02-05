/**************************************************************************************************************
* Macro_Name:   lock_on_member
*
* Purpose: Lock a SAS data set.
*          This macro uses the LOCK statement to attempt to lock a SAS data
*          set.
*
*          The program loops for up to LockAttemptSeconds trying to lock the
*          data set.
*
*          IMPORTANT: You must clear the lock after your program has
*                     finished processing the data set.
*                     Example: lock dataset clear;
*
* Usage: %lock_on_member(dataset,LockAttemptSeconds=60);
*
* Input_parameters:
*             dataset
*              Data set to lock.
*             LockAttemptSeconds
*              Number of seconds to try for a lock.
*
* Outputs:  None.
*
* Returns:  returnCode
*             1 if lock successful, else 0.
*           If error, jumptoexit=1
*
* Example:
*
* Modules_called: random_number_generate
*
* Maintenance_History:
*-------------------------------------------------------------------------------------------------------------*
*  Date:      |   Who:           |  Description:                                                              *
*-------------------------------------------------------------------------------------------------------------*
* 12/14/2011  | Michael Gilman   | Initial creation.                                                          *
* 05/08/2012  | Michael Gilman   | Changed default of LockAttemptSeconds from 15 to 60.                       *
*-------------------------------------------------------------------------------------------------------------*
* HeaderEnd:                                                                                                  *
**************************************************************************************************************/

%macro lock_on_member(dataset,LockAttemptSeconds=60);
%put Start macro lock_on_member;

 %global returnCode;

 %local rc btime etime iterations seconds;

 %let returnCode=0;

 %let btime=%sysfunc(time());

 %let iterations=0;

 %if %sysfunc(exist(&dataset))=0 %then
 %do;

    %let errormsg1=Data set &dataset does not exist.;

    %let jumptoexit=1;

    %goto EXIT2;

 %end;

 %if %scan(&dataset,2,%str(.))=%str() %then %let dataset=work.&dataset;

%LOOP:

 %let iterations=%eval(&iterations+1);

 %put Attempt &iterations: Trying to get a lock on the dataset &dataset....;

 lock &dataset;

 %if &syslckrc<=0 %then %goto EXIT;

 %let etime=%sysfunc(time());

 %if %sysevalf(%sysevalf(&etime-&btime)>&LockAttemptSeconds) %then %goto ERREXIT;

 %let seconds=%random_number_generate(min=.1,max=1,interval=.1);

 %let rc=%sysfunc(sleep(&seconds,1));

 %goto LOOP;

%ERREXIT:

 %let errormsg1=Could not lock data set &dataset;

 %let jumptoexit=1;

 %goto EXIT2;

%EXIT:

 %let returnCode=1;

%EXIT2:

%put End macro lock_on_member;
%mend lock_on_member;

