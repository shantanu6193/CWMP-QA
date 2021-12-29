public without sharing class HMA_WorkScheduleLineItemTriggerHandler extends TriggerHandler implements TriggerInterface {
    public HMA_WorkScheduleLineItemTriggerHandler() {

    }
    public override void beforeTrigger() {
    }

    public override void beforeInsert() {
        
    } 
    public override void afterInsert() {
        Set<Id> workScheduleIds = new Set<Id>();
        for(Work_Schedule_Line_Item__c wsli : (List<Work_Schedule_Line_Item__c>) Trigger.New) {  
            if(String.isNotEmpty(wsli.Work_Schedule__c)) {
                workScheduleIds.add(wsli.Work_Schedule__c);
            }            
        }
        System.debug('workScheduleIds : '+ workScheduleIds);
        if(workScheduleIds.size() > 0) {
            HMA_WorkScheduleLineItemTriggerHandler.calculateWorkSchedulePlanDuration(workScheduleIds);       
        }
    }
    public override void beforeUpdate() {
        
    } 
    public override void afterUpdate() {
        Set<Id> workScheduleIds = new Set<Id>();
        for(Work_Schedule_Line_Item__c wsli : (List<Work_Schedule_Line_Item__c>) Trigger.New) {  
            if(String.isNotEmpty(wsli.Work_Schedule__c)) {
                workScheduleIds.add(wsli.Work_Schedule__c);
            }            
        }
        System.debug('workScheduleIds : '+ workScheduleIds);
        if(workScheduleIds.size() > 0) {
            HMA_WorkScheduleLineItemTriggerHandler.calculateWorkSchedulePlanDuration(workScheduleIds);       
        }
    }

    public static void calculateWorkSchedulePlanDuration(Set<Id> workScheduleIds) {
        Map<Id, List<Work_Schedule_Line_Item__c>> wsIdToWsliMap = new Map<Id, List<Work_Schedule_Line_Item__c>>();
        Map<Id, Integer> wsIdToTotalDurationMap = new Map<Id, Integer>();
        List<Work_Schedule__c> wsToUpdate = new List<Work_Schedule__c>();

        List<Work_Schedule_Line_Item__c>  relatedWsli = [SELECT Id, Work_Schedule__c, Start_Month__c, Duration_Months__c FROM Work_Schedule_Line_Item__c WHERE Work_Schedule__c IN: workScheduleIds];
        System.debug('relatedWsli : ' + relatedWsli);
        for(Work_Schedule_Line_Item__c wsliRec : relatedWsli) {
            if(wsIdToWsliMap.get(wsliRec.Work_Schedule__c) == null) {
                wsIdToWsliMap.put(wsliRec.Work_Schedule__c, new List<Work_Schedule_Line_Item__c>());
            }
            wsIdToWsliMap.get(wsliRec.Work_Schedule__c).add(wsliRec);
        }
        for(Id wsId : wsIdToWsliMap.keySet()) {
            List<Work_Schedule_Line_Item__c> wsliList = wsIdToWsliMap.get(wsId);
            Integer maxSum = 0;
            for(Work_Schedule_Line_Item__c wsli : wsliList) {
                System.debug('wsli : ' + wsli);
                Integer sum = HMA_WorkScheduleLineItemTriggerHandler.getIntegerFromString(wsli.Start_Month__c) + HMA_WorkScheduleLineItemTriggerHandler.getIntegerFromString(wsli.Duration_Months__c);
                if(sum > maxSum) {
                    maxSum = sum;
                }
            }
            maxSum = maxSum + 3;       // Adding Closeout Row Duration Values & Closeout Duration is fixed
            wsIdToTotalDurationMap.put(wsId, maxSum);
        }
        System.debug('wsIdToTotalDurationMap : ' + wsIdToTotalDurationMap);
        List<Work_Schedule__c> wsList = [SELECT Id, Application__c, Project_Plan_Duration_In_Months__c FROM Work_Schedule__c WHERE Id IN: wsIdToTotalDurationMap.keySet()];
        for(Work_Schedule__c ws : wsList) {
            ws.Project_Plan_Duration_In_Months__c = wsIdToTotalDurationMap.get(ws.Id);
            wsToUpdate.add(ws);
        }
        update wsToUpdate;
    }
    public static Integer getIntegerFromString(String value) {
        if(String.isNotEmpty(value)) {
            return Integer.valueOf(value);
        } else {
            return 0;
        }
    }
}