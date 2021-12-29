@isTest
private class MARS_SalarySurveyCrl_Test {
    @isTest
static void getDataTest(){
Account acc = new Account();
acc.Name = 'test';
insert acc;

Agency_Salary_Survey__c agencyRecord = new Agency_Salary_Survey__c();
agencyRecord.Account__c = acc.Id;
agencyRecord.Status__c = 'Reviewed';
insert agencyRecord;

CFAA__c cfaaRecord = new CFAA__c();
cfaaRecord.Name = 'test';
cfaaRecord.Start_Date__c = System.today();
cfaaRecord.END_Date__c = System.today() + 10;
insert cfaaRecord;

Id recId = Schema.SObjectType.CFAA_Line_Items__c.getRecordTypeInfosByName().get('Personnel Base Rate').getRecordTypeId();

CFAA_Line_Items__c cfaaLI = new CFAA_Line_Items__c();
cfaaLI.Personnel_Role__c = 'Chief';
cfaaLI.CFAA__c = cfaaRecord.Id;
cfaaLI.Order_No__c = 1;
cfaaLI.Straight_Time_Rate__c = 100;
cfaaLI.RecordTypeId = recId;
insert cfaaLI;

MARS_SalarySurveyCrl.getData(acc.Id);
String dat = String.valueOf(System.today());
//MARS_SalarySurveyCrl.submitSalarySurveyLines('test', acc.Id, dat, 'null');

}
    
    @testSetup
    static void createRec(){
        Account acc = new Account();
        acc.Name = 'test';
        acc.MACS_ID__c = '1234321';
        insert acc;
        
        Agency_Rate_Agreement__c ageRateAgr = new Agency_Rate_Agreement__c();
        ageRateAgr.Name = 'testAgeRateAgr';
        ageRateAgr.Agency__c = acc.Id;
        ageRateAgr.Approval_Status__c = 'Approved';
        insert ageRateAgr;
        
        Agency_Rate_Agreement_Line_Item__c ageRateAgrLI = new Agency_Rate_Agreement_Line_Item__c();
        ageRateAgrLI.Agency_Rate_Agreement__c = ageRateAgr.Id;
        ageRateAgrLI.Name = 'Chief';
        ageRateAgrLI.OT__c = false;
        ageRateAgrLI.PTP__c = false;
        insert ageRateAgrLI;
        
        Agency_Salary_Survey__c agenSalSur = new Agency_Salary_Survey__c();
        agenSalSur.Name = 'testAgenSalSur';
        agenSalSur.Account__c = acc.Id;
        agenSalSur.Status__c = MARS_Constants.SURVEY_STATUS_REVISED;
        agenSalSur.Start_Date__c = System.today() - 10;
        agenSalSur.END_Date__c = System.today() + 10;
        insert agenSalSur;
        
        Agency_Salary_Survey__c agenSalSur1 = new Agency_Salary_Survey__c();
        agenSalSur1.Name = 'testAgenSalSur1';
        agenSalSur1.Account__c = acc.Id;
        agenSalSur1.Status__c = MARS_Constants.SURVEY_STATUS_PENDING_REVIEW;
        
        insert agenSalSur1;
        
        Salary_Survey_Line_Items__c salSurLI = new Salary_Survey_Line_Items__c();
        salSurLI.Name = 'testSalSurLI';
        salSurLI.Agency_Salary_Survey__c = agenSalSur.Id;
        salSurLI.Classification_Title__c = 'Chief';
        salSurLI.Current_Rate__c = 20.0;
        salSurLI.Status__c = MARS_Constants.SURVEY_STATUS_ACTIVE;
        insert salSurLI;
        
        CFAA__c cfaaRecord = new CFAA__c();
        cfaaRecord.Name = 'test';
        cfaaRecord.Start_Date__c = System.today();
        cfaaRecord.END_Date__c = System.today() + 10;
        insert cfaaRecord;
        
        Id recTypeId = Schema.SObjectType.CFAA_Line_Items__c.getRecordTypeInfosByName().get('Personnel Base Rate').getRecordTypeId();
        
        CFAA_Line_Items__c cfaaLI = new CFAA_Line_Items__c();
        cfaaLI.Personnel_Role__c = 'Chief';
        cfaaLI.CFAA__c = cfaaRecord.Id;
        cfaaLI.Order_No__c = 1;
        cfaaLI.Straight_Time_Rate__c = 100;
        cfaaLI.RecordTypeId = recTypeId;
        insert cfaaLI;
    }
    
    @isTest
    static void test(){
        Account acct = [SELECT Id, Name FROM Account WHERE Name = 'test' LIMIT 1];
        String accId = acct.Id;
        List<Salary_Survey_Line_Items__c> salSurveyLI = [SELECT Id, Name FROM Salary_Survey_Line_Items__c WHERE Name = 'testSalSurLI'];
        String data = JSON.serialize(salSurveyLI);
        MARS_SalarySurveyCrl.getData(acct.Id);
        String effDate = String.valueOf(Date.today());
       // MARS_SalarySurveyCrl.submitSalarySurveyLines(data, accId, effDate, 'test');
    }
}