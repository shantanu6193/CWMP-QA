public inherited sharing class TriggerAction {
    public interface BeforeInsert {
        void beforeInsert(List<SObject> newList);
    }

    public interface AfterInsert {
        void afterInsert(List<SObject> newList);
    }
}