/**
 * Created by Ricky on 10-08-2021.
 */

trigger ContactTrigger on Contact (before insert, before update) {
    Map<String, Object> triggerConfigMap = new TriggerHandler().instantiateApplicationHandlerClass('Contact');
    if(triggerConfigMap.get('SkipExecutionFlag') == true) return;
    for(String classToInstantiateStrings : (List<String>) triggerConfigMap.get('ApplicationTriggerHandlers')) {
        try {
            System.debug('----'+classToInstantiateStrings);
            Type dynamicTriggerHandler = (Type) Type.forName(classToInstantiateStrings);
            TriggerInterface triggerHandlerInstance = (TriggerInterface) dynamicTriggerHandler.newInstance();
            triggerHandlerInstance.run();
        } catch(System.TypeException te) {
            throw new CustomExceptionController.NoApplicationTriggerException('Contact Trigger is not configured');
        } catch(System.NullPointerException ne) {
            throw new CustomExceptionController.NoApplicationTriggerException('Class Name is not defined in Metadata');
        }
    }
}