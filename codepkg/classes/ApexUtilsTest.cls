@IsTest
public with sharing class ApexUtilsTest {
    @IsTest
    static void testCheckIfCurrentUserHasEditAccess(){
        test.startTest();
        User newUser = PHOS_TestHelper.getUser(true);
        string recordId = String.valueOf(newUser.Id);
        Boolean value = ApexUtils.checkIfCurrentUserHasEditAccess(recordId);
        System.assertEquals(value,true);
        test.stopTest();
    }
    @IsTest
    static void testShowErrorWhenRecordLocked(){
        test.startTest();
        User newUser = PHOS_TestHelper.getUser(true);
        string recordId = String.valueOf(newUser.Id);
        Boolean value = ApexUtils.showErrorWhenRecordLocked(recordId);
        System.assertEquals(value,true);
        test.stopTest();
    }
    @IsTest
    static void testGetCurrentUserDetails(){
        test.startTest();
        Map<String,object> returnMap = new Map<String,Object>();
        User newUser = PHOS_TestHelper.getUser(true);
        //string recordId = String.valueOf(newUser.Id);
        User newUser1= ApexUtils.getCurrentUserDetails();
        returnMap.put('user',newUser1);
        System.assert(returnMap.size()>0);
        test.stopTest();
    }
    @IsTest
    static void testCheckCommunityUser(){
        test.startTest();
        User newUser = PHOS_TestHelper.getPortalUser(true);
        //string recordId = String.valueOf(newUser.Id);
        system.runAs(newUser){
            Boolean value = ApexUtils.checkCommunityUser();
            System.assertEquals(value,true);
        }
        test.stopTest();
        
    }

}