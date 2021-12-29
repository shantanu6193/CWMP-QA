@isTest public with sharing class Order_ProductsViewCtrlTest {
    @isTest public static void testGetOrderProducts(){
        /*Account newAccount = new Account();
        newAccount.Name  = '01 - Alameda';
        newAccount.Queue_Name__c = 'RDMHS_Region_11';
        insert newAccount;

        Contact newContact = new Contact(LastName = 'Contact Last Name', AccountId = newAccount.id);
        insert newContact;

        User newUser = new User();
        newUser.ProfileID = [Select Id From Profile Where Name='CalOES Customer Community Plus User'].id;
        newUser.EmailEncodingKey = 'ISO-8859-1';
        newUser.LanguageLocaleKey = 'en_US';
        newUser.TimeZoneSidKey = 'America/New_York';
        newUser.LocaleSidKey = 'en_US';
        newUser.FirstName = 'first';
        newUser.LastName = 'last';
        newUser.Username = 'test@appssm111ssirio.com';   
        newUser.CommunityNickname = 'testcccUser123';
        newUser.Alias = 't1';
        newUser.Email = 'no1111@emakkkkkil.com';
        newUser.IsActive = true;
        newUser.ContactId = newContact.Id;*/
        Account acc = PHOS_TestHelper.getParentAccount(true);
        Contact con = PHOS_TestHelper.getPortalContact(false);
        con.AccountId = acc.Id;
        insert con;
        User newUser = PHOS_TestHelper.getPortalUser(false);
        newUser.Username = 'testUser1233221@gmail.com';
        newUser.Email = 'testUser1233221@gmail.com';
        newUser.ContactId = con.Id;
        insert newUser;
        System.runAs(newUser){
            Map<String, Object> returnMap = new Map<String, Object>();
            List<String> fieldAPINameList = new List<String>();
            Order__c newOrder = PHOS_TestHelper.getOrder(false);
            //newOrder.CreatedById = newUser.Id;
            insert newOrder;
            String orderId = String.valueOf(newOrder.Id);
            fieldAPINameList.add('Description__c');
            String fieldAPINames = JSON.serialize(fieldAPINameList);

            Test.startTest();
            returnMap = Order_ProductsViewCtrl.getOrderProducts(orderId, fieldAPINames);
            System.assert(returnMap.size()>0);
            Test.stopTest();
        }
        
    }
}