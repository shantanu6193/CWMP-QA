trigger Contact_Role_Trigger on Contact_Role__c (before insert, after insert) {
    Map<String, Object> triggerConfigMap = new TriggerHandler().instantiateApplicationHandlerClass('Contact_Role__c');
    if(triggerConfigMap.get('SkipExecutionFlag') == true) return;
    for(String classToInstantiateStrings : (List<String>) triggerConfigMap.get('ApplicationTriggerHandlers')) {
        try {
            System.debug('----'+classToInstantiateStrings);
            Type dynamicTriggerHandler = (Type) Type.forName(classToInstantiateStrings);
            TriggerInterface triggerHandlerInstance = (TriggerInterface) dynamicTriggerHandler.newInstance();
            triggerHandlerInstance.run();
        } catch(System.TypeException te) {
            throw new CustomExceptionController.NoApplicationTriggerException('Application Trigger is not configured');
        } catch(System.NullpointerException ne) {
            System.debug('Contact_Role_Trigger Exception from trigger--'+ne.getStackTraceString());
            throw new CustomExceptionController.NoApplicationTriggerException('Class Name is not defined in Metadata');
        }
    }
}