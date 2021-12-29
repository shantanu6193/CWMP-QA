@IsTest
private class MARS_CFAAProcessing_Batch_Test {
    
    @IsTest
    static void createSalarySurvey(){
		Agency_Salary_Survey__c surveyRecord = new Agency_Salary_Survey__c();
        surveyRecord.Status__c = 'Reviewed';
        surveyRecord.Start_Date__c = system.today();
        surveyRecord.END_Date__c=system.today().addDays(2);
        surveyRecord.Name = 'Salary Survey For Agency';
        insert surveyRecord;
        
        CFAA__c currentCFAA = new CFAA__c();
        currentCFAA.Name = 'test';
        currentCFAA.Start_Date__c = Date.today();
        CFAA_Line_Items__c lineitem = new CFAA_Line_Items__c();
        
        insert currentCFAA;
        String currentID = currentCFAA.Id;
        lineitem.CFAA__c = currentCFAA.Id;
        insert lineitem;
        
        Salary_Survey_Line_Items__c salarySurveyLI = New Salary_Survey_Line_Items__c();
        salarySurveyLI.Agency_Salary_Survey__c = surveyRecord.Id;
        salarySurveyLI.Base_Rates__c=27.14; 
        salarySurveyLI.Classification_Title__c='Chief'; 
        salarySurveyLI.Line_Item_Type__c='Personnel'; 
        salarySurveyLI.Are_you_adding_WC_UI__c='No'; 
        salarySurveyLI.WC_and_or_UI__c='Yes'; 
        salarySurveyLI.Current_Rate__c=27.14; 
        salarySurveyLI.Revised_Rate__c=27.14;
        salarySurveyLI.CFAA__c = currentCFAA.Id;
        salarySurveyLI.CFAA_Line_Items__c = lineitem.Id;
        insert salarySurveyLI;    
        
        Test.startTest();
        MARS_CFAAProcessing_Batch mcb = new MARS_CFAAProcessing_Batch();
        mcb.cfaarecId = currentCFAA.Id;
        Id jobId = DataBase.executeBatch(mcb);
        Test.stopTest();
    }

}