/**************************************************************************************************************
* Macro_Name: retention
*
* Purpose: This macro looks at every sas data set in the &rootloc/&env/data subfolders and determines if
*          it satisfies the retention criteria specified in adminlib.programsetup.
*          If the macro parameter list_only=N and the data set satisfies the retention criteria, it is deleted.
*          The macro also deletes the related report files in &rootloc/&env/reports.
*
* Usage: %retention(env=,list_only=Y);
*
* Input_parameters: rootloc (global)
*                    Root location
*                   env
*                    labs, dev, qa, uat, prod
*                   list_only
*                    Y/N Specify Y if you just want to only display the data sets that satisfy the retention criteria
*                        Otherwise, specify N and data sets will be deleted.
*                    Default: Y
*                   ignore_retention_criteria
*                    Y/N Select Y if you want to ignore the retention criteria as specified in adminlib.programsetup.
*                        This has the effect of producing a report for all found data sets.
*                    Default: N
*                   odstype
*                    Report type: html/pdf/rtf
*                    Default: html
*                   printed_results_sortby
*                    Sort order of printed results.
*                    Default: security_level lob subjectArea pgmname
*                   delete_badname_datasets
*                    Y/N Delete data sets not conforming to the expected naming convention.
*                    Default: Y
*                   datasets_results_dataset
*                    SAS data set containing the results of the data set retention.
*                    Default: work.retention_results
*                   files_deleted_dataset
*                    SAS data set containing the names of the flat files deleted .
*                    Default: work.files_deleted
*                   suppress_log
*                    Y/N Suppress the log (can be large)
*                    Default: N
*
* Outputs:  Report file written to &rootloc/&env/lst/retention_&env_datetime.&odstype
*           datasets_results_dataset
*           files_deleted_dataset
*
* Returns:  None
*
* Example:
*
* Modules_called: lock_on_member
*                 lock_off_member
*                 get_varval_using_pgmid
*                 get_security_levels
*
* Maintenance_History:
*-------------------------------------------------------------------------------------------------------------*
*  Date:      |   Who:        |  Description:                                                                 *
*-------------------------------------------------------------------------------------------------------------*
* 06/06/2012  | Michael Gilman| Initial creation.                                                             *
*-------------------------------------------------------------------------------------------------------------*
* HeaderEnd:                                                                                                  *
**************************************************************************************************************/

%macro retention(env=uat,
                 list_only=Y,
                 ignore_retention_criteria=N,
                 printed_results_sortby=security_level lob subjectArea pgmname,
                 datasets_results_dataset=work.retention_results,
                 files_deleted_dataset=work.files_deleted,
                 delete_badname_datasets=Y,
                 odstype=html,
                 suppress_log=N
                );
%put Start macro retention;

 %global rootloc_EG filesFound number_of_security_levels jumptoexit;

 %local obs memname memnames i j k ii dd len date dataset delete dir
        dnum fref did did_security_level did_lob security_level lob subjectArea
        root_data root_reports dsid dsid_program_out_files obs did_subjectArea lib dataset delete deleted status
        today todayc badname badname_count permanent retention_date retention_datec
        delete deleted string retention_instances_fnl retention_instances_intermed retention_days
        pgmid pgmfreq pgmname pgmfreq_first_letter dsid starttime endtime elaspsedtime elaspsedtimec
 ;

 %let starttime=%sysfunc(datetime());

 %let ignore_retention_criteria=%upcase(&ignore_retention_criteria);

 %let suppress_log=%upcase(&suppress_log);

 %if %superq(rootloc_EG) ne %str() %then %let rootloc=&rootloc_EG/&env;
 %else %let rootloc=&rootloc/&env;

 %let directory_output_location=&rootloc/lst;

 %sysfunc(ifc(%sysfunc(fileref(sasmacr)) and
 %sysfunc(fileref(macrosEG)), filename macrosEG "&rootloc/macros";
          options mautosource mrecall %bquote(sasautos=(macrosEG sasautos)),%str( )));


 %let rtn_final_y=4; %let rtn_temp_y=2; /* Year retention defaults */

 %let rtn_final_q=16; %let rtn_temp_q=2; /* Quarter retention defaults */

 %let rtn_final_m=48; %let rtn_temp_m=2; /* Month retention defaults */

 %let rtn_final_w=16; %let rtn_temp_w=2; /* Week retention defaults */

 %let rtn_final_d=9; %let rtn_temp_d=2; /* Day retention defaults */

 %let today=%sysfunc(today());

 libname adminlib "&rootloc/admin/data";

 %if &syslibrc ne 0 %then
 %do;

    %put ERROR: Could not assign libref adminlib to &rootloc/admin/data;

    %goto ERREXIT;

 %end;

 libname rstats "&rootloc/runtimestats";

 %if &syslibrc ne 0 %then
 %do;

    %put ERROR: Could not assign libref rstats to &rootloc/runtimestats;

    %goto ERREXIT;

 %end;

 %if %sysfunc(exist(adminlib.programsetup))=0 %then
 %do;

    %put ERROR: adminlib.programsetup does not exist.;

    %goto ERREXIT;

 %end;

 %if %sysfunc(exist(rstats.program_output_files))=0 %then
 %do;

    %put ERROR: rstats.program_output_files does not exist.;

    %goto ERREXIT;

 %end;

 %let list_only=%upcase(&list_only);

 %let odstype=%lowcase(&odstype);

 %let delete_badname_datasets=%upcase(&delete_badname_datasets);

 %let root_data=&rootloc/data;

 %let root_reports=&rootloc/reports;

 %let dataset=%scan(&datasets_results_dataset,2,%str(.));

 %if &dataset=%str() %then
 %do;

    %let lib=work;

    %let dataset=&datasets_results_dataset;

 %end;
 %else
 %do;

    %let lib=%scan(&datasets_results_dataset,1,%str(.));

 %end;

 %if %sysfunc(exist(&datasets_results_dataset)) %then
 %do;

    proc datasets lib=&lib nolist nowarn;
    delete &dataset;
    quit;

    %if &syserr>4 %then
    %do;

       %put ERROR: Could not delete &datasets_results_dataset;

       %goto ERREXIT;

    %end;

 %end;

 %let dataset2=%scan(&files_deleted_dataset,2,%str(.));

 %if &dataset2=%str() %then
 %do;

    %let lib2=work;

    %let dataset=&files_deleted_dataset;

 %end;
 %else
 %do;

    %let lib2=%scan(&files_deleted_dataset,1,%str(.));

 %end;

 %if %sysfunc(exist(&files_deleted_dataset)) %then
 %do;

    proc datasets lib=&lib2 nolist nowarn;
    delete &dataset2;
    quit;

    %if &syserr>4 %then
    %do;

       %put ERROR: Could not delete &files_deleted_dataset;

       %goto ERREXIT;

    %end;

 %end;

 proc datasets lib=work nolist nowarn;
 delete badname_datasets;
 quit;

 title1;

 %let title3=;
 %let title4=;

 %lock_on_member(adminlib.programsetup);

 proc sql;
  create table pgmnames as
  select distinct pgmid, pgmname
  from adminlib.programsetup
  order by pgmid
  ;
 quit;

 %lock_off_member(adminlib.programsetup);

 %lock_on_member(rstats.program_output_files);

 proc sql;
  create table keep_datasets as
  select distinct lowcase(file) as memname
  from rstats.program_output_files
  ;
 quit;

 %lock_off_member(rstats.program_output_files);

 %lock_on_member(rstats.program_out_files);

 proc sql;
  create table program_out_files as
  select distinct pgmid, pgmname, security_level, file, lob, SubjectArea, FilePrefix, dt_prcs_data, extension
  from rstats.program_out_files
  ;
 quit;

 %lock_off_member(rstats.program_out_files);

 %get_security_levels(&root_data); /* Get security level */

 %let badname_count=0;

 %if &suppress_log=Y %then
 %do;

    filename _dummy_ DUMMY;

    proc printto log=_dummy_;
    run;

 %end;

 %do i=1 %to &number_of_security_levels;

    %let security_level=&&security_levels&i;

    %let fref=;

    %let dir=&root_data/&security_level;

    %let rc=%qsysfunc(filename(fref,%bquote(&dir)));

    %let did_security_level=%sysfunc(dopen(&fref));

    %if &did_security_level<=0 %then %goto NEXT_SEC;

    %let dnum_security_level=%sysfunc(dnum(&did_security_level));

    %if &dnum_security_level<=0 %then %goto NEXT_SEC;

    %do j=1 %to &dnum_security_level;

       %let lob=%qsysfunc(dread(&did_security_level,&j));

       %let fref=;

       %let dir=&root_data/&security_level/&lob;

       %let rc=%qsysfunc(filename(fref,%bquote(&dir)));

       %let did_lob=%sysfunc(dopen(&fref));

       %if &did_lob<=0 %then %goto NEXT;

       %let dnum_lob=%sysfunc(dnum(&did_lob));

       %if &dnum_lob<=0 %then %goto NEXT;

       %let dsid=0;

       %do dd=1 %to &dnum_lob;

          %let subjectArea=%qsysfunc(dread(&did_lob,&dd));

          %let dir=&root_data/&security_level/&lob/&subjectArea;

          %let fref=;

          %let rc=%qsysfunc(filename(fref,%bquote(&dir)));

          %let did_subjectArea=%sysfunc(dopen(&fref));

          %if &did_subjectArea<=0 %then %goto NEXT3;

          %let dnum_subjectArea=%sysfunc(dnum(&did_lob));

          %if &dnum_subjectArea<=0 %then %goto NEXT3;

          libname saslib "&dir";

          %if &syslibrc ne 0 %then
          %do;

             %put ERROR: Could not assign saslib libref to &dir;

             %goto NEXT3;

          %end;

          proc sql;
           create table memnames as
           select lowcase(memname) as memname, Filesize, modate
           from dictionary.tables
           where libname='SASLIB'
           ;
          quit;

          %let obs=&sqlobs;

          %if &dsid>0 %then %let dsid=%sysfunc(close(&dsid));

          %let dsid=%sysfunc(open(memnames));

          %do k=1 %to &obs;

             %let badname=0;

             %let jumptoexit=0;

             %let rc=%sysfunc(fetch(&dsid));

             %let memname=%sysfunc(getvarc(&dsid,1));

             %let filesize=%sysfunc(getvarn(&dsid,2));

             %let modate=%sysfunc(getvarn(&dsid,3));

             %if %length(&memname)<12 %then %let badname=1;
             %else
             %if %lowcase(%substr(&memname,1,2)) ne %lowcase(&security_level) %then %let badname=1;

             %if &badname=0 %then
             %do;

                %let pgmid=%substr(%scan(&memname,1,%str(_)),3);

                %if %sysfunc(notdigit(&pgmid))=0 %then
                %do;

                   %if %sysevalf(&pgmid>0 and &pgmid<=999) %then
                   %do;

                      %let dt_prcs_data=%scan(&memname,2,%str(_));

                      %let len=%length(&dt_prcs_data);

                      %if %sysfunc(notdigit(&dt_prcs_data))=0 and (&len=4 or &len=6) %then
                      %do;

                         %if &len=4 %then
                         %do;

                            %let date=01&dt_prcs_data;

                            %let date=%sysfunc(inputn(&date,ddmmyy6));

                         %end;
                         %else %let date=%sysfunc(inputn(&dt_prcs_data,mmddyy6));

                      %end;
                      %else %let badname=1;

                   %end;
                   %else %let badname=1;

                %end;
                %else %let badname=1;

             %end;

             %let pgmfreq=;

             %let pgmname=;

             %if &badname=0 %then
             %do;

                %get_varval_using_pgmid(&pgmid,pgmfreq);

                %let pgmfreq=&varval;

                %let pgmfreq=%lowcase(&pgmfreq);

                %if &pgmfreq ne %str() %then
                %do;

                   %get_varval_using_pgmid(&pgmid,pgmname);

                   %let pgmname=&varval;

                   %if &pgmname=%str() %then %let badname=1;

                %end;
                %else %let badname=1;

             %end;

             %if &badname=1 %then
             %do; /* &badname=1 */

                %let badname_count=%eval(&badname_count+1);

                data badname_temp;
                 length dir $200 security_level $2 lob $80 subjectArea $80 dataset $32 ;
                 dir="&dir";
                 security_level="&security_level";
                 lob="&lob";
                 subjectArea="&subjectArea";
                 dataset="&memname";
                 Filesize=&filesize;
                 modate=&modate;
                 format filesize comma32. modate datetime.;
                 label filesize='Filesize' modate='Modified Date';
                run;

                proc append base=badname_datasets data=badname_temp force;
                run;

                %if &list_only=N and &delete_badname_datasets=Y %then
                %do;

                   %lock_on_member(saslib.&memname);

                   %if &jumptoexit=0 %then
                   %do;

                      proc datasets lib=saslib nolist nowarn;
                      delete &memname;
                      quit;

                      %if &syserr<=4 %then
                      %do;

                         %let deleted=Yes;

                         %let status=Success;

                      %end;
                      %else
                      %do;

                         %let status=Delete failed;

                         %put ERROR: Delete failed for saslib.&memname..;
                         %put ERROR: %sysfunc(pathname(saslib));

                      %end;

                      %lock_off_member(saslib.&memname);

                   %end;
                   %else %let status=Lock failed;

                %end;

                %goto NEXT2;

             %end;/* &badname=1 */

             %let len=%length(&dt_prcs_data);

             %if &len=4 %then
             %do;

                %let date=01&dt_prcs_data;

                %let date=%sysfunc(inputn(&date,ddmmyy6));

             %end;
             %else %let date=%sysfunc(inputn(&dt_prcs_data,mmddyy6));

             %let retentions_instances=;

             %let pgmfreq_first_letter=%substr(&pgmfreq,1,1);

             %if &ignore_retention_criteria=N %then
             %do;

                %get_varval_using_pgmid(&pgmid,retention_instances_fnl);

                %let retention_instances_fnl=&varval;

             %end;
             %else %let retention_instances_fnl=-100;

             %if &ignore_retention_criteria=N %then
             %do;

                %get_varval_using_pgmid(&pgmid,retention_instances_intermed);

                %let retention_instances_intermed=&varval;

             %end;
             %else %let retention_instances_intermed=-100;

             %if &retention_instances_fnl=%str(.) or &retention_instances_fnl=%str() %then
                 %let retention_instances_fnl=&&rtn_final_&pgmfreq_first_letter;

             %if &retention_instances_intermed=%str(.) or &retention_instances_intermed=%str() %then
                 %let retention_instances_intermed=&&rtn_temp_&pgmfreq_first_letter;

             %let dsid_keep_datasets=%sysfunc(open(keep_datasets(where=(memname="&memname"))));

             %if &dsid_keep_datasets>0 %then
             %do;

                %if %sysfunc(fetch(&dsid_keep_datasets)) ne -1 %then %let permanent=Yes;
                %else %let permanent=No;

                %let dsid_keep_datasets=%sysfunc(close(&dsid_keep_datasets));

             %end;
             %else %let permanent=No;

             %if &permanent=Yes %then
                %let retention_date=%sysfunc(intnx(&pgmfreq,&today,-&retention_instances_fnl));
             %else
                %let retention_date=%sysfunc(intnx(&pgmfreq,&today,-&retention_instances_intermed));

             %if %sysevalf(&date<&retention_date) %then
             %do;

                %let delete=Yes;

             %end;
             %else %let delete=No;

             %let deleted=No;

             %let status=List only;

             %if &delete=Yes and &list_only=N %then
             %do; /* &delete=Yes and &list_only=N */

                %lock_on_member(saslib.&memname);

                %if &jumptoexit=0 %then
                %do;

                   proc datasets lib=saslib nolist nowarn;
                   delete &memname;
                   quit;

                   %if &syserr<=4 %then
                   %do;

                      %let deleted=Yes;

                      %let status=Success;

                   %end;
                   %else
                   %do;

                      %put ERROR: Delete failed for saslib.&memname..;
                      %put ERROR: %sysfunc(pathname(saslib));

                      %let status=Delete failed;

                   %end;

                   %lock_off_member(saslib.&memname);

                %end;
                %else %let status=Lock failed;

             %end;/* &delete=Yes and &list_only=N */

             data temp;

              length dir $200 pgmid $3 security_level $2 lob $80 subjectArea $80 dataset $32
                     pgmname $80 Deleted Permanent $3 Status $20 modate 8 dt_prcs_data $6
              ;

              dir="&dir";
              pgmid="&pgmid";
              security_level="&security_level";
              lob="&lob";
              subjectArea="&subjectArea";
              dataset="&memname";
              permanent="&permanent";
              delete="&delete";
              deleted="&deleted";
              pgmname="&pgmname";
              status="&status";
              modate=&modate;
              filesize=&filesize;
              dt_prcs_data="&dt_prcs_data";

              label security_level='Security*Level' lob='LOB' subjectArea='Subject Area'
                    dataset='Data Set' pgmname='Program'
                    filesize='Filesize' modate='Modified Date'
              ;

              format filesize comma32. modate datetime.;

             run;

             proc append base=&datasets_results_dataset data=temp force;
             run;


          %NEXT2:

          %end;/* %do k=1 %to &obs */

       %NEXT3:

          %if &did_subjectArea>0 %then %let did_subjectArea=%sysfunc(dclose(&did_subjectArea));

          %let dsid=%sysfunc(close(&dsid));

       %end; /* %do dd=1 %to &dnum_lob */

       %NEXT:

       %if &did_lob>0 %then %let did_lob=%sysfunc(dclose(&did_lob));

    %end; /* %do j=1 %to &dnum_security_level */

 %NEXT_SEC:

    %if &did_security_level>0 %then %let did_security_level=%sysfunc(dclose(&did_security_level));

 %end; /* %do i=1 %to &number_of_security_levels */

 /***************************************************************************/
 /* Now get associated flat files.                                          */
 /***************************************************************************/

 %let where=%str(status in ('List only' 'Success') and permanent='Yes' and delete='Yes');

 %if &list_only=N %then
 %do;

    %let where=&where and deleted='Yes');

 %end;

 proc sql;
  create table pgmid_dt_prcs_data as
  select distinct pgmid, dt_prcs_data
  from &datasets_results_dataset
  where &where
  ;
 quit;

 %let pgmid_obs=&sqlobs;

 %let dsid_pgmid_dt_prcs_data=%sysfunc(open(pgmid_dt_prcs_data));

 %do i=1 %to &pgmid_obs;

    %let rc=%sysfunc(fetch(&dsid_pgmid_dt_prcs_data));

    %let pgmid=%sysfunc(getvarc(&dsid_pgmid_dt_prcs_data,%sysfunc(varnum(&dsid_pgmid_dt_prcs_data,pgmid))));

    %let dt_prcs_data=%sysfunc(getvarc(&dsid_pgmid_dt_prcs_data,%sysfunc(varnum(&dsid_pgmid_dt_prcs_data,dt_prcs_data))));

    %let dsid_program_out_files=%sysfunc(open(program_out_files(where=(pgmid="&pgmid" and dt_prcs_data="&dt_prcs_data"))));

    %do %while(%sysfunc(fetch(&dsid_program_out_files)) ne -1);

       %let file=%sysfunc(getvarc(&dsid_program_out_files,%sysfunc(varnum(&dsid_program_out_files,file))));
       %let security_level=%sysfunc(getvarc(&dsid_program_out_files,%sysfunc(varnum(&dsid_program_out_files,security_level))));
       %let lob=%sysfunc(getvarc(&dsid_program_out_files,%sysfunc(varnum(&dsid_program_out_files,lob))));
       %let SubjectArea=%sysfunc(getvarc(&dsid_program_out_files,%sysfunc(varnum(&dsid_program_out_files,SubjectArea))));
       %let extension=%sysfunc(getvarc(&dsid_program_out_files,%sysfunc(varnum(&dsid_program_out_files,extension))));
       %let pgmname=%sysfunc(getvarc(&dsid_program_out_files,%sysfunc(varnum(&dsid_program_out_files,pgmname))));

       %let report_dir=&root_reports/&security_level/&lob/&SubjectArea;

       %let filename=&report_dir/&file..&extension;
       %put filename=&filename;

       %if %sysfunc(fileexist(&filename)) %then
       %do;

          %let fileref=_ftemp;

          %let rc=%sysfunc(filename(fileref,&filename));

          %let _fid=%sysfunc(fopen(_ftemp));

          %let filesize=%sysfunc(finfo(&_fid,File Size (bytes)));

          %let _fid=%sysfunc(fclose(&_fid));

          %if &list_only=N %then
          %do;

             %let rc=%sysfunc(fdelete(_ftemp));

             %if &rc=0 %then %let file_deleted=Yes;
             %else file_deleted=Failed;

          %end;
          %else %let file_deleted=No;

          data temp;

           length dir $200 pgmid $3 security_level $2 lob $80 subjectArea $80 File $80
                  pgmname $80 Deleted $8
           ;

           dir="&report_dir";
           pgmname="&pgmname";
           pgmid="&pgmid";
           security_level="&security_level";
           lob="&lob";
           subjectArea="&subjectArea";
           file="&file..&extension";
           deleted="&file_deleted";
           pgmname="&pgmname";
           filesize=&filesize;

           label security_level='Security*Level' lob='LOB' subjectArea='Subject Area'
                 filename='File' pgmname='Program'
                 filesize='Filesize'
                 dir='Directory'
           ;

           format filesize comma32.;

          run;

          proc append base=&files_deleted_dataset data=temp force;
          run;

          %let file=%superq(file).zip;

          %let filename=&report_dir/&file;

          %if %sysfunc(fileexist(&filename)) %then
          %do;

             %let fileref=_ftemp;

             %let rc=%sysfunc(filename(fileref,&filename));

             %let _fid=%sysfunc(fopen(_ftemp));

             %let filesize =%sysfunc(finfo(&_fid,File Size (bytes)));

             %let _fid=%sysfunc(fclose(&_fid));

             %if &list_only=N %then
             %do;

                %let rc=%sysfunc(fdelete(_ftemp));

                %if &rc=0 %then %let file_deleted=Yes;
                %else file_deleted=Failed;

             %end;
             %else %let file_deleted=No;

             data temp;

              length dir $200 pgmid $3 security_level $2 lob $80 subjectArea $80 File $80
                     pgmname $80 Deleted $8
              ;

              dir="&report_dir";
              pgmname="&pgmname";
              pgmid="&pgmid";
              security_level="&security_level";
              lob="&lob";
              subjectArea="&subjectArea";
              file="&file";
              deleted="&file_deleted";
              pgmname="&pgmname";
              filesize=&filesize;

              label security_level='Security*Level' lob='LOB' subjectArea='Subject Area'
                    filename='File' pgmname='Program'
                    filesize='Filesize'
                    dir='Directory'
              ;

              format filesize comma32.;

             run;

             proc append base=&files_deleted_dataset data=temp force;
             run;

          %end;

       %end;

    %end;

    %let dsid_program_out_files=%sysfunc(close(&dsid_program_out_files));

 %end;

 %let dsid_pgmid_dt_prcs_data=%sysfunc(close(&dsid_pgmid_dt_prcs_data));

 proc printto;
 run;

 %if &dsid %then %let dsid=%sysfunc(close(&dsid));

 %let todayc=%qsysfunc(putn(&today,mmddyy6));

 %let timec=%sysfunc(time());
 %let timec=%qsysfunc(putn(&timec,time8.));
 %let timec=%trim(%left(%sysfunc(compress(&timec,%str(:)))));
 %if %length(&timec)=5 %then %let timec=0&timec;

 %if &ignore_retention_criteria=Y %then %let title3=%str(title3 "Retention criteria ignored";);

 options orientation=landscape leftmargin=.25in rightmargin=.1in;

 ods _all_ close;

 %if &odstype=html %then %let htmltitle=(title="Retention");
 %else %let htmltitle=;

 ods &odstype file="&directory_output_location/retention_&env._&todayc.&timec..&odstype" &htmltitle style=styles.analysis;

 %if %lowcase(&odstype)=pdf %then
 %do;

    ods pdf pdftoc=1;

 %end;

 %if %sysfunc(exist(&datasets_results_dataset)) %then
 %do;

    proc sort data=&datasets_results_dataset(drop=dt_prcs_data);
    by &printed_results_sortby permanent dataset;
    run;

    %if &list_only=Y %then
    %do;

       data deleted;
        if e then call symputx('_deleted',_N_-1);
        set &datasets_results_dataset(drop=dir pgmid) end=e;
        where delete='Yes';
        drop delete;
       run;

       %let _not_deleted=0;

    %end;
    %else
    %do; /* &list_only=N */

       data deleted not_deleted;

        set &datasets_results_dataset(drop=dir pgmid) end=e;

        if deleted='Yes' then
        do;

           _deleted+1;

           output deleted;

        end;
        else
        do;

           _not_deleted+1;

           output not_deleted;

        end;

        if e then
        do;

           call symputx('_deleted',_deleted);

           call symputx('_not_deleted',_not_deleted);

        end;

        drop deleted _deleted _not_deleted;

       run;

       %let string=deleted;

    %end;/* &list_only=N */

    ods proclabel "%trim(%qleft(%qsysfunc(putn(&_deleted,comma32.)))) data sets satisfying retention criteria";

    title1 "Retention report for root directory location &root_data";
    title2 "%trim(%qleft(%qsysfunc(putn(&_deleted,comma32.)))) data sets satisfying retention criteria";
    &title3
    &title4

    proc print data=deleted split='*';
    by &printed_results_sortby;
    id &printed_results_sortby;
    sum filesize;
    run;

    proc summary data=deleted nway;
    class permanent;
    var filesize;
    output out=smy(drop=_type_) sum=;
    run;

    ods proclabel "Summary by Permanent (Yes/No)";

    title3 "Summary by Permanent (Yes/No)";

    proc print data=smy split='*' noobs;
    sum filesize _freq_;
    label _freq_='Number of Files';
    format _freq_ comma32.;
    run;

    proc summary data=deleted nway;
    class security_level lob subjectarea;
    var filesize;
    output out=smy(drop=_type_) sum=;
    run;

    ods proclabel "Summary by Security Level, LOB, SubjectArea";

    title3 "Summary by Security Level, LOB, SubjectArea";

    proc print data=smy split='*' noobs;
    by security_level lob subjectarea;
    id security_level lob subjectarea;
    sum filesize _freq_;
    label _freq_='Number of Files';
    format _freq_ comma32.;
    run;

    %if &_not_deleted>0 %then
    %do;

       ods proclabel "%trim(%qleft(%qsysfunc(putn(&_not_deleted,comma32.)))) sets satisfying retention criteria but could not be deleted";

       title2 "%trim(%qleft(%qsysfunc(putn(&_not_deleted,comma32.)))) sets satisfying retention criteria but could not be deleted";
       &title3
       &title4

       proc print data=not_deleted split='*';
       by &printed_results_sortby;
       id &printed_results_sortby;
       sum filesize;
       run;

    %end;

    data retained;

     if e then call symputx('_retained',_N_-1);

     set &datasets_results_dataset(drop=dir pgmid) end=e;
     where delete ne 'Yes';

     drop delete deleted status;

    run;

    ods proclabel "%trim(%qleft(%qsysfunc(putn(&_retained,comma32.)))) data sets not satisfying retention criteria";

    title2 "%trim(%qleft(%qsysfunc(putn(&_retained,comma32.)))) data sets not satisfying retention criteria";
    &title3
    &title4

    proc print data=retained split='*';
    by &printed_results_sortby;
    id &printed_results_sortby;
    sum filesize;
    run;

 %end;
 %else
 %do;

    title2 "No data sets found satisfying retention criteria";
    &title3
    &title4

    data temp;
     Info="No data sets found satisfying retention criteria";
    run;

    proc print data=temp noobs;
    run;

 %end;

 %if &badname_count %then
 %do;

    proc sort data=badname_datasets;
    by security_level lob subjectArea dataset;
    run;

    ods proclabel "%trim(%qleft(%qsysfunc(putn(&badname_count,comma32.)))) data sets having non-conforming names";

    title2 "%trim(%qleft(%qsysfunc(putn(&badname_count,comma32.)))) data sets having non-conforming names";
    &title3
    &title4

    proc print data=badname_datasets(drop=dir) split='*';
    by security_level lob subjectArea;
    id security_level lob subjectArea;
    sum filesize;
    run;

 %end;

 %if %sysfunc(exist(&files_deleted_dataset)) %then
 %do;

    %let dsid=%sysfunc(open(&files_deleted_dataset));

    %let files_deleted_dataset_obs=%sysfunc(attrn(&dsid,nlobs));

    %let dsid=%sysfunc(close(&dsid));

    ods proclabel "%trim(%qleft(%qsysfunc(putn(&files_deleted_dataset_obs,comma32.)))) files associated with deleted final data sets";

    title2 "%trim(%qleft(%qsysfunc(putn(&files_deleted_dataset_obs,comma32.)))) files associated with deleted final data sets";
    &title3
    &title4

    proc sort data=&files_deleted_dataset;
    by &printed_results_sortby file;
    run;

    proc print data=&files_deleted_dataset(drop=dir pgmid) split='*';
    by &printed_results_sortby;
    id &printed_results_sortby;
    sum filesize;
    run;

 %end;

 ods &odstype close;

  %let endtime=%sysfunc(datetime());

  %let elapsedtime=%sysevalf(&endtime-&starttime);

  %put *********************************************************************************************;
  %put * Elapsed time: %time_hours_minutes_secs_format(&elapsedtime);
  %put *********************************************************************************************;

%ERREXIT:

%put End macro retention;
%mend retention;

%let env=uat;

%let metadata_env=%upcase(&env);

%let dmgrootloc=/u04/data/cig_ebi/dmg/&env.;

%let stprootloc=&dmgrootloc./stp/code/include;

%include "&stprootloc./dmg_startup_code.sas";

options nomlogic nomprintnest nomlogicnest nosymbolgen;


%let rootloc_EG=/u04/data/cig_ebi/dmg;
%let rootloc=/u04/data/cig_ebi/dmg;

%retention(env=uat,
           list_only=Y,
           ignore_retention_criteria=N,
           odstype=html,
           suppress_log=N,
           datasets_results_dataset=rstats.retention_results_datasets,
           files_deleted_dataset=rstats.retention_results_files
);
