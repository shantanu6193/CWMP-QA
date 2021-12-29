@isTest
public with sharing class HMA_CloneApplicationCtrlTest {
    @TestVisible
        private static Set<String> relationshipsToClone = new Set<String>{'Application_Extensions__r', 
                                                                    'Documents__r',
                                                                    'Project_Budgets__r', 
                                                                    'Project_Costs__r',
                                                                    'Project_Cost_Line_Items__r'};
    @isTest
    public static void testCloneApplication() {
        User user = HMA_TestHelper.getPortalUserHMA(true);
        System.debug('---test clone---'+user.contactId);
        Pre_Application__c preApp = HMA_TestHelper.getPreApplication(true);
        Application__c app = HMA_TestHelper.getApplication(false, '', '', '');
        app.Status__c = 'Draft';
        app.Status_Reason__c = 'In Progress';
        app.Pre_Application__c = preApp.Id;
        insert app;
        HMA_TestHelper.createCustomDocumentRecord(app.Id);
        Application_Extension__c appExt = HMA_TestHelper.getApplicationExension(true, app.Id);
        Document__c doc = HMA_TestHelper.createCustomDocumentRecord(app.Id);
        doc.Application_Extension__c = appExt.Id;
        update doc;
        Project_Budget__c pb = HMA_TestHelper.getProjectBudget(true, app.Id, appExt.Id);
        Project_Cost__c pc = HMA_TestHelper.getProjectCost(true, pb.Id);
        Project_Cost_Line_Item__c pcli1 = HMA_TestHelper.getProjectCostLineItem(true, pc.Id);
        //Contact_Role__c newContactRole = HMA_TestHelper.getContactRoleForSpecificApplication(true, app, user.contactId, 'Responsible Representative');
        List<Document__c> docs = new List<Document__c>{doc};
        // System.runAs(user) {
            Test.startTest();
            Map<String, Object> returnMap = HMA_CloneApplicationCtrl.CloneApplication(app.Id);
            HMA_CloneApplicationCtrl.cloneDocuments(docs, appExt.Id);
            System.assert(returnMap.size() > 0);
            Test.stopTest();
        // }
    }
}