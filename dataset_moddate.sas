/**************************************************************************************************************
* Macro_Name:   dataset_moddate                                                                        
* 
* Purpose: This macro retrieves the modification date of a dataset.
*          
* Usage: %dataset_moddate(dataset);                                                                                 
*
* Input_parameters: dataset - name of your dataset
*                                                                                                              
* Outputs:  Macro value.                                                                                              
*                                                                                                              
* Returns:  datetime23. formatted moddate.  
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



%macro dataset_moddate(dataset);
 %local modate dsid;

 %let dsid=%sysfunc(open(&dataset));

 %if &dsid ne 0 %then
 %do;
	 %let modate=%sysfunc(attrn(&dsid,MODTE),datetime23.);
	 %let dsid=%sysfunc(close(&dsid));
	 %let dfmt=%substr(&modate,1,2)-%substr(&modate,3,3)-%substr(&modate,6,4) - %substr(&modate,11);
 %end;

&dfmt

%mend dataset_moddate;