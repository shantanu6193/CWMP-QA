/***********************************************************************************************************************************
* Class Name   : PHOS_UserServiceAppHandler
* Description  : This class for PHOS user serive app handler 
* Author       : Pankaj
* Created On   : 07/09/2020
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Pankaj              07/09/2020      Initial Implementation
**************************************************************************************************************************************/

public without sharing class PHOS_UserServiceAppHandler implements UserServiceAppHandler{

    /***********************************************
    * Method Name : handleApprove
    * Author : Pankaj
    * Inputs : List<User_Registration__c> userRegistrations
    * Description: This method handle user registration approval
    *********************************************/
    public void handleApprove(List<User_Registration__c> userRegistrations) {
        Map<Id, Set<Id>> userIdsByAppId = new Map<Id, Set<Id>>();
        Set<Id> countyUserIds = new Set<Id>();
        Set<Id> facilityUserIds = new Set<Id>();
        for (User_Registration__c userRegistration : userRegistrations) {
            if (userIdsByAppId.get(userRegistration.Community_Application__c) == null) {
                userIdsByAppId.put(userRegistration.Community_Application__c, new Set<Id>());
            }
            userIdsByAppId.get(userRegistration.Community_Application__c).add(userRegistration.User__c);
        }
        UserService.addApplicationToUser(userIdsByAppId);
        //CH01 start
        addMembersToContacts(userIdsByAppId);
        //CH01 End

        for(User_Registration__c userReg : [Select Id, User__c, User__r.Account.Entity_Type__c, User__r.Account.Parent.Entity_Type__c, Rejection_Reason__c
                                            from User_Registration__c where ID IN: userRegistrations]) {
            if (userReg.User__r.Account.Entity_Type__c == 'County' || userReg.User__r.Account.Entity_Type__c == 'State Agency'
                    || userReg.User__r.Account.Entity_Type__c == 'Non-Governmental Entity') {
                countyUserIds.add(userReg.User__c);
            }
            if (userReg.User__r.Account.Parent.Entity_Type__c == 'County') {
                facilityUserIds.add(userReg.User__c);
            }
        }
        if(!countyUserIds.isEmpty()) {
            shareUsersForChatter(countyUserIds);
        }
        if(!facilityUserIds.isEmpty()) {
            shareUsersForChatter(facilityUserIds);
        }
        //Approval Email when the user registration is approved
        if(userRegistrations != null && !userRegistrations.isEmpty()){
            sendApprovalEmail(userRegistrations);
        }
    }

    /***********************************************
    * Method Name : handleReject
    * Author : Pankaj
    * Inputs : List<User_Registration__c> userRegistrations
    * Description: This method call sendRejectionEmail method
    *********************************************/
    public void handleReject(List<User_Registration__c> userRegistrations) {
        if(userRegistrations == null || userRegistrations.size() == 0) return;
        sendRejectionEmail(userRegistrations);
    }

    /***********************************************
    * Method Name : sendRejectionEmail
    * Author : Pankaj
    * Inputs : List<User_Registration__c> userRegList
    * Description: This method send user approval request rejection email
    *********************************************/
    public static void sendRejectionEmail(List<User_Registration__c> userRegList) {

        List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>();
        List<String> toAddresses = new List<String>();

        String fromAddr = KeyValueHelper.getTextValue('PHOS_From_Email_Addresses');
        List<OrgWideEmailAddress> fromAddresses = new List<OrgWideEmailAddress>();
        Id OrgWideEmailAddressId;
        if(String.isNotBlank(fromAddr)){
            fromAddresses =  [Select Id from OrgWideEmailAddress where DisplayName=: fromAddr];
        }
        if(fromAddresses.size()>0){
            OrgWideEmailAddressId = fromAddresses[0].Id;
        }
        for (User_Registration__c userReg : userRegList) {
            toAddresses.add(userReg.Email__c);
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(toAddresses);
            mail.setOrgWideEmailAddressId(OrgWideEmailAddressId);
            EmailTemplate et;
            if(userReg.Rejection_Reason__c == 'Request Denied') {
                if(userReg.Entity_Type__c == 'County') {
                    et = [SELECT id FROM EmailTemplate WHERE developerName = 'CountyUser_RejectionEmailCounty'];
                }else if(userReg.Entity_Type__c == 'State Agency') {
                    et = [SELECT id FROM EmailTemplate WHERE developerName = 'CountyUser_RejectionEmailStateAgency'];
                }else if(userReg.Entity_Type__c == 'Non-Governmental Entity') {
                    et = [SELECT id FROM EmailTemplate WHERE developerName = 'CountyUser_RejectionEmailNonGov'];
                }else { // todo create Generic Email Template
                    et = [SELECT id FROM EmailTemplate WHERE developerName = 'CountyUser_RejectionEmailNonGov'];
                }
            }
            if(userReg.Rejection_Reason__c == 'Entity Change Required') {
                et = [SELECT id FROM EmailTemplate WHERE developerName = 'PHOS_RejectionEmail_IncorrectEntity'];
            }
            Messaging.SingleEmailMessage singleEmail = Messaging.renderStoredEmailTemplate(et.Id,null
                    , (String.isNotEmpty(userReg.Id) ? userReg.Id : null));
            mail.htmlBody=String.isNotEmpty(singleEmail.htmlBody) ? singleEmail.htmlBody : formatPlainBody(singleEmail.plainTextBody);
            mail.subject = singleEmail.subject;

            mail.setWhatId(userReg.Id);
            mail.setSaveAsActivity(true);
            mails.add(mail);
            System.debug('**************mail*************  '+mail);

        }
        System.debug('**************mails ALL*************  '+mails);
        Messaging.sendEmail(mails);
    }

    /***********************************************
    * Method Name : formatPlainBody
    * Author : Pankaj
    * Inputs : String plainBody
    * Description: This method return string with relpace \n with <br/>
    *********************************************/
    @TestVisible 
    private static String formatPlainBody(String plainBody) {
        if (String.isEmpty(plainBody)) return '';
        return plainBody.replace('\n', '<br/>');
    }

    /***********************************************
    * Method Name : addMembersToContacts
    * Author : Pankaj
    * Inputs : Map<Id, Set<Id>> userIdsByAppId
    * Description: This method adding hospital account to County and Region users Related Accounts list
    *********************************************/
    public void addMembersToContacts(Map<Id, Set<Id>> userIdsByAppId) {

        Set<Id> userIds = new Set<Id>();
        for (Id appId : userIdsByAppId.keySet()) {
             userIds.addAll(userIdsByAppId.get(appId));
        }

        if(userIds.size() == 0) return;
        Boolean isCountyUser = false; 
        Map<Id, Set<Id>> parentAccountToChildAccountMap = new Map<Id, Set<Id>>();
        Set<Id> allParentAccountIds = new Set<Id>();
        Set<Id> allParentToChildAccountIds = new Set<Id>();
        Map<String,String> userQueueMap = new Map<String,String>();
        Set<Id> countyUserIdSet = new Set<Id>();
        Set<Id> countyContactIdSet = new Set<Id>();//added
        for(User u : [SELECT Id, ContactId,  AccountId, Account.ParentId, Account.Parent.ParentId,
                      Account.Entity_Type__c,Account.Queue_Name__c FROM User  WHERE Id IN : userIds]) {
            // This if for in case user is county
            if(u.Account.Entity_Type__c == 'County'){
                allParentToChildAccountIds.add(u.AccountId); 
                userQueueMap.put(u.Account.Queue_Name__c,u.Id); 
                isCountyUser = true;
                countyUserIdSet.add(u.Id);
                countyContactIdSet.add(u.ContactId); //added
            }          
            if(u.AccountId != null) {
                allParentAccountIds.add(u.AccountId); 
            }
            if(u.Account.ParentId != null) {
                if(parentAccountToChildAccountMap.get(u.Account.ParentId) == null) {
                    parentAccountToChildAccountMap.put(u.Account.ParentId, new Set<Id>());
                }
                parentAccountToChildAccountMap.get(u.Account.ParentId).add(u.AccountId);
                allParentAccountIds.add(u.Account.ParentId);
            }
            if(u.Account.Parent.ParentId != null) {
                if(parentAccountToChildAccountMap.get(u.Account.Parent.ParentId) == null) {
                    parentAccountToChildAccountMap.put(u.Account.Parent.ParentId, new Set<Id>());
                }
                parentAccountToChildAccountMap.get(u.Account.Parent.ParentId).add(u.AccountId);
                allParentAccountIds.add(u.Account.Parent.ParentId);
            }
        } 
        if(isCountyUser){// New user is County, create ACR with Heath care user
            //addCountyMembersToCountyChildAccount(allParentToChildAccountIds,userQueueMap,parentAccountToChildAccountMap,allParentAccountIds,countyUserIdSet,countyContactIdSet);
        }else if(parentAccountToChildAccountMap.keySet().size() > 0){// New user is Health care user, create ACR for Region and County
            //addContactWithMultipleAccount(allParentAccountIds,parentAccountToChildAccountMap);
        }
    }

    /***********************************************
    * Method Name : addCountyMembersToCountyChildAccount
    * Author : Pankaj
    * Inputs : Set<Id> allParentToChildAccountIds,Map<String,String> userQueueMap,Map<Id, Set<Id>> parentAccountToChildAccountMap,Set<Id> allParentAccountIds,Set<Id> countyUserIdSet,Set<Id> countyContactIdSet
    * Description: This method is used for new user is county, create user relationship with the County Child Account to view the orders
    *********************************************/
    /*public void addCountyMembersToCountyChildAccount(Set<Id> allParentToChildAccountIds,Map<String,String> userQueueMap,Map<Id, Set<Id>> parentAccountToChildAccountMap,Set<Id> allParentAccountIds,Set<Id> countyUserIdSet,Set<Id> countyContactIdSet) { //added countyContactIdSet
   
        if(allParentToChildAccountIds.size() > 0){
            for(Account ac : [SELECT Id,Name, Entity_Type__c, ParentId FROM Account  WHERE ParentId IN : allParentToChildAccountIds]){
                if(ac.Id != null) {
                    if(parentAccountToChildAccountMap.get(ac.ParentId) == null) {
                        parentAccountToChildAccountMap.put(ac.ParentId, new Set<Id>());
                    }
                    parentAccountToChildAccountMap.get(ac.ParentId).add(ac.Id);
                    allParentAccountIds.add(ac.Id);
                }
            }
            if(userQueueMap.size() > 0){ 
                //addMemberToQueue(userQueueMap);
            }
            if(parentAccountToChildAccountMap.keySet().size() > 0 ){
                //addContactWithMultipleAccountForCounty(allParentAccountIds,parentAccountToChildAccountMap,countyContactIdSet);//call New function
                
            }
            if(countyUserIdSet.size() > 0){
                //assignPermissionSetToCounty(countyUserIdSet);
            }
       }
    }*/

    /***********************************************
    * Method Name : addContactWithMultipleAccount
    * Author : Pankaj
    * Inputs : Set<Id> allParentAccountIds,Map<Id, Set<Id>> parentAccountToChildAccountMap
    * Description: This method create ACR for contact with multiple Accounts
    *********************************************/
    /*public void addContactWithMultipleAccount(Set<Id> allParentAccountIds,Map<Id, Set<Id>> parentAccountToChildAccountMap ){
        Map<Id, Set<Id>> contactIdWithAccountIds = new Map<Id, Set<Id>>();
        for(AccountContactRelation accountContactRelation : [SELECT AccountId, ContactId ,Id FROM AccountContactRelation
                                                        WHERE AccountId IN : allParentAccountIds]) {
            if(contactIdWithAccountIds.get(accountContactRelation.ContactId) == null) {
                contactIdWithAccountIds.put(accountContactRelation.ContactId, new Set<Id>());
            }
            contactIdWithAccountIds.get(accountContactRelation.ContactId).add(accountContactRelation.AccountId);
        }
        List<AccountContactRelation> accountContactList = new List<AccountContactRelation>();
        for(Contact con : [SELECT Id,Name, AccountId, Account.Name  FROM Contact
                                            WHERE AccountId IN : parentAccountToChildAccountMap.keySet()]) {
            Set<Id> accountIdsToAdd = parentAccountToChildAccountMap.get(con.AccountId);
            if(accountIdsToAdd == null) continue;

            Set<Id> existingAccounts = contactIdWithAccountIds.get(con.Id);
            for (Id accountId : accountIdsToAdd) {
                if(existingAccounts.isEmpty() == false && existingAccounts.contains(accountId) == false) {
                    AccountContactRelation acr = new AccountContactRelation();
                    acr.AccountId = accountId;
                    acr.ContactId = con.Id;
                    accountContactList.add(acr);
                }
            }
        }
        if(accountContactList.size() > 0){
            insert accountContactList;
        }
    }*/

    /***********************************************
    * Method Name : addMemberToQueue
    * Author : Pankaj
    * Inputs : Map<String,String> userQueueMap
    * Description: This method add new county user in County Queue
    *********************************************/
    /*@future
    public static void addMemberToQueue(Map<String,String> userQueueMap)
    {
        Group countyQueueGroup =[SELECT Id,Name FROM Group WHERE Type = 'Queue' AND Name IN : userQueueMap.keySet() LIMIT 1];
        if(countyQueueGroup.Id != null){
        GroupMember member = new GroupMember();
                    member.UserOrGroupId = userQueueMap.get(countyQueueGroup.Name);
                    member.GroupId =countyQueueGroup.Id;
                    Insert member;        
        }
    }*/

    /***********************************************
    * Method Name : shareUsersForChatter
    * Author : Pankaj
    * Inputs : Set<Id> userIds
    * Description: This method share region users with county users & share county users with Healthcare Facility Users
    *********************************************/
       private static void shareUsersForChatter(Set<Id> userIds) {
        Map<Id, Id> userIdToParentAccId = new Map<Id, Id>();
        Map<Id, Set<Id>> parentAccIdToAllUsers = new Map<Id, Set<Id>>();
        List<UserShare> userShareList = new List<UserShare>();
        for(User usr : [Select Id,Account.Entity_Type__c,Account.ParentId from User where Id IN : userIds AND IsActive = true]) {
            userIdToParentAccId.put(usr.Id, usr.Account.ParentId);
        }
        for(User usr : [Select Id,AccountId from User where AccountId IN : userIdToParentAccId.values() AND IsActive = true]) {
            if(parentAccIdToAllUsers.get(usr.AccountId) == null) {
                parentAccIdToAllUsers.put(usr.AccountId, new Set<Id>());
            }
            parentAccIdToAllUsers.get(usr.AccountId).add(usr.Id);
        }
        for(Id userToAccessId : userIdToParentAccId.keySet()) {
            for(Set<Id> usrIds : parentAccIdToAllUsers.values()) {
                for(Id usrId : usrIds) {
                    UserShare userShareRecord = new UserShare();
                    userShareRecord.RowCause = 'Manual';
                    userShareRecord.UserAccessLevel = 'Read';
                    userShareRecord.UserId  = usrId;
                    userShareRecord.UserOrGroupId  = userToAccessId;
                    userShareList.add(userShareRecord);
                }
            }
        }
        insert userShareList;
    }

    /***********************************************
    * Method Name : assignPermissionSetToCounty
    * Author : Pankaj
    * Inputs : Set<Id> countyUserIdSet
    * Description: This method assign user registration permission set to County user
    *********************************************/
    // Assign user registration permission set to County user
    /*@future
    public static void assignPermissionSetToCounty(Set<Id> countyUserIdSet)
    {
        PermissionSet permissionSet = [SELECT Id,Name FROM PermissionSet WHERE Name = 'User_Registration_Permission' LIMIT 1];
        Set<Id> userAssignIdSet = new Set<Id>();
        if(String.isNotEmpty(permissionset.Id) && countyUserIdSet.size() > 0){
            for(PermissionSetAssignment psa : [SELECT Id,PermissionSetId,AssigneeId FROM PermissionSetAssignment WHERE PermissionSetId =: permissionSet.Id]){
                userAssignIdSet.add(psa.AssigneeId);
            }
            List<PermissionSetAssignment> permissionSetList = new List<PermissionSetAssignment>();
            for (Id userId : countyUserIdSet){ 
                if(userAssignIdSet.contains(userId) == false){
                    PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = permissionSet.Id, AssigneeId = userId);
                    permissionSetList.add(psa);
                }    
            }
            insert permissionSetList;
        }
    }*/

    /***********************************************
    * Method Name : addContactWithMultipleAccountForCounty
    * Author : Pankaj
    * Inputs : Set<Id> allParentAccountIds,Map<Id, Set<Id>> parentAccountToChildAccountMap,Set<Id> countyContactIdSet 
    * Description: This method create ACR for contact with multiple Account For County New User only
    *********************************************/
    /*public void addContactWithMultipleAccountForCounty(Set<Id> allParentAccountIds,Map<Id, Set<Id>> parentAccountToChildAccountMap,Set<Id> countyContactIdSet ){
        Map<Id, Set<Id>> contactIdWithAccountIds = new Map<Id, Set<Id>>();
        for(AccountContactRelation accountContactRelation : [SELECT AccountId, ContactId ,Id FROM AccountContactRelation
                                                        WHERE AccountId IN : allParentAccountIds]) {
            if(contactIdWithAccountIds.get(accountContactRelation.ContactId) == null) {
                contactIdWithAccountIds.put(accountContactRelation.ContactId, new Set<Id>());
            }
            contactIdWithAccountIds.get(accountContactRelation.ContactId).add(accountContactRelation.AccountId);
        }
        List<AccountContactRelation> accountContactList = new List<AccountContactRelation>();
        for(Contact con : [SELECT Id,Name, AccountId, Account.Name  FROM Contact
                                            WHERE Id IN :countyContactIdSet]) {
            Set<Id> accountIdsToAdd = parentAccountToChildAccountMap.get(con.AccountId);
            if(accountIdsToAdd == null) continue;

            Set<Id> existingAccounts = contactIdWithAccountIds.get(con.Id);
            for (Id accountId : accountIdsToAdd) {
                if(existingAccounts.isEmpty() == false && existingAccounts.contains(accountId) == false) {
                    AccountContactRelation acr = new AccountContactRelation();
                    acr.AccountId = accountId;
                    acr.ContactId = con.Id;
                    accountContactList.add(acr);
                }
            }
        }
        if(accountContactList.size() > 0){
            insert accountContactList;
        }
    }*/

    /***********************************************
    * Method Name : sendApprovalEmail
    * Author : Pankaj
    * Inputs : List<User_Registration__c> userRegList
    * Description: This method send an approval email when the user registration is approved
    *********************************************/
    public static void sendApprovalEmail(List<User_Registration__c> userRegList) {
        List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>();
        List<String> toAddresses = new List<String>();

        String fromAddr = KeyValueHelper.getTextValue('PHOS_From_Email_Addresses');
        List<OrgWideEmailAddress> fromAddresses = new List<OrgWideEmailAddress>();
        Id OrgWideEmailAddressId;
        if(String.isNotBlank(fromAddr)){
            fromAddresses =  [Select Id from OrgWideEmailAddress where DisplayName=: fromAddr];
        }
        if(fromAddresses.size()>0){
            OrgWideEmailAddressId = fromAddresses[0].Id;
        }
        for (User_Registration__c userReg : userRegList) {
            toAddresses.add(userReg.Email__c);
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(toAddresses);
            mail.setOrgWideEmailAddressId(OrgWideEmailAddressId);
            EmailTemplate et = [SELECT id FROM EmailTemplate WHERE developerName = 'PHOS_UserRegistration_Approval'];

            Messaging.SingleEmailMessage singleEmail = Messaging.renderStoredEmailTemplate(et.Id,null
                    , (String.isNotEmpty(userReg.Id) ? userReg.Id : null));
            mail.htmlBody=String.isNotEmpty(singleEmail.htmlBody) ? singleEmail.htmlBody : formatPlainBody(singleEmail.plainTextBody);
            mail.subject = singleEmail.subject;

            mail.setWhatId(userReg.Id);
            mail.setSaveAsActivity(true);
            mails.add(mail);
            System.debug('**************mail*************  '+mail);

        }
        System.debug('**************mails ALL*************  '+mails);
        Messaging.sendEmail(mails);
    }
}