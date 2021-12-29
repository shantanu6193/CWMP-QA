/***********************************************************************************************************************************
* Class Name   : PHOS_InformRequestorForFinalStatus
* Description  : This class for Unfulfilled, partially fulfilled, etc. is selected, the original requestor gets an email
* Author       : Pankaj
* Created On   : 09/09/2020
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Pankaj              09/09/2020      Initial Implementation
**************************************************************************************************************************************/

public class PHOS_InformRequestorForFinalStatus {
    
    /***********************************************
    * Method Name : informRequestor
    * Author : Pankaj
    * Inputs : List<ID> ids
    * Description: This method send an email to requestor if unfulfilled, partially fulfilled, etc. is selected
    *********************************************/
    @InvocableMethod(label='Send Email For Final Status' description='When Unfulfilled, partially fulfilled, etc. is selected, the original requestor gets an email.')
    public static void informRequestor(List<ID> ids) {
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        String subject = '%' + System.Label.PHOS_FinalStatusEmailSubject + '%';
        List<EmailMessage> tasks = [SELECT Id, RelatedToId from EmailMessage where RelatedToId IN:ids AND 
                                    Subject LIKE:subject];
        List<Id> tskIDs = new List<Id>();
        for(EmailMessage task: tasks){
            tskIDs.add(task.RelatedToId);
        }
        List<Order> orderRecord = [Select 
                                   Id,
                                   Status,
                                   Requestor_Email_Text__c
                                   from Order where ID IN : ids];

        EmailTemplate et=[Select id from EmailTemplate where name = 'PHOS_InformRequestorForFinalStatus' LIMIT 1];
        
        for(Order orderRec : orderRecord){
            if(!tskIDs.contains(orderRec.Id)){
                if(String.isNotBlank(orderRec.Requestor_Email_Text__c)){
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    List<String> toAddresses = new List<String>();
                    toAddresses.add(orderRec.Requestor_Email_Text__c);
                    mail.setToAddresses(toAddresses);
                    Messaging.SingleEmailMessage singleEmail = Messaging.renderStoredEmailTemplate(et.Id,null
                            , (String.isNotEmpty(orderRec.Id) ? orderRec.Id : null));
                    mail.htmlBody=String.isNotEmpty(singleEmail.htmlBody) ? singleEmail.htmlBody : formatPlainBody(singleEmail.plainTextBody);
                    mail.subject = singleEmail.subject;
                    mail.setWhatId(orderRec.Id);
                    mail.setSaveAsActivity(true);

                    mails.add(mail);
                }
            }
        }
        Messaging.sendEmail(mails);        
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
}