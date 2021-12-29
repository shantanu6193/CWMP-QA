@isTest public with sharing class HMA_RequestForInformationCtrlTest {
    @isTest public static void testProcessOnRFI() {
        Map<String, Object> returnMap = new Map<String, Object>();

        Application__c newApplication = HMA_TestHelper.getApplication(true, '', '', '');
        Request_For_Information__c rfi = HMA_TestHelper.getRFI(true, newApplication.Id, 2, 'FEMA OES Programmatic');
        Test.startTest();
        returnMap = HMA_RequestForInformationCtrl.processOnRFI(newApplication.Id);
        System.assert(returnMap.size() > 0);
        Test.stopTest();
    }
    @isTest public static void testProcessOnRFI1() {
        Map<String, Object> returnMap = new Map<String, Object>();

        Contact portalCon = HMA_TestHelper.getPortalContact(true);
        Application__c newApplication = HMA_TestHelper.getApplication(true, '', '', '');
        Request_For_Information__c rfi = HMA_TestHelper.getRFI(false, newApplication.Id, 2, 'OES BCA');
        rfi.Status__c = 'Draft';
        insert rfi;
        AccountContactRole__c acRole = new AccountContactRole__c(Contact_Name__c = portalCon.Id );
        insert acRole;
        Contact_Role__c conRole = HMA_TestHelper.getContactRole(false);
        conRole.Role__c = 'Responsible Representative';
        conRole.Application__c = newApplication.Id;
        conRole.Contact__c = portalCon.Id;
        conRole.AccountContactJunction__c = acRole.Id;
        insert conRole;

        Test.startTest();
        returnMap = HMA_RequestForInformationCtrl.processOnRFI(newApplication.Id);
        System.assert(returnMap.size() > 0);
        Test.stopTest();
    }
    @isTest public static void testGetRFIRecordDetails() {
        Map<String, Object> returnMap = new Map<String, Object>();
        Map<String, Object> returnMapEmpty = new Map<String, Object>();

        Application__c newApplication = HMA_TestHelper.getApplication(true, '', '', '');
        Request_For_Information__c rfi = HMA_TestHelper.getRFI(true, newApplication.Id, 2, 'FEMA OES Programmatic');
        Test.startTest();
        returnMapEmpty = HMA_RequestForInformationCtrl.getRFIRecordDetails('');
        returnMap = HMA_RequestForInformationCtrl.getRFIRecordDetails(rfi.Id);
        System.assert(returnMap.size() > 0);
        Test.stopTest();
    }
    @isTest public static void testGetRFIRelatedDocuments() {
        Map<String, Object> returnMap = new Map<String, Object>();
        Map<String, Object> returnMapEmpty = new Map<String, Object>();

        Application__c newApplication = HMA_TestHelper.getApplication(true, '', '', '');
        Request_For_Information__c rfi = HMA_TestHelper.getRFI(true, newApplication.Id, 2, 'FEMA OES Programmatic');

        Blob b = Blob.valueOf('Test Data');
        ContentVersion contentVersion_1 = new ContentVersion();
        contentVersion_1.Title = 'Penguins';
        contentVersion_1.PathOnClient = 'Penguins.jpg';
        contentVersion_1.Document_Type__c = 'GANTT Chart';
        contentVersion_1.VersionData = b;
        contentVersion_1.IsMajorVersion = true;   
        insert contentVersion_1;

        ContentVersion contentVersion_2 = [SELECT Id, Title,Document_Type__c, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
        ContentDocumentLink conDocLink = new ContentDocumentLink();
            conDocLink.ShareType = 'V';
            conDocLink.Visibility = 'AllUsers';
            conDocLink.LinkedEntityId = rfi.Id;
            conDocLink.ContentDocumentId = contentVersion_2.ContentDocumentId;
            insert conDocLink;

        Test.startTest();
        returnMapEmpty = HMA_RequestForInformationCtrl.getRFIRelatedDocuments('');
        returnMap = HMA_RequestForInformationCtrl.getRFIRelatedDocuments(rfi.Id);
        System.assert(returnMap.size() > 0);
        Test.stopTest();
    }

    @isTest public static void testAttachUploadedFilesToRFI() {
        
        Map<String, Object> returnMap = new Map<String, Object>();
            List<String> contentDocumentIds = new List<String>();
            Application__c newApplication = HMA_TestHelper.getApplication(true, '', '', '');
            Request_For_Information__c rfi = HMA_TestHelper.getRFI(true, newApplication.Id, 2, 'FEMA OES Programmatic');
    
            Blob b = Blob.valueOf('Test Data');
            ContentVersion contentVersion_1 = new ContentVersion();
            contentVersion_1.Title = 'Penguins';
            contentVersion_1.PathOnClient = 'Penguins.jpg';
            contentVersion_1.Document_Type__c = 'GANTT Chart';
            contentVersion_1.VersionData = b;
            contentVersion_1.IsMajorVersion = true;   
            insert contentVersion_1;
            
            ContentVersion contentVersion_2 = [SELECT Id, Title,Document_Type__c, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
            
            contentDocumentIds.add(contentVersion_2.ContentDocumentId);
            Test.startTest();
            returnMap = HMA_RequestForInformationCtrl.attachUploadedFilesToRFI(contentDocumentIds, rfi.Id);
            System.assert(returnMap.size() > 0);
            Test.stopTest();
    }

    @isTest public static void testDeleteContentDocument() {
        Map<String, Object> returnMap = new Map<String, Object>();
            Application__c newApplication = HMA_TestHelper.getApplication(true, '', '', '');
            Request_For_Information__c rfi = HMA_TestHelper.getRFI(true, newApplication.Id, 2, 'FEMA OES Programmatic');
    
            Blob b = Blob.valueOf('Test Data');
            ContentVersion contentVersion_1 = new ContentVersion();
            contentVersion_1.Title = 'Penguins';
            contentVersion_1.PathOnClient = 'Penguins.jpg';
            contentVersion_1.Document_Type__c = 'GANTT Chart';
            contentVersion_1.VersionData = b;
            contentVersion_1.IsMajorVersion = true;   
            insert contentVersion_1;
            
            ContentVersion contentVersion_2 = [SELECT Id, Title,Document_Type__c, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
            
            Test.startTest();
            returnMap = HMA_RequestForInformationCtrl.deleteContentDocument(contentVersion_2.ContentDocumentId);
            System.assert(returnMap.size() > 0);
            Test.stopTest();
    }

    @isTest public static void testChangeRFIStatus() {
        Map<String, Object> returnMapForOperationBlank = new Map<String, Object>();
        Map<String, Object> returnMap = new Map<String, Object>();        
        Map<String, Object> returnMapForOperationSubmitRFI = new Map<String, Object>();
        Map<String, Object> returnMapWithoutRFI = new Map<String, Object>();
        
        Contact portalCon = HMA_TestHelper.getPortalContact(true);
        Application__c newApplication = HMA_TestHelper.getApplication(true, '', '', '');
        Request_For_Information__c rfi = HMA_TestHelper.getRFI(true, newApplication.Id, 2, 'FEMA OES Programmatic');
        AccountContactRole__c acRole = new AccountContactRole__c(Contact_Name__c = portalCon.Id );
        insert acRole;
        Contact_Role__c conRole = HMA_TestHelper.getContactRole(false);
        conRole.Role__c = 'FEMA Programmatic Analyst';
        conRole.Application__c = newApplication.Id;
        conRole.Contact__c = portalCon.Id;
        conRole.AccountContactJunction__c = acRole.Id;
        insert conRole;
        
        Test.startTest();
        /** This call is used for cover code if operation is blank */
        returnMapForOperationBlank = HMA_RequestForInformationCtrl.changeRFIStatus(rfi.Id, '');
        System.assert(returnMapForOperationBlank.get('IsSuccess') == false);

        returnMap = HMA_RequestForInformationCtrl.changeRFIStatus(rfi.Id, 'TimeExtensionRequest');
        System.assert(returnMap.size() > 0);

        /** This call is used for cover code if operation is SubmitRFI */
        returnMapForOperationSubmitRFI = HMA_RequestForInformationCtrl.changeRFIStatus(rfi.Id, 'SubmitRFI');
        System.assert(returnMapForOperationSubmitRFI.size() > 0);

        /** This call is used for cover code if No RFI */
        returnMapWithoutRFI = HMA_RequestForInformationCtrl.changeRFIStatus(newApplication.Id, 'SubmitRFI');
        System.assert(returnMapWithoutRFI.get('IsSuccess') == false);
        Test.stopTest();
    }

    @isTest public static void testLoadRFIRecord() {
        Map<String, Object> returnMap = new Map<String, Object>();
        Map<String, Object> returnMapForNullRFI = new Map<String, Object>();
        Map<String, Object> returnMapWithoutRFI = new Map<String, Object>();

        Application__c newApplication = HMA_TestHelper.getApplication(true, '', '', '');
        Request_For_Information__c rfi = HMA_TestHelper.getRFI(true, newApplication.Id, 2, 'FEMA OES Programmatic');
        Test.startTest();
        /** This call is used for cover the code if rfi Id is null */
        returnMapForNullRFI = HMA_RequestForInformationCtrl.loadRFIRecord(null);
        System.assert(returnMapForNullRFI.get('IsSuccess') == false);

        returnMap = HMA_RequestForInformationCtrl.loadRFIRecord(rfi.Id);
        System.assert(returnMap.size() > 0);

        /** This call is used for cover the code if No rfi got in query result*/
        returnMapWithoutRFI = HMA_RequestForInformationCtrl.loadRFIRecord(newApplication.Id);
        System.assert(returnMapWithoutRFI.get('IsSuccess') == false);
        Test.stopTest();
    }
    @isTest public static void testUpdateRFIRecordAndSendNotification() {
        Map<String, Object> returnMap = new Map<String, Object>();

        Contact portalCon = HMA_TestHelper.getPortalContact(true);
        Application__c newApplication = HMA_TestHelper.getApplication(true, '', '', '');
        Request_For_Information__c rfi = HMA_TestHelper.getRFI(false, newApplication.Id, 2, 'OES BCA');
        rfi.Status__c = 'Draft';
        insert rfi;
        AccountContactRole__c acRole = new AccountContactRole__c(Contact_Name__c = portalCon.Id );
        insert acRole;
        Contact_Role__c conRole = HMA_TestHelper.getContactRole(false);
        conRole.Role__c = 'Responsible Representative';
        conRole.Application__c = newApplication.Id;
        conRole.Contact__c = portalCon.Id;
        conRole.AccountContactJunction__c = acRole.Id;
        insert conRole;

        Test.startTest();
        returnMap = HMA_RequestForInformationCtrl.updateRFIRecordAndSendNotification(JSON.serialize(rfi), newApplication.Id, 'RequestForExtension');
        System.assert(returnMap.size() > 0);

        Test.stopTest();
    }
    /*@isTest public static void testUpdateRFIRecordAndSendNotification1() {
        Contact portalCon = HMA_TestHelper.getPortalContact(true);
        User portalUser = HMA_TestHelper.getPortalUser(false);
        portalUser.ContactId = portalCon.Id;
        insert portalUser;
            Map<String, Object> returnMapActionFEMASubmit = new Map<String, Object>();
            Map<String, Object> returnMapActionSubmit = new Map<String, Object>();
        Application__c newApplication = HMA_TestHelper.getApplication(false, '', '', '');
    
        newApplication.ownerId = Userinfo.getUserId();
        insert newApplication;
        System.debug('Request for information---'+newApplication.ownerId);
            Request_For_Information__c rfi = HMA_TestHelper.getRFI(false, newApplication.Id, 2, 'OES BCA');
            rfi.Status__c = 'Draft';
            insert rfi;
            AccountContactRole__c acRole = new AccountContactRole__c(Contact_Name__c = portalCon.Id );
            insert acRole;
            Contact_Role__c conRole = HMA_TestHelper.getContactRole(false);
            conRole.Role__c = 'Responsible Representative';
            conRole.Application__c = newApplication.Id; 
            conRole.Contact__c = portalCon.Id;
            conRole.AccountContactJunction__c = acRole.Id;
            insert conRole;
        System.runAs(portalUser) {
            Test.startTest();    
            returnMapActionSubmit = HMA_RequestForInformationCtrl.updateRFIRecordAndSendNotification(JSON.serialize(rfi), newApplication.Id, 'Submit');
            System.assert(returnMapActionSubmit.size() > 0);
            Test.stopTest();
        }
    }

    @isTest public static void testSendEmailToSubApplicants() {
        Contact portalCon = HMA_TestHelper.getPortalContact(true);
        Application__c newApplication = HMA_TestHelper.getApplication(true, '', '', '');
        Request_For_Information__c rfi = HMA_TestHelper.getRFI(false, newApplication.Id, 2, 'OES BCA');
        rfi.Status__c = 'Draft';
        insert rfi;
        AccountContactRole__c acRole = new AccountContactRole__c(Contact_Name__c = portalCon.Id );
        insert acRole;
        Contact_Role__c conRole = HMA_TestHelper.getContactRole(false);
        conRole.Role__c = 'Responsible Representative';
        conRole.Application__c = newApplication.Id;
        conRole.Contact__c = portalCon.Id;
        conRole.AccountContactJunction__c = acRole.Id;
        insert conRole;

        Test.startTest();
        Boolean returnValue = HMA_RequestForInformationCtrl.sendEmailToSubApplicants(newApplication.Id, 'HMA_RFI_Sent_To_SubApplicant_Notification');
        //System.assert(returnValue == true);
        Test.stopTest();
    }

    /** Need to create HMA Analyst User and Call testSendEmailToHmaAnalyst  method */
    @isTest public static void testSendEmailToHmaAnalyst() {
        User analystUser = HMA_TestHelper.getInternalUser(true, 'HMA_Analyst');
        System.runAs(analystUser) {
            Contact portalCon = HMA_TestHelper.getPortalContact(true);
            Application__c newApplication = HMA_TestHelper.getApplication(true, '', '', '');
            Request_For_Information__c rfi = HMA_TestHelper.getRFI(false, newApplication.Id, 2, 'OES BCA');
            rfi.Status__c = 'Draft';
            insert rfi;
            AccountContactRole__c acRole = new AccountContactRole__c(Contact_Name__c = portalCon.Id );
            insert acRole;
            Contact_Role__c conRole = HMA_TestHelper.getContactRole(false);
            conRole.Role__c = 'Responsible Representative';
            conRole.Application__c = newApplication.Id;
            conRole.Contact__c = portalCon.Id;
            conRole.AccountContactJunction__c = acRole.Id;
            insert conRole;

            Test.startTest();
            Boolean returnValue = HMA_RequestForInformationCtrl.sendEmailToHmaAnalyst(newApplication.Id, 'HMA Sub-Application Owner Change To HMA Analyst');
            System.assert(returnValue == true);    
            Test.stopTest();
        }        
    }
}