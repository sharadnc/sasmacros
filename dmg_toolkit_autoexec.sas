/**************************************************************************************************************
* Macro_Name:   dmg_toolkit_autoexec
*
* Purpose: This program is used as the autoexec for all programs that use the toolkit in batch mode using the 
*          call_sasscript.ksh Shell script
*
* Usage: see /u04/data/cig_ebi/dmg/&env/shl/call_sasscript.ksh
*
* Input_parameters: Various shell variables set in the shell script
*
* Outputs:  None.
*
* Returns: Several global macro variables. 
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


 %let useEG=0;
 %let env=%sysget(env);                                                                                                                                                                  
 %let rootloc=%sysget(rootloc);                                                                                                                                                          
 %let PgmName=%sysget(pgm);                                                                                                                                                              
 %let dt_prcs=%sysget(dt_prcs);                                                                                                                                                          
 %let logfile=%sysget(logfile); 
 %let userid=&sysuserid;
 %let debug=%sysget(debug); 
 %let exec_user=%lowcase(%sysget(exec_user));

 filename sasmacr "&rootloc/macros";
 options mautosource mrecall sasautos=(sasmacr sasautos); 