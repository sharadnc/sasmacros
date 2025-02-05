/**************************************************************************************************************
* Macro_Name:   encrypt_file
*
* Purpose: This macro is used to zip and encrypt a unix file.
*
* Usage: %encrypt_file(reppath,unxfile,extension);
*
* Input_parameters: reppath
*                    Unix directory pathname to the file.
*                   unxfile
*                    The file to zip and encrypt.
*                   extension
*                    Extension of the file to zip
*
* Outputs:  None.
*
* Returns:  If error, jumptoexit=1
*
* Example:
*
* Modules_called: %get_macro_system_options
*
* Maintenance_History:
*-------------------------------------------------------------------------------------------------------------*
*  Date:      |   Who:           |  Description:                                                              *
*-------------------------------------------------------------------------------------------------------------*
* 12/14/2011  | Sharad           | Initial creation.                                                          *
* 12/14/2011  | Michael Gilman   | Initial creation.                                                          *
* 04/15/2012  | Michael Gilman   | Set nomprint and nosymbolgen to hide password.                             *
* 04/16/2012  | Sharad           | Set the 7za path for Dev and Prod servers                                  *
* 05/25/2012  | Sharad           | 7za command is modified to not put a password when not provided.           *
* 08/28/2012  | Michael Gilman   | Now use %get_macro_system_options to get macro system options.             *
* 10/28/2012  | Michael Gilman   | Minor documentation changes.                                               *
* 12/10/2012  | Michael Gilman   | Now handle possible different zip extensions: zip, gz.                     *
*             |                  | Also streamlined the macro.                                                *
* 02/27/2013  | Sharad           | Add donotzip option and zip_ext option to the macro                        *
*-------------------------------------------------------------------------------------------------------------*
* HeaderEnd:                                                                                                  *
**************************************************************************************************************/

%macro encrypt_file(reppath,unxfile,extension,zipext=);
%put Start macro encrypt_file;

 %local options zip_options command zip_pwd zipextn; 

 %let options=%get_macro_system_options;
 
 %if %length(&zipext) gt 1 %then %let zipextn=&zipext;
 %else %let zipextn=&zip_extension; 

 %if &zipextn=zip %then %let zip_options=%str(-mx5 -tzip);
 %else %if &zipextn=gz %then %let zip_options=%str(-tgzip);
 %else %if &zipextn=donotzip %then %goto EXIT;

 options nomprint nosymbolgen nomlogic;

 proc sql noprint;
  select strip(encr_pwd) into :encr_pwd
  from adminlib.ProgramSetup(where=(upcase(PgmName)=%upcase("&PgmName")));
 quit;


 %if %upcase(&env) eq UAT or %upcase(&env) eq PROD or %upcase(&env) eq IST %then %let command=7za;
 %else %let command=/usr/local/bin/7za;

 %if %length(&encr_pwd) ge 1 %then %let zip_pwd=%str(-p&encr_pwd);
 %else %let zip_pwd=;

 data _null_;

   Z = "&command a &zip_pwd &zip_options";

   text       = "&reppath/&unxfile";
   
   
 %if &zipextn=zip %then 
 %do; 
 	ZZ         = compbl(Z||' '||text||".&zipextn"||' '||text!!".&extension");
 	%end;
 %else
 %if &zipextn=gz %then 
  %do; 
 	ZZ         = compbl(Z||' '||text||".&extension..&zipextn"||' '||text!!".&extension");
 	%end;


   call symput("ZZ", ZZ);

 run;

 options &options;

 /* Encrypting the file using 7-zip */

 systask command "&ZZ" wait taskname=changemod status=encrypt;

 waitfor changemod;

 %if &encrypt ne 0 %then
 %do;
    %if &zipextn=gz %then 
    	%let errormsg1= Could not encrypt the file to produce the file &reppath./&unxfile..&extension..&zip_extension;    
    %else %if &zipextn=zip %then 
    	%let errormsg1= Could not encrypt the file to produce the file &reppath./&unxfile..&zip_extension;    

    %let jumptoexit=1;

 %end;

%EXIT:

	options &options;

%put End macro encrypt_file;
%mend encrypt_file;