@isTest
private class MARS_SalarySurveyHistoryCtrl_Test {
    @isTest
    static void createRecData(){
        Account acc = new Account();
        acc.Name = 'test';
        insert acc;
        
        Agency_Salary_Survey__c agSalSurvey = new Agency_Salary_Survey__c();
        agSalSurvey.Account__c = acc.Id;
        agSalSurvey.Name = 'Salary survey test';
        insert agSalSurvey;
        
        Salary_Survey_Line_Items__c agSalSurveyLI = new Salary_Survey_Line_Items__c();
        agSalSurveyLI.Agency_Salary_Survey__c = agSalSurvey.Id;
        agSalSurveyLI.Classification_Title__c = 'Chief';
        agSalSurveyLI.Base_Rates__c=27.14;
        agSalSurveyLI.WC_and_or_UI__c='Yes';
        agSalSurveyLI.Are_you_adding_WC_UI__c='No'; 
        agSalSurveyLI.Current_Rate__c=27.14;
        agSalSurveyLI.Revised_Rate__c=27.14; 
        agSalSurveyLI.MOU_MOA__c=false;
        agSalSurveyLI.P_T_P__c=true;
        insert agSalSurveyLI;
        
        MARS_SalarySurveyHistoryCtrl.getAgencySalarySurveyHistory(acc.Id);
        MARS_SalarySurveyHistoryCtrl.getData(agSalSurvey.Id);
    }
}