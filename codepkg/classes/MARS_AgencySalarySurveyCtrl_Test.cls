@isTest
public class MARS_AgencySalarySurveyCtrl_Test {
 @isTest
  static void testAgencySalarySurvey(){
      	Account acc = new Account();
        acc.Name = 'test';
        insert acc;
        
        Agency_Salary_Survey__c salarySurvey = new Agency_Salary_Survey__c();
        salarySurvey.Account__c = acc.Id;
        salarySurvey.Status__c = 'Reviewed';
        insert salarySurvey;
        
 		 ContentVersion cv = MARS_TestHelper.getContentVersion();
        //Get Content Documents
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        //Create ContentDocumentLink 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = salarySurvey.Id;
        cdl.ContentDocumentId = conDocId;
        cdl.shareType = 'V';
        Insert cdl;
        PageReference testPage = Page.MARS_AgencySalarySurveyPDF; 
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('Id', String.valueOf(salarySurvey.Id));
        MARS_AgencySalarySurveyCtrl testObject = new MARS_AgencySalarySurveyCtrl(); 
  }
}