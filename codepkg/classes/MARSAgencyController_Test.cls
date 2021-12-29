@isTest
private class MARSAgencyController_Test {
	@testSetup
    static void createRecData(){
        //Salary Id is used as record ID.
        Agency_Salary_Survey__c ass = new Agency_Salary_Survey__c();
        ass.Name = 'testAss';
        insert ass;
        
        Salary_Survey_Line_Items__c salSurLI = new Salary_Survey_Line_Items__c();
        salSurLI.Agency_Salary_Survey__c = ass.Id;
        insert salSurLI;
        
        Agency_Special_Equipment__c ase = new Agency_Special_Equipment__c();
        ase.Name = 'testAse';
        insert ase;
        
        Agency_Special_Equipment_Line_Item__c aseLI = new Agency_Special_Equipment_Line_Item__c();
        aseLI.Agency_Special_Equipment__c = ase.Id;
        insert aseLI;
        
        Agency_Non_Suppression_Personnel__c agNonSupPer = new Agency_Non_Suppression_Personnel__c();
        agNonSupPer.Name = 'testAgNonSupPer';
        insert agNonSupPer;
        
        Agency_Non_Suppression_Line_Item__c agNonSupPerLI = new Agency_Non_Suppression_Line_Item__c();
        agNonSupPerLI.Agency_Non_Suppression_Personnel__c = agNonSupPer.Id;
        insert agNonSupPerLI;
        
        Agency_Rate_Agreement__c agRateAgr = new Agency_Rate_Agreement__c();
        agRateAgr.Name = 'testAgRateAgr';
        insert agRateAgr;
        
        Agency_Rate_Agreement_Line_Item__c agRateAgrLI = new Agency_Rate_Agreement_Line_Item__c();
        agRateAgrLI.Agency_Rate_Agreement__c = agRateAgr.Id;
        insert agRateAgrLI;
        
        Agency_Admin_Rates__c agAdmRate = new Agency_Admin_Rates__c();
        agAdmRate.Name = 'testAgAdmRate';
        insert agAdmRate;
        
        Agency_Admin_Line_Items__c agAdmRateLI = new Agency_Admin_Line_Items__c();
        agAdmRateLI.Agency_Administrative_Rates__c = agAdmRate.Id;
        insert agAdmRateLI;
    }
    
    @isTest
    static void test(){
        Agency_Salary_Survey__c ass = [SELECT Id FROM Agency_Salary_Survey__c WHERE Name = 'testAss' LIMIT 1];
        String assId = ass.Id;
        Agency_Special_Equipment__c ase = [SELECT Id FROM Agency_Special_Equipment__c WHERE Name = 'testAse' LIMIT 1];
        String aseId = ase.Id;
        Agency_Non_Suppression_Personnel__c agNonSup = [SELECT Id FROM Agency_Non_Suppression_Personnel__c WHERE Name = 'testAgNonSupPer' LIMIT 1];
        String agNonSupId = agNonSup.Id;
        Agency_Rate_Agreement__c agRateAgr = [SELECT Id FROM Agency_Rate_Agreement__c WHERE Name = 'testAgRateAgr' LIMIT 1];
        String agRateAgrId = agRateAgr.Id;
        Agency_Admin_Rates__c agAdmnRate = [SELECT Id FROM Agency_Admin_Rates__c WHERE Name = 'testAgAdmRate' LIMIT 1];
        String agAdmnRateId = agAdmnRate.Id;
        
        MARSAgencyController.updateTheParentToApproved(assId);
        MARSAgencyController.updateTheParentToExpired(assId, 'test');
        MARSAgencyController.updateTheParentToApproved(aseId);
        MARSAgencyController.updateTheParentToExpired(aseId, 'test');
        MARSAgencyController.updateTheParentToApproved(agNonSupId);
        MARSAgencyController.updateTheParentToExpired(agNonSupId, 'test');
        MARSAgencyController.updateTheParentToApproved(agRateAgrId);
        MARSAgencyController.updateTheParentToExpired(agRateAgrId, 'test');
        MARSAgencyController.updateTheParentToApproved(agAdmnRateId);
        MARSAgencyController.updateTheParentToExpired(agAdmnRateId, 'test');
    }
}