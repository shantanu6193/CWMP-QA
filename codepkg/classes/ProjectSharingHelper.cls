public without sharing class ProjectSharingHelper {
    public static Boolean skipSendEmail = false;

    public class CustomException extends Exception{

    }

    public class CommAppActionClass {
        public String action;
        public String value;
    }

    /***********************************************
    * Method Name : shareRecords
    * Author : Prajakta
    * Inputs : -
    * Description: This method is used to share project records with users on basis of roles,project status and programs.
                    We have added project role support for Incident-Subrecipient and Subrecipient.
                    Projects below incident Subrecipient and Subrecipient are shared with users that meet criteria.
    ************************************************/
    public static void shareRecords(String projectRoleRecId) {

        Project_Role__c projectRole = [SELECT Id, Incident_Subrecipient_Summary__c, Project_Name__c, Subrecipient__c,Programs__c
                FROM Project_Role__c WHERE Id=:projectRoleRecId];
        String recordId;
        String srcObject;
        if(String.isNotEmpty(projectRole.Incident_Subrecipient_Summary__c)) {
            srcObject = 'Incident-Subrecipient';
            recordId = projectRole.Incident_Subrecipient_Summary__c;
        } else  if(String.isNotEmpty(projectRole.Subrecipient__c)){
            srcObject = 'Subrecipient';
            recordId = projectRole.Subrecipient__c;
        } else {
            srcObject = 'Project';
            recordId = projectRole.Project_Name__c;
        }

        List<String> parentPrograms = new List<String>();
        if(projectRole.Programs__c != null) {
            parentPrograms = projectRole.Programs__c.split(';');
        }

        List<Project__c> projectListToShare = getProjects(recordId, projectRoleRecId, srcObject, parentPrograms);

        List<String> projectIds = new  List<String>();
        for(Project__c proj : projectListToShare) {
            projectIds.add(proj.Id);
        }
        if(projectIds.size() > 0){
            sendInviteMailOnContactAndShareProject(projectRoleRecId, recordId, projectIds);
        }
    }

    /***********************************************
    * Method Name : getProjects
    * Author : Prajakta
    * Inputs : -
    * Description: This method is used to get project records from Incident-Subrecipient, Subrecipient and Projects.
    ************************************************/
    private static List<Project__c> getProjects(String recordId, String projectRoleRecId, String srcObject, List<String> parentPrograms) {
        List<Project__c> projectListToShare = new List<Project__c>();
        // set default value of value is blank
        if(string.isEmpty(srcObject)) {
            srcObject = 'Project__c';
        }

        switch on srcObject {
            when 'Incident-Subrecipient', 'Incident_Subrecipient_Stage__c' {//todo - add Constant for New
                projectListToShare = [SELECT id FROM Project__c WHERE Incident_Subrecipient_Summary__c =: recordId AND Stage__c !=: PA_CONSTANTS.PA_PROJECT_NEW_STATUS AND
                Program_Name__r.Parent_Program__r.Name IN:parentPrograms];
            }
            when 'Subrecipient', 'Account' {
                if(parentPrograms.size() > 0){
                    projectListToShare = [SELECT id FROM Project__c WHERE Obligating_Sub_Recipient__c=:recordId AND Stage__c !=: PA_CONSTANTS.PA_PROJECT_NEW_STATUS AND
                    Program_Name__r.Parent_Program__r.Name IN:parentPrograms];
                }

            }
            when 'Project__c', 'Project' {
                projectListToShare = [SELECT id FROM Project__c WHERE Id = :recordId AND Stage__c !=: PA_CONSTANTS.PA_PROJECT_NEW_STATUS
                    AND Program_Name__r.Parent_Program__r.Name=:PA_CONSTANTS.PA_PARENT_PROGRAM_NAME];
            }
        }
        return projectListToShare;
    }

    /***********************************************
   * Method Name : sendInviteMailOnContactAndShareProject
   * Author : Prajakta
   * Inputs : -
   * Description: This method is used to send mail and share project records.
   ************************************************/
    private static void sendInviteMailOnContactAndShareProject(String projectRoleRecId, String parentRecId, List<String> projectIds){
        List<Project_Role__c> projectRoleRecordList = [SELECT Id, AccountContactJunction__c, Project_Role_Global_List__c, isSendInvitation__c, Name, AccountContactJunction__r.Contact_Name__c,
                AccountContactJunction__r.Contact_Name__r.Email FROM Project_Role__c WHERE Id=:projectRoleRecId];
        system.debug('projectRoleRecordList------------>'+projectRoleRecordList);
        if(projectRoleRecordList.size() > 0){
            List<User>  userValLst = [SELECT Id,ContactId FROM User WHERE ContactId =:projectRoleRecordList[0].AccountContactJunction__r.Contact_Name__c AND ContactId != NULL];

            // check if community application to user present. if not then create one
            // Linking of Contact with Community to Application User
            //todo - it should be applicable to other Apps as well. Need to discuss with Nik
            List<Community_Application_to_User__c> commAppUser = [SELECT Id, Name, Contact__c, User__c, isActive__c, Post_Active_Actions__c
            FROM Community_Application_to_User__c
            WHERE Contact__c =:projectRoleRecordList[0].AccountContactJunction__r.Contact_Name__c and Community_Application__r.Name ='PA'
             AND Community_Application__r.isActive__c =TRUE];

            if(commAppUser.size() == 0) {
                Community_Application_to_User__c newCommAppUser = new Community_Application_to_User__c();
                newCommAppUser.Contact__c = projectRoleRecordList[0].AccountContactJunction__r.Contact_Name__c;
                newCommAppUser.User__c = userValLst.size() > 0 ? userValLst[0].Id:null;
                newCommAppUser.isActive__c = userValLst.size() > 0 ? true : false;

                List<Community_Application__c> communityAppVal  = [SELECT Id, Name
                FROM Community_Application__c WHERE Name='PA' AND isActive__c=TRUE];
                if(communityAppVal.size() ==0) return;

                newCommAppUser.Community_Application__c = communityAppVal[0].Id;

                // if user not present then add post active action where records will get shared once accepted invitation
                if(userValLst.size() == 0) {
                    List<CommAppActionClass> commAppActionClasses = new List<CommAppActionClass>();
                    CommAppActionClass commAppActionClass = new CommAppActionClass();
                    commAppActionClass.action = 'ShareProject';
                    commAppActionClass.value = projectRoleRecId;
                    commAppActionClasses.add(commAppActionClass);
                    newCommAppUser.Post_Active_Actions__c = JSON.serialize(commAppActionClasses);
                }
                insert newCommAppUser;
            } else {
                // if user not present then add post active action where records will get shared once accepted invitation
                if(userValLst.size() == 0) {
                    List<CommAppActionClass> commAppActionClasses = new List<CommAppActionClass>();
                    if(commAppUser[0].Post_Active_Actions__c != null) {
                        commAppActionClasses = (List<CommAppActionClass>)JSON.deserialize(commAppUser[0].Post_Active_Actions__c, List<CommAppActionClass>.Class);
                    }
                    CommAppActionClass commAppActionClass = new CommAppActionClass();
                    commAppActionClass.action = 'ShareProject';
                    commAppActionClass.value = projectRoleRecId;
                    commAppActionClasses.add(commAppActionClass);
                    commAppUser[0].Post_Active_Actions__c = JSON.serialize(commAppActionClasses);
                    update commAppUser[0];
                }
            }

            Map<String, Project_Sharing_Config__mdt> projectSharingConfigMapByRole = getProjectShareConfig();


            // if user present then share record with user.
            if(userValLst.size() > 0) {
                shareProjectAndRelatedRecordsToContact(projectIds, projectRoleRecordList[0].Id, userValLst[0].Id, projectSharingConfigMapByRole);
            }

            if(skipSendEmail == false) {
                if(projectRoleRecordList[0].Project_Role_Global_List__c != null && projectSharingConfigMapByRole.get(projectRoleRecordList[0].Project_Role_Global_List__c) != null
                        && projectSharingConfigMapByRole.get(projectRoleRecordList[0].Project_Role_Global_List__c).Share_Project__c != null) {
                    //EmailHelper.sendEmail(projectIds[0], projectRoleRecordList[0].AccountContactJunction__r.Contact_Name__c, new List<String>(), KeyValueHelper.getTextValue('PA_Invitation_Email'), 'PA_From_Email_Addresses');

                }
            }
        }
    }

    /***********************************************
    * Method Name : shareProjectAndRelatedRecordsToContact
    * Author : Prajakta
    * Inputs : -
    * Description: This method is used to send mail and share project records.
    ************************************************/
    private static void shareProjectAndRelatedRecordsToContact(List<String> projectIds, String projectRoleRecId, String userId, Map<String, Project_Sharing_Config__mdt> projectSharingConfigMapByRole) {
        List<Project_Role__c> projectRoles = [SELECT Id, Project_Name__c, AccountContactJunction__r.Contact_Name__c, Project_Role_Global_List__c
                FROM Project_Role__c
                WHERE Id=:projectRoleRecId];
        system.debug('projectRoles------------>'+projectRoles);
        if(projectRoles.size() == 0) return;


        if(projectSharingConfigMapByRole.size() == 0) return;

        // share Projects based on Role
        shareProjectRecords(projectIds, projectRoles.get(0), projectSharingConfigMapByRole, userId);

        // Share Amendment Request
        shareAmendmentRecords(projectRoles, projectSharingConfigMapByRole, userId, projectIds);
    }

    /***********************************************
    * Method Name : getProjectShareConfig
    * Author : Prajakta
    * Inputs : -
    * Description: This method is used  to get project sharing roles from custom metadata.
    ************************************************/
    private static Map<String, Project_Sharing_Config__mdt> getProjectShareConfig() {
        Map<String, Project_Sharing_Config__mdt> projectSharingConfigMapByRole = new Map<String, Project_Sharing_Config__mdt>();
        List<Project_Sharing_Config__mdt> projectSharingConfigs = [SELECT Id,Share_Project__c,Share_Amendment_Requests__c,Share_Award__c,Role__c,
                Share_Closeout__c,Share_Payment__c,Share_Payment_Request__c
        FROM Project_Sharing_Config__mdt];
        if(projectSharingConfigs.size() == 0) return projectSharingConfigMapByRole;

        for (Project_Sharing_Config__mdt projectSharingConfig : projectSharingConfigs) {
            projectSharingConfigMapByRole.put(projectSharingConfig.Role__c, projectSharingConfig);
        }
        return projectSharingConfigMapByRole;
    }

    /***********************************************
    * Method Name : shareProjectRecords
    * Author : Prajakta
    * Inputs : -
    * Description: This method is used to share project records.
    ************************************************/
    private static void shareProjectRecords(List<String> projectIds, Project_Role__c projectRole, Map<String, Project_Sharing_Config__mdt> projectSharingConfigMapByRole, String userId) {
        List<Project__Share> projectShares = new List<Project__Share>();
        if(projectRole.Project_Role_Global_List__c != null && projectSharingConfigMapByRole.get(projectRole.Project_Role_Global_List__c) != null
                    && projectSharingConfigMapByRole.get(projectRole.Project_Role_Global_List__c).Share_Project__c != null) {
            //When we have entry for roles in custom metadata then only we need to send emails to user that is associated with role.

            String accessLevel = 'Read';
            //todo - read from constant
            if(projectSharingConfigMapByRole.get(projectRole.Project_Role_Global_List__c).Share_Project__c == 'Read/Write') {
                accessLevel = 'Edit';
            }

            for (String projectId : projectIds) {
                Project__Share jobShr  = new Project__Share();
                jobShr.ParentId = projectId;
                jobShr.UserOrGroupId = userId;
                jobShr.AccessLevel = accessLevel;
                jobShr.RowCause = Schema.Project__Share.RowCause.RoleSharing__c;
                //todo - add sharing reason
                projectShares.add(jobShr);
            }
        }
        insert projectShares;
    }

    private static void shareAmendmentRecords(List<Project_Role__c> projectRoles, Map<String, Project_Sharing_Config__mdt> projectSharingConfigMapByRole, String userId, List<String> projectIds) {
        // List<Amendment_Request__Share> amendmentRequestShares = new List<Amendment_Request__Share>();
        // Map<Id, List<Amendment_Request__c>> amendmentRequestMap = new Map<Id, List<Amendment_Request__c>>();
        // for (Amendment_Request__c amendmentRequest : [SELECT Project__c FROM Amendment_Request__c WHERE Project__c In:projectIds]) {
        //     if(amendmentRequestMap.get(amendmentRequest.Project__c) == null) {
        //         amendmentRequestMap.put(amendmentRequest.Project__c, new List<Amendment_Request__c>());
        //     }
        //     amendmentRequestMap.get(amendmentRequest.Project__c).add(amendmentRequest);
        // }

        // for (Project_Role__c projectRole : projectRoles) {
        //     if(projectRole.Project_Role_Global_List__c != null && projectSharingConfigMapByRole.get(projectRole.Project_Role_Global_List__c) != null
        //             && projectSharingConfigMapByRole.get(projectRole.Project_Role_Global_List__c).Role__c != null) {
        //         String accessLevel = 'Read';
        //         if(projectSharingConfigMapByRole.get(projectRole.Project_Role_Global_List__c).Share_Amendment_Requests__c == 'Read/Write') {
        //             accessLevel = 'Read/Write';
        //         }
        //         if(amendmentRequestMap.get(projectRole.Project_Name__c) == null) continue;

        //         for (Amendment_Request__c amendmentRequest : amendmentRequestMap.get(projectRole.Project_Name__c)) {
        //             Amendment_Request__Share jobShr  = new Amendment_Request__Share();
        //             jobShr.ParentId = amendmentRequest.Id;
        //             jobShr.UserOrGroupId = userId;
        //             jobShr.AccessLevel = accessLevel;
        //             amendmentRequestShares.add(jobShr);
        //         }
        //     }
        // }
        // insert amendmentRequestShares;
    }


    
    /***********************************************
    * Method Name : getCurrentLoginUserAppName
    * Author : Atul
    * Inputs : 
    * Description: Check App of Current login user
    *********************************************/
    @AuraEnabled(Cacheable=true)
    public static String getCurrentLoginUserAppName(){
        String userIdVal = UserInfo.getUserId();
        String currentAppName='';
        List<UserAppInfo>  userAppInfoList  = [SELECT Id, UserId, AppDefinitionId, FormFactor, CreatedById, CreatedDate, LastModifiedById, LastModifiedDate 
                                            FROM UserAppInfo WHERE UserId =:userIdVal];
        System.debug('UserAppInfo List===='+userAppInfoList);    
      if(userAppInfoList.size() > 0){
          List<AppDefinition> appDefList = [SELECT Id,DeveloperName,DurableId 
                                            FROM AppDefinition WHERE DurableId=:userAppInfoList[0].AppDefinitionId];

           System.debug('appDefList List===='+appDefList);                                  
           currentAppName =   appDefList[0].DeveloperName;                               
      }  

      return  currentAppName;
    }

    public static void shareNewProjectRecords(List<String> projectIdList){
        List<Project__c> projectList = [SELECT Id, Incident_Name__c, Incident_Subrecipient_Summary__c, Obligating_Sub_Recipient__c FROM Project__c
                Where id In:projectIdList AND Stage__c != :PA_CONSTANTS.PA_PROJECT_NEW_STATUS];
        system.debug('projectList'+projectList);
        List<String> incidentSubrecipientIdList = new  List<String>();
        List<String> subrecipientIdList = new  List<String>();
        List<String> projectIdsList = new  List<String>();
        if(projectList.size() > 0){
            for(Project__c proj : projectList) {

                if(String.isNotEmpty(proj.Incident_Subrecipient_Summary__c)){
                    incidentSubrecipientIdList.add(proj.Incident_Subrecipient_Summary__c);
                }

                if(String.isNotEmpty(proj.Obligating_Sub_Recipient__c)){
                    subrecipientIdList.add(proj.Obligating_Sub_Recipient__c);
                }

                projectIdList.add(proj.Id);

            }

            List<Project_Role__c> projectRoleRecordList = [SELECT Id, Incident_Subrecipient_Summary__c, Project_Role_Global_List__c, AccountContactJunction__r.Contact_Name__c, Project_Name__c, Subrecipient__c
            FROM Project_Role__c WHERE Incident_Subrecipient_Summary__c IN: incidentSubrecipientIdList OR  Subrecipient__c IN: subrecipientIdList OR Project_Name__c IN: projectIdsList];
            if(projectRoleRecordList.size() == 0) return;
            Set<Id> contactIdList = new Set<Id>();
            Map<String, Project_Sharing_Config__mdt> projectSharingConfigMapByRole = getProjectShareConfig();
            if(projectSharingConfigMapByRole.size() == 0) return;

            for(Project_Role__c projectRole : projectRoleRecordList) {
                if(projectRole.AccountContactJunction__c != null) {
                    contactIdList.add(projectRole.AccountContactJunction__r.Contact_Name__c);
                }
            }
            Map<Id, Id> contactToUserId = new Map<Id, Id>();
            if(contactIdList != null){
                List<User> userValueList = [SELECT Id,ContactId FROM User WHERE ContactId IN: contactIdList AND ContactId != NULL];
                for (User userRec : userValueList) {
                    contactToUserId.put(userRec.ContactId, userRec.Id);
                }
            }
            List<Project__Share> projectShares = new List<Project__Share>();

            for (Project__c proj : projectList) {
                for(Project_Role__c projectRole : projectRoleRecordList){
                    if((projectRole.Project_Name__c != null && projectRole.Project_Name__c == proj.Id) ||
                            (projectRole.Incident_Subrecipient_Summary__c != null && projectRole.Incident_Subrecipient_Summary__c == proj.Incident_Subrecipient_Summary__c) ||
                            (projectRole.Subrecipient__c != null && projectRole.Subrecipient__c == proj.Obligating_Sub_Recipient__c)) {
                        String accessLevel = 'Read';
                        if(projectRole.Project_Role_Global_List__c != null && projectSharingConfigMapByRole.get(projectRole.Project_Role_Global_List__c) != null
                                && projectSharingConfigMapByRole.get(projectRole.Project_Role_Global_List__c).Share_Project__c != null) {
                            if(projectSharingConfigMapByRole.get(projectRole.Project_Role_Global_List__c).Share_Project__c == 'Read/Write') {
                                accessLevel = 'Edit';
                            }
                        if(projectRole.AccountContactJunction__c != null &&
                                contactToUserId.get(projectRole.AccountContactJunction__r.Contact_Name__c) != null) {
                            Project__Share jobShr  = new Project__Share();
                            jobShr.ParentId = proj.Id;
                            jobShr.UserOrGroupId = contactToUserId.get(projectRole.AccountContactJunction__r.Contact_Name__c);
                            jobShr.AccessLevel = accessLevel;
                            jobShr.RowCause = Schema.Project__Share.RowCause.RoleSharing__c;
                            projectShares.add(jobShr);
                        }
                        }

                    }
                }
            }
            insert projectShares;
        }

    }

}