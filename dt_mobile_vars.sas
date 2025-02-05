/**************************************************************************************************************
* Macro_Name:  dt_mobile_vars
*
* Purpose: This macro creates date variables needed for the mobile programs.
*
* Usage: dt_mobile_vars
*
* Input_parameters: dt_sas (global)
*
* Outputs:  Several global macro date variables.
*
* Returns:  None
*
* Example:
*
* Modules_called: %dt_date
*
* Maintenance_History:
*-------------------------------------------------------------------------------------------------------------*
*  Date:      |   Who:        |  Description:                                                                 *
*-------------------------------------------------------------------------------------------------------------*
* 05/02/2012  | Michael Gilman| Initial creation.                                                             *
*-------------------------------------------------------------------------------------------------------------*
* HeaderEnd:                                                                                                  *
**************************************************************************************************************/

%macro dt_mobile_vars;
%put Start macro dt_mobile_vars;

 %global dt_curr_mo_beg_sas
         dt_curr_mo_end_sas
         dt_curr_mo_beg_db2
         dt_curr_mo_end_db2

         dt_1mo_bk_beg_sas
         dt_1mo_bk_end_sas
         dt_1mo_bk_beg_db2
         dt_1mo_bk_end_db2

         dt_2mo_bk_beg_sas
         dt_2mo_bk_end_sas
         dt_2mo_bk_beg_db2
         dt_2mo_bk_end_db2

         dt_curr_yr_beg_sas
         dt_curr_yr_end_sas

         dt_1yr_bk_beg_sas
         dt_1yr_bk_end_sas
 ;

 %let dt_curr_mo_beg_sas=%dt_date(interval=month,offset=0,format=best,alignment=B,quote=N);

 %let dt_curr_mo_end_sas=%dt_date(interval=month,offset=0,format=best,alignment=E,quote=N);

 %let dt_curr_mo_beg_db2=%dt_date(interval=month,offset=0,format=mmddyys10,alignment=B,quote=Y);

 %let dt_curr_mo_end_db2=%dt_date(interval=month,offset=0,format=mmddyys10,alignment=E,quote=Y);


 %let dt_1mo_bk_beg_sas=%dt_date(interval=month,offset=-1,format=best,alignment=B,quote=N);

 %let dt_1mo_bk_end_sas=%dt_date(interval=month,offset=-1,format=best,alignment=E,quote=N);

 %let dt_1mo_bk_beg_db2=%dt_date(interval=month,offset=-1,format=mmddyys10,alignment=B,quote=Y);

 %let dt_1mo_bk_end_db2=%dt_date(interval=month,offset=-1,format=mmddyys10,alignment=E,quote=Y);


 %let dt_2mo_bk_beg_sas=%dt_date(interval=month,offset=-2,format=best,alignment=B,quote=N);

 %let dt_2mo_bk_end_sas=%dt_date(interval=month,offset=-2,format=best,alignment=E,quote=N);

 %let dt_2mo_bk_beg_db2=%dt_date(interval=month,offset=-2,format=mmddyys10,alignment=B,quote=Y);

 %let dt_2mo_bk_end_db2=%dt_date(interval=month,offset=-2,format=mmddyys10,alignment=E,quote=Y);


 %let dt_curr_yr_beg_sas=%dt_date(interval=year,offset=0,format=best,alignment=B,quote=N);

 %let dt_curr_yr_end_sas=%dt_date(interval=year,offset=0,format=best,alignment=E,quote=N);


 %let dt_1yr_bk_beg_sas=%dt_date(interval=year,offset=-1,format=best,alignment=B,quote=N);

 %let dt_1yr_bk_end_sas=%dt_date(interval=year,offset=-1,format=best,alignment=E,quote=N);

%put End macro dt_mobile_vars;
%mend dt_mobile_vars;
