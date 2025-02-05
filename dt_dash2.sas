/**************************************************************************************************************                                                             
* Macro_Name: dt_dash2                                                                                                                                                      
*                                                                                                                                                                           
* Purpose: Returns a quoted date in the form dd-monname-yy (e.g. '01-DEC-11')                                                                                               
*          By default, the macro uses the process date as the base date for                                                                                                 
*          the date calculation.                                                                                                                                            
*                                                                                                                                                                           
* Usage: dt_dash2(interval,offset,date=)
*                                                                                                                                                                           
* Input_parameters: Interval                                                                                                                                                
*                    DAY, MONTH, WEEK, QTR, YEAR                                                                                                                            
*                    Offset:                                                                                                                                                
*                     Integer representing the number of intervals to offset.                                                                                               
*                    Date: 
*                     Optional. By default uses the process date as the base date.                                                                                     
*                                                                                                                                                                           
* Outputs:  None.                                                                                                                                                           
*                                                                                                                                                                           
* Returns:  Quoted date in the form dd-monname-yy (e.g. '01-DEC-11')                                                                                                        
*                                                                                                                                                                           
* Example:                                                                                                                                                                  
*                                                                                                                                                                           
* Modules_called: None                                                                                                                                                      
*                                                                                                                                                                           
* Maintenance_History:                                                                                                                                                      
*-------------------------------------------------------------------------------------------------------------*                                                             
*  Date:      |   Who:        |  Description:                                                                 *                                                             
*-------------------------------------------------------------------------------------------------------------*                                                             
* 01/30/2012  | Michael Gilman| Initial creation.                                                             *                                                             
*-------------------------------------------------------------------------------------------------------------*                                                             
* HeaderEnd:                                                                                                  *                                                             
**************************************************************************************************************/                                                             
                                                                                                                                                                            
%macro dt_dash2(interval,offset,date=); 
%put Start macro dt_dash2;                                                                                                                                    
                                                                                                                                                                            
 %if %superq(date)=%str() %then %let date=&dt_sas;                                                                                                                          
                                                                                                                                                                            
 %let d=%dt_date(date=&date,interval=&interval,format=date7,offset=&offset,quote=Y);                                                                                        
                                                                                                                                                                            
 %let d=%bquote(%substr(%superq(d),1,3)-%substr(%superq(d),4,3)-%substr(%superq(d),7));                                                                                     
                                                                                                                                                                            
 %unquote(&d)                                                                                                                                                               
                                                                                                                                                                            
%put End macro dt_dash2;  
%mend dt_dash2;
