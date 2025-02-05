/**************************************************************************************************************
* Macro_Name:   random_number_generate
*
* Purpose: This macro is used to generate a random number between a minimum and maximum value with
*          a specified interval.
*
* Usage: %random_number_generate(min=,max=,interval=);
*
* Input_parameters: None.
*
* Outputs:  None.
*
* Returns:  A random number
*
* Example:
*          %let random_number=%random_number_generate(min=1,max=10,interval=1)
*            Generates an integer between 1 and 10.
*
*          %let random_number=%random_number_generate(min=.1,max=.5,interval=.1)
*            Generates a real number between .1 and .5 (e.g.: .3)
*
* Modules_called: None
*
* Maintenance_History:
*-------------------------------------------------------------------------------------------------------------*
*  Date:      |   Who:        |  Description:                                                                 *
*-------------------------------------------------------------------------------------------------------------*
* 12/14/2011  | Michael Gilman   | Initial creation.                                                          *
*-------------------------------------------------------------------------------------------------------------*
* HeaderEnd:                                                                                                  *
**************************************************************************************************************/

%macro random_number_generate(min=,      /* Minimum value */
                              max=,      /* Maximum value */
                              interval=1 /* Interval      */
                             );

 %local count;

 %let count=0;

 %let min=%sysevalf(&min*&interval/&interval);

 %let max=%sysevalf(&max*&interval/&interval);

%AGAIN:

 %let count=%eval(&count+1);

 %let random_number=%sysfunc(ranuni(0));

 %let random_number=%sysevalf(&random_number*%sysevalf(&max-&min)+%sysevalf(&min));

 %let random_number=%sysfunc(round(&random_number,&interval));

 %if &count>100 %then
 %do;

    %let random_number=&max;

    %goto EXIT;

 %end;

 %if %sysevalf(&random_number<&min) %then %goto AGAIN;

 %if %sysevalf(&random_number>&max) %then %goto AGAIN;

%EXIT:

 &random_number

%mend random_number_generate;

