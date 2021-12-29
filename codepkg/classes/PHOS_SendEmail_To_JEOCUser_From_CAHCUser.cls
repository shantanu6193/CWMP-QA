/***********************************************************************************************************************************
* Class Name   : PHOS_SendEmail_To_JEOCUser_From_CAHCUser
* Description  : This class for send order request email to incidents 
* Author       : Chandrabhan
* Created On   : 03/22/2021
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Pankaj              03/22/2021      Initial Implementation
**************************************************************************************************************************************/

public without sharing class PHOS_SendEmail_To_JEOCUser_From_CAHCUser {
    public static Boolean hasExecuted = false;

    /***********************************************
    * Method Name : sendEmail
    * Author : Pankaj
    * Inputs : List<Id> orderIds
    * Description: This method call sendEmailFuture method for send an email
    *********************************************/
    @InvocableMethod(label='Order Update From Mulesoft' description='Send email notification from Mulesoft to PHOS JEOC User when order status is Staffing in Progress')
    public static void sendEmail(List<Id> orderIds) {
        //if(hasExecuted == false && !QuiddityController.getEmailQuidity()) {
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
    @TestVisible
    private static String formatPlainBody(String plainBody) {
        if (String.isEmpty(plainBody)) return '';
        return plainBody.replace('\n', '<br/>');
    }

    /***********************************************
    * Method Name : sendEmailFuture
    * Author : Pankaj
    * Inputs : List<Id> orderIds
    * Description: This method send order request email to incidents
    *********************************************/
    @future
    public static void sendEmailFuture(List<Id> orderIds){
        List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>();
        List<String> idList = new List<String>();
        List<String> mailToAddresses = new List<String>(); 
        String fromAddr = KeyValueHelper.getTextValue('PHOS_From_Email_Addresses');
        List<OrgWideEmailAddress> fromAddresses = new List<OrgWideEmailAddress>();
        Id OrgWideEmailAddressId;
        if(String.isNotBlank(fromAddr)){
            fromAddresses =  [Select Id from OrgWideEmailAddress where DisplayName=: fromAddr];
        }
        if(fromAddresses.size()>0){
            OrgWideEmailAddressId = fromAddresses[0].Id;
        }
        Group gp = [SELECT (SELECT UserOrGroupId FROM GroupMembers) FROM Group WHERE DeveloperName = 'PHOS_Staffing_People'];
        for (GroupMember gm : gp.GroupMembers) {
            idList.add(gm.UserOrGroupId);
        }
        List<User> userList = [SELECT Email FROM User WHERE Id IN :idList];
        for(User u : userList) {
            mailToAddresses.add(u.email);
        } 
        if (mailToAddresses != null && !mailToAddresses.isEmpty()){
            for (String orderId : orderIds) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setToAddresses(mailToAddresses);
                    mail.setOrgWideEmailAddressId(OrgWideEmailAddressId);
                    EmailTemplate et = [SELECT id FROM EmailTemplate WHERE DeveloperName = 'PHOS_Order_Status_Staffing_In_Progres_Email'];
                    Messaging.SingleEmailMessage singleEmail = Messaging.renderStoredEmailTemplate(et.Id, null
                            , (String.isNotEmpty(orderId) ? orderId : null));
                    mail.htmlBody = String.isNotEmpty(singleEmail.htmlBody) ? singleEmail.htmlBody : formatPlainBody(singleEmail.plainTextBody);
                    System.debug('singleEmail.subject*************  ' +singleEmail.subject);
                    mail.subject = singleEmail.subject;
                    mail.setWhatId(orderId);
                    mail.setSaveAsActivity(true);
                    mails.add(mail);
                    System.debug('**************mail*************  ' + mail);
            }
            System.debug('**************mails ALL*************  '+mails);
            Messaging.sendEmail(mails);
        }    
    }
}