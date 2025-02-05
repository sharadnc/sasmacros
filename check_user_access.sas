/**************************************************************************************************************                                                                                                                                                 
* Macro_Name:   check_user_access.sas  
*                                                                                                                                                                                                                                                               
* Purpose: This macro fetches the user access from portald.dmgaccess_links for the logged on user
*                                                                                                                                                                                                                                                               
* Usage: %check_user_access(wsid);
*                                                                                                                                                                                                                                                               
* Input_parameters: wsid 
*                    sid to check access                                                                                                                                                                                                                                     
*
* Outputs:  None.
*                                                                                                                                                                                                                                                               
* Returns:  which_sid(global)....updates the value of which_sid.
*                                                                                                                                                                                                                                                               
* Example:  %check_user_access(w432445)
*                                                                                                                                                                                                                                                               
* Modules_called:  None
*                                                                                                                                                                                                                                                               
* Maintenance_History:   
*-------------------------------------------------------------------------------------------------------------*                                                                                                                                                 
*  Date:      |   Who:        |  Description:                                                                 *                                                                                                                                                 
*-------------------------------------------------------------------------------------------------------------*                                                                                                                                                 
* 03/28/2012  | Sharad           | Initial creation.                                                          *                                                                                                                                                 
* 07/24/2012  | Sharad           | Initialize the value of _role_sid to blank                                 *                                                                                                                                                 
*-------------------------------------------------------------------------------------------------------------*                                                                                                                                                 
* HeaderEnd:                                                                                                  *                                                                                                                                                 
**************************************************************************************************************/  

%macro check_user_access(wsid);
	%put Start macro check_user_access; 
	
 %global which_sid;
 %let _role_sid=0;
 
 /*reset the dmgbatch*/
 %if %lowcase(%superq(wsid)) eq dmgbatch@saspw %then %let wsid=dmgbatch;

  /*check if the user is a DMG Team member with Report Admin access*/
  
  proc sql feedback noprint;	
		select compress(Report_Admin_&env.) into :_role_sid
		from portalw.dmglinks_accesses
		where compress(lowcase(sid))=compress(lowcase("&wsid"));
	quit;
	
	%let _role_sid=&_role_sid.;
	
	%put _role_sid=&_role_sid.;
	
	
	%if &_role_sid %then %do; %let which_sid=ADMIN; %end;
	%else %do; %let which_sid=%lowcase(&wsid.); %end;

	%put which_sid=&which_sid;

%put End macro check_user_access;
%mend check_user_access;