/**
 * Created by Admin on 17-05-2020.
 */

@IsTest
private class OrderItemTriggerHelperTest {

    @testSetup static void setup() {
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opportunity';
        opp.StageName = 'Draft';
        opp.CloseDate =  system.today() + 4;
        insert opp;

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
        odr.Name = 'Test Order';
        odr.Status = 'Draft';
        odr.EffectiveDate = system.today();
        odr.EndDate = system.today() + 4;
        odr.OpportunityId = opp.id;
        odr.AccountId = acc.Id;
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

    }

    @IsTest
    static void testBehavior() {
        Order order =  [Select Id , OpportunityId ,Opportunity.Amount , TotalAmount from Order Where Name = 'Test Order'];
        String orderId = order.Id;

        OrderItem orderItem = [Select Id , Quantity from OrderItem Where OrderId =:orderId LIMIT 1];
        orderItem.Quantity = orderItem.Quantity + 1 ;

        Opportunity opp = [Select Id , Amount from Opportunity Where Id =: order.OpportunityId];

        //System.assert(order.TotalAmount == opp.Amount, 'Success');

    }
}