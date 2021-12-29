/***********************************************************************************************************************************
* Class Name   : PHOS_SendEmail_OrderApproval
* Description  : This class for send order approval email
* Author       : Pankaj
* Created On   : 10/23/2020
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Pankaj              10/23/2020      Initial Implementation
**************************************************************************************************************************************/

public without sharing class PHOS_SendEmail_OrderApproval {
    public static Boolean hasExecuted = false;
   
    /***********************************************
    * Method Name : sendEmail
    * Author : Pankaj
    * Inputs : List<Id> orderIds
    * Description: This method call sendEmailFuture method for send an email
    *********************************************/
    @InvocableMethod(label='Order Approval Email' description='Order Approval Email')
    public static void sendEmail(List<Id> orderIds) {
        if(hasExecuted == false) {
            sendEmailFuture(orderIds);
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
    * Method Name : sendEmailFuture
    * Author : Pankaj
    * Inputs : List<Id> orderIds
    * Description: This method send order approval email
    *********************************************/
    public static void sendEmailFuture(List<Id> orderIds){
        List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>();
        List<Order__c> orders = [SELECT Id, Name, CreatedBy.Email, Record_Approval_Status__c FROM Order__c WHERE Id IN :orderIds];
        Map<Id, String> orderIDCountyApprover = new Map<Id, String>();
        String fromAddr = KeyValueHelper.getTextValue('PHOS_From_Email_Addresses');
        List<OrgWideEmailAddress> fromAddresses = new List<OrgWideEmailAddress>();
        Id OrgWideEmailAddressId;
        if(String.isNotBlank(fromAddr)){
            fromAddresses =  [Select Id from OrgWideEmailAddress where DisplayName=: fromAddr];
        }
        if(fromAddresses.size()>0){
            OrgWideEmailAddressId = fromAddresses[0].Id;
        }
        List<ProcessInstance> processInstances = [SELECT Id,ProcessDefinition.DeveloperName,LastActor.Email,TargetObjectId,LastActor.Account.Entity_Type__c
        FROM ProcessInstance WHERE TargetObjectId IN: orderIds];
        for(ProcessInstance processInstance : processInstances) {
            if(processInstance.ProcessDefinition.DeveloperName == 'MHOAC_Review_Process') {
                orderIDCountyApprover.put(processInstance.TargetObjectId, processInstance.LastActor.Email);
            }
        }

        for (Order__c order : orders) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            List<String> toAddressList = new List<String>();
            List<String> ccAddressList = new List<String>();
            toAddressList.add(order.CreatedBy.Email);
            mail.setToAddresses(toAddressList);
            mail.setOrgWideEmailAddressId(OrgWideEmailAddressId);
            if(order.Record_Approval_Status__c == 'RDMHS User Approved') {
                if(orderIDCountyApprover != null && orderIDCountyApprover.get(order.Id) != null) {
                    ccAddressList.add(orderIDCountyApprover.get(order.Id));
                    if(ccAddressList != null && !ccAddressList.isEmpty()) {
                        mail.setCcAddresses(ccAddressList);
                    }
                }
            }
            EmailTemplate et = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'PHOS_Order_Approval_Email'];
            Messaging.SingleEmailMessage singleEmail = Messaging.renderStoredEmailTemplate(et.Id, null
                    , (String.isNotEmpty(order.Id) ? order.Id : null));
            mail.htmlBody = String.isNotEmpty(singleEmail.htmlBody) ? singleEmail.htmlBody : formatPlainBody(singleEmail.plainTextBody);
            System.debug('singleEmail.subject*************  ' + singleEmail.subject);
            if(order.Record_Approval_Status__c == 'County User Approved') {
                mail.subject = singleEmail.subject + ' County '+order.Name;
            }
            if(order.Record_Approval_Status__c == 'RDMHS User Approved') {
                mail.subject = singleEmail.subject + ' Region '+order.Name;
            }

            mail.setWhatId(order.Id);
            mail.setSaveAsActivity(true);
            mails.add(mail);
            System.debug('**************mail*************  ' + mail);


        }
        System.debug('**************mails ALL*************  '+mails);
        Messaging.sendEmail(mails);
    }
}