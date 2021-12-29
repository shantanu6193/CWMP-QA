public without sharing class HMA_EditApplicationButton {
    @AuraEnabled
    public static Map<String, Object> getInitData(String appId) {
        Map<String, Object> returnMap  = new Map<String, Object>();
        try {
            Boolean isEdit;
            List<Request_For_Information__c> openRFIList = new List<Request_For_Information__c>();
            User[] user = [Select Id, ContactId from User where Id=: UserInfo.getUserId()];
            Contact_Role__c[] contactRoles = [SELECT Id,Role__c, Application__c, Application__r.Status__c, Application__r.Status_Reason__c, Application__r.Is_Any_Open_RFI__c, AccountContactJunction__r.Contact_Name__c FROM Contact_Role__c 
                                                WHERE Application__c =:appId AND AccountContactJunction__r.Contact_Name__c=:user[0].ContactId];
            //TODO: Crete new class HMA_EditApplicationButton
            //TODO: Not a FEMA User
            //TODO: first 4 RFI Types and i9f any open RFI

            System.debug('contactRoles----'+contactRoles);

            if(contactRoles[0].Role__c.contains(HMA_CONSTANTS.CONTACT_ROLE_PICKLIST_RESPONSIBLE_REPRESENTATIVE) || 
                contactRoles[0].Role__c.contains(HMA_CONSTANTS.CONTACT_ROLE_PICKLIST_REQUESTOR) ||
                contactRoles[0].Role__c.contains(HMA_CONSTANTS.CONTACT_ROLE_PICKLIST_CONTRIBUTOR) ||
                contactRoles[0].Role__c.contains(HMA_CONSTANTS.CONTACT_ROLE_PICKLIST_VIEWER)) {
                    Set<String> rfiTypes = new Set<String>{HMA_CONSTANTS.REQUEST_FOR_INFORMATION_TYPE_OES_BCA, 
                                                            HMA_CONSTANTS.REQUEST_FOR_INFORMATION_TYPE_OES_PROGRAMMATIC, 
                                                            HMA_CONSTANTS.REQUEST_FOR_INFORMATION_TYPE_FEMA_PROGRAMMATIC, 
                                                            HMA_CONSTANTS.REQUEST_FOR_INFORMATION_TYPE_FEMA_EHP};
                    Set<String> rfiStatus = new Set<String>{HMA_CONSTANTS.REQUEST_FOR_INFORMATION_STATUS_SENT_TO_SUBAPPLICANT, 
                                                            HMA_CONSTANTS.REQUEST_FOR_INFORMATION_STATUS_TIME_EXTENSION_REQUESTED};
                    openRFIList = [ SELECT Id, 
                                            Analyst_Comment__c, 
                                            Subapplicant_Comment__c, 
                                            RFI_Deadline__c, 
                                            Name, 
                                            Application__c
                                            FROM Request_For_Information__c 
                                            WHERE Application__c =: appId AND RFI_Type__c IN: rfiTypes AND Status__c IN: rfiStatus];

            }

            if((contactRoles[0].Role__c.contains(HMA_CONSTANTS.CONTACT_ROLE_PICKLIST_RESPONSIBLE_REPRESENTATIVE) || 
                contactRoles[0].Role__c.contains(HMA_CONSTANTS.CONTACT_ROLE_PICKLIST_REQUESTOR) ||
                contactRoles[0].Role__c.contains(HMA_CONSTANTS.CONTACT_ROLE_PICKLIST_CONTRIBUTOR) ||
                contactRoles[0].Role__c.contains(HMA_CONSTANTS.CONTACT_ROLE_PICKLIST_VIEWER)) && 
                (contactRoles[0].Application__r.Status__c == HMA_CONSTANTS.APPLICATION_STATUS_DRAFT || openRFIList.size() > 0)) {
                isEdit = true;
            }else if( (contactRoles[0].Application__r.Status__c == HMA_CONSTANTS.APPLICATION_STATUS_FEMA_REVIEW ||
                      contactRoles[0].Application__r.Status__c == HMA_CONSTANTS.APPLICATION_STATUS_FEMA_DECISION) &&
                        (contactRoles[0].Role__c.contains(HMA_CONSTANTS.CONTACT_ROLE_PICKLIST_FEMA_EHP_ANALYST) || 
                        contactRoles[0].Role__c.contains(HMA_CONSTANTS.CONTACT_ROLE_PICKLIST_FEMA_PROGRAMMATIC_ANALYST) ||
                        contactRoles[0].Role__c.contains(HMA_CONSTANTS.CONTACT_ROLE_PICKLIST_FEMA_REVIEW))) {
                isEdit = true;
            }else {
                isEdit = false;
            }
            if(contactRoles[0].Application__r.Status__c == HMA_CONSTANTS.APPLICATION_STATUS_WITHDRAWN){
                isEdit = false;
            }
                returnMap.put('isEdit', isEdit);
        } catch (Exception e) {
            System.debug('Error : '+e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
        return returnMap;
    }
}