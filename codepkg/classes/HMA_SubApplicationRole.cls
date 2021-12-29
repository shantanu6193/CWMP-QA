public without sharing class HMA_SubApplicationRole implements DynamicTableInterface {
    public Map<String, Object> executeClass(String recordId, String pageFieldDeveloperName) {
        System.debug('----HMA_SubApplicationRole----executeClass----'+recordId);
        try{
            Map<String, Object> returnMap = new Map<String, Object>();
            returnMap.put('isNewActionAvailable', false);
            returnMap.put('isEditActionAvailable', false);
            returnMap.put('isDeleteActionAvailable', false);
            returnMap.put('isActionColumnAvailable', false);
            returnMap.put('isSendForSignatureAvailable', false);
            User[] user = [Select Id, ContactId from User where Id=: UserInfo.getUserId()];
            if(user.size() > 0) {
                Contact_Role__c[] contactRoles = [SELECT Id,Role__c FROM Contact_Role__c WHERE Application__c = :recordId AND AccountContactJunction__r.Contact_Name__c = :user[0].ContactId];
                if (contactRoles.size() > 0) {
                    if(pageFieldDeveloperName == 'Contact_Roles') {
                        if(contactRoles[0].Role__c.contains(HMA_CONSTANTS.CONTACT_ROLE_PICKLIST_RESPONSIBLE_REPRESENTATIVE)){
                            returnMap.put('isNewActionAvailable', true);
                            returnMap.put('isEditActionAvailable', true);
                            returnMap.put('isDeleteActionAvailable', true);
                            returnMap.put('isActionColumnAvailable', true);
                        }
                    } else if(pageFieldDeveloperName == 'Contact_Role_Confirmation_Table' || pageFieldDeveloperName == 'Contact_Role_Confirmation_Table1') {
                        if(contactRoles[0].Role__c.contains(HMA_CONSTANTS.CONTACT_ROLE_PICKLIST_RESPONSIBLE_REPRESENTATIVE) || contactRoles[0].Role__c.contains(HMA_CONSTANTS.CONTACT_ROLE_PICKLIST_REQUESTOR)){
                            returnMap.put('isNewActionAvailable', true);
                            returnMap.put('isEditActionAvailable', true);
                            returnMap.put('isDeleteActionAvailable', true);
                            returnMap.put('isActionColumnAvailable', true);
                            returnMap.put('isSendForSignatureAvailable', true);
                        }
                    }else if(pageFieldDeveloperName == 'FEMA_Request_For_Information') {
                        if(contactRoles[0].Role__c.contains(HMA_CONSTANTS.CONTACT_ROLE_PICKLIST_FEMA_EHP_ANALYST) || contactRoles[0].Role__c.contains(HMA_CONSTANTS.CONTACT_ROLE_PICKLIST_FEMA_PROGRAMMATIC_ANALYST)){
                            returnMap.put('isNewActionAvailable', true);
                            returnMap.put('isEditActionAvailable', true);
                            returnMap.put('isDeleteActionAvailable', true);
                            returnMap.put('isActionColumnAvailable', true);
                            returnMap.put('isSendForSignatureAvailable', false);
                        }
                    }
                }
            }
            return returnMap;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
}