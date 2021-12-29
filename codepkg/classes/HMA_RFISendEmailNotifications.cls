public without sharing class HMA_RFISendEmailNotifications {
    public HMA_RFISendEmailNotifications() {

    }

    public class FlowInputs {
        @InvocableVariable public String rfiId;
        @InvocableVariable public String sendEmailsTo;
        @InvocableVariable public Request_For_Information__c newRFIRecord;
        @InvocableVariable public List<Request_For_Information__c> oldRFIRecords;
    }

    @InvocableMethod(label='RFI Email Notification' description='Response Accepted or Rejected Email notification')
    public static void sendEmailForResponseAcceptedOrRejected(List<FlowInputs> flowInput) {
        try {
        List<String> toAddresses;
        List<String> ccAddresses = new List<String>();
            List<Request_For_Information__c> rfiList = new List<Request_For_Information__c>();
            List<Request_For_Information__c> rfiForUpdate = new List<Request_For_Information__c>();
            List<FeedItem> feedbackList = new List<FeedItem>();
            String rfiId = flowInput[0].rfiId;
            STring sendEmailTo = flowInput[0].sendEmailsTo;
            System.debug('flowInput----'+flowInput);
        Map<Id, Id> rfiToApplicationIdMap = new Map<Id, Id>();
            Request_For_Information__c newRFI = (Request_For_Information__c) flowInput[0].newRFIRecord;
            Request_For_Information__c oldRFI = (Request_For_Information__c) flowInput[0].oldRFIRecords[0];
            rfiToApplicationIdMap.put(newRFI.Id, newRFI.Application__c);
            rfiList.add(newRFI);
        
        Map<Id, List<Contact_Role__c>> applicationToContactRolesMap = new Map<Id, List<Contact_Role__c>>();
            Map<Id, Application__c> subAppsIdMap = new Map<Id, Application__c>();
            if(sendEmailTo.equals('FEMA')){
                subAppsIdMap = new Map<Id, Application__c>([SELECT Id, Status__c, Name, Status_Reason__c, OwnerId, Owner.Email, (SELECT Id, Role__c,
                                                            Contact__c, Contact__r.Email
                                                            FROM Contact_Roles__r
                                                            WHERE Role__c INCLUDES('FEMA Programmatic Analyst', 'FEMA EHP Analyst'))
                                                            FROM Application__c WHERE Id IN :rfiToApplicationIdMap.values()]);
            
            }else if(sendEmailTo.equals('NonFEMA')){
                subAppsIdMap = new Map<Id, Application__c>([SELECT Id, Status__c, Name, Status_Reason__c, OwnerId, Owner.Email, (SELECT Id, Role__c,
                                                            Contact__c, Contact__r.Email
                                                            FROM Contact_Roles__r
                                                            WHERE Role__c INCLUDES('Primary Contact', 'Responsible Representative', 'Contributor'))
                                                            FROM Application__c WHERE Id IN :rfiToApplicationIdMap.values()]);
            }
            System.debug('subAppsIdMap----'+subAppsIdMap);
        for(Application__c app : subAppsIdMap.values()) {
            for(Contact_Role__c contactRole : app.Contact_Roles__r) {
                    System.debug('contactRole----'+contactRole);
                    if(applicationToContactRolesMap.containsKey(app.Id)) {
                        List<Contact_Role__c> tempContactRoleList = applicationToContactRolesMap.get(app.Id);
                        tempContactRoleList.add(contactRole);
                        applicationToContactRolesMap.put(app.Id, tempContactRoleList);
                    } else {
                        applicationToContactRolesMap.put(app.Id, new List<Contact_Role__c>{contactRole});
                    }
                }
            }
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            List<String> FEMA_RFI_TYPES = new List<String>{HMA_CONSTANTS.REQUEST_FOR_INFORMATION_TYPE_FEMA_OES_PROGRAMMATIC, HMA_CONSTANTS.REQUEST_FOR_INFORMATION_TYPE_FEMA_OES_EHP};
            List<String> NON_FEMA_RFI_TYPES = new List<String>{HMA_CONSTANTS.REQUEST_FOR_INFORMATION_TYPE_OES_BCA, HMA_CONSTANTS.REQUEST_FOR_INFORMATION_TYPE_FEMA_EHP,
                                                                HMA_CONSTANTS.REQUEST_FOR_INFORMATION_TYPE_FEMA_PROGRAMMATIC, HMA_CONSTANTS.REQUEST_FOR_INFORMATION_TYPE_OES_PROGRAMMATIC};
                               
            for(Request_For_Information__c rfi : rfiList) {
                    Application__c app = subAppsIdMap.get(rfi.Application__c);
                if(NON_FEMA_RFI_TYPES.contains(rfi.RFI_Type__c) && String.valueOf(app.ownerId).startsWith('005')) {
                    if(rfi.Status__c.equals(HMA_CONSTANTS.REQUEST_FOR_INFORMATION_STATUS_SENT_TO_SUBAPPLICANT) && 
                        oldRFI.Status__c.equals(HMA_CONSTANTS.REQUEST_FOR_INFORMATION_STATUS_DRAFT) && 
                        rfiToApplicationIdMap.containsKey(rfi.Id)) {
                        for(Contact_Role__c conRole : applicationToContactRolesMap.get(rfiToApplicationIdMap.get(rfi.Id))) {
                            toAddresses = new List<String>();
                            toAddresses.add(conRole.Contact__r.Email);
                            mails.addAll(HMA_ApplicationHelper.sendEmail((SObject) subAppsIdMap.get(rfiToApplicationIdMap.get(rfi.Id)), 
                                            toAddresses, 
                                            ccAddresses, 
                                            HMA_CONSTANTS.HMA_RFI_SENT_TO_SUBAPPLICANT_NOTIFICATION, 
                                            HMA_CONSTANTS.HMA_FROM_EMAIL_ADDRESSES, 
                                            conRole.Contact__c));
                        } 
                    } else if(rfi.Status__c.equals(HMA_CONSTANTS.REQUEST_FOR_INFORMATION_STATUS_RESPONSE_SUBMITTED) && rfiToApplicationIdMap.containsKey(rfi.Id)) {
                        //mails.addAll(HMA_ApplicationHelper.prepareForMailsSendToHmaAnalyst(subAppsIdMap.get(rfiToApplicationIdMap.get(rfi.Id)), HMA_CONSTANTS.HMA_RFI_RESPONSE_SUBMITTED_TO_HMA_ANALYST_EMAIL_NOTIFICATION));
                        feedbackList.add(getFeedItemPost(app.OwnerId,
                                'RFI Response submitted for Subapplication '+app.Name+'/'+rfi.Name,
                                'RFI',
                                '/lightning/r/Request_For_Information__c/' + rfi.Id + '/view'));
                        for(Contact_Role__c conRole : applicationToContactRolesMap.get(rfiToApplicationIdMap.get(rfi.Id))) {
                            toAddresses = new List<String>();
                            toAddresses.add(conRole.Contact__r.Email);
                            mails.addAll(HMA_ApplicationHelper.sendEmail((SObject) subAppsIdMap.get(rfiToApplicationIdMap.get(rfi.Id)),
                                    toAddresses,
                                    ccAddresses,
                                    HMA_CONSTANTS.HMA_RFI_RESPONSE_SUBMITTED_TO_HMA_ANALYST_EMAIL_NOTIFICATION,
                                    HMA_CONSTANTS.HMA_FROM_EMAIL_ADDRESSES,
                                    conRole.Contact__c));
                        }
                        System.debug('mails----'+mails);
                    } else if(rfi.Status__c.equals(HMA_CONSTANTS.REQUEST_FOR_INFORMATION_STATUS_TIME_EXTENSION_REQUESTED) && rfiToApplicationIdMap.containsKey(rfi.Id)) {
                        /**mails.addAll(HMA_ApplicationHelper.prepareForMailsSendToHmaAnalyst(subAppsIdMap.get(rfiToApplicationIdMap.get(rfi.Id)), 
                                                                                            HMA_CONSTANTS.HMA_RFI_TIME_EXTENSION_REQUEST_TO_HMA_ANALYST_EMAIL_NOTIFICATION));*/
                        feedbackList.add(getFeedItemPost(app.OwnerId, 
                                                        'RFI Time Extension Request for Subapplication '+app.Name+'/'+rfi.Name,
                                                        'RFI', 
                                                        '/lightning/r/Request_For_Information__c/' + rfi.Id + '/view'));
                    } else if(rfi.Status__c.equals(HMA_CONSTANTS.REQUEST_FOR_INFORMATION_STATUS_TIME_EXTENSION_ACCEPTED) && rfiToApplicationIdMap.containsKey(rfi.Id)) {
                        for(Contact_Role__c conRole : applicationToContactRolesMap.get(rfiToApplicationIdMap.get(rfi.Id))) {
                            toAddresses = new List<String>();
                            toAddresses.add(conRole.Contact__r.Email);
                            mails.addAll(HMA_ApplicationHelper.sendEmail((SObject) subAppsIdMap.get(rfiToApplicationIdMap.get(rfi.Id)), 
                                            toAddresses, 
                                            ccAddresses, 
                                            HMA_CONSTANTS.HMA_RFI_TIME_EXTENSION_ACCEPTED_TO_SUBAPPLICANTS_EMAIL_NOTIFICATION, 
                                            HMA_CONSTANTS.HMA_FROM_EMAIL_ADDRESSES, 
                                            conRole.Contact__c));
                        } 
                    }else if(rfi.Status__c.equals(HMA_CONSTANTS.REQUEST_FOR_INFORMATION_STATUS_TIME_EXTENSION_REJECTED) && rfiToApplicationIdMap.containsKey(rfi.Id)) {
                        for(Contact_Role__c conRole : applicationToContactRolesMap.get(rfiToApplicationIdMap.get(rfi.Id))) {
                            toAddresses = new List<String>();
                            toAddresses.add(conRole.Contact__r.Email);
                            mails.addAll(HMA_ApplicationHelper.sendEmail((SObject) subAppsIdMap.get(rfiToApplicationIdMap.get(rfi.Id)), 
                                            toAddresses, 
                                            ccAddresses, 
                                            HMA_CONSTANTS.HMA_RFI_TIME_EXTENSION_REJECTED_TO_SUBAPPLICANTS_EMAIL_NOTIFICATION, 
                                            HMA_CONSTANTS.HMA_FROM_EMAIL_ADDRESSES, 
                                            conRole.Contact__c));
                        } 
                    }else if(rfi.Status__c.equals(HMA_CONSTANTS.REQUEST_FOR_INFORMATION_STATUS_RESPONSE_ACCEPTED) && rfiToApplicationIdMap.containsKey(rfi.Id)){
                        for(Contact_Role__c conRole : applicationToContactRolesMap.get(rfiToApplicationIdMap.get(rfi.Id))) {
                            toAddresses = new List<String>();
                            toAddresses.add(conRole.Contact__r.Email);
                            mails.addAll(HMA_ApplicationHelper.sendEmail((SObject) subAppsIdMap.get(rfiToApplicationIdMap.get(rfi.Id)), 
                                            toAddresses, 
                                            ccAddresses, 
                                            HMA_CONSTANTS.HMA_RFI_RESPONSE_ACCEPTED_EMAIL_NOTIFICATION, 
                                            HMA_CONSTANTS.HMA_FROM_EMAIL_ADDRESSES, 
                                            conRole.Contact__c));
                        }
                    }

                }else if(FEMA_RFI_TYPES.contains(rfi.RFI_Type__c) && String.valueOf(app.ownerId).startsWith('005')){
                    if(rfi.Status__c.equals(HMA_CONSTANTS.REQUEST_FOR_INFORMATION_STATUS_SUBMITTED_TO_CAL_OES_ANALYST)){
                        //mails.addAll(HMA_ApplicationHelper.prepareForMailsSendToHmaAnalyst(subAppsIdMap.get(rfiToApplicationIdMap.get(rfi.Id)), HMA_CONSTANTS.HMA_FEMA_RFI_SUBMITTED_TO_HMA_ANALYST_EMAIL_NOTIFICATION));
                        feedbackList.add(getFeedItemPost(app.OwnerId, 
                                                        'RFI Created for Subapplication '+app.Name+'/'+rfi.Name,
                                                        'RFI', 
                                                        '/lightning/r/Request_For_Information__c/' + rfi.Id + '/view'));
                    }else if(rfi.RFI_Type__c.equals(HMA_CONSTANTS.REQUEST_FOR_INFORMATION_TYPE_FEMA_OES_EHP) &&
                            rfi.Status__c.equals(HMA_CONSTANTS.REQUEST_FOR_INFORMATION_STATUS_FEMA_TIME_EXTENSION_REQUESTED) && 
                            rfiToApplicationIdMap.containsKey(rfi.Id)){
                        //TODO: Time Extension Request email to FEMA Programmatic and FEMA EHP Analyst
                        for(Contact_Role__c conRole : applicationToContactRolesMap.get(rfiToApplicationIdMap.get(rfi.Id))) {
                            toAddresses = new List<String>();
                            toAddresses.add(conRole.Contact__r.Email);
                            mails.addAll(HMA_ApplicationHelper.sendEmail((SObject) subAppsIdMap.get(rfiToApplicationIdMap.get(rfi.Id)), 
                                            toAddresses, 
                                            ccAddresses, 
                                            HMA_CONSTANTS.HMA_FEMA_EHP_RFI_TIME_EXTENSION_REQUESTED_BY_HMA_ANALYST_EMAIL_NOTIFICATION, 
                                            HMA_CONSTANTS.HMA_FROM_EMAIL_ADDRESSES, 
                                            conRole.Contact__c));
                        }
                    }else if(rfi.RFI_Type__c.equals(HMA_CONSTANTS.REQUEST_FOR_INFORMATION_TYPE_FEMA_OES_PROGRAMMATIC) && 
                            rfi.Status__c.equals(HMA_CONSTANTS.REQUEST_FOR_INFORMATION_STATUS_FEMA_TIME_EXTENSION_REQUESTED) && 
                            rfiToApplicationIdMap.containsKey(rfi.Id)){
                        //TODO: Time Extension Request email to FEMA Programmatic and FEMA EHP Analyst
                        for(Contact_Role__c conRole : applicationToContactRolesMap.get(rfiToApplicationIdMap.get(rfi.Id))) {
                            toAddresses = new List<String>();
                            toAddresses.add(conRole.Contact__r.Email);
                            mails.addAll(HMA_ApplicationHelper.sendEmail((SObject) subAppsIdMap.get(rfiToApplicationIdMap.get(rfi.Id)), 
                                            toAddresses, 
                                            ccAddresses, 
                                            HMA_CONSTANTS.HMA_FEMA_PROGRAMMATIC_RFI_TIME_EXTENSION_REQUESTED_BY_HMA_ANALYST_EMAIL_NOTIFICATION, 
                                            HMA_CONSTANTS.HMA_FROM_EMAIL_ADDRESSES, 
                                            conRole.Contact__c));
                        }
                    }else if(rfi.Status__c.equals(HMA_CONSTANTS.REQUEST_FOR_INFORMATION_STATUS_FEMA_TIME_EXTENSION_ACCEPTED)){
                        //TODO: Time Extension Request Accepted email to HMA Analyst
                        //mails.addAll(HMA_ApplicationHelper.prepareForMailsSendToHmaAnalyst(subAppsIdMap.get(rfiToApplicationIdMap.get(rfi.Id)), HMA_CONSTANTS.HMA_FEMA_RFI_TIME_EXTENSION_REQUEST_ACCEPTED_BY_FEMA_ANALYST_EMAIL_NOTIFICATION));
                        feedbackList.add(getFeedItemPost(app.OwnerId, 
                                                        'RFI Time Extension Request Accepted for Subapplication '+app.Name+'/'+rfi.Name,
                                                        'RFI', 
                                                        '/lightning/r/Request_For_Information__c/' + rfi.Id + '/view'));
                    }else if(rfi.Status__c.equals(HMA_CONSTANTS.REQUEST_FOR_INFORMATION_STATUS_FEMA_TIME_EXTENSION_REJECTED)){
                        //TODO: Time Extension Request Reject email to HMA Analyst
                        //mails.addAll(HMA_ApplicationHelper.prepareForMailsSendToHmaAnalyst(subAppsIdMap.get(rfiToApplicationIdMap.get(rfi.Id)), HMA_CONSTANTS.HMA_FEMA_RFI_TIME_EXTENSION_REQUEST_REJECTED_BY_FEMA_ANALYST_EMAIL_NOTIFICATION));
                        feedbackList.add(getFeedItemPost(app.OwnerId, 
                                                        'RFI Time Extension Request Rejected for Subapplication '+app.Name+'/'+rfi.Name,
                                                        'RFI', 
                                                        '/lightning/r/Request_For_Information__c/' + rfi.Id + '/view'));

                    }else  if(rfi.RFI_Type__c.equals(HMA_CONSTANTS.REQUEST_FOR_INFORMATION_TYPE_FEMA_OES_EHP) &&
                                rfi.Status__c.equals(HMA_CONSTANTS.REQUEST_FOR_INFORMATION_STATUS_RESPONSE_SUBMITTED_BY_CAL_OES_ANALYST)){ // 1 EHP
                        //TODO: HMA Analyst Response Submitted to FEMA - send email to FEMA Programmatic and FEMA EHP Analyst
                        for(Contact_Role__c conRole : applicationToContactRolesMap.get(rfiToApplicationIdMap.get(rfi.Id))) {
                            toAddresses = new List<String>();
                            toAddresses.add(conRole.Contact__r.Email);
                            mails.addAll(HMA_ApplicationHelper.sendEmail((SObject) subAppsIdMap.get(rfiToApplicationIdMap.get(rfi.Id)), 
                                            toAddresses, 
                                            ccAddresses, 
                                            HMA_CONSTANTS.HMA_FEMA_EHP_RFI_RESPONSE_SUBMITTED_BY_HMA_ANALYST_EMAIL_NOTIFICATION, 
                                            HMA_CONSTANTS.HMA_FROM_EMAIL_ADDRESSES, 
                                            conRole.Contact__c));
                        }
                    }else  if(rfi.RFI_Type__c.equals(HMA_CONSTANTS.REQUEST_FOR_INFORMATION_TYPE_FEMA_OES_PROGRAMMATIC) && 
                                rfi.Status__c.equals(HMA_CONSTANTS.REQUEST_FOR_INFORMATION_STATUS_RESPONSE_SUBMITTED_BY_CAL_OES_ANALYST)){ // 2 Programmatic
                        //TODO: HMA Analyst Response Submitted to FEMA - send email to FEMA Programmatic and FEMA EHP Analyst
                        for(Contact_Role__c conRole : applicationToContactRolesMap.get(rfiToApplicationIdMap.get(rfi.Id))) {
                            toAddresses = new List<String>();
                            toAddresses.add(conRole.Contact__r.Email);
                            mails.addAll(HMA_ApplicationHelper.sendEmail((SObject) subAppsIdMap.get(rfiToApplicationIdMap.get(rfi.Id)), 
                                            toAddresses, 
                                            ccAddresses, 
                                            HMA_CONSTANTS.HMA_FEMA_PROGRAMMATIC_RFI_RESPONSE_SUBMITTED_BY_HMA_ANALYST_EMAIL_NOTIFICATION, 
                                            HMA_CONSTANTS.HMA_FROM_EMAIL_ADDRESSES, 
                                            conRole.Contact__c));
                        }
                    }else if(rfi.Status__c.equals(HMA_CONSTANTS.REQUEST_FOR_INFORMATION_STATUS_FEMA_PROGRAMMATIC_RFI_ACCEPTED) ||
                            rfi.Status__c.equals(HMA_CONSTANTS.REQUEST_FOR_INFORMATION_STATUS_FEMA_EHP_RFI_ACCEPTED)){
                            feedbackList.add(getFeedItemPost(app.OwnerId, 
                                                            'RFI Accepted for Subapplication '+app.Name+'/'+rfi.Name,
                                                            'RFI', 
                                                            '/lightning/r/Request_For_Information__c/' + rfi.Id + '/view'));
                    }else if(rfi.Status__c.equals(HMA_CONSTANTS.REQUEST_FOR_INFORMATION_STATUS_FEMA_PROGRAMMATIC_RFI_REJECTED) ||
                            rfi.Status__c.equals(HMA_CONSTANTS.REQUEST_FOR_INFORMATION_STATUS_FEMA_EHP_RFI_REJECTED)){
                            feedbackList.add(getFeedItemPost(app.OwnerId, 
                                                            'RFI Rejected for Subapplication '+app.Name+'/'+rfi.Name,
                                                            'RFI', 
                                                            '/lightning/r/Request_For_Information__c/' + rfi.Id + '/view'));
                    }
                }
            }
            if(mails.size() > 0) {
            Messaging.sendEmail(mails);
            }
            //Update the new record status
            String rfiStatusStr = (String) newRFI.Status__c;
        
            if(FEMA_RFI_TYPES.contains(newRFI.RFI_Type__c)) {
                if((newRFI.Status__c == HMA_CONSTANTS.REQUEST_FOR_INFORMATION_STATUS_FEMA_TIME_EXTENSION_ACCEPTED || 
                    newRFI.Status__c == HMA_CONSTANTS.REQUEST_FOR_INFORMATION_STATUS_FEMA_TIME_EXTENSION_REJECTED) && 
                    oldRFI.Status__c == HMA_CONSTANTS.REQUEST_FOR_INFORMATION_STATUS_FEMA_TIME_EXTENSION_REQUESTED) {
                        newRFI.Status__c = HMA_CONSTANTS.REQUEST_FOR_INFORMATION_STATUS_SUBMITTED_TO_CAL_OES_ANALYST;
                        rfiForUpdate.add(newRFI);
                }
            }else if(NON_FEMA_RFI_TYPES.contains(newRFI.RFI_Type__c)) {
                if((newRFI.Status__c == HMA_CONSTANTS.REQUEST_FOR_INFORMATION_STATUS_TIME_EXTENSION_ACCEPTED || 
                    newRFI.Status__c == HMA_CONSTANTS.REQUEST_FOR_INFORMATION_STATUS_TIME_EXTENSION_REJECTED) && 
                    oldRFI.Status__c == HMA_CONSTANTS.REQUEST_FOR_INFORMATION_STATUS_TIME_EXTENSION_REQUESTED) {
                        System.debug('newRFI.Status__c----'+newRFI.Status__c);
                        newRFI.Status__c = HMA_CONSTANTS.REQUEST_FOR_INFORMATION_STATUS_SENT_TO_SUBAPPLICANT;
                        rfiForUpdate.add(newRFI);
                        System.debug('rfiForUpdate----'+rfiForUpdate);
                    }
            }
            System.debug('rfiForUpdate2----'+rfiForUpdate);
            if(rfiForUpdate.size() > 0) {
                update rfiForUpdate;
            }
            if(feedbackList.size() > 0) {
                insert feedbackList;
            }
        } catch (Exception e) {
            System.debug('error----'+e.getMessage());
            System.debug('error-2---'+e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        } 
    }

    public static FeedItem getFeedItemPost(String parentId, String body, String title, String linkUrl) {
        FeedItem post = new FeedItem();
        post.ParentId = parentId;
        post.Body = body;
        post.Title = title;
        post.LinkUrl = linkUrl;
        return post;
    }
}