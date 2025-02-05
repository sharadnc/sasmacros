/**************************************************************************************************************                         
* Macro_Name: dt_dash4                                                                                                                  
*                                                                                                                                       
* Purpose: Returns a quoted date in the form dd-monname-yyyy (e.g. '01-DEC-2011')                                                         
*          By default, the macro uses the process date as the base date for                                                             
*          the date calculation.                                                                                                        
*                                                                                                                                       
* Usage: %dt_dash4(interval,offset,date=)
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
* Returns:  Quoted date in the form dd-monname-yyyy (e.g. '01-DEC-2011')                                                                  
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
                                                                                                                                        
%macro dt_dash4(interval,offset,date=); 
%put Start macro dt_dash4;                                                                                                  
                                                                                                                                        
 %if %superq(date)=%str() %then %let date=&dt_sas;                                                                                      
                                                                                                                                        
 %let d=%dt_date(date=&date,interval=&interval,format=date11.,offset=&offset,quote=Y);                                                  
                                                                                                                                        
 %unquote(&d)                                                                                                                           
                                                                                                                                        
%put End macro dt_dash4;  
%mend dt_dash4;
