/**
 * Created by Pankaj on 30-03-2020.
 *
 * Temporary added see all data to true as it is quick deployment and we don't have time
 */

//todo - remove see all data


@isTest(SeeAllData=false)
public with sharing class PHOS_Order_EditCtrlTest {
    @isTest public static void testSaveOrder(){
        Map<String, Object> paramMap = new Map<String, Object>();
        List<Order_Product__c> orderItems = new List<Order_Product__c>();

        Order__c getOrder = PHOS_TestHelper.getOrder(true);

        Order_Product__c getOrderItemgoggle = PHOS_TestHelper.getOrderItemgoggle(false);
        getOrderItemgoggle.Order__c = getOrder.Id;
        insert getOrderItemgoggle;
        Order_Product__c getOrderItemmask = PHOS_TestHelper.getOrderItemmask(false);
        getOrderItemmask.Order__c = getOrder.Id;
        getOrderItemmask.Unit_Price__c = null;
        insert getOrderItemmask;

        getOrder.Order_Products__r.add(getOrderItemgoggle);
        getOrder.Order_Products__r.add(getOrderItemmask);
        //orderItems.add(getOrderItemgoggle);
        //orderItems.add(getOrderItemmask);

        //paramMap.put('Order', JSON.serialize(PHOS_TestHelper.getOrder(false)));
        //paramMap.put('OrderItems', JSON.serialize(OrderItems));
        //paramMap.put('QuickSave', false);
        test.startTest();
        Map<String, Object> returnMap = PHOS_Order_EditCtrl.saveOrder(JSON.serialize(getOrder),false);
        System.assert(returnMap.size() > 0);


       // paramMap.put('Order', JSON.serialize(getOrder));
        //paramMap.put('QuickSave', true);
        Map<String, Object> returnMap1 = PHOS_Order_EditCtrl.saveOrder(JSON.serialize(getOrder),true);
        test.stopTest();
        System.assert(returnMap1.size() > 0);
    }
  
    @isTest public static void testSubmitForRDMSHApprovalRequest(){
        Contact newContact = PHOS_TestHelper.getContact(true);
        User portalUser = PHOS_TestHelper.getPortalUser(false);
        portalUser.ContactId = newContact.Id;
        insert portalUser;
        System.runAs(portalUser){
            Order__c newOrder = PHOS_TestHelper.getOrder(false);
            newOrder.Account__c = newContact.AccountId;
            newOrder.Requestor__c = newContact.Id;
            newOrder.Creator_Contact__c = newContact.Id;
            newOrder.Status__c= 'MHOAC Review';
            insert newOrder;
            
            String orderIdString = String.valueOf(newOrder.Id);

            test.startTest();
            PHOS_Order_EditCtrl.submitForRDMSHApprovalRequest(orderIdString, 'Comment to order');
            test.stopTest();
        }        
    }
  
    /*@isTest public static void testProcessCDPHTeamApprovalRequest(){

        Account newAccount = new Account(Name = 'Test Account1', BillingStreet='re', BillingCountry='USA', BillingState='NY', BillingPostalCode='34545', Phone='54453434', Website='https://www.google.com');
        insert newAccount;
        Account AccountId = [SELECT id FROM Account WHERE Name = 'Test Account1'];
        Date myDate = Date.newInstance(2020, 04, 22);
        Order newOrder = new Order(AccountId = AccountId.Id, Status='Draft', EffectiveDate = myDate, Requestor_Agency_Text__c = 'test1');
        Order anotherOrder = new Order(AccountId = AccountId.Id, Status='Draft', EffectiveDate = myDate, Requestor_Agency_Text__c = 'test2');
        insert newOrder;
        insert anotherOrder;

        Order newOrderId = [Select Id From Order Where Requestor_Agency_Text__c = 'test1' ];
        Order anotherOrderId = [Select Id From Order Where Requestor_Agency_Text__c = 'test2' ];
        list<ID> idsList = new list<ID>();
        idsList.add(newOrderId.Id);
        idsList.add(anotherOrderId.Id);

        test.startTest();
        PHOS_Order_EditCtrl.processCDPHTeamApprovalRequest(idsList);
        string before = 'Testing base 64 encode';
        Blob beforeblob = Blob.valueOf(before);



        //Insert contentdocument data
        ContentVersion cv = new ContentVersion();
        cv.title = 'test content trigger';
        cv.PathOnClient ='test';
        cv.VersionData =beforeblob;
        insert cv;

        ContentVersion testContent = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :cv.Id];

        ContentDocumentLink newFileShare = new ContentDocumentLink();
        newFileShare.contentdocumentid = testcontent.contentdocumentid;
        newFileShare.LinkedEntityId = newOrderId.Id;
        newFileShare.ShareType= 'V';
        insert newFileShare;


        test.stopTest();
    }*/

    @isTest public static void testOrderApprovalRequestFromCountyUSER(){

        Account newAccount = new Account(Name = 'Test Account1', BillingStreet='re', BillingCountry='USA', BillingState='NY', BillingPostalCode='34545', Phone='54453434', Website='https://www.google.com');
        insert newAccount;
        Account AccountId = [SELECT id FROM Account WHERE Name = 'Test Account1'];
        Date myDate = Date.newInstance(2020, 04, 22);
        Order newOrder = new Order(AccountId = AccountId.Id, Status='Draft', EffectiveDate = myDate, Requestor_Agency_Text__c = 'test1');
        insert newOrder;
        List<Id> orderIds = new List<Id>();
        orderIds.add(newOrder.Id);
        //Order orderId = [Select Id From Order Where Requestor_Agency_Text__c = 'test1'];
        //String orderIdString = String.valueOf(orderId.ID);

        test.startTest();
        //PHOS_Order_EditCtrl.orderApprovalRequestFromCountyUSER(orderIds);
        test.stopTest();
    }

    @isTest public static void testGetOrders(){

        Order__c newOrder = PHOS_TestHelper.getOrder(true);
        String orderIdString = String.valueOf(newOrder.Id);
        test.startTest();
        Map<String, Object> recievedMap = PHOS_Order_EditCtrl.getOrders(orderIdString);
        test.stopTest();
        System.assert(recievedMap.size() > 0);
    }

    @isTest public static void testGetRecipientContact(){
     Contact newContact = PHOS_TestHelper.getContact(true);
        User portalUser = PHOS_TestHelper.getPortalUser(false);
        portalUser.ContactId = newContact.Id;
        insert portalUser;
        System.runAs(portalUser){
        test.startTest();
        Map<String, Object> receivedMap =  PHOS_Order_EditCtrl.getRecipientContact();
        test.stopTest();
        System.assert(receivedMap.size() > 0);
        }
    }

    @isTest public static void testGetVersion(){


        Account newAccount = new Account(Name = 'Test Account1', BillingStreet='re', BillingCountry='USA', BillingState='NY', BillingPostalCode='34545', Phone='54453434', Website='https://www.google.com');
        insert newAccount;
        Account AccountId = [SELECT id FROM Account WHERE Name = 'Test Account1'];

        Product2 mask = new Product2(Name = 'cloth Mask', Family = 'Mask', IsActive = True);
        insert mask;
        Product2 maskId = [select Name,Family,Id From Product2 Where Name = 'cloth Mask'];

        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(), IsActive = True);
        Update standardPricebook;
        Pricebook2 standardPricebookId = [SELECT Id, IsStandard FROM Pricebook2 WHERE Id = :standardPricebook.Id];

        PricebookEntry maskPricebookEntry = new PricebookEntry(Pricebook2Id = standardPricebookId.Id, Product2Id = maskId.Id, UnitPrice = 0, IsActive = True);
        insert maskPricebookEntry;
        PricebookEntry maskPricebookEntryId = [Select Id From PricebookEntry Where Product2Id = :maskId.Id];

        Date myDate = Date.newInstance(2020, 04, 22);
        Order newOrder = new Order(AccountId = AccountId.Id, Status='Draft', EffectiveDate = myDate, Requestor_Agency_Text__c = 'test1', Pricebook2Id = standardPricebookId.Id);
        insert newOrder;
        Order newOrderId = [Select Id From Order Where Requestor_Agency_Text__c = 'test1' ];
        String versionData = String.valueOf(Json.serialize(newOrder));

        OrderItem orderItem1 = new OrderItem(Product2Id = maskId.Id, PricebookEntryId = maskPricebookEntryId.Id, UnitPrice = 0, Quantity = 5);


        Order_Version__c newOrderVersion = new Order_Version__c(Order__c = newOrderId.Id, Version__c = 1, Version_Data__c = versionData);
        insert newOrderVersion;
        Order_Version__c newOrderVersionId = [Select Id From Order_Version__c  Where Order__c =:newOrderId.Id];
        String orderVersionId = String.valueOf(newOrderVersionId.Id);

        test.startTest();
        Map<String, Object> receivedMap =  PHOS_Order_EditCtrl.getVersion(orderVersionId);
        test.stopTest();
        System.assert(receivedMap.size() > 0);

    }

    @isTest public static void testGetPriorityOfRequests(){

        test.startTest();
        List<String> receivedList =  PHOS_Order_EditCtrl.getPriorityOfRequests();
        test.stopTest();
        System.assert(receivedList.size() > 0);
    }

    @isTest public static void testGetStateCodes(){
        List<String> returnList = new List<String>();
        test.startTest();
        returnList = PHOS_Order_EditCtrl.getStateCodes();
        System.assert(returnList.size()>0);
        test.stopTest();
    }
    @isTest public static void testGetCountyList(){
        List<String> returnList = new List<String>();
        test.startTest();
        returnList = PHOS_Order_EditCtrl.getCountyList();
        System.assert(returnList.size()>0);
        test.stopTest();
    }

    @isTest public static void testGetIncidentList(){
        List<Map<String, String>> returnMap = new List<Map<String, String>>();
        Incident__c newIncident = HMA_TestHelper.getIncident(true);
        String available = newIncident.Available_for_Application__c;

        test.startTest();
        returnMap = PHOS_Order_EditCtrl.getIncidentList(available);
        system.assert(returnMap.size()>0);
        test.stopTest();
    }
    
    @IsTest public static void testGetEntityTypeList1(){
        List<String> options =  PHOS_Order_EditCtrl.getEntityTypeList1();
        system.assert(options.size()>0);
    }
}