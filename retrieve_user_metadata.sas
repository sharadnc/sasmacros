/**************************************************************************************************************                                                               
* Macro_Name:   retrieve_user_metadata.sas                                                                                                                                                 
*                                                                                                                                                                             
* Purpose: this macro is used to retrieve an email address and PersonName from the LDAP Metadata
*                                                                                                                                                                             
* Usage: %retrieve_user_metadata(sid);
*                                                                                                                                                                             
* Input_parameters: sid                                                                                                                                                    
*                    A users SID
*                                                                                                                                                                             
* Outputs:  None.                                                                                                                                                             
*                                                                                                                                                                             
* Returns:  
*                                                                                                                                                                             
* Example: %retrieve_user_metadata(w432445);
*                                                                                                                                                                             
* Modules_called: 
*                                                                                                                                                                             
* Maintenance_History:                                                                                                                                                        
*-------------------------------------------------------------------------------------------------------------*                                                               
*  Date:      |   Who:        |  Description:                                                                 *                                                               
*-------------------------------------------------------------------------------------------------------------*                                                               
* 03/27/2012  | Sharad           | Initial creation.                                                          *                                                               
* 04/01/2013  | Sharad           | When the user left the company then ignore pulling the sid info            *                                                               
*-------------------------------------------------------------------------------------------------------------*                                                               
* HeaderEnd:                                                                                                  *                                                               
**************************************************************************************************************/ 

%macro retrieve_user_metadata(sid);

	%global emailaddress PersonName department phoneno location orglevel ;

 /* Initialize the values */	
 
  %let emailaddress=;
	%let personname=;
	%let department=;
	%let phoneno=;
	%let location=;
	%let orglevel=;	

	%let xmlurl=http://peoplelkp.jpmorgansharadnc.net/peoplelkp/PDXMLService2?sid=&sid;

	filename foo url "&xmlurl";
	%let _error=1;

	filename retrxml "/u04/data/cig_ebi/dmg/&env./dump/retrxml_&runtime..xml"; 
	data _null_;
	   infile foo lrecl=32767 dlm="^";
	   input;
	   file retrxml;
	   put _infile_;
	   if index(_infile_,'error') then call symputx('_error',0);
	run;

  %if &_error %then
  %do;
		libname in xml "/u04/data/cig_ebi/dmg/&env./dump/retrxml_&runtime..xml";
	
		data _null_;
			set in.EmployeeProfile(keep=internalsmtpaddress preferredfirstname lastname department PHONENO BUILDCITY BuildState COUNTRYABBR ORGLEVELC );
			length name $100;
			name=strip(lastname)||","||strip(preferredfirstname);
			/* put _all_; */
			call symputx('emailaddress',internalsmtpaddress);
			call symputx('PersonName',Name);
			call symputx('department',department);	
			call symputx('PHONENO',PHONENO);
			call symputx('Location',strip(BUILDCITY)||", "||strip(BuildState)||", "||strip(COUNTRYABBR));
			call symputx('ORGLEVEL',ORGLEVELC);
		run;
		
		libname in clear;
		
	%end;
	

x "rm -f /u04/data/cig_ebi/dmg/&env./dump/retrxml_&runtime..xml";
	
%mend retrieve_user_metadata;

