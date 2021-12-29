global class HMA_FundingDeadlineReminderBatch implements Database.Batchable<SObject>{
    Integer nDays = 30;
    Boolean isError = false;
    String errorMessage = '';
    List<String> applicationNames = new List<String>();
    public HMA_FundingDeadlineReminderBatch(Integer days){
        nDays = days;
    }
    global Database.QueryLocator start(Database.BatchableContext bc) {
        Date dueDate = system.today().addDays(nDays);
        System.debug('dueDate======='+dueDate);
        return Database.getQueryLocator('SELECT id, Name, Sub_Application_Due_Date__c , Project_Plan_Title__c, Pre_Application__c, Pre_Application__r.Name, Disaster__r.Declaration_Number__c, ' +
                '(SELECT Id, Role__c, AccountContactJunction__c, AccountContactJunction__r.Contact_Name__c, AccountContactJunction__r.Contact_Name__r.Email, AccountContactJunction__r.Contact_Name__r.Name FROM Contact_Roles__r ' +
                'WHERE Role__c includes(\'Responsible Representative\', \'Primary Contact\', \'Contributor\')) '+
                'from Application__c ' +
                'WHERE Sub_Application_Due_Date__c =:dueDate AND Status__c = \'Draft\' ORDER BY Name');
    }
    global void execute(Database.BatchableContext bc, List<Application__c> apps) {
        try {
            List<OrgWideEmailAddress> fromAddresses = new List<OrgWideEmailAddress>();
            List<Messaging.SingleEmailMessage> allMails = new List<Messaging.SingleEmailMessage>();
            EmailTemplate templateToSend = [Select id, HtmlValue, Subject from EmailTemplate where name = 'HMA_Funding_Deadline_Notification' LIMIT 1];
            String fromAddr = KeyValueHelper.getTextValue('HMA_From_Email_Addresses');
            
            Id OrgWideEmailAddressId;
            if(String.isNotBlank(fromAddr)){
                fromAddresses =  [Select Id from OrgWideEmailAddress where DisplayName=: fromAddr];
            }
            if(fromAddresses.size()>0){
                OrgWideEmailAddressId = fromAddresses[0].Id;
            }
            for(Application__c app : apps) {
                System.debug('app=='+app);
                for(Contact_Role__c role : app.Contact_Roles__r) {
                    List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
                    if(role.AccountContactJunction__r.Contact_Name__r.Email != null){
                        mails = sendEmail(  app, 
                                            new List<String>{role.AccountContactJunction__r.Contact_Name__r.Email}, 
                                            new List<String>{}, 
                                            templateToSend, 
                                            OrgWideEmailAddressId, 
                                            role.AccountContactJunction__r.Contact_Name__c);
                        for(Messaging.SingleEmailMessage mail : mails) {

                            mail.htmlBody = mail.htmlBody.replace('subAppDueDate',(app.Sub_Application_Due_Date__c == null ? '' : String.valueOf(app.Sub_Application_Due_Date__c)));
                            mail.htmlBody = mail.htmlBody.replace('incidentDeclarationNumber',(app.Disaster__r.Declaration_Number__c == null ? '' : String.valueOf(app.Disaster__r.Declaration_Number__c)));
                            mail.htmlBody = mail.htmlBody.replace('remainingDays', String.valueOf(nDays));
                            mail.htmlBody = mail.htmlBody.replace('{{{Recipient.Name}}}', role.AccountContactJunction__r.Contact_Name__r.Name);
                            mail.htmlBody = mail.htmlBody.replace('{{{Application__c.Project_Plan_Title__c}}}', app.Project_Plan_Title__c);
                            mail.htmlBody = mail.htmlBody.replace('{{{Application__c.Pre_Application__c}}}', app.Pre_Application__r.Name);
                        }
                        allMails.addAll(mails);
                    }
                }
                applicationNames.add(app.Name);
            }
            Messaging.sendEmail(allMails);
        } catch(Exception e) {
            isError = true;
            errorMessage = e.getMessage();
            System.debug('Exception===='+e.getStackTraceString());
        }
    }
    global void finish(Database.BatchableContext bc) { 
        System.debug('finish--');
        //TODO: Create Object CALOES Log - Type HMA,PA,ALS etc, Operation Type - Class(Text), Description (Long Text Area), IsError = true, false, Error Message (Long Text Area)
    }

   /* public static String getApplicationDueDates(Integer nDays) {
        Date dueDate = system.today().addDays(nDays);
        System.debug('dueDate======='+dueDate);
        String query = 'SELECT id, Name, Sub_Application_Due_Date__c, Disaster__r.Declaration_Number__c, ' +
                            '(SELECT Id, Role__c, AccountContactJunction__c, AccountContactJunction__r.Contact_Name__c, AccountContactJunction__r.Contact_Name__r.Email FROM Contact_Roles__r ' + 
                            'WHERE Role__c includes(\'Responsible Representative\', \'Primary Contact\', \'Contributor\')) '+
                            'from Application__c ' +
                            'WHERE Sub_Application_Due_Date__c = :dueDate '+
                            ' AND Status__c = \'Draft\' ORDER BY Name';

        return query;
    }*/

    public static List<Messaging.SingleEmailMessage> sendEmail(SObject sObj, List<String> toAddresses ,List<String> ccAddresses, EmailTemplate templateToSend, Id OrgWideEmailAddressId, Id targetId){
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        try {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(toAddresses);
            mail.setCcAddresses(ccAddresses);
            mail.setTemplateId(templateToSend.Id);
            mail.setOrgWideEmailAddressId(OrgWideEmailAddressId);
            mail.htmlBody = templateToSend.HtmlValue;
            // Messaging.SingleEmailMessage singleEmail = Messaging.renderStoredEmailTemplate(templateToSend.Id, targetId, (String.isNotEmpty(sObj.Id) ? sObj.Id : null));
            // mail.htmlBody=String.isNotEmpty(singleEmail.htmlBody) ? singleEmail.htmlBody : formatPlainBody(singleEmail.plainTextBody);
            // mail.subject= String.isNotEmpty(singleEmail.subject) ? singleEmail.subject : '';
            mail.subject = String.isNotEmpty(templateToSend.Subject) ? templateToSend.Subject : '' ;
            mail.setWhatId(sObj.Id);
            mail.setTargetObjectId(targetId);
            mail.setSaveAsActivity(true);
            mails.add(mail);
            return mails;
        } catch(Exception e) {
            System.debug('Exception in mail---'+e);
        }
        return mails;
    }
/*    @TestVisible
    private static String formatPlainBody(String plainBody) {
        if (String.isEmpty(plainBody)) return '';
        return plainBody.replace('\n', '<br/>');
    }*/
}