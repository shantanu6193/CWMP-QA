@isTest(seeAllData=true)
public without sharing class HMA_TestMetadataHelper {
    public static Program_Template_Page__mdt getProgramTemplatePageMdt(String developerName) {
        Program_Template_Page__mdt programTemplatePage = [SELECT Id, DeveloperName, Program_Template__c, Active__c 
                                                            FROM Program_Template_Page__mdt WHERE DeveloperName = : developerName];
        return programTemplatePage;
    }
    public static Page_Layout__mdt getPageLayoutMdt(String developerName) {
        Page_Layout__mdt pageLayoutMdt = [SELECT Id, DeveloperName FROM Page_Layout__mdt WHERE DeveloperName =: developerName];
        return pageLayoutMdt;
    }

    public static Page_Field__mdt getPageFieldMdt(String developerName) {
        Page_Field__mdt pageFieldMdt = [SELECT Id, DeveloperName FROM Page_Field__mdt WHERE DeveloperName =: developerName];
        return pageFieldMdt;
    }

    public static Key_Value_Store__mdt getKeyValue(String developerName) {
        Key_Value_Store__mdt keyValue = [SELECT Id, DeveloperName, Text_Value__c FROM Key_Value_Store__mdt WHERE DeveloperName = :developerName];
        return keyValue;
    }
}