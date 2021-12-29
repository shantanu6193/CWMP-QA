/**
 * Created by StackNexus Admin on 02-02-2021.
 */
@IsTest
public with sharing class ContactRoleTriggerHelperTest {
    @IsTest
    public static void testContactRile() {
        Account acc = new Account(Name='test12f', Entity_Type__c=ALS_CONSTANTS.Account_EntityType_City);
        insert acc;
        Contact con =new Contact(LastName='Test con', AccountId=acc.Id);
        insert con;
        AccountContactRole__c accCon1 = new AccountContactRole__c(Account_Name__c=acc.Id,Contact_Name__c=con.Id);
        insert accCon1;
        AccountContactRole__c accCon2 = new AccountContactRole__c(Account_Name__c=acc.Id,Contact_Name__c=con.Id);
        Test.startTest();
            try{
                insert accCon2;
            }
            catch (Exception e) {
                system.assert(e.getMessage().contains(System.Label.REAL_ContactRole_DuplicateError));
            }
        Test.stopTest();
    }
}