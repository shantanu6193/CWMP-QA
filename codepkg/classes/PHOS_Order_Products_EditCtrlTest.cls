/**
     * Created by Pankaj on 24-04-2020.
     */

@IsTest
private class PHOS_Order_Products_EditCtrlTest {
    @testSetup static void setup() {
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;

        List<Product2> productList = new List<Product2>();
        Product2 prod = new Product2();
        prod.Name = ' Test Product1';
        prod.Description = 'Test Product Entry 1';
        prod.productCode = 'ABC';
        prod.isActive = true;
        productList.add(Prod);

        prod = new Product2();
        prod.Name = ' Test Product2';
        prod.Description = 'Test Product Entry 2';
        prod.productCode = 'ABC';
        prod.isActive = true;
        productList.add(Prod);

        insert productList;

        Id pricebookId = Test.getStandardPricebookId();

        List<PricebookEntry> pricebookEntryList = new List<PricebookEntry>();
        for (Product2 product : productList) {
            PricebookEntry standardPrice = new PricebookEntry();
            standardPrice.Pricebook2Id = pricebookId;
            standardPrice.Product2Id = product.Id;
            standardPrice.UnitPrice = 100;
            standardPrice.IsActive = true;
            pricebookEntryList.add(standardPrice);
        }

        insert pricebookEntryList ;

        Order odr = new Order();
        odr.Name = 'Test Order ';
        odr.Status = 'Draft';
        odr.EffectiveDate = system.today();
        odr.EndDate = system.today() + 4;
        odr.AccountId = acc.id;
        odr.Pricebook2Id = pricebookId;
        insert odr;

        List<OrderItem> orderItemList = new List<OrderItem>();
        for (PricebookEntry pbe : pricebookEntryList) {
            OrderItem oderItm = new OrderItem();
            oderItm.OrderId = odr.id;
            oderItm.Quantity = 24;
            oderItm.UnitPrice = 240;
            oderItm.Product2id = pbe.Product2Id;
            oderItm.PricebookEntryId = pbe.id;
            orderItemList.add(oderItm);
        }

        insert orderItemList;

        prod = new Product2();
        prod.Name = 'Other';
        prod.Description = 'Other';
        prod.productCode = 'Other';
        prod.isActive = true;

        insert prod;

        PricebookEntry standardPrice = new PricebookEntry();
        standardPrice.Product2Id = prod.Id;
        standardPrice.UnitPrice = 100;
        standardPrice.IsActive = true;
        standardPrice.Pricebook2Id = pricebookId;
        insert standardPrice;
    }

    @isTest static void testMethod1() {
        Test.StartTest();
        Order__c newOrder = PHOS_TestHelper.getOrder(false);
        insert newOrder;
        String orderId= newOrder.Id;
        String prodOtherId = [Select Id from Product2 Where Name = 'Other' limit 1].Id;
        Map<String, Object> prodMap = PHOS_Order_Products_EditCtrl.getProducts();
        system.assert(prodMap.size() > 0);
        Map<String, Object> orderDetail = PHOS_Order_Products_EditCtrl.getOrderProductDetails(OrderId);
        system.assert(orderDetail.size() > 0);

        Order_Product__c  oderItm = PHOS_TestHelper.getOrderItemgoggle(false);
        oderItm.Quantity__c = 24;
        oderItm.Unit_Price__c = 240;
        oderItm.Product__c = prodOtherId;

        List<Order_Product__c > oiList = new List<Order_Product__c >();
        oiList.add(oderItm);

        orderDetail.put('orderItems', oiList);

        map<string, Object> orderItemMap = new map<string, Object>();
        orderItemMap.put('orderId', orderId);
        orderItemMap.put('OrderItems', JSON.serialize(orderDetail.get('orderItems')));
        //PHOS_Order_Products_EditCtrl.saveOrderItems(orderItemMap);
        Test.StopTest();

    }
}