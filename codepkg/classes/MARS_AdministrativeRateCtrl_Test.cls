@isTest
private class MARS_AdministrativeRateCtrl_Test {
    @isTest
    static void test(){
       Id profileId = [Select Id From Profile Where Name ='CalOES Portal User'].Id;
         Account acct = TestUtility.createAccount('test');
        
        Contact cont = TestUtility.createContact('test', 'tes', 'test@gmail.vom', acct.Id);
        User u = TestUtility.createCommunityUser(cont.Id, profileId, 'Amit', 'Singh');
        //PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'MARS Community User'];
		//insert new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = ps.Id);
        
        AccountContactRelation acr = [SELECT AccountId,ContactId FROM AccountContactRelation WHERE AccountId = :acct.Id AND ContactId = :cont.Id];
      
        acr.Relationship_Strength__c = 'Strong';
        update acr;
        
        Agency_Admin_Rates__c agAdmRate = new Agency_Admin_Rates__c();
        agAdmRate.Agency__c = acct.Id;
        agAdmRate.Name = 'testAgAdmRate';
        agAdmRate.Approval_Status__c = MARS_Constants.SURVEY_STATUS_PENDING_REVIEW;
        //insert agAdmRate;
        String objParentData = JSON.serialize(agAdmRate);
        
        Agency_Admin_Line_Items__c agAdmRateLI = new Agency_Admin_Line_Items__c();
        agAdmRateLI.Agency_Administrative_Rates__c = agAdmRate.Id;
        agAdmRateLI.Name = 'Telecommunications';
        //insert agAdmRateLI;
        List<Agency_Admin_Line_Items__c> agAdmRateLILst = [SELECT Id FROM Agency_Admin_Line_Items__c WHERE Agency_Administrative_Rates__c = :agAdmRate.Id];
        String lineItemsString = JSON.serialize(agAdmRateLILst);
        
        System.runAs(u){
            MARS_AdministrativeRateCtrl.retrivePrograms(acct.Id);
            String effDate = String.valueOf(System.today());
          // MARS_AdministrativeRateCtrl.createLineItems(lineItemsString, acr.Id, effDate, '', objParentData);
           MARS_AdministrativeRateCtrl.createLineItems(lineItemsString, acct.Id, effDate, '', objParentData);
          // MARS_AdministrativeRateCtrl.createLineItems(lineItemsString, '', effDate, '', objParentData);
        }
    }
    
    
}