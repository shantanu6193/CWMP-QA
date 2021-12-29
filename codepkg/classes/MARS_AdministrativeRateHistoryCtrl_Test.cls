@isTest
Private class MARS_AdministrativeRateHistoryCtrl_Test {
    @testSetup
    static void createAdminRateRec(){
        Account acc = new Account();
        acc.Name = 'test account';
        insert acc;
        
        Agency_Admin_Rates__c agenAdminRates = new Agency_Admin_Rates__c();
        agenAdminRates.Agency__c = acc.Id;
        agenAdminRates.Name = 'test Admin Rate';
        agenAdminRates.Start_Date__c = System.today();
        agenAdminRates.End_Date__c = System.today() + 10;
        agenAdminRates.Approval_Status__c = 'Reviewed';
        insert agenAdminRates;
        
        Agency_Admin_Line_Items__c agenAdminRatesLI = new Agency_Admin_Line_Items__c();
        agenAdminRatesLI.Agency_Administrative_Rates__c = agenAdminRates.Id;
        agenAdminRatesLI.Direct__c = 10;
        agenAdminRatesLI.Indirect__c = 20;
        agenAdminRatesLI.Name = 'test Admin LI';
        agenAdminRatesLI.Status__c = 'Active';
        insert agenAdminRatesLI;
    }
    
    @isTest
    static void test(){
        Account acct = [SELECT Id, Name FROM Account WHERE Name = 'test account' LIMIT 1];
        Agency_Admin_Rates__c agAdminRates = [SELECT Id, Name FROM Agency_Admin_Rates__c WHERE Name = 'test Admin Rate'];
        MARS_AdministrativeRateHistoryCtrl.getAdminRateHistory(acct.Id);
        MARS_AdministrativeRateHistoryCtrl.getData(agAdminRates.Id);
    }

}