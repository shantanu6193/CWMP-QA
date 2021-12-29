/***********************************************************************************************************************************
* Class Name   : UserRegistrationHelper
* Description  : This is helper class for user registration trigger
* Author       : Pankaj
* Created On   : 06/21/2020
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Pankaj                06/21/2020       Initial Implementation
**************************************************************************************************************************************/

public without sharing class UserRegistrationHelper  extends TriggerHelper {
    
    /***********************************************
    * Method Name : processAfterUpdate
    * Author : Pankaj
    * Inputs : -
    * Description: This method call after records are updated, create community user and add user to app
    *********************************************/
    public override void   processAfterUpdate() {
        //todo - remove below logic once PHOS signup moved to common registration
        List<User_Registration__c> userRegList = new List<User_Registration__c>();
        List<User_Registration__c> userRegListRejection = new List<User_Registration__c>();
        string MARS_RECORDTYPE =  Schema.SObjectType.User_Registration__c.getRecordTypeInfosByDeveloperName().get('MARS').getRecordTypeId();
        string HH_RECORDTYPE =  Schema.SObjectType.User_Registration__c.getRecordTypeInfosByDeveloperName().get('HH_Registration').getRecordTypeId();
        map<Id, User_Registration__c> marsnewMap = new map<Id,User_Registration__c>();
        map<Id, User_Registration__c> marsOldMap = new map<Id,User_Registration__c>();

        for(User_Registration__c userReg : (List<User_Registration__c>)Trigger.new) {
            User_Registration__c oldUserReg = (User_Registration__c)Trigger.oldMap.get(userReg.Id);
            if(oldUserReg.Status__c != userReg.Status__c && userReg.Status__c == 'Approved'){
                userRegList.add(userReg);
            }
            if(oldUserReg.Status__c != userReg.Status__c && userReg.Status__c == 'Rejected'){
                userRegListRejection.add(userReg);
            }
        }
        if(!userRegList.isEmpty()){
           // createContactAndUser(userRegList);
        }
        if(!userRegListRejection.isEmpty()){
            sendRejectionEmail(userRegListRejection);
        }
        // this is as per new approach
        List<User_Registration__c> userRegListToCreateUser = new List<User_Registration__c>();
        List<User_Registration__c> userRegListAppProcessing = new List<User_Registration__c>();
        for(User_Registration__c userReg : (List<User_Registration__c>)Trigger.new) {
            User_Registration__c oldUserReg = (User_Registration__c)Trigger.oldMap.get(userReg.Id);
            if(oldUserReg.Status__c != userReg.Status__c && userReg.Status__c == CONSTANTS.USER_REGISTRATION_STATUS_VERIFIED) {
                userRegListToCreateUser.add(userReg);
            }

            //Sravan - Ensuring MARS records are not processed through regular channel
            if(oldUserReg.Status__c != userReg.Status__c && userReg.RecordtypeId != MARS_RECORDTYPE &&
                    (userReg.Status__c == CONSTANTS.USER_REGISTRATION_STATUS_APP_APPROVED
                            || userReg.Status__c == CONSTANTS.USER_REGISTRATION_STATUS_APP_REJECTED)) {
                userRegListAppProcessing.add(userReg);
            }

             //Shantanu - Ensuring HH records are not processed through regular channel
             if(oldUserReg.Status__c != userReg.Status__c && userReg.RecordtypeId != HH_RECORDTYPE &&
             (userReg.Status__c == CONSTANTS.USER_REGISTRATION_STATUS_APP_APPROVED
                     || userReg.Status__c == CONSTANTS.USER_REGISTRATION_STATUS_APP_REJECTED)) {
                    userRegListAppProcessing.add(userReg);
            } 
            
            if(userReg.RecordtypeId == MARS_RECORDTYPE){ //handle MARS Application logic
                marsnewMap.put(userReg.id, userReg);
                marsoldMap.put(userReg.id, oldUserReg);
            }
        }
        if(!userRegListToCreateUser.isEmpty()) {
            UserService.createCommunityStandardUser(userRegListToCreateUser);
        }
        if(!userRegListAppProcessing.isEmpty()) {
            UserService.addUsersToApp(userRegListAppProcessing);
        }
        if(!marsnewMap.KeySet().isEmpty()){
            MARS_UserServiceAppHandler.processRecords(marsnewMap, marsoldMap);
        }
    }

    /***********************************************
    * Method Name : createContactAndUser
    * Author : Pankaj
    * Inputs : List<User_Registration__c> userRegList
    * Description: This method create contact and user records
    *********************************************/
    /*
    //todo - delete method once PHOS signup moved to common registration
    public static void createContactAndUser(List<User_Registration__c> userRegList){
        List<String> accountNames = new List<String>();
        List<String> nonGovAccountNames = new List<String>();
        Map<String, Account> accountByName = new Map<String, Account>();
        Map<String, Account> nonGovAccountByName = new Map<String, Account>();
        Map<String, String> mapOfNonGovNameToFederalId= new Map<String, String>();
        for(User_Registration__c userReg : userRegList) {
            if(String.isNotEmpty(userReg.County__c)) {
                accountNames.add(userReg.County__c);
            }
            if(String.isNotEmpty(userReg.Non_Governmental_Entity__c)) {
                nonGovAccountNames.add(userReg.Non_Governmental_Entity__c);
				if(String.isNotEmpty(userReg.Federal_Tax_ID__c)) {
					mapOfNonGovNameToFederalId.put(userReg.Non_Governmental_Entity__c, userReg.Federal_Tax_ID__c);
				}
            }
        }

        if (accountNames.size() > 0) {
            List<Account> accounts = [SELECT Id,Name FROM Account WHERE Name IN :accountNames AND Entity_Type__c='County'];
            for (Account account : accounts) {
                accountByName.put(account.Name, account);
            }
        }
        if (nonGovAccountNames.size() > 0) {
            List<Account> accList = new List<Account>();
            List<Account> accounts = [SELECT Id,Name,ParentId,Federal_Tax_ID__c,Entity_Type__c FROM Account WHERE Federal_Tax_ID__c IN :mapOfNonGovNameToFederalId.values()];
            for (Account account : accounts) {
                nonGovAccountByName.put(account.Federal_Tax_ID__c, account);
            }
            System.debug('nonGovAccountByName-----'+nonGovAccountByName);
            String sopAccountName = KeyValueHelper.getTextValue('SOC_OPS_Non_Government_Parent_Name');
            String accountOwnerId = KeyValueHelper.getTextValue('SOC_OPS_Non_GovernmentOwnerId');
            List<Account> accountList = [SELECT Id FROM Account WHERE  Name =: sopAccountName];
            if(accounts.isEmpty()){
                if(String.isNotEmpty(sopAccountName)){
                    System.debug('sopAccountName-----'+sopAccountName);
                    for(String accName : nonGovAccountNames){
                        Account acc = new Account();
                        acc.Name  = accName;
                        if(accountList.size() > 0) {
                            acc.ParentId = accountList.get(0).Id;
                        }
                        acc.OwnerId = accountOwnerId;
                        acc.Entity_Type__c = 'Non-Governmental Entity';
                        acc.Federal_Tax_ID__c = mapOfNonGovNameToFederalId.get(accName);
                        accList.add(acc);
                    }
                    System.debug('accList-----'+accList);
                }
                insert accList;
                for(Account acc : accList){
                    nonGovAccountByName.put(acc.Federal_Tax_ID__c, acc);
                }
            }
            else{
                List<Account> updateList = new List<Account>();
                for(Account acc : accounts) {
                    if(acc.ParentId == null) {
                        acc.ParentId = accountList.get(0).Id; 
                    }
                    acc.Entity_Type__c = 'Non-Governmental Entity';
                    updateList.add(acc);
                }
                if(!updateList.isEmpty()){
                    update updateList;
                }
            }
        }
        List<Contact> contactList = new List<Contact>();
        List<Contact> getContactList = new List<Contact>();
        List<User_Registration__c> getUserRegistrationList = new List<User_Registration__c>();
        set<String> uniqueEmailId = new set<String>();
        for(User_Registration__c userReg : userRegList){
            uniqueEmailId.add(userReg.Email__c);
        }
        System.debug('Unique Emails Id Set==='+uniqueEmailId);
        getContactList = [select FirstName, LastName, Email, Phone, AccountId from Contact where  Email In: uniqueEmailId];
        getUserRegistrationList = [SELECT Address_County__c, Approval_Comments__c, City_Name__c, City__c, Community_Application__c, Contact_Name__c, Contact__c, County__c, Courts__c, Email__c, Entity_Type__c, Facility_ID__c, Facility_Name__c, Facility__c, Federal_Tax_ID__c, First_Name__c, Id, Last_Name__c, Name, Non_Governmental_Entity__c, Non_Government_Entity_Type__c, Phone__c, RecordTypeId, Rejection_Comments__c, Rejection_Reason__c, Special_District__c, State_Agency__c, State__c, Status__c, Street_Address__c, SystemModstamp, Token__c, Tribal__c, User__c, Zip_Postal_Code__c, Title__c from User_Registration__c where Email__c In: uniqueEmailId];
        Map<String, Contact> mapEmailContacts = new Map<String, Contact>();
        System.debug('getContactList==='+getContactList);
        if( getContactList.size() > 0){
            for(Contact con : getContactList){
                mapEmailContacts.put(con.Email, con);
            }
             System.debug('mapEmailContacts==='+mapEmailContacts);
            // check email id is matach in user or not 
            for(User_Registration__c userRegistration : getUserRegistrationList){
                System.debug('Email Val.....'+userRegistration.Email__c);
                if(mapEmailContacts.get(userRegistration.Email__c) != null){
                    System.debug('Entered Existing Contact Block.....');
                }else{
                     System.debug('Entered New Contact Block.....');
                     Contact c = new Contact();
                    c.FirstName = userRegistration.First_Name__c;
                    c.LastName = userRegistration.Last_Name__c;
                    c.Email = userRegistration.Email__c;
                    c.Phone = userRegistration.Phone__c;
                    c.Title = userRegistration.Title__c;
                    if(userRegistration.Entity_Type__c == 'County' && String.isNotBlank(userRegistration.County__c)){
                        c.AccountId = accountByName.get(userRegistration.County__c).Id;
                    }else if(userRegistration.State_Agency__c != null){
                        c.AccountId = userRegistration.State_Agency__c;
                    }else if(String.isNotBlank(userRegistration.Federal_Tax_ID__c)){
                        c.AccountId = nonGovAccountByName.get(userRegistration.Federal_Tax_ID__c).Id;
                    }
                    contactList.add(c);  
                }
            }
            if(!contactList.isEmpty()){
                Database.insert(contactList,false);               
            }
            //here it add the existing  contact in contact list
            contactList.addAll(getContactList);               
        }else{
             System.debug('Entered New Contact Block2.....');
            for(User_Registration__c userReg : userRegList){
                Contact c = new Contact();
                c.FirstName = userReg.First_Name__c;
                c.LastName = userReg.Last_Name__c;
                c.Email = userReg.Email__c;
                c.Phone = userReg.Phone__c;
                c.Title = userReg.Title__c;
                if(userReg.Entity_Type__c == 'County' && String.isNotBlank(userReg.County__c)){
                    c.AccountId = accountByName.get(userReg.County__c).Id;
                }else if(userReg.State_Agency__c != null){
                    c.AccountId = userReg.State_Agency__c;
                }else if(String.isNotBlank(userReg.Federal_Tax_ID__c)){
                    c.AccountId = nonGovAccountByName.get(userReg.Federal_Tax_ID__c).Id;
                }
                contactList.add(c);
            }
            if(!contactList.isEmpty()){
                Database.insert(contactList,true);
            }
        }
        //List<Contact> contactList = new List<Contact>();
        Map<String, Contact> mapOfEmailToContact = new Map<String, Contact>();
        Map<String, String> mapOfEmailToAccountName = new Map<String, String>();
        for(Contact con : contactList){
            mapOfEmailToContact.put(con.Email, con);
        }
        for(Contact con : [Select id,Name,Email,AccountId,Account.Name from Contact where ID IN :contactList]){
            mapOfEmailToAccountName.put(con.Email, con.Account.Name);
        }      
        Profile porfileName = [Select id, Name from Profile where Name = 'PHOS Customer Community Plus Login User' LIMIT 1];
        List<User> userList = new List<User>();
        for(User_Registration__c userReg : userRegList){
            if(mapOfEmailToContact.get(userReg.Email__c).Id != null){
                User u = new User();
                u.FirstName = String.isNotBlank(userReg.First_Name__c) ? userReg.First_Name__c : '';
                u.LastName = userReg.Last_Name__c;
                u.Username = userReg.Email__c;
                u.Phone = userReg.Phone__c;
                u.ContactId = mapOfEmailToContact.get(userReg.Email__c).Id;
                u.Email = userReg.Email__c;
                u.Username = userReg.Email__c;
                String communityNikName = String.isNotBlank(userReg.First_Name__c) ? userReg.First_Name__c : '' ;
                communityNikName = communityNikName + userReg.Last_Name__c;
                Double randomNum =math.random();
                communityNikName = communityNikName + String.valueOf(randomNum);

                Integer aliasIndex = communityNikName.length() > 8 ? 8 : communityNikName.length();
                u.Alias = communityNikName.substring(0, aliasIndex);
                Integer communityNikNameIndex = communityNikName.length() > 39 ? 39 : communityNikName.length();
                u.CommunityNickname = communityNikName.substring(0, communityNikNameIndex);
                u.LocaleSidKey = 'en_US';
                u.TimeZoneSidKey = 'GMT';
                u.ProfileID = porfileName.Id;
                u.LanguageLocaleKey = 'en_US';
                u.EmailEncodingKey = 'UTF-8';
                u.County__c = userReg.County__c;
                userList.add(u);
            }
        }
        if(!contactList.isEmpty()){
            Database.insert(userList,true);
        }
        //Update User on User Registration Object
        Map<String, User> mapOfEmailToUser = new Map<String, User>();
        for(User usr : userList){
            mapOfEmailToUser.put(usr.Email, usr);
        }
        List<User_Registration__c> userRegToUpdate = new List<User_Registration__c>();
        for(User_Registration__c userReg : userRegList){
            User_Registration__c req = new User_Registration__c();
            req.Id = userReg.Id;
            req.User__c = mapOfEmailToUser.get(userReg.Email__c).Id;
            userRegToUpdate.add(req);
        }
        if(!userRegToUpdate.isEmpty()){
            updateUserRegistration(JSON.serialize(userRegToUpdate));
        }
    } */

    /***********************************************
    * Method Name : updateUserRegistration
    * Author : Pankaj
    * Inputs : String userRegJSON
    * Description: This method update user registration records
    *********************************************/
    @future
    public static void updateUserRegistration(String userRegJSON) {
        List<User_Registration__c> userRegs = (List<User_Registration__c>)JSON.deserialize(userRegJSON, List<User_Registration__c>.class);
        update userRegs;
    }

    /***********************************************
    * Method Name : sendRejectionEmail
    * Author : Pankaj
    * Inputs : List<User_Registration__c> userRegList
    * Description: This method send email of user registration rejection
    *********************************************/
    public static void sendRejectionEmail(List<User_Registration__c> userRegList){
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
            if(userReg.Entity_Type__c == 'County'){
                et = [SELECT id FROM EmailTemplate WHERE developerName = 'CountyUser_RejectionEmailCounty'];
            }else if(userReg.Entity_Type__c == 'State Agency'){
                et = [SELECT id FROM EmailTemplate WHERE developerName = 'CountyUser_RejectionEmailStateAgency'];
            }else if(userReg.Entity_Type__c == 'Non-Governmental Entity'){
                et = [SELECT id FROM EmailTemplate WHERE developerName = 'CountyUser_RejectionEmailNonGov'];
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
    private static String formatPlainBody(String plainBody) {
        if (String.isEmpty(plainBody)) return '';
        return plainBody.replace('\n', '<br/>');
    }
}