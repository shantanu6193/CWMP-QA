@isTest(seeAllData=false) 
public class PHOS_DistributionCtrlTest {
    @isTest public static void testGetOrderProducts(){

        Order__c newOrder = PHOS_TestHelper.getOrder(true);
        String orderIdString = String.valueOf(newOrder.Id);
        
        test.startTest();
        Map<String, Object> recievedMap = PHOS_DistributionCtrl.getOrderProducts(orderIdString);
        test.stopTest();
        System.assert(recievedMap.size() > 0);
    }
    @isTest public static void testApexSearchFacility() {
        List<String> selectedIds = new List<String>();
        List<LookupSearchResult> returnMap = new List<LookupSearchResult>();
        Account parentAccount = PHOS_TestHelper.getParentAccount(true);
        Account newAccount = PHOS_TestHelper.getAccount(false);
        newAccount.ParentId = parentAccount.Id;
        newAccount.Entity_Type__c = 'Health Care Facility';
        insert newAccount;
        String searchTerm = String.valueOf(newAccount.Name);
        selectedIds.add('test');
        
        Test.startTest();
        returnMap = PHOS_DistributionCtrl.apexSearchFacility(searchTerm , selectedIds);
        //System.assert(returnMap.size()>0);
        Test.stopTest();
    }
    @isTest public static void testSubmitRequest() {
        Order_Product__c newOrderProduct = PHOS_TestHelper.getOrderItemgoggle(true);
        Product_Distribution_Plan__c newProductDistributionPlan = PHOS_TestHelper.getProductDistributionPlan(false);
        newProductDistributionPlan.Order_Product__c = newOrderProduct.Id;
        insert newProductDistributionPlan;
        List<Order_Product__c> orderProducts = new List<Order_Product__c>();
        orderProducts.add(newOrderProduct);
        String recordData = JSON.serialize(orderProducts);
        System.debug('recordData-----'+recordData);
        Test.startTest();
        PHOS_DistributionCtrl.submitRequest(recordData, false);
        Test.stopTest();
    }
    @isTest public static void testSubmitRequest1() {
        Order_Product__c newOrderProduct = PHOS_TestHelper.getOrderItemgoggle(true);
        Product_Distribution_Plan__c newProductDistributionPlan = PHOS_TestHelper.getProductDistributionPlan(false);
        newProductDistributionPlan.Order_Product__c = newOrderProduct.Id;
        insert newProductDistributionPlan;
        List<Order_Product__c> orderProducts = new List<Order_Product__c>();
        orderProducts.add(newOrderProduct);
        String recordData = JSON.serialize(orderProducts);
        System.debug('recordData-----'+recordData);
        Test.startTest();
        PHOS_DistributionCtrl.submitRequest(recordData, true);
        Test.stopTest();
    }
    @IsTest
    public static void searchAccountTest1() {
        Test.startTest();
        Account stateAccount = PHOS_TestHelper.accountWithEntityType(true, 'County');
        PHOS_DistributionCtrl.getCounty();
        PHOS_DistributionCtrl.checkCommunityUser(UserInfo.getUserId());
        Test.stopTest();
    }
}