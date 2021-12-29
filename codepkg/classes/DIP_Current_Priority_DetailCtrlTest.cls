/**
 * Created by Admin on 15-04-2020.
 */


@IsTest
private class DIP_Current_Priority_DetailCtrlTest {
    @IsTest
    static void testBehavior() {
        Test.startTest();

        Current_Priorities__c testItem = new Current_Priorities__c();
        testItem.Priority_Description__c = 'this is a test priority';
        testItem.Is_Active__c = true;
        insert testItem;

        Map<String,Object> resultMap = (Map<String,Object>) DIP_Current_Priority_DetailCtrl.getPriorityItem();

        Current_Priorities__c testItemAnother = (Current_Priorities__c)resultMap.get('PriorityItem');

                System.assert(testItemAnother.Id ==testItem.Id);

        Test.stopTest();
    }
}