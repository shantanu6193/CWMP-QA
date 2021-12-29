@isTest(seeAllData=false)
public class AppUtilsTest {
    @isTest public static void testGenerateSnapshotInJSON(){
        Order__c newOrder = PHOS_TestHelper.getOrder(true);
        Order_Version__c newOrderVersion = PHOS_TestHelper.getOrderVersion(false);
        newOrderVersion.Order_Custom__c = newOrder.Id;
        insert newOrderVersion;        
        String orderId =  String.valueOf(newOrder.Id);
        
        test.startTest();
        AppUtils.generateSnapshotInJSON(orderId);
        test.stopTest();
    }
    
    @isTest public static void testFetchAllEmailAddresses(){
        List<String> returnMap = new List<String>();
        String data = 'test.gmail@gmail.com';
        
        test.startTest();
        returnMap = AppUtils.fetchAllEmailAddresses(data);
        System.assert(returnMap.size()>0);
        test.stopTest();
    }
    
    @isTest public static void testGenerateSnapshotInJSONForDistributionPlan(){
        Order__c newOrder = PHOS_TestHelper.getOrder(true);
        Order_Version__c newOrderVersion = PHOS_TestHelper.getOrderVersion(false);
        newOrderVersion.Order_Custom__c = newOrder.Id;
        insert newOrderVersion;        
        String orderId =  String.valueOf(newOrder.Id);
        
        test.startTest();
        AppUtils.generateSnapshotInJSONForDistributionPlan(orderId);
        test.stopTest();
    }
}