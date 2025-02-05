/**************************************************************************************************************
* Macro_Name: validate_program_long_dsn_names
*
* Purpose: This macro checks the lengths of data set names in a sas program.
*          Data set names are identified by either of the prefix strings:
*           %str(&LibDsnPrefix)
*           %str(&FilePrefix)
*
* Usage: %validate_program_long_dsn_names(program_file,chklen);
*
* Input_parameters: program_file
*                    Full pathname of the program file to check.
*                   chklen
*                    Length to check for, normally 19 or 21. If missing, the pgmfreq global macro value is used
*                    to set the chklen.
*
* Outputs:  work._long_names_unique
*
* Returns:  If error, jumptoexit=1 and errormsg1 macro variables are set.
*
* Example:
*
* Modules_called: None
*
* Maintenance_History:
*-------------------------------------------------------------------------------------------------------------*
*  Date:      |   Who:        |  Description:                                                                 *
*-------------------------------------------------------------------------------------------------------------*
* 04/23/2012  | Michael Gilman| Initial creation.                                                             *
* 05/16/2012  | Michael Gilman| Minor change to put to log second error message.                              *
* 05/17/2012  | Michael Gilman| Added comma to scan delimit string.                                           *
* 06/04/2012  | Michael Gilman| Remove potential tab characters from input line.                              *
* 07/18/2012  | Michael Gilman| Now check for data set havinga macro variable component,                      *
*             |               | e.g.: abc_&dt_prcs_data. If so, convert the macro value.                      *
* 10/08/2012  | Michael Gilman| Fixed bug when there are no saslib data sets created in program.              *
* 10/11/2012  | Michael Gilman| Fixed bug: %if obs<=0 should have been %if &obs<=0                            *
* 10/17/2012  | Michael Gilman| Fixed small bug: Now start looking for long names after we have encountered   *
*             |               | %STEP01.                                                                      *
*-------------------------------------------------------------------------------------------------------------*
* HeaderEnd:                                                                                                  *
**************************************************************************************************************/

%macro validate_program_long_dsn_names(program_file,chklen);
%put Start macro validate_program_long_dsn_names;

 %if %sysfunc(fileexist(&program_file))=0 %then %goto EXIT;

 %if &chklen=%str() %then
 %do;

    %if &pgmfreq=Monthly %then %let chklen=21;
    %else %let chklen=19;

 %end;

 proc datasets lib=work nolist nowarn;
  delete _all_names _long_names;
 quit;

 data _all_names _long_names;

  retain start_looking 0;

  infile "&program_file" truncover end=eof;

  length dataset_original $32 len 8 Dataset $32;

  input line $256.;

  line=translate(line,'','09'x);

  line=compbl(line);

  line=left(line);

  if upcase(line)=:'%STEP01:' then start_looking=1;

  if not start_looking then return;

  more=1;

  do while(more);

     pos1=find(upcase(line),'STR(&LIBDSNPREFIX)');
     pos2=find(upcase(line),'STR(&FILEPREFIX)');

     if pos1=0 and pos2=0 then more=0;
     if pos1=0 and pos2=0 then goto NEXT;

     if pos2=0 then pos=pos1;
     else
     if pos1=0 then pos=pos2;
     else
     if pos1 ne 0 and pos1<pos2 then pos=pos1;
     else pos=pos2;

     dataset=scan(substr(line,pos+5),2,'();., ');

     pos=indexc(dataset,'&');

     if pos then
     do;

        macrovar=substr(dataset,pos+1);

        macroval=symget(macrovar);

        dataset=trim(substr(dataset,1,pos-1))!!macroval;

     end;

     dataset_original=dataset;

     dataset=upcase(dataset);

     output _all_names;

     len=length(dataset);

     if len>&chklen then
     do;

        linenum=_N_;

        output _long_names;

     end;

     line=substr(line,pos+16+len);

  end;

 NEXT:

  keep dataset_original dataset len linenum;

 run;

 %let dsid=%sysfunc(open(_long_names));

 %let obs=%sysfunc(attrn(&dsid,nlobs));

 %let dsid=%sysfunc(close(&dsid));

 %if &obs<=0 %then %goto EXIT;

 proc sort data=_all_names out=_all_names_unique nodupkey;
 by dataset;
 run;

 proc sort data=_long_names out=_long_names_unique nodupkey;
 by dataset;
 run;

 %let dsid=%sysfunc(open(_all_names_unique));

 %let obs_all_names=%sysfunc(attrn(&dsid,nlobs));

 %let dsid=%sysfunc(close(&dsid));

 %let dsid=%sysfunc(open(_long_names_unique));

 %let obs_long_names=%sysfunc(attrn(&dsid,nlobs));

 %let dsid=%sysfunc(close(&dsid));

 data _new_names;

  retain total_names &obs_all_names;

  array names{%eval(&obs_all_names*2)} $32 _temporary_;

  array alpha{35} $1 _temporary_;

  if _N_=1 then
  do;

     do i=1 to &obs_all_names;

        set _all_names;

        names{i}=dataset;

     end;

     do i=1 to 9;

        alpha{i}=left(put(i,1.));

     end;

     do i=10 to 35;

        alpha{i}=byte(i+55);

     end;

  end;

  set _long_names_unique;

  originalDataset=substr(dataset,1,&chklen-1);

  createNewname=0;

  found=0;

  do n=1 to dim(alpha) while(not createNewname);

     newDataset=trim(originalDataset)!!alpha{n};

     do j=1 to dim(names) while(not createNewname);

        if newDataset=names{j} then found=1;

     end;

     if found=0 then createNewname=1;

  end;

  if createNewname then
  do;

     total_names+1;

     newname=newDataset;

     names{total_names}=newname;

     output;

  end;

  keep dataset_original len newname;

  label dataset_original='Original data set name'
        newname='Can be changed to'
        len='Original length'
  ;

 run;

 %let dsid=%sysfunc(open(_new_names));

 %let obs=%sysfunc(attrn(&dsid,nlobs));

 %let dsid=%sysfunc(close(&dsid));

 %if &obs %then
 %do;

    %let jumptoexit=1;

    %let errormsg1=There are &obs unique occurrences of data set names having lengths greater than &chklen..;
    %let errormsg2=HTML file showing the long names can be viewed at &rootloc./dump/&pgmname._long_names.html;

    %put ERROR: &errormsg1;
    %put ERROR: &errormsg2;

    title1 "&obs unique data set names with lengths greater than &chklen characters";
    title2 "Program: &program_file";

    ods listing close;
    ods results on;

    ods html body="&rootloc./dump/&pgmname._long_names.html";

    proc print data=_new_names label;
    run;

    ods html close;

 %end;

%EXIT:

%put End macro validate_program_long_dsn_names;
%mend validate_program_long_dsn_names;
