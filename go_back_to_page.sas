/**************************************************************************************************************                                                                                                                                                 
* Macro_Name:   go_back_to_page                                                                                                                                                                                                                                   
*                                                                                                                                                                                                                                                               
* Purpose: This macro builds HTML statements to re-direct to a page on click
*                                                                                                                                                                                                                                                               
* Usage: %go_back_to_page(stploc);                                                                                                                                                                                                                           
*                                                                                                                                                                                                                                                               
* Input_parameters: stploc                                                                                                                                                                                                                                    
*                    URL location
*                                                                                                                                                                                                                                                               
* Outputs:  None.                                                                                                                                                                                                                                               
*                                                                                                                                                                                                                                                               
* Returns:  None
*                                                                                                                                                                                                                                                               
* Example: %go_back_to_page(URL);                                                                                                                                                                                                                            
*                                                                                                                                                                                                                                                               
* Modules_called: %None                                                                                                                                                                                                                                          
*                                                                                                                                                                                                                                                               
* Maintenance_History:                                                                                                                                                                                                                                          
*-------------------------------------------------------------------------------------------------------------*                                                                                                                                                 
*  Date:      |   Who:        |  Description:                                                                 *                                                                                                                                                 
*-------------------------------------------------------------------------------------------------------------*                                                                                                                                                 
* 12/14/2011  | Sharad           | Initial creation.                                                          *                                                                                                                                                 
* 12/14/2011  | Michael Gilman   | Initial creation.                                                          *                                                                                                                                                 
*-------------------------------------------------------------------------------------------------------------*                                                                                                                                                 
* HeaderEnd:                                                                                                  *                                                                                                                                                 
**************************************************************************************************************/                                                                                                                                                 

%macro go_back_to_page(stploc);
			data _null_ ;
        file _webout mod ;		
        put '<table  align="center"  name="tab2" class="sample">'; 		 
				put '   <tr>';
				put '   <td align="center">';        				
				put ' <input type="button" value="Go Back" class="button" onclick=location.href="http://sharadnc.net:9090/SASStoredProcess/do?_action=execute&_program='
			        '%2FShared+Data%2FDMG+-+' "&metadata_env" '%2FStored+Processes%2FDMG+Administration%2F' "&stploc" '"></td>';
				put '   </tr>		 	 ';
			
				put ' </table>';
				put '</form>' ;
				put '<div style="clear:both;"></div>                                                                                 ';
				put '</body>                                                                                                         ';
				put '</html>                                                                                                         ';			
			run;						
%mend go_back_to_page;