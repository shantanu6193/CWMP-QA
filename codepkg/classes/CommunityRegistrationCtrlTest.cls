@IsTest(SeeAllData=true)
public class CommunityRegistrationCtrlTest {
    
    @IsTest
    public static void searchAccountTest1() {
        Test.startTest();
        Account stateAccount = PHOS_TestHelper.accountWithEntityType(true, 'State Agency');
        CommunityRegistrationCtrl.apexSearchStateAgency('NewTest', null);
        Test.stopTest();
    }
    @IsTest
    public static void searchAccountTest2() {
        Test.startTest();
        Account cityAccount = PHOS_TestHelper.accountWithEntityType(true, 'City');
        CommunityRegistrationCtrl.apexSearchCity('NewTest', null);
        Test.stopTest();
    }
    @IsTest
    public static void searchAccountTest3() {
        Test.startTest();
        Account tribalAccount = PHOS_TestHelper.accountWithEntityType(true, 'Tribal');
        CommunityRegistrationCtrl.apexSearchTribal('NewTest', null);
        Test.stopTest();
    }
    @IsTest
    public static void searchAccountTest4() {
        Test.startTest();
        Account specialDistrictAccount = PHOS_TestHelper.accountWithEntityType(true, 'Special District');
        CommunityRegistrationCtrl.apexSearchSpecialDistrict('NewTest', null);
        Test.stopTest();
    }
    @IsTest
    public static void searchAccountTest5() {
        Test.startTest();
        Account courtsAccount = PHOS_TestHelper.accountWithEntityType(true, 'Courts');
        CommunityRegistrationCtrl.apexSearchCourts('NewTest', null);
        Test.stopTest();
    }
    @IsTest
    public static void searchAccountTest6() {
        Test.startTest();
        Account facilityAccount = PHOS_TestHelper.accountWithEntityType(true, 'Health Care Facility');
        CommunityRegistrationCtrl.apexSearchFacility('NewTest', null);
        Test.stopTest();
    }
    @IsTest
    public static void createUserRegistrationRequestTest() {
        Test.startTest();
        User_Registration__c userReg = PHOS_TestHelper.getUserRegistration(false);
        userReg.Email__c = 'test12345@test.com';
        String userRegStr = JSON.serialize(userReg);
        CommunityRegistrationCtrl.createUserRegistration(userRegStr);
        User_Registration__c userRec = [Select Id, Email__c, Entity_Type__c from User_Registration__c where Email__c ='test12345@test.com'];
        System.assert(userRec.Id != null);
        Test.stopTest();
    }
    
    @IsTest
    public static void createHHUserRegistrationRequestTestEN() {
        Test.startTest();
        User_Registration__c userReg = PHOS_TestHelper.getUserRegistration(false);
        userReg.Email__c = 'test12345@test.com';
        userReg.Translation_Language__c ='en_US';
        userReg.RecordTypeId = Schema.SObjectType.User_Registration__c.getRecordTypeInfosByDeveloperName().get(System.Label.HH_RecordType_API_Name_HH_Registration).getRecordTypeId();
        userReg.Is_Mailing_Address_Different__c = HH_CONSTANTS.PickList_No;
        String userRegStr = JSON.serialize(userReg);
        CommunityRegistrationCtrl.createUserRegistration(userRegStr);
        User_Registration__c userRec = [Select Id, Email__c, Entity_Type__c from User_Registration__c where Email__c ='test12345@test.com'];
        System.assert(userRec.Id != null);
        Test.stopTest();
    }

        @IsTest
    public static void createHHUserRegistrationRequestTestES() {
        Test.startTest();
        User_Registration__c userReg = PHOS_TestHelper.getUserRegistration(false);
        userReg.Email__c = 'test12345@test.com';
        userReg.Translation_Language__c ='es';
        userReg.Unique_Household_Number__c = '4fqd4';
        userReg.RecordTypeId = Schema.SObjectType.User_Registration__c.getRecordTypeInfosByDeveloperName().get(System.Label.HH_RecordType_API_Name_HH_Registration).getRecordTypeId();
        String userRegStr = JSON.serialize(userReg);
        CommunityRegistrationCtrl.createUserRegistration(userRegStr);
        User_Registration__c userRec = [Select Id, Email__c, Entity_Type__c from User_Registration__c where Email__c ='test12345@test.com'];
        System.assert(userRec.Id != null);
        Test.stopTest();
    }
}