@isTest
public without sharing class PageTableControllerTest {
    @isTest public static void testGetTableRecordDetails() {
        Map<String, Object> returnMap = new Map<String, Object>();
        List<String> tableColumnNames = new List<String>();
        tableColumnNames.add('Task_Name__c');
        tableColumnNames.add('Description__c');
        tableColumnNames.add('Start_Month__c');
        tableColumnNames.add('Duration_Months__c');

        Application__c newApplication = HMA_TestHelper.getApplication(true, '', '', '');
        Work_Schedule__c ws = HMA_TestHelper.getWorkSchedule(true, newApplication.Id);
        Work_Schedule_Line_Item__c wsli = HMA_TestHelper.getWorkScheduleLineItem(true, ws.Id);
        String whereClause = 'Work_Schedule__r.Application__c=\'' + newApplication.Id+'\'  AND Work_Schedule__c= \'{parentRecordId}\'' ;
        String getParentRecordQuery = 'SELECT Id from Work_Schedule__c WHERE Application__c = \''+ newApplication.Id +'\' LIMIT 1';

        returnMap = PageTableController.getTableRecordDetails(tableColumnNames, 'Work_Schedule_Line_Item__c', '1', whereClause, getParentRecordQuery);
        System.assert(returnMap.size() > 0);
    }

    @isTest public static void testUpdateObjectDetails() {
        List<Work_Schedule_Line_Item__c> wsliList = new List<Work_Schedule_Line_Item__c>();

        Application__c newApplication = HMA_TestHelper.getApplication(true, '', '', '');
        Work_Schedule__c ws = HMA_TestHelper.getWorkSchedule(true, newApplication.Id);
        Work_Schedule_Line_Item__c wsli = HMA_TestHelper.getWorkScheduleLineItem(true, ws.Id);
        wsliList.add(wsli);
        Boolean isUpdateObject = PageTableController.updateObjectDetails(wsliList);
        System.assert(isUpdateObject == true);
    }
    @isTest public static void testUpdateObjectDetails1() {
        List<Work_Schedule_Line_Item__c> wsliList = new List<Work_Schedule_Line_Item__c>();
        Boolean isUpdateObject = PageTableController.updateObjectDetails(wsliList);
        System.assert(isUpdateObject == false);
    }
    @isTest public static void testDeleteTableRowRecord() {
        Application__c newApplication = HMA_TestHelper.getApplication(true, '', '', '');
        Work_Schedule__c ws = HMA_TestHelper.getWorkSchedule(true, newApplication.Id);
        Work_Schedule_Line_Item__c wsli = HMA_TestHelper.getWorkScheduleLineItem(true, ws.Id);

        PageTableController.deleteTableRowRecord(wsli.Id);
    }

    /**Test method for Send For Signature logic */
    @isTest public static void testExecuteTableAction() {
        Map<String, Object> returnMap = new Map<String, Object>();
        Application__c newApplication = HMA_TestHelper.getApplication(true, '', '', '');
        Application_Extension__c aapEx = HMA_TestHelper.getApplicationExension(true, newApplication.Id);
        Pre_Application__c PreApplication = [Select Id, Requestor__c from Pre_Application__c WHERE Id =: newApplication.Pre_Application__c LIMIT 1];
        Contact_Role__c conRole = HMA_TestHelper.getContactRole(false);
        conRole.Application__c = newApplication.Id;
        conRole.Contact__c = PreApplication.Requestor__c;
        conRole.Role__c = 'Match Commitment';
        insert conRole;

        returnMap = PageTableController.executeTableAction(aapEx.Id, conRole.Id, 'HMGP_SendDocuSignToResponsibleRepCtrl');
        System.assert(returnMap.size() > 0);
    }
}