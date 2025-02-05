/**************************************************************************************************************
* Macro_Name:   build_model_dataset
*
* Purpose: This macro is used for updating the portald.reportfields_metadata dataset with fieldnames for 
*          Display on the Portal.
*
* Usage: %build_model_dataset(model_dsn,dsn,dir,ReportName,pgmnm);
*
* Input_parameters: model_dsn - model dataset name that need to be associated with.
*                   dsn - dataset to be used to get the field names
*                   dir - Unix Dir location 
*                   ReportName - Name of the Report
*                   pgmnm - Name of the Program
*
* Outputs:  portald.reportfields_metadata.
*
* Returns:  None.
*
* Example:
*
* Modules_called: None.
*
* Maintenance_History:
*-------------------------------------------------------------------------------------------------------------*
*  Date:      |   Who:        |  Description:                                                                 *
*-------------------------------------------------------------------------------------------------------------*
* 05/24/2012  | Sharad        | Initial creation.                                                             *
*-------------------------------------------------------------------------------------------------------------*
* HeaderEnd:                                                                                                  *
**************************************************************************************************************/
				
%macro build_model_dataset(model_dsn,dsn,dir,ReportName,pgmnm);

%put Start macro build_model_dataset;

	%let rc=%sysfunc(libname(libn01,%superq(dir)));

	 %if %sysfunc(libref(libn01)) %then
	 %do;
	    %let errormsg1=Could not assign libn01 to %superq(dir);
	    %let errormsg2=&syserrortext;
	    %put ERROR: %superq(dir) does NOT exist;
	 %end;
	 %else
	 %do;

	    %put;
	    %put NOTE: Libref libn01 assigned to %sysfunc(pathname(libn01));
	    %put;

		 %if %sysfunc(exist(libn01.&dsn))=0 %then
		 %do;
		    %let errormsg1=Data set libn01.&dsn does not exist.;
		 %end;
		 %else
		 %do;

				proc contents data = libn01.&dsn out =&model_dsn; run;

				data &model_dsn (keep=model_dsn SAS_Field_Name Field_Display Field_Description varnum pgmname ReportName metadata_id);
				  length model_dsn dataset_contrib_model_dsn $32 SAS_Field_Name $32 metadata_id $10 Field_Display $32 Field_Description $256 pgmname ReportName $100 ;
				  set &model_dsn end=last;
						model_dsn="&model_dsn";
						SAS_Field_Name=name;
						pgmname="&pgmnm";
						ReportName="&ReportName";
						Field_Display=strip(translate(SAS_Field_Name,' ','_'));
						metadata_id='';
						if label eq "" then label=name;
						Field_Description=translate(label,' ','_');
						label SAS_field_name='Field Name' Field_Description='Field Description';
				run;
				
				%if %records_in_dataset(&model_dsn) %then
				%do;
					proc append base=portald.reportfields_metadata data=&model_dsn force; run;
				%end;
					
				%drop_table(&model_dsn);
				
		%end;
	%end;

%put End macro build_model_dataset;

%mend build_model_dataset;