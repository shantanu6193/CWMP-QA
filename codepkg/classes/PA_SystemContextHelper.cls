/**
 * Created by Pankaj on 2021-05-20.
 */

public without sharing class PA_SystemContextHelper {

    public static Closeout_Request__c upsertCloseoutRequest(Closeout_Request__c closeoutRequest) {
        upsert closeoutRequest;
        return closeoutRequest;
    }

    public static void upsertProjectCloseouts(List<Project_Closeout__c> projectCloseoutToInitiateList) {
        upsert projectCloseoutToInitiateList;
    }

    public static void upsertProject(List<Project__c> projectList) {
        upsert projectList;
    }

    public static void upsertContentDocLinks(List<ContentDocumentLink> contentDocumentLinks) {
        upsert contentDocumentLinks;
    }

    public static void upsertContentDoc(List<ContentDocument> contentDocumentList) {
        upsert contentDocumentList;
    }
    
    public static void upsertCloseoutTask(Closeout_Task__c closeoutTask){
        upsert closeoutTask;
    }

    public static void insertProjectCloseoutShareRecords(List<Project_Closeout__Share> projectCloseoutShareListToInsert) {
        Database.SaveResult[] projectShareListDBResults = Database.insert(projectCloseoutShareListToInsert,false);
    }

    public static void insertCloseoutShareRecords(List<Closeout_Request__Share> closeoutShareListToInsert) {
        Database.SaveResult[] projectShareListDBResults = Database.insert(closeoutShareListToInsert,false);
    }

    

    public static List<LookupSearchResult> getIncidentSearch(Set<Id> Ids, String searchTerm) {
        String query = 'Select Id,Name,Declaration_Number__c, Cost_Share_Eligibility__c From Incident__c Where Id IN:Ids ';
        if(String.isNotEmpty(searchTerm)) {
            query += ' AND (Name like\'%' + searchTerm + '%\' OR Declaration_Number__c like\'%' + searchTerm + '%\')';
        }
        query += ' AND Id In(Select Incident_Name__c from Project__c) ';
        query += ' Limit 200';
        system.debug('query===='+query);
        List<Incident__c> incidents = Database.query(query);

        List<LookupSearchResult> results = new List<LookupSearchResult>();

        // Extract Accounts & convert them into LookupSearchResult
        String productIcon = 'standard:account';
        for (Incident__c opProductReference : incidents) {
            results.add(
                    new LookupSearchResult(
                            opProductReference.Id,
                            'Account',
                            productIcon,
                            opProductReference.Name,
                            (opProductReference.Declaration_Number__c != null ? opProductReference.Declaration_Number__c  : ''),
                            opProductReference
                    )
            );
        }
        // Optionnaly sort all results on title
        results.sort();
        System.debug('results---' + results);
        return results;
    }

    /***********************************************
   * Method Name : checkLastSmallProjectPercentage
   * Author : Prajakta
   * Inputs : -
   * Description: This method will check old and new percent complete to date value for CDAA projects.
   *********************************************/
    public static void checkPercentageOfCDAAProjects(List<Project__c> projectList,Set<Id> incidentIds,Set<Id> subRecipientIds,String fundingSourceType) {
        List<User> userList = [SELECT ContactId,Contact.Email FROM User WHERE id =: UserInfo.getUserId()];
        List<Project__c> projectAllList = [SELECT id,Percent_Complete_To_Date__c FROM Project__c
        Where Incident_Name__c IN:incidentIds AND Obligating_Sub_Recipient__c IN:subRecipientIds And (Percent_Complete_To_Date__c < 100 Or Percent_Complete_To_Date__c = null)];
        system.debug('projectAllList'+projectAllList);
        system.debug('userList'+userList);
        set<String> projectIdsUpdated = new set<String>();
        system.debug('projectAllList.size()'+projectAllList.size());
        if(projectAllList.size() == 0){
            sendEmailToCurrentUserContact(projectList,userList,fundingSourceType);
        }
            }

    /***********************************************
  * Method Name : checkLastSmallProjectPercentage
  * Author : Prajakta
  * Inputs : -
  * Description: This method will check old and new percent complete to date value for federal projects.
  *********************************************/
    public static void checkPercentageOfFederalProjects(List<Project__c> projectList,Set<Id> incidentIds,Set<Id> subRecipientIds,String fundingSourceType) {
        List<User> userList = [SELECT ContactId,Contact.Email FROM User WHERE id =: UserInfo.getUserId()];
        List<Project__c> projectAllList = [SELECT id,Percent_Complete_To_Date__c FROM Project__c
        Where Incident_Name__c IN:incidentIds AND Obligating_Sub_Recipient__c IN:subRecipientIds And (Percent_Complete_To_Date__c < 100 Or Percent_Complete_To_Date__c = null) AND IsLargeProject__c = false];
        system.debug('projectAllList'+projectAllList);
        system.debug('userList'+userList);
        set<String> projectIdsUpdated = new set<String>();
        system.debug('projectAllList.size()'+projectAllList.size());
        if(projectAllList.size() == 0){
            sendEmailToCurrentUserContact(projectList,userList,fundingSourceType);
        }
    }

    /***********************************************
    * Method Name : sendEmailToCurrentUserContact
    * Author : Prajakta
    * Inputs : - project id list and current user list
    * Description: This method will send mail to current logged user contact email .
    *********************************************/
    private static void sendEmailToCurrentUserContact(List<Project__c> projectList,List<User> userList, String fundingSourceType) {
        String emailTemplateName;
       // String closeoutRequestEmailTextValueName;
        String emailTextValueName;
        if(fundingSourceType == 'CDAA (State Funding)'){
            //emailTextValueName = 'PA_SR_Update_CDAA_Last_Project_Email';
        }else if(fundingSourceType == 'PA - Federal'){
            emailTextValueName = 'PA_SR_Update_Last_Project_Email';
            //Key_Value_Store__mdt closeoutRequestKeyvalInst = Key_Value_Store__mdt.getInstance('PA_Closeout_Request_90_Day_Deadline');
            //closeoutRequestEmailTextValueName = closeoutRequestKeyvalInst.Text_Value__c;
        }
        Key_Value_Store__mdt keyValStoreLst =  new Key_Value_Store__mdt();
        if(emailTextValueName != null){
            keyValStoreLst = Key_Value_Store__mdt.getInstance(emailTextValueName);
            emailTemplateName = keyValStoreLst.Text_Value__c;
        }


        if(emailTemplateName != null){
            List<EmailTemplate> emailTemplateIns = [SELECT Id, markup FROM EmailTemplate WHERE Name =: emailTemplateName];
        if(emailTemplateIns.size() > 0 && (userList.size() >0 &&  userList[0].ContactId != null) && projectList.size() > 0){
            List<Messaging.SingleEmailMessage> mailingList = new List<Messaging.SingleEmailMessage>();
            for(Project__c proj :projectList){
                Messaging.SingleEmailMessage singleEmail = Messaging.renderStoredEmailTemplate(emailTemplateIns[0].Id, userList[0].ContactId, proj.Id);
                singleEmail.toAddresses = new List<String>{ userList[0].Contact.Email };
                singleEmail.setHtmlBody(singleEmail.htmlBody);
                singleEmail.setSaveAsActivity(true);
                singleEmail.setSubject(singleEmail.subject);
                mailingList.add(singleEmail);
            }
                system.debug('mailingList'+mailingList);
            List<Messaging.SendEmailResult> results = Messaging.sendEmail(mailingList, true);
        }
        }

        /*if(closeoutRequestEmailTextValueName != null){
            List<EmailTemplate> closeoutRequestEmailTemplateIns = [SELECT Id, markup FROM EmailTemplate WHERE Name =: closeoutRequestEmailTextValueName];
            if(closeoutRequestEmailTemplateIns.size() > 0 && (userList.size() >0 &&  userList[0].ContactId != null) && projectList.size() > 0){
                List<Messaging.SingleEmailMessage> mailingLists = new List<Messaging.SingleEmailMessage>();
                for(Project__c proj :projectList){
                    Messaging.SingleEmailMessage singleEmail = Messaging.renderStoredEmailTemplate(closeoutRequestEmailTemplateIns[0].Id, userList[0].ContactId, proj.Id);
                    singleEmail.toAddresses = new List<String>{ userList[0].Contact.Email };
                    singleEmail.setHtmlBody(singleEmail.htmlBody);
                    singleEmail.setSaveAsActivity(true);
                    singleEmail.setSubject(singleEmail.subject);
                    mailingLists.add(singleEmail);
                }
                system.debug('mailingList'+mailingLists);
                List<Messaging.SendEmailResult> results = Messaging.sendEmail(mailingLists, true);
            }
        }*/

    }

}