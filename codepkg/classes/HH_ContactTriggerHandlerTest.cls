/**
 * Created by Ricky on 31-08-2021.
 */
@IsTest
public with sharing class HH_ContactTriggerHandlerTest {
    @TestSetup private static void setup() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;
    }

    @IsTest
    public static void testHH_ApplicationTriggerHandler() {
        List<Account> accList = [SELECT Id, Name FROM Account];
        List<Contact> conToInsertList = new List<Contact>();
        Contact con1 = new Contact(FirstName = 'Test', LastName = 'Contact 1',  AccountId = accList[0].Id,
                Is_Mailing_Address_Different__c = HH_CONSTANTS.PickList_No);
        conToInsertList.add(con1);
        Contact con2 = new Contact(FirstName = 'Test', LastName = 'Contact 1',  AccountId = accList[0].Id,
                Physical_Street__c = 'Test Street', Physical_City__c = 'Test City', Physical_State__c = 'Test State',
                Physical_Zip_Postal_Code__c = '12345', Physical_Country__c = 'Test Country',
                Is_Mailing_Address_Different__c = HH_CONSTANTS.PickList_No);
        conToInsertList.add(con2);


        Test.startTest();
        insert conToInsertList;
        
        conToInsertList[0].Physical_Country__c = 'Test Country';

        update conToInsertList[0];

        Test.stopTest();
    }
}