/**
 * @description       : This controls the MARS Agency and access request logic
 * @author            : Sravan Reddy Pinninti
 * @group             : 
 * @last modified on  : 03-21-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   03-21-2021   Sravan Reddy Pinninti   
**/
public without sharing class MARS_UserAgencyAccess_Ctrl {
    @AuraEnabled(cacheable=true)
    public static map<string,list<AgencyWrapper>> getAgenciesList() {
        map<string, list<AgencyWrapper>> agenciesMap = new map<string, list<AgencyWrapper>>();
        list<AgencyWrapper> approvedAgencies = new list<AgencyWrapper>();
        list<AgencyWrapper> pendingAgencies = new list<AgencyWrapper>();

        AgencyWrapper agency;
        for( AccountContactRelation acr: [SELECT id,AccountId, Relationship_Strength__c, account.Name, account.MACS_ID__c,
                                                    Account.Chief_Name__c, Account.BillingCity
                                            FROM AccountContactRelation 
                                           WHERE ContactId IN (SELECT ContactId FROM User where id =: userinfo.getUserId())
                                           AND isActive = true]) {
            agency = new AgencyWrapper();
            agency.agencyName = acr.account.Name;
            agency.agencyMACSId = acr.account.MACS_ID__c;
            agency.agencyId = acr.AccountId;
            agency.userAccessLevel = acr.Relationship_Strength__c; 
            agency.approvalStatus = 'Approved';
            agency.chiefName = acr.Account.Chief_Name__c;
            agency.city = acr.Account.BillingCity;
            approvedAgencies.add(agency);
        }

        for( User_Registration__c ur: [select id, Fire_Agency__c, Access_Level__c, 
                                        Fire_Agency__r.Name,  Fire_Agency__r.MACS_ID__c,
                                        Fire_Agency__r.Chief_Name__c, Fire_Agency__r.BillingCity
                                        from User_Registration__c 
                                        where Recordtype.DeveloperName = 'MARS'
                                        AND User__c = :Userinfo.getUserId()
                                        AND  Status__c LIKE '%Requested%']) {
            agency = new AgencyWrapper();
            agency.agencyName = ur.Fire_Agency__r.Name;
            agency.agencyMACSId = ur.Fire_Agency__r.MACS_ID__c;
            agency.agencyId = ur.Fire_Agency__c;
            agency.userAccessLevel = ur.Access_Level__c;
            agency.approvalStatus = 'Pending';
            agency.chiefName = ur.Fire_Agency__r.Chief_Name__c;
            agency.city = ur.Fire_Agency__r.BillingCity;
            pendingAgencies.add(agency);
        }
        agenciesMap.put('ApprovedAgencies', approvedAgencies);
        agenciesMap.put('PendingAgencies', pendingAgencies);

        return agenciesMap;
    }

    @AuraEnabled
    public static void submitNewAgencyAccessRequest(string accessLevel, string accountId){
        try {
            User userRec =  ApexUtils.getCurrentUserDetails();
            User_Registration__c registration = new User_Registration__c();
            registration.RecordtypeId = Schema.SObjectType.User_Registration__c.getRecordTypeInfosByDeveloperName().get('MARS').getRecordTypeId();
            registration.First_Name__c =  userRec.FirstName;
            registration.Last_Name__c = userRec.LastName;
            registration.Email__c = userRec.Email;
            registration.Fire_Agency__c = accountId;
            registration.Status__c = 'Additional Agency Requested';
            registration.Entity_Type__c = 'Fire Agency';
            registration.Access_Level__c = accessLevel;
            registration.Contact_Name__c = userRec.ContactId;
            registration.User__c = UserInfo.getUserId();
            registration.OwnerId = KeyValueHelper.getTextValue('MARS_User_Request_Approval_Queue');//'00G35000001WF88'; //To-Do Query the Queue and get the Id
        

            insert registration;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void submitChangeAgencyAccessRequest(string accessLevel, string accountId){
        try {
            User userRec =  ApexUtils.getCurrentUserDetails();
            User_Registration__c registration = new User_Registration__c();
            registration.RecordtypeId = Schema.SObjectType.User_Registration__c.getRecordTypeInfosByDeveloperName().get('MARS').getRecordTypeId();
            registration.First_Name__c =  userRec.FirstName;
            registration.Last_Name__c = userRec.LastName;
            registration.Email__c = userRec.Email;
            registration.Fire_Agency__c = accountId;
            registration.Status__c = 'Access Level Change Requested';
            registration.Entity_Type__c = 'Fire Agency';
            registration.Access_Level__c = accessLevel;
            registration.Contact_Name__c = userRec.ContactId;
            registration.User__c = UserInfo.getUserId();
            registration.OwnerId = KeyValueHelper.getTextValue('MARS_User_Request_Approval_Queue');//'00G35000001WF88'; //To-Do Query the Queue and get the Id
        

            insert registration;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /***********************************************
    * Method Name : apexSearchFireAgency
    * Author : Sravan Reddy Pinninti
    * Inputs : String searchTerm, List<String> selectedIds
    * Description: This method return list of LookupSearchResult from Accounts with Entity Type Fire Agency but exclude the 
                    ones that user already has access to or pending approval on
    *********************************************/
    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> apexSearchFireAgency(String searchTerm, List<String> selectedIds) {
        //Make sure to exclude the accounts that user already have acess to
        set<Id> existingAgencies = new set<Id>();
        for(AccountContactRelation acr: [SELECT Id, AccountId FROM AccountContactRelation
                                          WHERE ContactId IN 
                                          (SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId())
                                          AND isActive = true
                                          ]){
            existingAgencies.add(acr.AccountId);

        }
        
        //exclude the accounts that user is currently waiting on approval
        for( User_Registration__c ur: [SELECT id, Fire_Agency__c
                                        FROM User_Registration__c 
                                        WHERE Recordtype.DeveloperName = 'MARS'
                                        AND User__c = :Userinfo.getUserId()
                                        AND  Status__c LIKE '%Requested%']) {
        
            existingAgencies.add(ur.Fire_Agency__c);
        }

        String fireAgency = 'Fire Agency';
        String query = 'Select Id,Name From Account';
        searchTerm = searchTerm.replace(' ','%');
        query += ' Where Entity_Type__c = \'' + fireAgency + '\'';
        if(String.isNotEmpty(searchTerm)) {
            query += ' AND ( Name like\'%' + searchTerm + '%\' OR MACS_ID__c  like\'%' + searchTerm + '%\' )';
        }
        if(!existingAgencies.isEmpty()){
            query += ' AND Id NOT IN : existingAgencies ';
        }
        query += ' Limit ' + 500;
        List<Account> accounts = Database.query(query);
        List<LookupSearchResult> results = new List<LookupSearchResult>();
        String accountIcon = 'standard:account';
        for (Account opAccountReference : accounts) {
            results.add(
                    new LookupSearchResult(
                            opAccountReference.Id,
                            'Account',
                            accountIcon,
                            opAccountReference.Name,
                            null,
                            opAccountReference
                    )
            );
        }

        // Optionnaly sort all results on title
        results.sort();
        return results;
    }

    public class AgencyWrapper {
        @AuraEnabled
        public string agencyName;
        @AuraEnabled
        public string agencyId;
        @AuraEnabled
        public string userAccessLevel;
        @AuraEnabled
        public string agencyMACSId;
        @AuraEnabled
        public string approvalStatus;
        @AuraEnabled
        public string chiefName;
        @AuraEnabled
        public string city;
    }
}