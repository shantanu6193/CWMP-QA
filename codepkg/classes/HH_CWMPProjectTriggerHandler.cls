/***********************************************************************************************************************************
* Class Name   : HH_CWMPProjectTriggerHandler
* Description  : Handle object trigger operations
* Author       : Ricky
* Created On   : 01/03/2022
* Modification Log:
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Ricky              01/03/2022       Initial Implementation
**************************************************************************************************************************************/
public without sharing class HH_CWMPProjectTriggerHandler extends TriggerHandler implements TriggerInterface {

    public override void beforeInsert() {
        /** This method is used to update the default Stage and Status of the Project records while inserting/updating if it is empty. */
        updateDefaultStageAndStatus();
    }

    public override void beforeUpdate() {
        /** This method is used to update the default Stage and Status of the Project records while inserting/updating if it is empty. */
        updateDefaultStageAndStatus();
    }

    public override void afterInsert() {
        /**  This method is used to share the Project record with its related Community County User group, 
         * based on the County of related CWMP Application. */
        shareProjectRecordWithCommunityAndCalOesUser();

        updateProjectFieldOnApplication();
    }

    /***********************************************
    * Method Name : updateDefaultStageAndStatus
    * Author : Ricky
    * Description: This method is used to update the default Stage and Status of the Project records while inserting/updating if it is empty.
    *********************************************/
    private void updateDefaultStageAndStatus() {
        if(Trigger.isInsert) {
            for(CWMP_Project__c projectToProcess : (List<CWMP_Project__c>) Trigger.new) {
                if(projectToProcess.Project_Stage__c == null || projectToProcess.Project_Stage__c == '') {
                    projectToProcess.Project_Stage__c = HH_CONSTANTS.CWMPProject_Stage_NewProjectCreated;
                }
                if(projectToProcess.Project_Status__c == null || projectToProcess.Project_Status__c =='') {
                    projectToProcess.Project_Status__c = HH_CONSTANTS.CWMPProject_Status_NewProject;
                }
            }
        }
        if(Trigger.isUpdate) {
            for(CWMP_Project__c projectToProcess : (List<CWMP_Project__c>) Trigger.new) {
                /** Condition to check if the Stage of the Application is null, then to update the default Stage and Staus to the Project. */
                if(projectToProcess.Project_Stage__c == null 
                        || projectToProcess.Project_Stage__c == '') {
                    projectToProcess.Project_Stage__c = HH_CONSTANTS.CWMPProject_Stage_NewProjectCreated;
                    projectToProcess.Project_Status__c = HH_CONSTANTS.CWMPProject_Status_NewProject;
                }

                /** Condition to update the Status of the Project upkn Stage is changed ans Status is not the Dependent value of the Stage, 
                 * then updatnig the Default Staus Value for that particular selected Stage. */
                CWMP_Project__c oldRecord = (CWMP_Project__c) Trigger.oldMap.get(projectToProcess.Id);
                if(oldRecord.Project_Stage__c != projectToProcess.Project_Stage__c 
                        || oldRecord.Project_Status__c != projectToProcess.Project_Status__c) {
                    if(projectToProcess.Project_Stage__c == HH_CONSTANTS.CWMPProject_Stage_NewProjectCreated 
                            && projectToProcess.Project_Status__c != HH_CONSTANTS.CWMPProject_Status_NewProject) {
                        projectToProcess.Project_Status__c = HH_CONSTANTS.CWMPProject_Status_NewProject;
                    }
                    else if (projectToProcess.Project_Stage__c == HH_CONSTANTS.CWMPProject_Stage_SiteWork 
                            && projectToProcess.Project_Status__c != HH_CONSTANTS.CWMPProject_Status_SiteWorReady
                            && projectToProcess.Project_Status__c != HH_CONSTANTS.CWMPProject_Status_SiteWorkInProgress 
                            && projectToProcess.Project_Status__c != HH_CONSTANTS.CWMPProject_Status_SiteWorkComplete) {
                        projectToProcess.Project_Status__c = HH_CONSTANTS.CWMPProject_Status_SiteWorReady;
                    }
                    else if (projectToProcess.Project_Stage__c == HH_CONSTANTS.CWMPProject_Stage_PostAssessment 
                            && projectToProcess.Project_Status__c != HH_CONSTANTS.CWMPProject_Status_ReadyForPostAssessment
                            && projectToProcess.Project_Status__c != HH_CONSTANTS.CWMPProject_Status_PostAssessmentPending 
                            && projectToProcess.Project_Status__c != HH_CONSTANTS.CWMPProject_Status_PostAssessmentIsCompleted) {
                        projectToProcess.Project_Status__c = HH_CONSTANTS.CWMPProject_Status_ReadyForPostAssessment;
                    }
                    else if (projectToProcess.Project_Stage__c == HH_CONSTANTS.CWMPProject_Stage_ProjectComplete 
                            && projectToProcess.Project_Status__c != HH_CONSTANTS.CWMPProject_Status_ProjectReadyForCloseout
                            && projectToProcess.Project_Status__c != HH_CONSTANTS.CWMPProject_Status_ProjectCloseoutComplete) {
                        projectToProcess.Project_Status__c = HH_CONSTANTS.CWMPProject_Status_ProjectReadyForCloseout;
                    }
                }
            }
        }
    }

    /***********************************************
    * Method Name : shareProjectRecordWithCommunityAndCalOesUser
    * Author : Ricky
    * Description: This method is used to share the Project record with its related Community County User group, 
    *              based on the County of related CWMP Application.
    *********************************************/
    private void shareProjectRecordWithCommunityAndCalOesUser() {
        /** Map collection to collect the Project records which needs to be shared/processed. */
        Map<Id, CWMP_Project__c> projectIdToProjectMap = new Map<Id,CWMP_Project__c>();
        /** Set collection in order to collect the related CWMP Application Id of the Project,
         * In order to fetch the County of the Apllication. */
        Set<Id> cwmpApplicationIds = new Set<Id>();

        /** Iterating the Trigger.new collection in order to collect the Project to be shared and the related Application Ids. */
        for(CWMP_Project__c projectToProcess : (List<CWMP_Project__c>) Trigger.new) {
            if(projectToProcess.CWMP_Application__c != null) {
                cwmpApplicationIds.add(projectToProcess.CWMP_Application__c);
                projectIdToProjectMap.put(projectToProcess.Id, projectToProcess);
            }
        }

        if(cwmpApplicationIds?.size() > 0) {
            /** Set collection to collect the County name of the rleated Application in or der to query the County Config metadata record. */
            Set<String> countyNames = new Set<String>();
            /** Set collection to collect the API name of the Public group in order to query the grpup record to share the Project. */
            Set<String> groupAPINames = new Set<String>();
            /** Fetching the Application records in ord erto get the related County. */
            Map<Id, HH_Application__c> appIdToAppRecordMap = new Map<Id, HH_Application__c>([SELECT Id, Name, County__c 
                                                                FROM HH_Application__c WHERE Id IN : cwmpApplicationIds]);
            /** Itearting the CWMP Application record in order to get the County Names. */
            for(HH_Application__c appRecord : appIdToAppRecordMap.values()) {
                if(appRecord.County__c != null) {
                    countyNames.add(appRecord.County__c);
                }
            }
            /** Fetching the County Config Metadat records. */
            Map<Id, County_Config__mdt> countyConfigIdToRecordMap = new Map<Id, County_Config__mdt>([SELECT Id, Label, Public_Group_API_Name__c 
                                                                    FROM County_Config__mdt WHERE Label IN : countyNames 
                                                                    AND Application_Type__c =: HH_CONSTANTS.HH_Application_APIName_CountyConfig]);
            
            /** Map collection to collect the County Config records with the County as key. */
            Map<String, County_Config__mdt> countyNameToCountyConfigRecordMap = new Map<String, County_Config__mdt>();
            /** Itearting the County Config record in order to Map into thye above Map collection with County as Key.
             * Collecting the Group API names in order to Query the Public group records. */ 
            for(County_Config__mdt countyConfig : countyConfigIdToRecordMap.values()) {
                countyNameToCountyConfigRecordMap.put(countyConfig.Label, countyConfig);
                groupAPINames.add(countyConfig.Public_Group_API_Name__c);
            }

            /** Fetching the Group records and arranding it into the Map colelction with Developer name as Key. */
            Map<Id, Group> groupRecordMap = new  Map<Id, Group>();
            Map<String, Group> groupAPINAmeToGroupRecordMap = new  Map<String, Group>();
            if(groupAPINames?.size() > 0) {
                groupRecordMap = new  Map<Id, Group>([SELECT Id, Name, DeveloperName FROM Group WHERE Type = 'Regular' AND DeveloperName IN : groupAPINames]);
                for(Group groupRecord : groupRecordMap.values()) {
                    groupAPINAmeToGroupRecordMap.put(groupRecord.DeveloperName, groupRecord);
                }
            }

            /** List colelction to collect the CWMP Project records which needs to be inserted. */
            List<CWMP_Project__Share> projectShareReocrdToInsert = new List<CWMP_Project__Share>();
            
            /** Iterating the Project records in order to craete the Project Share records 
             * to share the Project with their respoective Community County user group. */
            for(CWMP_Project__c projectToShare : projectIdToProjectMap.values()) {
                if(groupAPINAmeToGroupRecordMap?.get(countyNameToCountyConfigRecordMap?.get(appIdToAppRecordMap?.get(projectToShare.CWMP_Application__c)?.County__c).Public_Group_API_Name__c).Id != null) {
                    CWMP_Project__share projectShareRecord = new CWMP_Project__Share();
                    projectShareRecord.ParentId = projectToShare.Id;
                    projectShareRecord.RowCause = CWMP_Project__share.RowCause.Community_User__c;
                    projectShareRecord.UserOrGroupId = groupAPINAmeToGroupRecordMap?.get(countyNameToCountyConfigRecordMap?.get(appIdToAppRecordMap?.get(projectToShare.CWMP_Application__c)?.County__c).Public_Group_API_Name__c).Id;
                    projectShareRecord.AccessLevel = HH_CONSTANTS.HHApplication_ShareObject_AccessLevel_Edit;
                    
                    projectShareReocrdToInsert.add(projectShareRecord);
                }
            }
            /** Checking for null pointer exception before Inserting the Project share records. */
            if(projectShareReocrdToInsert?.size() > 0) {
                insert projectShareReocrdToInsert;
            }
        }
    }

    /***********************************************
    * Method Name : updateProjectFieldOnApplication
    * Author : Ricky
    * Description: This method is used to update the Project field on Application.
    *********************************************/
    private void updateProjectFieldOnApplication() {
        /** Collection to collect the HH Application record which needs to be updated. */
        List<HH_Application__c> applicationRecordToUpdateList = new List<HH_Application__c>();
        for(CWMP_Project__c projectrecordToProcess : (List<CWMP_Project__c>) Trigger.new) {
            if(projectrecordToProcess.CWMP_Application__c != null) {
                /** Creating instance for Application in order to update the Project field. */
                HH_Application__c applicationToUpdate = new HH_Application__c(Id = projectrecordToProcess.CWMP_Application__c, CWMP_Project__c = projectrecordToProcess.Id);
                applicationRecordToUpdateList.add(applicationToUpdate);
            }
        }

        /** Null pOinter exception check to collection before updating the Application record. */
        if(applicationRecordToUpdateList?.size() > 0) {
            update applicationRecordToUpdateList;
        }
    }
}