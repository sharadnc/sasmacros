/**************************************************************************************************************
* Macro_Name:   stp_not_authorized
*
* Purpose: Display an Message No Authorization to this Stored Process.
*
* Usage: %stp_not_authorized(STPACCESS);
*
* Input_parameters: reason
*
* Outputs:  None.
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

%macro stp_not_authorized(reason);
%put Start macro stp_not_authorized;

		data _null_;
			file _webout;
			length hyperlink Reason $ 1000;
			%if %upcase(&reason) eq STPACCESS %then
			%do;
				Reason="<b>You do NOT have proper authorization to view this Resource</b><br><br>";						
			%end;	               
			%else %if %upcase(&reason) eq METADATA %then
			%do;
				Reason="<b>Metadata for the Report is not Available</b><br><br>";						
			%end;  
			
			
			putlog hyperlink=;
			put '<html><head>';
			put '</head><body><center><br>';		
			put Reason;		
			put "<u><b>Please contact Digital Analytics and Business Insights Group<br></b></u><br>Please send an email to";
			put "<a href='mailto:dabi.production.support@sharadnc.net'>dabi.production.support@sharadnc.net</a> for any questions</center>";
			
			put '</body></html>';		
	run;			
		
%put End macro stp_not_authorized;
%mend stp_not_authorized;