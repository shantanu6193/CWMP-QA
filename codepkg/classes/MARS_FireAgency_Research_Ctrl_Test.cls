@IsTest
private class MARS_FireAgency_Research_Ctrl_Test {
    
    @testSetup
    static void getSalarySurveyItems(){
        Account acc = new Account();
        acc.Name = 'test';
        insert acc;
        
        Account accnt = new Account();
        accnt.Name = 'testing';
        insert accnt;
        
        Account acct = new Account();
        acct.Name = 'test account';
        insert acct;
        
        Agency_Salary_Survey__c expSurveyRecord = new Agency_Salary_Survey__c();
        expSurveyRecord.Account__c = acc.Id;
        expSurveyRecord.Status__c = 'Expired';
        expSurveyRecord.Start_Date__c = Date.today() - 10;
        expSurveyRecord.END_Date__c = Date.today() + 10;
        insert expSurveyRecord;
        
        Agency_Salary_Survey__c appSurveyRecord = new Agency_Salary_Survey__c();
        appSurveyRecord.Account__c = accnt.Id;
        appSurveyRecord.Status__c = 'Approved';
        appSurveyRecord.Start_Date__c = Date.today() - 10;
        insert appSurveyRecord;
        
        Salary_Survey_Line_Items__c expSurveyLineItem = new Salary_Survey_Line_Items__c();
        expSurveyLineItem.Agency_Salary_Survey__c = expSurveyRecord.Id;
        expSurveyLineItem.Classification_Title__c = 'Chief';
        expSurveyLineItem.Base_Rates__c = 20.0;
        expSurveyLineItem.Revised_Rate__c = 25.0;
        expSurveyLineItem.WC_and_or_UI__c = 'Yes';
        expSurveyLineItem.Are_you_adding_WC_UI__c = 'No';
        insert expSurveyLineItem;
        
        Salary_Survey_Line_Items__c appSurveyLineItem = new Salary_Survey_Line_Items__c();
        appSurveyLineItem.Agency_Salary_Survey__c = appSurveyRecord.Id;
        appSurveyLineItem.Classification_Title__c = 'Chief';
        appSurveyLineItem.Base_Rates__c = 20.0;
        appSurveyLineItem.Revised_Rate__c = 25.0;
        appSurveyLineItem.WC_and_or_UI__c = 'Yes';
        appSurveyLineItem.Are_you_adding_WC_UI__c = 'No';
        insert appSurveyLineItem;
        
        Agency_Non_Suppression_Personnel__c expNonSuppPersonnel = new Agency_Non_Suppression_Personnel__c();
        expNonSuppPersonnel.Agency__c = acc.Id;
        expNonSuppPersonnel.Approval_Status__c = 'Expired';
        expNonSuppPersonnel.Start_Date__c = System.today() - 10;
        expNonSuppPersonnel.End_Date__c = System.today() + 10;
        insert expNonSuppPersonnel;
        
        Agency_Non_Suppression_Personnel__c appNonSuppPersonnel = new Agency_Non_Suppression_Personnel__c();
        appNonSuppPersonnel.Agency__c = accnt.Id;
        appNonSuppPersonnel.Approval_Status__c = 'Approved';
        appNonSuppPersonnel.Start_Date__c = System.today() - 10;
        insert appNonSuppPersonnel;
        
        Agency_Special_Equipment__c expSpecialEquipment = new Agency_Special_Equipment__c();
        expSpecialEquipment.Agency__c = acc.Id;
        expSpecialEquipment.Approval_Status__c = 'Expired';
        expSpecialEquipment.Start_Date__c = System.today() - 10;
        expSpecialEquipment.End_Date__c = System.today() + 10;
        insert expSpecialEquipment;
        
        Agency_Special_Equipment__c appSpecialEquipment = new Agency_Special_Equipment__c();
        appSpecialEquipment.Agency__c = accnt.Id;
        appSpecialEquipment.Approval_Status__c = 'Approved';
        appSpecialEquipment.Start_Date__c = System.today() - 10;
        insert appSpecialEquipment;
        
        Agency_Rate_Agreement__c expRateAggrementLI = new Agency_Rate_Agreement__c();
        expRateAggrementLI.Agency__c = acc.Id;
        expRateAggrementLI.Approval_Status__c = 'Expired';
        expRateAggrementLI.Start_Date__c = System.today() - 10;
        expRateAggrementLI.End_Date__c = System.today() + 10;
        insert expRateAggrementLI;
        
        Agency_Rate_Agreement__c appRateAggrementLI = new Agency_Rate_Agreement__c();
        appRateAggrementLI.Agency__c = accnt.Id;
        appRateAggrementLI.Approval_Status__c = 'Approved';
        appRateAggrementLI.Start_Date__c = System.today() - 10;
        insert appRateAggrementLI;
        
        Agency_Admin_Rates__c expAdminRates = new Agency_Admin_Rates__c();
        expAdminRates.Agency__c = acc.Id;
        expAdminRates.Approval_Status__c = 'Expired';
        expAdminRates.Start_Date__c = System.today() - 10;
        expAdminRates.End_Date__c = System.today() + 10;
        insert expAdminRates;
        
        Agency_Admin_Rates__c appAdminRates = new Agency_Admin_Rates__c();
        appAdminRates.Agency__c = accnt.Id;
        appAdminRates.Approval_Status__c = 'Approved';
        appAdminRates.Start_Date__c = System.today() - 10;
        insert appAdminRates;
    }
    
    @IsTest
    static void expRecordTest(){
        Account acct = [SELECT Id FROM Account WHERE Name = 'test'];
        MARS_FireAgency_Research_Ctrl fireAgency = new MARS_FireAgency_Research_Ctrl();
        MARS_FireAgency_Research_Ctrl.getSalarySurveyItems(acct.Id, System.today());
        MARS_FireAgency_Research_Ctrl.getNonsupressionItems(acct.Id, System.today());
        MARS_FireAgency_Research_Ctrl.getSpecialEquipmentItems(acct.Id, System.today());
        MARS_FireAgency_Research_Ctrl.getAgreementLineItems(acct.Id, System.today());
        MARS_FireAgency_Research_Ctrl.getAdminLineItems(acct.Id, System.today());
    }
    
    @IsTest
    static void appRecordTest(){
        Account acct = [SELECT Id FROM Account WHERE Name = 'testing'];
        MARS_FireAgency_Research_Ctrl fireAgency = new MARS_FireAgency_Research_Ctrl();
        MARS_FireAgency_Research_Ctrl.getSalarySurveyItems(acct.Id, System.today());
        MARS_FireAgency_Research_Ctrl.getNonsupressionItems(acct.Id, System.today());
        MARS_FireAgency_Research_Ctrl.getSpecialEquipmentItems(acct.Id, System.today());
        MARS_FireAgency_Research_Ctrl.getAgreementLineItems(acct.Id, System.today());
        MARS_FireAgency_Research_Ctrl.getAdminLineItems(acct.Id, System.today());
    }
    
    @IsTest
    static void test(){
        Account acct = [SELECT Id FROM Account WHERE Name = 'test account'];
        MARS_FireAgency_Research_Ctrl fireAgency = new MARS_FireAgency_Research_Ctrl();
        MARS_FireAgency_Research_Ctrl.getSalarySurveyItems(acct.Id, System.today());
        MARS_FireAgency_Research_Ctrl.getNonsupressionItems(acct.Id, System.today());
        MARS_FireAgency_Research_Ctrl.getSpecialEquipmentItems(acct.Id, System.today());
        MARS_FireAgency_Research_Ctrl.getAgreementLineItems(acct.Id, System.today());
        MARS_FireAgency_Research_Ctrl.getAdminLineItems(acct.Id, System.today());
    }
    
}