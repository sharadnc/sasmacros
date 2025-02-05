/**************************************************************************************************************
* Macro_Name:  center_text_in_line
*
* Purpose: Create a text line that has text centered on a line of characters, usually asterisks.
*
* Usage: %center_text_in_line(text=test,linechar=*,lineLength=80);
*
* Input_parameters: text
*                    text to display centered on a line
*                   linechar
*                    The character to repeat on the line
*                    Default: *
*                   lineLength
*                    The total length of the line
*                    Default: 80
*
* Outputs:  None.
*
* Returns:  If error, jumptoexit=1;
*
* Example:
*
* Modules_called: None
*
* Maintenance_History:
*-------------------------------------------------------------------------------------------------------------*
*  Date:      |   Who:           |  Description:                                                              *
*-------------------------------------------------------------------------------------------------------------*
* 07/22/2012  | Michael Gilman   | Initial creation.                                                          *
*-------------------------------------------------------------------------------------------------------------*
* HeaderEnd:                                                                                                  *
**************************************************************************************************************/

%macro center_text_in_line(text=,linechar=*,lineLength=80);

 %local lenText lenAvail lenAvail2 c line;

 %let line=;

 %let lenText=%length(&text);

 %if &lenText>=&lineLength %then
 %do;

    %let errormsg1=Text cannot be longer than &lineLength;

    %let jumptoexit=1;

    %goto EXIT;

 %end;

 %if %length(&linechar)>1 %then
 %do;

    %let errormsg1=Line character must be only 1 character;

    %let jumptoexit=1;

    %goto EXIT;

 %end;

 %if &text ne %str() %then
 %do;

  %let lenText=%eval(&lenText+2);

  %let lenAvail=%eval(&lineLength-&lenText);

  %let lenAvail2=%sysevalf(&lenAvail/2-1);

  %let c=%sysfunc(repeat(&linechar,&lenAvail2));

  %let line=&c &text &c;

  %if %sysevalf(%length(&line)<&lineLength) %then %let line=&line&linechar;

 %end;
 %else %let line=%sysfunc(repeat(&linechar,%eval(&lineLength-1)));

%EXIT:

 &line

%mend center_text_in_line;
