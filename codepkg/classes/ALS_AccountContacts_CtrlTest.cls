@isTest
public with sharing class ALS_AccountContacts_CtrlTest {
    @testSetup private static void setup(){
        Account acc = new Account(Name='test12f', Entity_Type__c= ALS_CONSTANTS.Account_EntityType_City);
        insert acc;
        Contact con =new Contact(LastName='Test con', AccountId=acc.Id);
        insert con;
        AccountContactRole__c accCon = new AccountContactRole__c(Account_Name__c=acc.Id,Contact_Name__c=con.Id);
        insert accCon;
    }
    @isTest
	public static void testAccountContact(){
        test.startTest();
        AccountContactRole__c getAccountContactRoleId = [SELECT Id FROM AccountContactRole__c WHERE Account_Name__r.Name = 'test12f'];

        ALS_AccountContacts_Ctrl.getAccountContactsInfo(getAccountContactRoleId.Id,'');
        AccountContactRole__c getAccountContact = [SELECT Id FROM AccountContactRole__c WHERE Id = :getAccountContactRoleId.Id ];
        System.assertEquals(getAccountContactRoleId.Id, getAccountContact.Id);

        ALS_AccountContacts_Ctrl.deleteRecords(getAccountContactRoleId.Id);
        List<AccountContactRole__c> deleteAccountContactsList = [SELECT Id FROM AccountContactRole__c WHERE Id = : getAccountContactRoleId.Id ];
        System.assertEquals(0, deleteAccountContactsList.size());
        test.stopTest();
    }
}