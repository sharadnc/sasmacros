/**************************************************************************************************************
* Macro_Name:   lock_off_member
*
* Purpose: This macro releases the lock on a data set
*
* Usage: %lock_off_member(dsn);
*
* Input_parameters: dsn
*                    Name of the data set on which to release the lock.
*
* Outputs:  None.
*
* Returns:  None
*
* Example: l%ock_off_member(dsn);
*
* Modules_called: None
*
* Maintenance_History:
*-------------------------------------------------------------------------------------------------------------*
*  Date:      |   Who:           |  Description:                                                              *
*-------------------------------------------------------------------------------------------------------------*
* 12/14/2011  | Sharad           | Initial creation.                                                          *
*-------------------------------------------------------------------------------------------------------------*
* HeaderEnd:                                                                                                  *
**************************************************************************************************************/

%macro lock_off_member(dsn);
 lock &dsn. list;
 lock &dsn. clear;
 lock &dsn. list;
%mend lock_off_member;

