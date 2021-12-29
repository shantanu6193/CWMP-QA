@IsTest(SeeAllData = true)
public with sharing class LightningLoginFormControllerTest {

    @isTest public static void testLogin() {
        Test.startTest();
        String startUrl= System.currentPageReference().getParameters().get('startURL');
        string pageRef = LightningLoginFormController.login('test','test',startUrl);
        Test.stopTest();
    }
     @isTest public static void testLoginLWC() {
        Test.startTest();
        Map<String,Object> returnMap = new Map<String,Object>();
        String startUrl= System.currentPageReference().getParameters().get('startURL');
        returnMap = LightningLoginFormController.loginLWC('test','test',startUrl);
        System.assert(returnMap.size()>0);
        Test.stopTest();
    }
    @isTest public static void testGetForgotPasswordUrl() {
        String returnMap;
        Test.startTest();
        returnMap = LightningLoginFormController.getForgotPasswordUrl();
        Test.stopTest();
    }
    @isTest public static void testSetExperienceId() {
        String returnMap;
        String expid = ApexPages.currentPage().getParameters().get('expid'); 
        Test.startTest();
        returnMap = LightningLoginFormController.setExperienceId(expid);
        Test.stopTest();
    }

    @IsTest
    static void LightningLoginFormControllerInstantiation() {
        LightningLoginFormController controller = new LightningLoginFormController();
        System.assertNotEquals(controller, null);
    }

    @IsTest
    static void testIsUsernamePasswordEnabled() {
        System.assertEquals(true, LightningLoginFormController.getIsUsernamePasswordEnabled());
    }

    @IsTest
    static void testIsSelfRegistrationEnabled() {
        System.assertEquals(false, LightningLoginFormController.getIsSelfRegistrationEnabled());
    }

    @IsTest
    static void testGetSelfRegistrationURL() {
        System.assertEquals(null, LightningLoginFormController.getSelfRegistrationUrl());
    }

    @IsTest
    static void testAuthConfig() {
        Auth.AuthConfiguration authConfig = LightningLoginFormController.getAuthConfig();
        System.assertNotEquals(null, authConfig);
    }
}