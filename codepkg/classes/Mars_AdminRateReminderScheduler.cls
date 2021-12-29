global class Mars_AdminRateReminderScheduler implements Database.Batchable<sObject>, Schedulable{
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'SELECT Id, Contact__c FROM Community_Application_to_User__c WHERE Community_Application__r.Name =\'MARS\' AND isActive__c = true AND Contact__c IN (SELECT ContactId FROM AccountContactRelation WHERE Relationship_Strength__c = \'Primary\'  AND Account.Entity_Type__c=\'Fire Agency\')'
        );
    }

    global void execute(Database.BatchableContext bc, List<Community_Application_to_User__c> communityAppUserList) {
        Set<Id> contactIds = new Set<Id>();
        DateTime dt = System.now();
        Date todayDate = Date.newInstance(dt.year(), dt.month(), dt.day());
        String firstRemindeDate = KeyValueHelper.getTextValue('MARS_Admin_Rate_First_Reminder');
        String secondRemindeDate = KeyValueHelper.getTextValue('MARS_Admin_Rate_Second_Reminder');
        String thirdRemindeDate = KeyValueHelper.getTextValue('MARS_Admin_Rate_Third_Reminder');
        if(String.isNotBlank(firstRemindeDate) || String.isNotBlank(firstRemindeDate) || String.isNotBlank(thirdRemindeDate)) {
            List<String> firstReminderMonthDate = firstRemindeDate.split('/');
            List<String> secondReminderMonthDate = secondRemindeDate.split('/');
            List<String> thirdReminderMonthDate = thirdRemindeDate.split('/');
            Date firstDate = Date.newInstance(dt.year(),Integer.valueOf(firstReminderMonthDate[0]),Integer.valueOf(firstReminderMonthDate[1]));
            Date secondDate = Date.newInstance(dt.year(),Integer.valueOf(secondReminderMonthDate[0]),Integer.valueOf(secondReminderMonthDate[1]));
            Date thirdDate = Date.newInstance(dt.year(),Integer.valueOf(thirdReminderMonthDate[0]),Integer.valueOf(thirdReminderMonthDate[1]));
            if(todayDate == firstDate || todayDate == secondDate || todayDate == thirdDate) {
                List<EmailTemplate> firstEmailTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName='Email_Notification_for_Administration_Rate_Expiration_1620834626251'];
                List<EmailTemplate> secondEmailTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName='Second_Email_Notification_for_Administration_Rate_Expiration_1620896516013'];
                //get OWD Eamil Address
                String fromAddr = KeyValueHelper.getTextValue('MARS_From_Email_Addresses');
                List<OrgWideEmailAddress> fromAddresses = new List<OrgWideEmailAddress>();
                Id OrgWideEmailAddressId;
                if(String.isNotBlank(fromAddr)){
                    fromAddresses =  [Select Id from OrgWideEmailAddress where DisplayName=: fromAddr];
                }
                if(fromAddresses.size()>0){
                    OrgWideEmailAddressId = fromAddresses[0].Id;
                }
                for(Community_Application_to_User__c record : communityAppUserList) {
                    contactIds.add(record.Contact__c);
                }
                Map<String, List<String>> accountContactMap = new Map<String, List<String>>();
                List<AccountContactRelation> accountContactList = [SELECT Id,ContactId,AccountId FROM AccountContactRelation WHERE ContactId =: contactIds AND Relationship_Strength__c = 'Primary'];
                for(AccountContactRelation acRecord : accountContactList) {
                    if(accountContactMap.get(acRecord.AccountId) == null) {
                        accountContactMap.put(acRecord.AccountId, new List<String>());
                    }
                    accountContactMap.get(acRecord.AccountId).add(acRecord.ContactId);
                }
                List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
                List<Agency_Admin_Rates__c> adminRateList = [SELECT Id,Name,Agency__c FROM Agency_Admin_Rates__c WHERE Agency__c =: accountContactMap.keySet() AND Approval_Status__c IN ('Reviewed','Revised')];
                for(Agency_Admin_Rates__c adminRate : adminRateList) {
                    if(accountContactMap.containsKey(adminRate.Agency__c)) {
                        for(String contactId : accountContactMap.get(adminRate.Agency__c)) {
                            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                            if(String.isNotEmpty(contactId)){
                                mail.setTargetObjectId(contactId);
                            }
                            if(String.isNotEmpty(adminRate.Agency__c)){
                                mail.setWhatId(adminRate.Agency__c);
                            }
                            if(String.isNotEmpty(OrgWideEmailAddressId)){
                                mail.setOrgWideEmailAddressId(OrgWideEmailAddressId);
                            }
                            if(todayDate == firstDate || todayDate == secondDate) {
                                mail.setTemplateId(firstEmailTemplate[0].Id);
                            } else if(todayDate == thirdDate) {
                                mail.setTemplateId(secondEmailTemplate[0].Id);
                            }
                            mailList.add(mail);
                        }
                    }
                }
                Messaging.sendEmail(mailList);
            }    
        }    
    }

    global void finish(Database.BatchableContext bc) {
        
    }
    
    //Scheduled batch
    global void execute(SchedulableContext sc) {
        Database.executebatch(new Mars_AdminRateReminderScheduler(), 20);
    }
    
}