/**
 * Created by PREM on 05-10-2020.
 */
@isTest
public with sharing class CommunityResetPasswordCtrlTest {
    @isTest
    public static void resetPasswordTest() {
        test.startTest();
            Account acc = PHOS_TestHelper.getParentAccount(true);
            Contact con = PHOS_TestHelper.getPortalContact(false);
            con.AccountId = acc.Id;
            insert con;
            User u = PHOS_TestHelper.getPortalUser(false);
            u.Username = 'testUser1233221@gmail.com';
            u.Email = 'testUser1233221@gmail.com';
            u.ContactId = con.Id;
            insert u;
            CommunityResetPasswordCtrl.resetPassword(u.Username,'',HH_CONSTANTS.RecordType_Registration);
            CommunityResetPasswordCtrl.resetPassword(u.Username,'',HH_CONSTANTS.RecordType_HH_RegistrationAPIName);
        test.stopTest();
    }
}