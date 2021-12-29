public class ServiceUtility {
    
    public static Database.SaveResult logMessage(String className, String methodName, 
                                                 String exceptionMessage, String stackTrace,
                                                 String programName) {
        
        Exception_Log__c exceptionLog = new Exception_Log__c();
        exceptionLog.Type__c = 'Apex Handled Exception';
        exceptionLog.Class_Name__c = className;
        exceptionLog.Method_Name__c = methodName;
        exceptionLog.Message__c = exceptionMessage;
        exceptionLog.Exception_Date__c = Datetime.now();
        exceptionLog.Stack_Trace__c = stackTrace;
        exceptionLog.Program__c = programName;
        exceptionLog.User__c = UserInfo.getUserId();
        
        return Database.insert(exceptionLog, false);
    }

}