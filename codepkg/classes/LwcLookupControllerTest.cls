@isTest
public with sharing class LwcLookupControllerTest {
   
   @isTest public Static void testLwcLookupControllerMethod() {
    Account acc = new Account(Name='test1222',Entity_Type__c=ALS_CONSTANTS.Account_EntityType_City);
    insert acc;
    Contact con =new contact(LastName='test',AccountId=acc.Id);
    insert con;
    test.startTest();
     lwcLookupController.findDefaultRecord(acc.Id, 'Account');
     lwcLookupController.findContactsRelatedToAccount('Test',acc.Id);
     lwcLookupController.findRecords('Test','Account');
     lwcLookupController.searchSobjectUsingSOSL('Test','Contact','Id','','LastName');
     lwcLookupController.findDefaultRecord(con.Id, 'Contact');
    test.stopTest();
    }
}