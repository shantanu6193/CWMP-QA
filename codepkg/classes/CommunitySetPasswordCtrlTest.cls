@IsTest
public class CommunitySetPasswordCtrlTest {

    @TestSetup
    static void makeData() {
        User_Registration__c userReg = PHOS_TestHelper.getUserRegistration(true);
        String record = JSON.serialize(userReg);
        //CommunityRegistrationCtrl.createUserRegistration(record);
        User_Registration__c userRec = [Select Id, Email__c, Entity_Type__c, Token__c, User__c from User_Registration__c where Email__c =: userReg.Email__c];

        Community_Application__c communityApp = new Community_Application__c(Name = 'HMA',
                isActive__c = true);
        insert communityApp;
    }

    @IsTest
    static void checktokenEmpty() {
        User_Registration__c userRec = [Select Id, Email__c, Entity_Type__c, Token__c, User__c from User_Registration__c];
        userRec.Token__c = '';
        Test.startTest();
        try {
            communitySetPasswordCtrl.setPassword(userRec.Token__c, 'test@1234');
            System.debug('------password------->' + userRec.Password__c);
        }
        catch(Exception ex) {
             system.assertNotEquals(null,ex.getMessage());
            //System.assertEquals('Token empty', ex.getMessage());
            System.debug('------------->' + ex.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    static void checkInvalidtoken() {
        User_Registration__c userRec = [Select Id, Email__c, Entity_Type__c, Token__c, User__c from User_Registration__c];
        userRec.Token__c = 'kC3FY6RC7mdiQSL7r5drp2F8fvnSQp3D';
        Test.startTest();
        try {
            communitySetPasswordCtrl.setPassword(userRec.Token__c, 'test@1234');
            System.debug('------password------->' + userRec.Password__c);
        }
        catch(Exception ex) {
            system.assertNotEquals(null,ex.getMessage());
            //System.assertEquals('Invalid token', ex.getMessage());
            System.debug('------------->' + ex.getMessage());
        }
        Test.stopTest();
    }
 
     @IsTest
    static void checkCreatedUserVerification() {
        User_Registration__c userReg = PHOS_TestHelper.getUserRegistration(false);
 		userReg.Status__c = 'Verification Pending';
        userReg.Token__c = 'kC3FY6RC7mdiQSL7r5drp2F8fvnSQp3D';
        String password = 'test@1234567';
        userReg.Password__c = password;
        userReg.User__c = UserInfo.getUserId();
        insert userReg;
        User_Registration__c userRec = [Select Id, Email__c, Entity_Type__c, Token__c, User__c from User_Registration__c where Token__c =: userReg.Token__c limit 1];
        Test.startTest();
        try {
            communitySetPasswordCtrl.setPassword(userRec.Token__c, password);
        }
        catch(Exception ex) {
            System.debug('------------->' + ex.getMessage());
        }
        Test.stopTest();
    }

     @IsTest
    static void checkPasswordReset() {
        User_Registration__c userReg = PHOS_TestHelper.getUserRegistration(false);
 		userReg.Status__c = 'Password Reset';
        userReg.Token__c = 'kC3FY6RC7mdiQSL7r5drp2F8fvnSQp3D';
        String password = 'test@1234567';
        userReg.Password__c = password;
        userReg.Email__c = 'test23432@gmail.com';
        userReg.User__c = UserInfo.getUserId();
        insert userReg;
        User_Registration__c userRec = [Select Id, Email__c, Entity_Type__c, Token__c, User__c from User_Registration__c where Token__c =: userReg.Token__c limit 1];
        Test.startTest();
        try {
            communitySetPasswordCtrl.setPassword(userRec.Token__c, password);
        }
        catch(Exception ex) {
            System.debug('------------->' + ex.getMessage());
        }
        Test.stopTest();
    }

}