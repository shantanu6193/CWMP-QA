global class MARS_FEMAUpdateRate_Batch implements Database.Batchable<sobject> {
    Map<Id,FEMA_Code_LineItem__c> IdFEMALineItemMapBatch = new Map<Id,FEMA_Code_LineItem__c>();
    global MARS_FEMAUpdateRate_Batch(Map<Id,FEMA_Code_LineItem__c> IdFEMALineItemMap) {
        IdFEMALineItemMapBatch = IdFEMALineItemMap;
    } 
 
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator([SELECT Id, Current_Rate__c, Name From FEMA_Code_LineItem__c where Id IN:IdFEMALineItemMapBatch.keySet()]);
    }
    global void execute(Database.BatchableContext BC, List<FEMA_Code_LineItem__c> scope) {
        Map<String,FEMA_Code_LineItem__c> FEMACodeLineItemMap = new Map<String,FEMA_Code_LineItem__c>();
        for(FEMA_Code_LineItem__c cfaaRecord : scope)
        {    
            FEMACodeLineItemMap.put(cfaaRecord.Name,cfaaRecord);
        }
        Set<String> specialEqupIds = new Set<String>();
        Map<String,List<Agency_Special_Equipment_Line_Item__c>> specialEquipToLineItemMap = new Map<String,List<Agency_Special_Equipment_Line_Item__c>>();
        List<Agency_Special_Equipment_Line_Item__c> specialEqupLineItem = new List<Agency_Special_Equipment_Line_Item__c>();
        List<Agency_Special_Equipment_Line_Item__c> specialEqupLineItemList = [SELECT Id,Current_Rate__c, Revised_Rate__c,FEMA_CODE__c,Agency_Special_Equipment__c FROM Agency_Special_Equipment_Line_Item__c WHERE Status__c = 'Active' AND FEMA_CODE__c IN:FEMACodeLineItemMap.keySet()];
        for(Agency_Special_Equipment_Line_Item__c record : specialEqupLineItemList)
        {   
            if(specialEquipToLineItemMap.get(record.Agency_Special_Equipment__c) == null) {
                specialEquipToLineItemMap.put(record.Agency_Special_Equipment__c, new List<Agency_Special_Equipment_Line_Item__c>());
            }
            specialEquipToLineItemMap.get(record.Agency_Special_Equipment__c).add(record);
            specialEqupIds.add(record.Agency_Special_Equipment__c);
           /*if(FEMACodeLineItemMap.containsKey(record.FEMA_CODE__c)) {
                record.Current_Rate__c = FEMACodeLineItemMap.get(record.FEMA_CODE__c).Current_Rate__c;
                //record.Revised_Rate__c = FEMACodeLineItemMap.get(record.FEMA_CODE__c).Current_Rate__c;
                specialEqupLineItem.add(record);
           }*/
        }
        System.debug('specialEqupIds=='+specialEquipToLineItemMap);
        Map<Id, List<Agency_Special_Equipment_Line_Item__c>> specialEqupWithLineItems = new Map<Id, List<Agency_Special_Equipment_Line_Item__c>>();
        String status='';
        List<Agency_Special_Equipment__c> updateAgencySpecialEqup = new List<Agency_Special_Equipment__c>();
        List<Agency_Special_Equipment__c> insertAgencySpecialEqup = new List<Agency_Special_Equipment__c>();
        for (Agency_Special_Equipment__c assc :[ SELECT Id, Approval_Status__c,Agency__c, Start_Date__c, END_Date__c,Revised_From_Id__c,
                                                (SELECT Id,Current_Rate__c, Effective_Date__c,Revised_Rate__c,Special_Equipment_Type__c,FEMA_CODE__c FROM Agency_Special_Equipment_Line_Items__r)
                                                FROM Agency_Special_Equipment__c WHERE Id =: specialEquipToLineItemMap.keySet()]) {
                specialEqupWithLineItems.put(assc.id, assc.Agency_Special_Equipment_Line_Items__r);
                Agency_Special_Equipment__c aupdate = new Agency_Special_Equipment__c();
                aupdate.Id = assc.Id;
                aupdate.END_Date__c = System.today().addDays(-1);
                if(assc.Start_Date__c > System.today()) {
                    status='Revised'; 
                }else{
                    status='Expired'; 
                }
                aupdate.Approval_Status__c = status;

                updateAgencySpecialEqup.add(aupdate);
                // Inserting new Parent
                Agency_Special_Equipment__c ainsert = new Agency_Special_Equipment__c();
                ainsert.Name = 'Special Equipment ' + system.now().format();
                ainsert.Agency__c = assc.Agency__c;
                ainsert.Revised_From_Id__c = assc.Id;
                ainsert.Start_Date__c = assc.Start_Date__c;
                ainsert.Approval_Status__c = assc.Approval_Status__c;
                insertAgencySpecialEqup.add(ainsert);
            }
        
        if (insertAgencySpecialEqup.size() > 0) {
            insert insertAgencySpecialEqup;
            Map<Id, Id> oldwithNewId = new Map<Id, Id>();
            List<Agency_Special_Equipment__c> finalAgencySpecialEqup = new List<Agency_Special_Equipment__c>();
            for (Agency_Special_Equipment__c ass : insertAgencySpecialEqup) {
                //ass.Approval_Status__c = 'Pending Review';
                finalAgencySpecialEqup.add(ass);
                oldwithNewId.put(ass.Revised_From_Id__c, ass.Id);
            }
            List<Agency_Special_Equipment_Line_Item__c> insertLineItems = new List<Agency_Special_Equipment_Line_Item__c>();
            List<Agency_Special_Equipment_Line_Item__c> oldLineItems = new List<Agency_Special_Equipment_Line_Item__c>();
            for (Id parentOldSurvey : specialEqupWithLineItems.keySet()) {
                if (oldwithNewId.containsKey(parentOldSurvey)) {
                    for(Agency_Special_Equipment_Line_Item__c ssl : specialEqupWithLineItems.get(parentOldSurvey)) {
                        Agency_Special_Equipment_Line_Item__c newLineItem = ssl.clone(false, false, false, false);
                        ssl.Status__c = status;
                        if(FEMACodeLineItemMap.containsKey(ssl.FEMA_CODE__c) && FEMACodeLineItemMap.get(newLineItem.FEMA_CODE__c).Current_Rate__c != null) {
                            newLineItem.Current_Rate__c = FEMACodeLineItemMap.get(newLineItem.FEMA_CODE__c).Current_Rate__c;
                            newLineItem.Revised_Rate__c = FEMACodeLineItemMap.get(newLineItem.FEMA_CODE__c).Current_Rate__c;
                        }
                        oldLineItems.add(ssl);
                        newLineItem.Agency_Special_Equipment__c = oldwithNewId.get(parentOldSurvey);
                        System.debug(' New Record=='+newLineItem);
                        insertLineItems.add(newLineItem);
                    }
                }
            }
            try {
                insert insertLineItems;
                update oldLineItems;
                update finalAgencySpecialEqup;
                update updateAgencySpecialEqup;
            } catch (exception e) {
                system.debug('-------------' + e.getMessage());
            }
        }
        //update specialEqupLineItem;
    }
    global void finish(Database.BatchableContext BC)
    {
    }
}