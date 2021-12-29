public without sharing class MARS_Agency_Personnel_Ctrl {


    @AuraEnabled(cacheable=true)

    public static List<AccountContactRelation> getAgenciesUsersList(String accountId) {

        List<AccountContactRelation> agencyAdminList = 
        [SELECT  Id, Relationship_Strength__c, AccountId, Account.Name, 
        ContactId, Contact.FirstName, Contact.LastName,Contact.Phone, Contact.Email, IsActive 
        FROM AccountContactRelation WHERE AccountId =: accountId ];

        return agencyAdminList;

    }


    @AuraEnabled(cacheable=true)

    public static List<User_Registration__c> getPendingAgenciesUsersList(String accountId) {

        
        List<User_Registration__c> agencyPendingList = 
        [SELECT Id, First_Name__c, Last_Name__c, Access_Level__c, Email__c, Phone__c, Fire_Agency__c, Contact_Name__r.Phone 
        FROM User_Registration__c 
        WHERE
        (Status__c = 'App Requested' or Status__c = 'Access Level Change Requested' or Status__c = 'Additional Agency Requested') and (Fire_Agency__c =: accountId )];

        return agencyPendingList;

    }

    @AuraEnabled(cacheable=true)

    public static AggregateResult[]  getPendingAgenciesUsersCount(String accountId) {

        
        AggregateResult[] agencyPendingList = 
        [SELECT COUNT(Id)  
        FROM User_Registration__c 
        WHERE
        (Status__c = 'App Requested' or Status__c = 'Access Level Change Requested' or Status__c = 'Additional Agency Requested') and (Fire_Agency__c =: accountId )];


        return agencyPendingList;

    }



    @AuraEnabled
    public static void submitUserAccessChangeRequest(string accessLevel, string accountId, string contactId){
        try {


            string newAccessLevel;

            if(accessLevel == 'Primary')
            {
                newAccessLevel='Secondary';
            }

            if(accessLevel == 'Secondary')
            {
                newAccessLevel='Primary';
            }


            //GET User Id from Contact Id
            User userChange = [SELECT Id,FirstName,LastName,Email FROM User WHERE  ContactId =: contactId LIMIT 1];           
            Group recordOwner = [SELECT Id, DeveloperName FROM Group WHERE DeveloperName ='MARS_User_Request_Approval'];
            User_Registration__c registration = new User_Registration__c();
            registration.RecordtypeId = Schema.SObjectType.User_Registration__c.getRecordTypeInfosByDeveloperName().get('MARS').getRecordTypeId();
            registration.First_Name__c =  userChange.FirstName;
            registration.Last_Name__c = userChange.LastName;
            registration.Email__c = userChange.Email;
            registration.Fire_Agency__c = accountId;
            registration.Status__c = 'Access Level Change Requested';
            registration.Entity_Type__c = 'Fire Agency';
            registration.Access_Level__c = newAccessLevel;
            registration.Contact_Name__c = contactId;
            registration.User__c = userChange.Id; 
            //registration.OwnerId = '00G35000001WF88'; //To-Do Query the Queue and get the Id
            registration.OwnerId = userChange.Id;
            insert registration;

            registration.Status__c = 'Access Level Change Approved';

            update registration;


            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void submitUserAccessApproveRequest(string userregid){
        try {



            User_Registration__c ur = [SELECT Id, Status__c
                                                    FROM User_Registration__c
                                                    WHERE Id = :userregid
                                                     LIMIT 1];


            string newAccessLevel;

            if(ur.Status__c == 'App Requested')
            {
                newAccessLevel='App Approved';
            }

            if(ur.Status__c == 'Access Level Change Requested')
            {
                newAccessLevel='Access Level Change Approved';
            }

              ur.Status__c = newAccessLevel;

            update ur;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void submitUserAccessRejectRequest(string userregid){
        try {

            User_Registration__c ur = [SELECT Id, Status__c
                                                    FROM User_Registration__c
                                                    WHERE Id = :userregid
                                                     LIMIT 1];

              string newAccessLevel;

              if(ur.Status__c == 'App Requested')
              {
                  newAccessLevel='App Rejected';
              }
  
              if(ur.Status__c == 'Access Level Change Requested')
              {
                  newAccessLevel='Access Level Change Rejected';
              }
  
                ur.Status__c = newAccessLevel;


            update ur;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static void submitRemoveUserAccessRequest(string accessLevel, string accountId, string contactId){
        try {


            AccountContactRelation acr = [SELECT Id, AccountId, ContactId, Relationship_Strength__c 
                                                    FROM AccountContactRelation
                                                    WHERE AccountId = :accountId
                                                    AND ContactId = :contactId LIMIT 1];

              acr.IsActive = false;
            update acr;                                 

           
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void submitAddUserAccessRequest(string accessLevel, string accountId, string contactId){
        try {


            AccountContactRelation acr = [SELECT Id, AccountId, ContactId, Relationship_Strength__c 
                                                    FROM AccountContactRelation
                                                    WHERE AccountId = :accountId
                                                    AND ContactId = :contactId LIMIT 1];

              acr.IsActive = true;
            update acr;                                 

           
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled public static Boolean getRelationshipStrength(String accountId) {
        User userRec = [ SELECT Id, ContactId FROM User WHERE Id
                        =:UserInfo.getUserId() LIMIT 1 ];
        AccountContactRelation acr = [
            SELECT Id,
            Relationship_Strength__c FROM AccountContactRelation WHERE ContactId
            =:userRec.ContactId AND AccountId
            =:accountId LIMIT 1
        ];
        return acr.Relationship_Strength__c == 'Primary';
    }


}