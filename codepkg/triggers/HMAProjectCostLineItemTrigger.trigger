trigger HMAProjectCostLineItemTrigger on Project_Cost_Line_Item__c (before insert, after insert, after update, before delete) {
    Map<String, Object> triggerConfigMap= new TriggerHandler().instantiateApplicationHandlerClass('Project_Cost_Line_Item__c');
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
    }
}