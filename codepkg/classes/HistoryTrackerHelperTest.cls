@isTest public with sharing class HistoryTrackerHelperTest {
   @isTest public static void testProcessFieldTracking(){
      List<History_Tracker_Configuration__mdt> trackerConfigs = new List<History_Tracker_Configuration__mdt>();
      Pre_Application__c preApplication = HMA_TestHelper.getPreApplication(true);

      trackerConfigs = [ SELECT Id, Object_API_Name__c, (SELECT ID,Field_API_Name__c,Message_Field_API_Name__c From Related_Fields__r)
                           from History_Tracker_Configuration__mdt
                           Where Object_API_Name__c =:'Pre_Application__c'
                           ];

      preApplication.Status__c = 'Manager Review';
      update preApplication;
      trackerConfigs = [ SELECT Id, Object_API_Name__c, (SELECT ID,Field_API_Name__c,Message_Field_API_Name__c From Related_Fields__r)
                           from History_Tracker_Configuration__mdt
                           Where Object_API_Name__c =:'Pre_Application__c'
                           ];

      HistoryTrackerHelper.getFormattedNumber(10, 10, true);
   }

}