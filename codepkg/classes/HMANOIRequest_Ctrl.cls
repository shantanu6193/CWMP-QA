/***********************************************************************************************************************************
* Class Name   : HMANOIRequest_Ctrl
* Description  : This class for HMA NOI Request
* Author       : Pankaj
* Created On   : 07/12/2020
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Pankaj               07/12/2020       Initial Implementation
**************************************************************************************************************************************/

public without sharing class HMANOIRequest_Ctrl {
    
    /***********************************************
    * Method Name : submitRequest
    * Author : Pankaj
    * Inputs : String recordData
    * Description: This method return Pre_Application__c record
    *********************************************/
    @AuraEnabled
    public static Pre_Application__c submitRequest(String recordData) {
        try{
            System.debug('recordData---' + recordData);
            Pre_Application__c preApp = (Pre_Application__c) JSON.deserialize(recordData, Pre_Application__c.class);
            processPreApplication(preApp);
            processContactRoles(preApp);
            return preApp;
        }catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /***********************************************
    * Method Name : processPreApplication
    * Author : Pankaj
    * Inputs : Pre_Application__c preApp
    * Description: This method upsert Pre_Application__c record
    *********************************************/
    private static void processPreApplication(Pre_Application__c preApp) {
        //Insert Pre-Application
        //todo - need to check logic for this.
        /*Incident__c incident = [Select Id from Incident__c where isDefault__c = true LIMIT 1];
        preApp.Disaster__c = incident.Id;*/
        // todo - read developer name from Key value setting.
        Group queues = [SELECT Id FROM Group WHERE DeveloperName= 'HMA_NOI_Pending_Review' AND Type='Queue'];
        System.debug('===='+preApp);
        /*Id hmaRecordTypeId = Schema.SObjectType.Pre_Application__c.getRecordTypeInfosByDeveloperName().get('HMGP').getRecordTypeId();
        preApp.RecordTypeId = hmaRecordTypeId;*/
        if(preApp.Status__c == 'Pending Review') {
            preApp.OwnerId =queues.Id;
        }
        Contact contactRecord ;
        User usr = [SELECT Id,Name,AccountId FROM User WHERE Id=: UserInfo.getUserId()];
        if(usr.AccountId != null) {
            preApp.Subapplicant_Entity__c = usr.AccountId;
        }
       upsert preApp;
    }

    /***********************************************
    * Method Name : processContactRoles
    * Author : Pankaj
    * Inputs : Pre_Application__c preApp
    * Description: This method upsert ContactRoles record
    *********************************************/
    private static void processContactRoles(Pre_Application__c preApp) {
        //Upserting Contacts
        Set<String> contactEmails = new Set<String>();
        Set<String> accountEntityIds = new Set<String>();
        List<Id> contactRoleIds = new List<Id>();
        Map<String, Contact> originalContactByEmail = new Map<String, Contact>();
        for (Contact_Role__c contactRole : preApp.Contact_Roles__r) {
            if(String.isNotBlank(contactRole.Contact__r.Email)) {
            contactEmails.add(contactRole.Contact__r.Email.toLowerCase());
                originalContactByEmail.put(contactRole.Contact__r.Email.toLowerCase(), contactRole.Contact__r);
            }            
            accountEntityIds.add(contactRole.Contact__r.Account.Entity_Id__c);
            if(contactRole.Id != null) {
                contactRoleIds.add(contactRole.Id);
            }
        }
        // Format role picklist value
        for(Contact_Role__c contactRole : preApp.Contact_Roles__r) {
            contactRole.Role__c = contactRole.Role__c.replaceAll(',', ';');
        }


        // delete records which are deleted on UI
        delete [SELECT Id FROM Contact_Role__c WHERE Pre_Application__c=:preApp.Id AND Id NOT IN :contactRoleIds];

        Map<String, Contact> contactByEmail = new Map<String, Contact>();
        List<Contact> contactList = [Select id, FirstName, LastName, Email, Phone, MobilePhone, AccountId, Title from Contact where Email IN :contactEmails];
        for(Contact contact : contactList) {
            contactByEmail.put(contact.Email, contact);
        }

        Map<String, Account> accountEntityByAccount = new Map<String, Account>();
        List<Account> accList = [Select id, Name, Entity_Id__c from Account where Entity_Id__c IN : accountEntityIds];
        for (Account account : accList) {
            accountEntityByAccount.put(account.Entity_Id__c, account);
        }

        List<Contact> contactsToInsert = new List<Contact>();
        List<Contact> contactsToUpdate = new List<Contact>();
        List<Account> accountsInsert = new List<Account>();
        String userAccountId = [SELECT AccountId FROM User WHERE Id = :UserInfo.getUserId()]?.AccountId;
        for (Contact_Role__c contactRole : preApp.Contact_Roles__r) {
            Boolean isContactToUpdate = false;
            /*Check Existing contact in the map*/
            Contact contact = contactByEmail.get(contactRole.Contact__r.Email.toLowerCase());
            /*If exiting contact not available then create new contact*/
            if(contact == null) {
                contact = contactRole.Contact__r;
                contactsToInsert.add(contact);
                contactByEmail.put(contact.Email, contact);
                /*Account account = accountEntityByAccount.get(contact.Account.Entity_Id__c);
                if(account == null) {
                    account = contact.Account;
                    accountsInsert.add(account);
                    accountEntityByAccount.put(account.Entity_Id__c, account);
                }*/
            }else{
                /*we are updating only Title and FirstName of the contact if its empty in existing contact*/
                if(String.isBlank(contact.Title)){
                    contact.Title = contactRole.Contact__r.Title;
                    isContactToUpdate = true;
                }
                if(String.isBlank(contact.FirstName) && String.isNotBlank(contactRole.Contact__r.FirstName)){
                    contact.FirstName = contactRole.Contact__r.FirstName;
                    isContactToUpdate = true;
                }
                if(String.isBlank(contact.Phone) && String.isNotBlank(contactRole.Contact__r.Phone)){
                    contact.Phone = contactRole.Contact__r.Phone;
                    isContactToUpdate = true;
                }

                if(String.isBlank(contact.MobilePhone) && String.isNotBlank(contactRole.Contact__r.MobilePhone)){
                    contact.MobilePhone = contactRole.Contact__r.MobilePhone;
                    isContactToUpdate = true;
                }
                
                if(String.isBlank(contact.AccountId)) {
                    contact.AccountId = userAccountId;
                    isContactToUpdate = true;
                }
                /*If existing contact doesn't have account associated with that then check user enter account
                details in the accountEntityByAccount map */
                /*if(String.isBlank(contact.AccountId)){
                    Account account = accountEntityByAccount.get(contactRole.Contact__r.Account.Entity_Id__c);
                    /*If account not present in the accountEntityByAccount map then create new one*/
                    /*if(account == null) {
                        account = contactRole.Contact__r.Account;
                        accountsInsert.add(account);
                        accountEntityByAccount.put(account.Entity_Id__c, account);
                    }else{
                        contact.AccountId = account.Id;
                        isContactToUpdate = true;
                    }
                }*/
            }
            contactRole.Contact__r = contact;
            if(isContactToUpdate){
                contactsToUpdate.add(contact);
                isContactToUpdate = false;
            }
        }
        //insert accountsInsert;

        if(contactsToUpdate.size() > 0){
            /*If existing contact doesn't have account associated with that and if we created new account */
            /*for(Contact conUpdate: contactsToUpdate){
                if(originalContactByEmail.get(conUpdate.Email) != null && originalContactByEmail.get(conUpdate.Email) != null){
                    Contact originalContact = originalContactByEmail.get(conUpdate.Email);
                    if(accountEntityByAccount.get(originalContact.Account.Entity_Id__c) != null){
                        conUpdate.AccountId = accountEntityByAccount.get(originalContact.Account.Entity_Id__c).Id;
                    }
                }
            }*/
            update contactsToUpdate;
        }

        for (Contact contact : contactsToInsert) {
            /*if(originalContactByEmail.get(contact.Email) != null && originalContactByEmail.get(contact.Email) != null){
                Contact originalContact = originalContactByEmail.get(contact.Email);
                if(accountEntityByAccount.get(originalContact.Account.Entity_Id__c) != null){
                    contact.AccountId = accountEntityByAccount.get(originalContact.Account.Entity_Id__c).Id;
                }
            }*/
            /*if(contact.AccountId == null) {
                contact.AccountId = contact.Account.Id;
            }*/
            contact.Account = null;
            //Primary Contact and Responsible Representative Contacts are working in Same entity
            contact.AccountId = userAccountId;
        }
        insert contactsToInsert;
        for (Contact_Role__c contactRole : preApp.Contact_Roles__r) {
            if(contactRole.Contact__c == null) {
                contactRole.Contact__c = contactRole.Contact__r.Id;
            }
            contactRole.Contact__r = null;
            contactRole.Pre_Application__c = preApp.Id;
        }
        upsert preApp.Contact_Roles__r;


        /*Map<String, Contact> mapEmailToContact = new Map<String, Contact>();
        List<Contact> contactsToUpsert = new List<Contact>();
        List<Contact> contactsToUpsertList = new List<Contact>();
        Map<String, Account> mapEntityIdToName = new Map<String, Account>();
        Map<String, String> mapEmailToEntityId = new Map<String, String>();
        for (Contact_Role__c contactRoles : preApp.Contact_Roles__r) {
            if(contactRoles.Contact__r.Id == null) {

                mapEmailToContact.put(contactRoles.Contact__r.Email, contactRoles.Contact__r);
                mapEntityIdToName.put(contactRoles.Contact__r.Account.Entity_Id__c, contactRoles.Contact__r.Account);
                mapEmailToEntityId.put(contactRoles.Contact__r.Email, contactRoles.Contact__r.Account.Entity_Id__c);
                //contactsToUpsert.add(con);
            }
        }

        List<Contact> contactList = [Select id, FirstName, LastName, Email, Phone, MobilePhone, AccountId from Contact where Email IN :mapEmailToContact.keySet()];
        if(contactList.isEmpty()) {
            for(Contact con : mapEmailToContact.values()) {
                Contact conRec = new Contact();
                conRec.FirstName = con.FirstName;
                conRec.LastName = con.LastName;
                conRec.Phone = con.Phone;
                conRec.Email = con.Email;
                conRec.MobilePhone = con.MobilePhone;
                conRec.AccountId = null;
                contactsToUpsert.add(conRec);
            }
        }else {
            for(Contact contactRec : contactList) {
                if(mapEmailToContact.containsKey(contactRec.Email)) {
                    contactsToUpsert.add(contactRec);
                    mapEmailToContact.remove(contactRec.Email);
                }else {
                    for(Contact con : mapEmailToContact.values()) {
                        Contact conRec = new Contact();
                        conRec.FirstName = con.FirstName;
                        conRec.LastName = con.LastName;
                        conRec.Phone = con.Phone;
                        conRec.Email = con.Email;
                        conRec.MobilePhone = con.MobilePhone;
                        conRec.AccountId = null;
                        contactsToUpsert.add(conRec);
                    }
                }
            }
        }

        List<Account> accList = [Select id, Name, Entity_Id__c from Account where Entity_Id__c IN : mapEntityIdToName.keySet()];
        Map<String, Account> mapEntityIdToAccount = new Map<String, Account>();
        List<Account> insertAccountList = new List<Account>();
        if(accList.isEmpty()) {
            for(Account accRecord : mapEntityIdToName.values()) {
                Account accRec = new Account();
                accRec.Name = accRecord.Name;
                accRec.Entity_Id__c = accRecord.Entity_Id__c;
                insertAccountList.add(accRec);
            }
        }else {
            for(Account acc : accList) {
                if(mapEntityIdToName.containsKey(acc.Entity_Id__c)) {
                    mapEntityIdToAccount.put(acc.Entity_Id__c, acc);
                }else {
                    for(Account accRecord : mapEntityIdToName.values()) {
                        Account accRec = new Account();
                        accRec.Name = accRecord.Name;
                        accRec.Entity_Id__c = accRecord.Entity_Id__c;
                        insertAccountList.add(accRec);
                    }
                }
            }
        }

        insert insertAccountList;
        for(Account acc : insertAccountList) {
            mapEntityIdToAccount.put(acc.Entity_Id__c, acc);
        }


        for(Contact con : contactsToUpsert){
            if(con.AccountId == null){
                String entityId = mapEmailToEntityId.get(con.Email);
                con.AccountId = mapEntityIdToAccount.get(entityId).Id;
                contactsToUpsertList.add(con);
            }
        }
        System.debug('contactsToUpsertList---'+contactsToUpsertList);
        upsert contactsToUpsertList;


        //Inserting Contact Roles
        for (Contact_Role__c contactRoles : preApp.Contact_Roles__r) {
            for(Contact contact : contactsToUpsertList) {
                contactRoles.Pre_Application__c = preApp.Id;
                if(contactRoles.Contact__r.Id != null){
                    contactRoles.Contact__c = contactRoles.Contact__r.Id;
                    contactRoles.Contact__r = null;
                }else if(contactRoles.Contact__r.Email == contact.Email) {
                    contactRoles.Contact__c = contact.Id;
                    contactRoles.Contact__r = null;
                }
            }
        }
        System.debug('preApp.Contact_Roles__r---'+preApp.Contact_Roles__r);
        upsert preApp.Contact_Roles__r;*/
    }

    /***********************************************
    * Method Name : getRecordData
    * Author : Pankaj
    * Inputs : String recordId
    * Description: This method return Pre_Application__c record
    *********************************************/
    @AuraEnabled
    public static Pre_Application__c getRecordData(String recordId) {
        try{
            return HMA_Service.getPreAppRecordDetails(recordId);
            
        }catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }

    /***********************************************
    * Method Name : getCommunityContact
    * Author : Pankaj
    * Inputs : -
    * Description: This method return contact record
    *********************************************/
    //need to check if we can avoid this query here.. we can do query in JS side itself

    @AuraEnabled(Cacheable=true)
    public static Contact getCommunityContact() {
        Contact contactRecord ;
        User usr = [select id,Name,ContactId from User where id=: UserInfo.getUserId()];
        if(usr.ContactId != null){
                contactRecord = [Select Id, Name, FirstName, LastName, Title, Phone, MobilePhone, Email,AccountId,Account.Name,Account.Entity_Id__c from Contact where Id =: usr.ContactId];
        }
        return contactRecord;
    }

    @AuraEnabled(Cacheable=true)
    public static Map<String, Object> getUserAccount() {
        Map<String, Object> returnMap = new Map<String, Object>();
        Contact contactRecord ;
        User usr = [select id,Name,ContactId, Contact.AccountId, Contact.Account.Name, AccountId, Account.Name, Account.Entity_Id__c from User where id=: UserInfo.getUserId()];
        returnMap.put('account', usr.Contact.Account);
        return returnMap;
    }

    /***********************************************
    * Method Name : getRecordTypes
    * Author : Pankaj
    * Inputs : -
    * Description: This method return map of RecordTypes from HMA_RecordType__mdt metadata
    *********************************************/
    @AuraEnabled
    public static Map<String, Object> getRecordTypes() {
        Map<String, Object> returnMap = new Map<String, Object>();
        List<HMA_RecordType__mdt> recordTypeList1 = [SELECT Active__c,Description__c,DeveloperName,End_Date__c,Id,Label,MasterLabel,RecordType_Id__c,Start_Date__c
                                                        FROM HMA_RecordType__mdt where Active__c = true AND  End_Date__c >= TODAY AND Start_Date__c <= TODAY];
        List<HMA_RecordType__mdt> recordTypeList2 = [SELECT Active__c,Description__c,DeveloperName,End_Date__c,Id,Label,MasterLabel,RecordType_Id__c,Start_Date__c
                                                        FROM HMA_RecordType__mdt where Active__c = true AND  End_Date__c = null];
        recordTypeList1.addAll(recordTypeList2);
        returnMap.put('RecordTypes',recordTypeList1);
        return returnMap;
    }   
}