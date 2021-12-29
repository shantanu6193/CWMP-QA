/***********************************************************************************************************************************
* Class Name   : PHOS_SendEmail_Request_From_Other_User
* Description  : This class for send order email request from RDMHS or other user 
* Author       : Pankaj
* Created On   : 04/07/2020
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Pankaj              04/07/2020      Initial Implementation
**************************************************************************************************************************************/

public with sharing class PHOS_SendEmail_Request_From_Other_User {

    /***********************************************
    * Method Name : sendEmail
    * Author : Pankaj
    * Inputs : List<Id> orderIds
    * Description: This method send order email request from RDMHS or other user 
    *********************************************/
    @InvocableMethod(label='Order Request from RDMHS or other USER' description='Request from RDMHS or other USER')
    public static void sendEmail(List<Id> orderIds) {
       /* List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>();
        List<EmailMessage> tasks = [SELECT Id, RelatedToId from EmailMessage where RelatedToId IN:orderIds AND Subject like 'New request submitted by RDMHS/Other User%'];
        List<Id> tskIDs = new List<Id>();
        for(EmailMessage task: tasks){
            tskIDs.add(task.RelatedToId);
        }

        List<Key_Value_Store__mdt> toAddressList=[Select Id,Text_Value__c from Key_Value_Store__mdt where DeveloperName='PHOS_Order_Confirmation_To_Address' LIMIT  1];
        List<String> sendTo = new List<String>();
        for(Key_Value_Store__mdt toAddress:toAddressList){
            sendTo.addAll(AppUtils.fetchAllEmailAddresses(toAddress.Text_Value__c));
        }

        System.debug('**************To address*************  '+sendTo);

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
        System.debug('**************listofOrderIds*************  '+orderIds);
        for(Id orderId :orderIds) {
            if(!tskIDs.contains(orderId)){//To send email only once
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(sendTo);
                mail.setOrgWideEmailAddressId(OrgWideEmailAddressId);

                EmailTemplate et = [SELECT id FROM EmailTemplate WHERE developerName = 'PHOS_ORDER_REQUEST_FROM_RDMHS'];
                Messaging.SingleEmailMessage singleEmail = Messaging.renderStoredEmailTemplate(et.Id,null
                        , (String.isNotEmpty(orderId) ? orderId : null));
                mail.htmlBody=String.isNotEmpty(singleEmail.htmlBody) ? singleEmail.htmlBody : formatPlainBody(singleEmail.plainTextBody);
                mail.subject = singleEmail.subject;

                mail.setWhatId(orderId);
                mail.setSaveAsActivity(true);
                mails.add(mail);
                System.debug('**************mail*************  '+mail);
            }
        }
        System.debug('**************mails ALL*************  '+mails);
        Messaging.sendEmail(mails);*/
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
}