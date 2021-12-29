@isTest
private class MARS_SpecialEquipmentHistoryCtrl_Test {
	@isTest
    static void createRecData(){
        Account acc = new Account();
        acc.Name = 'test';
        insert acc;
        
        Agency_Special_Equipment__c ase = new Agency_Special_Equipment__c();
        ase.Agency__c = acc.Id;
        ase.Start_Date__c = System.today();
        ase.End_Date__c = System.today().addDays(10);
        ase.Approval_Status__c = 'Reviewed';
        insert ase;
        
        Agency_Special_Equipment_Line_Item__c aseLineItem = new Agency_Special_Equipment_Line_Item__c();
        aseLineItem.Agency_Special_Equipment__c = ase.Id;
        insert aseLineItem;
        
        MARS_SpecialEquipmentHistoryCtrl.getAgencySpecialEquipHistory(acc.Id);
        MARS_SpecialEquipmentHistoryCtrl.getAgencySpecialEquipLineItems(ase.Id);
        MARS_SpecialEquipmentHistoryCtrl.getData(ase.Id);
    }
    
}