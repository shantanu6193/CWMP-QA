/**
 * Created by ricky on 06-12-2021.
 */
@IsTest
public with sharing class HH_TaskTriggerHandlerTest {
    @TestSetup
    public static void taskTriggerHandlerSetUp() {
        HH_Application__c application = new HH_Application__c();
        application.Stage__c = HH_CONSTANTS.HHApplication_Stage_AssessmentDecision;
        application.Status__c = HH_CONSTANTS.HHApplication_Status_RejectedNotEligible;
        application.Assessor_Email__c = 'ashjkhasf@gmail.com';
        application.Tax_Parcel_Number__c = '234234';
        application.Is_the_property_in_the_floodplain__c = 'Yes';
        application.Assessed_Value_of_the_Property__c = 1200000;
        application.Income_Bracket__c = 'Less than 80%';
        insert application;
    }

    @IsTest
    public static void taskTriggerHandlertest() {
        HH_Application__c appl = [SELECT Id, Name FROM HH_Application__c];
        Task taskRecord = new Task(Subject = 'Call', WhatId = appl?.Id);
        insert taskRecord;
    }
}