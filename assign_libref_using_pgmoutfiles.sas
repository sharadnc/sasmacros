/**************************************************************************************************************
* Macro_Name:   assign_libref_using_pgmoutfiles
*
* Purpose: This macro assigns a libref to a data library using an input program name and an input process date (dt_prcs_data).
*          The macro reads the rstats.program_output_files data set to retrieve the dt_prcs_data values associated
*          with the input pgmname. It then looks for the most recent occurrence of a dt_prcs_data value that has a month/year
*          value equal to the month/year value of the input process date (dt_prcs_data).
*
* Usage: %assign_libref_using_pgmoutfiles(libref=,pgmname=,loc=data,input_dt_prcs_data=);
*
* Input_parameters: libref
*                    libref to assign.
*                   pgmname
*                    Name of program from which to obtain data library pathname.
*                   input_dt_prcs_data
*                    Optional: The process date (dt_prcs_data) to use.
*                    Default: &dt_prcs_data
*
* Outputs:  assign_libref
*           lock_on_member
*           lock_off_member
*
* Returns:  dataset_prefix
*            Prefix to use for data sets needed by calling program.
*           If error, jumptoexit=1
*
* Example:
*
* Modules_called: assign_libref
*                 lock_on_member
*                 lock_off_member
*
* Maintenance_History:
*-------------------------------------------------------------------------------------------------------------*
*  Date:      |   Who:        |  Description:                                                                 *
*-------------------------------------------------------------------------------------------------------------*
* 11/07/2012  | Michael Gilman| Initial creation.                                                             *
* 11/15/2012  | Diego         | Modified date input behavior                                                  *
*-------------------------------------------------------------------------------------------------------------*
* HeaderEnd:                                                                                                  *
**************************************************************************************************************/

%macro assign_libref_using_pgmoutfiles(libref=,pgmname=,loc=data,input_dt_prcs_data=);
%put Start macro assign_libref_using_pgmoutfiles ;

 %local pgmid security_level lob SubjectArea pgmfreq date found input_monthyear;

 %if &input_dt_prcs_data=%str() %then %let input_dt_prcs_data=&dt_prcs_sas;

 proc sql noprint;
 select length(MAX(dt_prcs_data))
 into :length_month
 from rstats.program_output_files
 where pgmname="&pgmname"
 ;
 quit;
	
 %chkerr(msg1=&syserrortext);
 %if &jumptoexit %then %goto ERREXIT;
	
 %if &length_month=1 %then
 %do;
	
    %let errormsg1=Program &pgmname not found.;
	
    %goto ERREXIT;
	
 %end;
 
 %if &length_month=6 %then 
 %do;
 proc sql noprint;
 select put(MAX(input(dt_prcs_data,mmddyy6.)),mmddyy6.)
 into :input_dt_prcs_data
 from rstats.program_output_files
 where pgmname="&pgmname"
 	and input(dt_prcs_data,MMDDYY6.) <= &input_dt_prcs_data.
 ;
 quit;
	
 %end;
 %else
 %do;
 proc sql noprint;
 select put(MAX(input(dt_prcs_data,4.)),Z4.)
 into :input_dt_prcs_data
 from rstats.program_output_files
 where pgmname="&pgmname"
	and input(substr(dt_prcs_data,1,2)||put(DAY(intnx('day',today(),0,'E')),z2.)||substr(dt_prcs_data,3,2),MMDDYY6.) =
	( select MAX(input(substr(dt_prcs_data,1,2)||put(DAY(intnx('day',today(),0,'E')),z2.)||substr(dt_prcs_data,3,2),MMDDYY6.))
		from rstats.program_output_files
		where pgmname="&pgmname"
 		and input(substr(dt_prcs_data,1,2)||put(DAY(intnx('day',today(),0,'E')),z2.)||substr(dt_prcs_data,3,2),MMDDYY6.) <= &input_dt_prcs_data.
 	)
 ;
 quit;
	
 %end;
	
 %chkerr(msg1=&syserrortext);
 %if &jumptoexit %then %goto ERREXIT;
	
 %if &input_dt_prcs_data=%str() %then
 %do;
	
    %let errormsg1=Program &pgmname not found.;
	
    %goto ERREXIT;
	
 %end;
 
 %if %length(&input_dt_prcs_data)=4 %then %let input_monthyear=&input_dt_prcs_data;
 %else %let input_monthyear=%substr(&input_dt_prcs_data,1,2)%substr(&input_dt_prcs_data,5,2);

 %assign_libref(rstats,&rootloc/runtimestats);
 %if &jumptoexit %then %goto ERREXIT;

 %lock_on_member(rstats.program_output_files);
 %if &jumptoexit %then %goto ERREXIT;

 proc sql;
 create table temp as
 select distinct pgmid, lob, security_level, SubjectArea, dt_prcs_data, FilePrefix
 from rstats.program_output_files
 where pgmname="&pgmname"
 ;
 quit;

 %lock_off_member(rstats.program_output_files);

 %if &sqlobs=0 %then
 %do;

    %let errormsg1=Program &pgmname not found in rstats.program_output_files.;

    %put ERROR: &errormsg1;

    %let jumptoexit=1;

    %goto ERREXIT;

 %end;

 data temp;

  set temp;

  if length(dt_prcs_data)=4 then date=input('01'!!dt_prcs_data,ddmmyy6.);
  else date=input(dt_prcs_data,mmddyy6.);

  monthyear=put(month(date),z2.)!!substr(put(year(date),4.),3);

  format date date9.;

 run;

 proc sort data=temp;
 by descending date;
 run;

 %let dataset_prefix=;

 data _null_;

  if _e then call symputx('found',0);

  set temp end=_e;

  if monthyear="&input_monthyear" then
  do;

     call symputx('found',1);

     call symputx('pgmid',pgmid);
     call symputx('lob',lob);
     call symputx('SubjectArea',SubjectArea);
     call symputx('security_level',security_level);
     call symputx('dataset_prefix',FilePrefix);

     stop;

  end;

 run;

 %if &found=0 %then
 %do;

    %let errormsg1=No record found in rstats.program_output_files with process date monthyear=&input_monthyear for &pgmname;

    %put ERROR: &errormsg1;

    %let jumptoexit=1;

    %goto ERREXIT;

 %end;

 %assign_libref(&libref,&rootloc/&loc/&security_level/&lob/&SubjectArea);
 %if &jumptoexit %then %goto ERREXIT;

%ERREXIT:

%put End assign_libref_using_pgmoutfiles ;
%mend assign_libref_using_pgmoutfiles ;