/**
 * Created by hp on 14-09-2021.
 */

public with sharing class ExceptionLogController {

    @AuraEnabled
    public static void logErrorMessage(String className, String methodName,
                                                      String exceptionMessage, String stackTrace,
                                                      String programName) {
         ServiceUtility.logMessage(className, methodName,exceptionMessage, stackTrace, programName);
    }

}