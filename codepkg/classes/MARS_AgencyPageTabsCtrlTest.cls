@isTest
private class MARS_AgencyPageTabsCtrlTest {
    static testMethod void getUserTabAccesstest(){
        Account acc=new Account();
        acc.Name='Test';
        insert acc;
        
        Test.startTest();
        MARS_AgencyPageTabsCtrl.getUserTabAccess(acc.Id);
        Test.stopTest();
        
       
        }
    
    static testMethod void createUser(){
        Id profileId = [Select Id From Profile Where Name ='CalOES Portal User'].Id;
        Account acct = TestUtility.createAccount('test');
        
        Contact cont = TestUtility.createContact('test', 'tes', 'test@gmail.vom', acct.Id);
        User u = TestUtility.createCommunityUser(cont.Id, profileId, 'Amit', 'Singh');
        System.runAs( u ){
            MARS_AgencyPageTabsCtrl.getUserTabAccess(acct.Id);
        }
    }
}