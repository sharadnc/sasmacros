/**************************************************************************************************************
* Macro_Name:   split_dsn_by_obs
*
* Purpose: Split a sas data set so that each output data set has a user-specified number of records.
*
* Usage: %split_dsn_by_obs(dsn=,split_dsn=,split_records=,outfile_type=);
*
* Input_parameters: dsn
*                    Data set to split. If no libref specified, saslib is assumed.
*                   split_dsn
*                    Root name of the data sets that will be created as a result of the split.
*                    The names will be suffixed by an integer 1-n where n is the total number of
*                    created datasets.
*                    If this parameter is blank, the dsn value will be used.
*                   split_records
*                    The number of records to split the input data set by.
*                    Each created data set will have these number of records. Last one may have fewer.
*                   outfile_type
*                    Optional. Valid values: txt, tab, sas, xls.
*
* Outputs:  Split data sets.
*
* Returns:  number_of_split_datasets
*           reccnt&i
*            The number of records in each split data set.
*           If outfile_type not missing then:
*            out_&outfile_type&i
*             Name of split data set i
*            _out_file&i
*             Name of flat file i
*
* Example:
*
* Modules_called: records_in_dataset
*
* Maintenance_History:
*-------------------------------------------------------------------------------------------------------------*
*  Date:      |   Who:           |  Description:                                                              *
*-------------------------------------------------------------------------------------------------------------*
* 08/09/2012  | Michael Gilman   | Initial creation.                                                          *
*-------------------------------------------------------------------------------------------------------------*
* HeaderEnd:                                                                                                  *
**************************************************************************************************************/
%macro split_dsn_by_obs(dsn=,split_dsn=,split_records=,outfile_type=);
%put Start macro split_dsn_by_obs;

 %local i j k records_in_dataset dsid temp_rename;

 %if %scan(%superq(dsn),2,%str(.))=%str() %then %let dsn=saslib.&dsn;

 %let libref_dsn=%scan(%superq(dsn),1,%str(.));

 %if &split_dsn=%str() %then %let split_dsn=&dsn;

 %if %scan(%superq(split_dsn),2,%str(.))=%str() %then %let split_dsn=&libref_dsn..&split_dsn;

 %let libref_split_dsn=%scan(%superq(split_dsn),1,%str(.));

 %let name_split_dsn=%scan(%superq(split_dsn),2,%str(.));

 %let records_in_dataset=%records_in_dataset(&dsn);

 %if &records_in_dataset=0 or &records_in_dataset<&split_records %then
 %do; /* No need to split, but still need to create copy with "1" suffix */

    %if &outfile_type ne %str() %then
    %do; /* Create correct out_xxx macro variable */

       %global out_&outfile_type.1 _out_file1;

       %let out_&outfile_type.1=&name_split_dsn.1;

       %let _out_file1=&name_split_dsn.1.&outfile_type;

       %let reccnt1=&records_in_dataset;

    %end;/* Create correct out_xxx macro variable */

    data &libref_split_dsn..&name_split_dsn.1;
     set &dsn;
    run;

    %let number_of_split_datasets=1;

    %goto EXIT;

 %end;/* No need to split, but still need to create copy with "1" suffix */

 %if %symexist(out_rename1) %then %let temp_rename=&out_rename1;

 %let j=0;

 /* Create n number of data sets where n=ceil(&records_in_dataset/&split_records) */

 %do i=1 %to &records_in_dataset %by &split_records;

    %let j=%eval(&j+1);

    %let k=%eval(&j*&split_records);

    data &libref_split_dsn..&name_split_dsn.&j;
     set &dsn (firstobs=&i obs=&k);
    run;

    %global reccnt&j;

    %if &outfile_type ne %str() %then
    %do; /* Create correct out_xxx macro variable */

       %global out_&outfile_type&j _out_file&j;

       %let out_&outfile_type&j=&name_split_dsn.&j;

       %let _out_file&j=&name_split_dsn.&j..&outfile_type;

       %let reccnt&j=&split_records;

       %if %symexist(out_rename1) and &j>1 %then
       %do;

          %global out_rename&j;

          %let out_rename&j=&temp_rename.&j;

       %end;

    %end;/* Create correct out_xxx macro variable */

 %end;

 %let number_of_split_datasets=&j;

 %let dsid=%sysfunc(open(&libref_split_dsn..&name_split_dsn.&number_of_split_datasets));

 %let reccnt&number_of_split_datasets=%sysfunc(attrn(&dsid,nlobs));

 %let dsid=%sysfunc(close(&dsid));

%EXIT:

%put End macro split_dsn_by_obs;
%mend split_dsn_by_obs;