@isTest
public with sharing class HH_CreateUpdateAccountRoleCtrlTest {
    @isTest 
    public static void searchAccountRoleTest() {
        Account acc= new Account(Name ='Contractor',Email_Address__c ='test@xyz.com',Phone = '1234567890');
        insert acc;
        Account acc1= new Account(Name ='Contractor1',Email_Address__c ='test@xyz.com',Phone = '1234567890');
        Contact con = new Contact (AccountId = acc.Id,LastName = 'Test',Email = 'Test@xyz.com');
        insert con;
        HH_Application__c hhApp = new HH_Application__c(County__c = 'Shasta',Applicant__c = con.Id);
        insert hhApp;
        CWMP_Project__c hhProj = new CWMP_Project__c (Applicant__c = con.Id,CWMP_Application__c = hhApp.Id);
        insert hhProj;
        Account_Role__c aRole= new Account_Role__c(CWMP_Application__c =hhApp.Id, Point_of_Contact__c= 'XYZ', Original_Contract_Amount__c = 5000, Role__c = 'Contractor', Account__c = acc.Id);
        insert aRole;
        Draw__c dr =new Draw__c(Account_Role__c = aRole.Id,Amount__c = 2000,Date__c = Date.Today()-1);
        insert dr;
        Order_Change__c oChange = new Order_Change__c(Account_Role__c = aRole.Id,Has_Homeowner_provided_check_payment__c = 'Yes',Homeowner_check_payment_amount__c = 2000);
        insert oChange;
        Test.startTest();
        String accoutDetail = JSON.serialize(acc);
        String accoutDetail1 = JSON.serialize(acc1);
        String accoutRoleDetail = JSON.serialize(aRole);
        HH_CreateUpdateAccountRoleCtrl.searchAccountRole('Contr');
        HH_CreateUpdateAccountRoleCtrl.saveDetails(hhApp.Id,accoutDetail,accoutRoleDetail);
        HH_CreateUpdateAccountRoleCtrl.saveDetails(hhProj.Id,accoutDetail1,accoutRoleDetail);
        HH_CreateUpdateAccountRoleCtrl.getDetails(hhApp.Id,aRole.Id);
        HH_CreateUpdateAccountRoleCtrl.getDetails(hhProj.Id,aRole.Id);
        Test.stopTest();
}
}