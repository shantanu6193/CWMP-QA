/**
 * Created by Shivraj on 12-02-2021.
 */

public without sharing class PHOS_VaccinationPersonnel_Email {
    public static Boolean hasExecuted = false;
    /***********************************************
    * Method Name : sendEmail
    * Author : Pankaj
    * Inputs : List<Id> orderIds
    * Description: This method to send email when Type of Personnel is Vaccination-related Personnel
    *********************************************/
    @InvocableMethod(label='Vaccination-related Personnel Email' description='Vaccination-related Personnel Email')
    public static void sendEmail(List<Id> orderIds) {
        if(hasExecuted == false) {
            sendEmailVaccinationPersonnel(orderIds);
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
    * Method Name : sendEmailVaccinationPersonnel
    * Author : Pankaj
    * Inputs : List<Id> orderIds
    * Description: This method send order request email to incidents
    *********************************************/
    public static void sendEmailVaccinationPersonnel(List<Id> orderIds){
        List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>();
        /*List<EmailMessage> tasks = [SELECT Id, RelatedToId, ToAddress, CcAddress
        FROM EmailMessage
        WHERE RelatedToId IN:orderIds AND Subject like 'New request submitted by%'];
        List<Id> tskIDs = new List<Id>();*/
        String fromAddr = KeyValueHelper.getTextValue('PHOS_From_Email_Addresses');
        List<OrgWideEmailAddress> fromAddresses = new List<OrgWideEmailAddress>();
        Id OrgWideEmailAddressId;
        if(String.isNotBlank(fromAddr)){
            fromAddresses =  [Select Id from OrgWideEmailAddress where DisplayName=: fromAddr];
        }
        if(fromAddresses.size()>0){
            OrgWideEmailAddressId = fromAddresses[0].Id;
        }
        Set<Id> userIds = new Set<Id>();
        Map<String, Set<String>> queueNameByEmail = new Map<String, Set<String>>();
        List<Order__c> orders = [SELECT Id,Name,Owner.Name FROM Order__c WHERE Id IN :orderIds];
        List<GroupMember> parentGroupMembers = [SELECT Id,Group.DeveloperName,UserOrGroupId FROM GroupMember WHERE Group.Name =: orders[0].Owner.Name AND Group.Type='Queue'];
        for(GroupMember gp :parentGroupMembers){
            userIds.add(gp.UserOrGroupId);
        }
        Map<Id, User> usersById = new Map<Id, User>([SELECT Id, Email FROM User WHERE Id IN :userIds AND IsActive=TRUE]);
        for(User usr : usersById.values()) {
            if (queueNameByEmail.get(orders[0].Owner.Name) == null) {
                queueNameByEmail.put(orders[0].Owner.Name, new Set<String>());
            }
            queueNameByEmail.get(orders[0].Owner.Name).add(usr.Email);
        }
        for (Order__c order : orders) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new List<String>(queueNameByEmail.get(order.Owner.Name)));
            mail.setOrgWideEmailAddressId(OrgWideEmailAddressId);
            EmailTemplate et = [SELECT id FROM EmailTemplate WHERE DeveloperName = 'Vaccine_Personnel_Email'];
            Messaging.SingleEmailMessage singleEmail = Messaging.renderStoredEmailTemplate(et.Id, null
                    , (String.isNotEmpty(order.Id) ? order.Id : null));
            mail.htmlBody = String.isNotEmpty(singleEmail.htmlBody) ? singleEmail.htmlBody : formatPlainBody(singleEmail.plainTextBody);
            System.debug('singleEmail.subject*************  ' + singleEmail.subject);
            mail.setWhatId(order.Id);
            mail.subject = singleEmail.subject;
            mail.setSaveAsActivity(true);
            mails.add(mail);
            System.debug('**************mail*************  ' + mail);
        }
        System.debug('**************mails ALL*************  '+mails);
        Messaging.sendEmail(mails);
    }
}