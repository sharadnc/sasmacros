/**************************************************************************************************************
* Macro_Name:   split_macrovalue                                                                        
* 
* Purpose: this macro is used to split a macro and return series of macro variables
*          
*                                                                                                              
* Usage: %split_macrovalue(macvar,prefix,splitcnt,dlm=' ');
*
* Input_parameters: macvar - input macro var
*                   prefix - prefix of the macro vars to be created in sequence order...
*                   splitcnt - name of the macro vars to store the length of the macro variable
*                   dlm=' ' - delimiter in the string (default is blank i.e. ' ')
*                                                                                                              
* Outputs:  None.                                                                                              
*                                                                                                              
* Returns:  None   
*
* Example: 
*									%let str1=he she me to 3 "some";
*									%SplitMacroValue(str1,pre,strcnt,dlm=' ');
*									
*									%put pre1=&pre1 pre2=&pre2 pre3=&pre3 pre4=&pre4 pre5=&pre5 pre6=&pre6 ;
*									%put strcnt=&strcnt;
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



%macro split_macrovalue(macvar,prefix,splitcnt,dlm=' ');

 %global &splitcnt; /*create the global variable for storing the splitcount*/ 
 %let num=1; /*initialize a counter variable*/   

 %global &prefix&num; /*create the global variable for storing the first split*/ 
 %let &prefix&num=%scan(&&macvar,&num,&dlm); /*Scan the first value*/ 
 
 options mprint mprintnest mlogic mlogicnest;

	%if %index(&&macvar,&dlm) gt 0 %then
	%do;
	 %do %while(%length(&&&prefix&num) gt 0);
  	  %let &splitcnt=&num; /*Store the split count to the macro variable reqd*/  	    
	    %let num=%eval(&num + 1);/*increment the counter*/         
	    %global &prefix&num; /*create the global variable*/ 
	    %let &prefix&num=%scan(&&macvar,&num,&dlm); /*scan the next value*/ 
	    %put &prefix&num=&&&prefix&num;
	  %end;
	%end;
	%else
	%do;	
		  %let &splitcnt=&num; /*Store the split count to the macro variable reqd*/  
	%end;	  

  /* Remove the comment's to check the values */
     %put &splitcnt=&&&splitcnt;
      %do i=1 %to %eval(&&&splitcnt + 0); 
     %put &&prefix&&&splitcnt = &&prefix&&&splitcnt;
    %end;   

%mend split_macrovalue; 
