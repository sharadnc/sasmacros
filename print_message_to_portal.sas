/**************************************************************************************************************                                                               
* Macro_Name:   print_message_to_portal                                                                                                                                          
*                                                                                                                                                                             
* Purpose: This macro is used to Print a Message to the Portal.                                                                                                              
*                                                                                                                                                                             
* Usage: %print_message_to_portal(msg);                                                                                                                                          
*                                                                                                                                                                             
* Input_parameters: msg                                                                                                                                                       
*                    Display Message to the Portal
*                                                                                                                                                                             
* Outputs:  None                                                                                                                                                     
*                                                                                                                                                                             
* Returns:  None                                                                                                                           
*                                                                                                                                                                             
* Example: %print_message_to_portal(msg)                                                                                                                                                                
*                                                                                                                                                                             
* Modules_called: None                                                                                                                                                        
*                                                                                                                                                                             
* Maintenance_History:                                                                                                                                                        
*-------------------------------------------------------------------------------------------------------------*                                                               
*  Date:      |   Who:        |  Description:                                                                 *                                                               
*-------------------------------------------------------------------------------------------------------------*                                                               
* 09/14/2012  | Sharad        | Initial creation.                                                             *                                                               
*-------------------------------------------------------------------------------------------------------------*                                                               
* HeaderEnd:                                                                                                  *                                                               
**************************************************************************************************************/                                                               
                                                                                                                                                                              
%macro print_message_to_portal(msg);                                                                                                                                             
%put Start macro print_message_to_portal;                                                                                                                                        

			data ___null;
				length x $500;
				%if %substr(%upcase(&msg),1,8) eq REDIRECT %then
				%do;
					 %if %upcase(&env) eq DEV or %upcase(&env) eq LABS or %upcase(&env) eq QA %then
					 %do;
					 		x="<img src='http://devportal.sharadnc.net/dmg/"||"&env."||"/portal/img/loadingIcon.gif'>";
					 %end;
					 %else %if %upcase(&env) eq UAT or %upcase(&env) eq PROD or %upcase(&env) eq IST %then
					 %do;
						x="<img src='http://dmgprodportal.sharadnc.net/nsm/dmg/"||"&env."||"/portal/img/loadingIcon.gif'>";
					 %end;
				%end;
				%else
				%do;
					x="Use Browser BACK button to go to PREVIOUS Page";
				%end;				
			run;
			
			ods html file=_webout style=meadow;
			title1 j=c c=red height=4 "***  &msg.  ****";			
			proc print data=___null noobs label; label x="09"x;run; 
                                                                                                                                                                              
%put End macro print_message_to_portal;                                                                                                                                          
%mend print_message_to_portal;
