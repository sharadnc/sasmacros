/**************************************************************************************************************
* Macro_Name:   squote
*
* Purpose: This macro returns a single quoted macro value.
*
* Usage: %squote(val);
*
* Input_parameters: Macro value to single quote.
*
* Outputs:  None.
*
* Returns:  Single quoted macro value
*
* Example:
*
* Modules_called: None
*
* Maintenance_History:
*--------------------------------------------------------------------------------------------------------------*
*  Date:      |   Who:         |  Description:                                                                 *
*--------------------------------------------------------------------------------------------------------------*
* 07/07/2012  | Michael Gilman | Initial creation.                                                             *
*--------------------------------------------------------------------------------------------------------------*
* HeaderEnd:                                                                                                   *
****************************************************************************************************************/

%macro squote(val);
%put Start macro squote;

 %unquote(%str(%')%superq(val)%str(%'))

%put End macro squote;
%mend squote;
