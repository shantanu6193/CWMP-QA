/***********************************************************************************************************************************
* Class Name   : HMA_Service
* Description  : This class for HMA Service to get pre application details
* Author       : Pankaj
* Created On   : 06/23/2020
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Pankaj              06/23/2020       Initial Implementation
**************************************************************************************************************************************/

public without sharing class HMA_Service {
    
    /***********************************************
    * Method Name : getPreAppRecordDetails
    * Author : Pankaj
    * Inputs : String recordId
    * Description: This method return Pre_Application__c record
    *********************************************/
    @AuraEnabled
    public static  Pre_Application__c getPreAppRecordDetails(String recordId){
        Pre_Application__c record = [SELECT Activity_Location_Latitude__c,
                                    Activity_Location_Longitude__c,
                                    Current_Stage__c,
                                    Mitigation_Dependent_On__c,
                                    Activity_in_Mitigation_Plan__c,
                                    Activity_Location__Latitude__s,
                                    Activity_Location__Longitude__s,
                                    Activity_TitleName__c,
                                    Applicant_Match__c,
                                    Applicant_Name_Entity__c,
                                    Applicant_Type__c,
                                    Application_Type__c,
                                    Brief_Summary__c,
                                    City__c,
                                    County__c,
                                    CreatedById,
                                    CreatedDate,
                                    Describe_the_problem_to_be_mitigated__c,
                                    Describe_the_scope_of_work__c,
                                    Design_documents_for_this_project__c,
                                    Disaster__c,
                                    DUNS__c,
                                    EIN_For_Private_Non_Profits__c,
                                    Federal_entity_have_funding_authority__c,
                                    Federal_Request_Share__c,
                                    FIPS__c,
                                    First_Name_of_Person_Completing_NOI__c,
                                    Funding_Opportunity__c,
                                    Hazard__c,
                                    Id,
                                    If_yes_identify_the_program__c,
                                    If_yes_planning_studies__c,
                                    If_yes_project_location__c,
                                    If_yes_proposed_project__c,
                                    Independent_mitigation_activity__c,
                                    IsDeleted,
                                    LastModifiedById,
                                    LastModifiedDate,
                                    Last_Name_of_Person_Completing_NOI__c,
                                    LHMP_Approval_Date__c,
                                    LHMP_Development_Status__c,
                                    Name,
                                    OwnerId,
                                    Percentage_complete_are_the_designs__c,
                                    Physical_project_work_already_started__c,
                                    Planning_studies_or_feasibility_reports__c,
                                    Program__c,
                                    Project_Duration_in_Months__c,
                                    Project_location_have_the_hazard__c,
                                    Project_Number__c,
                                    Project_related_to_asset__c,
                                    Project_Type__c,
                                    Proposed_project_area_documented__c,
                                    Protection_for_that_asset__c,
                                    RecordTypeId,
                                    RecordType.Name,
                                    Region__c,
                                    Source_of_applicant_match__c,
                                    State__c,
                                    Status_Reason__c,
                                    Status__c,
                                    Street_Address__c,
                                    Subapplicant_for_infrastructure__c,
                                    Subapplication_for_project_submitted__c,
                                    SystemModstamp,
                                    Total_Activity_Cost__c,
                                    Work_started_completed_in_detail__c,
                                    Zip_Code__c,
                                    Program__r.Id,
                                    Program__r.Name,
                                    Percentage_of_Applicant_Match__c,
                                    Percentage_of_Federal_Request_Share__c,
                                    Does_your_entity_have_an_active_LHMP__c,
                                    Entity_Responsible_For_Operation__c,
                                    Future_Hazard_Event_Trigger__c,
                                    Implementation_Plan_For_Mitigation__c,
                                    Protection_From_Future_Natural_Hazards__c,
                                    What_is_the_mitigation_action__c,
                                    Subapplicant_a_small_community__c,
                                    Project_in_conformance_with_latest_codes__c,
                                    Explain_why_project_not_in_conformance__c,
                                    Project_in_a_Special_Flood_Hazard_Area__c,
                                    National_Flood_Insurance_Program_NFIP__c,
                                    Structures_included_in_subapplication__c,
                                    Project_mitigate_Severe_Repetitive_Loss__c,
                                    Project_located_in_NFIP__c,
                                    Is_this_project_phased__c,
                                    Is_Project_Site_Identified__c,
                                    Percentage_Level_Of_Design__c,

                                    (Select Id,
                                        Name,
                                        Contact__r.Id,
                                        Contact__r.Title,
                                        Contact__r.FirstName,
                                        Contact__r.LastName,
                                        Contact__r.AccountId,
                                        Contact__r.Account.Name,
                                        Contact__r.Account.Entity_Id__c,
                                        Contact__r.Email,
                                        Contact__r.MobilePhone,
                                        Contact__r.Phone,
                                        Role__c,
                                        Type__c from Contact_Roles__r
                                    )
                                    FROM Pre_Application__c where Id =: recordId];
        return record;
    }
}