/**
 * Created by ricky on 09-12-2021.
 */

trigger EmailMessageTrigger on EmailMessage (before insert) {
    Map<String, Object> triggerConfigMap = new TriggerHandler().instantiateApplicationHandlerClass('EmailMessage');
    if(triggerConfigMap.get('SkipExecutionFlag') == true) return;
    for(String classToInstantiateStrings : (List<String>) triggerConfigMap.get('ApplicationTriggerHandlers')) {
        try {
            System.debug('----'+classToInstantiateStrings);
            Type dynamicTriggerHandler = (Type) Type.forName(classToInstantiateStrings);
            TriggerInterface triggerHandlerInstance = (TriggerInterface) dynamicTriggerHandler.newInstance();
            triggerHandlerInstance.run();
        } catch(System.TypeException te) {
            throw new CustomExceptionController.NoApplicationTriggerException('EmailMessage Trigger is not configured');
        } catch(System.NullPointerException ne) {
            throw new CustomExceptionController.NoApplicationTriggerException('Class Name is not defined in Metadata');
        }
    }
}