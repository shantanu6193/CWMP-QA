/**
 * Created by Neha on 10-04-2020.
 */

@IsTest
private class DIP_DashBoard_ListCtrlTest {
    @IsTest
    static void testBehavior() {
        Test.startTest();

        Map<String,List<DashBoard_Config__mdt>> resultMap =(Map<String,List<DashBoard_Config__mdt>>) DIP_DashBoard_ListCtrl.getImportantBoards();
        List<DashBoard_Config__mdt> dashBoardConfigs = [SELECT Id,Label,Dashboard_Description__c,Dashboard_Id__c,Dashboard_Label__c FROM DashBoard_Config__mdt Where is_Active__c=true ORDER BY Dashboard_Label__c];

        System.assert(resultMap.get('dashBoardConfigs').size() == dashBoardConfigs.size());

        Test.stopTest();
    }
}