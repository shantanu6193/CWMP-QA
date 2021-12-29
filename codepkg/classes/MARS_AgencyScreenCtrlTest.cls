@isTest
private class MARS_AgencyScreenCtrlTest {
	 static testMethod void getAccountDetailstest() {
         //Account acc = new Account(name='myAccount');
         //Test.startTest();
		 //insert acc;
		   
         //Test.stopTest();
        
         Id profileId = [Select Id From Profile Where Name ='CalOES Portal User'].Id;
         Account acct = TestUtility.createAccount('test');
        
        Contact cont = TestUtility.createContact('test', 'tes', 'test@gmail.vom', acct.Id);
        User u = TestUtility.createCommunityUser(cont.Id, profileId, 'Amit', 'Singh');
         System.runAs(u) {
             MARS_AgencyScreenCtrl.getAccountDetails(acct.Id);
            MARS_AgencyScreenCtrl.saveAccount(JSON.serialize(acct));
            MARS_AgencyScreenCtrl.inviteUsersToAgency('test@test.com', 'test', 'test');
         } 
		

}
}