public without sharing class ProjectRoleTriggerHelper extends TriggerHelper
{
    public override void processBeforeInsert() 
    {
        avoidDuplicateProjectRole();
    }

	public override void processAfterInsert() {
        /** This method is used to update Authorized Agent Information on related Project(These fields are used for Docu gen Templates). */
        updateAuthorizedAgentInfoOnRelatedProject();
    }

    public override void processBeforeUpdate() 
    {
        avoidDuplicateProjectRole();
    }

	public override void processAfterUpdate() {
        /** This method is used to update Authorized Agent Information on related Project when the Project Role is edited,
         * and Contact is no Authorized Agent for the Project anymore(These fields are used for Docu gen Templates). */
        removeAuthorizedAgentInfoOnRelatedProject();

        /** This method is used to update Authorized Agent Information on related Project(These fields are used for Docu gen Templates). */
        updateAuthorizedAgentInfoOnRelatedProject();
    }
    
    //To avoid creation of Duplicate Project Role....
    private void avoidDuplicateProjectRole()
    {
        Set<Id> contactRoleIds = new Set<Id>(); //To collect the Contact Role Ids...
        Set<Id> projectIds = new Set<Id>(); //TO collect the Project Ids...
        for(Project_Role__c pRole : (List<Project_Role__c>) Trigger.new) {
            if (pRole.AccountContactJunction__c != null) {
                contactRoleIds.add(pRole.AccountContactJunction__c); //Collecting the Contact Role Id...
            }
            if (pRole.Project_Name__c != null) {
                projectIds.add(pRole.Project_Name__c); //Collecting the Project Id...
            }
        }
        if (!contactRoleIds.isEmpty() && !projectIds.isEmpty()) { //Checking for null pointer exception.....
            //Collecting all the Project Role records whose AccountContactJunction and Project value is same as current Project Role record...
            List<Project_Role__c> existingRole = [SELECT Id, Name, Project_Name__c, AccountContactJunction__c, Project_Role_Global_List__c
                                        FROM Project_Role__c WHERE Project_Name__c IN : projectIds AND AccountContactJunction__c IN : contactRoleIds ];
            for(Project_Role__c pRole : (List<Project_Role__c>) Trigger.new) {
                for(Project_Role__c existRole : existingRole ) { //Iterating the existing Project roles..
                    if (pRole.AccountContactJunction__c == existRole.AccountContactJunction__c && pRole.Project_Name__c == existRole.Project_Name__c
                            && pRole.Project_Role_Global_List__c == existRole.Project_Role_Global_List__c) { // Checking for the Contact Role with same Account and Contact..
                       if(Trigger.isInsert) {
                           pRole.addError('Duplicate Project Role are not allowed.');
                       }// Displaying the error...
                        if(Trigger.isUpdate){
                            Project_Role__c oldRec = (Project_Role__c) Trigger.oldMap.get(pRole.Id);
                           if(oldRec.Project_Role_Global_List__c!=pRole.Project_Role_Global_List__c)
                           {
                               pRole.addError('Duplicate Project Role are not allowed.');
                           }
                        }
                    }
                }
            }
        }
    }

    /*********************************************
	* Method Name : updateAuthorizedAgentInfoOnRelatedProject
	* Called From Method : AfterInsert, AfterUpdate
	* Author : Ricky
	* Inputs : -
	* Description: This method is used to update Authorized Agent Information on related Project(These fields are used for Docu gen Templates).
	*********************************************/
    private void updateAuthorizedAgentInfoOnRelatedProject() {
        Map<Id, Project_Role__c> projectRoleIdToPrimaryAuthorizedAgentMap = new Map<Id, Project_Role__c>();
        if (Trigger.isInsert) {
            for(Project_Role__c projectRoleToProcess : (List<Project_Role__c>) Trigger.new) {
                if (projectRoleToProcess.Project_Name__c != null
                        && projectRoleToProcess.Project_Role_Global_List__c == ALS_CONSTANTS.ProjectRole_Role_AuthorizedAgent
                        && projectRoleToProcess.Contact_Type__c == ALS_CONSTANTS.ProjectRole_ContactType) {
                    projectRoleIdToPrimaryAuthorizedAgentMap.put(projectRoleToProcess.Id, projectRoleToProcess);
                }
            }
        }
        if (Trigger.isUpdate) {
            for(Project_Role__c projectRoleToProcess : (List<Project_Role__c>) Trigger.new) {
                Project_Role__c oldRecord = (Project_Role__c) Trigger.oldMap.get(projectRoleToProcess.Id);
                if (projectRoleToProcess.Project_Name__c != null
                        && (oldRecord.Project_Role_Global_List__c != projectRoleToProcess.Project_Role_Global_List__c
                            ||  oldRecord.Contact_Type__c != projectRoleToProcess.Contact_Type__c)
                        && projectRoleToProcess.Project_Role_Global_List__c == ALS_CONSTANTS.ProjectRole_Role_AuthorizedAgent
                        && projectRoleToProcess.Contact_Type__c == ALS_CONSTANTS.ProjectRole_ContactType) {
                    projectRoleIdToPrimaryAuthorizedAgentMap.put(projectRoleToProcess.Id, projectRoleToProcess);
                }
            }
        }

        Map<Id, Project_Role__c> projectRoleIdToProjectRoleMap = new Map<Id, Project_Role__c>([SELECT Id, Name, AccountContactJunction__c,
                                            AccountContactJunction__r.Contact_Name__r.FirstName, AccountContactJunction__r.Contact_Name__r.LastName,
                                            AccountContactJunction__r.Contact_Name__r.Salutation, AccountContactJunction__r.Contact_Name__r.Title,
                                            Project_Name__c FROM Project_Role__c WHERE Id IN : projectRoleIdToPrimaryAuthorizedAgentMap.keySet()]);
        List<Project__c> projectToUpdateList = new List<Project__c>();
        if (projectRoleIdToProjectRoleMap?.size() > 0) {
            for(Project_Role__c projectRoleToProcess : projectRoleIdToProjectRoleMap?.values()) {
                Project__c projectToUpdate = new Project__c();
                projectToUpdate.Id = projectRoleToProcess.Project_Name__c;
                projectToUpdate.Authorized_Agent_Salutation__c = projectRoleToProcess.AccountContactJunction__r.Contact_Name__r.Salutation;
                projectToUpdate.Authorized_Agent_FirstName__c = projectRoleToProcess.AccountContactJunction__r.Contact_Name__r.FirstName;
                projectToUpdate.Authorized_Agent_LastName__c = projectRoleToProcess.AccountContactJunction__r.Contact_Name__r.LastName;
                projectToUpdate.Authorized_Agent_Title__c = projectRoleToProcess.AccountContactJunction__r.Contact_Name__r.Title;
                projectToUpdateList.add(projectToUpdate);
            }

            update projectToUpdateList;
        }
    }

    /*********************************************
	* Method Name : removeAuthorizedAgentInfoOnRelatedProject
	* Called From Method : AfterInsert, AfterUpdate
	* Author : Ricky
	* Inputs : -
	* Description: This method is used to update Authorized Agent Information on related Project when the Project Role is edited,
*                   and Contact is no Authorized Agent for the Project anymore(These fields are used for Docu gen Templates).
	*********************************************/
    private void removeAuthorizedAgentInfoOnRelatedProject() {
        List<Project__c> projectToUpdateList = new List<Project__c>();
        Map<Id, Project_Role__c> pRoleIdToPRoleRecordMap = new Map<Id, Project_Role__c>();
        if (Trigger.isUpdate) {
            for(Project_Role__c projectRoleToProcess : (List<Project_Role__c>) Trigger.new) {
                Project_Role__c oldRecord = (Project_Role__c) Trigger.oldMap.get(projectRoleToProcess.Id);
                if (projectRoleToProcess.Project_Name__c != null
                        && (oldRecord.Project_Role_Global_List__c != projectRoleToProcess.Project_Role_Global_List__c
                            ||  oldRecord.Contact_Type__c != projectRoleToProcess.Contact_Type__c)
                        && (oldRecord.Project_Role_Global_List__c == ALS_CONSTANTS.ProjectRole_Role_AuthorizedAgent
                                && oldRecord.Contact_Type__c == ALS_CONSTANTS.ProjectRole_ContactType)
                        && (projectRoleToProcess.Project_Role_Global_List__c != ALS_CONSTANTS.ProjectRole_Role_AuthorizedAgent
                                || projectRoleToProcess.Contact_Type__c != ALS_CONSTANTS.ProjectRole_ContactType)) {
                    pRoleIdToPRoleRecordMap.put(projectRoleToProcess.Id, projectRoleToProcess);
                }
            }
        }

        if (pRoleIdToPRoleRecordMap?.size() > 0) {
            Map<Id, Project_Role__c> projectRoleIdToProjectRoleMap = new Map<Id, Project_Role__c>([SELECT Id, Name, AccountContactJunction__c,
                    AccountContactJunction__r.Contact_Name__r.FirstName, AccountContactJunction__r.Contact_Name__r.LastName,
                    AccountContactJunction__r.Contact_Name__r.Salutation, AccountContactJunction__r.Contact_Name__r.Title,
                    Project_Name__c, Project_Name__r.Authorized_Agent_Salutation__c, Project_Name__r.Authorized_Agent_FirstName__c,
                    Project_Name__r.Authorized_Agent_LastName__c, Project_Name__r.Authorized_Agent_Title__c
                    FROM Project_Role__c WHERE Id IN : pRoleIdToPRoleRecordMap.keySet()]);
            for (Project_Role__c projectRoleToProcess : projectRoleIdToProjectRoleMap?.values()) {
                if (projectRoleToProcess.Project_Name__r.Authorized_Agent_FirstName__c == projectRoleToProcess.AccountContactJunction__r.Contact_Name__r.FirstName
                        && projectRoleToProcess.Project_Name__r.Authorized_Agent_LastName__c == projectRoleToProcess.AccountContactJunction__r.Contact_Name__r.LastName) {
                    Project__c projectToUpdate = new Project__c();
                    projectToUpdate.Id = projectRoleToProcess.Project_Name__c;
                    projectToUpdate.Authorized_Agent_Salutation__c = null;
                    projectToUpdate.Authorized_Agent_FirstName__c = null;
                    projectToUpdate.Authorized_Agent_LastName__c = null;
                    projectToUpdate.Authorized_Agent_Title__c = null;
                    projectToUpdateList.add(projectToUpdate);
                }
            }
            if (projectToUpdateList?.size() > 0) {
                update projectToUpdateList;
            }
        }
    }
}