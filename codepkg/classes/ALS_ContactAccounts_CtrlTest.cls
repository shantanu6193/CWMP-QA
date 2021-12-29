@isTest
public with sharing class ALS_ContactAccounts_CtrlTest {
    @isTest
    public static void testContactAccount(){
        Account acc = new Account(Name='test12f', Entity_Type__c=ALS_CONSTANTS.Account_EntityType_City);
        insert acc;
        Contact con =new Contact(LastName='Test con', AccountId=acc.Id);
        insert con;
        AccountContactRole__c accCon = new AccountContactRole__c(Account_Name__c=acc.Id,Contact_Name__c=con.Id, Contact_Role_Global_List__c = ALS_CONSTANTS.ACRole_ContactRole_Employee);
        insert accCon;
        test.startTest();
        ALS_ContactAccounts_Ctrl.getContactAccountsInfo(con.Id,'');
        ALS_ContactAccounts_Ctrl.deleteRecords(accCon.Id);
        test.stopTest();
    }
}