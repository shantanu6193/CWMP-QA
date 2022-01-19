trigger OrderChangeTrigger on Order_Change__c (after insert, after update, after delete) {
        Map<String, Object> triggerConfigMap = new TriggerHandler().instantiateApplicationHandlerClass('Order_Change__c');
        if(triggerConfigMap.get('SkipExecutionFlag') == true) return;
        for(String classToInstantiateStrings : (List<String>) triggerConfigMap.get('ApplicationTriggerHandlers')) {
                try {
                        Type dynamicTriggerHandler = (Type) Type.forName(classToInstantiateStrings);
                        TriggerInterface triggerHandlerInstance = (TriggerInterface) dynamicTriggerHandler.newInstance();
                        triggerHandlerInstance.run();
                } catch(System.TypeException te) {
                        throw new CustomExceptionController.NoApplicationTriggerException('Order Change Trigger is not configured');
                } catch(System.NullpointerException ne) {
                        throw new CustomExceptionController.NoApplicationTriggerException('Class Name is not defined in Metadata');
                }
        }
}