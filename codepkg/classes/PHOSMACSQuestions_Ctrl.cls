/***********************************************************************************************************************************
* Class Name   : PHOSMACSQuestions_Ctrl
* Description  : This class MACS Questions on Order
* Author       : Shivraj
* Created On   : 01/07/2021
* Modification Log:
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Shivraj             01/07/2021      Initial Implementation
**************************************************************************************************************************************/
public without sharing class PHOSMACSQuestions_Ctrl {
    /***********************************************
    * Method Name : submitRequest
    * Author : Shivraj
    * Inputs : String recordData, String recordId
    * Description: This method updates orders fields with values and creates entries in Resource_Request_Question_Answer__c object
    *********************************************/
    @AuraEnabled
    public static void submitRequest(String recordData, String recordId) {
        Order__c order = (Order__c) JSON.deserialize(recordData, Order__c.class);
        order.Id = recordId;
        TriggerHelper.skipTrigger = true;
        update order;
        PHOS_Order_EditCtrl.createQuestionsAndAnswers(order);
    }
    /***********************************************
    * Method Name : getRecordData
    * Author : Shivraj
    * Inputs : Order recordId
    * Description: This method returns record details of Order
    *********************************************/
    @AuraEnabled
    public static Order__c getRecordData(String recordId) {
        return [SELECT Id, What_is_the_county_s_7_day_case_rate__c,
                    ICU_beds_available_in_the_County__c,
                    What_is_the_county_s_population_density__c,
                    Population_65_years_old_in_county__c,
                    Is_the_facility_a_specialty_center__c,
                    Personnel__c,
                    Is_this_a_Medical_Staffing_Request__c,
                    Is_this_for_a_GACH__c,
                    Bed_to_staff_ratio_bed_staff__c,
                    How_many_total_staff_are_you_requesting__c,
                    Allows_additional_ICU_or_M_S_T_beds__c,
                    Does_site_need_personnel_to_keep_ICU__c,
                    Total_ICU_beds_occupied__c,
                    Have_you_attempted_to_transfer_patients__c,
                    Have_you_cancelled_all_surgeries__c,
                    Average_time_of_T_to_T_for_ESI_Cat_3__c,
                    Do_you_have_an_active_staffing_waiver__c,
                    Would_you_be_able_to_accept_transfers__c,
                    Type_of_Personnel__c,
                    Total_Vaccinator_Staff_needed__c,
                    Specific_Vaccinator_Licenses_req_d__c,
                    Total_Logistics_Staff_needed__c,
                    Logistics_staff_tasks__c,
                    Total_Admin_Data_Staff_needed__c,
                    Admin_Data_Staff_Assignments__c,
                    Total_Security_Staff_needed__c,
                    Specific_language_preferred__c,
                    Language_specified__c,
                    First_date_of_Event__c,
                    Date_Time_staff_are_needed__c,
                    Address_for_staff__c,
                    Schedule_for_staff__c,
                    Vaccination_site_type__c,
                    Other_Vaccination_Site__c,
                    How_many_clients_expected__c,
                    Is_allocation_amount_sufficient__c,
                    What_is_closest_phase_tier__c,
                    Communication_with_Locals__c,
                    Any_unmet_communication_needs__c,
                    X2nd_Dose_plan_in_place__c,
                    X2nd_Dose_plan_detail__c,
                    Has_state_previously_helped__c,
                    How_many_clients_previously_helped__c,
                    What_is_the_site_name__c,
                    Clients_Anticipated_at_Site__c,
                    Doses_Anticipated_per_Day__c,
                    Doses_per_Day_Previous_Events__c,
                    What_status_is_the_event_currently_in__c,
                    Confirm_Compliance_Checkboxes__c,
                    Compliance_Narrative__c,
                    We_provide_staff_for_vaccination_events__c,
                    School_Requirements_Confirmation__c,
                    Logistics_Task_Assignments__c,
                    Hospital_Burden_Score__c,
                    What_of_County_population_vaccinated__c,Using_team_nursing_and_out_of_ratio__c,
                    What_is_current_total_patient_census__c,What_is_current_census_of_COVID_patients__c,
                    Total_patient_divide_COVID_patient_censu__c
        FROM Order__c WHERE Id=: recordId];
    }
}