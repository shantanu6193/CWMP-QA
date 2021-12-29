/***********************************************************************************************************************************
* Class Name   : PHOS_SendEmail_Request_For_Incidents
* Description  : This class for send order request email to incidents 
* Author       : Pankaj
* Created On   : 08/28/2020
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Pankaj              08/28/2020      Initial Implementation
**************************************************************************************************************************************/

public without sharing class PHOS_SendEmail_Request_For_Incidents {
    public static Boolean hasExecuted = false;

    /***********************************************
    * Method Name : sendEmail
    * Author : Pankaj
    * Inputs : List<Id> orderIds
    * Description: This method call sendEmailFuture method for send an email
    *********************************************/
    @InvocableMethod(label='Order Request for Incidents' description='Request for Incidents')
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
        List<EmailMessage> tasks = [SELECT Id, RelatedToId, ToAddress, CcAddress
                                    FROM EmailMessage
                                    WHERE RelatedToId IN:orderIds AND Subject like 'New request submitted by%'];
        List<Id> tskIDs = new List<Id>();
        Set<String> emailStrings = new Set<String>();
        for(EmailMessage task: tasks){
            tskIDs.add(task.RelatedToId);
            for(String toAddress : task.ToAddress.split(';')) {
                emailStrings.add((toAddress.toLowerCase()).trim());
            }
            if(task.CcAddress != null) {
                for(String ccAddress : task.CcAddress.split(';')) {
                    emailStrings.add((ccAddress.toLowerCase()).trim());
                }
            }
        }

        List<Order__c> orders = [SELECT Id,Name,Account__r.Parent.Queue_Name__c,Incident_Name__c,Personnel__c,Incident__c,CreatedBy.Account.Entity_Type__c
                                    FROM Order__c WHERE Id IN :orderIds];
        Set<String> incidentIDs = new Set<String>();
        for (Order__c order : orders) {
            incidentIDs.add(order.Incident__c);
        }

        List<Incident__c> incidentList = [SELECT Id, Name, Eamil_To_Send__c, Personnel_Email_IDs__c, Available_for_Application__c, isActive__c, isDefault__c, IsDeleted
                                            FROM Incident__c WHERE Id IN: incidentIDs AND isActive__c = true];
        Map<String,Set<String>> incidentNameToEmailMap = new Map<String,Set<String>>();
        Map<String,Set<String>> incidentNameToPerEmailMap = new Map<String,Set<String>>();
        for(Incident__c newIncident : incidentList) {
            if(String.isNotEmpty(newIncident.Eamil_To_Send__c)) {
                incidentNameToEmailMap.put(newIncident.Id, new Set<String>(newIncident.Eamil_To_Send__c.split(',')));
            }
            if(String.isNotEmpty(newIncident.Personnel_Email_IDs__c)) {                
                incidentNameToPerEmailMap.put(newIncident.Id, new Set<String>(newIncident.Personnel_Email_IDs__c.split(',')));
            }
        }
        for (Order__c order : orders) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            if(incidentNameToEmailMap.get(order.Incident__c) != null) {
                for(String incidentEmail : incidentNameToEmailMap.get(order.Incident__c)) {
                    if(emailStrings.contains((incidentEmail.toLowerCase()).trim())) {
                        incidentNameToEmailMap.get(order.Incident__c).remove(incidentEmail);
                    }
                }
                if(incidentNameToEmailMap.get(order.Incident__c) != null && !incidentNameToEmailMap.get(order.Incident__c).isEmpty()) {
                    mail.setToAddresses(new List<String>(incidentNameToEmailMap.get(order.Incident__c)));
                    if (order.Personnel__c == true && incidentNameToPerEmailMap.get(order.Incident__c) != null){
                        for(String incidentEmail : incidentNameToPerEmailMap.get(order.Incident__c)) {
                            if(emailStrings.contains((incidentEmail.toLowerCase()).trim())) {
                                incidentNameToPerEmailMap.get(order.Incident__c).remove(incidentEmail);
                            }
                        }
                        mail.setCcAddresses(new List<String>(incidentNameToPerEmailMap.get(order.Incident__c)));
                    }
                    EmailTemplate et = [SELECT id FROM EmailTemplate WHERE DeveloperName = 'PHOS_ORDER_REQUEST_FROM_County_Users'];
                    Messaging.SingleEmailMessage singleEmail = Messaging.renderStoredEmailTemplate(et.Id, null
                            , (String.isNotEmpty(order.Id) ? order.Id : null));
                    mail.htmlBody = String.isNotEmpty(singleEmail.htmlBody) ? singleEmail.htmlBody : formatPlainBody(singleEmail.plainTextBody);
                    System.debug('singleEmail.subject*************  ' + singleEmail.subject);
                    if(order.CreatedBy.Account.Entity_Type__c != null) {
                        mail.subject = 'New request submitted by '+ order.CreatedBy.Account.Entity_Type__c + ' User ' + order.Name;
                    } else {
                        mail.subject = 'New request submitted by User ' + order.Name;
                    }
                    mail.setWhatId(order.Id);
                    mail.setSaveAsActivity(true);
                    mails.add(mail);
                    System.debug('**************mail*************  ' + mail);
                }
            }
        }
        System.debug('**************mails ALL*************  '+mails);
        Messaging.sendEmail(mails);
    }
}