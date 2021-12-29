public inherited sharing virtual class TriggerBase {
    private static final String HANDLER_OUTSIDE_TRIGGER_MESSAGE = 'Trigger handler called outside of Trigger execution';
    public static Set<String> byPassedObjects;
    public static Set<Id> idsProcessedBeforeUpdate { get; private set; }
    public static Set<Id> idsProcessedAfterUpdate { get; private set; }

    static {
        byPassedObjects = new Set<String>();
        idsProcessedBeforeUpdate = new Set<Id>();
        idsProcessedAfterUpdate = new Set<Id>();
    }

    public TriggerBase() {

    }

    public void run() {
        if(!validateRun()) return;
        if(this.context == System.TriggerOperation.BEFORE_INSERT && this instanceof TriggerAction.BeforeInsert) {
            try{
                ((TriggerAction.BeforeInsert) this).beforeInsert(triggerNew);
            } catch(Exception e) {
                for(SObject obj : triggerNew) {
                    obj.addError(e.getMessage());
                }
            }
        } 
        // else if(this.context == System.TriggerOperation.AFTER_INSERT && this instanceof TriggerAction.AfterInsert) {
        //     try{
        //         ((TriggerAction.AfterInsert) this).afterInsert(triggerNew);
        //     } catch(Exception e) {
        //         for(SObject obj : triggerNew) {
        //             obj.addError(e.getMessage());
        //         }
        //     }
        // }
    }

    public static void bypass(String sObjectName) {
        TriggerBase.byPassedObjects.add(sObjectName);
    }

    public static void clearBypass(String sObjectName) {
        TriggerBase.byPassedObjects.remove(sObjectName);
    }

    public static Boolean isBypassed(String sObjectName) {
        return TriggerBase.byPassedObjects.contains(sObjectName);
    }

    public static void clearAllBypass() {
        TriggerBase.byPassedObjects.clear();
    }


    private Boolean validateRun() {
        if(!Trigger.isExecuting && this.context == null) throw new TriggerBaseException(HANDLER_OUTSIDE_TRIGGER_MESSAGE);
        if(TriggerBase.byPassedObjects.contains(this.sObjectName)) return false;
        return true;
    }

    protected String sObjectName {
        get {
            if(sObjectName == null) {
                if(this.triggerNew != null) {
                    sObjectName = this.triggerNew[0].getSObjectType().getDescribe().getName();
                } else {
                    sObjectName = this.triggerOld[0].getSObjectType().getDescribe().getName();
                }
            }
            return sObjectName;
        }
        private set;
    }

    private System.TriggerOperation context {
        get {
            if(context == null) context = Trigger.operationType;
            return context;
        }
        set;
    }

    protected List<SObject> triggerNew {
        get {
            if(triggerNew == null) triggerNew = Trigger.new;
            return triggerNew;
        }
        private set;
    }

    protected List<SObject> triggerOld {
        get {
            if(triggerOld == null) triggerOld = Trigger.old;
            return triggerOld;
        }   
        private set;
    }

    public class TriggerBaseException extends Exception {

    }
}