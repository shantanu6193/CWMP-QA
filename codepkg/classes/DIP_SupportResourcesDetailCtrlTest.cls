/**
 * Created by Admin on 14-05-2020.
 */
@IsTest
private  class DIP_SupportResourcesDetailCtrlTest {
    @IsTest
    static void testBehavior() {
        Test.startTest();

        Support_Resource__c testItem = new Support_Resource__c();
        testItem.Description__c = 'this is a test Resource';
        testItem.Is_Active__c = true;
        testItem.As_of_Date__c = System.now().date();
        insert testItem;

        Map<String,Object> resultMap = (Map<String,Object>) DIP_SupportResourcesDetailCtrl.getSupportResources();

        Support_Resource__c testItemAnother = (Support_Resource__c)resultMap.get('SupportResources');

        System.assert(testItemAnother.Id ==testItem.Id);

        Test.stopTest();
    }
}