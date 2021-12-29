/*
@Author : Rohith
@CreatedDate : 10th Dec 2020
@Description : Test class of AccountEmailNotificationBatch
*/
@isTest
private class AccountEmailNotificationBatchTest{
    
    //Create account records with DUNS and FFATA expiry date
    @testSetup static void setup() {
        List<Account> accList = new List<Account>();
        accList.add(new Account(Name = 'TestAcct1',
                                Email_Address__c = 'testacc1@test.com',
                                DUNS_Expiration_Date__c = System.today().addDays(1),
                                FFATAExpirationDate__c = System.today().addDays(1)));
        accList.add(new Account(Name = 'TestAcct14',
                                Email_Address__c = 'testacc14@test.com',
                                DUNS_Expiration_Date__c = System.today().addDays(14),
                                FFATAExpirationDate__c = System.today().addDays(14)));
        accList.add(new Account(Name = 'TestAcct30',
                                Email_Address__c = 'testacc30@test.com',
                                DUNS_Expiration_Date__c = System.today().addDays(30),
                                FFATAExpirationDate__c = System.today().addDays(30)));
        accList.add(new Account(Name = 'TestAcct60',
                                Email_Address__c = 'testacc60@test.com',
                                DUNS_Expiration_Date__c = System.today().addDays(60),
                                FFATAExpirationDate__c = System.today().addDays(60)));
        accList.add(new Account(Name = 'TestAcct90',
                                Email_Address__c = 'testacc90@test.com',
                                DUNS_Expiration_Date__c = System.today().addDays(90),
                                FFATAExpirationDate__c = System.today().addDays(90)));
        insert accList;        
    }
    
    //test the batch class
    static testmethod void testAccountEmailNotificationBatch() {
        Database.executebatch(new AccountEmailNotificationBatch(), 10);
    }
    
    //test the scheduled job
    static testmethod void testAccountEmailNotificationBatchSchedule() {
        System.schedule('Account Email Notification Batch Test', '0 0 0 3 9 ? 2022', new AccountEmailNotificationBatch());
    }
}