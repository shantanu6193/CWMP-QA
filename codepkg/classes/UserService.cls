/***********************************************************************************************************************************
* Class Name   : UserService
* Description  : This class for user service
* Author       : Pankaj
* Created On   : 07/12/2020
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Pankaj                07/12/2020       Initial Implementation
**************************************************************************************************************************************/

public without sharing class UserService {

    /***********************************************
    * Method Name : createCommunityStandardUser
    * Author : Pankaj
    * Inputs : List<User_Registration__c> userRegList
    * Description: This method create community standard user
    *********************************************/
    public static void createCommunityStandardUser(List<User_Registration__c> userRegList) {
        List<String> accountNames = new List<String>();
        List<String> nonGovFederalIDs = new List<String>();
        List<String> facilityIds = new List<String>();
        Map<String, Account> accountByName = new Map<String, Account>();
        Map<String, Account> nonGovAccountByName = new Map<String, Account>();
        Map<String, String> mapOfFederalIdToNonGovName= new Map<String, String>();
        Map<String, Account> facilityIdToAcc = new Map<String, Account>();
        Map<String, String> mapOfFacilityIDToName = new Map<String, String>();
        Map<String, User_Registration__c> mapOfFederalIDToUserReg = new Map<String, User_Registration__c>();
        Map<String, User_Registration__c> mapOfFacilityToUserReg= new Map<String, User_Registration__c>();
        Set<Id> contactIDSet = new Set<Id>();

        /** Variables for Home Hardening User Registration. - Start */
        /** This collection is to store the Account names in "Unique Household Number-HOUSEHOLD", In order to search for existing Accounts. */
        List<String> hhAccountNameList = new List<String>();
        Map<String,User_Registration__c> hhAccNameToUserRegMap = new Map<String, User_Registration__c>();
        Map<String, Account> hhAccountByName = new Map<String, Account>();
        /** Variables for Home Hardening User Registration. - End */

        for(User_Registration__c usrReg : [SELECT Id, User__r.ContactId FROM User_Registration__c WHERE ID IN: userRegList]) {
            if(usrReg.User__r.ContactId != null) contactIDSet.add(usrReg.User__r.ContactId);
        }
        for(User_Registration__c userReg : userRegList) {
            if(String.isNotEmpty(userReg.County__c) && userReg.Non_Government_Entity_Type__c != 'Health Care Facility') {
                accountNames.add(userReg.County__c);
            }
            if(String.isNotEmpty(userReg.County__c) && userReg.Non_Government_Entity_Type__c == 'Health Care Facility') {
                mapOfFacilityToUserReg.put(userReg.Facility_ID__c, userReg);
                accountNames.add(userReg.County__c);
            }
            if(String.isNotEmpty(userReg.Non_Governmental_Entity__c) && userReg.Non_Government_Entity_Type__c == 'Other') {
                nonGovFederalIDs.add(userReg.Federal_Tax_ID__c);
                accountNames.add(userReg.County__c);
                mapOfFederalIDToUserReg.put(userReg.Federal_Tax_ID__c, userReg);
                if(String.isNotEmpty(userReg.Federal_Tax_ID__c)) {
                    mapOfFederalIdToNonGovName.put(userReg.Federal_Tax_ID__c,userReg.Non_Governmental_Entity__c);
                }
            }
            /** Change for HH Community User Registration. - Start */
            if (userReg.RecordTypeId == Schema.SObjectType.User_Registration__c.getRecordTypeInfosByDeveloperName().get(System.Label.HH_RecordType_API_Name_HH_Registration).getRecordTypeId()) {
                if (userReg.Unique_Household_Number__c != null) {
                    String hhAccountName;
                    hhAccountName = HH_CONSTANTS.Account_HOUSEHOLD_Name + '-' + userReg.Unique_Household_Number__c;
                    hhAccountNameList.add(hhAccountName);
                    System.debug('hhAccountName: '+hhAccountName);
                    //No need to have list of user Reg. pick only one 
                    if(!hhAccNameToUserRegMap.containsKey(hhAccountName)){
                        hhAccNameToUserRegMap.put(hhAccountName, userReg);
                    }
                    // if (hhAccountNameToUserRegistrationListMap.containsKey(hhAccountName)) {
                    //     List<User_Registration__c> userRegistrationList = hhAccountNameToUserRegistrationListMap.get(hhAccountName);
                    //     userRegistrationList.add(userReg);
                    //     hhAccountNameToUserRegistrationListMap.put(hhAccountName, userRegistrationList);
                    // }
                    // else {
                    //     List<User_Registration__c> userRegistrationList = new List<User_Registration__c>();
                    //     hhAccountNameToUserRegistrationListMap.put(hhAccountName, userRegistrationList);
                    // }
                }
            }
            /** Change for HH Community User Registration. - End */

            if(String.isNotEmpty(userReg.Facility_ID__c)) {
                facilityIds.add(userReg.Facility_ID__c);
                if(String.isNotEmpty(userReg.Facility_ID__c)) {
                    mapOfFacilityIDToName.put(userReg.Facility_ID__c, userReg.Facility_Name__c);
                }
            }
        }

        if (accountNames.size() > 0) {
            List<Account> accounts = [SELECT Id,Name FROM Account WHERE Name IN :accountNames AND Entity_Type__c='County' ];
            for (Account account : accounts) {
                accountByName.put(account.Name, account);
            }
        }

        /** Change for HH Community User Registration. - Start */
        if (hhAccountNameList.size() > 0) {
            List<Account> hhExistingAccountList = [SELECT Id,Name FROM Account WHERE Name IN : hhAccountNameList];
            if (hhExistingAccountList.size() > 0) {
                for (Account hhAccount : hhExistingAccountList) {
                    hhAccountByName.put(hhAccount.Name, hhAccount);
                }
            }
           
            List<Account> accToInsert = new List<Account>();
            for(String hhAccName : hhAccountNameList) {
                if (hhAccountByName.size() == 0 || !hhAccountByName.containsKey(hhAccName)) {
                    Account acc = new Account();
                    User_Registration__c userReg = hhAccNameToUserRegMap.get(hhAccName);
                    //copy the Needed User Reg Fields to Account.
                    acc.Name = hhAccName;
                    acc.Account_Name__c = userReg.Unique_Household_Number__c;
                    accToInsert.add(acc);
                }    
            }
            if(accToInsert.size() > 0) {
                insert accToInsert;
                for (Account hhAccount : accToInsert) {
                    hhAccountByName.put(hhAccount.Name, hhAccount);
                }
            }
            //Now we have map of all hh accounts.. new and old both.
        }
        /** Change for HH Community User Registration. - End */

        if (nonGovFederalIDs.size() > 0) {
            String accountOwnerId = KeyValueHelper.getTextValue('SOC_OPS_Non_GovernmentOwnerId');
            List<Account> accList = new List<Account>();
            List<Account> accUpdateList = new List<Account>();
            List<Account> accounts = [SELECT Id,Name,Federal_Tax_ID__c,ParentId,Entity_Type__c,Entity_Id__c,Owner.ContactId
                                        FROM Account WHERE Entity_Id__c IN :mapOfFederalIdToNonGovName.keySet() AND Name IN: mapOfFederalIdToNonGovName.values()];
            for (Account account : accounts) {
                if(account.Owner.ContactId != null) {
                    account.OwnerId = accountOwnerId;
                    accUpdateList.add(account);
                }
                nonGovAccountByName.put(account.Entity_Id__c, account);
            }
            if(!accUpdateList.isEmpty()) update accUpdateList;
            //String sopAccountName = KeyValueHelper.getTextValue('SOC_OPS_Non_Government_Parent_Name');
            String sopAccountName = KeyValueHelper.getTextValue('SOC_OPS_Non_Government_Parent_Id');
            List<Account> accountList = [SELECT Id FROM Account WHERE  Name IN: accountNames AND Entity_Type__c = 'County'];
            if(accounts.isEmpty()) {
                if(String.isNotEmpty(sopAccountName)){
                    for(String federalId : nonGovFederalIDs){
                        Account acc = new Account();
                        acc.Name  = mapOfFederalIdToNonGovName.get(federalId);
                       /* if(accountList.size() > 0) {
                            acc.ParentId = accountList.get(0).Id;
                        }*/
                        acc.ParentId = sopAccountName;
                        acc.OwnerId = accountOwnerId;
                        acc.Entity_Type__c = 'Non-Governmental Entity';
                        acc.Entity_Id__c = federalId;
                        User_Registration__c usrReg = mapOfFederalIDToUserReg.get(federalId);
                        acc.ShippingCity = usrReg.City_Name__c;
                        acc.ShippingStreet = usrReg.Street_Address__c;
                        acc.ShippingState = usrReg.State__c;
                        acc.ShippingPostalCode = usrReg.Zip_Postal_Code__c;
                        accList.add(acc);
                    }
                }
                insert accList;
                for(Account acc : accList){
                    nonGovAccountByName.put(acc.Entity_Id__c, acc);
                }
            }
            else{
                List<Account> updateList = new List<Account>();
                for(Account acc : accounts) {
                    if(acc.ParentId == null) {
                      // acc.ParentId = accountList.get(0).Id;   
                       acc.ParentId = sopAccountName;   
                    }
                    acc.Entity_Type__c = 'Non-Governmental Entity';
                    updateList.add(acc);
                }
                if(!updateList.isEmpty()){
                    update updateList;
                }
            }
        }

        if (facilityIds.size() > 0) {
            List<Account> accList = new List<Account>();
            List<Account> accUpdateList = new List<Account>();
            String accountOwnerId = KeyValueHelper.getTextValue('SOC_OPS_Non_GovernmentOwnerId');
            List<Account> accounts = [SELECT Id,Name,Federal_Tax_ID__c,ParentId,Entity_Type__c,Entity_Id__c,Owner.ContactId
                                        FROM Account WHERE Entity_Id__c IN: mapOfFacilityIDToName.keySet() AND Name IN: mapOfFacilityIDToName.values()];
            for (Account account : accounts) {
                if(account.Owner.ContactId != null) {
                    account.OwnerId = accountOwnerId;
                    accUpdateList.add(account);
                }
                facilityIdToAcc.put(account.Entity_Id__c, account);
            }
            if(!accUpdateList.isEmpty()) update accUpdateList;
            List<Account> accountList = [SELECT Id,Name FROM Account WHERE  Name IN : accountNames AND Entity_Type__c = 'County'];
            Map<String, Id> countyAccToId = new Map<String, Id>();
            for(Account acc : accountList) {
                countyAccToId.put(acc.Name, acc.Id);
            }
            if(accounts.isEmpty()){
                for(String facilityId : facilityIds){
                    Account acc = new Account();
                    acc.Name  = mapOfFacilityIDToName.get(facilityId);
                    User_Registration__c usrReg =  mapOfFacilityToUserReg.get(facilityId);
                    if(accountList.size() > 0) {
                        acc.ParentId = countyAccToId.get(usrReg.County__c);
                        System.debug('------'+acc.ParentId);
                    }
                    acc.OwnerId = accountOwnerId;
                    acc.Entity_Type__c = 'Health Care Facility';
                    acc.Entity_Id__c = facilityId;
                    acc.ShippingCity = usrReg.City_Name__c;
                    acc.ShippingStreet = usrReg.Street_Address__c;
                    acc.ShippingState = usrReg.State__c;
                    acc.ShippingPostalCode = usrReg.Zip_Postal_Code__c;
                    accList.add(acc);
                }
                insert accList;
                for(Account acc : accList){
                    facilityIdToAcc.put(acc.Entity_Id__c, acc);
                }
            }
        }
        //check Contact is present & Entity Change Requested is true
        List<Contact> existingContactList = [SELECT Id, Email, Entity_Change_Requested__c FROM Contact WHERE ID IN : contactIDSet];
        Map<String, Contact> mapEmailToConID = new Map<String, Contact>();
        for(Contact con : existingContactList) {
            mapEmailToConID.put(con.Email, con);
        }
        
        //check for Federal Agency
        Set<Id> federalAgencyConIds = new Set<Id>();
        for(User_Registration__c userReg : userRegList) {
            if(String.isNotEmpty(userReg.Entity_Type__c) && userReg.Entity_Type__c.equals('Federal Agency')) {
                //mapEmailToConId.put(userReg.Contact_Name__r.Email, (Contact) userReg.Contact_Name__c);
                federalAgencyConIds.add(userReg.Contact_Name__c);
            }
        }
        List<Contact> existingFederalAgencyContactList = [SELECT Id, Email FROM Contact WHERE ID IN :federalAgencyConIds];
        if(existingFederalAgencyContactList.size() > 0) {
            for(Contact con : existingFederalAgencyContactList) {
                mapEmailToConID.put(con.Email, Con);
            }
        }

        //Check fro Contact based on Mail...
        List<Contact> getContactList = new List<Contact>();
        set<String> uniqueEmailId = new set<String>();
        for(User_Registration__c userReg : userRegList){
            uniqueEmailId.add(userReg.Email__c);
        }
        System.debug('Unique Emails Id Set==='+uniqueEmailId);

        getContactList = [select FirstName, LastName, Email, Phone, AccountId from Contact where  Email In: uniqueEmailId];
        List<Contact> contactList = new List<Contact>();
        List<Contact> updateConList = new List<Contact>();
         Map<String, Contact> mapEmailContacts = new Map<String, Contact>();
         System.debug('getContactList==='+getContactList);
        if(getContactList.size() > 0){
            for(Contact con : getContactList){
                mapEmailContacts.put(con.Email, con);
            }
        }
        System.debug('mapEmailContacts==='+mapEmailContacts);
        for(User_Registration__c userReg : userRegList){

            if(mapEmailToConID.get(userReg.Email__c) != null || mapEmailContacts.get(userReg.Email__c) != null) {
                 
                Contact updateContact  =  mapEmailToConID.get(userReg.Email__c) != null?mapEmailToConID.get(userReg.Email__c):mapEmailContacts.get(userReg.Email__c);
                if(userReg.Rejection_Reason__c == 'Entity Change Required' || mapEmailContacts.get(userReg.Email__c) != null) {
                    System.debug('Existing Contact Block');
                    if(userReg.Entity_Type__c == 'County' && String.isNotBlank(userReg.County__c)){
                        if(accountByName.get(userReg.County__c) == null) {
                            userReg.addError('Account not found by County. Please contact your system administrator');
                        } else {
                            updateContact.AccountId = accountByName.get(userReg.County__c).Id; 
                        }
                    }
                        /** Change for HH Community User Registration. - Start */
                    else if (userReg.RecordTypeId == Schema.SObjectType.User_Registration__c.getRecordTypeInfosByDeveloperName().get(System.Label.HH_RecordType_API_Name_HH_Registration).getRecordTypeId()) {
                        String hhAccountName = HH_CONSTANTS.Account_HOUSEHOLD_Name + '-' + userReg.Unique_Household_Number__c;
                        updateContact.AccountId = hhAccountByName.get(hhAccountName).Id;
                        addHHContactDetails(updateContact, userReg);
                    }   /** Change for HH Community User Registration. - End */
                    else if(userReg.Non_Government_Entity_Type__c == 'Health Care Facility' && userReg.Facility__c != null) {
                        updateContact.AccountId = userReg.Facility__c;
                    }else if(userReg.State_Agency__c != null){
                        updateContact.AccountId = userReg.State_Agency__c;
                    }else if(string.isNotBlank(userReg.Fire_Agency__c)){
                        updateContact.AccountId = userReg.Fire_Agency__c;
                    }else if(string.isNotBlank(userReg.Federal_Agency__c)){
                        updateContact.AccountId = userReg.Federal_Agency__c;
                    }else if(string.isNotBlank(userReg.MARS_Paying_Entity__c)){
                        updateContact.AccountId = userReg.MARS_Paying_Entity__c;
                    }else if(String.isNotBlank(userReg.Federal_Tax_ID__c)){
                        if(nonGovAccountByName.get(userReg.Federal_Tax_ID__c) == null) {
                            userReg.addError('Account not found by Federal_Tax_ID. Please contact your system administrator');
                        } else {
                            updateContact.AccountId = nonGovAccountByName.get(userReg.Federal_Tax_ID__c).Id;
                        }
                    }else if(userReg.City__c != null){
                        updateContact.AccountId = userReg.City__c;
                    }else if(userReg.Tribal__c != null){
                        updateContact.AccountId = userReg.Tribal__c;
                    }else if(userReg.Special_District__c != null){
                        updateContact.AccountId = userReg.Special_District__c;
                    }else if(userReg.Courts__c != null){
                        updateContact.AccountId = userReg.Courts__c;
                    }else if(String.isNotBlank(userReg.Facility_ID__c)){
                        if(facilityIdToAcc.get(userReg.Facility_ID__c) == null) {
                            userReg.addError('Account not found by Facility_ID. Please contact your system administrator');
                        } else {
                            updateContact.AccountId = facilityIdToAcc.get(userReg.Facility_ID__c).Id;
                        }
                    }
                    updateConList.add(updateContact);
                }
            }else {
                Contact c = new Contact();
                c.FirstName = userReg.First_Name__c;
                c.LastName = userReg.Last_Name__c;
                c.Email = userReg.Email__c;
                c.Phone = userReg.Phone__c;
                c.Title = userReg.Title__c;
                if(userReg.Entity_Type__c == 'County' && String.isNotBlank(userReg.County__c)){
                    if(accountByName.get(userReg.County__c) == null) {
                        userReg.addError('Account not found by County. Please contact your system administrator');
                    } else {
                        
                        c.AccountId = accountByName.get(userReg.County__c).Id;
                    }
                }
                    /** Change for HH Community User Registration. - Start */
                else if(userReg.RecordTypeId == Schema.SObjectType.User_Registration__c.getRecordTypeInfosByDeveloperName().get(System.Label.HH_RecordType_API_Name_HH_Registration).getRecordTypeId()) {
                    String hhAccountName = HH_CONSTANTS.Account_HOUSEHOLD_Name + '-' + userReg.Unique_Household_Number__c;
                    c.AccountId = hhAccountByName.get(hhAccountName).Id;
                    addHHContactDetails(c, userReg);
                    //Added populate fields to contact from userReg 
                }   /** Change for HH Community User Registration. - End */
                else if(userReg.Non_Government_Entity_Type__c == 'Health Care Facility' && userReg.Facility__c != null) {
                    c.AccountId = userReg.Facility__c;
                }else if(userReg.State_Agency__c != null){
                    c.AccountId = userReg.State_Agency__c;
                }else if(string.isNotBlank(userReg.Fire_Agency__c)){
                    c.AccountId = userReg.Fire_Agency__c;
                }else if(string.isNotBlank(userReg.Federal_Agency__c)){
                    c.AccountId = userReg.Federal_Agency__c;
                }else if(string.isNotBlank(userReg.MARS_Paying_Entity__c)){
                    c.AccountId = userReg.MARS_Paying_Entity__c;
                }else if(String.isNotBlank(userReg.Federal_Tax_ID__c)){
                    if(nonGovAccountByName.get(userReg.Federal_Tax_ID__c) == null) {
                        userReg.addError('Account not found by Federal_Tax_ID. Please contact your system administrator');
                    } else {
                        c.AccountId = nonGovAccountByName.get(userReg.Federal_Tax_ID__c).Id;
                    }
                }else if(userReg.City__c != null){
                    c.AccountId = userReg.City__c;
                }else if(userReg.Tribal__c != null){
                    c.AccountId = userReg.Tribal__c;
                }else if(userReg.Special_District__c != null){
                    c.AccountId = userReg.Special_District__c;
                }else if(userReg.Courts__c != null){
                    c.AccountId = userReg.Courts__c;
                }else if(String.isNotBlank(userReg.Facility_ID__c)){
                    if(facilityIdToAcc.get(userReg.Facility_ID__c) == null) {
                        userReg.addError('Account not found by Facility_ID. Please contact your system administrator');
                    } else {
                        c.AccountId = facilityIdToAcc.get(userReg.Facility_ID__c).Id;
                    }
                }
                contactList.add(c);
            }
        }
        if(!contactList.isEmpty()){
            
            Database.insert(contactList,true);
        }
        if(!updateConList.isEmpty()){
            Database.update(updateConList,true);
            //here it add the existing  contact in contact list
            contactList.addAll(getContactList);   
        }
        if(contactList != null && !contactList.isEmpty()) {
            Map<String, Contact> mapOfEmailToContact = new Map<String, Contact>();
            Map<String, String> mapOfEmailToAccountName = new Map<String, String>();
            for(Contact con : contactList){
                mapOfEmailToContact.put(con.Email, con);
            }
            for(Contact con : [Select id,Name,Email,AccountId,Account.Name from Contact where ID IN :contactList]){
                mapOfEmailToAccountName.put(con.Email, con.Account.Name);
            }
            String profileName = KeyValueHelper.getTextValue('Community_User_Profile_Name');
            Profile profile = [Select id, Name from Profile where Name = :profileName LIMIT 1];
            List<User> userList = new List<User>();
            Map<String, String> userNameWithPassword = new Map<String, String>();
            for(User_Registration__c userReg : userRegList) {
                if(mapOfEmailToContact.get(userReg.Email__c).Id != null) {
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
                    u.TimeZoneSidKey = 'America/Los_Angeles';
                    u.ProfileID = profile.Id;
                    u.LanguageLocaleKey = 'en_US';
                    u.EmailEncodingKey = 'UTF-8';
                    // Change for HH Community User Registration. - Start
                    if(userReg.Translation_Language__c != null) {
                            u.LocaleSidKey = userReg.Translation_Language__c;
                            u.LanguageLocaleKey = userReg.Translation_Language__c;
                    }
                    // Change for HH Community User Registration. - End
                    u.County__c = userReg.County__c;
                    u.UserPreferencesReceiveNoNotificationsAsApprover = true;
                    userList.add(u);
                    userNameWithPassword.put(userReg.Email__c.toLowerCase(), userReg.Password__c);
                }
            }
            if(!userList.isEmpty()) {
               
                Database.insert(userList,true);
                for (User user : userList) {
                    //System.assertEquals('34', userNameWithPassword.get(user.Username.toLowerCase()));
                    System.setPassword(user.Id, userNameWithPassword.get(user.Username.toLowerCase()));
                }
            }

            //Update User on User Registration Object
            Map<String, User> mapOfEmailToUser = new Map<String, User>();
            for(User usr : userList) {
                mapOfEmailToUser.put(usr.Email, usr);
            }
            List<User_Registration__c> userRegToUpdate = new List<User_Registration__c>();
            for(User_Registration__c userReg : userRegList) {
                User_Registration__c req = new User_Registration__c();
                req.Id = userReg.Id;
                req.User__c = mapOfEmailToUser.get(userReg.Email__c).Id;
                req.Contact_Name__c = mapOfEmailToUser.get(userReg.Email__c).ContactId;
                req.RecordTypeId = userReg.RecordTypeId;
                userRegToUpdate.add(req);
            }
            if(!userRegToUpdate.isEmpty()) {
                System.enqueueJob(new UpdateUserRegistrationObject(JSON.serialize(userRegToUpdate)));
            }
        }
    }


    private static void addHHContactDetails(Contact c, User_Registration__c userReg) {
        c.Is_Physical_Address_a_Foreign_Address__c = userReg.Is_Physical_Address_a_Foreign_Address__c == null ? null : userReg.Is_Physical_Address_a_Foreign_Address__c;
        c.Is_Mailing_Address_Different__c = userReg.Is_Mailing_Address_Different__c == null ? null : userReg.Is_Mailing_Address_Different__c;
        c.Is_Mailing_Address_a_Foreign_Address__c = userReg.Is_Mailing_Address_a_Foreign_Address__c == null ? null : userReg.Is_Mailing_Address_a_Foreign_Address__c;
        c.Physical_Street__c = userReg.Street_Address__c == null ? null : userReg.Street_Address__c;
        c.Physical_City__c = userReg.City_Name__c == null ? null : userReg.City_Name__c;
        c.Physical_State__c = userReg.State__c == null ? null : userReg.State__c;
        c.Physical_Zip_Postal_Code__c = userReg.Zip_Postal_Code__c == null ? null : userReg.Zip_Postal_Code__c;
        c.Physical_Country__c = userReg.Country_Region__c == null ? null : userReg.Country_Region__c;
        //c.Country__c = userReg.Country_Region__c == null ? null : userReg.Country_Region__c;
        c.English_Language_Proficiency__c = userReg.English_Language_Proficiency__c == null ? null : userReg.English_Language_Proficiency__c;
        c.HomePhone = userReg.Secondary_Phone__c == null ? null : userReg.Secondary_Phone__c;
        c.Preferred_Language__c = userReg.Preferred_Language__c == null ? null : userReg.Preferred_Language__c;
        if (userReg.Is_Mailing_Address_Different__c == HH_CONSTANTS.PickList_Yes) {
            c.MailingStreet = userReg.Mailing_Address__c == null ? null : userReg.Mailing_Address__c;
            c.MailingCity = userReg.Mailing_City__c == null ? null : userReg.Mailing_City__c;
            c.MailingState = userReg.Mailing_State_Province__c == null ? null : userReg.Mailing_State_Province__c;
            c.MailingPostalCode = userReg.Mailing_Zip_Postal_Code__c == null ? null : userReg.Mailing_Zip_Postal_Code__c;
            c.MailingCountry = userReg.Mailing_Country_Region__c == null ? null : userReg.Mailing_Country_Region__c;
            //c.Mailing_Country__c = userReg.Mailing_Country_Region__c == null ? null : userReg.Mailing_Country_Region__c;
        }    
        c.Contact_Type__c =  HH_CONSTANTS.HH_Contact_Type_Homeowner;
    }

    /***********************************************
    * Method Name : addUsersToApp
    * Author : Pankaj
    * Inputs : List<User_Registration__c> userRegistrations
    * Description: This method add user to community app(approve\reject)
    *********************************************/
    public static void addUsersToApp(List<User_Registration__c> userRegistrations) {
        Map<Id, Map<String, List<User_Registration__c>>> userRegistrationMapByStatusAndApp = new Map<Id, Map<String, List<User_Registration__c>>>();
        for (User_Registration__c appRegistration : userRegistrations) {
            if(userRegistrationMapByStatusAndApp.get(appRegistration.Community_Application__c) == null) {
                userRegistrationMapByStatusAndApp.put(appRegistration.Community_Application__c, new Map<String, List<User_Registration__c>>());
            }
            if (userRegistrationMapByStatusAndApp.get(appRegistration.Community_Application__c).get(appRegistration.Status__c) == null) {
                userRegistrationMapByStatusAndApp.get(appRegistration.Community_Application__c).
                        put(appRegistration.Status__c, new List<User_Registration__c>());
            }
            userRegistrationMapByStatusAndApp.get(appRegistration.Community_Application__c).get(appRegistration.Status__c).add(appRegistration);
        }
        Map<Id, Community_Application__c> communityApplicationMap = new Map<Id, Community_Application__c>(
                [SELECT Id,User_Approval_Class__c FROM Community_Application__c WHERE Id IN :userRegistrationMapByStatusAndApp.keySet()]);
        for (Id appId : userRegistrationMapByStatusAndApp.keySet()) {
            List<User_Registration__c> userRegistrationApproved = userRegistrationMapByStatusAndApp.get(appId).get(CONSTANTS.USER_REGISTRATION_STATUS_APP_APPROVED);
            List<User_Registration__c> userRegistrationRejected = userRegistrationMapByStatusAndApp.get(appId).get(CONSTANTS.USER_REGISTRATION_STATUS_APP_REJECTED);
            Type classType = Type.forName(communityApplicationMap.get(appId).User_Approval_Class__c);
            UserServiceAppHandler handler = (UserServiceAppHandler) classType.newInstance();
            if(userRegistrationApproved!=null){
                handler.handleApprove(userRegistrationApproved);
            }
            if(userRegistrationRejected!=null){
                handler.handleReject(userRegistrationRejected);
            }    
                    
        }
    }

    /***********************************************************************************************************************************
    * Class Name   : UpdateUserRegistrationObject
    * Description  : This is Queueable class for update user registration
    * Author       : Pankaj
    * Created On   : 07/12/2020
    * Modification Log:  
    * --------------------------------------------------------------------------------------------------------------------------------------
    * Developer             Date             Description 
    * ---------------------------------------------------------------------------------------------------------------------------------------
    * Pankaj                07/12/2020       Initial Implementation
    **************************************************************************************************************************************/
    public class UpdateUserRegistrationObject implements Queueable {
        String userRegJSON;
        UpdateUserRegistrationObject(String userRegJSON) {
            this.userRegJSON = userRegJSON;
        }

        //TODO: Bulkify this method... to insert more user.... try again queue
        public void execute(QueueableContext context) {
            List<User_Registration__c> userRegs = (List<User_Registration__c>)JSON.deserialize(userRegJSON, List<User_Registration__c>.class);
            update userRegs;
            String hhUserRegTypeId = Schema.SObjectType.User_Registration__c.getRecordTypeInfosByDeveloperName().get(System.Label.HH_RecordType_API_Name_HH_Registration).getRecordTypeId();
            // to do - remove after enabling common community
   			String customAppName = 'HMA';
            Community_Application__c communityApplication = null;
 			if(userRegs.get(0).RecordTypeId == hhUserRegTypeId) {
                communityApplication = [SELECT Id FROM Community_Application__c WHERE Parent__r.Name =:HH_CONSTANTS.HH_Parent_Community_Application_Name AND User_Type__c ='Homeowner'];
            }
            if (communityApplication == null) {
                communityApplication = [SELECT Id FROM Community_Application__c WHERE Name=:customAppName];
            }
            Map<Id, Set<Id>> appTouserIds = new Map<Id, Set<Id>>();
            appTouserIds.put(communityApplication.Id, new Set<Id>());
            appTouserIds.get(communityApplication.Id).add(userRegs.get(0).User__c);
            
            UserService.addApplicationToUser(appTouserIds, userRegs.get(0).Contact_Name__c, userRegs.get(0).User__c);
        }
    }
    public class CommAppActionClass {
        public String action;
        public String value;
    }
    
    /***********************************************
    * Method Name : addApplicationToUser
    * Author : Pankaj
    * Inputs : Map<Id, Set<Id>> appIdToUserIdSet
    * Description: This method insert community application to users
    *********************************************/
    public static void addApplicationToUser(Map<Id, Set<Id>> appIdToUserIdSet){
        addApplicationToUser(appIdToUserIdSet, null, null);
    }
    public static void addApplicationToUser(Map<Id, Set<Id>> appIdToUserIdSet, String contactId, String userId) {
        List<Community_Application_to_User__c> communityApplicationToUsers = new List<Community_Application_to_User__c>();
        Map<Id, Id> usrIDToContactIDMap = new Map<Id, Id>();
        Map<Id, Id> contactTOusrIDMap = new Map<Id, Id>();
        Set<Id> userIdSet = new Set<Id>();
        for(Set<Id> idSet : appIdToUserIdSet.values()) {
            userIdSet.addAll(idSet);
        }
        List<User> userList = [SELECT Id,ContactId FROM User WHERE Id IN :userIdSet];
        List<String> contactIdLst = new List<String>();
        for(User usr : userList) {
            if(usr.ContactId != null) {
                usrIDToContactIDMap.put(usr.Id, usr.ContactId);
                contactIdLst.add(usr.ContactId);
                contactTOusrIDMap.put(usr.ContactId, usr.Id);
            }
        }
        for (Id appId : appIdToUserIdSet.keySet()) {
            Set<Id> userIds = appIdToUserIdSet.get(appId);
            if(userIds == null) continue;
            
            for (Id userId1 : userIds) {
                communityApplicationToUsers.add(new Community_Application_to_User__c(User__c=userId1, Community_Application__c=appId,  isActive__c = false, Contact__c=usrIDToContactIDMap.get(userId)));
            }
        }
        insert communityApplicationToUsers;
        //First insert community applications with active = FALSE & then update with active = TRUE, this will avoid issue
        //with multiple jobs in queue for same transaction
        for( Community_Application_to_User__c communityApplicationToUser : communityApplicationToUsers){
            communityApplicationToUser.isActive__c = true;
        }
        //update communityApplicationToUsers;
        List<Community_Application_to_User__c> comAppUserObjLst = [SELECT Id, User__c, Post_Active_Actions__c, Community_Application__c, Community_Application__r.Id,
                        isActive__c, Contact__c
                        FROM Community_Application_to_User__c
                        WHERE User__c = null and Contact__c =:contactID and Contact__c != null];

        for(Community_Application_to_User__c communityApplicationToUser : comAppUserObjLst) {
            communityApplicationToUser.isActive__c = true;
            communityApplicationToUser.User__c =userId;
            communityApplicationToUsers.add(communityApplicationToUser);
        }
        update communityApplicationToUsers;

        List<String> postActionColList = new List<String>();
        for(Community_Application_to_User__c communityApplicationToUser : comAppUserObjLst) {
            if(communityApplicationToUser.Post_Active_Actions__c != null){
                postActionColList.add(communityApplicationToUser.Post_Active_Actions__c);
           }
        }

        if(postActionColList.size() > 0) {
            Database.executeBatch(new UserRegistrationPostActionBatch(JSON.serialize(postActionColList), userId),1);
        }
    }

    /***********************************************
    * Method Name : addPermissionSetToUser
    * Author : Pankaj
    * Inputs : Map<Id, Set<Id>> appIdToUserIdSet
    * Description: This method assign permission set to user
    *********************************************/
    public static void addPermissionSetToUser(Map<Id, Set<Id>> appIdToUserIdSet) {
        Map<Id, Community_Application__c> communityApplications = new Map<Id, Community_Application__c>(
                        [SELECT App_Permission_Set_Developer_Name__c FROM Community_Application__c WHERE Id IN :appIdToUserIdSet.keySet()] );
        Set<String> permissionSetDeveloperName = new Set<String>();
        for (Community_Application__c communityApplication : communityApplications.values()) {
            permissionSetDeveloperName.add(communityApplication.App_Permission_Set_Developer_Name__c);
        }
        Map<String, PermissionSet> permissionSetByName = new Map<String, PermissionSet>();
        for (PermissionSet permissionSet : [SELECT Id,Name FROM PermissionSet WHERE Name IN : permissionSetDeveloperName]) {
            permissionSetByName.put(permissionSet.Name, permissionSet);
        }

        List<PermissionSetAssignment> permissionSetAssignments = new List<PermissionSetAssignment>();
        for (String appId : appIdToUserIdSet.keySet()) {
            Set<Id> userIds = appIdToUserIdSet.get(appId);
            Community_Application__c communityApplication = communityApplications.get(appId);
            if(communityApplication == null) Continue;
            if(permissionSetByName.get(communityApplication.App_Permission_Set_Developer_Name__c) == null) continue;
            Id permissionSetId = permissionSetByName.get(communityApplication.App_Permission_Set_Developer_Name__c).Id;
            for (String userId : userIds) {
                permissionSetAssignments.add(new PermissionSetAssignment(AssigneeId=userId, PermissionSetId=permissionSetId));
            }
        }
        insert permissionSetAssignments;
    }
    public class CustomException extends Exception{

    }
}