@isTest(seeAllData=false)
public class CommunityAppHmaRegistrationCtrlTest {
    @isTest public static void testProcessHMARequest(){
        Community_Application__c commApp = new Community_Application__c(Name='HMA');
        insert commApp;
        test.startTest();
        	CommunityAppHmaRegistrationCtrl.processHMARequest();
        test.stopTest();
    }
    @isTest public static void testGetUserDetails(){
        test.startTest();
            Account a = new Account(Name='Test Account Name');
            insert a;
            Contact c = new Contact(LastName = 'Contact Last Name', AccountId = a.id);
            insert c;
            User user = new User();
            user.ProfileID = [select Id,name from Profile where Name like 'PHOS Customer Community Plus Login User' limit 1].id;
            user.EmailEncodingKey = 'ISO-8859-1';
            user.LanguageLocaleKey = 'en_US';
            user.TimeZoneSidKey = 'America/New_York';
            user.LocaleSidKey = 'en_US';
            user.FirstName = 'first';
            user.LastName = 'last';
            user.Username = 'test@appirio.com';
            user.CommunityNickname = 'testUser123';
            user.Alias = 't1';
            user.Email = 'no@email.com';
            user.IsActive = true;
            user.ContactId = c.Id;
            insert user;
            System.RunAs(user) {
                Map<String, Object> userMap = CommunityAppHmaRegistrationCtrl.getUserDetails();
                System.assertNotEquals(userMap, null);
            }
        test.stopTest();
    }
}