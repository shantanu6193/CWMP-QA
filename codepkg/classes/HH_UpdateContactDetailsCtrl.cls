public without sharing class HH_UpdateContactDetailsCtrl {
    
    @AuraEnabled
    public static Map<String,Object> showContactDetails() {
        Map<String,Object> result = new Map<String,Object>();
        Boolean showContactDetails = true;
        List<PermissionSetAssignment> permissionSetAssignments = [SELECT Id, PermissionSet.Name FROM PermissionSetAssignment WHERE Assignee.Id =:UserInfo.getUserId()];
        for (PermissionSetAssignment pa : permissionSetAssignments) {
            if(pa.PermissionSet.Name == HH_CONSTANTS.HH_PermissionSet_HomeOwner_APIName) {
                showContactDetails = false;
                break;
            }
        }
        result.put('showContactDetails', showContactDetails);
        return result;
    }

    @AuraEnabled
    public static Map<String,Object> getContactDetails(String contactId){
        Map<String,Object> result = new Map<String,Object>();
        Contact contact = [SELECT Id,OtherStreet, OtherCity, OtherState, OtherPostalCode, OtherCountry, OtherPhone,
        Physical_Street__c, Physical_City__c, Physical_State__c, Physical_Country__c, Physical_Zip_Postal_Code__c,
        MailingStreet, MailingCity, MailingState, MailingCountry, MailingPostalCode, HomePhone, Phone FROM Contact WHERE Id=:contactId LIMIT 1];
        result.put('contact', contact);
        return result;
    }

    @AuraEnabled
    public static Map<String, Object> updateContactDetails(String record) {
        Map<String, Object> returnMap = new Map<String, Object>();
        Contact contactRecord = (Contact) JSON.deserialize(record, Contact.class);
        try {
            update contactRecord;
            returnMap.put('contact',contactRecord);
            return returnMap;
        }
        catch (Exception e) {
            throw new AuraHandledException(CustomExceptionController.getSpecificErrorMessage(e.getMessage()));
        }
    }
}