/**************************************************************************************************************
* Macro_Name:   ftp_file                                                                        
* 
* Purpose: this macro is used to ftp a file using sas from one server to another
*          
*                                                                                                              
* Usage: %ftp_file(localfile,localdir,remotefile,remotedir,remotehost,ftpcommand);
*
* Input_parameters: None.
*                                                                                                              
* Outputs:  None.                                                                                              
*                                                                                                              
* Returns:  None   
*
* Example: 
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

%macro ftp_file(localfile,localdir,remotefile,remotedir,remotehost,ftpcommand);
%put Start macro ftp_file;

 options comamid=tcp;

 proc Sql noprint;
  select strip(username),strip(passwd)
  into :rmtuser, :rmtpw
   from adminlib.ftpinfo
    where upcase(host)="%upcase(&remotehost.)" and RecordActive="Y";
 quit;

 /* Set a filename FTP statement to remote file */
    filename rmfile ftp &remotefile cd=&remotedir. host=&remotehost. user=&rmtuser. pass=&rmtpw.;

 %if &ftpcommand = get %then      /*i.e. download remotefile to the Local file */
 %do;

    /* Check if the file exists */

    %let rc=%sysfunc(fexist(rmfile));

    %*****If unable to establish a filename, send error stop;

    %if (&rc eq 0)%then
    %do;

       %put ******Unable to establish FTP connection to file--&rc.;
       %put ******Problem with input file: &remotefile.;
       %let rc= -1;

    %end;
    %else
    %do;

        %put ******Establish FTP connection to file--&remotefile;

        data _null_;
         infile rmfile;
         file "&localdir./&localfile.";
         input;
         put _infile_;
        run;

       %let filrf=lclfile;

       %let rc=%sysfunc(filename(filrf,"&localdir./&localfile."));

    %end;

 %end;
 %else
 %if &ftpcommand = put %then
 %do;

    /* Check if the file exists */

    %let filrf=lclfile;

    %let rc=%sysfunc(filename(filrf,"&localdir./&localfile."));

    %if &rc ne 0 %then
    %do;

       %put %sysfunc(sysmsg());

    %end;
    %else
    %do;

       data _null_;
        infile "&localdir./&localfile.";
        file rmfile;
        input;
        put _infile_;
       run;

       /* Check if the file exists */

       %let rc=%sysfunc(fexist(rmfile));

    %end;

 %end;

 %put ftp returncode:&rc;

 /* Abort the job with rc=16 for batch processes...
    Remove this line if you are using it in interactive sas..else your session will be ended
 */

 %chkerr(errCaptur=&rc,msg1=FTP Failed,msg2=Error in Ftp Step: Exited with &rc);

%put End macro ftp_file;
%mend ftp_file;

