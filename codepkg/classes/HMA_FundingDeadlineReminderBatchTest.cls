@isTest public without sharing class HMA_FundingDeadlineReminderBatchTest {
    @isTest public static void testFundingDeadlineReminderBatch() {
        Integer nDays = 10;
        String cronExp = '0 0 22 * * ? *'; 
        Contact portalCon = HMA_TestHelper.getPortalContact(true);
        Application__c newApplication = HMA_TestHelper.getApplication(true, '', '', '');
        newApplication.Project_Plan_Title__c = 'Test';
        newApplication.Sub_Application_Due_Date__c = system.today().addDays(nDays);
        update newApplication;
        AccountContactRole__c acRole = new AccountContactRole__c(Contact_Name__c = portalCon.Id );
            insert acRole;
            Contact_Role__c conRole = HMA_TestHelper.getContactRole(false);
            conRole.Application__c = newApplication.Id;
            conRole.Contact__c = portalCon.Id;
            conRole.AccountContactJunction__c = acRole.Id;
            insert conRole;
        
        Test.startTest();
        Database.executeBatch(new HMA_FundingDeadlineReminderBatch(nDays),100);
        /**Used to cover HMA_FundingDeadlineReminderScheduler class */
        String jobId = System.schedule('myJobTestJobName', cronExp, new HMA_FundingDeadlineReminderScheduler());
        Test.stopTest();
    }
}