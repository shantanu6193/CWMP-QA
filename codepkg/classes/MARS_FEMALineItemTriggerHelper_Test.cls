@isTest
private class MARS_FEMALineItemTriggerHelper_Test {
    @isTest
    static void testUpate(){
		FEMA_Code__c  femaRecord = new FEMA_Code__c();
        femaRecord.Effective_Date__c  = DateTime.Now().AddDays(-3).date();
        femaRecord.Status__c = 'Active';
        insert femaRecord;
        FEMA_Code_LineItem__c femalineItem = new FEMA_Code_LineItem__c();
        femalineItem.Current_Rate__c = 24.75;
        femalineItem.Name = '8089';
        femalineItem.FEMA_Code__c = femaRecord.Id;
        insert femalineItem;
        femalineItem.Current_Rate__c =30.75;
        update femalineItem;
    } 
}