@isTest(seeAllData=false)
public class PreApplicationHelperTest {
       @isTest public static void testData() {
            test.startTest();
            Pre_Application__c PreApplication = HMA_TestHelper.getPreApplication(false);
            PreApplication.Current_Stage__c = 'Record Submitted';
            insert PreApplication;
            test.stopTest();
       }
}