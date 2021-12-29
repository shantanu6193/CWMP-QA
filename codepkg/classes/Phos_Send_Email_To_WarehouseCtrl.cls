/***********************************************************************************************************************************
* Class Name   : Phos_Send_Email_To_WarehouseCtrl
* Description  : This class for send email to warehouse
* Author       : Pankaj
* Created On   : 04/02/2020
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Pankaj              04/02/2020      Initial Implementation
**************************************************************************************************************************************/

public with sharing class Phos_Send_Email_To_WarehouseCtrl {
    
    /***********************************************
    * Method Name : sendEmailToWareHouse
    * Author : Pankaj
    * Inputs : String orderIdString
    * Description: This method send email to warehouse
    *********************************************/
    /*@AuraEnabled
    public static void sendEmailToWareHouse(String orderIdString) {

        List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>();
        List<Key_Value_Store__mdt> toAddressList = [Select Id,Text_Value__c from Key_Value_Store__mdt where DeveloperName='PHOS_To_Email_Addresses' LIMIT  1];
        List<String> toEmailAddresses = new List<String>();
        for(Key_Value_Store__mdt toAddress : toAddressList){
            toEmailAddresses.addAll(toAddress.Text_Value__c.split(','));
        }

        List<Key_Value_Store__mdt> ccAddressList = [Select Id,Text_Value__c from Key_Value_Store__mdt where DeveloperName='PHOS_Cc_Email_Addresses' LIMIT  1];
        List<String> ccEmailAddresses = new List<String>();
        for(Key_Value_Store__mdt toAddress : ccAddressList){
            ccEmailAddresses.addAll(toAddress.Text_Value__c.split(','));
        }


        List<Key_Value_Store__mdt> fromAddressList=[Select Id,Text_Value__c from Key_Value_Store__mdt where DeveloperName='PHOS_From_Email_Addresses' LIMIT 1];
        List<OrgWideEmailAddress> fromAddresses = new List<OrgWideEmailAddress>();
        Id OrgWideEmailAddressId;
        if(fromAddressList.size()>0){
            fromAddresses =  [Select Id from OrgWideEmailAddress where DisplayName=:fromAddressList[0].Text_Value__c];
        }
        if(fromAddresses.size()>0){
            OrgWideEmailAddressId = fromAddresses[0].Id;
        }

        System.debug('**************OrgWideEmailAddressId*************  '+OrgWideEmailAddressId);

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(toEmailAddresses);
        mail.setCcAddresses(ccEmailAddresses);

        mail.setOrgWideEmailAddressId(OrgWideEmailAddressId);

        EmailTemplate et = [SELECT id FROM EmailTemplate WHERE developerName = 'CDPH_Order_Fulfil'];
        Messaging.SingleEmailMessage singleEmail = Messaging.renderStoredEmailTemplate(et.Id,null
                    , (String.isNotEmpty(orderIdString) ? orderIdString : null));
        mail.htmlBody=String.isNotEmpty(singleEmail.htmlBody) ? singleEmail.htmlBody : formatPlainBody(singleEmail.plainTextBody);
        mail.subject = singleEmail.subject;

        mail.setWhatId(orderIdString);
        mail.setSaveAsActivity(true);
        mails.add(mail);
        System.debug('**************mail*************  '+mail);

        System.debug('**************mails ALL*************  '+mails);
        Messaging.sendEmail(mails);
    }

    private static String formatPlainBody(String plainBody) {
        if (String.isEmpty(plainBody)) return '';
        return plainBody.replace('\n', '<br/>');
    }*/
}