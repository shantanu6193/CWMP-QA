/**
 * Created by ricky on 30-11-2021.
 */

trigger TaskTrigger on Task (before insert) { 
    Map<String, Object> triggerConfigMap = new TriggerHandler().instantiateApplicationHandlerClass('Task');
    if(triggerConfigMap.get('SkipExecutionFlag') == true) return;
    for(String classToInstantiateStrings : (List<String>) triggerConfigMap.get('ApplicationTriggerHandlers')) {
        try {
            System.debug('----'+classToInstantiateStrings);
            Type dynamicTriggerHandler = (Type) Type.forName(classToInstantiateStrings);
            TriggerInterface triggerHandlerInstance = (TriggerInterface) dynamicTriggerHandler.newInstance();
            triggerHandlerInstance.run();
        } catch(System.TypeException te) {
            throw new CustomExceptionController.NoApplicationTriggerException('Task Trigger is not configured');
        } catch(System.NullPointerException ne) {
            throw new CustomExceptionController.NoApplicationTriggerException('Class Name is not defined in Metadata');
        }
    }
}