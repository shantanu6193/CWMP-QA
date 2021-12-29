@isTest
public with sharing class PHOS_VaccinationPersonnel_EmailTest {
    @isTest
    public static void testSendEmail(){
        Account acc = PHOS_TestHelper.getParentAccount(true);
        Contact con = CommunityAppPHOSRegistrationCtrlTest.getPortalContact(false);
        con.AccountId = acc.Id;
        insert con; 
        User u = [SELECT Id FROM User WHERE ID =: UserInfo.getUserId()]; 
        User usr = CommunityAppPHOSRegistrationCtrlTest.getPortalUser(false);
        usr.ContactId = con.Id;
        usr.IsActive = true;
        insert usr;
        Group g1;
        System.runAs(u) {  
             g1 = new Group(Name='testQ', type='Queue');
            insert g1;   
            QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Order__c');
            insert q1;
            GroupMember member = new GroupMember();
            member.UserOrGroupId = usr.Id;
            member.GroupId = g1.Id;
            insert member;
        }
        System.runAs(usr) {  
            Test.startTest();
            List<Id> orderList = new List<Id>();
            Order__c newOrder = PHOS_TestHelper.getOrder(false);
            newOrder.Status__c ='CDPH Pharmacy Consultant Review';
            newOrder.OwnerId = g1.Id;
            newOrder.Type_of_Personnel__c ='Vaccination-related Personnel';
            insert newOrder;
            
            orderList.add(newOrder.Id);
            PHOS_VaccinationPersonnel_Email.sendEmail(orderList);
            Test.stopTest();
            System.assertNotEquals(newOrder.Id, null);
        }
    }
    @isTest public static void testFormatPlainBody(){
        Test.startTest();
        PHOS_SendEmail_Request_For_Incidents.formatPlainBody('this is first, email.');                                                            
        Test.stopTest();
    }
}