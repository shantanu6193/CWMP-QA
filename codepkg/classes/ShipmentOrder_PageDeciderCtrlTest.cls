@isTest(seeAllData=false)
public class ShipmentOrder_PageDeciderCtrlTest {
    @isTest public static void testGetInitData() {
        Map<String, Object> returnMap = new Map<String, Object>();
        Order__c newOrder = PHOS_TestHelper.getOrder(true);
        String orderId = String.valueOf(newOrder.Id);
        
        Test.startTest();
        returnMap = ShipmentOrder_PageDeciderCtrl.getInitData(orderId);
        System.assert(returnMap.size()>0);
        Test.stopTest();

    }
}