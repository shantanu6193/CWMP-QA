/***********************************************************************************************************************************
* Class Name   : HH_AccountRoleTriggerHandler
* Description  : Handle Account Role object trigger operations
* Author       : Shantanu
* Created On   : 04/01/2022
* Modification Log:
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Shantanu              04/01/2022       Initial Implementation
**************************************************************************************************************************************/

public without sharing class HH_AccountRoleTriggerHandler  extends TriggerHandler implements TriggerInterface{
    public override void beforeInsert() {
        /** This method is used update the CWMP Application(CWMP Application related to CWMP Project) in Account Role record while inserting. */
        updateApplicationFieldOnAccountRole();

        /** This method is used update the CWMP Project(CWMP Project related to CWMP Application) in Account Role record while inserting. */
        updateProjectFieldOnAccountRole();
    }


    public override void afterInsert() {
        shareRecordsWithCommunityAndCaloesGroup();
    }


     /***********************************************
    * Method Name : shareRecordsWithCommunityAndCaloesGroup
    * Author : Shantanu
    * Description: This method is used to Share the AccountRole records with Community and Cal OES user groups.
    *********************************************/
    private void shareRecordsWithCommunityAndCaloesGroup() {
        /** Fetching CWMP Record Type Id by Developer Name. */
        Id cwmpRecordTypeId = Schema.SObjectType.Account_Role__c.getRecordTypeInfosByDeveloperName().get(HH_CONSTANTS.AccountRole_CWMPRecordType_APIName).getRecordTypeId();
        List<Account_Role__c> accountRoles = new List<Account_Role__c>();
        Set<Id> applicationIdSet = new Set<Id>();
        for (Account_Role__c accountRole : (List<Account_Role__c>) Trigger.new) {
            if (accountRole.RecordTypeId == cwmpRecordTypeId
                    && accountRole.CWMP_Application__c != null) {
                accountRoles.add(accountRole);
                applicationIdSet.add(accountRole.CWMP_Application__c);
            }
        }
        /** Condition to check for null pointer exception for the rfiToProcessList collection. */
        if (accountRoles?.size() > 0) {
            /** Fetching CWMP Application records which are related to RFI which needs to be processed. */
            Map<Id, HH_Application__c> appIdToApplicationRecordMap = new Map<Id, HH_Application__c>(
                    [SELECT Id, Name, County__c, Stage__c, Applicant__r.Name FROM HH_Application__c WHERE Id IN : applicationIdSet]);
            /** Set collection to store the name of the Counties of the related CWMP Application records. */
            Set<String> countySet = new Set<String>();
            /** Iterating Application records to collect the counties of the Application. */
            for (HH_Application__c hhApplicationToProcess : appIdToApplicationRecordMap?.values()) {
                if (hhApplicationToProcess.County__c != null) {
                    countySet.add(hhApplicationToProcess.County__c);
                }
            }

            List<County_Config__mdt> countyConfigMetaRecordList = new List<County_Config__mdt>();
            Map<String, String> countyNameToPublicGroupApiNameMap = new Map<String, String>();
            Map<String, Group> groupDeveloperNameToGroupRecordMap = new Map<String, Group>();
            Set<String> publicGroupApiNames = new Set<String>();
            publicGroupApiNames.add(HH_CONSTANTS.HH_CalOESInternal_User_Group_APIName);
            List<Group> publicGroupInfoList = new List<Group>();
            if (countySet?.size() > 0) {
                countyConfigMetaRecordList = [SELECT Id, Label, Application_Type__c, Public_Group_API_Name__c, Queue_API_Name__c FROM County_Config__mdt
                        WHERE Label IN : countySet AND Application_Type__c = :HH_CONSTANTS.HH_Application_APIName_CountyConfig];
            }
            /** Arranging the County Config Metadata Record in order as County name as Key and Group API name as value. */
            if (countyConfigMetaRecordList?.size() > 0) {
                for (County_Config__mdt countyConfig : countyConfigMetaRecordList) {
                    if (countyConfig.Public_Group_API_Name__c != null) {
                        publicGroupApiNames.add(countyConfig.Public_Group_API_Name__c);
                        countyNameToPublicGroupApiNameMap.put(countyConfig.Label, countyConfig.Public_Group_API_Name__c);
                    }
                }
            }

            if (publicGroupApiNames?.size() > 0) {
                /** Fetching the Public Group Info in order to share the record. */
                publicGroupInfoList = [SELECT Id, Name, DeveloperName, Type FROM Group
                                        WHERE DeveloperName IN :publicGroupApiNames AND Type = 'Regular'];

                /** Arranging the Group record in order as Group API name as Key and Group record as value,
                 * In order to fetch the record while processing the Applications. */
                if (publicGroupInfoList?.size() > 0) {
                    for (Group groupRecord : publicGroupInfoList) {
                        groupDeveloperNameToGroupRecordMap.put(groupRecord.DeveloperName, groupRecord);
                    }
                }
            }

            List<Account_Role__Share> arShareToInsertList = new List<Account_Role__Share>();
            List<AccountShare> accountShareToInsertList = new List<AccountShare>();
            for (Account_Role__c arToShare : accountRoles) {
                /** Sharing AccountRole record with Community user Group. */
                System.debug('Map: '+ groupDeveloperNameToGroupRecordMap);
                if (groupDeveloperNameToGroupRecordMap?.get(countyNameToPublicGroupApiNameMap?.get(appIdToApplicationRecordMap?.get(arToShare.CWMP_Application__c)?.County__c))?.Id != null) {
                    Account_Role__Share arShareToInsert1 = new Account_Role__Share();
                    arShareToInsert1.ParentId = arToShare.Id;
                    arShareToInsert1.AccessLevel = HH_CONSTANTS.AccountRole_ShareObject_AccessLevel_Edit;
                    arShareToInsert1.UserOrGroupId = groupDeveloperNameToGroupRecordMap?.get(countyNameToPublicGroupApiNameMap?.get(appIdToApplicationRecordMap?.get(arToShare.CWMP_Application__c)?.County__c))?.Id;
                    arShareToInsert1.RowCause = Account_Role__Share.RowCause.CWMP_Sharing__c;
                    arShareToInsertList.add(arShareToInsert1);

                    AccountShare accShareToInsert1 = new AccountShare();
                    accShareToInsert1.AccountId = arToShare.Account__c;
                    accShareToInsert1.AccountAccessLevel = HH_CONSTANTS.AccountRole_ShareObject_AccessLevel_Edit;
                    accShareToInsert1.OpportunityAccessLevel = 'none';
                    accShareToInsert1.UserOrGroupId = groupDeveloperNameToGroupRecordMap?.get(countyNameToPublicGroupApiNameMap?.get(appIdToApplicationRecordMap?.get(arToShare.CWMP_Application__c)?.County__c))?.Id;
                    accountShareToInsertList.add(accShareToInsert1);
                }
                /** Sharing the AccountRole record with Cal OES User group. */
                if (groupDeveloperNameToGroupRecordMap.get(HH_CONSTANTS.HH_CalOESInternal_User_Group_APIName).Id != null) {
                    Account_Role__Share arShareToInsert2 = new Account_Role__Share();
                    arShareToInsert2.ParentId = arToShare.Id;
                    arShareToInsert2.AccessLevel = HH_CONSTANTS.AccountRole_ShareObject_AccessLevel_Edit;
                    arShareToInsert2.UserOrGroupId = groupDeveloperNameToGroupRecordMap.get(HH_CONSTANTS.HH_CalOESInternal_User_Group_APIName).Id;
                    arShareToInsert2.RowCause = Account_Role__Share.RowCause.CWMP_Sharing__c;
                    arShareToInsertList.add(arShareToInsert2);


                    AccountShare accShareToInsert2 = new AccountShare();
                    accShareToInsert2.AccountId = arToShare.Account__c;
                    accShareToInsert2.AccountAccessLevel = HH_CONSTANTS.AccountRole_ShareObject_AccessLevel_Edit;
                    accShareToInsert2.OpportunityAccessLevel = 'none';
                    accShareToInsert2.UserOrGroupId = groupDeveloperNameToGroupRecordMap.get(HH_CONSTANTS.HH_CalOESInternal_User_Group_APIName).Id;
                    accountShareToInsertList.add(accShareToInsert2);
                }
            }
            /** Checking for null pointer exception for the arShareToInsertList collection before inserting. */
            if (arShareToInsertList?.size() > 0) {
                insert arShareToInsertList;
            }
            if (accountShareToInsertList?.size() > 0) {
                insert accountShareToInsertList;
            }
        }
    }

    /***********************************************
    * Method Name : updateApplicationFieldOnAccountRole
    * Author : Ricky
    * Description: This method is used update the CWMP Application(CWMP Application related to CWMP Project) in Account Role record while inserting. 
    *********************************************/
    private void updateApplicationFieldOnAccountRole() {
        /** Set collection to store Project ids which is related to Account Roles, in order to fetch the records. */
        Set<Id> projectIds = new Set<Id>();
        /** List collection to store the Accountrole records which needs to be processed. */
        List<Account_Role__c> accountRoleToProcessList = new List<Account_Role__c>();

        /** Iterating Trigger.new colelction in order to check, 
         * if the Project is present and Application is absent on the Account Role record. */
        for (Account_Role__c accountRole : (List<Account_Role__c>) Trigger.new) {
            if(accountRole.CWMP_Project__c != null 
                && accountRole.CWMP_Application__c == null) {
                    projectIds.add(accountRole.CWMP_Project__c);
                    accountRoleToProcessList.add(accountRole);
            }
        }

        if(projectIds?.size() > 0) {
            /** Fetching the Project records in order to update it on Account Role. */
            Map<Id, CWMP_Project__c> projectIdToProjectRecordMap = new Map<Id, CWMP_Project__c>([SELECT Id, Name, 
                                                                    CWMP_Application__c FROM CWMP_Project__c WHERE Id IN : projectIds]);

            /** Updating the CWMP APplication field on Account Role. */
            for(Account_Role__c accountRole : accountRoleToProcessList) {
                if(projectIdToProjectRecordMap?.get(accountRole.CWMP_Project__c)?.CWMP_Application__c != null) {
                    accountRole.CWMP_Application__c = projectIdToProjectRecordMap?.get(accountRole.CWMP_Project__c)?.CWMP_Application__c;
                }
            }
        }
    }

    /***********************************************
    * Method Name : updateProjectFieldOnAccountRole
    * Author : Ricky
    * Description: This method is used update the CWMP Project(CWMP Project related to CWMP Application) in Account Role record while inserting. 
    *********************************************/
    private void updateProjectFieldOnAccountRole() {
        /** Set collection to store application ids which is related to Account Roles, in order to fetch the records. */
        Set<Id> applicationIds = new Set<Id>();
        /** List collection to store the Accountrole records which needs to be processed. */
        List<Account_Role__c> accountRoleToProcessList = new List<Account_Role__c>();

        /** Iterating Trigger.new colelction in order to check, 
         * if the Project is absent and Application is present on the Account Role record. */
        for (Account_Role__c accountRole : (List<Account_Role__c>) Trigger.new) {
            if(accountRole.CWMP_Application__c != null 
                && accountRole.CWMP_Project__c == null) {
                    applicationIds.add(accountRole.CWMP_Application__c);
                    accountRoleToProcessList.add(accountRole);
            }
        }

        if(applicationIds?.size() > 0) {
             /** Fetching the Application records in order to update it on Account Role. */
            Map<Id, HH_Application__c> appIdIdToappRecordMap = new Map<Id, HH_Application__c>([SELECT Id, Name, 
                                                        CWMP_Project__c FROM HH_Application__c WHERE Id IN : applicationIds]);

            /** Updating the CWMP Project field on Account Role. */
            for(Account_Role__c accountRole : accountRoleToProcessList) {
                if(appIdIdToappRecordMap?.get(accountRole.CWMP_Application__c)?.CWMP_Project__c != null) {
                    accountRole.CWMP_Project__c = appIdIdToappRecordMap?.get(accountRole.CWMP_Application__c)?.CWMP_Project__c;
                }
            }
        }
    }
}