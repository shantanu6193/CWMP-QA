/***********************************************************************************************************************************
* Class Name   : EmailHelper
* Description  : This class for send the emails
* Author       : Pankaj
* Created On   : 07/12/2020
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Pankaj             07/12/2020       Initial Implementation
**************************************************************************************************************************************/

public class EmailHelper {
    
    /***********************************************
    * Method Name : sendEmail
    * Author : Pankaj
    * Inputs : List<SObject> records, List<String> toAddresses ,List<String> ccAddresses, String emailTemplate, String fromAddress
    * Description: This method return List of email messages
    *********************************************/
    public static List<Messaging.SingleEmailMessage> sendEmail(List<SObject> records, List<String> toAddresses ,List<String> ccAddresses, String emailTemplate, String fromAddress){
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        EmailTemplate templateToSend = [Select id, HtmlValue from EmailTemplate where name =:emailTemplate LIMIT 1];
        String fromAddr = KeyValueHelper.getTextValue(fromAddress);
        List<OrgWideEmailAddress> fromAddresses = new List<OrgWideEmailAddress>();
        Id OrgWideEmailAddressId;
        if(String.isNotBlank(fromAddr)){
            fromAddresses =  [Select Id from OrgWideEmailAddress where DisplayName=: fromAddr];
        }
        if(fromAddresses.size()>0){
            OrgWideEmailAddressId = fromAddresses[0].Id;
        }
        system.debug('.....'+templateToSend+'ssss'+records);
        for(SObject sObj: records){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(toAddresses);
            mail.setCcAddresses(ccAddresses);
            mail.setOrgWideEmailAddressId(OrgWideEmailAddressId);
            Messaging.SingleEmailMessage singleEmail = Messaging.renderStoredEmailTemplate(templateToSend.Id,null, (String.isNotEmpty(sObj.Id) ? sObj.Id : null));
            mail.htmlBody=String.isNotEmpty(singleEmail.htmlBody) ? singleEmail.htmlBody : formatPlainBody(singleEmail.plainTextBody);
            mail.subject = singleEmail.subject;
            System.debug('Html Body Val-=------'+ mail.htmlBody);
             System.debug('Subject Val-=------'+ mail.subject);
            mail.setWhatId(sObj.Id);
            mail.setSaveAsActivity(true);
            mails.add(mail);
        }
        return mails;
    }
    
    /***********************************************
    * Method Name : formatPlainBody
    * Author : Pankaj
    * Inputs : String plainBody
    * Description: This method replace \n with <br/> in string and return a string 
    *********************************************/
    @TestVisible
    private static String formatPlainBody(String plainBody) {
        if (String.isEmpty(plainBody)) return '';
        return plainBody.replace('\n', '<br/>');
    }

    /***********************************************
    * Method Name : sendEmail
    * Author : Pankaj
    * Inputs : String whatId, String targetObjectId ,List<String> ccAddresses, String emailTemplate, String fromAddress
    * Description: This method return List of email messages
    *********************************************/
    public static List<Messaging.SingleEmailMessage> sendEmail(String whatId, String targetObjectId, List<String> ccAddresses, String emailTemplate, String fromAddress){
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        EmailTemplate templateToSend = [Select Id from EmailTemplate where Name =:emailTemplate LIMIT 1];
        String fromAddr = KeyValueHelper.getTextValue(fromAddress);
        Id OrgWideEmailAddressId;
        if(String.isNotBlank(fromAddr)){
            List<OrgWideEmailAddress> orgWideEmailAddresses = [Select Id from OrgWideEmailAddress where DisplayName=: fromAddr];
            if(orgWideEmailAddresses.size() > 0) {
                OrgWideEmailAddressId = orgWideEmailAddresses[0].Id;
            }
        }

        Messaging.SingleEmailMessage singleEmail = Messaging.renderStoredEmailTemplate(templateToSend.Id,targetObjectId, whatId);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTargetObjectId(targetObjectId);
        mail.setCcAddresses(ccAddresses);
        mail.setOrgWideEmailAddressId(OrgWideEmailAddressId);

        mail.htmlBody=String.isNotEmpty(singleEmail.htmlBody) ? singleEmail.htmlBody : formatPlainBody(singleEmail.plainTextBody);
        mail.subject = singleEmail.subject;
        System.debug('Html Body Val-=------'+ mail.htmlBody);
        System.debug('Subject Val-=------'+ mail.subject);
        mail.setWhatId(whatId);
        mail.setSaveAsActivity(true);
        mails.add(mail);
        Messaging.sendEmail(mails);
        return mails;
    }
}