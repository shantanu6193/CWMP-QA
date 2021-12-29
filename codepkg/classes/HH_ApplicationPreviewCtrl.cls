public without sharing class HH_ApplicationPreviewCtrl {

    /***********************************************
    * Method Name : getApplicationPreviewDetails
    * Author : Shantanu
    * Inputs : String applicationId(HH_Application__c)
    * Description: This method return's Application and related  records with its required translation labels.
    *********************************************/
    @AuraEnabled
    public static Map<String,Object> getApplicationPreviewDetails(String applicationId) {
        Map<String,Object> result = new Map<String,Object>();
        HH_Application__c appPreview = new HH_Application__c();  
        if(applicationId != null) {
            appPreview =  queryApplicationPreview(applicationId);
        }
        List<Application_Contact__c> memberAppContactsPreview = new List<Application_Contact__c>();
        List<Application_Contact__c> deedAppContactsPreview = new List<Application_Contact__c>();
        for(Application_Contact__c ac : queryApplicationContactsPreview(applicationId)) {
            if (ac.Role__c == HH_CONSTANTS.HH_Application_Contact_HouseHoldMember) {
                memberAppContactsPreview.add(ac);
            } else if (ac.Role__c == HH_CONSTANTS.HH_Application_Contact_Co_Owner) {
                deedAppContactsPreview.add(ac);
            }
        }
        result.put('applicationPreview', appPreview);
        result.put('documentsPreview', getDocumentsPreview(applicationId));
        result.put('appContactsPreview',memberAppContactsPreview);
        result.put('deedContactsPreview',deedAppContactsPreview);
        //result.put('fundedProgramsPreview', queryFundedProgramsPreview(applicationId));
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
    * Method Name : queryApplicationPreview
    * Author : Shantanu
    * Inputs : String applicationId(HH_Application__c)
    * Description: This method return's HH_Application__c with its required translation labels.
    *********************************************/
    private static HH_Application__c queryApplicationPreview(String applicationId) {
        return [SELECT Id, toLabel(Property_Owner__c), toLabel(Property_Structure__c), toLabel(Car_Ownership__c), toLabel(Currently_Occupied__c),
                Damage_Description__c, toLabel(Ethnicities_of_Household_Members__c), toLabel(Is_Anyone_65__c), toLabel(Is_Anyone_Age_5_and_Under__c),
                toLabel(Is_Anyone_has_Disabilities__c), toLabel(Property_Currently_Damaged__c), toLabel(Rental_Property__c),
                Agreement_Disclosure__c, toLabel(Primary_Residence__c), toLabel(Accessible_by_a_Passenger_Vehicle__c), toLabel(Any_Other_Names_on_the_Property_Deed__c), 
                toLabel(Anyone_Not_a_Proficient_English_Speaker__c), Assessed_Value_of_the_Property__c, toLabel(Did_you_receive_wildfire_assistance__c),
                City__c, County__c,Property_Street_Address__c, Which_program_s_and_when__c,
                State__c, Zip_Postal_Code__c, toLabel(Authority_to_make_updates_to_the_Home__c), Year_of_Construction__c, Total_Living_Area__c,
                Number_of_Stories__c, toLabel(Is_National_Register_of_Historic_Places__c),
                toLabel(Property_Foreclosed_or_in__c), toLabel(Property_Liens__c),toLabel(Good_Standing_with_a_payment_plan_on_you__c),
                toLabel(Measures_to_Reduce_risks_to_wi__c), Stage__c, List_of_Measures__c,Program__c,
                Applicant__r.AccountId, Applicant__r.Account.Name, Applicant__r.FirstName,
                Applicant__r.Email, Applicant__r.Phone,Applicant__r.LastName,
                toLabel(Applicant__r.Is_Physical_Address_a_Foreign_Address__c), toLabel(Applicant__r.Is_Mailing_Address_a_Foreign_Address__c),
                toLabel(Applicant__r.Is_Mailing_Address_Different__c), toLabel(Applicant__r.Preferred_Language__c),
                Applicant__r.Physical_Street__c, Applicant__r.Physical_City__c,Applicant__r.Physical_State__c, Applicant__r.Physical_Country__c,Applicant__r.Physical_Zip_Postal_Code__c, Applicant__r.OtherPhone,
                Applicant__r.MailingStreet,Applicant__r.MailingCity,Applicant__r.MailingState,
                Applicant__r.MailingCountry, Applicant__r.MailingPostalCode,OwnerId,
                toLabel(Applicant__r.English_Language_Proficiency__c), Applicant__r.MobilePhone, Applicant__r.HomePhone, Unique_Household_Number__c,Household_Members__c 
                FROM HH_Application__c WHERE Id =:applicationId LIMIT 1];    
    }

    // /***********************************************
    // * Method Name : queryFundedProgramsPreview
    // * Author : Shantanu
    // * Inputs : String applicationId(HH_Application__c)
    // * Description: This method return's List<Funded_Program__c> with its required translation labels.
    // *********************************************/
    // private static List<Funded_Program__c> queryFundedProgramsPreview(String applicationId) {
    //     return [SELECT Id, Name, Date_Funding_Received__c, Other_Program_Name__c,
    //             HH_Application__c, toLabel(Program_Name__c) FROM Funded_Program__c
    //             WHERE HH_Application__c =: applicationId];
    // }

    /***********************************************
    * Method Name : queryApplicationContactsPreview
    * Author : Shantanu
    * Inputs : String applicationId(HH_Application__c)
    * Description: This method return's List<Application_Contact__c> with its required translation labels.
    *********************************************/
    private Static List<Application_Contact__c> queryApplicationContactsPreview(String applicationId) {
        return [SELECT Id,toLabel(Head_of_Household__c), toLabel(Relationship_to_Homeowner__c), Annual_Income__c, Date_of_Birth__c,Contact__r.FirstName,
                Contact__r.LastName, HH_Application__c, Role__c FROM Application_Contact__c WHERE HH_Application__c=:applicationId];
    }

     /***********************************************
    * Method Name : getDocumentsPreview
    * Author : Shantanu
    * Inputs : String applicationId(HH_Application__c)
    * Description: This method return's List<HHDocument> with its required translation labels.
    *********************************************/
    //TODO: remove unwanted code for document Preview
    private static List<HHDocument> getDocumentsPreview(String applicationId) {
        List<HHDocument> hhDocuments = new List<HHDocument>();
        List<PermissionSetAssignment> permissionSetAssignments = [SELECT Id FROM PermissionSetAssignment WHERE PermissionSet.Name =: HH_CONSTANTS.HH_PermissionSet_HomeOwner_APIName AND Assignee.Id =:UserInfo.getUserId()];
        String documentTypeFilter ='';
        if(permissionSetAssignments.size() >0){
            documentTypeFilter = ' AND Document_Type__c IN(\''+HH_CONSTANTS.Document_DocumentType_Rental+'\',\''+HH_CONSTANTS.Document_DocumentType_PropertyOwnerID+'\',\''+HH_CONSTANTS.Document_DocumentType_ProofOfOwnership+'\')';
        }
        String docQuery = 'SELECT Id,Name,toLabel(Stage__c),Comments__c,Is_Required__c,Date_Uploaded__c,Date_Time_Uploaded__c,Document_Name__c, toLabel(Document_Type__c) FROM Document__c WHERE HH_Application__c =:applicationId '+ documentTypeFilter +' ORDER BY Document_Name__c ';
        List<Document__c> documents = Database.query(docQuery);
        //List<Document__c> documents = [SELECT Id,Name,toLabel(Stage__c),Date_Uploaded__c,Document_Name__c, toLabel(Document_Type__c) FROM Document__c WHERE HH_Application__c =:applicationId ORDER BY Document_Name__c ];
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
    }
   
}