trigger HMAApplicationExtensionTrigger on Application_Extension__c (before insert, after insert, before update, after update) {
    new HMA_ApplicationExtensionTriggerCtrl().process();
    /*
    Map<String, Object> triggerConfigMap= new TriggerHandler().instantiateApplicationHandlerClass('Application_Extension__c');
    if(triggerConfigMap?.get('SkipExecutionFlag')==true)
        return;
    // @todo - @rakesh This should be a method in the facilitator class
    
    for(String classToInstantiateStrings : (List<String>)triggerConfigMap.get('ApplicationTriggerHandlers')) {
        try {
            // System.assertEquals('HMAAccountTriggerHandler',classToInstantiateStrings);
            Type dynamicTriggerHandler = (Type) Type.forName(classToInstantiateStrings);
            TriggerInterface triggerHandlerInstance = (TriggerInterface)dynamicTriggerHandler.newInstance();
            triggerHandlerInstance.run();

        } catch(System.TypeException te) {
            throw new CustomExceptionController.NoApplicationTriggerException('Application Trigger is not Configured');
        } catch(System.NullpointerException ne) {
            throw new CustomExceptionController.NoApplicationTriggerException('Class Name is not defined in Metadata');
        }
    }*/
}