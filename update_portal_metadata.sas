/**************************************************************************************************************
* Macro_Name:   update_portal_metadata.sas
*
* Purpose: This macro is used to update portal metadata.
*
* Usage: %update_portal_metadata;
*
* Input_parameters: sequence of the Step Numbers to be executed
*
* Outputs:  None.
*
* Returns:
*
* Example:
*
* Modules_called: %split_macrovalue
*
* Maintenance_History:
*-------------------------------------------------------------------------------------------------------------*
*  Date:      |   Who:        |  Description:                                                                 *
*-------------------------------------------------------------------------------------------------------------*
* 12/14/2011  | Sharad           | Initial creation.                                                          *
* 06/13/2011  | Sharad           | When a user is added the adminlib.programsetup_emails_bcc is not updated   *
* 06/25/2012  | Sharad           | Mitigate the existence of the dataset                                      *
* 10/04/2012  | Sharad           | Add Program Prefix to the Search Path                                      *
* 04/01/2013  | Sharad           | Fix the code pulling code metadata on the system                           * 
* 04/04/2013  | Sharad           | keep only the records that really exist on the Unix directories            *                                                       
*-------------------------------------------------------------------------------------------------------------*
* HeaderEnd:                                                                                                  *
**************************************************************************************************************/

%macro update_portal_metadata/parmbuff;

%put syspbuff contains: &syspbuff;
%let steps=%sysfunc(translate(&syspbuff,' ','(',' ',')'));

%split_macrovalue(&steps,stepno,stepcnt,dlm=|);

%do m=1 %to &stepcnt;

	%if &&stepno&m	%then %goto STEP&&stepno&m;
	%else %goto EndMacro;

	%STEP01:

     /* If the Script is disabled then the reports need to be disabled from the Portal as well */
     
			proc sql feedback;
			create table pgm_outputitems as
			select 
			case 
			when A.RECORDACTIVE eq 'N' then 'N'
			else coalesce(B.RECORDACTIVE,A.RECORDACTIVE)
			end as RECORDACTIVE,
			A.PGMNAME,A.MODEL_DSN,A.REPORTNAME,
			RPT_TITLE2,RPT_TITLE3,RPT_FOOTNOTE1,RPT_DESCRIPTION,CSV,XLS,PDF,ZIP,OBS_PAGEBREAK
			from portald.pgm_outputitems A left join adminlib.programsetup B
			on compress(lowcase(A.pgmname))=compress(lowcase(B.pgmname))
			order by A.pgmname;
			
			%delete_insert_allrecords(portald.pgm_outputitems,pgm_outputitems);			
      
      proc sql feedback;
			delete from portald.dmg_report_user_mapping 
			where model_dsn in (
			select lowcase(model_dsn) 
			from adminlib.programsetup A, portald.pgm_outputitems B 
			where A.pgmname=B.pgmname 
			and upcase(A.recordactive) eq 'N' 
			);										
			
			quit;

		/* merge report level and admin level metadata*/
		data _outputitems;
		set portald.pgm_outputitems portald.admin_outputitems;
		keep pgmname model_dsn reportname;
		run;


		proc sql feedback;
			create table PROGRAMSETUP_EMAILS_BCC as
			select A.pgmname, A.model_dsn, A.reportname,B.sid,
		           C.Personname,C.email,C.Department
			from _outputitems A
			     left join
			     portalv.v_dmg_report_user_mapping B
			     on  A.model_dsn=B.model_dsn
			     left join
			     portalw.DMG_PORTAL_USER C
			     on upcase(B.sid)=upcase(C.sid)
		 where upcase(B.user_status) eq 'ACTIVE';
		quit;

		proc sort data=programsetup_emails_bcc nodupkey;
		by pgmname model_dsn sid;
		run;

		data programsetup_emails_bcc1;
		set programsetup_emails_bcc;
		by pgmname model_dsn;

		if first.model_dsn then user_no=0;
		user_no+1;
		run;
		
		%delete_insert_allrecords(portald.programsetup_emails_bcc,programsetup_emails_bcc1);
		%delete_insert_allrecords(adminlib.programsetup_emails_bcc,programsetup_emails_bcc1);

		%lock_on_member(portald.programsetup_emails_bcc);
		%lock_on_member(adminlib.programsetup_emails_bcc);

		proc sort data = portald.programsetup_emails_bcc;
		by pgmname model_dsn; run;

		proc sort data = adminlib.programsetup_emails_bcc;
		by pgmname model_dsn; run;

		%lock_off_member(portald.programsetup_emails_bcc);
		%lock_off_member(adminlib.programsetup_emails_bcc);

		%put End of STEP01;
		%goto DOEND;


	%STEP02:

		/* this variable is created for creating date values for Portal */
		%let check_dsn_years='2009','2010','2011','2012','2013','2014','2015';

		/* Get the other items from program setup */
		proc sql feedback;
		create table &sysuserid._pgm_outputitems as
		select B.SUBJECTAREA, B.PGMFREQ, B.SECURITY_LEVEL, B.PGMID, LOWCASE(B.LOB) as LOB,A.*,
					 compress("/u04/data/cig_ebi/dmg/&env./data/" || UPCASE(B.SECURITY_LEVEL) || '/'
		             || LOWCASE(B.LOB)|| '/' || compress(LOWCASE(B.SUBJECTAREA))) as datadir length=300
		from portald.pgm_outputitems A left join adminlib.programsetup B
		on compress(A.pgmname)=compress(B.pgmname);
		quit;

		data &sysuserid._outputitems;
		set &sysuserid._pgm_outputitems portald.admin_outputitems;
		cnt+1;

		if pgmname="Admin" then sid="";
		length suffix pgmprefix $100;
		if pgmname="Admin" then suffix=model_dsn;
		else
		do;
			count=count(model_dsn,'_');
			if count ge 2 then
			do;
				do i=3 to count+1;
				 suffix=catx('_',suffix,strip(scan(model_dsn,i,'_')));
				end;
			end;
			suffix="_"||strip(suffix);
		end;

		if pgmname="Admin" then pgmprefix='';
		else pgmprefix=compress(lowcase(security_level)||pgmid);

			call symputx(compress('__scnt'),strip(cnt));
			call symputx(compress('suffix'||cnt),strip(suffix));
			call symputx(compress('datadir'||cnt),strip(datadir));
			call symputx(compress('pgmname'||cnt),strip(pgmname));
			call symputx(compress('model_dsn'||cnt),strip(model_dsn));
			call symputx(compress('pgmfreq'||cnt),strip(pgmfreq));
			call symputx(compress('ReportName'||cnt),strip(ReportName));
			call symputx(compress('pgmprefix'||cnt),strip(pgmprefix));
		drop count i;
		run;


		/*Scan the unix file structure for same suffix datasets used to populate the date drop down in reports*/

		%macro BuildDSNList;

			%drop_table(fulldsnlist);

			%do i=1 %to &__scnt;

				filename ps_list pipe "ls -l %superq(datadir&i.)/&&pgmprefix&i*&&suffix&i...sas7b*";

				data dsnlist;
				   infile ps_list end=last dsd missover;

				length modate $30
						line fullpath $ 500 dirpath $ 300
						pgmname $100 suffix $100 ReportName $100
						period $20 dsnname $32 pgmfreq $20 model_dsn $100;

				   array months {12} $3 _temporary_ ("Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec");

					 input line;
					 
					 /*remove files that end with .lck i.e. intermediate lock datasets*/
					 if index(line,'.lck') then delete;
					 
					 Mon=scan(line,6,'');
					 day=scan(line,7,'');
					 time=scan(line,8,'');
					 fullpath=scan(line,9,'');
					 cnt=count(fullpath,"/")+1;
				 	 dsnname=substr(scan(fullpath,cnt,"/","m"),1,length(scan(fullpath,cnt,"/","m"))-9); /*9 for .sas7bdat*/
					 dirpath=substr(fullpath,1,length(fullpath)-length(scan(fullpath,cnt,"/","m"))-1);

			 		pgmname="&&pgmname&i.";
			 		model_dsn="&&model_dsn&i.";
					suffix="&&suffix&i.";
					pgmfreq="&&pgmfreq&i";
					ReportName=strip("&&ReportName&i.");

					if upcase(pgmname) ne "ADMIN" then period=scan(dsnname,2,"_","m");
					else if upcase(pgmname) eq "ADMIN" then period=put(today(),mmddyy6.);

					ncnt=count(dsnname,"_")+1;
					/*		 for daily 6 digit 072811 only*/
					if length(period) eq 6 then
					do;
						dt_process=mdy(input(compress(substr(period,1,2)),2.),input(compress(substr(period,3,2)),2.),input(compress("20"||substr(period,5,2)),4.));
					end;
					/*		 for years 2009 2010 2011 2012 2013 only*/
					else if length(period) eq 4 and period in (&check_dsn_years.) then
					do;
						dt_process=mdy(01,01,input(period,4.));
					end;

					/*		 for Monthly 4 digit 0711 only*/
					else
					do;
						dt_process=mdy(input(compress(substr(period,1,2)),2.),1,input(compress("20"||substr(period,3,2)),4.));
					end;

			/*		if dt_process eq . then delete;*/
			       if dt_process ne . then
					do;
					    dt_day=put(day(dt_process),Z2.);
						dt_month=months(month(dt_process));
						dt_yr=put(year(dt_process),4.);
						if upcase(pgmfreq) in ("DAILY","WEEKLY") then Day_Text=dt_day||"-"||dt_month||"-"||dt_yr;
						if upcase(pgmfreq) = "MONTHLY" then Day_Text=dt_month||"-"||dt_yr;
						date_prcs= put(dt_process,mmddyy10.);


						if upcase(pgmfreq) in ("DAILY","WEEKLY") then date_prcs= date_prcs;
						if upcase(pgmfreq) = "MONTHLY" then date_prcs= compress(substr(date_prcs,1,3)||substr(date_prcs,7));
					end;

					/*calculation for modification date*/
					year=put(year(today()),4.);
					month=month(today());
					do i=1 to dim(months);
					   	if Mon=Months(i) then index=i;
					end;
					if index > month then year=year+1; else year=year;
					yr=put(year(today()),4.);
					modate=compress(put(input(day,2.),z2.)||Mon||yr||":"||time);
			/*		put _all_;*/

					 keep fullpath suffix dsnname pgmfreq modate dirpath period dt_process
			              pgmname dt_day modate date_prcs dt_month dt_yr Day_Text ReportName model_dsn;
				run;
				
				%if %records_in_dataset(dsnlist) %then
				%do;
					proc append base=fulldsnlist data=dsnlist force;
				%end;		
					
				%drop_table(dsnlist);

			%end;


		%mend BuildDSNList;

		%BuildDSNList;

		proc sql noprint;
			select compress(upcase(sid)) into :teamsids separated by ' | '
			from portalw.dmg_portal_user
			where compress(upcase(role)) eq "DMGTEAM"
			order by sid;
		quit;

		/*flatten out the programsetup_emails_bcc per report for list of users sid*/
		data programsetup_emails_bcc(keep=pgmname model_dsn sids);
		length sids $1000;
		retain sids;
		set portald.programsetup_emails_bcc;
		by pgmname model_dsn;
		if first.model_dsn then sids='';
		sids=compress(catx('|',strip(sids),strip(sid)));
		if last.model_dsn then output;
		run;

		/*create one master dataset for each report / admin controlled dataset */
		proc Sql feedback;
			create table portal_report_metadata as
				select X.pgmname,X.PGMID,
					case
						when X.dsnname eq '' then X.model_dsn
						else X.dsnname
					end as dsnname,
					X.modate, X.fullpath, X.dirpath,  X.suffix, X.ReportName, X.csv, X.xls, X.pdf, X.zip, X.period,
					X.model_dsn, X.subjectArea, X.pgmfreq, X.dt_process, X.dt_day, X.dt_month, X.dt_yr, X.Day_Text, X.date_prcs, X.Rpt_title2,
					X.Rpt_title3, X.Rpt_footnote1, X.SECURITY_LEVEL, X.lob,
					X.Rpt_Description,
					X.obs_pagebreak,
					case
						when Z.libdef eq '' then 'HOMELIB'
						else Z.libdef
					end as libdef,
					case
					when compress(upcase(X.pgmname)) eq 'ADMIN' then "&teamsids"
					else coalesce(Y.sids,X.sids)
					end as sids length=3000

				from ( select A.dsnname, A.modate, A.fullpath, coalesce(A.dirpath,B.datadir) as dirpath, A.pgmname, A.suffix, A.ReportName,
					A.period, A.pgmfreq, A.dt_process, A.dt_day, A.dt_month, A.dt_yr, A.Day_Text, A.date_prcs, B.Rpt_title2,
					B.Rpt_title3, B.Rpt_footnote1, B.SECURITY_LEVEL, B.PGMID, B.lob,B.sid as sids,B.model_dsn,B.csv,B.xls,
					B.pdf,B.zip,B.subjectarea,B.Rpt_Description,B.obs_pagebreak
				from &sysuserid._outputitems B left join WORK.FULLDSNLIST A
					on (A.pgmname = B.pgmname) and (A.suffix = B.suffix) and (A.model_dsn=B.model_dsn)
					where compress(A.fullpath) ne ''
						) as X
					left outer join programsetup_emails_bcc Y on X.pgmname = Y.pgmname
					left outer join portald.all_dsn_paths Z on compress(X.dirpath) = compress(Z.path)
		order by X.pgmname, X.ReportName,dt_process desc;
		quit;
		
		/* keep only the records that really exist on the Unix directories*/
		data portal_report_metadata1(drop = fname rc_f);
		set portal_report_metadata;
	
	    fname="tempfile";
	    rc_f=filename(fname,fullpath);
	    if rc_f = 0 and fexist(fname) then output;				    
		run;				
		
		%delete_insert_allrecords(portald.portal_report_metadata,portal_report_metadata1);	

		%lock_on_member(portald.portal_report_metadata);

		proc sort data = portald.portal_report_metadata nodupkey;
		by pgmname PGMID dsnname fullpath dirpath suffix ReportName csv xls pdf zip
		   period model_dsn subjectArea pgmfreq dt_process dt_day dt_month dt_yr Day_Text date_prcs Rpt_title2
		   Rpt_title3 Rpt_footnote1 SECURITY_LEVEL lob sids Rpt_Description libdef;
		run;

		%lock_off_member(portald.portal_report_metadata);

		%put End of STEP02;
		%goto DOEND;

	%STEP03:

    /*Here we add field level metadata by the model dataset name..
    For most cases this should be sufficient... */
    
		proc sql noprint feedback;
		create table ____temp as
		select pgmname, suffix, model_dsn, dsnname,dirpath, ReportName		      
		from portald.portal_report_metadata A
		where pgmname=symget("__pgmname") and  model_dsn=symget("__model_dsn");
		quit;

    %if %records_in_dataset(____temp) %then
    %do;
				proc sql noprint feedback;
				select pgmname, suffix, model_dsn, dsnname,dirpath, ReportName
				      into :_pgmname, :_suffix, :_model_dsn, :_dsnname,:_dirpath, :_ReportName
				from portald.portal_report_metadata A
				where pgmname=symget("__pgmname") and  model_dsn=symget("__model_dsn");
				quit;
		
				%put _pgmname=&_pgmname _suffix=&_suffix _model_dsn=&_model_dsn _dsnname=&_dsnname _dirpath=&_dirpath _ReportName=&_ReportName;
		
				%lock_on_member(portald.reportfields_metadata);
		
				/* Use this macro invocation for every new report to be added.*/
				%build_model_dataset(&_model_dsn,                     /*model dataset name usually add mmyy for the dsn*/
				                   &_dsnname,                     /*dataset from which the metadata attributes should be picked up from*/
				                   &_dirpath,  /*Location of the dataset on the Unix dir */
				                   &_ReportName,                       /*Report Name that would be displayed on the DMG Main Page*/
				                   &_pgmname);                            /*name of the program no .sas ext*/
		
				proc sort data=portald.reportfields_metadata nodupkey;
		        by model_dsn SAS_field_name; run;
		        
				proc sort data=portald.reportfields_metadata;
		        by model_dsn varnum SAS_field_name; run;		        
		
				%lock_off_member(portald.reportfields_metadata);
				
		%end;
		
		%put End of STEP03;
		%goto DOEND;

	%STEP04: /* Update Code metadata */
		%global which_codedir GotoPage;
		%let which_codedir=code;
		%let GotoPage=1;
		%include "/u04/data/cig_ebi/dmg/&env/stp/code/include/update_code_metadata.sas";
	  %goto DOEND;

	%STEP05: /* Update Macro code metadata */
	  %global which_codedir GotoPage;
		%let which_codedir=macros;
		%let GotoPage=1;
		%include "/u04/data/cig_ebi/dmg/&env/stp/code/include/update_code_metadata.sas";
		%goto DOEND;

	%STEP06:/* Update Search metadata */

		%let rootdir=/u04/data/cig_ebi/dmg/&env./code;

		filename ps_list pipe "find %superq(rootdir) -name '*.sas'";

		data sasjob_metadata(keep= line_num codepath line pgmname);
		   infile ps_list;
		   length line sascodefilename fullpath codepath $ 500 pgmname $ 100 ;

			input sascodefilename;
			fullpath=strip(sascodefilename);

		  /* the following infile statement reads from each of the ;
		   raw data files listed after the cards statement; */
		  infile dummy filevar=fullpath end=EOF dlm="!" dsd missover;

			line_num=0;
		  do until (EOF);
		   line_num + 1;
			  input line;
			  codepath=fullpath;
				cnt=count(codepath,"/")+1;
				pgmname=substr(scan(codepath,cnt,"/","m"),1,length(scan(codepath,cnt,"/","m")));
		    output;
		  end;
		run;
		
		%delete_insert_allrecords(portald.sasjob_metadata,sasjob_metadata);

		%goto DOEND;

	%STEP07:/* Update Search metadata */

		%let rootdir=/u04/data/cig_ebi/dmg/&env./macros;

		filename ps_list pipe "find %superq(rootdir) -name '*.sas'";

		data macro_metadata(keep= line_num codepath line pgmname);
		   infile ps_list;
		   length line sascodefilename fullpath codepath $ 500 pgmname $ 100 ;

			input sascodefilename;
			fullpath=strip(sascodefilename);

		  /* the following infile statement reads from each of the ;
		   raw data files listed after the cards statement; */
		  infile dummy filevar=fullpath end=EOF dlm="!" dsd missover;

			line_num=0;
		  do until (EOF);
		   line_num + 1;
			  input line;
			  codepath=fullpath;
				cnt=count(codepath,"/")+1;
				pgmname=substr(scan(codepath,cnt,"/","m"),1,length(scan(codepath,cnt,"/","m")));
		    output;
		  end;
		run;
		
		%delete_insert_allrecords(portald.macro_metadata,macro_metadata);

		%put End of STEP07;
		%goto DOEND;		

		
	%STEP08:
	
	/*Here we add field level metadata by the absolute dataset name */

		proc sql noprint feedback;
		create table ____temp as
		select pgmname, suffix, model_dsn, dsnname,dirpath, ReportName		      
		from portald.portal_report_metadata A
		where pgmname=symget("__pgmname") and  dsnname=symget("__dsnname");
		quit;

    %if %records_in_dataset(____temp) %then
    %do;
				proc sql noprint feedback;
				select pgmname, suffix, model_dsn, dsnname,dirpath, ReportName
				      into :_pgmname, :_suffix, :_model_dsn, :_dsnname,:_dirpath, :_ReportName
				from portald.portal_report_metadata A
				where pgmname=symget("__pgmname") and  dsnname=symget("__dsnname");
				quit;
		
				%put _pgmname=&_pgmname _suffix=&_suffix _model_dsn=&_model_dsn _dsnname=&_dsnname _dirpath=&_dirpath _ReportName=&_ReportName;
		
		
				%lock_on_member(portald.reportfields_metadata);
		
				/* Use this macro invocation for every new report to be added.*/
				%build_model_dataset(&_model_dsn,                     /*model dataset name usually add mmyy for the dsn*/
				                   &_dsnname,                     /*dataset from which the metadata attributes should be picked up from*/
				                   &_dirpath,  /*Location of the dataset on the Unix dir */
				                   &_ReportName,                       /*Report Name that would be displayed on the DMG Main Page*/
				                   &_pgmname);                            /*name of the program no .sas ext*/
		
				proc sort data=portald.reportfields_metadata nodupkey;
		        by model_dsn SAS_field_name; run;
		        
				proc sort data=portald.reportfields_metadata;
		        by model_dsn varnum SAS_field_name; run;		        
		
				%lock_off_member(portald.reportfields_metadata);
		%end;
		
		%put End of STEP08;
		%goto DOEND;		

	%STEP09:
	
	/*Here we update end user's Email, Name, organization and department information */
	
	    data new(keep=sid);
	    	set portalw.dmg_portal_user;
	    	if index(upcase(PersonName),'LIST') gt 0 then delete;
	    run;	
			
			proc sort data=new nodupkey; by sid;run;
			
			%macro loop(dsn);
			
					%drop_table(dmg_portal_user_final);
					
					%let cnt=%records_in_dataset(&dsn);
					%convert_varval_seriesof_macroval(&dsn,sid,sid);
					
					%do i=1 %to &cnt;
					
						%retrieve_user_metadata(&&sid&i.);
											
						data dmg_portal_user;
							length email personname department phoneno location orglevel $200 data_security_level $2 Who_added $7 sid $10;
					
						  email=symget("emailaddress");
							personname=symget("personname");
							department=upcase(symget("department"));
							phoneno=symget("phoneno");
							location=upcase(symget("location"));
							orglevel=upcase(symget("orglevel"));							
							data_security_level="L1";
							Who_added="&_metauser";
							Dt_added=datetime();
							Dt_Ended=.;	
						  sid=lowcase(symget("sid&i."));  
							if compress(email)="" then delete;
						run;	
					  
					  %if %records_in_dataset(dmg_portal_user) %then 
					  %do;
							proc append base = dmg_portal_user_final data = dmg_portal_user force; run;
						%end;
						
					%end;
			%mend;
			
			%loop(new);
			
			proc sort data=dmg_portal_user_final nodupkey; by sid;run;
			proc sort data=portalw.dmg_portal_user out=dmg_portal_user nodupkey; by sid; run;
			proc sort data=portalw.dmg_portal_user out=dmg_portal_user_bkp; by sid; run;			
			
			%delete_insert_allrecords(portalw.dmg_portal_user_bkp,dmg_portal_user_bkp);
			
			data dmg_portal_users;
			length sid $ 10;
			merge dmg_portal_user(in = A) dmg_portal_user_final(in = B keep=email sid PersonName department	phoneno	location orglevel) ;
			by sid;
			run;
			
			proc sort data=dmg_portal_users nodupkey; by sid;run;
			
			data dmg_portal_user2;
			set dmg_portal_users;
			sid=lowcase(sid);
			email=lowcase(email);
			department=upcase(department);
			location=upcase(location);
			orglevel=upcase(orglevel);
			if compress(subrole)="" then subrole="End User";
			if compress(role)="" then role="End User";
			if compress(data_security_level)="" then role="L1"; 
			if Dt_added=. then Dt_added=datetime();
			if compress(who_added)="" then who_added="&_metauser";
			run;		      
      
      %delete_insert_allrecords(portalw.dmg_portal_user,dmg_portal_user2);
      
		%put End of STEP09;
		%goto DOEND;		

	%DOEND:


%end;

%EndMacro:

%mend update_portal_metadata;