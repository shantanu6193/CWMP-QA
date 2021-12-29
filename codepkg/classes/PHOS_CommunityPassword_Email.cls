/***********************************************************************************************************************************
* Class Name   : PHOS_CommunityPassword_Email
* Description  : This class for PHOS community password email tracking
* Author       : Pankaj
* Created On   : 10/29/2020
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Pankaj              10/29/2020      Initial Implementation
**************************************************************************************************************************************/

public without sharing class PHOS_CommunityPassword_Email {
    public static Boolean hasExecuted = false;

    /***********************************************
    * Method Name : sendEmail
    * Author : Pankaj
    * Inputs : List<Id> userIds
    * Description: This method call sendEmailToUser method for sending email
    *********************************************/
    @InvocableMethod(label='Send Reset Password Email' description='Email Tracking for Set Password from User Registration')
    public static void sendEmail(List<Id> userIds) {
        if(hasExecuted == false) {
            sendEmailToUser(userIds);
            hasExecuted = true;
        }
    }

    /***********************************************
    * Method Name : formatPlainBody
    * Author : Pankaj
    * Inputs : String plainBody
    * Description: This method return string with relpace \n with <br/>
    *********************************************/
    private static String formatPlainBody(String plainBody) {
        if (String.isEmpty(plainBody)) return '';
        return plainBody.replace('\n', '<br/>');
    }

    /***********************************************
    * Method Name : sendEmailToUser
    * Author : Pankaj
    * Inputs : List<Id> userIds
    * Description: This method send an email to user and track under activity
    *********************************************/
    public static void sendEmailToUser(List<Id> userIds){
        List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>();
        /** Added recordtypeid and Status__c in Query **/
        List<User_Registration__c> users = [SELECT Id, Name, recordtypeid, Status__c, Email__c, Translation_Language__c FROM User_Registration__c WHERE Id IN :userIds];
        String fromAddr = KeyValueHelper.getTextValue(HH_CONSTANTS.From_EmailAddress_PHOS);
        List<OrgWideEmailAddress> fromAddresses = new List<OrgWideEmailAddress>();
        Id OrgWideEmailAddressId;
        if(String.isNotBlank(fromAddr)){
            fromAddresses =  [Select Id from OrgWideEmailAddress where DisplayName=: fromAddr];
        }
        if(fromAddresses.size()>0){
            OrgWideEmailAddressId = fromAddresses[0].Id;
        }
       
        for (User_Registration__c userRecord : users) {
            /** getting recordTypeName of Record **/
            string recordTypeName = Schema.SObjectType.User_Registration__c.getRecordTypeInfosById().get(userRecord.recordtypeid).getDeveloperName();
            String emailTemplateName = HH_CONSTANTS.Email_Template_CalOES_Community_Set_Password;
            /** If HH Record then send HH Email template **/
            if (recordTypeName == HH_CONSTANTS.RecordType_HH_RegistrationAPIName) {
                /** If Translation Language is English then send Email in English **/
                if(userRecord.Translation_Language__c ==HH_CONSTANTS.Language_English){
                    /** If Status = Verification Pending send Set password Email**/
                    if(userRecord.Status__c == HH_CONSTANTS.UserRegistration_Status_VerificationPending){
                        emailTemplateName = HH_CONSTANTS.Email_Template_CalOES_HH_Community_Set_Password_EN;
                        System.debug('emailTemplateName-- 72'+emailTemplateName);
                    }
                    /** If Status = Verification Pending send ReSet password Email**/
                    if(userRecord.Status__c == HH_CONSTANTS.UserRegistration_Status_PasswordReset){
                        emailTemplateName = HH_CONSTANTS.Email_Template_CalOES_HH_Community_Reset_Password_EN;
                    }
                }
                /** If Translation Language is Spanish then send Email in Spanish **/
                else if(userRecord.Translation_Language__c == HH_CONSTANTS.Language_Spanish){
                    /** If Status = Verification Pending send Set password Email**/
                    if(userRecord.Status__c == HH_CONSTANTS.UserRegistration_Status_VerificationPending){
                        emailTemplateName = HH_CONSTANTS.Email_Template_CalOES_HH_Community_Set_Password_ES;
                    }
                    /** If Status = Verification Pending send ReSet password Email**/
                    if(userRecord.Status__c == HH_CONSTANTS.UserRegistration_Status_PasswordReset){
                        emailTemplateName = HH_CONSTANTS.Email_Template_CalOES_HH_Community_Reset_Password_ES;
                    }
                }
            }
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            List<String> toAddressList = new List<String>();
            toAddressList.add(userRecord.Email__c);
            mail.setToAddresses(toAddressList);
            mail.setOrgWideEmailAddressId(OrgWideEmailAddressId);
            EmailTemplate et = [SELECT Id FROM EmailTemplate WHERE DeveloperName =:emailTemplateName];
            Messaging.SingleEmailMessage singleEmail = Messaging.renderStoredEmailTemplate(et.Id, null
                    , (String.isNotEmpty(userRecord.Id) ? userRecord.Id : null));
            mail.htmlBody = String.isNotEmpty(singleEmail.htmlBody) ? singleEmail.htmlBody : formatPlainBody(singleEmail.plainTextBody);
            System.debug('singleEmail.subject*************  ' + singleEmail.subject);
            mail.subject = singleEmail.subject;
            mail.setWhatId(userRecord.Id);
            mail.setSaveAsActivity(true);
            mails.add(mail);
            System.debug('**************mail*************  ' + mail);
        }
        System.debug('**************mails ALL*************  '+mails);
        Messaging.sendEmail(mails);
    }
}