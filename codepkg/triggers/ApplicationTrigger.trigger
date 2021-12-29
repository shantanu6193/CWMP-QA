trigger ApplicationTrigger on Application__c (before insert, after insert, before update, after update) {
    new HMA_ApplicationTriggerHandler().process();
    /*Map<String, Object> triggerConfigMap = new TriggerHandler().instantiateApplicationHandlerClass('Application__c');
    if(triggerConfigMap.get('SkipExecutionFlag') == true) return;
    // triggerConfigMap will only contain SkipValidationRules key value pair if Skip_Validation_Rule field is set to true
    //     Here, if SkipValidationRules is not present in map then run the validations class
    
    // if(!triggerConfigMap.containsKey('SkipValidationRules')) {
    //     System.debug('----'+triggerConfigMap.get('ValidationRuleConfigs'));
    //     ContactValidationRuleHandler contactValidation = new ContactValidationRuleHandler((List<Validation_Rule_Config__mdt>)triggerConfigMap.get('ValidationRuleConfigs'));
    //     if(Trigger.isBefore) {
    //         contactValidation.runCustomValidations((List<Contact>) Trigger.New);
    //     }
    // }
    for(String classToInstantiateStrings : (List<String>) triggerConfigMap.get('ApplicationTriggerHandlers')) {
        try {
            System.debug('----'+classToInstantiateStrings);
            Type dynamicTriggerHandler = (Type) Type.forName(classToInstantiateStrings);
            TriggerInterface triggerHandlerInstance = (TriggerInterface) dynamicTriggerHandler.newInstance();
            triggerHandlerInstance.run();
        } catch(System.TypeException te) {
            throw new CustomExceptionController.NoApplicationTriggerException('Application Trigger is not configured');
        } catch(System.NullpointerException ne) {
            throw new CustomExceptionController.NoApplicationTriggerException('Class Name is not defined in Metadata');
        }
    }*/
}