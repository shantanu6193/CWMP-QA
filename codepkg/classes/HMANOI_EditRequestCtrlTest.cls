@isTest(seeAllData=false)
public with sharing class HMANOI_EditRequestCtrlTest {
    @isTest 
    static void testGetInitData(){
        Pre_Application__c PreApplication = HMA_TestHelper.getPreApplication(true);
        PreApplication.Status__c ='Pending Review';
        PreApplication.Current_Stage__c ='Record Submitted';
        update PreApplication;
        string preAppId = String.valueOf(PreApplication.Id);       
        test.startTest();
        Map<String, Object> returnMap = HMANOI_EditRequestCtrl.getInitData(preAppId);
        test.stopTest();
        system.assert(returnMap.size()>0);
    }
    @isTest 
    static void testGetInitData1(){
        Pre_Application__c PreApplication = HMA_TestHelper.getPreApplication(true);
        PreApplication.Status__c ='Analyst Review';
        update PreApplication;
        string preAppId = String.valueOf(PreApplication.Id);       
        test.startTest();
        Map<String, Object> returnMap = HMANOI_EditRequestCtrl.getInitData(preAppId);
        test.stopTest();
        system.assert(returnMap.size()>0);
    }
}