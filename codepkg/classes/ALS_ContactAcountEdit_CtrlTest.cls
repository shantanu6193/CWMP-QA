@isTest
public with sharing class ALS_ContactAcountEdit_CtrlTest {
    @isTest
    public static void testALS_ContactAcountEdit_CtrlMethod1() {
        Account acc = new Account(Name='test12f', Entity_Type__c=ALS_CONSTANTS.Account_EntityType_City);
        insert acc;
        Contact con =new Contact(LastName='Test con', AccountId=acc.Id );
        insert con;
        AccountContactRole__c accCon = new AccountContactRole__c(Account_Name__c=acc.Id,Contact_Name__c=con.Id);
        insert accCon;

        String accountDetail2 =JSON.serialize(acc);
        String accountContac2 =JSON.serialize(accCon);
        String contactIds =con.Id;
        Boolean isEdit2 =TRUE;
        Boolean isAccount2 =TRUE;
        String accountDetail3 =null;
        String accountContac3 =null;
        Boolean isAccount3 =TRUE;
        Boolean isEdit3 =FALSE;

        test.startTest();
            try{
            ALS_ContactAcountEdit_Ctrl.saveDetails(accountDetail2,accountContac2 ,isAccount2,isEdit2,contactIds);
            }
            catch(exception e)
            {
            System.assert(e.getMessage().contains('Script-thrown exception'));
            }

            try{
            ALS_ContactAcountEdit_Ctrl.saveDetails(accountDetail2,accountContac2 ,isAccount2,isEdit3,contactIds);
            }
            catch(exception e)
            {
            System.assert(e.getMessage().contains('Script-thrown exception'));
            }

            try{
            ALS_ContactAcountEdit_Ctrl.saveDetails(accountDetail2,accountContac2 ,isAccount3,isEdit3,contactIds);
            }
            catch(exception e)
            {
            System.assert(e.getMessage().contains('Script-thrown exception'));
            }

            ALS_ContactAcountEdit_Ctrl.getDetails(accCon.Id);
        test.stopTest();
    }
}