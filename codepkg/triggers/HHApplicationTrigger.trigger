trigger HHApplicationTrigger on HH_Application__c (before insert, after insert, before update, after update, before delete) { 
	Map<String, Object> triggerConfigMap = new TriggerHandler().instantiateApplicationHandlerClass('HH_Application__c');
	if(triggerConfigMap.get('SkipExecutionFlag') == true) return;
	for(String classToInstantiateStrings : (List<String>) triggerConfigMap.get('ApplicationTriggerHandlers')) {
			try {
					System.debug('----'+classToInstantiateStrings);
					Type dynamicTriggerHandler = (Type) Type.forName(classToInstantiateStrings);
					TriggerInterface triggerHandlerInstance = (TriggerInterface) dynamicTriggerHandler.newInstance();
					triggerHandlerInstance.run();
			} catch(System.TypeException te) {
					throw new CustomExceptionController.NoApplicationTriggerException('HH_Application__c Trigger is not configured');
			} catch(System.NullPointerException ne) {
					throw new CustomExceptionController.NoApplicationTriggerException('Class Name is not defined in Metadata');
			}
	}
}