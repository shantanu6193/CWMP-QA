@isTest
public class MARS_AgencySummaryCtrl_Test {
    @isTest
    static void testGetData() {
        Account acc = new Account();
        acc.Name = 'test';
        insert acc;
        
        Agency_Salary_Survey__c expSurveyRecord = new Agency_Salary_Survey__c();
        expSurveyRecord.Account__c = acc.Id;
        expSurveyRecord.Status__c = 'Expired';
        expSurveyRecord.Start_Date__c = Date.today() - 10;
        expSurveyRecord.END_Date__c = Date.today() + 10;
        insert expSurveyRecord;
        
        Agency_Salary_Survey__c appSurveyRecord = new Agency_Salary_Survey__c();
        appSurveyRecord.Account__c = acc.Id;
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
        appSurveyLineItem.Classification_Title__c = 'Test';
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
        appNonSuppPersonnel.Agency__c = acc.Id;
        appNonSuppPersonnel.Approval_Status__c = 'Approved';
        appNonSuppPersonnel.Start_Date__c = System.today() - 10;
        insert appNonSuppPersonnel;

        Agency_Non_Suppression_Line_Item__c nonSuppLineItem = new Agency_Non_Suppression_Line_Item__c();
        nonSuppLineItem.Classification_Title__c = 'Chief';
        nonSuppLineItem.Current_Rate__c = 20.24;
        nonSuppLineItem.Revised_Rate__c = 22.24;
        nonSuppLineItem.MOU_MOA_GBR__c =  true;
        nonSuppLineItem.Agency_Non_Suppression_Personnel__c=expNonSuppPersonnel.Id;
		insert nonSuppLineItem;

        Agency_Non_Suppression_Line_Item__c nonSuppLineItem1 = new Agency_Non_Suppression_Line_Item__c();
        nonSuppLineItem1.Classification_Title__c = 'Test';
        nonSuppLineItem1.Current_Rate__c = 20.24;
        nonSuppLineItem1.Revised_Rate__c = 22.24;
        nonSuppLineItem1.MOU_MOA_GBR__c =  true;
        nonSuppLineItem1.Agency_Non_Suppression_Personnel__c=expNonSuppPersonnel.Id;
		insert nonSuppLineItem1;
        
        Agency_Special_Equipment__c expSpecialEquipment = new Agency_Special_Equipment__c();
        expSpecialEquipment.Agency__c = acc.Id;
        expSpecialEquipment.Approval_Status__c = 'Expired';
        expSpecialEquipment.Start_Date__c = System.today() - 10;
        expSpecialEquipment.End_Date__c = System.today() + 10;
        insert expSpecialEquipment;
        
        Agency_Special_Equipment__c appSpecialEquipment = new Agency_Special_Equipment__c();
        appSpecialEquipment.Agency__c = acc.Id;
        appSpecialEquipment.Approval_Status__c = 'Approved';
        appSpecialEquipment.Start_Date__c = System.today() - 10;
        insert appSpecialEquipment;
        
        Agency_Rate_Agreement__c expRateAggrementLI = new Agency_Rate_Agreement__c();
        expRateAggrementLI.Agency__c = acc.Id;
        expRateAggrementLI.Approval_Status__c = 'Expired';
        expRateAggrementLI.Start_Date__c = System.today() - 10;
        expRateAggrementLI.End_Date__c = System.today() + 10;
        insert expRateAggrementLI;
        
        Agency_Rate_Agreement_Line_Item__c agreementlineItem1 = new Agency_Rate_Agreement_Line_Item__c();
        agreementlineItem1.Agency_Rate_Agreement__c = expRateAggrementLI.Id;
		agreementlineItem1.OT__c = true;
        agreementlineItem1.MOU_MOA__c = true;
        agreementlineItem1.PTP__c = true;
        agreementlineItem1.Name ='Test';
        insert agreementlineItem1;
        
        Agency_Rate_Agreement__c appRateAggrementLI = new Agency_Rate_Agreement__c();
        appRateAggrementLI.Agency__c = acc.Id;
        appRateAggrementLI.Approval_Status__c = 'Approved';
        appRateAggrementLI.Start_Date__c = System.today() - 10;
        insert appRateAggrementLI;
        
        Agency_Rate_Agreement_Line_Item__c agreementlineItem2 = new Agency_Rate_Agreement_Line_Item__c();
        agreementlineItem2.Agency_Rate_Agreement__c = appRateAggrementLI.Id;
        agreementlineItem2.OT__c = true;
        agreementlineItem2.MOU_MOA__c = true;
        agreementlineItem2.PTP__c = true;
        agreementlineItem2.Name = 'Chief';
        insert agreementlineItem2;
        Agency_Admin_Rates__c expAdminRates = new Agency_Admin_Rates__c();
        expAdminRates.Agency__c = acc.Id;
        expAdminRates.Approval_Status__c = 'Approved';
        expAdminRates.Start_Date__c = System.today() - 10;
        expAdminRates.End_Date__c = System.today() + 10;
        insert expAdminRates;
        
        Agency_Admin_Rates__c appAdminRates = new Agency_Admin_Rates__c();
        appAdminRates.Agency__c = acc.Id;
        appAdminRates.Approval_Status__c = 'Approved';
        appAdminRates.Start_Date__c = System.today() - 10;
        appAdminRates.Administrative_Rate_Indirect_Cost_Direct__c = 0.10000;
        insert appAdminRates;
        
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        Insert cv;
        
        //Get Content Documents
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;

        //Create ContentDocumentLink 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = appRateAggrementLI.Id;
        cdl.ContentDocumentId = conDocId;
        cdl.shareType = 'V';
        Insert cdl;
        MARS_AgencySummaryCtrl.SalaryAndNonSuppresionPersonnel obj= new MARS_AgencySummaryCtrl.SalaryAndNonSuppresionPersonnel();
        Datetime dt = System.today();
        Map<String, Object> returnMap = MARS_AgencySummaryCtrl.getData(acc.Id,Date.newInstance(dt.year(),dt.month(),dt.day()));
        String dateStr = dt.year()+'-'+dt.month()+'-'+dt.day();
        PageReference testPage = Page.MARS_AgencySummaryPDF; 
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('id', String.valueOf(acc.Id));
        testPage.getParameters().put('date', dateStr);
        MARS_AgencySammaryPdfCtrl test = new MARS_AgencySammaryPdfCtrl(); 
    }

}