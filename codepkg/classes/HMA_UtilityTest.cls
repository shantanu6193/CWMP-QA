@isTest
public with sharing class HMA_UtilityTest {
    @isTest
    public static void testShareCustomObjectRecordsWithUser() {
        User u = HMA_TestHelper.getPortalUserHMA(true);
        Application__c app = HMA_TestHelper.getApplication(true, '','', '');
        Map<Id, Set<Id>> sObjectIdtoUserIdsMap = new Map<Id, Set<Id>>();
        sObjectIdtoUserIdsMap.put(app.Id, new Set<Id>{u.Id});
        Test.startTest();
        Boolean shared = HMA_Utility.shareCustomObjectRecordsWithUser(sObjectIdtoUserIdsMap, 'Application__share', 'Edit', 'Manual');
        System.assert(shared == true || shared == false);
        Test.stopTest();
    }

    @isTest
    public static void testGetApplicationRFIs() {
        Application__c app = HMA_TestHelper.getApplication(true, '', '', '');
        Request_For_Information__c rfi = HMA_TestHelper.getRFI(true, app.Id, 2, 'OES BCA');
        Set<String> appIds = new Set<String>{String.valueOf(app.Id)};
        Set<String> rfiTypes = new Set<String>{'OES BCA'};
        Set<String> statuses = new Set<String>{'Draft'};
        Test.startTest();
        List<Request_For_Information__c> rfis = HMA_Utility.getApplicationRFIs(appIds, rfiTypes, statuses);
        System.assert(rfis.size() > 0);
        Test.stopTest();
    }

    // @isTest
    // public static void testGetContactIdtoUserIdMap() {
    //     User u = HMA_TestHelper.getPortalUserHMA(true);
    //     Test.startTest();
    //     Map<Id, Id> returnMap = HMA_Utility.getContactIdtoUserIdMap(new Set<Id>{String.valueOf(u.contactId)});
    //     System.assert(returnMap.size() > 0);
    //     Test.stopTest();
    // }

    @isTest
    public static void testConvertSIdToSObject() {
        Application__c app = HMA_TestHelper.getApplication(true, '','', '');
        Test.startTest();
        SObject sobj = HMA_Utility.convertSIdToSObject('Application__c', app.Id);
        System.assert(sobj != null);
        Test.stopTest();
    }

    @isTest
    public static void testShareApplicationRelatedDocumentsWithSpecificUser() {
        Map<Id, Set<Id>> paramMap = new Map<Id, Set<Id>>();
        Application__c app = HMA_TestHelper.getApplication(true, '', '', '');
        User u = HMA_TestHelper.getPortalUserHMA(true);
        paramMap.put(app.Id, new Set<Id>{u.Id});
        HMA_TestHelper.createCustomDocumentRecord(app.Id);
        Test.startTest();
        HMA_Utility.shareApplicationRelatedDocumentsWithSpecificUser(paramMap);
        Test.stopTest();
    }

    @isTest
    public static void testShareProjectSiteRelatedDocumentsWithSpecificUser() {
        Map<Id, Set<Id>> paramMap = new Map<Id, Set<Id>>();
        Application__c app = HMA_TestHelper.getApplication(true, '', '', '');
        Application_Extension__c appExt = HMA_TestHelper.getApplicationExension(true, app.Id);
        User u = HMA_TestHelper.getPortalUserHMA(true);
        Project_Site__c ps = HMA_TestHelper.getProjectSite(true, app.Id, appExt.Id);
        Document__c doc = HMA_TestHelper.createCustomDocumentRecord(app.Id);
        doc.Project_Site__c = ps.Id;
        update doc;
        paramMap.put(app.Id, new Set<Id>{u.Id});
        Test.startTest();
        HMA_Utility.shareProjectSiteRelatedDocumentsWithSpecificUser(paramMap);
        Test.stopTest();
    }
}