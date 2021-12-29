public inherited sharing virtual class TriggerHandler {

    private static final String HANDLER_OUTSIDE_TRIGGER_MESSAGE = 'Trigger handler called outside of Trigger execution';
    public static Map<Id, Boolean> processedRecordMap;
    public static Boolean skipFieldHistoryTrigger = false;

    //
    static {
        processedRecordMap = new Map<Id, Boolean>();
    }
    public TriggerHandler() {

    }
    
    public void run() {
        if(!validateRun()) return;
        //Extra code, need to remove this extra if condition as we already had it in trigger itself.
        if(Trigger.isBefore) {
            this.beforeTrigger();
        }
        if(Trigger.isAfter) {
            if(skipFieldHistoryTrigger == false) {
                HistoryTrackerHelper.processFieldTracking();
                skipFieldHistoryTrigger = true;
            }
        }
        switch on this.context {
            when 'BEFORE_INSERT' {
                this.beforeInsert();
            }
            when 'AFTER_INSERT' {
                this.afterInsert();
            }
            when 'BEFORE_UPDATE' {
                this.beforeUpdate();
            }
            when 'AFTER_UPDATE' {
                this.afterUpdate();
            }
            when 'BEFORE_DELETE' {
                this.beforeDelete();
            }
            when 'AFTER_DELETE' {
                this.afterDelete();
            }
            when 'AFTER_UNDELETE' {
                this.afterUndelete();
            }
            when else {
                //if required in future
            }
        }
    }

    public static Boolean shouldExecute(SObject rec) {
        if(!processedRecordMap.containsKey(rec.Id)) {
            processedRecordMap.put(rec.Id, true);
            return true;
        } else {
            return false;
        }
    }

    // @todo @Rakesh please add comments here.
    private Boolean validateRun() {
        if(!Trigger.isExecuting && this.context == null) throw new TriggerHandlerException(HANDLER_OUTSIDE_TRIGGER_MESSAGE);
        return true;
    }

    // If True is returned in the flag(SkipExecutionFlag) : No further Execution, If Flag is False : List of Classes to be instantiated are returned
    public Map<String, Object> instantiateApplicationHandlerClass(String sobjectName) {
        Map<String, Object> returnMap = new Map<String, Object>();

        //Fetch the map data @todo fetch only that data which is required for processing.
        Map<String, Object> metadataConfigMap = MetadataUtility.fetchAllMetadataTypes(sobjectName);

        //Get all the Object Level Trigger Configuration
        List<SObject__mdt> objectTriggerConfigs = ((List<SObject__mdt>) metadataConfigMap.get('SobjectConfig'));
        if(objectTriggerConfigs.size() > 0 && objectTriggerConfigs[0].Skip_Validation_Rules__c) {
            returnMap.put('SkipValidationRules', true);
        }
        if(isTriggerByPassedAtAnyLevel(objectTriggerConfigs)) {
            returnMap.put('SkipExecutionFlag', true);
        } else {
            returnMap.put('SkipExecutionFlag', false);
            returnMap.put('ApplicationTriggerHandlers', objectTriggerConfigs[0].Applicable_Trigger_Handlers__c.split(';'));
        }
        // Get all the validation rules to map
        if(metadataConfigMap.containsKey('ValidationRuleConfigs')) {
            returnMap.put('ValidationRuleConfigs', (List<Validation_Rule_Config__mdt>) metadataConfigMap.get('ValidationRuleConfigs'));
        }
        

        return returnMap;
    }



    //Skips Trigger - if no Triggers are Configured for the Specified Object OR Trigger is Skipped through Meta data OR  Application Specific handlers are not configured
    private Boolean isTriggerByPassedAtAnyLevel(List<SObject__mdt> sobjectConfigs) {
        if(sobjectConfigs.size() <= 0) return true;
        if(sobjectConfigs[0].Bypass_Trigger_Execution__c) return true;
        if(String.isBlank(sobjectConfigs[0].Applicable_Trigger_Handlers__c)) return true;
        return false;
    }


    private String context {
        get {
            if(context == null) context = Trigger.operationType.name();
            return context;
        }
        set;
    }

    //Currently not using this property
    private List<SObject> triggerNew {
        get {
            if(triggerNew == null) triggerNew = Trigger.New;
            return triggerNew;
        }
        set;
    }

    //Context specific method for overriding
    protected virtual void beforeTrigger() {

    }
    protected virtual void beforeInsert() {

    }
    protected virtual void afterInsert() {
        
    }
    protected virtual void beforeUpdate() {
        
    }
    protected virtual void afterUpdate() {
        
    }
    protected virtual void beforeDelete() {

    }
    protected virtual void afterDelete() {

    }
    protected virtual void afterUndelete() {

    }

    private class TriggerHandlerException extends Exception {}
}