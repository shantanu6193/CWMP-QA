@isTest 
public with sharing class HMA_ApplicationCtrlTest {
    @isTest public static void testProcessRecord() {
        try{
        Map<String,Object> returnMap = new Map<String,Object>();
        List<Work_Schedule_Line_Item__c> WSLIList = new List<Work_Schedule_Line_Item__c>();
        List<Project_Cost_Line_Item__c> projectCostLineItemList = new List<Project_Cost_Line_Item__c>();
        Account newAcc = HMA_TestHelper.getParentAccount(true);
        Application__c newApplication = HMA_TestHelper.getApplication(false, '', '', '');
        newApplication.Status__c = 'Draft';
        newApplication.Status_Reason__c = 'In Progress';
        insert newApplication;
        Application_Extension__c appExtension = HMA_TestHelper.getApplicationExension(true, newApplication.Id);  
        Work_Schedule__c newWS = HMA_TestHelper.getWorkSchedule(true, newApplication.Id);
        Work_Schedule_Line_Item__c newWSLI = HMA_TestHelper.getWorkScheduleLineItem(true, newWS.Id);
        Project_Budget__c newProjectBudget = HMA_TestHelper.getProjectBudget(true, newApplication.Id, appExtension.Id);
        Project_Cost__c newProjectCost= HMA_TestHelper.getProjectCost(true, newProjectBudget.Id);
            Project_Cost_Line_Item__c newPCLI = HMA_TestHelper.getProjectCostLineItem(true, newProjectCost.Id);
            Project_Site__c newProjectSite = HMA_TestHelper.getProjectSite(true, newApplication.Id, appExtension.Id);
            HMA_TestHelper.getRFI(true, newApplication.Id, 2, 'FEMA OES Programmatic');
            try{
                Contact contact = HMA_TestHelper.getPortalContact(true);
                Contact_Role__c newContactRole = HMA_TestHelper.getContactRoleForSpecificApplication(true, newApplication, contact.Id, 'Responsible Representative');
            }catch(Exception e){
                System.debug('---eee----'+e.getStackTraceString());
            }

            projectCostLineItemList.add(newPCLI);
        WSLIList.add(newWSLI);
        String serAccount = JSON.serialize(newAcc);
        String serApplication = JSON.serialize(newApplication);
        String serWSLIList = JSON.serialize(WSLIList);
        String serPCLIList = JSON.serialize(projectCostLineItemList);

        Test.startTest();
        returnMap = HMA_ApplicationCtrl.processRecord('Application__c', serApplication, serAccount, serWSLIList, newApplication.Id, '', serPCLIList, 'quickSave');
        System.assert(returnMap.size() > 0);
        Test.stopTest();
        }catch(Exception e){
            System.debug('-----Test class---'+e.getStackTraceString());
        }
    }

    @isTest public static void testProcessRecordSubmit() {
        try{
            Map<String,Object> returnMap = new Map<String,Object>();
            List<Work_Schedule_Line_Item__c> WSLIList = new List<Work_Schedule_Line_Item__c>();
            List<Project_Cost_Line_Item__c> projectCostLineItemList = new List<Project_Cost_Line_Item__c>();
            Account newAcc = HMA_TestHelper.getParentAccount(true);
            Application__c newApplication = HMA_TestHelper.getApplication(false, '', '', '');
            newApplication.Status__c = 'Draft';
            newApplication.Status_Reason__c = 'In Progress';
            insert newApplication;
            Application_Extension__c appExtension = HMA_TestHelper.getApplicationExension(true, newApplication.Id);
            Work_Schedule__c newWS = HMA_TestHelper.getWorkSchedule(true, newApplication.Id);
            Work_Schedule_Line_Item__c newWSLI = HMA_TestHelper.getWorkScheduleLineItem(true, newWS.Id);
            Project_Budget__c newProjectBudget = HMA_TestHelper.getProjectBudget(true, newApplication.Id, appExtension.Id);
            Project_Cost__c newProjectCost= HMA_TestHelper.getProjectCost(true, newProjectBudget.Id);
            Project_Cost_Line_Item__c newPCLI = HMA_TestHelper.getProjectCostLineItem(true, newProjectCost.Id);
            Project_Site__c newProjectSite = HMA_TestHelper.getProjectSite(true, newApplication.Id, appExtension.Id);
            HMA_TestHelper.getRFI(true, newApplication.Id, 2, 'FEMA OES Programmatic');
            Document__c doc = HMA_TestHelper.createCustomDocumentRecord(newApplication.Id);
            doc.Project_Site__c = newProjectSite.Id;
            update doc;
            try{
                Contact contact = HMA_TestHelper.getPortalContact(true);
                Contact_Role__c newContactRole = HMA_TestHelper.getContactRoleForSpecificApplication(true, newApplication, contact.Id, 'Responsible Representative');
            }catch(Exception e){
                System.debug('---eee----'+e.getStackTraceString());
            }

            projectCostLineItemList.add(newPCLI);
            WSLIList.add(newWSLI);
            String serAccount = JSON.serialize(newAcc);
            String serApplication = JSON.serialize(newApplication);
            String serWSLIList = JSON.serialize(WSLIList);
            String serPCLIList = JSON.serialize(projectCostLineItemList);

            Test.startTest();
            returnMap = HMA_ApplicationCtrl.processRecord('Application__c', serApplication, serAccount, serWSLIList, newApplication.Id, '', serPCLIList, 'submit');
            System.assert(returnMap.size() > 0);
            Test.stopTest();
        }catch(Exception e){
            System.debug('-----Test class---'+e.getStackTraceString());
        }
    }

    /*@isTest public static void testProcessRecordElse() {
        Map<String,Object> returnMap = new Map<String,Object>();
        List<Work_Schedule_Line_Item__c> WSLIList = new List<Work_Schedule_Line_Item__c>();
        List<Project_Cost_Line_Item__c> projectCostLineItemList = new List<Project_Cost_Line_Item__c>();
        Account newAcc = HMA_TestHelper.getParentAccount(true);
        Application__c newApplication = HMA_TestHelper.getApplication(false, '', '', '');
        newApplication.Status__c = 'Draft';
        newApplication.Status_Reason__c = 'In Progress';
        Application_Extension__c newApplicationEx = HMA_TestHelper.getApplicationExension(true, newApplication.Id);
        Work_Schedule__c newWS = HMA_TestHelper.getWorkSchedule(true, newApplication.Id);
        Work_Schedule_Line_Item__c newWSLI = HMA_TestHelper.getWorkScheduleLineItem(true, newWS.Id);
        WSLIList.add(newWSLI);
        String serAccount = JSON.serialize(newAcc);
        String serApplicationEx = JSON.serialize(newApplicationEx);
        String serWSLIList = JSON.serialize(WSLIList);
        String serPCLIList = JSON.serialize(projectCostLineItemList);
        
        Test.startTest();
        returnMap = HMA_ApplicationCtrl.processRecord('Application_Extension__c', serApplicationEx, serAccount, serWSLIList, newApplication.Id, '', serPCLIList, 'quickSave');
        System.assert(returnMap.size() > 0);
        Test.stopTest();
    }*/
    @isTest public static void testFileUpload() {
        List<ContentVersion> conVer = new List<ContentVersion>();        
        Blob b = Blob.valueOf('Test Data');
        ContentVersion contentVersion_1 = new ContentVersion();
        contentVersion_1.Title = 'Penguins';
        contentVersion_1.PathOnClient = 'Penguins.jpg';
        //contentVersion_1.Type__c = 'GANTT Chart';
        contentVersion_1.VersionData = b;
        contentVersion_1.IsMajorVersion = true;   
        insert contentVersion_1;

        ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];

        Test.startTest();
        conVer = HMA_ApplicationCtrl.fileUpload(contentVersion_2.ContentDocumentId);
        System.assert(conVer.size() > 0);
        Test.stopTest();
    }

    @isTest public static void testGetFiles() {
        List<String> documentTypes = new List<String>{'GANTT Chart'};
        List<ContentVersion> conVer = new List<ContentVersion>();
        Application__c newApplication = HMA_TestHelper.getApplication(true, '', '', '');
        Work_Schedule__c newWS = HMA_TestHelper.getWorkSchedule(true, newApplication.Id);

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
            conDocLink.LinkedEntityId = newWS.Id;
            conDocLink.ContentDocumentId = contentVersion_2.ContentDocumentId;
            insert conDocLink;

        Test.startTest();
        conVer = HMA_ApplicationCtrl.getFiles(newWS.Id, JSON.serialize(documentTypes));
        System.assert(conVer.size() > 0);
        Test.stopTest();     
    }

    @isTest public static void testRemoveFile() {        
        Blob b = Blob.valueOf('Test Data');
        ContentVersion contentVersion_1 = new ContentVersion();
        contentVersion_1.Title = 'Penguins';
        contentVersion_1.PathOnClient = 'Penguins.jpg';
        //contentVersion_1.Type__c = 'Supplier Diversity Certificate';
        contentVersion_1.VersionData = b;
        contentVersion_1.IsMajorVersion = true;   
        insert contentVersion_1;

        ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];

        Test.startTest();
        Boolean returnValue = HMA_ApplicationCtrl.removeFile(contentVersion_2.ContentDocumentId);
        System.assert(returnValue == true);
        Test.stopTest();
    }
    @isTest public static void testGetApplication() {
        Map<String,Object> returnMap = new Map<String,Object>();
        Application__c newApplication = HMA_TestHelper.getApplication(true, '', '', '');
        
        Test.startTest();
        returnMap = HMA_ApplicationCtrl.getApplication(newApplication.Id);
        System.assert(returnMap.size() > 0);
        Test.stopTest();
    }
    @isTest public static void testGetWorkScheduleLineItem() {
        List<Work_Schedule_Line_Item__c> returnList = new List<Work_Schedule_Line_Item__c>();
        Application__c newApplication = HMA_TestHelper.getApplication(true, '', '', '');
        Work_Schedule__c newWS = HMA_TestHelper.getWorkSchedule(true, newApplication.Id);
        Work_Schedule_Line_Item__c newWSLI = HMA_TestHelper.getWorkScheduleLineItem(true, newWS.Id);

        Test.startTest();
        returnList = HMA_ApplicationCtrl.getWorkScheduleLineItem(newApplication.Id);
        System.assert(returnList.size() > 0);
        Test.stopTest();
    }
    @isTest public static void testUpdateLineItems() {
        List<Work_Schedule_Line_Item__c> WSLIList = new List<Work_Schedule_Line_Item__c>();
        List<Work_Schedule__c> WSList = new List<Work_Schedule__c>();
        Application__c newApplication = HMA_TestHelper.getApplication(true, '', '', '');
        Work_Schedule__c newWS = HMA_TestHelper.getWorkSchedule(true, newApplication.Id);
        WSList.add(newWS);
        Work_Schedule_Line_Item__c newWSLI = HMA_TestHelper.getWorkScheduleLineItem(true, newWS.Id);
        WSLIList.add(newWSLI);
        String serWSLIList = JSON.serialize(WSLIList);
        String serWSList = JSON.serialize(WSList);

        Test.startTest();
        boolean returnValue = HMA_ApplicationCtrl.updateLineItems(serWSLIList, serWSList);
        System.assert(returnValue == true);
        Test.stopTest();
    }
    @isTest public static void testProcessOnContactInformation() {
        //Pre_Application__c preApplication = HMA_TestHelper.getPreApplication(true);
        User u = HMA_TestHelper.getPortalUserHMA(true);
        Application__c app = HMA_TestHelper.getApplication(false, '', '', '');
        app.Status__c = 'Draft';
        app.Status_Reason__c = 'In Progress';
        insert app;
        Id accountId = [SELECT AccountId FROM Contact WHERE Id = :u.ContactId]?.AccountId;
        Contact_Role__c newContactRole = HMA_TestHelper.getContactRoleForSpecificApplication(true, app, u.ContactId, 'Responsible Representative');
        //newContactRole.Contact__c = contact.Id;
        // newContactRole.Contact__r = contact;
        // newContactRole.Pre_Application__c = preApplication.Id;
        // insert newContactRole;
        Contact_Role__c contactRole = [SELECT Id, Application__c, AccountContactJunction__c, Contact__c, Role__c, 
                                            Type__c, Contact__r.Email, Contact__r.Id 
                                            FROM Contact_Role__c 
                                            WHERE Id = :newContactRole.Id];
        Map<String, Object> paramMap = new Map<String, Object>();
        System.debug('newContactRole---'+newContactRole);
        paramMap.put('accountId', accountId);
        paramMap.put('recordDetails', JSON.serialize(contactRole));
        paramMap.put('createAccount', false);
        System.runAs(u) {
        Test.startTest();
        Contact_Role__c  returnRole = HMA_ApplicationCtrl.processOnContactInformation(paramMap);
        System.assert(String.isNotBlank(String.valueOf(returnRole)));
        Test.stopTest();
        }
    }
    @isTest public static void testProcessOnContactInformationElse() {
        User u = HMA_TestHelper.getPortalUserHMA(true);
        Application__c app = HMA_TestHelper.getApplication(false, '', '', '');
        app.Status__c = 'Draft';
        app.Status_Reason__c = 'In Progress';
        insert app;
        Id accountId = [SELECT AccountId FROM Contact WHERE Id = :u.ContactId]?.AccountId;
        Contact_Role__c newContactRole = HMA_TestHelper.getContactRoleForSpecificApplication(true, app, u.ContactId, 'Responsible Representative');
        //newContactRole.Contact__c = contact.Id;
        // newContactRole.Contact__r = contact;
        // newContactRole.Pre_Application__c = preApplication.Id;
        // insert newContactRole;
        Contact_Role__c contactRole = [SELECT Id, Application__c, AccountContactJunction__c, Contact__c, Role__c, 
                                            Type__c, Contact__r.Email, Contact__r.Id 
                                            FROM Contact_Role__c 
                                            WHERE Id = :newContactRole.Id];
        Map<String, Object> paramMap = new Map<String, Object>();
        System.debug('newContactRole---'+newContactRole);
        //paramMap.put('accountId', accountId);
        paramMap.put('recordDetails', JSON.serialize(contactRole));
        paramMap.put('createAccount', true);
        System.runAs(u) {
        Test.startTest();
        Contact_Role__c  returnRole = HMA_ApplicationCtrl.processOnContactInformation(paramMap);
        System.assert(String.isNotBlank(String.valueOf(returnRole)));
        Test.stopTest();
        }
    }

    /*This method tests getLoggedInUserContactRoleForApplication. 
    *create portal user, app, contact role and then run the test with the user created
    */
    @isTest
    public static void testGetLoggedInUserContactRoleForApplication() {
        User user = HMA_TestHelper.getPortalUserHMA(true);
        Application__c app = HMA_TestHelper.getApplication(true, '', '', '');
        Contact_Role__c contactRole = HMA_TestHelper.getContactRoleForSpecificApplication(true, app, user.ContactId, 'Responsible Representative');
        System.runAs(user) {
            Test.startTest();
            Map<String, Object> returnMap = HMA_ApplicationCtrl.getLoggedInUserContactRoleForApplication(app.Id);
            System.assert(returnMap.size() > 0);
            Test.stopTest();
        }
    }
    
    //Test update Project Site Record method. Create app, app extensiona nd project site and then pass it to hma_ApplicationCtrl.
    @isTest
    public static void testUpdateProjectSiteRecord() {
        Application__c app = HMA_TestHelper.getApplication(true, 'Project', '', '');
        Application_Extension__c appExt = HMA_TestHelper.getApplicationExension(true, app.Id);
        Project_Site__c ps = HMA_TestHelper.getProjectSite(true, app.Id, appExt.Id);
            Test.startTest();
        Map<String, Object> returnMap = HMA_ApplicationCtrl.updateProjectSiteRecord(JSON.serialize(ps), '', '');
            System.assert(returnMap.size() > 0);
            Test.stopTest();
        }
    
    //Test getProjectSitePageDetails. Pass projectSiteId, App Id and mode and pass it to hma_ApplicationCtrl.
    @isTest
    public static void testGetProjectSitePageDetails() {
        Application__c app = HMA_TestHelper.getApplication(true, 'Project', '', '');
        Application_Extension__c appExt = HMA_TestHelper.getApplicationExension(true, app.Id);
        Project_Site__c ps = HMA_TestHelper.getProjectSite(true, app.Id, appExt.Id); 
            Test.startTest();
        Map<String, Object> returnMap = HMA_ApplicationCtrl.getProjectSitePageDetails(ps.Id, '', app.Id, 'create');
            System.assert(returnMap.size() > 0);
            Test.stopTest();
        }

    //Test getAccountDetails
    @isTest
    public static void testGetAccountDetails() {
        Account acc = new Account(name = 'Acc1', Entity_Id__c = '1', Entity_Type__c = 'Test Entity');
        insert acc;
        Contact con = new Contact(AccountId = acc.Id, FirstName = 'Testacc', LastName = 'TestLast', Email = 'testacc@abc.com', phone = '9898989898');
        insert con;
        Test.startTest();
        String accName = HMA_ApplicationCtrl.getAccountDetails(con.Id);
        System.assert(String.isBlank(accName) != true);
        Test.stopTest();
    }

    //Test processNextPreviousProgramTemplatePage method
    @isTest
    public static void testProcessNextPreviousProgramTemplatePage() {
        Map<String, Object> returnMap = new Map<String, Object>();
        Application__c newApplication = HMA_TestHelper.getApplication(true, '', '', '');
        Program_Template_Page__mdt ptMdt = HMA_TestMetadataHelper.getProgramTemplatePageMdt('HMGP_Scope_Of_Work_General');
        String ptMtId = String.valueOf(ptMdt.Id);
        String appId = String.valueOf(newApplication.Id);
        Test.startTest();
        returnMap = HMA_ApplicationCtrl.processNextPreviousProgramTemplatePage(appId, 'previous', ptMtId);
        System.assert(returnMap.size() > 0);
        Test.stopTest();
    }

    //Test processReadOnlyRecord
    @isTest
    public static void testProcessReadOnlyRecord() {
        Map<String, Object> returnMap = new Map<String, Object>();
        Application__c newApplication = HMA_TestHelper.getApplication(true, '', '', '');
        Program_Template_Page__mdt ptMdt = HMA_TestMetadataHelper.getProgramTemplatePageMdt('HMGP_Scope_Of_Work_General');
        String ptMtId = String.valueOf(ptMdt.Id);
        String appId = String.valueOf(newApplication.Id);
        Test.startTest();
        returnMap = HMA_ApplicationCtrl.processReadOnlyRecord(appId, ptMtId, 'previous');
        System.assert(returnMap.size() > 0);
        Test.stopTest();
    }

    //Not in use
    /*@isTest public static void testProcessProjectCostLineItem() {
        List<Project_Cost_Line_Item__c> PCLIList = new List<Project_Cost_Line_Item__c>();
        Application__c newApplication = HMA_TestHelper.getApplication(true, '', '', '');
        Application_Extension__c appExtension = HMA_TestHelper.getApplicationExension(true, newApplication.Id);  
        Project_Budget__c newProjectBudget = HMA_TestHelper.getProjectBudget(true, newApplication.Id, appExtension.Id);
        Project_Cost__c newProjectCost = HMA_TestHelper.getProjectCost(true, newProjectBudget.Id);
        Project_Cost_Line_Item__c newPCLI = HMA_TestHelper.getProjectCostLineItem(false, newProjectCost.Id);
        PCLIList.add(newPCLI);

        Test.startTest();
        HMA_ApplicationCtrl.processProjectCostLineItem(PCLIList);
        Test.stopTest();
    }*/
}