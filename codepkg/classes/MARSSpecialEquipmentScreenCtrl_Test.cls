@isTest
private class MARSSpecialEquipmentScreenCtrl_Test {
    @isTest
    static void test(){
        Account testAccount = MARS_TestHelper.getAccount(true);
        Agency_Special_Equipment_Line_Item__c agenSpeEquipLI = new Agency_Special_Equipment_Line_Item__c();
        agenSpeEquipLI.Special_Equipment_Type__c = 'testAgenSpeEquip';
        agenSpeEquipLI.Description__c = 'test';
        agenSpeEquipLI.FEMA_CODE__c = '1234';
        agenSpeEquipLI.Revised_Rate__c = 10;
        List<Agency_Special_Equipment_Line_Item__c> lineItemsForUpdateList = new List<Agency_Special_Equipment_Line_Item__c>();
        lineItemsForUpdateList.add(agenSpeEquipLI);
        String data = JSON.serialize(lineItemsForUpdateList);
        String effDate = String.valueOf(Date.today());
        String searchTerm = 'testFEMACodeLI';
        List<String> salId = new List<String>{'', ''};
        MARSSpecialEquipmentScreenCtrl.getSpecialEquipmentLatest(testAccount.Id);
        //MARSSpecialEquipmentScreenCtrl.getSpecialEquipmentLineItems(agenSpecEqp.Id);
        MARSSpecialEquipmentScreenCtrl.getData(testAccount.Id);
        MARSSpecialEquipmentScreenCtrl.apexSearchFemaCode(searchTerm, salId);
        MARSSpecialEquipmentScreenCtrl.submitSpecEquipLines(data, testAccount.Id, effDate, 'test');
    }
    @isTest
    static void test1(){
        Account testAccount = MARS_TestHelper.getAccount(true);
        Agency_Special_Equipment__c agenSpeEquip = new Agency_Special_Equipment__c();
        agenSpeEquip.Name = 'testAgenSpeEquip';
        agenSpeEquip.Agency__c = testAccount.Id;
        agenSpeEquip.Approval_Status__c = 'Pending Review';
        agenSpeEquip.Start_Date__c = Date.today();
        agenSpeEquip.End_Date__c = Date.today().addDays(10);
        agenSpeEquip.Reject_Reason__c = 'test';
        insert agenSpeEquip;
        
        Agency_Special_Equipment_Line_Item__c agenSpeEquipLI = new Agency_Special_Equipment_Line_Item__c();
        agenSpeEquipLI.Agency_Special_Equipment__c = agenSpeEquip.Id;
        agenSpeEquipLI.Special_Equipment_Type__c = 'testAgenSpeEquip';
        agenSpeEquipLI.Description__c = 'test';
        agenSpeEquipLI.FEMA_CODE__c = '1234';
        agenSpeEquipLI.Revised_Rate__c = 10;
        insert agenSpeEquipLI;
        MARSSpecialEquipmentScreenCtrl.getSpecialEquipmentLineItems(agenSpeEquip.Id);

    }
}