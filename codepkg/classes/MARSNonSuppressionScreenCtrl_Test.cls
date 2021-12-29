@isTest
private class MARSNonSuppressionScreenCtrl_Test {
    @isTest
    static void test(){
        Account testAccount = MARS_TestHelper.getAccount(true);
        Agency_Non_Suppression_Line_Item__c agenNONSuppPerLI = new Agency_Non_Suppression_Line_Item__c();
        agenNONSuppPerLI.Classification_Title__c = 'testAgenNONSuppPerLI';
        agenNONSuppPerLI.Revised_Rate__c = 20.0;
        agenNONSuppPerLI.Current_Rate__c = 20.0;
        agenNONSuppPerLI.MOU_MOA_GBR__c = false;
        List<Agency_Non_Suppression_Line_Item__c> itemList = new List<Agency_Non_Suppression_Line_Item__c>();
        itemList.add(agenNONSuppPerLI);
        String data = JSON.serialize(itemList);
        String effDate = String.valueOf(Date.today());
        MARSNonSuppressionScreenCtrl.getAgencyNonSuppressionLatest(testAccount.Id);
        MARSNonSuppressionScreenCtrl.getData(testAccount.Id);
        MARSNonSuppressionScreenCtrl.submitNonSuppLines(data, testAccount.Id, effDate, 'test');
    }
        @isTest
    static void test1(){
        Account testAccount = MARS_TestHelper.getAccount(true);
        Agency_Non_Suppression_Personnel__c agenNONSuppPer = new Agency_Non_Suppression_Personnel__c();
        agenNONSuppPer.Name = 'testAgenNonSuppPer';
        agenNONSuppPer.Agency__c = testAccount.Id;
        agenNONSuppPer.Approval_Status__c = 'Pending Review';
        agenNONSuppPer.Start_Date__c = Date.today();
        agenNONSuppPer.End_Date__c = Date.today().addDays(10);
        agenNONSuppPer.Reject_Reason__c = 'test';
        insert agenNONSuppPer;
        
        Agency_Non_Suppression_Line_Item__c agenNONSuppPerLI = new Agency_Non_Suppression_Line_Item__c();
        agenNONSuppPerLI.Agency_Non_Suppression_Personnel__c = agenNONSuppPer.Id;
        agenNONSuppPerLI.Classification_Title__c = 'testAgenNONSuppPerLI';
        agenNONSuppPerLI.Revised_Rate__c = 20.0;
        agenNONSuppPerLI.Current_Rate__c = 20.0;
        agenNONSuppPerLI.MOU_MOA_GBR__c = false;
        insert agenNONSuppPerLI;
        MARSNonSuppressionScreenCtrl.getAgencyNonSuppressionLineItems(agenNONSuppPer.Id);
    }

}