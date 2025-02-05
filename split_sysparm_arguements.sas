/**************************************************************************************************************
* Macro_Name:   split_sysparm_arguements                                                                        
* 
* Purpose: this macro is used to split sysparm parameters
*          
*                                                                                                              
* Usage: %split_sysparm_arguements;
*
* Input_parameters: None.
*                                                                                                              
* Outputs:  None.                                                                                              
*                                                                                                              
* Returns:  None   
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

/*************************************************************/
/* To use this example, invoke a SAS session like this:      */
/*                                                           */  
/*  sas -sysparm "env=dev^lob=cc^PgmFreq=dly"                   */
/*                                                           */
/*************************************************************/

/* Create a macro to parse the value passed to SYSPARM at    */
/* invocation into three separate date values for use in the */
/* following DATA step.                                      */                                                                                           
                                                                                                                                        
%macro split_sysparm_arguements;

data   _null_;
length temp varname varval $200;
if "&sysparm." ne "" then
do;
   putlog "sysparm: &sysparm.";
   do i = 1 to length(compress("&sysparm",'=','k'));
      temp=scan("&sysparm",i,'^','m');
	  varname=scan(temp,1,'=','m');
	  varval= scan(temp,2,'=','m');
	  call symputx(varname,varval);
   end;
end;
run; 
/*%put _user_;*/

%mend split_sysparm_arguements;
