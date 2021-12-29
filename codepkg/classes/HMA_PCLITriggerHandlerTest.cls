@isTest
public with sharing class HMA_PCLITriggerHandlerTest {
    @isTest
    public static void testTriggerScenarios() {
        Application__c app = HMA_TestHelper.getApplication(true, '', '', '');
        HMA_TestHelper.createCustomDocumentRecord(app.Id);
        Application_Extension__c appExt = HMA_TestHelper.getApplicationExension(false, app.Id);
        appExt.Total_Project_Cost__c = 0;
        appExt.Phase_1_Project_Costs__c = 0;
        appExt.Phase_2_Project_Costs__c = 0;
        insert appExt;
        Project_Site__c ps = HMA_TestHelper.getProjectSite(true, app.Id, appExt.Id);
        Project_Budget__c pb = HMA_TestHelper.getProjectBudget(true, app.Id, appExt.Id);
        Project_Cost__c pcb = HMA_TestHelper.getProjectCost(true, pb.Id);
        Project_Cost__c pcs = HMA_TestHelper.getProjectCostwithProjectSiteRecordType(true, ps.Id);
        Test.startTest();
            Project_Cost_Line_Item__c pcli1 = HMA_TestHelper.getProjectCostLineItem(false, pcb.Id);
            pcli1.Cost_Estimate_Total__c = 100;
            pcli1.Phase__c = 'Phase 1';
            pcli1.Cost_Type__c = 'Survey';
            pcli1.Item_Name__c = 'test';
            pcli1.Unit_Quantity__c = 2;
            pcli1.Unit_Measure__c = 'Each';
            pcli1.Unit_Cost__c = 50;
            Project_Cost_Line_Item__c pcli2 = HMA_TestHelper.getProjectCostLineItem(false, pcb.Id);
            pcli2.Cost_Estimate_Total__c = 100;
            pcli2.Phase__c = 'Phase 2';
            pcli2.Cost_Type__c = 'Survey';
            pcli2.Item_Name__c = 'test';
            pcli2.Unit_Quantity__c = 2;
            pcli2.Unit_Measure__c = 'Each';
            pcli2.Unit_Cost__c = 50;
            List<Project_Cost_Line_Item__c> pclis =  new List<Project_Cost_Line_Item__c>();
            pclis.add(pcli1);
            pclis.add(pcli2);
            insert pclis;
            for(Project_Cost_Line_Item__c pcli : pclis) {
                pcli.Cost_Estimate_Total__c = 200;
            }
            update pclis;
            for(Project_Cost_Line_Item__c pcli : pclis) {
                if(pcli.Phase__c == 'Phase 1') {
                    pcli.Cost_Estimate_Total__c = 210;
                    pcli.Phase__c = 'Phase 2';
                }
            }
            update pclis;
            for(Project_Cost_Line_Item__c pcli : pclis) {
                if(pcli.Phase__c == 'Phase 2') {
                    pcli.Cost_Estimate_Total__c = 220;
                    pcli.Phase__c = 'Phase 1';
                }
            }
            update pclis;
            for(Project_Cost_Line_Item__c pcli : pclis) {
                if(pcli.Phase__c == 'Phase 1') {
                    pcli.Phase__c = 'Phase 2';
                }
            }
            update pclis;
            for(Project_Cost_Line_Item__c pcli : pclis) {
                if(pcli.Phase__c == 'Phase 2') {
                    pcli.Phase__c = 'Phase 1';
                }
            }
            update pclis;
            for(Project_Cost_Line_Item__c pcli : pclis) {
                pcli.Cost_Estimate_Total__c = 400;
            }
            update pclis; 
            for(Project_Cost_Line_Item__c pcli : pclis) {
                pcli.Cost_Estimate_Total__c = 180;
            }
            update pclis;
            for(Project_Cost_Line_Item__c pcli : pclis) {
                if(pcli.Phase__c == 'Phase 1') {
                    pcli.Cost_Estimate_Total__c = 150;
                    pcli.Phase__c = 'Phase 2';
                }
            }
            update pclis;
            for(Project_Cost_Line_Item__c pcli : pclis) {
                if(pcli.Phase__c == 'Phase 2') {
                    pcli.Cost_Estimate_Total__c = 100;
                    pcli.Phase__c = 'Phase 1';
                }
            }
            update pclis;
            delete pclis;
        Test.stopTest();
    }

    @isTest
    public static void testTriggerScenariosSites() {
        Application__c app = HMA_TestHelper.getApplication(true, '', '', '');
        HMA_TestHelper.createCustomDocumentRecord(app.Id);
        Application_Extension__c appExt = HMA_TestHelper.getApplicationExension(false, app.Id);
        appExt.Total_Project_Cost__c = 0;
        appExt.Phase_1_Project_Costs__c = 0;
        appExt.Phase_2_Project_Costs__c = 0;
        insert appExt;
        Project_Site__c ps = HMA_TestHelper.getProjectSite(true, app.Id, appExt.Id);
        Project_Budget__c pb = HMA_TestHelper.getProjectBudget(true, app.Id, appExt.Id);
        Project_Cost__c pcb = HMA_TestHelper.getProjectCost(true, pb.Id);
        Project_Cost__c pcs = HMA_TestHelper.getProjectCostwithProjectSiteRecordType(true, ps.Id);
        Test.startTest();
            List<Project_Cost_Line_Item__c> pcliSites = new List<Project_Cost_Line_Item__c>();
            Project_Cost_Line_Item__c pcliSite1 = HMA_TestHelper.getProjectCostLineItem(false, pcs.Id);
            pcliSite1.Phase__c = 'Phase 1';
            pcliSites.add(pcliSite1);
            Project_Cost_Line_Item__c pcliSite2 = HMA_TestHelper.getProjectCostLineItem(false, pcs.Id);
            pcliSite2.Phase__c = 'Phase 2';
            pcliSites.add(pcliSite2);
            insert pcliSites; 
            for(Project_Cost_Line_Item__c pcli : pcliSites) {
                if(pcli.Phase__c == 'Phase 1') {
                    pcli.Cost_Estimate_Total__c = 210;
                    pcli.Phase__c = 'Phase 2';
                }
            }
            update pcliSites;
            for(Project_Cost_Line_Item__c pcli : pcliSites) {
                if(pcli.Phase__c == 'Phase 2') {
                    pcli.Cost_Estimate_Total__c = 220;
                    pcli.Phase__c = 'Phase 1';
                }
            }
            update pcliSites;
            for(Project_Cost_Line_Item__c pcli : pcliSites) {
                if(pcli.Phase__c == 'Phase 1') {
                    pcli.Phase__c = 'Phase 2';
                }
            }
            update pcliSites;
            for(Project_Cost_Line_Item__c pcli : pcliSites) {
                if(pcli.Phase__c == 'Phase 2') {
                    pcli.Phase__c = 'Phase 1';
                }
            }
            update pcliSites;
            for(Project_Cost_Line_Item__c pcli : pcliSites) {
                pcli.Cost_Estimate_Total__c = 400;
            }
            update pcliSites; 
            for(Project_Cost_Line_Item__c pcli : pcliSites) {
                pcli.Cost_Estimate_Total__c = 180;
            }
            update pcliSites;
            for(Project_Cost_Line_Item__c pcli : pcliSites) {
                if(pcli.Phase__c == 'Phase 1') {
                    pcli.Cost_Estimate_Total__c = 150;
                    pcli.Phase__c = 'Phase 2';
                }
            }
            update pcliSites;
            for(Project_Cost_Line_Item__c pcli : pcliSites) {
                if(pcli.Phase__c == 'Phase 2') {
                    pcli.Cost_Estimate_Total__c = 100;
                    pcli.Phase__c = 'Phase 1';
                }
            }
            update pcliSites;
            delete pcliSites;
        Test.stopTest();
    }
}