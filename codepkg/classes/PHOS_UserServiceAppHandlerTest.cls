@isTest(seeAllData=false)
public class PHOS_UserServiceAppHandlerTest {
    @isTest public static void testHandleApproveCounty() {
        Contact newContact = PHOS_TestHelper.getContact(true);
        User poratlUser = PHOS_TestHelper.getPortalUser(false);
        poratlUser.ContactId = newContact.Id;
        insert poratlUser;

        System.runAs(poratlUser) {
            List<User_Registration__c> userRegistrationsList = new List<User_Registration__c>();
            Community_Application__c newCommApp = PHOS_TestHelper.getCommunityApplication(true);
            User_Registration__c newUserReg = PHOS_TestHelper.getUserRegistration(false);
            newUserReg.Community_Application__c = newCommApp.Id;
            newUserReg.User__c = poratlUser.Id;
            insert newUserReg;
            userRegistrationsList.add(newUserReg);

            Test.startTest();
            PHOS_UserServiceAppHandler PHOSUserServiceAppHandlerObj = new PHOS_UserServiceAppHandler();
            PHOSUserServiceAppHandlerObj.handleApprove(userRegistrationsList);
            Test.stopTest();
        }
    }

    @isTest public static void testHandleReject() {
        Contact newContact = PHOS_TestHelper.getContact(true);
        User poratlUser = PHOS_TestHelper.getPortalUser(false);
        poratlUser.ContactId = newContact.Id;
        insert poratlUser;

        System.runAs(poratlUser) {

            List<User_Registration__c> userRegistrationsList = new List<User_Registration__c>();
            Community_Application__c newCommApp = PHOS_TestHelper.getCommunityApplication(true);
            User_Registration__c newUserReg = PHOS_TestHelper.getUserRegistration(false);
            newUserReg.Community_Application__c = newCommApp.Id;
            newUserReg.User__c = poratlUser.Id;
            newUserReg.Rejection_Reason__c = 'Request Denied';
            insert newUserReg;
            User_Registration__c newUserReg1 = PHOS_TestHelper.getUserRegistration(false);
            newUserReg1.Community_Application__c = newCommApp.Id;
            newUserReg1.User__c = poratlUser.Id;
            newUserReg1.Entity_Type__c = 'County';
            newUserReg1.Rejection_Reason__c = 'Request Denied';
            insert newUserReg1;
            User_Registration__c newUserReg2 = PHOS_TestHelper.getUserRegistration(false);
            newUserReg2.Community_Application__c = newCommApp.Id;
            newUserReg2.User__c = poratlUser.Id;
            newUserReg2.Entity_Type__c = 'Non-Governmental Entity';
            newUserReg2.Rejection_Reason__c = 'Request Denied';
            insert newUserReg2;

            userRegistrationsList.add(newUserReg);
            userRegistrationsList.add(newUserReg1);
            userRegistrationsList.add(newUserReg2);

            Test.startTest();
            PHOS_UserServiceAppHandler PHOSUserServiceAppHandlerObj = new PHOS_UserServiceAppHandler();
            PHOSUserServiceAppHandlerObj.handleReject(userRegistrationsList);
            Test.stopTest();
        }
    }
    
    @isTest public static void testHandleApproveHospital() {
        Account newParentAccount = new Account();
        newParentAccount.Name = 'New Test21'+system.now()+Math.random();
        newParentAccount.BillingStreet='rewxe';
        newParentAccount.BillingCountry='USA-11';
        newParentAccount.BillingState='NSdY';
        newParentAccount.Queue_Name__c = 'COVID_Contributions_Group_Initial';
        newParentAccount.BillingPostalCode='3425345';
        newParentAccount.Phone='544534334';
        newParentAccount.Entity_Type__c = 'Region';
        newParentAccount.Entity_Id__c = '23434324';
        newParentAccount.Account_Name__c = 'Test';
        insert newParentAccount;
        
        Account newAccount = new Account();
        newAccount.Name = 'demo Test'+system.now()+Math.random();
        newAccount.ParentId = newParentAccount.Id;
        newAccount.BillingStreet='re';
        newAccount.BillingCountry='USA';
        newAccount.type = 'Customer';
        newAccount.BillingState='NY';
        newAccount.Queue_Name__c = 'test23';
        newAccount.BillingPostalCode='3456';
        newAccount.Phone='3243242423';
        newAccount.Website='https://www.google.com';
        newAccount.Entity_Type__c = 'County';
        newAccount.Entity_Id__c = '46546546';
        insert newAccount;
        
        Account newChildAccount = new Account();
        newChildAccount.Name = 'demo Test'+system.now()+Math.random();
        newChildAccount.ParentId = newAccount.Id;
        newChildAccount.BillingStreet='re';
        newChildAccount.BillingCountry='USA';
        newChildAccount.type = 'Customer';
        newChildAccount.BillingState='NY';
        newChildAccount.Queue_Name__c = 'test23';
        newChildAccount.BillingPostalCode='3456';
        newChildAccount.Phone='3243242423';
        newChildAccount.Website='https://www.google.com';
        newChildAccount.Entity_Type__c = 'Health Care Facility';
        newChildAccount.Entity_Id__c = '23423432';
        insert newChildAccount;
        
         Contact childContact = new Contact();
         childContact.AccountId = newChildAccount.Id; 
         childContact.Firstname = 'ChildFirstName';
         childContact.Lastname = 'childLastName';
         childContact.Email = 'childemail@email.com';
         childContact.Phone ='123-123-1234';
         insert childContact;
        User poratlUser = PHOS_TestHelper.getPortalUser(false);
        poratlUser.ContactId = childContact.Id;
        insert poratlUser;

        System.runAs(poratlUser) {
            List<User_Registration__c> userRegistrationsList = new List<User_Registration__c>();
            Community_Application__c newCommApp = PHOS_TestHelper.getCommunityApplication(true);
            User_Registration__c newUserReg = PHOS_TestHelper.getUserRegistration(false);
            newUserReg.Community_Application__c = newCommApp.Id;
            newUserReg.User__c = poratlUser.Id;
            insert newUserReg;
            userRegistrationsList.add(newUserReg);

            Test.startTest();
            PHOS_UserServiceAppHandler PHOSUserServiceAppHandlerObj = new PHOS_UserServiceAppHandler();
            PHOSUserServiceAppHandlerObj.handleApprove(userRegistrationsList);
            Test.stopTest();
        }
    }
    @IsTest public static void testFormatPlainBody(){
        Test.startTest();
        PHOS_SendEmail_Request_For_Incidents.formatPlainBody('this is first, email.');                                                            
        Test.stopTest();
    }
    
}