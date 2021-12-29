@isTest
private class MARS_F42Approval_Controller_Test {
    @testSetup
    static void createF42Rec(){
        Account acc = new Account();
        acc.Name = 'test';
        insert acc;
        
        F42__c F42Rec1 = new F42__c();
        F42Rec1.Name = 'test1';
        F42Rec1.Status__c = 'CALOES REVIEW';
        F42Rec1.Account__c = acc.Id;
        insert F42Rec1;
        
        F42__c F42Rec2 = new F42__c();
        F42Rec2.Name = 'test2';
        F42Rec2.Status__c = 'AGENCY REVIEW';
        insert F42Rec2;
        
        F42__c F42Rec3 = new F42__c();
        F42Rec3.Name = 'test3';
        F42Rec3.Status__c = 'APPROVED';
        F42Rec3.Account__c = acc.Id;
        insert F42Rec3;
        
        F42__c F42Rec4 = new F42__c();
        F42Rec4.Name = 'test4';
        F42Rec4.Status__c = 'DOCUMENTATION ONLY';
        insert F42Rec4;
        
        F42__c F42Rec5 = new F42__c();
        F42Rec5.Name = 'test5';
        insert F42Rec5;
    }
    
    @isTest
    static void f42ApprovalTest(){
        F42__c f42Rec1 = [SELECT Id, Name, Status__c FROM F42__c WHERE Name = 'test1' LIMIT 1];
        F42__c f42Rec2 = [SELECT Id, Name, Status__c FROM F42__c WHERE Name = 'test2' LIMIT 1];
        F42__c f42Rec3 = [SELECT Id, Name, Status__c FROM F42__c WHERE Name = 'test3' LIMIT 1];
        F42__c f42Rec4 = [SELECT Id, Name, Status__c FROM F42__c WHERE Name = 'test4' LIMIT 1];
        F42__c f42Rec5 = [SELECT Id, Name FROM F42__c WHERE Name = 'test5' LIMIT 1];
        
        MARS_F42Approval_Controller.initialize(f42Rec1.Id);
        MARS_F42Approval_Controller.initialize(f42Rec2.Id);
        MARS_F42Approval_Controller.initialize(f42Rec3.Id);
        MARS_F42Approval_Controller.initialize(f42Rec4.Id);
        MARS_F42Approval_Controller.initialize(f42Rec5.Id);
        MARS_F42Approval_Controller.f42Approval(f42Rec1.Id, 'DOCUMENTATION ONLY', 'test');
    }
}