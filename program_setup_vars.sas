/**************************************************************************************************************
* Macro_Name:   program_setup_vars
* 
* Purpose: these set of macro is used to centralize all Programsetup vars
*                                                                                                              
* Usage: %program_setup_vars
*
* Input_parameters: None
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
* 01/10/2013  | Sharad           | Initial creation.                                                          *
*-------------------------------------------------------------------------------------------------------------*
* HeaderEnd:                                                                                                  *
**************************************************************************************************************/


%MACRO ProgramSetupVars;
	PGMNAME $ 200 RECORDACTIVE $ 1 EMAILTURNON $ 1 SECURITY_LEVEL $ 2 PGMID $ 6 
	PROCESS_DATE_LAG $ 2 SENDZIP $ 1 PGMFREQ $ 20 SUBJECTAREA $ 100 LOB $ 50 DELIVERYMETHOD $ 100 
	ZIP_EXTENSION $ 10 ENCR_PWD $ 50 NOTES $1000 BUSINESSANALYST1 $ 100 SCRIPT_REPORT_NAME $100
	DEVELOPER1 $ 100 DEVELOPER2 $ 100 BUSINESSCONTACT1 BUSINESSCONTACT2 $400 LASTUPDATEDTIME $ 100 LASTUPDATEDBY $ 10 NOTIFY_EMAIL $1000
	RETENTION_INSTANCES_FNL RETENTION_INSTANCES_INTERMED $5
	USE_VAR_LABELS_FOR_EXPORT $ 1 COLUMN_HEADERS_IN_EXPORT $1
%mend ProgramSetupVars;

%MACRO ProgramSetupKeepVars;
	PGMID PGMNAME PGMFREQ PROCESS_DATE_LAG SCRIPT_REPORT_NAME
    SUBJECTAREA	LOB	SECURITY_LEVEL	RECORDACTIVE 
    DELIVERYMETHOD	EMAILTURNON	SENDZIP	USE_VAR_LABELS_FOR_EXPORT 
    COLUMN_HEADERS_IN_EXPORT	NOTIFY_EMAIL	ZIP_EXTENSION ENCR_PWD	BUSINESSANALYST1	
    DEVELOPER1	DEVELOPER2	BUSINESSCONTACT1 BUSINESSCONTACT2 RETENTION_INSTANCES_FNL	RETENTION_INSTANCES_INTERMED	
    NOTES LASTUPDATEDTIME LASTUPDATEDBY
%mend ProgramSetupKeepVars;

%MACRO Select_Vars;
	PGMNAME, RECORDACTIVE, EMAILTURNON, SECURITY_LEVEL, PGMID, PROCESS_DATE_LAG, SENDZIP, PGMFREQ, SCRIPT_REPORT_NAME,
	USE_VAR_LABELS_FOR_EXPORT,COLUMN_HEADERS_IN_EXPORT,
	SUBJECTAREA, LOB, DELIVERYMETHOD, ZIP_EXTENSION, ENCR_PWD, NOTES,NOTIFY_EMAIL, BUSINESSANALYST1, DEVELOPER1, DEVELOPER2, 
	BUSINESSCONTACT1,BUSINESSCONTACT2, RETENTION_INSTANCES_FNL,RETENTION_INSTANCES_INTERMED,LASTUPDATEDTIME, LASTUPDATEDBY 
%mend Select_Vars;