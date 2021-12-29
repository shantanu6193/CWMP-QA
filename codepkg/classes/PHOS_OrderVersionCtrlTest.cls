@isTest(seeAllData = false)
public with sharing class PHOS_OrderVersionCtrlTest {

    @isTest public static void testGetProducts(){
        Map<String,Object> returnMap = new Map<String,Object>();
        Map<String,Object> returnMap1 = new Map<String,Object>();
        Product2 newProductGoggles =  PHOS_TestHelper.getProductGoggles(true);

        test.startTest();
        returnMap = PHOS_OrderVersionCtrl.getProducts();
        System.assert(returnMap.size()>0);


        Product2 newProductOther =  PHOS_TestHelper.getProductOther(true);
        returnMap1= PHOS_OrderVersionCtrl.getProducts();
        System.assert(returnMap1.size()>0);
        test.stopTest();
    }

    @isTest public static void testGetVersion(){
        User newUser = PHOS_TestHelper.getUser(true);

        Map<String, Object> returnMap = new Map<String, Object>();

        Order_Version__c newOrderVersion = PHOS_TestHelper.getOrderVersion(false);

        insert newOrderVersion;
        String orderVersionId = String.valueOf(newOrderVersion.Id);
        test.startTest();
        returnMap = PHOS_OrderVersionCtrl.getVersion(orderVersionId);
        System.assert(returnMap.size()>0);
        test.stopTest();


    }
}