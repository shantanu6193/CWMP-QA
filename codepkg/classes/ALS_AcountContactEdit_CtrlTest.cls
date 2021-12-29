@isTest
    public with sharing class ALS_AcountContactEdit_CtrlTest {
    @isTest
    public static void testALS_AcountContactEdit_CtrlMethod1() {
        Account acc = new Account(Name='test12f', Entity_Type__c=ALS_CONSTANTS.Account_EntityType_City);
        insert acc;
        Contact con =new Contact(LastName='Test con', AccountId=acc.Id );
        insert con;
        AccountContactRole__c accCon = new AccountContactRole__c(Account_Name__c=acc.Id,Contact_Name__c=con.Id);
        insert accCon;

        String ContactDetail2 =JSON.serialize(con);
        String accountContac2 =JSON.serialize(accCon);
        Boolean isEdit2 =TRUE;
        Boolean isContact2 =TRUE;
        String ContactDetail3='Test';

        ALS_AcountContactEdit_Ctrl.saveDetails(ContactDetail2,accountContac2,isContact2,isEdit2,acc.Id);
        Boolean isEdit3 =FALSE;
        Boolean isContact3 =FALSE;

       test.startTest();
        try{
             ALS_AcountContactEdit_Ctrl.saveDetails(ContactDetail2,accountContac2,isContact3,isEdit3,acc.Id);
        }
        catch(exception e)
        {
            System.assert(e.getMessage().contains('Script-thrown exception'));
        }
        Boolean isContact5 =TRUE;
        try
        {
            ALS_AcountContactEdit_Ctrl.saveDetails(ContactDetail2,accountContac2,isContact5,isEdit3,acc.Id);
        }
        catch(exception e)
        {
            System.assert(e.getMessage().contains('Script-thrown exception'));
        }
        String ContactDetail =null;
        String accountContac =null;
        try
        {
            ALS_AcountContactEdit_Ctrl.saveDetails(ContactDetail,accountContac,isContact5,isEdit3,acc.Id);
        }
        catch(exception e)
        {
            System.assert(e.getMessage().contains('Script-thrown exception'));
        }

        ALS_AcountContactEdit_Ctrl.getDetails(accCon.Id);
        test.stopTest();
    }
}