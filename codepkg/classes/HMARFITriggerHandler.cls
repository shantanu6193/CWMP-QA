/*
Name : HMARFITriggerHandler
Description : This class is handler for trigger of Request_For_Information__c object.
                It's configuration is mentioned in the custom metadata types.
Date : July 19th 2021
Author : Rakesh
*/
public without sharing class HMARFITriggerHandler extends TriggerHandler implements TriggerInterface{
    public HMARFITriggerHandler() {

    }
    public override void beforeInsert() {
        setDefaultRFIStatusAccordingToRFIType();
        validateBeforeInsert();
    }
    public override void afterInsert() {
        List<Request_For_Information__c> subApplicantsRFIRecords = new List<Request_For_Information__c>();

        /**Record Type = HMA */
        Id RFIRecordTypeId = Schema.SObjectType.Request_For_Information__c.getRecordTypeInfosByName().get('HMA').getRecordTypeId();
        for(Request_For_Information__c rfi : (List<Request_For_Information__c>) Trigger.new) {
            if ((rfi.RFI_Type__c == HMA_CONSTANTS.REQUEST_FOR_INFORMATION_TYPE_OES_BCA || 
                rfi.RFI_Type__c == HMA_CONSTANTS.REQUEST_FOR_INFORMATION_TYPE_OES_PROGRAMMATIC || 
                rfi.RFI_Type__c == HMA_CONSTANTS.REQUEST_FOR_INFORMATION_TYPE_FEMA_PROGRAMMATIC || 
                rfi.RFI_Type__c == HMA_CONSTANTS.REQUEST_FOR_INFORMATION_TYPE_FEMA_EHP ||
                rfi.RFI_TYPE__c == HMA_CONSTANTS.REQUEST_FOR_INFORMATION_TYPE_FEMA_OES_PROGRAMMATIC ||
                rfi.RFI_Type__c == HMA_CONSTANTS.REQUEST_FOR_INFORMATION_TYPE_FEMA_OES_EHP) &&
                rfi.RecordTypeId  == RFIRecordTypeId) {
                    subApplicantsRFIRecords.add(rfi);
            }
        }
        if(subApplicantsRFIRecords.size() > 0) {
            setIsRFIOpenFlagonApplication(subApplicantsRFIRecords);
            shareRFIWithSubApplicants(subApplicantsRFIRecords);
        }
        
    }

    public override void beforeUpdate() {
        validateRFIRecord((Map<Id, Request_For_Information__c>) Trigger.newMap, (Map<Id, Request_For_Information__c>)  Trigger.oldMap);
    }

    /**This is only used for Record Type = HMA 
      *Validation on Request for Information records*/
    private static void validateRFIRecord(Map<Id, Request_For_Information__c> newMap, Map<Id, Request_For_Information__c> oldMap) {
        /**Record Type = HMA */
        Id RFIRecordTypeId = Schema.SObjectType.Request_For_Information__c.getRecordTypeInfosByName().get('HMA').getRecordTypeId();
        for(Request_For_Information__c rfi : newMap.values()) {
            if(rfi.RecordTypeId == RFIRecordTypeId) {
                Request_For_Information__c oldRFIRecord = oldMap.get(rfi.Id);
                /**Approved time should be new date*/
                System.debug('---'+rfi+'--old---'+oldRFIRecord);
                if((rfi.RFI_TYPE__c.equals(HMA_CONSTANTS.REQUEST_FOR_INFORMATION_TYPE_OES_BCA) ||
                    rfi.RFI_TYPE__c.equals(HMA_CONSTANTS.REQUEST_FOR_INFORMATION_TYPE_OES_PROGRAMMATIC) ||
                    rfi.RFI_TYPE__c.equals(HMA_CONSTANTS.REQUEST_FOR_INFORMATION_TYPE_FEMA_PROGRAMMATIC) ||
                    rfi.RFI_TYPE__c.equals(HMA_CONSTANTS.REQUEST_FOR_INFORMATION_TYPE_FEMA_EHP)) && 
                        (oldRFIRecord.Status__c.equals(HMA_CONSTANTS.REQUEST_FOR_INFORMATION_STATUS_TIME_EXTENSION_REQUESTED) && rfi.Status__c.equals(HMA_CONSTANTS.REQUEST_FOR_INFORMATION_STATUS_TIME_EXTENSION_ACCEPTED)) 
                    && (oldRFIRecord.RFI_Deadline__c >= rfi.RFI_Deadline__c)) {
                        rfi.addError('Approved Time Extension Notice must include the new RFI Due Date');
                }
            }            
        }
    }

    public override void afterUpdate() {
        List<Request_For_Information__c> hmaRFIRecords = new List<Request_For_Information__c>();

        /**Record Type = HMA */
        Id RFIRecordTypeId = Schema.SObjectType.Request_For_Information__c.getRecordTypeInfosByName().get('HMA').getRecordTypeId();
        for(Request_For_Information__c rfi : (List<Request_For_Information__c>) Trigger.new) {
            if(rfi.RecordTypeId  == RFIRecordTypeId) {
                hmaRFIRecords.add(rfi);
            }
        }
        if(hmaRFIRecords.size() > 0) {
            setIsRFIOpenFlagonApplication(hmaRFIRecords);
        }
    }

    /**This is only used for Record Type = HMA */
    public static void setDefaultRFIStatusAccordingToRFIType() {
        Id rfiRecordTypeId = Schema.SObjectType.Request_For_Information__c.getRecordTypeInfosByName().get('HMA').getRecordTypeId();

        for(Request_For_Information__c rfi : (List<Request_For_Information__c>)Trigger.new) {
            if( rfi.RecordTypeId == rfiRecordTypeId ){
                if (rfi.RFI_Type__c == HMA_CONSTANTS.REQUEST_FOR_INFORMATION_TYPE_OES_BCA ||
                        rfi.RFI_Type__c == HMA_CONSTANTS.REQUEST_FOR_INFORMATION_TYPE_OES_PROGRAMMATIC ||
                        rfi.RFI_Type__c == HMA_CONSTANTS.REQUEST_FOR_INFORMATION_TYPE_FEMA_PROGRAMMATIC ||
                        rfi.RFI_Type__c == HMA_CONSTANTS.REQUEST_FOR_INFORMATION_TYPE_FEMA_EHP) {
                    rfi.Status__c = HMA_CONSTANTS.REQUEST_FOR_INFORMATION_STATUS_DRAFT;
                }else if(rfi.RFI_Type__c == HMA_CONSTANTS.REQUEST_FOR_INFORMATION_TYPE_FEMA_OES_PROGRAMMATIC ||
                        rfi.RFI_Type__c == HMA_CONSTANTS.REQUEST_FOR_INFORMATION_TYPE_FEMA_OES_EHP){
                    if(rfi.Status__c == null){
                        rfi.Status__c = HMA_CONSTANTS.REQUEST_FOR_INFORMATION_STATUS_FEMA_DRAFT;
                    }
                }
            }
        }
    }

    /**This is only used for Record Type = HMA */
    public static void shareRFIWithSubApplicants(List<Request_For_Information__c> rfiList) {
        Set<Id> applicationIds = new Set<Id>();
        Map<Id, Set<Id>> SObjectIdToUserIds = new Map<Id, Set<Id>>();
        Map<Id, Set<Id>> applicationIdToRFIDIdsMap = new Map<Id, Set<Id>>();
        for(Request_For_Information__c rfi : rfiList) {
            if(rfi.Application__c != null) {
                if(applicationIdToRFIDIdsMap.get(rfi.Application__c) == null) {
                    applicationIdToRFIDIdsMap.put(rfi.Application__c, new Set<Id>());
                }
                applicationIdToRFIDIdsMap.get(rfi.Application__c).add(rfi.Id);
            }
        }
        applicationIds.addAll(applicationIdToRFIDIdsMap.keySet());
        Map<Id, Set<Id>> contactIdtoApplicationIdsMap = HMA_ApplicationHelper.getContactIdsOfSubApplicants(applicationIds);
        System.debug('contactIdtoApplicationIdsMap--'+contactIdtoApplicationIdsMap);
        /** Finding the contactUsers from specified Contact Ids */
        List<User> userList = [SELECT Id, ContactId FROM User WHERE ContactId IN: contactIdtoApplicationIdsMap.keySet()];
        System.debug('userList--'+userList);
        for(User u : userList) {
            for(Id appId : contactIdtoApplicationIdsMap.get(u.ContactId)) {
                for(Id rfiId : applicationIdToRFIDIdsMap.get(appId)) {
                    if(SObjectIdToUserIds.get(rfiId) == null) {
                        SObjectIdToUserIds.put(rfiId, new Set<Id>());
                    }
                    SObjectIdToUserIds.get(rfiId).add(u.Id);
                }
            }
        }

        if(SObjectIdToUserIds.size() > 0) {
            Boolean isRecordShared = HMA_Utility.shareCustomObjectRecordsWithUser(SObjectIdToUserIds, 'Request_For_Information__share', 'Read', Schema.Request_For_Information__share.RowCause.Manual);
            if(isRecordShared) {
                System.debug('Request for Information Records shared Successfully.');
            }
        }
    }
    
    /**This is only used for Record Type = HMA */
    private void setIsRFIOpenFlagonApplication(List<Request_For_Information__c> rfiList) {
        List<Application__c> applicationsToUpdate = new List<Application__c>();
        Set<Id> applicationIds = new Set<Id>();
        Set<String> applicationIdsToCheckOpenRFIs = new Set<String>();
        for(Request_For_Information__c rfi : rfiList) {
            if(rfi.Application__c != null) {
                applicationIds.add(rfi.Application__c);
            }
        }
        Set<String> applicationIdsToUpdate = new Set<String>();
        for(Request_For_Information__c rfi : rfiList) {
            if(((rfi.RFI_Type__c.equals(HMA_CONSTANTS.REQUEST_FOR_INFORMATION_TYPE_OES_BCA) ||
                    rfi.RFI_Type__c.equals(HMA_CONSTANTS.REQUEST_FOR_INFORMATION_TYPE_OES_PROGRAMMATIC) ||
                    rfi.RFI_Type__c.equals(HMA_CONSTANTS.REQUEST_FOR_INFORMATION_TYPE_FEMA_PROGRAMMATIC) ||
                    rfi.RFI_Type__c.equals(HMA_CONSTANTS.REQUEST_FOR_INFORMATION_TYPE_FEMA_EHP)) &&
                        rfi.Status__c.equals(HMA_CONSTANTS.REQUEST_FOR_INFORMATION_STATUS_SENT_TO_SUBAPPLICANT)) || 
                            ((rfi.RFI_TYPE__c.equals(HMA_CONSTANTS.REQUEST_FOR_INFORMATION_TYPE_FEMA_OES_EHP) ||
                            rfi.RFI_TYPE__c.equals(HMA_CONSTANTS.REQUEST_FOR_INFORMATION_TYPE_FEMA_OES_PROGRAMMATIC)) && 
                                (rfi.Status__c.equals(HMA_CONSTANTS.REQUEST_FOR_INFORMATION_STATUS_SUBMITTED_TO_CAL_OES_ANALYST) ||
                                rfi.Status__c.equals(HMA_CONSTANTS.REQUEST_FOR_INFORMATION_STATUS_FEMA_OES_ANALYST_REVIEW_FEMA_EHP_RFI) ||
                                rfi.Status__c.equals(HMA_CONSTANTS.REQUEST_FOR_INFORMATION_STATUS_FEMA_OES_ANALYST_REVIEW_FEMA_PROGRAMMATIC_RFI) ||
                                rfi.Status__c.equals(HMA_CONSTANTS.REQUEST_FOR_INFORMATION_STATUS_FEMA_TIME_EXTENSION_REQUESTED)))) {
                if(!applicationIdsToUpdate.contains(rfi.Application__c)){
                    Application__c app = new Application__c(Id= rfi.Application__c, Is_Any_Open_RFI__c = true);
                    applicationsToUpdate.add(app);
                    applicationIdsToUpdate.add(rfi.Application__c);
                }

            }else if((rfi.RFI_Type__c.equals(HMA_CONSTANTS.REQUEST_FOR_INFORMATION_TYPE_OES_BCA) ||
                    rfi.RFI_Type__c.equals(HMA_CONSTANTS.REQUEST_FOR_INFORMATION_TYPE_OES_PROGRAMMATIC) ||
                    rfi.RFI_Type__c.equals(HMA_CONSTANTS.REQUEST_FOR_INFORMATION_TYPE_FEMA_PROGRAMMATIC) ||
                    rfi.RFI_Type__c.equals(HMA_CONSTANTS.REQUEST_FOR_INFORMATION_TYPE_FEMA_EHP)) &&
                    (rfi.Status__c.equals(HMA_CONSTANTS.REQUEST_FOR_INFORMATION_STATUS_RESPONSE_SUBMITTED) ||
                            rfi.Status__c.equals(HMA_CONSTANTS.REQUEST_FOR_INFORMATION_STATUS_RESPONSE_ACCEPTED) ||
                            rfi.Status__c.equals(HMA_CONSTANTS.REQUEST_FOR_INFORMATION_STATUS_RESPONSE_REJECTED)) ||
                            
                                ((rfi.RFI_TYPE__c.equals(HMA_CONSTANTS.REQUEST_FOR_INFORMATION_TYPE_FEMA_OES_EHP) ||
                                rfi.RFI_TYPE__c.equals(HMA_CONSTANTS.REQUEST_FOR_INFORMATION_TYPE_FEMA_OES_PROGRAMMATIC)) &&
                                    (rfi.Status__c.equals(HMA_CONSTANTS.REQUEST_FOR_INFORMATION_STATUS_FEMA_PROGRAMMATIC_RFI_ACCEPTED) ||
                                    rfi.Status__c.equals(HMA_CONSTANTS.REQUEST_FOR_INFORMATION_STATUS_FEMA_PROGRAMMATIC_RFI_REJECTED) ||
                                    rfi.Status__c.equals(HMA_CONSTANTS.REQUEST_FOR_INFORMATION_STATUS_RESPONSE_SUBMITTED_BY_CAL_OES_ANALYST) ||
                                    rfi.Status__c.equals(HMA_CONSTANTS.REQUEST_FOR_INFORMATION_STATUS_FEMA_EHP_RFI_ACCEPTED) ||
                                    rfi.Status__c.equals(HMA_CONSTANTS.REQUEST_FOR_INFORMATION_STATUS_FEMA_EHP_RFI_REJECTED)))){
                applicationIdsToCheckOpenRFIs.add(rfi.Application__c);
            }
        }
        System.debug('----applicationIdsToCheckOpenRFIs------'+applicationIdsToCheckOpenRFIs);
        if(applicationIdsToCheckOpenRFIs.size() > 0){
            Set<String> rfiTypes = new Set<String>{HMA_CONSTANTS.REQUEST_FOR_INFORMATION_TYPE_OES_BCA, HMA_CONSTANTS.REQUEST_FOR_INFORMATION_TYPE_OES_PROGRAMMATIC, HMA_CONSTANTS.REQUEST_FOR_INFORMATION_TYPE_FEMA_PROGRAMMATIC, HMA_CONSTANTS.REQUEST_FOR_INFORMATION_TYPE_FEMA_EHP, HMA_CONSTANTS.REQUEST_FOR_INFORMATION_TYPE_FEMA_OES_EHP, HMA_CONSTANTS.REQUEST_FOR_INFORMATION_TYPE_FEMA_OES_PROGRAMMATIC};
            Set<String> rfiStatus = new Set<String>{HMA_CONSTANTS.REQUEST_FOR_INFORMATION_STATUS_SENT_TO_SUBAPPLICANT, HMA_CONSTANTS.REQUEST_FOR_INFORMATION_STATUS_TIME_EXTENSION_REJECTED, HMA_CONSTANTS.REQUEST_FOR_INFORMATION_STATUS_SUBMITTED_TO_CAL_OES_ANALYST, HMA_CONSTANTS.REQUEST_FOR_INFORMATION_STATUS_FEMA_OES_ANALYST_REVIEW_FEMA_EHP_RFI, HMA_CONSTANTS.REQUEST_FOR_INFORMATION_STATUS_FEMA_OES_ANALYST_REVIEW_FEMA_PROGRAMMATIC_RFI, HMA_CONSTANTS.REQUEST_FOR_INFORMATION_STATUS_FEMA_TIME_EXTENSION_REQUESTED};
            Request_For_Information__c[] openRFIs = [SELECT Id, Analyst_Comment__c, Subapplicant_Comment__c, RFI_Deadline__c, Name, Application__c
                            from Request_For_Information__c WHERE Application__c IN: applicationIdsToCheckOpenRFIs AND RFI_Type__c IN: rfiTypes AND Status__c IN: rfiStatus];

            System.debug('----openRFIs----'+openRFIs.size());
            /*
            List<Request_For_Information__c> openRFIs = HMA_Utility.getApplicationRFIs(applicationIdsToCheckOpenRFIs,
                    new Set<String>{HMA_CONSTANTS.REQUEST_FOR_INFORMATION_TYPE_OES_BCA, HMA_CONSTANTS.REQUEST_FOR_INFORMATION_TYPE_OES_PROGRAMMATIC, HMA_CONSTANTS.REQUEST_FOR_INFORMATION_TYPE_FEMA_PROGRAMMATIC, HMA_CONSTANTS.REQUEST_FOR_INFORMATION_TYPE_FEMA_EHP},
                    new Set<String>{HMA_CONSTANTS.REQUEST_FOR_INFORMATION_STATUS_DRAFT, HMA_CONSTANTS.REQUEST_FOR_INFORMATION_STATUS_SENT_TO_SUBAPPLICANT});*/
            Map<String, List<Request_For_Information__c>> applicationOpenRFI = new Map<String, List<Request_For_Information__c>>();
            for(Request_For_Information__c openRFI : openRFIs){
                if(applicationOpenRFI.get(openRFI.Application__c) == null){
                    applicationOpenRFI.put(openRFI.Application__c, new List<Request_For_Information__c>());
                }
            }
            System.debug('-----applicationOpenRFI---'+applicationOpenRFI);
            for(String appId : applicationIdsToCheckOpenRFIs){
                System.debug('---applicationOpenRFI.get(appId)----'+applicationOpenRFI.get(appId));
                if(applicationOpenRFI.get(appId) == null){
                    Application__c app = new Application__c(Id= appId, Is_Any_Open_RFI__c = false);
                    applicationsToUpdate.add(app);
                }
            }

        }
        if(applicationsToUpdate.size() > 0){
            update applicationsToUpdate;
        }
    }

    /**This is only used for Record Type = HMA */
    public void validateBeforeInsert(){
        
        Id RFIRecordTypeId = Schema.SObjectType.Request_For_Information__c.getRecordTypeInfosByName().get('HMA').getRecordTypeId();        
        String roleId = System.userInfo.getUserRoleId();
        UserRole singleRole = [SELECT Id, Name FROM UserRole WHERE Id = :roleId];
        if(singleRole.Name.equals('HMA Manager') || singleRole.Name.equals('HMA Analyst')){
            for(Request_For_Information__c rfi : (List<Request_For_Information__c>)Trigger.new) {
                /**Record Type = HMA */
                if(rfi.RecordTypeId  == RFIRecordTypeId) {
                        if(rfi.RFI_Type__c.equals(HMA_CONSTANTS.REQUEST_FOR_INFORMATION_TYPE_FEMA_OES_EHP) ||
                        rfi.RFI_Type__c.equals(HMA_CONSTANTS.REQUEST_FOR_INFORMATION_TYPE_FEMA_OES_PROGRAMMATIC)){
                        rfi.addError('You do not have permission to create RFI Types: '+HMA_CONSTANTS.REQUEST_FOR_INFORMATION_TYPE_FEMA_OES_EHP+' AND '+ HMA_CONSTANTS.REQUEST_FOR_INFORMATION_TYPE_FEMA_OES_PROGRAMMATIC);
                    }
                    //Validate RFI Deadline for past date
                    Date now = Date.today();
                    System.debug('condition---'+(rfi.RFI_Deadline__c > now));
                    if( (rfi.RFI_TYPE__c.equals(HMA_CONSTANTS.REQUEST_FOR_INFORMATION_TYPE_OES_BCA) ||
                        (rfi.RFI_TYPE__c.equals(HMA_CONSTANTS.REQUEST_FOR_INFORMATION_TYPE_OES_PROGRAMMATIC)) ||
                        (rfi.RFI_TYPE__c.equals(HMA_CONSTANTS.REQUEST_FOR_INFORMATION_TYPE_FEMA_PROGRAMMATIC)) ||
                        (rfi.RFI_TYPE__c.equals(HMA_CONSTANTS.REQUEST_FOR_INFORMATION_TYPE_FEMA_EHP))) && 
                        rfi.RFI_Deadline__c < now) {
                            rfi.addError('RFI Deadline cannot be a past date');
                    }
                }
            }
        }

    }

   /* private void setRFIOpenOrCloseOnUpdate(List<Request_For_Information__c> rfiList) {
        List<Application__c> applicationsToUpdate = new List<Application__c>();
        Set<Id> applicationIds = new Set<Id>();
        for(Request_For_Information__c rfi : rfiList) {
            if(rfi.Application__c != null){
                applicationIds.add(rfi.Application__c);
            }
        }
        Map<Id, Application__c> appIdToAppMap = new Map<Id, Application__c>([SELECT Id, Is_Any_Open_RFI__c FROM Application__c WHERE Id IN :applicationIds]);
        Map<Id, Application__c> rfiIdToApplicationMap = new Map<Id, Application__c>();
        for(Request_For_Information__c rfi : rfiList) {
            rfiIdToApplicationMap.put(rfi.Id, appIdToAppMap.get(rfi.Application__c));
        }
        for(Request_For_Information__c rfi : rfiList) {
            if(!rfi.Status__c.equals(HMA_CONSTANTS.REQUEST_FOR_INFORMATION_STATUS_RESPONSE_ACCEPTED) && (!rfi.Status__c.equals(HMA_CONSTANTS.REQUEST_FOR_INFORMATION_STATUS_RESPONSE_REJECTED))) {
                if(rfiIdToApplicationMap.containsKey(rfi.Id)) {
                    Application__c app = (Application__c) rfiIdToApplicationMap.get(rfi.Id);
                    app.Is_Any_Open_RFI__c = true;
                    applicationsToUpdate.add(app);
                }
            }
        }
        update applicationsToUpdate;
    }*/
}