/**************************************************************************************************************
* Macro_Name:   dataset_createdate                                                                        
* 
* Purpose: This macro retrieves the Creation date of a dataset.
*          
* Usage: %dataset_createdate(dataset);                                                                                 
*
* Input_parameters: dataset - name of your dataset
*                                                                                                              
* Outputs:  Macro value.                                                                                              
*                                                                                                              
* Returns:  creation date.  
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

%macro dataset_createdate(dataset);
 %local crdate dsid;


 %let dsid=%sysfunc(open(&dataset));

 %if &dsid ne 0 %then
 %do;
	 %let crdate=%sysfunc(attrn(&dsid,CRDTE),datetime23.);
	 %let dsid=%sysfunc(close(&dsid));
	 %let dfmt=%substr(&crdate,1,2)-%substr(&crdate,3,3)-%substr(&crdate,6,4) - %substr(&crdate,11);
 %end;

&dfmt

%mend dataset_createdate;