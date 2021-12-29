public with sharing class HMAApplicationTriggerHandler extends TriggerHandler implements TriggerInterface {
    //private ApplicationValidationRuleHandler validationRuleHandler;
    public HMAApplicationTriggerHandler() {
        
    }

    public override void beforeTrigger() {
        
        try{
           
        } catch(Exception e) {
            throw new CustomExceptionController.NoApplicationTriggerException(e);
        }
        
    }

    public override void beforeInsert() {
        for(Application__c app : (List<Application__c>) Trigger.New) {
            
        }
        
    } 
    public override void afterInsert() {
        if(Trigger.newMap.keySet().size() > 0) {
            ApplicationHelper.processToCreateWSAndWSLI(Trigger.newMap.keySet());
        }
    } 

    public override void afterUpdate() {
        Set<Id> appIds = new Set<Id>();
        for(Application__c app : (List<Application__c>) Trigger.New) {
            if(shouldExecute(app)) {
                Application__c oldApp = (Application__c) trigger.oldMap.get(app.Id);
                Application__c newApp = (Application__c) trigger.newMap.get(app.Id);
                if(oldApp.Application_Type__c != newApp.Application_Type__c) {
                    appIds.add(app.Id);
                }
            }
        }
        if(appIds.size() > 0) {
            //ApplicationHelper.processToCreateWSAndWSLI(appIds);  //-------Commented Create Work Schedule and Work Schedule Line Item call after Update Application 
        }        
    }
}