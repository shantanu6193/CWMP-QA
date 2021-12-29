@isTest(SeeAllData=false)
public class PHOS_TestHelper {

    public static User getStandardUser(boolean create)
    {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' limit 1];
        User u = new User(Alias = 'standt', Email='standarduser@govbd.dev', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/New_York', UserName='standarduser'+Math.random()+'@govbd.dev');
        if(create)
            insert u;
        return u;
    }
    public static User getPortalUser(boolean create) {
        
        //**** First give call to getPortalContact() methos and provide ContactId to PortalUser

        Profile profile = [select Id,name from Profile where Name like 'PHOS Customer Community Plus Login User' limit 1];
        UserRole userRole = [Select Id, Name from UserRole where Name like 'Region 1 Customer User' limit 1];
        system.debug('profile-----------'+profile);
        Contact con = PHOS_TestHelper.getPortalContact(create);
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        String uniqueName = orgId + dateString;
        User portalUser = new User(
            Username = uniqueName+'@acme.com',
            //ContactId = contact.Id,
            ProfileId = profile.Id,
            Alias = 'test123',
            Email = 'test12345@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'McTesty',
            CommunityNickname = 'test12345',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            ContactId = con.Id
            //IsActive = true,
            //UserRoleId = userRole.Id
        );
        
        if(create)
            insert portalUser;
        return portalUser;
    }

    public static Contact getPortalContact(boolean create) {
        Account acc = PHOS_TestHelper.getAccount(create);
        Contact portalContact = new Contact();
        portalContact.Firstname='FirstNameportal';
        portalContact.Lastname='LastNameportal';
        portalContact.Email='email@portal.com';
        portalContact.Phone ='923-875-1274';
        portalContact.AccountId = acc.Id;

        if(create)
            insert portalContact;
        return portalContact;
    }
    public static User getUser(boolean create){
        Profile profile = [select Id,name from Profile where Name = 'CalOES Internal User' limit 1];
        User user = new User(Username = 'standarduser123Test45333@govbd.dev', LastName = 'nik' , Email = 'test12345@test.com',
                Alias = 'standt',   TimeZoneSidKey = 'America/New_York',    LocaleSidKey = 'en_US',EmailEncodingKey = 'UTF-8',
                ProfileId = profile.Id,LanguageLocaleKey = 'en_US',
                SenderEmail = 'standarduser@govbd.dev',    SenderName = 'user');
        if(create)
            insert user;
        return user;
    }

    public static Account getParentAccount(boolean create){
        Account newAccount = new Account();
        newAccount.Name = 'NewTest13'+system.now()+Math.random();
        newAccount.BillingStreet='rewxe';
        newAccount.BillingCountry='USA-11';
        newAccount.BillingState='NSdY';
        newAccount.Queue_Name__c = 'COVID_Contributions_Group_Initial';
        newAccount.BillingPostalCode='3425345';
        newAccount.Phone='544534334';
        newAccount.Entity_Type__c = 'Region';
        newAccount.Entity_Id__c = '234543';
        newAccount.Account_Name__c = 'Test';
        if(create)
            insert newAccount;
        return newAccount;
    }

    public static Account getAccount(boolean create){
        Account newParentAccount = PHOS_TestHelper.getParentAccount(create);
        Account newAccount = new Account();
        newAccount.Name = 'NewTest'+system.now()+Math.random();
        newAccount.ParentId = newParentAccount.Id;
        newAccount.BillingStreet='re';
        newAccount.BillingCountry='USA';
        newAccount.type = 'Customer';
        newAccount.BillingState='NY';
        newAccount.Queue_Name__c = 'test23';
        newAccount.BillingPostalCode='34545';
        newAccount.Phone='54453434';
        newAccount.Website='https://www.google.com';
        newAccount.Entity_Type__c = 'County';
        newAccount.Entity_Id__c = '23454453';
        if(create)
            insert newAccount;
        return newAccount;
    }
    public static Contact getContact(Boolean create) {
        Account newAccount = PHOS_TestHelper.getAccount(create);
        Contact contact = new Contact(AccountId = newAccount.Id ,Firstname='FirstName', Lastname='LastName',Email='email@email.com',Phone ='123-123-1234');
        if (create) {
            insert contact;
        }
        return contact;
    }

    public static Opportunity getOpportunity(boolean create){
        Account newAccount = PHOS_TestHelper.getAccount(create);
        Opportunity newOpportunity = new Opportunity();
        newOpportunity.AccountId = newAccount.Id;
        newOpportunity.Name = 'test125';
        newOpportunity.StageName = 'Shipped';
        newOpportunity.CloseDate = System.today();
        if(create)
            insert newOpportunity;
        return newOpportunity;

    }
    public static EmailMessage getEmailMessage(boolean create , Id orderId){
        EmailMessage newEmailMessage = new EmailMessage();
        newEmailMessage.Subject = 'New request submitted by County User%';
        newEmailMessage.RelatedToId = orderId;
        if(create)
            insert newEmailMessage;
        return newEmailMessage;
    }

    public static Order getStandardOrder(boolean create){
        Pricebook2 standardPricebook = PHOS_TestHelper.getPricebook2(create);
        Account newAccount = PHOS_TestHelper.getAccount(create);
        Date myDate = Date.newInstance(2020, 04, 22);
        Order newOrder = new Order(AccountId = newAccount.Id, Status='Draft', EffectiveDate = myDate, Requestor_Agency_Text__c = 'test1', Pricebook2Id = standardPricebook.Id);
        if(create)
            insert newOrder;
        return newOrder;
    }

    public static Order__c getOrder(boolean create){
        Order__c getOrder = new Order__c();
        Contact getContact = PHOS_TestHelper.getContact(create);
        User getUser = PHOS_TestHelper.getUser(create);
        Opportunity newOpprtunity = PHOS_TestHelper.getOpportunity(false);
        newOpprtunity.AccountId = getContact.AccountId;
        insert newOpprtunity;
        getOrder.Account__c = getContact.AccountId;
        getOrder.Incident_Name__c = 'COVID-19';
        getOrder.CreatedById = getUser.Id;
        getOrder.Delivery_Recipient_First_Name_Text__c = 'Test1';
        getOrder.Delivery_Recipient_Last_Name_Text__c = 'Test2';
        getOrder.Delivery_Recipient_Title_Text__c = 'Test3';
        getOrder.Delivery_Recipient_Email_Text__c = 'test@test.com';
        getOrder.Delivery_Recipient_Phone_Text__c = '48411';
        getOrder.Delivery_Schedule_Delivery_Date__c = Date.today();
        getOrder.Description__c = 'testz';
        getOrder.Requestor__c = getContact.Id;
        getOrder.Opportunity__c = newOpprtunity.Id;
        getOrder.Requestor_First_Name_Text__c = 'test4';
        getOrder.Requestor_Last_Name_Text__c = 'test';
        getOrder.Requestor_Title_Text__c = 'test';
        getOrder.Requestor_Email_Text__c = 'Test@test,com';
        getOrder.Requestor_Phone_Text__c = '546543421';
        getOrder.Requestor_Agency_Text__c = 'test';
        getOrder.Shipping_City__c = 'test';
        getOrder.Shipping_Country__c= 'test';
        getOrder.Shipping_ZipPostal_Code__c= 'test';
        getOrder.Shipping_State__c= 'CA';
        getOrder.Shipping_Street__c= 'test';
        //getOrder.Status__c= 'MHOAC Review';
        getOrder.County__c= '04 - Butte';
        getOrder.SuppliesEquipment__c= true;
        getOrder.Personnel__c= true;
        getOrder.Delivery_Notes__c= 'test';
        getOrder.Other_Request_Number_If_Applicable__c= 'test';
        getOrder.Mission_Request_Number_If_Applicable__c= 'test';
        getOrder.PHM_EOM_Confirmed__c= true;
        getOrder.RDMHS_Program_Confirmed__c= true;
        getOrder.Type_Of_Resource_Other__c= true;
        getOrder.Priority_for_Requests__c= 'Emergency';
        getOrder.Actions_Taken_On_This_Request__c= 'test';
        getOrder.Industry__c= 'Social Services';
        //getOrder.Sub_Industry__c= 'Plumbing';
        getOrder.Creator_Contact__c= getContact.Id;

        Id registrationRecordTypeId = Schema.SObjectType.Order__c.getRecordTypeInfosByDeveloperName().get('PHOS').getRecordTypeId();
        getOrder.RecordTypeId = registrationRecordTypeId;
        if(create){
            insert getOrder;
        }
        return getOrder;
    }

    public static Pricebook2 getPricebook2(boolean create){
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(), IsActive = True);
        if(create)
            update standardPricebook;
        return standardPricebook;
    }



    public static Order_Version__c getOrderVersion(boolean create){
        Order__c newOrder = PHOS_TestHelper.getOrder(create);
        insert newOrder;
        Order_Version__c newOrderVersion = new Order_Version__c();
        newOrderVersion.Version_Data__c = '{"attributes":{"type":"Order__c","url":"/services/data/v49.0/sobjects/Order__c/a08r000000CYzGUAA1"},"Id":"a08r000000CYzGUAA1","IsDeleted":false,"Name":"CASF-00003125","RecordTypeId":"012r0000000IB5JAAW","CreatedDate":"2020-06-23T15:42:31.000+0000","CreatedById":"005r00000042m4WAAQ","LastModifiedDate":"2020-06-23T15:42:31.000+0000","LastModifiedById":"005r00000042m4WAAQ","SystemModstamp":"2020-06-23T15:42:31.000+0000","LastViewedDate":"2020-06-26T06:18:09.000+0000","LastReferencedDate":"2020-06-26T06:18:09.000+0000","Account__c":"001r000000JRaIrAAL","Approved_by_CPO__c":false,"County__c":"01 - Alameda","Delivery_Recipient_Email_Text__c":"test@test.com","Delivery_Recipient_First_Name_Text__c":"test","Delivery_Recipient_Last_Name_Text__c":"test phos user","Delivery_Recipient_Phone_Text__c":"68524752","Delivery_Recipient_Title_Text__c":"test","Does_Not_Have_Resources__c":false,"Donation__c":false,"Incident_Name__c":"COVID-19","Industry__c":"Automotive and Transportation","Order_Create_Date_Time__c":"2020-06-23T15:42:31.000+0000","Other_Request_Number_If_Applicable__c":"COVID-19","PHM_EOM_Confirmed__c":false,"Personnel__c":false,"Priority_for_Requests__c":"Sustainment","Purchase_Order_Amendment__c":false,"Quality_Release__c":"R","RDMHS_Program_Confirmed__c":false,"Region__c":"San Francisco Bay Area","Requestor_Agency_Text__c":"Numquam recusandae","Requestor_Email_Text__c":"test@test.com","Requestor_First_Name_Text__c":"test","Requestor_Last_Name_Text__c":"test phos user","Requestor_Phone_Text__c":"68524752","Requestor_Title_Text__c":"test","Sub_Industry__c":"Ports","SuppliesEquipment__c":false,"Type_Of_Resource_Other__c":false,"Estimated_Donation_Order_Value__c":0.00,"Status__c":"RDMHS Review","Shipping_Street_2__c":"california","Shipping_City__c":"california","Shipping_ZipPostal_Code__c":"41526","Shipping_State__c":"CA","Shipping_Street__c":"california","OrderAmount__c":0.0000,"Order_Products__r":{"totalSize":1,"done":true,"records":[{"attributes":{"type":"Order_Product__c","url":"/services/data/v49.0/sobjects/Order_Product__c/a09r00000023KmsAAE"},"Order__c":"a08r000000CYzGUAA1","Id":"a09r00000023KmsAAE","IsDeleted":false,"Name":"OP-00000032","CreatedDate":"2020-06-23T15:42:31.000+0000","CreatedById":"005r00000042m4WAAQ","LastModifiedDate":"2020-06-23T15:42:31.000+0000","LastModifiedById":"005r00000042m4WAAQ","SystemModstamp":"2020-06-23T15:42:31.000+0000","Product__c":"01tt000000027uXAAQ","Quantity__c":200.00,"Equivalent_Substitutes_Acceptable__c":false,"Equivalent_Substitutes__c":"No","Is_Donation__c":false,"Product_Ordered_Total_Cost__c":0.00,"Product_Received_Total_Cost__c":0.00,"Product_Received_UOM__c":"Each","UOM__c":"Each","Product_Family__c":"KN95 Respirators","Product_Name__c":"KN95 Respirator - Unspecified","Unit_Price__c":0.0000,"ProductCode__c":"Unspecified","Total_Amount__c":0.00,"Product__r":{"attributes":{"type":"Product2","url":"/services/data/v49.0/sobjects/Product2/01tt000000027uXAAQ"},"Family":"KN95 Respirators","Id":"01tt000000027uXAAQ"}}]}}';
        newOrderVersion.Order_Custom__c = newOrder.id;
        if(create)
            insert newOrderVersion;
        return newOrderVersion;
    }

    public static Product2 getProductGoggles(boolean create){
        Product2 product = new  Product2(Name = 'Eye Goggles', Family = 'Goggles', IsActive = True, External_Material_No__c = 'P-28148001',Minimum_Order_Quantity__c = 10,Available_to_use_in_PHOS__c = true);
        if(create)
            insert product;
        return product;
    }


    public static Order_Product__c getOrderItemgoggle(boolean create){
        Order__c getOrder = PHOS_TestHelper.getOrder(create);
        Product2 product = PHOS_TestHelper.getProductGoggles(true);
        Order_Product__c goggleItem = new Order_Product__c(Order__c = getOrder.Id, Product__c = product.Id,Unit_Price__c = 10, Quantity__c = 10);
        if(create)
            insert goggleItem;
        return goggleItem;
    }

    public static   Product2 getProductMask(boolean create){
        Product2 mask = new Product2(Name = 'cloth Mask', Family = 'Mask', IsActive = True,External_Material_No__c = 'P-28191001',Minimum_Order_Quantity__c = 10,Available_to_use_in_PHOS__c = true);
        if(create)
            insert mask;
        return mask;
    }

    public static Order_Product__c getOrderItemmask(boolean create){
        Order__c getOrder = PHOS_TestHelper.getOrder(create);
        Product2 product = PHOS_TestHelper.getProductMask(true);

        Order_Product__c maskItem = new Order_Product__c(Order__c = getOrder.Id, Product__c = product.Id,Unit_Price__c = 10, Quantity__c = 10);
        if(create)
            insert maskItem;
        return maskItem;

    }
    public static Product_Distribution_Plan__c getProductDistributionPlan(boolean create) {
        Order_Product__c newOrderProduct = PHOS_TestHelper.getOrderItemgoggle(create);
        Product_Distribution_Plan__c newProductDistributionPlan = new Product_Distribution_Plan__c();
        newProductDistributionPlan.Distribution_Notes__c = 'TestDistributionNotes';
        newProductDistributionPlan.Facility_Name__c = 'TestFacilityName';
        newProductDistributionPlan.Order_Product__c = newOrderProduct.Id;
        if(create)
            insert newProductDistributionPlan;
        return newProductDistributionPlan;
    }

    public static   Product2 getProductOther(boolean create){
        Product2 mask = new Product2(Name = 'Other', Family = 'Mask', IsActive = True);
        if(create)
            insert mask;
        return mask;
    }

    public static User_Registration__c getUserRegistration(boolean create){
        Account newAccount = PHOS_TestHelper.getAccount(create);
        User_Registration__c   newUserRegistration = new User_Registration__c();
        //newUserRegistration.Community_Application__c = Community_Application__c.Id;
        newUserRegistration.County__c = 'Alameda';
        newUserRegistration.First_Name__c = 'testFirstName';
        newUserRegistration.Last_Name__c = 'testLastName';
        newUserRegistration.Status__c = 'Pending for Approval';
        newUserRegistration.Email__c = 'test@gmail.com';
        newUserRegistration.Non_Governmental_Entity__c = 'test';
        //newUserRegistration.State_Agency__c = newAccount.Id;
        newUserRegistration.Entity_Type__c = 'State Agency';
        
        if(create)
            insert newUserRegistration;
        return newUserRegistration;
    }
    
    public static Community_Application__c getCommunityApplication(boolean create){
        Community_Application__c newCommunityApplication = new Community_Application__c();
        newCommunityApplication.App_Permission_Set_Developer_Name__c = 'HMA_Community_User';
        newCommunityApplication.User_Approval_Class__c = 'PHOS_UserServiceAppHandler';
        newCommunityApplication.App_URL__c = 'https://uat-caloes.cs33.force.com/hma ';
        newCommunityApplication.Display_Name__c = 'Hazard Mitigation - NOI Requests Portal  ';
        newCommunityApplication.isActive__c = true;
        newCommunityApplication.Name = 'HMA';
        if(create)
            insert newCommunityApplication;
        return newCommunityApplication;
    }
    public static Account accountWithEntityType(boolean create, String entityType){
        Account newParentAccount = PHOS_TestHelper.getParentAccount(create);
        Account newAccount = new Account();
        newAccount.Name = 'NewTest'+system.now()+Math.random();
        newAccount.ParentId = newParentAccount.Id;
        newAccount.BillingStreet='re';
        newAccount.BillingCountry='USA';
        newAccount.type = 'Customer';
        newAccount.BillingState='NY';
        newAccount.Queue_Name__c = 'test23';
        newAccount.BillingPostalCode='34545';
        newAccount.Phone='54453434';
        newAccount.Website='https://www.google.com';
        newAccount.Entity_Type__c=entityType;
        newAccount.Entity_Id__c=entityType;
        if(create)
            insert newAccount;
        return newAccount;
    }
    public static Distribution_Plan_Version__c getPlanVersion(boolean create){
        Order__c newOrder = PHOS_TestHelper.getOrder(false);
        insert newOrder;
        Distribution_Plan_Version__c planVersion = new Distribution_Plan_Version__c();
        planVersion.Version_Data__c = '[{"attributes":{"type":"Order_Product__c","url":"/services/data/v50.0/sobjects/Order_Product__c/a08r000000Ct5t0AAB"},"Id":"a08r000000Ct5t0AAB","IsDeleted":false,"Name":"OP-00032602","CreatedDate":"2020-08-14T07:08:43.000+0000","CreatedById":"005r00000047xcgAAA","LastModifiedDate":"2020-08-14T16:06:34.000+0000","LastModifiedById":"005t00000049et0AAA","SystemModstamp":"2020-08-14T16:06:34.000+0000","Order__c":"a09r00000023ktkAAA","Equivalent_Substitutes_Acceptable__c":false,"Equivalent_Substitutes__c":"No","Fulfilment_Entity_Warehouse__c":"West Sacramento","Is_Donation__c":false,"ProductCode__c":"ADV001","Product_Ordered_Total_Cost__c":0.00,"Product_Received_Total_Cost__c":0.00,"Product_Received_UOM__c":"Each","Product__c":"01tt0000000pIHyAAM","Quantity__c":1500.00,"Total_Price__c":0.0000,"UOM__c":"Each","Unit_Price__c":0.0000,"Product_Family__c":"N-95 Respirators","Product_Name__c":"Advoque N95 Particulate Respirator","Total_Amount__c":0.00,"Status__c":"Sent","Product_Distribution_Plans__r":{"totalSize":3,"done":true,"records":[{"attributes":{"type":"Product_Distribution_Plan__c","url":"/services/data/v50.0/sobjects/Product_Distribution_Plan__c/a0Mr0000001waxGEAQ"},"Order_Product__c":"a08r000000Ct5t0AAB","Id":"a0Mr0000001waxGEAQ","IsDeleted":false,"Name":"PDP-00000634","CreatedDate":"2020-09-11T10:20:59.000+0000","CreatedById":"005t00000049et0AAA","LastModifiedDate":"2020-09-15T13:29:34.000+0000","LastModifiedById":"005t00000049et0AAA","SystemModstamp":"2020-09-15T13:29:34.000+0000","Facility__c":"001r000000LF8O9AAL","Facility_Name__c":"Hospital 1","County__c":"001r000000L7G8NAAV","Proposed_Quantity_Distribution__c":3,"Distribution_Notes__c":"veeverf","Actual_Quantity_Distribution__c":0,"Facility_Code__c":"111222","County__r":{"attributes":{"type":"Account","url":"/services/data/v50.0/sobjects/Account/001r000000L7G8NAAV"},"Name":"Alameda","Id":"001r000000L7G8NAAV"}},{"attributes":{"type":"Product_Distribution_Plan__c","url":"/services/data/v50.0/sobjects/Product_Distribution_Plan__c/a0Mr0000001wdTbEAI"},"Order_Product__c":"a08r000000Ct5t0AAB","Id":"a0Mr0000001wdTbEAI","IsDeleted":false,"Name":"PDP-00000639","CreatedDate":"2020-09-15T13:29:01.000+0000","CreatedById":"005t00000049et0AAA","LastModifiedDate":"2020-09-15T13:29:34.000+0000","LastModifiedById":"005t00000049et0AAA","SystemModstamp":"2020-09-15T13:29:34.000+0000","Facility__c":"001r000000LF8O9AAL","Facility_Name__c":"Hospital 1","County__c":"001r000000L7G8NAAV","Facility_Code__c":"111222","Sequence__c":2,"County__r":{"attributes":{"type":"Account","url":"/services/data/v50.0/sobjects/Account/001r000000L7G8NAAV"},"Name":"Alameda","Id":"001r000000L7G8NAAV"}},{"attributes":{"type":"Product_Distribution_Plan__c","url":"/services/data/v50.0/sobjects/Product_Distribution_Plan__c/a0Mr0000001wdTcEAI"},"Order_Product__c":"a08r000000Ct5t0AAB","Id":"a0Mr0000001wdTcEAI","IsDeleted":false,"Name":"PDP-00000640","CreatedDate":"2020-09-15T13:29:01.000+0000","CreatedById":"005t00000049et0AAA","LastModifiedDate":"2020-09-15T13:29:34.000+0000","LastModifiedById":"005t00000049et0AAA","SystemModstamp":"2020-09-15T13:29:34.000+0000","Facility__c":"001r000000LLazWAAT","Facility_Name__c":"Hospital 4","County__c":"001r000000L7G8NAAV","Sequence__c":3,"County__r":{"attributes":{"type":"Account","url":"/services/data/v50.0/sobjects/Account/001r000000L7G8NAAV"},"Name":"Alameda","Id":"001r000000L7G8NAAV"}}]}},{"attributes":{"type":"Order_Product__c","url":"/services/data/v50.0/sobjects/Order_Product__c/a08r000000Ct5t1AAB"},"Id":"a08r000000Ct5t1AAB","IsDeleted":false,"Name":"OP-00032603","CreatedDate":"2020-08-14T07:08:43.000+0000","CreatedById":"005r00000047xcgAAA","LastModifiedDate":"2020-08-14T16:06:34.000+0000","LastModifiedById":"005t00000049et0AAA","SystemModstamp":"2020-08-14T16:06:34.000+0000","Order__c":"a09r00000023ktkAAA","Equivalent_Substitutes_Acceptable__c":false,"Equivalent_Substitutes__c":"No","Fulfilment_Entity_Warehouse__c":"West Sacramento","Is_Donation__c":false,"ProductCode__c":"D13484884","Product_Ordered_Total_Cost__c":0.00,"Product_Received_Total_Cost__c":0.00,"Product_Received_UOM__c":"Each","Product__c":"01tt000000022O5AAI","Quantity__c":200.00,"Total_Price__c":0.0000,"UOM__c":"Each","Unit_Price__c":0.0000,"Product_Family__c":"Coveralls (Hospitals or EMS)","Product_Name__c":"Coverall - 2X","Total_Amount__c":0.00,"Status__c":"Sent","Product_Distribution_Plans__r":{"totalSize":1,"done":true,"records":[{"attributes":{"type":"Product_Distribution_Plan__c","url":"/services/data/v50.0/sobjects/Product_Distribution_Plan__c/a0Mr0000001waxHEAQ"},"Order_Product__c":"a08r000000Ct5t1AAB","Id":"a0Mr0000001waxHEAQ","IsDeleted":false,"Name":"PDP-00000635","CreatedDate":"2020-09-11T10:20:59.000+0000","CreatedById":"005t00000049et0AAA","LastModifiedDate":"2020-09-15T13:29:34.000+0000","LastModifiedById":"005t00000049et0AAA","SystemModstamp":"2020-09-15T13:29:34.000+0000","Facility__c":"001r000000LT3nbAAD","Facility_Name__c":"marina","County__c":"001r000000L7G8NAAV","Proposed_Quantity_Distribution__c":2,"Distribution_Notes__c":"vdsvdv","Actual_Quantity_Distribution__c":0,"Facility_Code__c":"111","County__r":{"attributes":{"type":"Account","url":"/services/data/v50.0/sobjects/Account/001r000000L7G8NAAV"},"Name":"Alameda","Id":"001r000000L7G8NAAV"}}]}},{"attributes":{"type":"Order_Product__c","url":"/services/data/v50.0/sobjects/Order_Product__c/a08r000000Ct7e9AAB"},"Id":"a08r000000Ct7e9AAB","IsDeleted":false,"Name":"OP-00032610","CreatedDate":"2020-08-14T16:06:34.000+0000","CreatedById":"005t00000049et0AAA","LastModifiedDate":"2020-08-14T16:06:34.000+0000","LastModifiedById":"005t00000049et0AAA","SystemModstamp":"2020-08-14T16:06:34.000+0000","Order__c":"a09r00000023ktkAAA","Equivalent_Substitutes_Acceptable__c":false,"Equivalent_Substitutes__c":"No","Fulfilment_Entity_Warehouse__c":"Stockton","Is_Donation__c":false,"ProductCode__c":"Unspecified","Product_Ordered_Total_Cost__c":0.00,"Product_Received_Total_Cost__c":0.00,"Product_Received_UOM__c":"Each","Product__c":"01tt000000027urAAA","Quantity_Back_Ordered__c":111.00,"Quantity__c":111.00,"Total_Price__c":0.0000,"UOM__c":"Each","Unit_Price__c":0.0000,"Product_Family__c":"Beds/Cots","Product_Name__c":"Beds - Unspecified","Total_Amount__c":0.00,"Status__c":"New","Product_Distribution_Plans__r":{"totalSize":1,"done":true,"records":[{"attributes":{"type":"Product_Distribution_Plan__c","url":"/services/data/v50.0/sobjects/Product_Distribution_Plan__c/a0Mr0000001wdS4EAI"},"Order_Product__c":"a08r000000Ct7e9AAB","Id":"a0Mr0000001wdS4EAI","IsDeleted":false,"Name":"PDP-00000638","CreatedDate":"2020-09-15T12:30:48.000+0000","CreatedById":"005t00000049et0AAA","LastModifiedDate":"2020-09-15T13:29:34.000+0000","LastModifiedById":"005t00000049et0AAA","SystemModstamp":"2020-09-15T13:29:34.000+0000","Facility__c":"001r000000LKyg0AAD","Facility_Name__c":"Test","County__c":"001r000000L7G8NAAV","Proposed_Quantity_Distribution__c":11,"Facility_Code__c":"238972938","County__r":{"attributes":{"type":"Account","url":"/services/data/v50.0/sobjects/Account/001r000000L7G8NAAV"},"Name":"Alameda","Id":"001r000000L7G8NAAV"}}]}}]';
        planVersion.Order__c = newOrder.Id;
        if(create)
            insert planVersion;
        return planVersion;
    }

    public static Account getWarehouseAccount(boolean create){
        Account newAccount = new Account();
        newAccount.Name = 'CDPH West Sacramento test';
        newAccount.Entity_Type__c = 'Warehouse';
        newAccount.Entity_Id__c = 'CV12';
        if(create)
            insert newAccount;
        return newAccount;
    }

    public static Shipment_Order__c getShipmentOrder(boolean create){
        Order__c orderRec = PHOS_TestHelper.getOrder(create);
        Id phosShipOrderRecordTypeId = Schema.SObjectType.Shipment_Order__c.getRecordTypeInfosByDeveloperName().get('PHOS').getRecordTypeId();
        Shipment_Order__c shipmentOrder = new Shipment_Order__c();
        shipmentOrder.Order_Custom__c = orderRec.Id;
        shipmentOrder.Name = 'Shipment Name';
        shipmentOrder.Status__c = PHOS_Constants.SHIPMENT_ORDER_STATUS_READY;
        shipmentOrder.RecordTypeId = phosShipOrderRecordTypeId;

        if(create)
            insert shipmentOrder;
       return shipmentOrder; 
    }
    public static Shipment_Order_Line_Item__c getShipmentOrderLineItem(boolean create){
        Shipment_Order__c shipmentOrder = PHOS_TestHelper.getShipmentOrder(create);
        Order_Product__c orderProduct = PHOS_TestHelper.getOrderItemmask(create);
        Shipment_Order_Line_Item__c shipmentOrderLineItem = new Shipment_Order_Line_Item__c();
        shipmentOrderLineItem.Order_Product_Shipped__c = orderProduct.Name;
        shipmentOrderLineItem.Quantity__c = 10;
        shipmentOrderLineItem.Shipment__c = shipmentOrder.Id;
        if(create)
            insert shipmentOrderLineItem;
       return shipmentOrderLineItem; 
    }
}