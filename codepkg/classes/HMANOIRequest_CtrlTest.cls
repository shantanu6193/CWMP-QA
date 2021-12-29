@isTest public with sharing class HMANOIRequest_CtrlTest {
    @isTest public static void testSubmitRequest(){
        Map<String,Object> returnMap = new Map<String,Object>();
        Pre_Application__c preApplication = HMA_TestHelper.getPreApplication(false);
        preApplication.Status__c = 'Pending Review';
        insert preApplication;
        Contact contact = HMA_TestHelper.getPortalContact(true);
        Contact_Role__c contactRole = HMA_TestHelper.getContactRoleForSpecificPreApplication(true, preApplication, contact.Id, 'Responsible Representative');
        Pre_Application__c record = HMA_TestHelper.getPreApplicationQueryData(preApplication.Id);         
        string recordData = JSON.serialize(record);
        Test.startTest();
        Pre_Application__c result = HMANOIRequest_Ctrl.submitRequest(recordData);
        returnMap.put('result',result);
        system.assert(returnMap.size()>0);
        Test.stopTest();
    }
    @isTest public static void testgetRecordData(){
        Pre_Application__c preApplication = HMA_TestHelper.getPreApplication(true);
        string recordId = preApplication.Id;
        test.startTest();
        Pre_Application__c result = HMANOIRequest_Ctrl.getRecordData(recordId);
        test.stopTest();
        Map<String,Object> returnMap = new Map<String,Object>();
        returnMap.put('result',result);
        system.assert(returnMap.size()>0);
    }

    @isTest public static void testgetCommunityContact(){
        Account acc = HMA_TestHelper.getParentAccount(true);
        Contact con = HMA_TestHelper.getPortalContact(false);
        con.AccountId = acc.Id;
        insert con;
        User newUser = HMA_TestHelper.getPortalUser(false);
        newUser.Username = 'testUser1233221@gmail.com';
        newUser.Email = 'testUser1233221@gmail.com';
        newUser.ContactId = con.Id;
        insert newUser;
        System.runAs(newUser){
        test.startTest();
        Contact result = HMANOIRequest_Ctrl.getCommunityContact();
        HMANOIRequest_Ctrl.getRecordTypes();
        test.stopTest();
        Map<String,Object> returnMap = new Map<String,Object>();
        returnMap.put('result',result);
        system.assert(returnMap.size()>0);
        }
        
    }
}