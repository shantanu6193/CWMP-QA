public without sharing class HMA_Sub_Application_StatusEmail {
    public HMA_Sub_Application_StatusEmail() {

    }

    //TODO: Change method name to sendStatusChangeEmail - We have to handle other Status's in this class only so Check RT = HMGP and Status = Pending Review

    @InvocableMethod(label='HMA Subapp Status Email' description='description')
    public static void sendStatusChangeEmail(List<Id> ids) {
        List<String> toAddresses;
        List<String> ccAddresses = new List<String>();
        String recordTypeHMGP = HMA_CONSTANTS.SUB_APPLICATION_RECORDTYPE_HMGP;
        
        //Create a map of id and application record with record type and status as expected
        Map<Id, Application__c> subAppsIdMap = new Map<Id, Application__c>([SELECT Id, 
                                                                                    Status__c, 
                                                                                    Status_Reason__c,
                                                                                    Local_Hazard_Mitigation_Plan_Status__c,
                                                                                    Is_BCR_verified_at_1_0_or_greater__c,
                                                                                    Is_this_an_eligible_Activity__c,
                                                                                    Is_this_an_eligible_Subapplicant__c,
                                                                                    (SELECT Id, 
                                                                                            Role__c,
                                                                                            Contact__c, 
                                                                                            Contact__r.Email 
                                                                                            FROM Contact_Roles__r 
                                                                                            WHERE Role__c INCLUDES('Primary Contact', 'Responsible Representative', 'Contributor')) 
                                                                                    FROM Application__c 
                                                                                    WHERE Id IN :ids AND RecordType.Name = :recordTypeHMGP]);//, OwnerId, Owner.UserRole.Name

        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<Messaging.SingleEmailMessage> modifyMails = new List<Messaging.SingleEmailMessage>();
        for(Application__c subApp : subAppsIdMap.values()) {
            if(subApp.Status__c == HMA_CONSTANTS.APPLICATION_STATUS_OES_REVIEW && subApp.Status_Reason__c == HMA_CONSTANTS.APPLICATION_STATUS_REASON_PENDING_OES_REVIEW) {
                for(Contact_Role__c conRole : subApp.Contact_Roles__r) {
                    toAddresses = new List<String>();
                    toAddresses.add(conRole.Contact__r.Email);
                    mails.addAll(HMA_ApplicationHelper.sendEmail((SObject) subApp, 
                                                                toAddresses, 
                                                                ccAddresses, 
                                                                HMA_CONSTANTS.EMAIL_TEMPLATE_HMA_SUBAPP_SUBMISSION_NOTIFICATION, 
                                                                HMA_CONSTANTS.HMA_FROM_EMAIL_ADDRESSES, 
                                                                conRole.Contact__c));
                }
            } else if(subApp.Status__c == HMA_CONSTANTS.APPLICATION_STATUS_WITHDRAWN && 
                        (subApp.Status_Reason__c == HMA_CONSTANTS.APPLICIATION_STATUS_REASON_BY_SUBAPPLICANT_AFTER_FUNDS_ARE_OBLIGATED || 
                        subApp.Status_Reason__c == HMA_CONSTANTS.APPLICIATION_STATUS_REASON_BY_SUBAPPLICANT_WITH_NO_FUNDS_OBLIGATED)) {
                for(Contact_Role__c conRole : subApp.Contact_Roles__r) {
                    toAddresses = new List<String>();
                    toAddresses.add(conRole.Contact__r.Email);
                    mails.addAll(HMA_ApplicationHelper.sendEmail((SObject) subApp, 
                                                                toAddresses, 
                                                                ccAddresses, 
                                                                HMA_CONSTANTS.HMA_SUBAPPLICATION_WITHDRAWN_EMAIL_NOTIFICATION, 
                                                                HMA_CONSTANTS.HMA_FROM_EMAIL_ADDRESSES, 
                                                                conRole.Contact__c));
                }
            } else if(subApp.Status__c == HMA_CONSTANTS.APPLICATION_STATUS_WITHDRAWN && subApp.Status_Reason__c == HMA_CONSTANTS.APPLICIATION_STATUS_REASON_BY_OES) {
                for(Contact_Role__c conRole : subApp.Contact_Roles__r) {
                    toAddresses = new List<String>();
                    toAddresses.add(conRole.Contact__r.Email);
                    modifyMails = HMA_ApplicationHelper.sendEmail((SObject) subApp, 
                                                                toAddresses, 
                                                                ccAddresses, 
                                                                HMA_CONSTANTS.HMA_SUBAPPLICATION_WITHDRAWN_BY_CAL_OES_EMAIL_NOTIFICATION, 
                                                                HMA_CONSTANTS.HMA_FROM_EMAIL_ADDRESSES, 
                                                                conRole.Contact__c);

                    for(Messaging.SingleEmailMessage mail : modifyMails) {
                        String reason = '';
                        if(subApp.Local_Hazard_Mitigation_Plan_Status__c == 'Not Started') {
                            reason = reason + '- Due to not having an approved Local Hazard Mitigation Plan (LHMP)' + '<br><br>';
                        }
                        if(subApp.Is_BCR_verified_at_1_0_or_greater__c == 'No') {
                            reason = reason + '- Due to BCR of less than 1.0' + '<br><br>';
                        }
                        if(subApp.Is_this_an_eligible_Activity__c == 'No') {
                            reason = reason + '- Due to Subapplicant not eligible' + '<br><br>';
                        }
                        if(subApp.Is_this_an_eligible_Subapplicant__c == 'No') {
                            reason = reason + '- Due to ineligible activity' + '<br>';
                        }
                        mail.htmlBody = mail.htmlBody.replace('withdrawn_reason', reason);
                    }
                    mails.addAll(modifyMails);
                }
            }
            /*if(subApp.Owner.UserRole.Name != null && (subApp.Owner.UserRole.Name).equals(HMA_CONSTANTS.HMA_USER_ROLE_HMA_ANALYST) && (subApp.Status_Reason__c == HMA_CONSTANTS.APPLICATION_STATUS_REASON_ANALYST_REVIEW_IN_PROGRESS)) {
                mails.addAll(HMA_ApplicationHelper.sendEmail((SObject) subApp, toAddresses, ccAddresses, HMA_CONSTANTS.EMAIL_TEMPLATE_HMA_SUBAPP_SUBMISSION_NOTIFICATION, HMA_CONSTANTS.HMA_FROM_EMAIL_ADDRESSES, subApp.ownerId));
            }*/
        }
        Messaging.sendEmail(mails);
    }
}