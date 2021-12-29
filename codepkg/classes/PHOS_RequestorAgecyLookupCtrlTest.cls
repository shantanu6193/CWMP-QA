/**
 * Created by PREM on 05-10-2020.
 */

@IsTest
private class PHOS_RequestorAgecyLookupCtrlTest {
    @IsTest
    static void apexSearchAgencyTest() {
        test.startTest();
            Account acc = PHOS_TestHelper.getAccount(false);
            Account newParentAccount = PHOS_TestHelper.getParentAccount(true);
        	acc.ParentId = newParentAccount.Id;
            acc.Name = 'Test Heathcare Acc123321';
            acc.Entity_Type__c = 'County';
            insert acc;
            List<LookupSearchResult> accList = PHOS_RequestorAgecyLookupCtrl.apexSearchAgency('Test','County');
            System.assertNotEquals(accList.size(),0);
        test.stopTest();
    }
    @IsTest
    static void testGetPicklistData(){
        Test.startTest();
        List<String> picklistValue = PHOS_RequestorAgecyLookupCtrl.getPicklistData('Account','Entity_Type__c');
    	System.assertNotEquals(picklistValue.size(),0);
    }
    
    @IsTest
    static void testGetCounty(){
        Account acc = PHOS_TestHelper.getAccount(false);
        Account newParentAccount = PHOS_TestHelper.getParentAccount(true);
        acc.ParentId = newParentAccount.Id;
        acc.Name = 'Test Heathcare';
        acc.Entity_Type__c = 'County';
        insert acc;
        List<Account> accList = PHOS_RequestorAgecyLookupCtrl.getCounty();
        System.assert(accList.size()>0);
    }
}