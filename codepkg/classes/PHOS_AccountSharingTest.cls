@IsTest
public with sharing class PHOS_AccountSharingTest {
    @IsTest
    public static void testContactSharingWithMultipleAccounts(){
        Account newAccount = new Account();
        newAccount.Name = 'My Test'+system.now()+Math.random();
        newAccount.Phone='544534334';
        newAccount.Entity_Type__c = 'Region';
        newAccount.Entity_Id__c = '454666';
        newAccount.Account_Name__c = 'My Test';
        insert newAccount;
        Contact contact = new Contact(AccountId = newAccount.Id ,Firstname='FirstName', Lastname='LastName',Email='email@email.com',Phone ='123-123-1234');
		insert contact;
        Account newAccount1 = new Account();
        newAccount1.Name = 'New Test17'+system.now()+Math.random();
        newAccount1.Phone='544534334';
        newAccount1.Entity_Type__c = 'County';
        newAccount1.Entity_Id__c = '234543';
        newAccount1.Account_Name__c = 'Test';
        newAccount1.ParentId = newAccount.Id;
        insert newAccount1;
        
        Account newAccount2 = new Account();
        newAccount2.Name = 'Demo Account'+system.now()+Math.random();
        newAccount2.Phone='544534334';
        newAccount2.Entity_Type__c = 'Health Care Facility';
        newAccount2.Entity_Id__c = '433434';
        newAccount2.Account_Name__c = 'Demo';
        newAccount2.ParentId = newAccount1.Id;
        insert newAccount2;
        List<Id> contactId = new List<Id>();
        contactId.add(contact.Id);
        Test.startTest();
        PHOS_AccountSharing.contactSharingWithMultipleAccounts(contactId);
        Test.stopTest();
        
        /*List<Id> contactId = new List<Id>();
        Contact con = PHOS_TestHelper.getContact(true);
        contactId.add(con.Id);
        Test.startTest();
        PHOS_AccountSharing.contactSharingWithMultipleAccounts(contactId);
        Test.stopTest();*/
    }
}