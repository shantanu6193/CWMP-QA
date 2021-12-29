/***********************************************************************************************************************************
* Class Name   : PHOS_SendEmail_Request_From_County_User
* Description  : This class for send order email request from county user 
* Author       : Pankaj
* Created On   : 04/07/2020
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Pankaj              04/07/2020      Initial Implementation
**************************************************************************************************************************************/

public without sharing class PHOS_SendEmail_Request_From_County_User {
    public static Boolean hasExecuted = false;

    /***********************************************
    * Method Name : sendEmail
    * Author : Pankaj
    * Inputs : List<Id> orderIds
    * Description: This method call sendEmailFuture method for send an email
    *********************************************/
    @InvocableMethod(label='Order Request from County USER' description='Request from County USER')
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
    * Description: This method send order email request from county user
    *********************************************/
    @future
    public static void sendEmailFuture(List<Id> orderIds){
        List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>();
        List<EmailMessage> tasks = [SELECT Id, RelatedToId, ToAddress, CcAddress
            from EmailMessage
            where RelatedToId IN:orderIds AND Subject like 'New request submitted by%'];
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

        List<Order__c> orders = [SELECT Id, Name, Account__r.Parent.Queue_Name__c, Incident_Name__c,Personnel__c,Status__c, CreatedBy.Account.Entity_Type__c, Incident__c, Account__r.Parent.Parent.Queue_Name__c
                                    FROM Order__c WHERE Id IN :orderIds];
        List<String> queueNames = new List<String>();
        List<String> parentQueueNames = new List<String>();
        Set<String> incidentIDs = new Set<String>();
        for (Order__c order : orders) {
            if(order.Account__r.Parent.Queue_Name__c == null) continue;
            queueNames.add(order.Account__r.Parent.Queue_Name__c);
            incidentIDs.add(order.Incident__c);
            // Get Parent Account's Parent QueueName to send email to region users
            if(order.Account__r.Parent.Parent.Queue_Name__c != null) {
                parentQueueNames.add(order.Account__r.Parent.Parent.Queue_Name__c);
            }
        }

        List<GroupMember> groupMembers = [SELECT Id,Group.DeveloperName,UserOrGroupId
                                            FROM GroupMember WHERE Group.DeveloperName IN :queueNames AND Group.Type='Queue'];
        List<GroupMember> parentGroupMembers = [SELECT Id,Group.DeveloperName,UserOrGroupId
        FROM GroupMember WHERE Group.DeveloperName IN :parentQueueNames AND Group.Type='Queue'];

        List<Id> userIds = new List<Id>();
        for (GroupMember groupMember : groupMembers) {
            userIds.add(groupMember.UserOrGroupId);
        }
        List<Id> parentUserIds = new List<Id>();
        for (GroupMember groupMember : parentGroupMembers) {
            parentUserIds.add(groupMember.UserOrGroupId);
        }
        Map<Id, User> usersById = new Map<Id, User>([SELECT Id, Email FROM User WHERE Id IN :userIds AND IsActive=TRUE]);
        Map<Id, User> parentUsersById = new Map<Id, User>([SELECT Id, Email FROM User WHERE Id IN :parentUserIds AND IsActive=TRUE]);
        Map<String, Set<String>> queueEmailsByName = new Map<String, Set<String>>();
        for (String queueName :  queueNames) {
            for (GroupMember groupMember : groupMembers) {
                if (queueEmailsByName.get(queueName) == null) {
                    queueEmailsByName.put(queueName, new Set<String>());
                }
                if(usersById.get(groupMember.UserOrGroupId) != null) {
                    queueEmailsByName.get(queueName).add(usersById.get(groupMember.UserOrGroupId).Email);
                }
            }
        }
        for (String queueName :  parentQueueNames) {
            for (GroupMember groupMember : parentGroupMembers) {
                if (queueEmailsByName.get(queueName) == null) {
                    queueEmailsByName.put(queueName, new Set<String>());
                }
                if(parentUsersById.get(groupMember.UserOrGroupId) != null) {
                    queueEmailsByName.get(queueName).add(parentUsersById.get(groupMember.UserOrGroupId).Email);
                }
            }
        }

        List<Incident__c> incidentList = [SELECT Id, Name, Eamil_To_Send__c, Personnel_Email_IDs__c, Available_for_Application__c, isActive__c, isDefault__c, IsDeleted
                                            FROM Incident__c WHERE Id IN: incidentIDs AND isActive__c = true];

        Map<String,List<String>> incidentNameToPerEmailMap = new Map<String,List<String>>();
        //Set<String> ccEmailList = new Set<String>();
        for(Incident__c newIncident : incidentList) {
            if(String.isNotEmpty(newIncident.Personnel_Email_IDs__c)) {                
                incidentNameToPerEmailMap.put(newIncident.Id, newIncident.Personnel_Email_IDs__c.split(','));
            }
        }
        for (Order__c order : orders) {
            List<String> toEmailList = new List<String>();
            System.debug('------queueEmailsByName'+ queueEmailsByName);
            if(order.Account__r.Parent.Queue_Name__c == null) continue;
            if (queueEmailsByName.get(order.Account__r.Parent.Queue_Name__c) == null
                    || queueEmailsByName.get(order.Account__r.Parent.Queue_Name__c).size() == 0) continue;

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            for(String queueEmail : queueEmailsByName.get(order.Account__r.Parent.Queue_Name__c)) {
                if(emailStrings.contains((queueEmail.toLowerCase()).trim())) {
                    queueEmailsByName.get(order.Account__r.Parent.Queue_Name__c).remove(queueEmail);
                }
            }
            //Remove Email ids if Email is already sent for Parent's Parent Queue Members
            if(order.Account__r.Parent.Parent.Queue_Name__c != null && queueEmailsByName.get(order.Account__r.Parent.Parent.Queue_Name__c) != null) {
                for(String queueEmail : queueEmailsByName.get(order.Account__r.Parent.Parent.Queue_Name__c)) {
                    if(emailStrings.contains((queueEmail.toLowerCase()).trim())) {
                        queueEmailsByName.get(order.Account__r.Parent.Parent.Queue_Name__c).remove(queueEmail);
                    }
                }
            }
            //System.debug('------queueEmailsByName111'+ queueEmailsByName);
            if((queueEmailsByName.get(order.Account__r.Parent.Queue_Name__c) != null && !queueEmailsByName.get(order.Account__r.Parent.Queue_Name__c).isEmpty()) ||
                    queueEmailsByName.get(order.Account__r.Parent.Parent.Queue_Name__c) != null && !queueEmailsByName.get(order.Account__r.Parent.Parent.Queue_Name__c).isEmpty()) {
                if(order.Status__c == 'MHOAC Review') {
                    if(queueEmailsByName.get(order.Account__r.Parent.Queue_Name__c) != null) {
                        toEmailList.addAll(queueEmailsByName.get(order.Account__r.Parent.Queue_Name__c));
                    }
                    //mail.setToAddresses(new List<String>(queueEmailsByName.get(order.Account__r.Parent.Queue_Name__c)));
                }
                if(order.Status__c == 'RDMHS Review') {
                    if(queueEmailsByName.get(order.Account__r.Parent.Queue_Name__c) != null) {
                        toEmailList.addAll(queueEmailsByName.get(order.Account__r.Parent.Queue_Name__c));
                        //mail.setToAddresses(new List<String>(queueEmailsByName.get(order.Account__r.Parent.Queue_Name__c)));
                    }
                    if(queueEmailsByName.get(order.Account__r.Parent.Parent.Queue_Name__c) != null) {
                        toEmailList.addAll(queueEmailsByName.get(order.Account__r.Parent.Parent.Queue_Name__c));
                        //mail.setToAddresses(new List<String>(queueEmailsByName.get(order.Account__r.Parent.Parent.Queue_Name__c)));
                    }
                }
                if(!toEmailList.isEmpty()){
                    mail.setToAddresses(toEmailList);
                    /*if(order.Personnel__c == true && incidentNameToPerEmailMap.get(order.Incident__c) != null) {
                        ccEmailList.addAll(incidentNameToPerEmailMap.get(order.Incident__c));
                    }
                    for(String ccEmail : ccEmailList) {
                        if(emailStrings.contains(ccEmail.toLowerCase())) {
                            ccEmailList.remove(ccEmail);
                        }
                    }
                    mail.setCcAddresses(new List<String>(ccEmailList));*/
                    
                    EmailTemplate et = [SELECT id FROM EmailTemplate WHERE developerName = 'PHOS_ORDER_REQUEST_FROM_County_Users'];
                    Messaging.SingleEmailMessage singleEmail = Messaging.renderStoredEmailTemplate(et.Id,null
                            , (String.isNotEmpty(order.Id) ? order.Id : null));
                    mail.htmlBody=String.isNotEmpty(singleEmail.htmlBody) ? singleEmail.htmlBody : formatPlainBody(singleEmail.plainTextBody);
                    if(order.CreatedBy.Account.Entity_Type__c != null) {
                        mail.subject = 'New request submitted by '+ order.CreatedBy.Account.Entity_Type__c + ' User ' + order.Name;
                    } else {
                        mail.subject = 'New request submitted by User ' + order.Name;
                    }
                    mail.setWhatId(order.Id);
                    mail.setSaveAsActivity(true);
                    mails.add(mail);
                    System.debug('**************mail*************  '+mail);
                }
            }
        }
        System.debug('**************mails ALL*************  '+mails);
        Messaging.sendEmail(mails);
    }
}