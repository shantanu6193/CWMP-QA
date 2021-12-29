public with sharing class ApplicationHelper {
    public static void processToCreateWSAndWSLI(Set<Id> appIds) {
        try {
            //Map<String, Set<Id>> paramMap = new Map<String, Set<Id>>();
            Set<Id> appIdsOfPlanning = new Set<Id>();
            Set<Id> appIdsOfPhasedNo = new Set<Id>();
            Set<Id> appIdsOfPhasedYes = new Set<Id>();
            if(appIds.size() > 0) {
                List<Application__c> appDetailList = [SELECT Id, 
                                                                Application_Type__c, 
                                                                Subapplicant_Entity__c,
                                                                Subapplicant_Entity__r.Is_this_project_phased__c,
                                                                (SELECT Id FROM Work_Schedules__r)
                                                                FROM Application__c WHERE Id IN: appIds];
    
                for(Application__c app : appDetailList) {
                    if(app.Application_Type__c == HMA_CONSTANTS.APPLICATION_SUBAPPLICATION_TYPE_PLANNING) {
                        appIdsOfPlanning.add(app.Id);
                    } else if(checkSubApplicationType(app.Application_Type__c) && app.Subapplicant_Entity__r.Is_this_project_phased__c == 'No') {
                        appIdsOfPhasedNo.add(app.Id);
                    } else if(checkSubApplicationType(app.Application_Type__c) && app.Subapplicant_Entity__r.Is_this_project_phased__c == 'Yes') {
                        appIdsOfPhasedYes.add(app.Id);
                    }
                }

                if(appIdsOfPlanning.size() > 0) {
                    ApplicationHelper.deleteWorkSchedules(appIdsOfPlanning);
                    ApplicationHelper.createWorkSchedules(new Map<String,Set<Id>>{'appIdsOfPlanning' => appIdsOfPlanning});
                }
                if(appIdsOfPhasedNo.size() > 0) {
                    ApplicationHelper.deleteWorkSchedules(appIdsOfPhasedNo);
                    ApplicationHelper.createWorkSchedules(new Map<String,Set<Id>>{'appIdsOfPhasedNo' => appIdsOfPhasedNo});
                }
                if(appIdsOfPhasedYes.size() > 0) {
                    ApplicationHelper.deleteWorkSchedules(appIdsOfPhasedYes);
                    ApplicationHelper.createWorkSchedules(new Map<String,Set<Id>>{'appIdsOfPhasedYes' => appIdsOfPhasedYes});
                }
            }
        } catch (Exception e) {
            System.debug('error_processToCreateWSAndWSLI: ' + e);
            throw new AuraHandledException(e.getMessage());
        }               
    }
    
    public static void createWorkSchedules(Map<String,Set<Id>> paramMap) {
        Set<Id> WSIds = new Set<Id>();
        List<Work_Schedule__c> workSchedules = new List<Work_Schedule__c>();
        for(Id appId : paramMap.values()[0]) {
            Work_Schedule__c ws = new Work_Schedule__c(Application__c = appId);
            workSchedules.add(ws);
        }        
        insert workSchedules;
        for(Work_Schedule__c workS : workSchedules) {
            WSIds.add(workS.Id);
        }
        if(paramMap.keySet().contains('appIdsOfPlanning')) {
            ApplicationHelper.createWorkScheduleLineItems(WSIds);
            ApplicationHelper.createCloseoutWorkScheduleLineItems(WSIds);
        } else if(paramMap.keySet().contains('appIdsOfPhasedNo')) {
            ApplicationHelper.createCloseoutWorkScheduleLineItems(WSIds);
        } else if(paramMap.keySet().contains('appIdsOfPhasedYes')) {
            ApplicationHelper.createPhaseWorkScheduleLineItems(WSIds);
            ApplicationHelper.createCloseoutWorkScheduleLineItems(WSIds);
        }
    }


    public static void createWorkScheduleLineItems(Set<Id> WSIds) {
        try {
            List<Work_Schedule_Line_Item__c> WSLIList = new List<Work_Schedule_Line_Item__c>();
            List<String> phasePicklistValues = new List<String>();
            phasePicklistValues.add(HMA_CONSTANTS.WSLI_PHASE_THE_PLANNING_PROCESS);
            phasePicklistValues.add(HMA_CONSTANTS.WSLI_PHASE_HAZARD_IDENTIFICATION);
            phasePicklistValues.add(HMA_CONSTANTS.WSLI_PHASE_RISK_ASSESSMENT);
            phasePicklistValues.add(HMA_CONSTANTS.WSLI_PHASE_MITIGATION_STRATEGY);
            phasePicklistValues.add(HMA_CONSTANTS.WSLI_PHASE_PLAN_PREPARATION);
            phasePicklistValues.add(HMA_CONSTANTS.WSLI_PHASE_PLAN_DRAFTING);
            phasePicklistValues.add(HMA_CONSTANTS.WSLI_PHASE_PUBLIC_OUTREACH_MEETINGS_PUBLICHEARINGS);
            phasePicklistValues.add(HMA_CONSTANTS.WSLI_PHASE_PLAN_ADOPTION);

            for(Id WSId : WSIds) {
                for(String phaseValue : phasePicklistValues) {                        
                    Work_Schedule_Line_Item__c wsli = new Work_Schedule_Line_Item__c(Work_Schedule__c = WSId, Phase__c = phaseValue);
                    WSLIList.add(wsli);
                }
            }            
            insert WSLIList;
            
        } catch (Exception e) {
            System.debug('error: ' + e);
        }
    }
    public static void createPhaseWorkScheduleLineItems(Set<Id> WSIds) {
        List<Work_Schedule_Line_Item__c> WSLIList = new List<Work_Schedule_Line_Item__c>();
        for(Id WSId : WSIds) {
            Work_Schedule_Line_Item__c wsliPhase1 = new Work_Schedule_Line_Item__c(Work_Schedule__c = WSId, Phase__c = HMA_CONSTANTS.WSLI_PHASE_PHASE1);
            Work_Schedule_Line_Item__c wsliPhase2 = new Work_Schedule_Line_Item__c(Work_Schedule__c = WSId, Phase__c = HMA_CONSTANTS.WSLI_PHASE_PHASE2);
            WSLIList.add(wsliPhase1);
            WSLIList.add(wsliPhase2);
        }
        insert WSLIList;
    }
    public static void createCloseoutWorkScheduleLineItems(Set<Id> WSIds) {
        List<Work_Schedule_Line_Item__c> WSLIList = new List<Work_Schedule_Line_Item__c>();
        for(Id WSId : WSIds) {
            Work_Schedule_Line_Item__c wsli = new Work_Schedule_Line_Item__c(Work_Schedule__c = WSId, Phase__c = 'Closeout', Task_Name__c = 'Closeout', Description__c = 'Project Closeout line item', Duration_Months__c = '3');
            WSLIList.add(wsli);
        }
        insert WSLIList;
    }

    
    public static void deleteWorkSchedules(Set<Id> appIds) {
        try {
            List<Work_Schedule__c> wsList = new List<Work_Schedule__c>();
            wsList = [SELECT Id FROM Work_Schedule__c WHERE Application__c IN: appIds];
            if(wsList.size() > 0) {
                delete wsList;
            }            
            //delete[SELECT Id FROM Work_Schedule__c WHERE Application__c IN: appIds];
        } catch (Exception e) {
            System.debug('error: ' + e);
        }
    }
    private static Boolean checkSubApplicationType(String subApplicationType) {
        return (subApplicationType == HMA_CONSTANTS.APPLICATION_SUBAPPLICATION_TYPE_PROJECT || 
                subApplicationType == HMA_CONSTANTS.APPLICATION_SUBAPPLICATION_TYPE_5INITIATIVE || 
                subApplicationType == HMA_CONSTANTS.APPLICATION_SUBAPPLICATION_TYPE_PLANNING_RELATED) ? true : false;
    }
}