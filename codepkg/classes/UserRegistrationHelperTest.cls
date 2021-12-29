@isTest(SeeAllData=true)
public class UserRegistrationHelperTest {
	
    /*@IsTest
    public static void test1() {
        Test.startTest();

        Account acc = new Account();
        acc.Name  = 'Alameda, County of';
        acc.Queue_Name__c = 'RDMHS_Region_11';
        insert acc;

        Contact c = new Contact(LastName = 'Contact Last Name', AccountId = acc.id);
        insert c;

        User user = new User();
        user.ProfileID = [Select Id From Profile Where Name='PHOS Customer Community Plus Login User'].id; 
        user.EmailEncodingKey = 'ISO-8859-1';
        user.LanguageLocaleKey = 'en_US';
        user.TimeZoneSidKey = 'America/New_York';
        user.LocaleSidKey = 'en_US';
        user.FirstName = 'first';
        user.LastName = 'last';
        user.Username = 'test@appssm111ssirio.com';   
        user.CommunityNickname = 'testcccUser123';
        user.Alias = 't1';
        user.Email = 'no1111@emakkkkkil.com';
        user.IsActive = true;
        user.ContactId = c.Id;
 
        insert user;
            System.RunAs(user) {
                User_Registration__c userReg = new User_Registration__c();
                userReg.First_Name__c = 'Test';
                userReg.Last_Name__c = 'User';
                userReg.Phone__c = '123456789';
                userReg.Email__c = 'test@111test.com';
                userReg.County__c = 'Alameda, County of';
                userReg.Status__c = 'Pending for Approval';
                userReg.Entity_Type__c= 'County';
                insert userReg;
                User_Registration__c userReg1 = new User_Registration__c();
                userReg1.Id = userReg.Id;
                userReg1.Status__c = 'Approved';
                update userReg1;
            }
        Test.stopTest();
    }*/
    @IsTest
    public static void test2() {
        Test.startTest();

        Account acc = new Account();
        acc.Name  = 'SOC OPS';
        acc.Queue_Name__c = 'RDMHS_Region_11';
        insert acc;

        Contact c = new Contact(LastName = 'Contact Last Name1', AccountId = acc.id);
        insert c;

        User user = new User();
        user.ProfileID = [Select Id From Profile Where Name='PHOS Customer Community Plus Login User'].id;
        user.EmailEncodingKey = 'ISO-8859-1';
        user.LanguageLocaleKey = 'en_US';
        user.TimeZoneSidKey = 'America/New_York';
        user.LocaleSidKey = 'en_US';
        user.FirstName = 'first';
        user.LastName = 'last';
        user.Username = 'test@aqqqqp11rio.com';   
        user.CommunityNickname = 'testssjjsUser123';
        user.Alias = 't1';
        user.Email = 'no1122qq@eaaaamail.com';
        user.IsActive = true;
        user.ContactId = c.Id;
 
        insert user;
            System.RunAs(user) {
                User_Registration__c userReg = new User_Registration__c();
                userReg.First_Name__c = 'Test';
                userReg.Last_Name__c = 'User';
                userReg.Phone__c = '123456789';
                userReg.Email__c = 'test@111tesmmmt.com';
                userReg.County__c = 'Alameda, County of';
                userReg.Status__c = 'Pending for Approval';
                userReg.Entity_Type__c= 'Non-Governmental Entity';
                userReg.Non_Governmental_Entity__c= 'nnncnnnn';
				userReg.Federal_Tax_ID__c = '332222321143212';
                insert userReg;
                User_Registration__c userReg1 = new User_Registration__c();
                userReg1.Id = userReg.Id;
                userReg1.Status__c = 'Approved';
                update userReg1;
            }
        Test.stopTest();
    }
    @IsTest
    public static void test3() {
        Test.startTest();

        Account acc = new Account();
        acc.Name  = 'SOC OPS';
        acc.Queue_Name__c = 'SOC_OPS';
        insert acc;

        Contact c = new Contact(LastName = 'Contact Last Name2', AccountId = acc.id);
        insert c;

        User user = new User();
        user.ProfileID = [Select Id From Profile Where Name='PHOS Customer Community Plus Login User'].id;
        user.EmailEncodingKey = 'ISO-8859-1';
        user.LanguageLocaleKey = 'en_US';
        user.TimeZoneSidKey = 'America/New_York';
        user.LocaleSidKey = 'en_US';
        user.FirstName = 'first';
        user.LastName = 'last';
        user.Username = 'test@aqqq111qp11rio.com';   
        user.CommunityNickname = 'tests111sjjsUser123';
        user.Alias = 't1';
        user.Email = 'no1111122qq@eaaaamail.com';
        user.IsActive = true;
        user.ContactId = c.Id;
 
        insert user;
            System.RunAs(user) {
                User_Registration__c userReg = new User_Registration__c();
                userReg.First_Name__c = 'Test';
                userReg.Last_Name__c = 'User';
                userReg.Phone__c = '123456789';
                userReg.Email__c = 'test@111tcccesmmmt.com';
                userReg.County__c = 'Alameda, County of';
                userReg.Status__c = 'Pending for Approval';
                userReg.Entity_Type__c= 'Non-Governmental Entity';
                userReg.Non_Governmental_Entity__c= 'nnncnnnn';
				userReg.Federal_Tax_ID__c = '33222232112';
                insert userReg;
                User_Registration__c userReg1 = new User_Registration__c();
                userReg1.Id = userReg.Id;
                userReg1.Status__c = 'Rejected';
                update userReg1;
            }
        Test.stopTest();
    }
}