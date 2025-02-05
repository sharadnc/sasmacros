/**************************************************************************************************************                                                                                                                                                 
* Macro_Name:   check_dmglink_access.sas                                                                                                                                                                                                                           
*                                                                                                                                                                                                                                                               
* Purpose: This macro fetches vars from portald.dmgaccess_links for the logged on user to retrieve access parameters                                                                                                                                                                                                 
*                                                                                                                                                                                                                                                               
* Usage: %check_dmglink_access(accessvars);                                                                                                                                                                                                                                
*                                                                                                                                                                                                                                                               
* Input_parameters: Several global macro variables requested by program.                                                                                                                                                                                 
*                                                                                                                                                                                                                                                               
* Outputs:  None.                                                                                                                                                                                                                                               
*                                                                                                                                                                                                                                                               
* Returns:  None                                                                                                                                                                                                                             
*                                                                                                                                                                                                                                                               
* Example:                                                                                                                                                                                                                                                      
*                                                                                                                                                                                                                                                               
* Modules_called: %records_in_dataset
*                 %convert_allvars_macrovars                                                                                                                                                                                                                       
*                                                                                                                                                                                                                                                               
* Maintenance_History:                                                                                                                                                                                                                                          
*-------------------------------------------------------------------------------------------------------------*                                                                                                                                                 
*  Date:      |   Who:        |  Description:                                                                 *                                                                                                                                                 
*-------------------------------------------------------------------------------------------------------------*                                                                                                                                                 
* 03/28/2012  | Sharad           | Initial creation.                                                          *                                                                                                                                                 
*-------------------------------------------------------------------------------------------------------------*                                                                                                                                                 
* HeaderEnd:                                                                                                  *                                                                                                                                                 
**************************************************************************************************************/  

%macro check_dmglink_access/parmbuff;
	%put Start macro check_dmglink_access; 

   %put syspbuff contains: &syspbuff;
   %let selectvars=%sysfunc(translate(&syspbuff,' ','(',' ',')'));

  proc sql feedback;
	create table __temp as
	select &selectvars
	from portalw.dmglinks_accesses
	where compress(upcase(sid)) in ("%upcase(&_metauser)");
	quit;

	%if %records_in_dataset(__temp) gt 0 %then
	%do;
		%convert_allvars_macrovars(__temp);
		/* %put _user_ ; */
  %end;
  
%put End macro check_dmglink_access;    
%mend check_dmglink_access;