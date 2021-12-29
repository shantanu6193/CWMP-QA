/***********************************************************************************************************************************
* Class Name   : MARS_UserServiceAppHandler
* Description  : This class for MARS user serive app handler 
* Author       : Sravan Reddy Pinninti
* Created On   : 03/14/2021
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Sravan               03/14/2021      Initial Implementation
**************************************************************************************************************************************/


public without sharing class MARS_UserServiceAppHandler implements UserServiceAppHandler{
   
   public static void processRecords(map<Id,User_Registration__c> newMap, map<Id,User_Registration__c> oldMap ){
        list<User_Registration__c> approvedAppAccess = new list<User_Registration__c>();
        list<User_Registration__c> rejectedAppAccess = new list<User_Registration__c>();

        list<User_Registration__c> approvednewAgencyAccess = new list<User_Registration__c>();
        list<User_Registration__c> rejectednewAgencyAccess = new list<User_Registration__c>();

        list<User_Registration__c> approvedchangeAgencyAccessLevel = new list<User_Registration__c>();
        list<User_Registration__c> rejectedchangeAgencyAccessLevel = new list<User_Registration__c>();


        User_Registration__c oldR;
        for(User_Registration__c ur: newmap.Values()){
            oldR = oldMap.get(ur.Id);
            if(oldR.Status__c != ur.Status__c && 
               oldR.Status__c == 'App Requested' && ur.Status__c == 'App Approved'){
                approvedAppAccess.add(ur); //App request is approved
            }
            if(oldR.Status__c != ur.Status__c && 
               oldR.Status__c == 'App Requested' && ur.Status__c == 'App Rejected'){
                rejectedAppAccess.add(ur); //App request rejected
            }
            if(oldR.Status__c != ur.Status__c && 
               oldR.Status__c == 'Additional Agency Requested' && ur.Status__c == 'Additional Agency Approved'){
                approvednewAgencyAccess.add(ur); //New Agency request approved
            }
            if(oldR.Status__c != ur.Status__c && 
               oldR.Status__c == 'Additional Agency Requested' && ur.Status__c == 'Additional Agency Rejected'){
                rejectednewAgencyAccess.add(ur); //New Agency request rejected
            }
            if(oldR.Status__c != ur.Status__c && 
               oldR.Status__c == 'Access Level Change Requested' && ur.Status__c == 'Access Level Change Approved'){
                approvedchangeAgencyAccessLevel.add(ur); //Access Level change request approved
            }
            if(oldR.Status__c != ur.Status__c && 
               oldR.Status__c == 'Access Level Change Requested' && ur.Status__c == 'Access Level Change Rejected'){
                rejectedchangeAgencyAccessLevel.add(ur); //Access Level change request rejected
            }
        }

        if(!approvedAppAccess.isEmpty()){
            handleApproveApp(approvedAppAccess);
        }
        /*if(!rejectedAppAccess.isEmpty()){
            sendEmail(rejectedAppAccess, 'MARS_App_Access_Rejected');
        }*/
        if(!approvednewAgencyAccess.isEmpty()){
            handleApproveAccessLevelChange(approvednewAgencyAccess);
            //sendEmail(approvednewAgencyAccess, 'MARS_New_Agency_Approved');
        }
        if(!rejectednewAgencyAccess.isEmpty()){
            //sendEmail(rejectednewAgencyAccess, 'MARS_New_Agency_Rejected');
        }
        if(!approvedchangeAgencyAccessLevel.isEmpty()){
            handleApproveAccessLevelChange(approvedchangeAgencyAccessLevel);
            //sendEmail(approvedchangeAgencyAccessLevel, 'MARS_Access_Level_Change_Approved');
        }
        if(!rejectedchangeAgencyAccessLevel.isEmpty()){
            //sendEmail(rejectedchangeAgencyAccessLevel, 'MARS_Access_Level_Change_Rejected');

        }
   }
   
   
    /***********************************************
    * Method Name : handleApproveApp
    * Author : Sravan Reddy Pinninti
    * Inputs : List<User_Registration__c> userRegistrations
    * Description: This method handle user registration approval
    *********************************************/
    public static void handleApproveApp(List<User_Registration__c> userRegistrations) {
        list<Community_Application_to_User__c> addApptoUser = new list<Community_Application_to_User__c>();
        string appId = [SELECT Id FROM Community_Application__c WHERE Name='MARS' LIMIT 1].Id;
        Community_Application_to_User__c app;
        for(User_Registration__c ureg: userRegistrations){
            app = new Community_Application_to_User__c();
            app.Contact__c = ureg.Contact_Name__c;
            app.User__c = ureg.User__c;
            app.isActive__c = true;
            app.Community_Application__c = appId;
            addApptoUser.add(app);
        }

        insert addApptoUser;
        handleApproveAccessLevelChange(userRegistrations);
        
    }


    /***********************************************
    * Method Name : handleApproveAccessLevelChange
    * Author : Sravan Reddy Pinninti
    * Inputs : List<User_Registration__c> userRegistrations
    * Description: This method handle user registration approval for access level change within the same account
    *********************************************/
    public static void handleApproveAccessLevelChange(List<User_Registration__c> userRegistrations) {
        list<AccountContactRelation> upsertAccessLevel = new list<AccountContactRelation>();
        set<string> accountIds = new set<string>(); //for Fire Agency
        set<string> payingEntityaccIds = new set<string>(); //for paying entity accIds
        set<string> contactIds = new set<string>();
        set<string> primaryAccessKey = new set<string>();
        set<string> secondaryAccessKey = new set<string>();
        set<string> allKeys = new set<string>(); //for fire agency
        set<string> keysForPayingEntity = new set<string>(); //for paying entity
       


        for(User_Registration__c ureg: userRegistrations){
            accountIds.add(ureg.Fire_Agency__c);
            payingEntityaccIds.add(ureg.MARS_Paying_Entity__c);
            contactIds.add(ureg.Contact_Name__c);
            if(string.isNotBlank(ureg.Fire_Agency__c)){ //only for Fire Agencies
                string key = ureg.Fire_Agency__c+'~'+ureg.Contact_Name__c;
                allKeys.add(key);
                if(ureg.Access_Level__c == 'Primary'){
                    primaryAccessKey.add(key);
                }else{
                    secondaryAccessKey.add(key);
                }
            }

            if(string.isNotBlank(ureg.MARS_Paying_Entity__c)){//for paying entities
                keysForPayingEntity.add(ureg.MARS_Paying_Entity__c+'~'+ureg.Contact_Name__c);
            }
            
        }

        if(!accountIds.isEmpty()){ //for fire agencies
            for(AccountContactRelation acr: [SELECT Id, ContactId, AccountId, isActive, RelationShip_Strength__c
                                            FROM AccountContactRelation
                                            WHERE ContactId IN: contactIds
                                            AND AccountId IN: accountIds]){
                string key = acr.AccountId + '~'+acr.ContactId;
                if(!allKeys.contains(key)){
                    continue;
                }
                if(primaryAccessKey.contains(key)){
                    if(acr.RelationShip_Strength__c != 'Primary'){
                        acr.RelationShip_Strength__c = 'Primary';
                        acr.isActive = true;
                        upsertAccessLevel.add(acr);
                        allKeys.remove(key);
                    }
                }
                if(secondaryAccessKey.contains(key)){
                    if(acr.RelationShip_Strength__c != 'Secondary'){
                        acr.RelationShip_Strength__c = 'Secondary';
                        acr.isActive = true;
                        upsertAccessLevel.add(acr);
                        allKeys.remove(key);
                    }
                }
            }

            AccountContactRelation ac;
            for(string s: allKeys){
                string accountId = s.SubstringBeforeLast('~');
                string contactId = s.SubstringAfterLast('~');
                ac = new AccountContactRelation();
                ac.AccountId = accountId;
                ac.ContactId = contactId;
                ac.Relationship_Strength__c = primaryAccessKey.contains(s) ? 'Primary' : 'Secondary';
                ac.isActive = true;
                upsertAccessLevel.add(ac);

            }
        }

        if(!payingEntityaccIds.isEmpty()){
            for(AccountContactRelation acr: [SELECT Id, ContactId, AccountId, isActive, RelationShip_Strength__c
                                            FROM AccountContactRelation
                                            WHERE ContactId IN: contactIds
                                            AND AccountId IN: payingEntityaccIds]){
                string key = acr.AccountId + '~'+acr.ContactId;
                if(!keysForPayingEntity.contains(key)){
                    continue;
                }
    
                if(acr.RelationShip_Strength__c != 'Primary'){
                    acr.RelationShip_Strength__c = 'Primary';
                    acr.isActive = true;
                    upsertAccessLevel.add(acr);
                    keysForPayingEntity.remove(key);
                }

                AccountContactRelation ac;
                for(string s: keysForPayingEntity){
                    string accountId = s.SubstringBeforeLast('~');
                    string contactId = s.SubstringAfterLast('~');
                    ac = new AccountContactRelation();
                    ac.AccountId = accountId;
                    ac.ContactId = contactId;
                    ac.Relationship_Strength__c = 'Primary';
                    ac.isActive = true;
                    upsertAccessLevel.add(ac);
                }
            }
        }

        upsert upsertAccessLevel;
    }

    /***********************************************
    * Method Name : handleReject
    * Author : Sravan Reddy Pinninti
    * Inputs : List<User_Registration__c> userRegistrations
    * Description: This method call sendRejectionEmail method
    *********************************************/
    public void handleReject(List<User_Registration__c> userRegistrations) {
    
    }

    /***********************************************
    * Method Name : handleApprove
    * Author : Sravan Reddy Pinninti
    * Inputs : List<User_Registration__c> userRegistrations
    * Description: This method call handleApprove Logic
    *********************************************/
    public void handleApprove(List<User_Registration__c> userRegistrations) {
    
    }

    /***********************************************
    * Method Name : sendRejectionEmail
    * Author : Sravan Reddy Pinninti
    * Inputs : List<User_Registration__c> userRegList
    * Description: This method send user approval request rejection email
    *********************************************/
    public static void sendRejectionEmail(List<User_Registration__c> userRegList) {

    }

    /***********************************************
    * Method Name : sendApprovalEmail
    * Author : Sravan Reddy Pinninti
    * Inputs : List<User_Registration__c> userRegList
    * Description: This method send an approval email when the user registration is approved
    *********************************************/
    public static void sendEmail(List<User_Registration__c> userRegList, string templateName) {
        List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>();
        List<String> toAddresses = new List<String>();
        String fromAddr = KeyValueHelper.getTextValue('MARS_From_Email_Addresses');
        List<OrgWideEmailAddress> fromAddresses = new List<OrgWideEmailAddress>();
        Id OrgWideEmailAddressId;
        if(String.isNotBlank(fromAddr)){
            fromAddresses =  [Select Id from OrgWideEmailAddress where DisplayName=: fromAddr];
        }
        if(fromAddresses.size()>0){
            OrgWideEmailAddressId = fromAddresses[0].Id;
        }
        EmailTemplate et = [SELECT id FROM EmailTemplate WHERE developerName = :templateName];
        
        for (User_Registration__c userReg : userRegList) {
            toAddresses.add(userReg.Email__c);
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTargetObjectId(UserReg.User__c); //these emails are not counted against daily limits by salesforce
            mail.setOrgWideEmailAddressId(OrgWideEmailAddressId);
            Messaging.SingleEmailMessage singleEmail = Messaging.renderStoredEmailTemplate(et.Id,null
                    , (String.isNotEmpty(userReg.Id) ? userReg.Id : null));
            mail.htmlBody=String.isNotEmpty(singleEmail.htmlBody) ? singleEmail.htmlBody : formatPlainBody(singleEmail.plainTextBody);
            mail.subject = singleEmail.subject;
            mail.setWhatId(userReg.Id);
            mail.setSaveAsActivity(false);
            mails.add(mail);
        }
        
        Messaging.sendEmail(mails);
    }

    /***********************************************
    * Method Name : formatPlainBody
    * Author : Sravan Reddy Pinninti
    * Inputs : String plainBody
    * Description: This method return string with relpace \n with <br/>
    *********************************************/
    @TestVisible 
    private static String formatPlainBody(String plainBody) {
        if (String.isEmpty(plainBody)){
            return '';
        } 
        return plainBody.replace('\n', '<br/>');
    }
}