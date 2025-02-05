/**************************************************************************************************************
* Macro_Name:   get_varlist_dsn                                                                        
* 
* Purpose: Macro to get a list of all variables in the dataset in different formats
*          
*                                                                                                              
* Usage: %get_varlist_dsn(dsn, varlist=, varlist_comma=, varlistlen=, lenvarlist=);
*
* Input_parameters: dsn=dataset name
*                   varlist=macrovar to which the list of variables is assigned to
*                   varlist_comma=macrovar to which the list of variables separated by comma is assigned to
*                   varlistlen=macrovar to which the list of variables is assigned to
*                   lenvarlist=macrovar to which the list of variables with length statement style is assigned to
*                                                                                                              
* Outputs:  None.                                                                                              
*                                                                                                              
* Returns:  None   
*
* Example: See Below
*                                                                                                              
* Modules_called: None
* 
* Maintenance_History:                                                                                        
*-------------------------------------------------------------------------------------------------------------*
*  Date:      |   Who:        |  Description:                                                                 *
*-------------------------------------------------------------------------------------------------------------*
* 12/14/2011  | Sharad           | Initial creation.                                                          *
*-------------------------------------------------------------------------------------------------------------*
* HeaderEnd:                                                                                                  *
**************************************************************************************************************/

%macro get_varlist_dsn(dsn,varlist=,varlist_comma=,varlistlen=,lenvarlist=);

   %global &varlist &varlistlen &varlist_comma &lenvarlist;

   %if &varlistlen eq %str() %then %let varlistlen=none;
   %if &varlist eq %str() %then %let varlist=none;
   %if &varlist_comma eq %str() %then %let varlist_comma=none;
   %if &lenvarlist eq %str() %then %let lenvarlist=none;

  %if %index(&dsn,.) gt 0 %then %do; %let lib=%upcase(%scan(&dsn,1,.)); %let dsn=%upcase(%scan(&dsn,2,.)); %end;
  %else %do; %let lib=WORK; %let dsn=%upcase(&dsn); %end;

	proc sql noprint;
	select compbl(upcase(name))||compress("["||Propcase(Type)||"("||put(Length,12.)||")]"), 
		   compbl(upcase(name))||" "||strip(compress(case when Type eq 'char' then '$ ' else ' ' end))||strip(put(Length,12.)), 
		   compbl(upcase(name)),
		   compbl(upcase(name))
		   INTO :&varlistlen separated by ",",
		        :&lenvarlist separated by " ",
				:&varlist separated by " ",
				:&varlist_comma separated by ","
	from sashelp.vcolumn
	where memtype="DATA" and libname="%upcase(&lib)" and memname="%upcase(&dsn)" 
	order by varnum;
	quit;
/*	%PUT &varlistlen=&&&varlistlen;*/
/*	%PUT &varlist=&&&varlist;*/
	%PUT &varlist_comma=&&&varlist_comma;

%mend get_varlist_dsn;

/* Usage Example
%get_varlist_dsn(sashelp.class,varlist=list,varlist_comma=list_comma,varlistlen=listlen,lenvarlist=lenlist);
%put list=&list;
%put  listlen=&listlen;
%put  list_comma=&list_comma; 
%put lenlist=&lenlist;

returns
-------------
list_comma=NAME,SEX,AGE,HEIGHT,WEIGHT
list=NAME SEX AGE HEIGHT WEIGHT
listlen=NAME [Char(8)],SEX [Char(1)],AGE [Num(8)],HEIGHT [Num(8)],WEIGHT [Num(8)]
list_comma=NAME,SEX,AGE,HEIGHT,WEIGHT
lenlist=NAME  $8 SEX  $1 AGE  8 HEIGHT  8 WEIGHT  8
*/
