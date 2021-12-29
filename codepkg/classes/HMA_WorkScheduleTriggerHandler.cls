public without sharing class HMA_WorkScheduleTriggerHandler extends TriggerHandler implements TriggerInterface {
    public HMA_WorkScheduleTriggerHandler() {

    }
    public override void beforeTrigger() {
    }

    public override void beforeInsert() {
        
    } 
    public override void afterInsert() {
        
    }
    public override void beforeUpdate() {
        checkProjectPlanDuration();             // This method used for Displaing error message when Project/Plan Duration exceed 36 months.
    } 
    public override void afterUpdate() {

    }

    public static void checkProjectPlanDuration() {
        for(Work_Schedule__c ws : (List<Work_Schedule__c>) Trigger.New) {
            if(ws.Project_Plan_Duration_In_Months__c > 36) {
                ws.addError('Project/Plan Duration should not exceed 36 months. ');
            }
        }
    }
}