@isTest
private class MarsGenerateInvoiceCtrl_Test {
    @isTest
    static void createF42Rec(){
        Account acct = TestUtility.createAccount('test');
        Contact cont = TestUtility.createContact('test', 'tes', 'test@gmail.vom', acct.Id);
        
        Incident__c incident = new Incident__c();
        incident.Name = 'testIncident';
        insert incident;
        
        Invoice__c invoice = new Invoice__c();
        invoice.Name = 'testInvoice';
        insert invoice;
        
        F42__c f42Rec = new F42__c(Strike_Team__c = '22134', Name = 'testing', Status__c = 'Approved', Account__c = acct.Id, Incident__c = incident.Id);
        insert f42Rec;
        
        Agency_Salary_Survey__c agencyRecord = new Agency_Salary_Survey__c();
        agencyRecord.Account__c = f42Rec.Account__c;
        agencyRecord.Status__c = 'Approved';
        agencyRecord.Start_Date_Year__c = '2021';
        insert agencyRecord;
        
        Funding_Source__c funSource = new Funding_Source__c();
        funSource.Account__c = acct.Id;
        funSource.Name = 'testFunSource';
        insert funSource;
        
        Funding_Rule__c funRule = new Funding_Rule__c();
        funRule.Funding_Source_1__c = funSource.Id;
        funRule.Incident__c = incident.Id;
        funRule.Name = 'testFunRule';
        funRule.Rule_Type__c = 'Sole Source';
        insert funRule;
        
        Reimbursement__c expClaims = new Reimbursement__c();
        expClaims.Incident__c = incident.Id;
        insert expClaims;
        
        String incidentId = incident.Id;
        String accId = acct.Id;
        String funRuleId = funRule.Id;
        String expClaimId = expClaims.Id;
        List<String> f42s = new List<String>();
        for(F42__c ac: [Select Id, Name from F42__c where Name = 'testing']){
            f42s.add(ac.Id);
        }
        
        MarsGenerateInvoiceCtrl.getF42Entries(accId, incidentId);
        MarsGenerateInvoiceCtrl.apexSearchIncident('testIncident');
        MarsGenerateInvoiceCtrl.apexSearchAgency('test');
        //MarsGenerateInvoiceCtrl.generateInvoice(incidentId, accId, f42s, funRuleId, new List<String>{expClaims.Id});
    }    
}