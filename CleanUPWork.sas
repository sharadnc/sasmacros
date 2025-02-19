%macro CleanupWORK(membertype);
/***
ACCESS - access descriptor files (created by SAS/ACCESS software)
ALL - all member types
CATALOG- SAS catalogs
DATA - SAS data files
FDB - financial database
MDDB - multidimensional database
PROGRAM - stored compiled SAS programs
VIEW - SAS views
****/ 


%let validvals=ACCESS ALL CATALOG DATA FDB MDDB PROGRAM VIEW;
%if %index(&validvals,%upcase(&membertype)) gt 0 %then 
  %do;
      proc datasets lib=WORK kill nolist memtype=%upcase(&membertype); 
      quit;
   %end;
%mend;

/* Want to delete all Work Datasets*/
%CleanupWORK(data);
%CleanupWORK(CATALOG);
