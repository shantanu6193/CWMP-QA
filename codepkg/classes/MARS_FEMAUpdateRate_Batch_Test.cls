@isTest
private class MARS_FEMAUpdateRate_Batch_Test {
    @isTest
    static void createRecData(){
        FEMA_Code_LineItem__c femaLI = new FEMA_Code_LineItem__c();
        femaLI.Name = 'test';
        femaLI.Current_Rate__c = 20.0;
        insert femaLI;
        
        Agency_Special_Equipment__c agenSpEqip = new Agency_Special_Equipment__c();
        agenSpEqip.Name = 'testAgenSpEqip';
        insert agenSpEqip;
        
        Agency_Special_Equipment_Line_Item__c agenSpEqipLI = new Agency_Special_Equipment_Line_Item__c();
        agenSpEqipLI.Agency_Special_Equipment__c = agenSpEqip.Id;
        agenSpEqipLI.Current_Rate__c = 20.0;
        agenSpEqipLI.Revised_Rate__c = 21;
        agenSpEqipLI.Status__c = 'Active';
        agenSpEqipLI.FEMA_CODE__c = 'test';
        insert agenSpEqipLI;
        
        Map<Id,FEMA_Code_LineItem__c> IdFEMALineItemMap = new Map<Id,FEMA_Code_LineItem__c>([SELECT Id, Name, Current_Rate__c FROM FEMA_Code_LineItem__c WHERE Name = 'test' LIMIT 1]);
        
        MARS_FEMAUpdateRate_Batch fub = new MARS_FEMAUpdateRate_Batch(IdFEMALineItemMap);
        Id jobId = Database.executeBatch(fub);
    }

}