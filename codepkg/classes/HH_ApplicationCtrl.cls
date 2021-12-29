public with sharing class HH_ApplicationCtrl {



     /***********************************************
    * Method Name : getApplicationRecord
    * Author : Shantanu
    * Inputs : String applicationId(HH_Application__c)
    * Description: This method return's Application and related records
    *********************************************/
    @AuraEnabled
    public static Map<String,Object> getApplicationRecord(String applicationId) {
        Map<String,Object> result = new Map<String,Object>();
        HH_Application__c app = new HH_Application__c();
        //check is current user is homeowner
        Boolean isHomeowner = isHomeowner();
        if(applicationId != null) {
           app =  queryApplication(applicationId);
        }  else {
            if(isHomeowner) {
                app.Applicant__r  = getHomeownerContactDetails();
            }
        }
        List<Funded_Program__c> fundedPrograms = new List<Funded_Program__c>();
        if(applicationId != null) {
            fundedPrograms = [SELECT Id, Name, Date_Funding_Received__c, Other_Program_Name__c,
            HH_Application__c, Program_Name__c FROM Funded_Program__c
                                                    WHERE HH_Application__c =: applicationId];
            
        }
        result.put('application', app);
        
        List<Application_Contact__c> memberAppContacts = new List<Application_Contact__c>();
        List<Application_Contact__c> deedAppContacts = new List<Application_Contact__c>();
        //separate out household members and co owners
        for(Application_Contact__c ac : getApplicationContacts(applicationId)) {
            if (ac.Role__c == HH_CONSTANTS.HH_Application_Contact_HouseHoldMember) {
                memberAppContacts.add(ac);
            } else if (ac.Role__c == HH_CONSTANTS.HH_Application_Contact_Co_Owner) {
                deedAppContacts.add(ac);
            }
        }

        List<HHDocument> documents = new SystemContextProvider().getDocuments(applicationId); 
        //add all the required data related to application in to result map
        result.put('appContacts',memberAppContacts);
        result.put('deedContacts',deedAppContacts);
        result.put('fundedPrograms', fundedPrograms);
        result.put('documents', documents);
        result.put('userLanguage',UserInfo.getLanguage());
        result.put('houseHoldNumber',app.Applicant__r.Account.Account_Name__c);
        result.put('isHomeowner', isHomeowner);
        result.put('isExternalUser', isExternalUser());
        return result;
    }

    /***********************************************
    * Method Name : isExternalUser
    * Author : Shantanu
    * Inputs : 
    * Description: This method check current user is external or not.
    *********************************************/ 
    private static Boolean isExternalUser() {
        User user = [SELECT Id,AccountId FROM User WHERE Id=:UserInfo.getUserId()];
        return user.AccountId != null;  
    }

    /***********************************************
    * Method Name : isHomeOwner
    * Author : Shantanu
    * Inputs : 
    * Description: This method check current user Permission is Homeowner or not.
    *********************************************/
    private static Boolean isHomeowner() {
        List<PermissionSetAssignment> currentUserPermissionList = [SELECT Id, PermissionSetId, PermissionSet.Name,AssigneeId FROM PermissionSetAssignment WHERE AssigneeId =: UserInfo.getUserId() AND PermissionSet.Name =:HH_CONSTANTS.HH_PermissionSet_HomeOwner_APIName];
        if(currentUserPermissionList.size() > 0) {
            for(PermissionSetAssignment currentUserPermission: currentUserPermissionList) {
            if(currentUserPermission.PermissionSet.Name == HH_CONSTANTS.HH_PermissionSet_HomeOwner_APIName) {
                return true;
            }
        }
        }
        return false;
    }

    /***********************************************
    * Method Name : queryApplication
    * Author : Shantanu
    * Inputs : String applicationId(HH_Application__c)
    * Description: This method return's Application and related records
    *********************************************/
    private static HH_Application__c queryApplication(String applicationId) {
        return [SELECT Id, Name, Property_Owner__c, Property_Structure__c, Car_Ownership__c, Currently_Occupied__c,
                    Damage_Description__c, Ethnicities_of_Household_Members__c, Is_Anyone_65__c, Is_Anyone_Age_5_and_Under__c,
                    Is_Anyone_has_Disabilities__c, Property_Currently_Damaged__c, Rental_Property__c,
                    Agreement_Disclosure__c, Primary_Residence__c, Accessible_by_a_Passenger_Vehicle__c, Any_Other_Names_on_the_Property_Deed__c, 
                    Anyone_Not_a_Proficient_English_Speaker__c, Assessed_Value_of_the_Property__c, Assistance_to_reduce_yo__c,
                City__c, County__c, Property_Street_Address__c,
                    State__c, Zip_Postal_Code__c, Authority_to_make_updates_to_the_Home__c, Year_of_Construction__c, Total_Living_Area__c,
                    Number_of_Stories__c, Is_National_Register_of_Historic_Places__c,
                    Property_Foreclosed_or_in__c, Property_Liens__c,Good_Standing_with_a_payment_plan_on_you__c,
               Measures_to_Reduce_risks_to_wi__c, Did_you_receive_wildfire_assistance__c, Stage__c, Status__c,  List_of_Measures__c, Which_program_s_and_when__c, Program__c,
                Applicant__r.AccountId, Applicant__r.Account.Name, Applicant__r.Account.Account_Name__c, Applicant__r.FirstName,
                Applicant__r.Physical_Street__c,Applicant__r.Physical_City__c,Applicant__r.Physical_State__c, Applicant__r.Physical_Country__c,Applicant__r.Physical_Zip_Postal_Code__c,
                Applicant__r.Email, Applicant__r.Phone,Applicant__r.LastName,
                Applicant__r.Is_Physical_Address_a_Foreign_Address__c, Applicant__r.Is_Mailing_Address_a_Foreign_Address__c,
                Applicant__r.Is_Mailing_Address_Different__c, Applicant__r.Preferred_Language__c, Applicant__r.OtherPhone,
                Applicant__r.MailingStreet,Applicant__r.MailingCity,Applicant__r.MailingState,
                Applicant__r.MailingCountry, Applicant__r.MailingPostalCode,OwnerId,
                Applicant__r.English_Language_Proficiency__c, Applicant__r.MobilePhone, Applicant__r.HomePhone, Unique_Household_Number__c,Household_Members__c 
                FROM HH_Application__c WHERE Id =:applicationId LIMIT 1];    
        } 

     /***********************************************
    * Method Name : getHomeownerContactDetails
    * Author : Shantanu
    * Description: This method return's Homeowner Contact record
    *********************************************/
    private static Contact getHomeownerContactDetails() {
        List<User> users =  [SELECT Id, AccountId, Account.Name, Account.Account_Name__c, Contact.AccountId, Contact.Account.Name, Contact.Account.Account_Name__c, ContactId, Contact.FirstName, Contact.Email, Contact.Phone,
        Contact.LastName, Contact.Is_Physical_Address_a_Foreign_Address__c, Contact.Is_Mailing_Address_a_Foreign_Address__c, Contact.Is_Mailing_Address_Different__c, Contact.Preferred_Language__c,
        Contact.Physical_Street__c,Contact.Physical_City__c,Contact.Physical_State__c, Contact.Physical_Country__c,Contact.Physical_Zip_Postal_Code__c,
        Contact.OtherPhone, Contact.MailingStreet,Contact.MailingCity,
                            Contact.MailingState, Contact.MailingCountry, Contact.MailingPostalCode,
        Contact.English_Language_Proficiency__c, Contact.MobilePhone,Contact.HomePhone  FROM User WHERE Id=:UserInfo.getUserId() WITH SECURITY_ENFORCED];
        return users.get(0).Contact;
    }


    /***********************************************
    * Method Name : getApplicationContacts
    * Author : Shantanu
    * Inputs : Application Record Id -  recordId
    * Description: This method get related contacts for Application
    *********************************************/
    private Static List<Application_Contact__c> getApplicationContacts(String recordId) {
        return [SELECT Id,Head_of_Household__c, Relationship_to_Homeowner__c, Annual_Income__c, Date_of_Birth__c,Contact__r.FirstName,
                Contact__r.LastName, Contact__r.AccountId, HH_Application__c, Role__c FROM Application_Contact__c WHERE HH_Application__c=:recordId WITH SECURITY_ENFORCED];
    }

    /***********************************************
    * Method Name : saveApplication
    * Author : Shantanu
    * Inputs : recordJSON
    * Description: This method upsert Application and related record and return map of Applcation and related records
    *********************************************/
    @AuraEnabled
    public static Map<String, Object> saveApplication(String applicationDataJSON, String houseHoldNumber, Boolean isSubmit, String currentStage) {
        Map<String,Object> result = new Map<String,Object>();
        try {
            System.debug('recordData: '+applicationDataJSON);
            HH_Application__c applicationRec = (HH_Application__c)JSON.deserialize(applicationDataJSON, HH_Application__c.class);
            
            List<Application_Contact__c> appContacts = applicationRec.Application_Contacts__r;
            List<Funded_Program__c> fundedPrograms = applicationRec.Funded_Programs__r;
            List<Document__c> documents = applicationRec.Documents__r;
            //check if application new or old application
            if(applicationRec.Applicant__r != null ) {
                Contact contact = applicationRec.Applicant__r;
                //if its new and current user is community user  who is creating application on behalf of homeowner
                //create contact and account for that homeowner (if  household no. provided then search 
                //for that account and attach contact to that account.)
                if(applicationRec.Id == null && !isHomeowner()) {
                    Map<String,String> resultMap =  createAccountAndContact(contact,houseHoldNumber) ; 
                    contact.Id = resultMap.get('contactId'); 
                    contact.AccountId = resultMap.get('accountId');
                }
                System.debug('Contact: '+contact);
                new SystemContextProvider().upsertContact(contact);
                //attach that contact to Appliation.
                applicationRec.Applicant__c = contact.Id;
                applicationRec.Applicant__r = contact;
            }
            //if application Stage is empty mark it as Draft Stage.
            if(String.isEmpty(applicationRec.Stage__c)) {
                applicationRec.Stage__c = HH_CONSTANTS.HHApplication_Stage_Draft;
            }

         
            System.debug('Applicant: ' + applicationRec.Applicant__r);
            //if application is not editable then throw error message.
            
            if(applicationRec.Id != null && !HH_EditRequestCtrl.isApplicationEditable(applicationRec.Id)) {
            throw new CustomException('Application not editable');
            }
            //calculate the total annual income from household members.
            applicationRec.Total_Annual_Income__c = 0;
            if(appContacts != null && appContacts.size() > 0 ) {
               Integer numberOfHouseholdMembers = 0;
                for(Application_Contact__c ac : appContacts) {
                    if(ac.Annual_Income__c != null) {
                        applicationRec.Total_Annual_Income__c += ac.Annual_Income__c;
                       numberOfHouseholdMembers++;
                    }
                }
               applicationRec.Household_Members__c = numberOfHouseholdMembers; 
            }
           if(isSubmit == false) {
            new SystemContextProvider().upsertApplication(applicationRec);
           }
            System.debug('Application Record: '+applicationRec);
            System.debug('Application Contacts: ' + appContacts);
            Id applicationAccountId = applicationRec.Applicant__r.AccountId;
            //delete the Application Contacts which are removed from UI .
            deleteAppContacts(applicationRec.Id,appContacts,applicationRec.Applicant__c);
            if (appContacts == null || appContacts.size() == 0) {
                //result.put('appContacts',new List<Application_Contact__c>());
            } else {
                //while creating application contact check if provided contact  already exist in household account.
                //If yes, then attach that contact to Application contact.
                checkExistingAccountContacts(appContacts, applicationRec.Applicant__r.AccountId, applicationRec.Applicant__c);
            Map<Application_Contact__c,Contact> appContToContact = new Map<Application_Contact__c,Contact>();
           
            for (Application_Contact__c appContact : appContacts) {
                appContact.HH_Application__c = applicationRec.Id;
                    if(appContact.Role__c ==HH_CONSTANTS.HH_Application_Contact_HouseHoldMember) {
                        appContact.Contact__r.AccountId =  applicationRec.Applicant__r.AccountId;
                    }
                if(appContact.Contact__r.Id == null && appContact.Contact__r.Contact_Type__c == null) {
                    appContact.Contact__r.Contact_Type__c = HH_CONSTANTS.HH_Contact_Type_Others;
                }
                appContToContact.put(appContact,appContact.Contact__r);
            }
            
            if (appContToContact.size() > 0) {
                //upserting the contacts
                    new SystemContextProvider().upsertContacts(appContToContact.values());
                for (Application_Contact__c appC : appContToContact.keySet()) {
                    appC.Contact__c =appC.Contact__r.Id;
                }
                //upsert Application Contact
                    new SystemContextProvider().upsertApplicationContact(new List<Application_Contact__c> (appContToContact.keySet()));
                   
                    for (Application_Contact__c ap : appContToContact.keySet()) {
                    }
                   
                    result.put('appContacts',appContToContact.keySet());
                }
            
            }       
              
            //Delete programs which are removed from UI.
            deleteFundedPrograms(applicationRec.Id,fundedPrograms);   
            if(fundedPrograms.size() > 0) {
                for(Funded_Program__c fp : fundedPrograms) {
                    fp.HH_Application__c = applicationRec.Id;
                }
                upsert fundedPrograms;
            }
            //if we click submit and Stage is Draft and Change Stage to Community Review.
           updateTotalAnnualIncome(applicationRec);
            if(applicationRec.Agreement_Disclosure__c == true && isSubmit) {
                if(applicationRec.Stage__c == HH_CONSTANTS.HHApplication_Stage_Draft) {
                    if(applicationRec.Status__c == null || applicationRec.Status__c == HH_CONSTANTS.HHApplication_Status_New) {
                        applicationRec.Submission_Date__c = System.now();
                    }
                    applicationRec.Stage__c = HH_CONSTANTS.HHApplication_Stage_CommunityReview;
                    applicationRec.Applicant_s_Name__c = applicationRec.Applicant__r.FirstName + ' ' + applicationRec.Applicant__r.LastName;
                }
                update applicationRec;
                //once the application goes in community review share the account with Communiy county group and CAL OES group.
                shareAccountRecordWithGroups(applicationRec.Applicant__r.AccountId, applicationRec.Applicant__c,applicationRec.County__c);
                //shareDocumentRecordWithGroups(applicationRec.Id,applicationRec.County__c);
                List<Document__c> docList = [SELECT Id,HH_Application__c FROM Document__c WHERE HH_Application__c =:applicationRec.Id];
                DocumentTriggerHelper docTrig = new DocumentTriggerHelper();
                docTrig.shareHHDocuments(docList);
               System.debug('Application Submitted...');
            }
            result.put('application', applicationRec);
        } catch (Exception e) {
            System.debug(e.getStackTraceString());
           System.debug(e.getMessage());
            System.debug('Application save Record Exception: '+e);
            if(Test.isRunningTest()) {
                throw e;
            }
           throw new CustomException(CustomExceptionController.getSpecificErrorMessage(e.getMessage()));
        }
        //system.debug('Save result :'+ result);
        return result;
    }

     /***********************************************
    * Method Name : deleteAppContacts
    * Author : Shantanu
    * Inputs : app Id, application contacts
    * Description: This method will delete existings Application contacts which are deleted from UI.
    *********************************************/
    private static void deleteAppContacts(String applicationId, List<Application_Contact__c> appContacts, String applicantId)  {
        List<String> existingAppContactIds = new List<String>();
        for (Application_contact__c appContact : appContacts) {
            if(String.isNotEmpty(appContact.Id)) {
                existingAppContactIds.add(appContact.Id);
            }    
        }
        List<Application_Contact__c> appContactsToDelete = new List<Application_Contact__c>();
        if (appContacts.size() == 0 && existingAppContactIds.size() == 0) {
            appContactsToDelete = [SELECT Id,Contact__c FROM Application_Contact__c WHERE HH_Application__c=:applicationId];
        } else {
            appContactsToDelete = [SELECT Id,Contact__c FROM Application_Contact__c WHERE HH_Application__c=:applicationId AND Id NOT IN :existingAppContactIds];
        }
        List<Contact> contactsToDelete = new List<Contact>();
        if (appContactsToDelete.size() > 0 ) {
            for(Application_Contact__c appContact : appContactsToDelete) {
                if(appContact.Contact__c != null && appContact.Contact__c != applicantId) {
                    contactsToDelete.add(new Contact(Id=appContact.Contact__c));
                }
            }
            delete appContactsToDelete;
        if (contactsToDelete.size() > 0 ) {
                new SystemContextProvider().deleteContacts(contactsToDelete);
            }
    }
    }

   
     /***********************************************
    * Method Name : deleteFundedPrograms
    * Author : Shantanu
    * Inputs : HH_Application__c appRecord
    * Description: This method will delete existings Funded Programs which are deleted from UI.
    *********************************************/
    private static void deleteFundedPrograms(String applicationId, List<Funded_Program__c> fundedPrograms)  {
        List<String> existingFundedProgIds = new List<String>();
        for (Funded_Program__c appContact : fundedPrograms) {
            if(String.isNotEmpty(appContact.Id)) {
                existingFundedProgIds.add(appContact.Id);
            }    
        }
        List<Funded_Program__c> fpToDelete = new List<Funded_Program__c>();
        if (fundedPrograms.size() == 0 && existingFundedProgIds.size() == 0) {
            fpToDelete = [SELECT Id FROM Funded_Program__c WHERE HH_Application__c=:applicationId];
        } else {
            fpToDelete = [SELECT Id FROM Funded_Program__c WHERE HH_Application__c=:applicationId AND Id NOT IN :existingFundedProgIds];
        }
        if(fpToDelete.size() > 0) {
            delete fpToDelete;
        }
    }

    /***********************************************
    * Method Name : deleteDocument
    * Author : Shantanu
    * Inputs : Id documentId,Content Document Id
    * Description: This method will delete Content Document related to Record.
    *********************************************/
    @AuraEnabled
    public static void deleteDocument(String documentId, String conDocId) {
        new SystemContextProvider().deleteDocument(documentId, conDocId);
    }


    /***********************************************
    * Method Name : saveFileDetails
    * Author : Shantanu
    * Inputs : String documentRecordId
    * Description: This method will update Document Record. 
    *********************************************/
    @AuraEnabled
    public static void updateDocumentRecord(String documentRecordId, String fileName) {
        new SystemContextProvider().updateDocumentRecord(documentRecordId, fileName);
    }
   
    /***********************************************
    * Method Name : checkExistingAccountContact
    * Author : Shantanu
    * Inputs : List<Application_Contact__c> appContacts
    * Description: This will check existing contact and will attached contact to Application_Contact whose lastname is matches to avoid duplication.
    *********************************************/
    public static void checkExistingAccountContacts(List<Application_Contact__c> appContacts, String  accountId, String applicantId){
        if(appContacts.size() == 0) {
            return;
        }
        
        List<Contact> contacts = [SELECT Id,FirstName,LastName,Contact_Type__c FROM Contact WHERE AccountId=:accountId];
        Map<String,Id> existingAccContactMap = new Map<String,Id>();
        Map<String,Id> existingApplicantContactMap = new Map<String,Id>();
        for (Contact contact : contacts) {
            if(contact.Contact_Type__c != HH_CONSTANTS.HH_Contact_Type_Homeowner && contact.FirstName != null && contact.LastName != null){
                existingAccContactMap.put(contact.FirstName.toLowerCase()+'#'+contact.LastName.toLowerCase(), contact.Id);
        }
            if(contact.Contact_Type__c == HH_CONSTANTS.HH_Contact_Type_Homeowner && contact.FirstName != null && contact.LastName != null) {
                existingApplicantContactMap.put(contact.FirstName.toLowerCase()+'#'+contact.LastName.toLowerCase(), contact.Id);
            }
        }
       
        System.debug('exsting: '+existingAccContactMap);
        for (Application_Contact__c ac : appContacts) {
            System.debug('ac: '+ac);
            if(ac.Role__c == HH_CONSTANTS.HH_Application_Contact_Co_Owner) {
                continue;
            }
            if(ac.Relationship_to_Homeowner__c == HH_CONSTANTS.Relationship_to_Homeowner_Self) {
                Id existingApplicantId = existingApplicantContactMap.get(ac.Contact__r.FirstName.toLowerCase()+'#'+ac.Contact__r.LastName.toLowerCase());
                if(existingApplicantId != null ) {
                    ac.Contact__r.Id = applicantId;
                }  else if (applicantId == ac.Contact__r.Id) {
                    ac.Contact__r.Id = null;
                }
            }
        }
    }

    /***********************************************
        * Method Name : createDocumentRecord
        * Author : Sushant
        * Inputs : documentType, ApplicationId
        * Description: This method will Create New Document record.
        */
    @AuraEnabled
    public static void createDocumentRecord(String documentType, String ApplicationId) {
        Document__c doc = new Document__c();
        doc.Document_Name__c = documentType+' Document - Manual';
        doc.HH_Application__c = ApplicationId;
        doc.Is_Required__c = HH_CONSTANTS.Document_IsRequired_Required;
        doc.Document_Type__c = documentType;
        insert doc;
    }

     /***********************************************
    * Method Name : updateTotalAnnualIncome
    * Author : Shantanu
    * Inputs : applicationId
    * Description: This method will update Application with total AnnualIncome.
    */
    public static void updateTotalAnnualIncome(HH_Application__c app) {
        AggregateResult[] groupedResults
        = [SELECT HH_Application__c ,SUM(Annual_Income__c) 
            FROM Application_Contact__c 
            WHERE HH_Application__c = :app.Id GROUP BY HH_Application__c ];
        for (AggregateResult ar : groupedResults)  {
            app.Total_Annual_Income__c = (Decimal)ar.get('expr0');
            break;
        }
    }

    /***********************************************
    * Method Name : createAccountAndContact
    * Author : Ricky
    * Inputs : 1. String contactDetails - Serialized Contact record details need to be created/Updated.
     *          2. String uniqueHouseholdNumber - Unique Household Number - Can be null/Value
    * Description: This method will update Application with total AnnualIncome.
    *********************************************/
    @AuraEnabled
    public static Map<String, String> createAccountAndContact(Contact contactDetails, String uniqueHouseholdNumber) {
        /** Map collection to store Contact Id as Key and Unique Household Number as Value in order to return upon execution of method. */
        Map<String, String> resultMap = new Map<String, String>();
        /** Contact object instance to store the deserialized Contact Details sent from Application Page. */
        //Contact contactRecordToUpsert = new Contact();
        /** Condition to check if the contactDetails has data in it before Deserializing it. */
        if (contactDetails != null) {
            //contactRecordToUpsert = (Contact) JSON.deserialize(contactDetails, Contact.class);
            /** Condition to check if the Contact record already has ID then just updating the Contact record. */
               
            if (contactDetails.Id != null) {
                update contactDetails;
                /** Putting the Contact Id and Unique Household Number into the Map collection for returning it. */
                resultMap.put('contactId',contactDetails.Id);
                resultMap.put('accountId', contactDetails.AccountId);
            }
            else {
                /** If Unique Household Number is provided on Application Page,
                 * then searching for the Account with the Unique Household Number provided.
                 * 1. If the Account record found in the System, then associating Contact with the Account before inserting it.
                 * 2. If the Account record not Found in the System ,
                 *      then creating new Account by generating a new Unique Household Number and associating Contact record with this Account. */
                if (uniqueHouseholdNumber != null && uniqueHouseholdNumber != '') {
                    String AccountName = HH_CONSTANTS.Account_HOUSEHOLD_Name + '-' + uniqueHouseholdNumber;
                    List<Account> accountRecord = [SELECT Id, Name FROM Account WHERE Name =: AccountName LIMIT 1];
                    Account accountToInsert = new Account();
                    if (accountRecord?.size() == 0) {
                        uniqueHouseholdNumber = SkyWalkerUtility.generateToken(6);
                        accountToInsert.Name = HH_CONSTANTS.Account_HOUSEHOLD_Name + '-' + uniqueHouseholdNumber;
                        accountToInsert.Account_Name__c = uniqueHouseholdNumber;
                        new SystemContextProvider().insertAccount(accountToInsert);
                        try {
                            contactDetails.AccountId = accountToInsert.Id;
                            contactDetails.Contact_Type__c = HH_CONSTANTS.HH_Contact_Type_Homeowner;
                            new SystemContextProvider().upsertContact(contactDetails);
                        }
                        catch (Exception e) {
                            System.debug(e);
                           throw new customException(e.getMessage());
                        }
                    }
                    else if(accountRecord?.size() == 1) {
                       List<Contact> contacts = [SELECT Id, Firstname, Email FROM Contact WHERE AccountId =:accountRecord.get(0).Id AND Email =:contactDetails.Email];
                       if(contacts.size() > 0) {
                           contactDetails.Id = contacts.get(0).Id;
                       }
                        contactDetails.AccountId = accountRecord[0].Id;
                        contactDetails.Contact_Type__c = HH_CONSTANTS.HH_Contact_Type_Homeowner;
                        try {
                            new SystemContextProvider().upsertContact(contactDetails);
                        }
                        catch (Exception e) {
                            System.debug('exception: '+ e);
                           throw new customException(e.getMessage());
                        }
                    }
                    /** Putting the Contact Id and accountId into the Map collection for returning it. */
                    System.debug('ContactDetails: '+contactDetails);
                    resultMap.put('contactId',contactDetails.Id);
                    resultMap.put('accountId', contactDetails.AccountId);
                    System.debug('resultMap: '+resultMap);
                }
                /** If Unique Household Number is not provided on Application Page,
                 * then creating new Account by generating a new Unique Household Number and associating Contact record with this Account. */
                else {
                    Account accountToInsert = new Account();
                    uniqueHouseholdNumber = SkyWalkerUtility.generateToken(6);
                    accountToInsert.Name = HH_CONSTANTS.Account_HOUSEHOLD_Name + '-' + uniqueHouseholdNumber;
                    accountToInsert.Account_Name__c = uniqueHouseholdNumber;
                    new SystemContextProvider().insertAccount(accountToInsert);

                    try {
                        contactDetails.AccountId = accountToInsert.Id;
                       	contactDetails.Contact_Type__c = HH_CONSTANTS.HH_Contact_Type_Homeowner;
                        new SystemContextProvider().upsertContact(contactDetails);
                    }
                    catch (Exception e) {
                       throw new CustomException(e.getMessage());
                    }
                    /** Putting the Contact Id and accountId into the Map collection for returning it. */
                    resultMap.put('contactId',contactDetails.Id);
                    resultMap.put('accountId', contactDetails.AccountId);
                }
            }
        }
        if(resultMap.get('accountId') != null) {
            String userCountyAccessName = null;
            Map<String,String> countyMap = getCommunityUserCounty();
            if(countyMap.size() > 0 && countyMap.get('county') != null) {
                userCountyAccessName = countyMap.get('county');
            }

            shareAccountRecordWithGroups(resultMap.get('accountId'),  resultMap.get('contactId'),userCountyAccessName);
        }
        /** Returning the Contact ID and Unique Household Number back. */
        System.debug('ResultMap: '+ resultMap);
        return resultMap;
    }

    /***********************************************
    * Method Name : getCommunityUserCounty
    * Author : Shantanu
    * Description: This method will provide county name based  on county it has access to.
    */
    @AuraEnabled
    public Static Map<String,String> getCommunityUserCounty() {
        Map<String,String> result = new Map<String,String>();
        if(isHomeowner()){
            result.put('county', null);
            return result;    
        }
       List<groupmember> members = [select group.DeveloperName from groupmember where group.Type = 'Regular' AND UserOrGroupid=:UserInfo.getUserId()];
        if(members.size() == 0) {
            result.put('county', null);
            return result;
        }
        List<County_Config__mdt> hhCountyConfigs = [SELECT Label, DeveloperName,
                                                     Application_Type__c, Public_Group_API_Name__c 
                                                     FROM County_Config__mdt 
                                                     WHERE Application_Type__c =:HH_CONSTANTS.HH_Application_APIName_CountyConfig 
                                                     AND Public_Group_API_Name__c =:members.get(0).Group.DeveloperName];
        if(hhCountyConfigs.size() == 0) {
            result.put('county', null);
            return result;
        }  
        result.put('county',hhCountyConfigs.get(0).Label);                                      
        return result;
    }
    
     /***********************************************
    * Method Name : shareAccountRecordWithGroups
    * Author : Shantanu
    * Description: This method will share the accoun record to  county group based on application county.
    **************************************************/
    public static void shareAccountRecordWithGroups(String accountId,String contactId, String countyName) {
        System.debug('accountId: '+accountId);
        System.debug('countyName: '+ countyName);
        List<String> groupsAPINames = new List<String>();
        if(countyName != null) {
            List<County_Config__mdt> counties = [SELECT Id,Label,Public_Group_API_Name__c FROM County_Config__mdt WHERE Label =:countyName];
           
            if(counties.size() > 0) {
                groupsAPINames.add(counties.get(0).Public_Group_API_Name__c);        
            }
        }
        groupsAPINames.add(HH_CONSTANTS.HH_CalOESInternal_User_Group_APIName);
        List<Group> groups = [SELECT Id FROM Group WHERE DeveloperName IN :groupsAPINames AND Type != 'Queue'];
        List<AccountShare> ashares = new List<AccountShare>();
      //  List<ContactShare> cshares = new List<ContactShare>();
        for( Group group1 : groups) {
            AccountShare aShare = new AccountShare(AccountId=accountId, UserOrGroupId=group1.Id, AccountAccessLevel='Edit', OpportunityAccessLevel='None'); 
          //  ContactShare cShare = new ContactShare(ContactId =contactId, UserOrGroupId =group1.Id,ContactAccessLevel='Edit');
            ashares.add(aShare);
          //  cshares.add(cshare);
        }       
        new SystemContextProvider().insertAccountShares(ashares);
    }
  


    public  without sharing class SystemContextProvider {

        public  void upsertContact(Contact contact) {
            upsert contact;
        }

        public  void upsertContacts(List<Contact> contacts) {
            upsert contacts;
        }

        public  void insertAccountShare(AccountShare aShare) {
            insert aShare;
        }

        public  void insertAccountShares(List<AccountShare> aShares) {
            insert aShares;
        }

        public  void upsertApplicationContact(List<Application_Contact__c> appContacts) {
            upsert appContacts;
        }

        public  void upsertApplication(HH_Application__c app) {
            upsert app;
        }

        public  void insertAccount(Account acc) {
            insert acc;
        }

        public  void insertApplication(HH_Application__c appRecord) {
            insert appRecord;
        }

        
        public  void deleteContacts(List<Contact> contactsToDelete) {
            delete contactsToDelete;
        }
        /***********************************************
        * Method Name : getDocuments
        * Author : Shantanu
        * Inputs : applicationId
        * Description: This method will provide docuemts information in a wrapper.
        *********************************************/
        public  List<HHDocument> getDocuments(String applicationId) {
            if(applicationId != null){
            List<HHDocument> hhDocuments = new List<HHDocument>();
            List<PermissionSetAssignment> permissionSetAssignments = [SELECT Id FROM PermissionSetAssignment WHERE PermissionSet.Name =: HH_CONSTANTS.HH_PermissionSet_HomeOwner_APIName AND Assignee.Id =:UserInfo.getUserId()];
                String documentTypeFilter ='';
                if(permissionSetAssignments.size() >0){
                    documentTypeFilter = ' AND Document_Type__c IN(\''+HH_CONSTANTS.Document_DocumentType_Rental+'\',\''+HH_CONSTANTS.Document_DocumentType_PropertyOwnerID+'\',\''+HH_CONSTANTS.Document_DocumentType_ProofOfOwnership+'\')';
                }
               String docQuery = 'SELECT Id,Name,toLabel(Stage__c),Comments__c,Is_Required__c,Date_Uploaded__c,Date_Time_Uploaded__c,Document_Name__c, toLabel(Document_Type__c) FROM Document__c WHERE HH_Application__c =:applicationId '+ documentTypeFilter +' ORDER BY Document_Name__c Desc';
                List<Document__c> documents = Database.query(docQuery);
                //List<Document__c> documents = [SELECT Id,Name,Stage__c,Is_Required__c,Date_Uploaded__c,Date_Time_Uploaded__c,Document_Name__c, Document_Type__c FROM Document__c WHERE HH_Application__c =:applicationId ORDER BY Document_Name__c ];
            if(documents.size() == 0) {
                return hhDocuments;
            }
            List<String> documentIds = new List<String>();
            for(Document__c doc : documents) {
                documentIds.add(doc.Id);
            }
            List<ContentDocumentLink> contentLinks  = [SELECT Id, ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN: documentIds];
            List<String> contentDocIds = new List<String>();
            Map<String,String> contentDocMap = new Map<String,String>();
            for(ContentDocumentLink cdl : contentLinks) {
                contentDocMap.put(cdl.LinkedEntityId,cdl.ContentDocumentId);
            }
            List<ContentVersion> contentVersions = [SELECT Id,ContentDocumentId,PathOnClient,IsLatest,FileType,VersionNumber from ContentVersion where IsLatest = true AND ContentDocumentId IN:contentDocMap.values()];
            Map<String,ContentVersion> contentDocVersionMap = new Map<String,ContentVersion>();
            for(ContentVersion latestVersion: contentVersions) {
                contentDocVersionMap.put(latestVersion.ContentDocumentId,latestVersion);
            }
            
            for(Document__c doc : documents) {
                HHDocument hhDoc = new HHDocument();
                hhDoc.setDocument(doc);
                System.debug('Document: '+hhDoc);
                String contentDocId = contentDocMap.get(doc.Id);
                if(contentDocId != null) {
                    hhDoc.setContentDocumentId(contentDocId);
                    ContentVersion latestVersion = contentDocVersionMap.get(contentDocId);
                    if(latestVersion != null) {
                        hhDoc.setLatestVersionId(latestVersion.Id);
                        hhDoc.setVersionNumber(latestVersion.VersionNumber);
                        hhDoc.setFileName(latestVersion.PathOnClient);
                    }
                }
                hhDocuments.add(hhDoc);
            }
            System.debug('Documents: '+hhDocuments);
            return hhDocuments;
            }else {
                return null;
            }
        }

        public  void deleteDocument(String documentId,String conDocId) {
            if(documentId == null) {
               throw new customException('DocumentId is null.');
            }
            HH_DocumentActionCtrl hhAction = new HH_DocumentActionCtrl();
            hhAction.executeDeleteAction(documentId,conDocId);
//            try{
//                List<Document__c> documents  = [SELECT Id,Document_Type__c,Is_Required__c,Document_Creation_Method__c,(SELECT Id, ContentDocumentId FROM ContentDocumentLinks WHERE LinkedEntityId =: documentId) from Document__c WHERE Id =: documentId LIMIT 1];
//                List<String> contentDocIds = new List<String>();
//
//                if(documents?.size()==1 && documents[0]?.ContentDocumentLinks?.size() > 0) {
//                    for (ContentDocumentLink cdl : documents[0].ContentDocumentLinks) {
//                        contentDocIds.add(cdl.ContentDocumentId);
//                    }
//                }
//                if(contentDocIds.size() > 0) {
//                    List<ContentDocument> contentDocList = [Select Id,ParentId  From ContentDocument Where Id IN :contentDocIds];
//                    if(contentDocList.size() > 0) {
//                        delete contentDocList;
//                    }
//                }
//                if(documents?.size() == 1 && documents[0]?.Document_Creation_Method__c != HH_CONSTANTS.Document_CreationMethod_SystemGenerated){
//                    delete documents;
//                }else{
//                    Document__c doc = new Document__c();
//                    doc.Id = documentId;
//                    doc.Stage__c = ALS_CONSTANTS.Document_Stage_New;
//                    doc.Date_Uploaded__c = null;
//                    doc.Uploaded_By__c = null;
//                    update doc;
//                }
//            }catch (Exception e){
//                throw new AuraHandledException('No files found -- '+e);
//            }
        }

        public  void updateDocumentRecord(String documentRecordId, String fileName) {
            try {
                Document__c document = [
                        SELECT Id,Stage__c,Document_Name__c,Uploaded_By__c, Document_Type__c, Date_Uploaded__c,Date_Time_Uploaded__c, (
                                SELECT ContentDocumentId,ContentDocument.CreatedDate, ContentDocument.Id, ContentDocument.Title
                                FROM ContentDocumentLinks
                                ORDER BY ContentDocument.CreatedDate ASC
                        )
                        from Document__c
                        Where Id = :documentRecordId
                ];
    			System.debug('document----1 '+document);
                if (document.Stage__c != ALS_CONSTANTS.Document_Stage_Uploaded) {
                    document.Stage__c = ALS_CONSTANTS.Document_Stage_Uploaded;
                }
                System.debug('document----2 '+document);
                document.Date_Uploaded__c = System.today();
                document.Date_Time_Uploaded__c = System.now();
                System.debug('UserInfo.getUserId  '+ UserInfo.getUserId());
                document.Uploaded_By__c = UserInfo.getUserId();
                update document;
                System.debug('document----3 '+document);
    
                if (document.ContentDocumentLinks.size() == 2) {
                    ContentVersion recentVersion = [Select Id,PathOnClient,Title,VersionData From ContentVersion Where ContentDocumentId = :document.ContentDocumentLinks[1].ContentDocumentId LIMIT 1];
                    System.debug('This is Versions : ' + recentVersion);
                    ContentVersion cv = new ContentVersion();
                    cv.ContentDocumentId = document.ContentDocumentLinks[0].ContentDocumentId;
                    cv.PathOnClient = recentVersion.PathOnClient;
                    cv.VersionData = recentVersion.VersionData;
                    cv.Title = document.ContentDocumentLinks[0].ContentDocument.Title;
                    System.debug(cv);
                    insert cv;
                    ContentDocumentLink toDelete = [SELECT Id FROM ContentDocumentLink Where Id = :document.ContentDocumentLinks[1].Id];
                    delete toDelete;
                    update document;
                }
            }catch (Exception e){
                System.debug(e.getStackTraceString());
               throw new customException(e.getMessage());
            }
        }

    }


   
    public class CustomException extends Exception{

    }
}