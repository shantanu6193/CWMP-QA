/**
 * Created by Shivraj on 21-09-2020.
 */

public without sharing class HMA_Email_For_NewRequest {
    @InvocableMethod(label='Email for New NOI Request' description='Request for NOI')
    public static void sendEmail(List<Id> requestIds) {
        List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>();
        List<EmailMessage> tasks = [SELECT Id, RelatedToId
        from EmailMessage
        where RelatedToId IN:requestIds AND Subject like 'SUBMISSION CONFIRMATION%'];
        List<Id> tskIDs = new List<Id>();
        for(EmailMessage task: tasks){
            tskIDs.add(task.RelatedToId);
        }


        List<Pre_Application__c> preApplications = [SELECT Id,RecordType.Name,CreatedBy.Email,
                                                    (SELECT Id, Contact__c, Contact__r.Email from Contact_Roles__r WHERE Role__c includes('Responsible Representative') LIMIT 1)
                                                    from Pre_Application__c where ID IN : requestIds];

        Map<String, Id> templateNameToId = new Map<String, Id>();
        for(EmailTemplate emailTemplate : [Select Id, DeveloperName from EmailTemplate]) {
            templateNameToId.put(emailTemplate.DeveloperName, emailTemplate.Id);
        }
        String fromAddr = KeyValueHelper.getTextValue('HMA_From_Email_Addresses');
        List<OrgWideEmailAddress> fromAddresses = new List<OrgWideEmailAddress>();
        Id OrgWideEmailAddressId;
        if(String.isNotBlank(fromAddr)){
            fromAddresses =  [Select Id from OrgWideEmailAddress where DisplayName=: fromAddr];
        }
        if(fromAddresses.size()>0){
            OrgWideEmailAddressId = fromAddresses[0].Id;
        }
        List<String> toAddress = new List<String>();
        List<Pre_Application__c> preAppToUpdate = new List<Pre_Application__c>();
        for (Pre_Application__c preAppRec : preApplications) {
            if(!tskIDs.contains(preAppRec.Id)){//To send email only once
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                toAddress.add(preAppRec.CreatedBy.Email);

                String templateToSend;
                if(preAppRec.RecordType.Name == 'HMGP') {
                    templateToSend = templateNameToId.get('HMA_NOI_New_Request_Email');
                    /* https://stacknexus.atlassian.net/browse/CALOESHMA-62
                    Send email to Responsible Representative we are assuming that there is only 1 Responsible Representative on NOI*/
                    if(preAppRec.Contact_Roles__r.size() > 0){
                        toAddress.add(preAppRec.Contact_Roles__r[0].Contact__r.Email);
                        preAppToUpdate.add(new Pre_Application__c(Id=preAppRec.Id, Responsible_Representative__c = preAppRec.Contact_Roles__r[0].Contact__c));
                    }
                }
                if(preAppRec.RecordType.Name == 'BRIC') {
                    templateToSend = templateNameToId.get('BRIC_NOI_New_Request_Email');
                }
                if(preAppRec.RecordType.Name == 'FMA') {
                    templateToSend = templateNameToId.get('FMA_NOI_New_Request_Email');
                }
                Messaging.SingleEmailMessage singleEmail = Messaging.renderStoredEmailTemplate(templateToSend, null
                        , (String.isNotEmpty(preAppRec.Id) ? preAppRec.Id : null));
                mail.setToAddresses(toAddress);
                mail.setOrgWideEmailAddressId(OrgWideEmailAddressId);
                mail.htmlBody = String.isNotEmpty(singleEmail.htmlBody) ? singleEmail.htmlBody : formatPlainBody(singleEmail.plainTextBody);
                mail.subject = singleEmail.subject;
                mail.setWhatId(preAppRec.Id);
                mail.setSaveAsActivity(true);
                mails.add(mail);
                System.debug('**************mail*************  ' + mail);
            }
        }
        System.debug('**************mails ALL*************  '+mails);
        Messaging.sendEmail(mails);
        update preAppToUpdate;
    }

    private static String formatPlainBody(String plainBody) {
        if (String.isEmpty(plainBody)) return '';
        return plainBody.replace('\n', '<br/>');
    }
}