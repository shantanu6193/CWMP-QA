@isTest public class ProgressBarWithSubStepsCtrlTest {
    
    @isTest public static void testGetInitData(){
        
        Account newAccount = new Account(Name = 'Test Account1', BillingStreet='re', BillingCountry='USA', BillingState='NY', BillingPostalCode='34545', Phone='54453434', Website='https://www.google.com');
        insert newAccount;
        Account AccountId = [SELECT id FROM Account WHERE Name = 'Test Account1'];
        Date myDate = Date.newInstance(2020, 04, 22);
        Order newOrder = new Order(AccountId = AccountId.Id, Status='Draft', EffectiveDate = myDate, Requestor_Agency_Text__c = 'test1');
        insert newOrder;       
        Order orderId = [SELECT id FROM Order WHERE Requestor_Agency_Text__c = 'test1'];
        String stringId = String.valueOf(orderId.Id);
        
        test.startTest();
        Map<String, Object> returnMap = ProgressBarWithSubStepsCtrl.getInitData('Order', 'Status', stringId);
        test.stopTest();
        System.assert(returnMap.size() > 0);
    }
    
    @isTest public static void testUpdateRecord(){
        
        Account newAccount = new Account(Name = 'Test Account2', BillingStreet='re', BillingCountry='USA', BillingState='NY', BillingPostalCode='34545', Phone='54453434', Website='https://www.google.com');
        insert newAccount;
        Account AccountId = [SELECT id FROM Account WHERE Name = 'Test Account2'];
        Date myDate = Date.newInstance(2020, 04, 22);
        Order newOrder = new Order(AccountId = AccountId.Id, Status='Draft', EffectiveDate = myDate, Requestor_Agency_Text__c = 'test2');
        insert newOrder;       
        Order orderId = [SELECT id FROM Order WHERE Requestor_Agency_Text__c = 'test2'];
        String stringId = String.valueOf(orderId.Id);
        
        test.startTest();
        Map<String, Object> returnMap = ProgressBarWithSubStepsCtrl.updateRecord('Order', 'Status', stringId, 'MHOAC Review');
        test.stopTest();
        System.assert(returnMap.size() > 0); 
        
    }

}