/**************************************************************************************************************                         
* Macro_Name: dt_monname3                                                                                                               
*                                                                                                                                       
* Purpose: Returns the 3 character quoted name of the month (e.g. 'Jan')                                                                
*          By default, the macro uses the process date as the base date for                                                             
*          the date calculation.                                                                                                        
*                                                                                                                                       
* Usage: %dt_monname3(interval,offset,date=)                                                                                                                   
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
* Returns:  3 character quoted name of the month (e.g. 'Jan')                                                                           
*                                                                                                                                       
* Example:  %dt_monname3(month,-1);                                                                                                                            
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
                                                                                                                                        
%macro dt_monname3(interval,offset,date=);                                                                                              
                                                                                                                                        
 %if %superq(date)=%str() %then %let date=&dt_sas;                                                                                      
                                                                                                                                        
 %let d=%dt_date(date=&date,interval=&interval,format=monname3.,offset=&offset,quote=Y);                                                
                                                                                                                                        
 %unquote(&d)                                                                                                                           
                                                                                                                                        
%mend dt_monname3;
