public without sharing class HMA_ProjectCostLineItemTriggerHandler extends TriggerHandler implements TriggerInterface {
    private Map<Id, application_extension__c> applicationExtensionMap;
    public HMA_ProjectCostLineItemTriggerHandler() {

    }

    public override void afterInsert() {
        calculateSumProjectCostLineItemsOnInsert((List<Project_Cost_Line_Item__c>) Trigger.new);
    }

    public override void afterUpdate() {
        calculateSumProjectCostLineItemsOnUpdate((Map<Id, Project_Cost_Line_Item__c>) Trigger.newMap, (Map<Id, Project_Cost_Line_Item__c>) Trigger.oldMap);
    }

    public override void beforeDelete() {
        calculateSumProjectCostLineItemsOnDelete((List<Project_Cost_Line_Item__c>) Trigger.old);
    }

    /* 
        Date : 8th June 2021
        Author : Rakesh
        This method calcualates the sum of project cost line items coresponding to
        application Extension on insertion of new record. Check the Initial value of
        total project cost and assign it accordingly.
    */
    private void calculateSumProjectCostLineItemsOnInsert(List<Project_Cost_Line_Item__c> costLineItems) {
        //create a map of id and application extension record
        costLineItems = queryAgainAllTheCostLineItems();
        Set<Id> applicationExtensionIdSet = new Set<Id>();
        for(Project_Cost_Line_Item__c pcli : costLineItems) {
            if(String.valueOf(pcli.Project_Cost__r.RecordType.DeveloperName).equals(HMA_CONSTANTS.PROJECT_COST_RECORDTYPE_PROJECT) && (pcli.Project_Cost__r.Project_Budget__r.Type__c).equals(HMA_CONSTANTS.PROJECT_BUDGET_TYPE_PROJECT) && (pcli.Project_Cost__r.Project_Budget__r.Application_Extension__c != null)) {
                applicationExtensionIdSet.add(pcli.Project_Cost__r.Project_Budget__r.Application_Extension__c);
            } else if(String.valueOf(pcli.Project_Cost__r.RecordType.DeveloperName).equals(HMA_CONSTANTS.PROJECT_COST_RECORDTYPE_PROJECT_SITE) && (pcli.Project_Cost__r.Project_Site__r.Application_Extension__c != null)) {
                applicationExtensionIdSet.add(pcli.Project_Cost__r.Project_Site__r.Application_Extension__c);
            } // Add Management Cost condition is required
        }
        prepareApplicationExtensionMap(applicationExtensionIdSet);
        for(Project_Cost_Line_Item__c pcli: costLineItems) {
            if(pcli?.Cost_Estimate_Total__c != null) {
                Application_Extension__c ae;
                if(String.valueOf(pcli.Project_Cost__r.RecordType.DeveloperName).equals(HMA_CONSTANTS.PROJECT_COST_RECORDTYPE_PROJECT) && (pcli.Project_Cost__r.Project_Budget__r.Type__c).equals(HMA_CONSTANTS.PROJECT_BUDGET_TYPE_PROJECT) && (pcli.Project_Cost__r.Project_Budget__r.Application_Extension__c != null)) {
                    ae = this.applicationExtensionMap.get(pcli.Project_Cost__r.Project_Budget__r.Application_Extension__c);

                    if(pcli.Phase__c == HMA_CONSTANTS.PROJECT_COST_LINE_ITEM_PHASE_PHASE_1) {
                        if(ae.Phase_1_Project_Costs__c != null) {
                            ae.Phase_1_Project_Costs__c += pcli.Cost_Estimate_Total__c;
                        }else {
                            ae.Phase_1_Project_Costs__c = pcli.Cost_Estimate_Total__c;
                        }                        
                    } else if(pcli.Phase__c == HMA_CONSTANTS.PROJECT_COST_LINE_ITEM_PHASE_PHASE_2) {
                        if(ae.Phase_2_Project_Costs__c != null) {
                            ae.Phase_2_Project_Costs__c += pcli.Cost_Estimate_Total__c;
                        }else {
                            ae.Phase_2_Project_Costs__c = pcli.Cost_Estimate_Total__c;
                        }
                    }

                    if(ae.Total_Project_Cost__c != null) {
                        ae.Total_Project_Cost__c += pcli.Cost_Estimate_Total__c;
                    } else {
                        ae.Total_Project_Cost__c = pcli.Cost_Estimate_Total__c;
                    }
                    this.applicationExtensionMap.put(pcli.Project_Cost__r.Project_Budget__r.Application_Extension__c, calculateOtherFieldValuesBasedOnTotalCost(ae));
                } else if(String.valueOf(pcli.Project_Cost__r.RecordType.DeveloperName).equals(HMA_CONSTANTS.PROJECT_COST_RECORDTYPE_PROJECT_SITE) && (pcli.Project_Cost__r.Project_Site__r.Application_Extension__c != null)) {
                    ae = this.applicationExtensionMap.get(pcli.Project_Cost__r.Project_Site__r.Application_Extension__c);

                    if(pcli.Phase__c == HMA_CONSTANTS.PROJECT_COST_LINE_ITEM_PHASE_PHASE_1) {
                        if(ae.Phase_1_Project_Costs__c != null) {
                            ae.Phase_1_Project_Costs__c += pcli.Cost_Estimate_Total__c;
                        }else {
                            ae.Phase_1_Project_Costs__c = pcli.Cost_Estimate_Total__c;
                        }                        
                    } else if(pcli.Phase__c == HMA_CONSTANTS.PROJECT_COST_LINE_ITEM_PHASE_PHASE_2) {
                        if(ae.Phase_2_Project_Costs__c != null) {
                            ae.Phase_2_Project_Costs__c += pcli.Cost_Estimate_Total__c;
                        }else {
                            ae.Phase_2_Project_Costs__c = pcli.Cost_Estimate_Total__c;
                        }
                    }

                    if(ae.Total_Project_Cost__c != null) {
                        ae.Total_Project_Cost__c += pcli.Cost_Estimate_Total__c;
                    } else {
                        ae.Total_Project_Cost__c = pcli.Cost_Estimate_Total__c;
                    }
                    this.applicationExtensionMap.put(pcli.Project_Cost__r.Project_Site__r.Application_Extension__c, calculateOtherFieldValuesBasedOnTotalCost(ae));
                }
            }
        }
        update this.applicationExtensionMap.values();
    }

    /* 
        Date : 8th June 2021
        Author : Rakesh
        This method calcualates the sum of project cost line items coresponding to
        application Extension on update. If net value if larger then add it else 
        subtract it from Total Project Cost of Application Extension.
    */

    private void calculateSumProjectCostLineItemsOnUpdate(Map<Id, Project_Cost_Line_Item__c> newCostLineItemMap, Map<Id, Project_Cost_Line_Item__c> oldCostLineItemMap) {
        List<Project_Cost_Line_Item__c> costLineItems = queryAgainAllTheCostLineItems();
        Set<Id> applicationExtensionIdSet = new Set<Id>();
        for(Project_Cost_Line_Item__c pcli : costLineItems) {
            if(String.valueOf(pcli.Project_Cost__r.RecordType.DeveloperName).equals(HMA_CONSTANTS.PROJECT_COST_RECORDTYPE_PROJECT) && (pcli.Project_Cost__r.Project_Budget__r.Type__c).equals(HMA_CONSTANTS.PROJECT_BUDGET_TYPE_PROJECT) && (pcli.Project_Cost__r.Project_Budget__r.Application_Extension__c != null)) {
                applicationExtensionIdSet.add(pcli.Project_Cost__r.Project_Budget__r.Application_Extension__c);
            } else if(String.valueOf(pcli.Project_Cost__r.RecordType.DeveloperName).equals(HMA_CONSTANTS.PROJECT_COST_RECORDTYPE_PROJECT_SITE) && (pcli.Project_Cost__r.Project_Site__r.Application_Extension__c != null)) {
                applicationExtensionIdSet.add(pcli.Project_Cost__r.Project_Site__r.Application_Extension__c);
            } // Add Management Cost condition is required
        }
        prepareApplicationExtensionMap(applicationExtensionIdSet);
        for(Project_Cost_Line_Item__c pcli: costLineItems) {
            Project_Cost_Line_Item__c newRec = newCostLineItemMap.get(pcli.Id);
            Project_Cost_Line_Item__c oldRec = oldCostLineItemMap.get(pcli.Id);
            Application_Extension__c ae;
            if(String.valueOf(pcli.Project_Cost__r.RecordType.DeveloperName).equals(HMA_CONSTANTS.PROJECT_COST_RECORDTYPE_PROJECT) && (pcli.Project_Cost__r.Project_Budget__r.Type__c).equals(HMA_CONSTANTS.PROJECT_BUDGET_TYPE_PROJECT) && (pcli.Project_Cost__r.Project_Budget__r.Application_Extension__c != null)) {
                ae = this.applicationExtensionMap.get(pcli.Project_Cost__r.Project_Budget__r.Application_Extension__c);
                if(newRec.Cost_Estimate_Total__c < oldRec.Cost_Estimate_Total__c) {
                    ae.Total_Project_Cost__c -= (oldRec.Cost_Estimate_Total__c - newRec.Cost_Estimate_Total__c);
                    if(oldRec.Phase__c == newRec.Phase__c) {
                        if(newRec.Phase__c == HMA_CONSTANTS.PROJECT_COST_LINE_ITEM_PHASE_PHASE_1) {
                            ae.Phase_1_Project_Costs__c -= (oldRec.Cost_Estimate_Total__c - newRec.Cost_Estimate_Total__c);                      
                        } else if(newRec.Phase__c == HMA_CONSTANTS.PROJECT_COST_LINE_ITEM_PHASE_PHASE_2) {
                            ae.Phase_2_Project_Costs__c -= (oldRec.Cost_Estimate_Total__c - newRec.Cost_Estimate_Total__c);
                        }
                    } else if(oldRec.Phase__c == HMA_CONSTANTS.PROJECT_COST_LINE_ITEM_PHASE_PHASE_2 && newRec.Phase__c == HMA_CONSTANTS.PROJECT_COST_LINE_ITEM_PHASE_PHASE_1) {
                        ae.Phase_2_Project_Costs__c -= oldRec.Cost_Estimate_Total__c;
                        if(ae.Phase_1_Project_Costs__c != null) {
                            ae.Phase_1_Project_Costs__c += newRec.Cost_Estimate_Total__c;
                        } else {
                            ae.Phase_1_Project_Costs__c = newRec.Cost_Estimate_Total__c;
                        }
                    } else if(oldRec.Phase__c == HMA_CONSTANTS.PROJECT_COST_LINE_ITEM_PHASE_PHASE_1 && newRec.Phase__c == HMA_CONSTANTS.PROJECT_COST_LINE_ITEM_PHASE_PHASE_2) {
                        ae.Phase_1_Project_Costs__c -= oldRec.Cost_Estimate_Total__c;
                        if(ae.Phase_2_Project_Costs__c != null) {
                            ae.Phase_2_Project_Costs__c += newRec.Cost_Estimate_Total__c;
                        } else {
                            ae.Phase_2_Project_Costs__c = newRec.Cost_Estimate_Total__c;
                        }
                    }
                    
                } else if(newRec.Cost_Estimate_Total__c > oldRec.Cost_Estimate_Total__c) {
                    ae.Total_Project_Cost__c += (newRec.Cost_Estimate_Total__c - oldRec.Cost_Estimate_Total__c);
                    if(oldRec.Phase__c == newRec.Phase__c) {
                        if(newRec.Phase__c == HMA_CONSTANTS.PROJECT_COST_LINE_ITEM_PHASE_PHASE_1) {
                            ae.Phase_1_Project_Costs__c += (newRec.Cost_Estimate_Total__c - oldRec.Cost_Estimate_Total__c);
                        } else if(pcli.Phase__c == HMA_CONSTANTS.PROJECT_COST_LINE_ITEM_PHASE_PHASE_2) {
                            ae.Phase_2_Project_Costs__c += (newRec.Cost_Estimate_Total__c - oldRec.Cost_Estimate_Total__c);
                        }
                    } else if(oldRec.Phase__c == HMA_CONSTANTS.PROJECT_COST_LINE_ITEM_PHASE_PHASE_2 && newRec.Phase__c == HMA_CONSTANTS.PROJECT_COST_LINE_ITEM_PHASE_PHASE_1) {
                        ae.Phase_2_Project_Costs__c -= oldRec.Cost_Estimate_Total__c;
                        if(ae.Phase_1_Project_Costs__c != null) {
                            ae.Phase_1_Project_Costs__c += newRec.Cost_Estimate_Total__c;
                        } else {
                            ae.Phase_1_Project_Costs__c = newRec.Cost_Estimate_Total__c;
                        }
                        
                    } else if(oldRec.Phase__c == HMA_CONSTANTS.PROJECT_COST_LINE_ITEM_PHASE_PHASE_1 && newRec.Phase__c == HMA_CONSTANTS.PROJECT_COST_LINE_ITEM_PHASE_PHASE_2) {
                        ae.Phase_1_Project_Costs__c -= oldRec.Cost_Estimate_Total__c;
                        if(ae.Phase_2_Project_Costs__c != null) {
                            ae.Phase_2_Project_Costs__c += newRec.Cost_Estimate_Total__c;
                        } else {
                            ae.Phase_2_Project_Costs__c = newRec.Cost_Estimate_Total__c;
                        }
                        
                    }
                    
                } else if(newRec.Cost_Estimate_Total__c == oldRec.Cost_Estimate_Total__c && oldRec.Phase__c != newRec.Phase__c) {
                    if(oldRec.Phase__c == HMA_CONSTANTS.PROJECT_COST_LINE_ITEM_PHASE_PHASE_2 && newRec.Phase__c == HMA_CONSTANTS.PROJECT_COST_LINE_ITEM_PHASE_PHASE_1) {
                        ae.Phase_2_Project_Costs__c -= oldRec.Cost_Estimate_Total__c;
                        if(ae.Phase_1_Project_Costs__c != null) {
                            ae.Phase_1_Project_Costs__c += newRec.Cost_Estimate_Total__c;
                        } else {
                            ae.Phase_1_Project_Costs__c = newRec.Cost_Estimate_Total__c;
                        }
                        
                    } else if(oldRec.Phase__c == HMA_CONSTANTS.PROJECT_COST_LINE_ITEM_PHASE_PHASE_1 && newRec.Phase__c == HMA_CONSTANTS.PROJECT_COST_LINE_ITEM_PHASE_PHASE_2) {
                        ae.Phase_1_Project_Costs__c -= oldRec.Cost_Estimate_Total__c;
                        if(ae.Phase_2_Project_Costs__c != null) {
                            ae.Phase_2_Project_Costs__c += newRec.Cost_Estimate_Total__c;
                        } else {
                            ae.Phase_2_Project_Costs__c = newRec.Cost_Estimate_Total__c;
                        }
                        
                    }
                }
                this.applicationExtensionMap.put(pcli.Project_Cost__r.Project_Budget__r.Application_Extension__c, calculateOtherFieldValuesBasedOnTotalCost(ae));
            } else if(String.valueOf(pcli.Project_Cost__r.RecordType.DeveloperName).equals(HMA_CONSTANTS.PROJECT_COST_RECORDTYPE_PROJECT_SITE) && (pcli.Project_Cost__r.Project_Site__r.Application_Extension__c != null)) {
                ae = this.applicationExtensionMap.get(pcli.Project_Cost__r.Project_Site__r.Application_Extension__c);
                if(newRec.Cost_Estimate_Total__c < oldRec.Cost_Estimate_Total__c) {
                    ae.Total_Project_Cost__c -= (oldRec.Cost_Estimate_Total__c - newRec.Cost_Estimate_Total__c);
                    if(oldRec.Phase__c == newRec.Phase__c) {
                        if(newRec.Phase__c == HMA_CONSTANTS.PROJECT_COST_LINE_ITEM_PHASE_PHASE_1) {
                            ae.Phase_1_Project_Costs__c -= (oldRec.Cost_Estimate_Total__c - newRec.Cost_Estimate_Total__c);                      
                        } else if(newRec.Phase__c == HMA_CONSTANTS.PROJECT_COST_LINE_ITEM_PHASE_PHASE_2) {
                            ae.Phase_2_Project_Costs__c -= (oldRec.Cost_Estimate_Total__c - newRec.Cost_Estimate_Total__c);
                        }
                    } else if(newRec.Phase__c == HMA_CONSTANTS.PROJECT_COST_LINE_ITEM_PHASE_PHASE_1) {
                        ae.Phase_2_Project_Costs__c -= oldRec.Cost_Estimate_Total__c;
                        if(ae.Phase_1_Project_Costs__c != null) {
                            ae.Phase_1_Project_Costs__c += newRec.Cost_Estimate_Total__c;
                        } else {
                            ae.Phase_1_Project_Costs__c = newRec.Cost_Estimate_Total__c;
                        }
                    } else if(newRec.Phase__c == HMA_CONSTANTS.PROJECT_COST_LINE_ITEM_PHASE_PHASE_2) {
                        ae.Phase_1_Project_Costs__c -= oldRec.Cost_Estimate_Total__c;
                        if(ae.Phase_2_Project_Costs__c != null) {
                            ae.Phase_2_Project_Costs__c += newRec.Cost_Estimate_Total__c;
                        } else {
                            ae.Phase_2_Project_Costs__c = newRec.Cost_Estimate_Total__c;
                        }
                    }
                } else if(newRec.Cost_Estimate_Total__c > oldRec.Cost_Estimate_Total__c) {
                    ae.Total_Project_Cost__c += (newRec.Cost_Estimate_Total__c - oldRec.Cost_Estimate_Total__c);
                    if(oldRec.Phase__c == newRec.Phase__c) {
                        if(newRec.Phase__c == HMA_CONSTANTS.PROJECT_COST_LINE_ITEM_PHASE_PHASE_1) {
                            ae.Phase_1_Project_Costs__c += (newRec.Cost_Estimate_Total__c - oldRec.Cost_Estimate_Total__c);
                        } else if(newRec.Phase__c == HMA_CONSTANTS.PROJECT_COST_LINE_ITEM_PHASE_PHASE_2) {
                            ae.Phase_2_Project_Costs__c += (newRec.Cost_Estimate_Total__c - oldRec.Cost_Estimate_Total__c);
                        }
                    } else if(oldRec.Phase__c == HMA_CONSTANTS.PROJECT_COST_LINE_ITEM_PHASE_PHASE_2 && newRec.Phase__c == HMA_CONSTANTS.PROJECT_COST_LINE_ITEM_PHASE_PHASE_1) {
                        ae.Phase_2_Project_Costs__c -= oldRec.Cost_Estimate_Total__c;
                        if(ae.Phase_1_Project_Costs__c != null) {
                            ae.Phase_1_Project_Costs__c += newRec.Cost_Estimate_Total__c;
                        } else {
                            ae.Phase_1_Project_Costs__c = newRec.Cost_Estimate_Total__c;
                        }
                    } else if(oldRec.Phase__c == HMA_CONSTANTS.PROJECT_COST_LINE_ITEM_PHASE_PHASE_1 && newRec.Phase__c == HMA_CONSTANTS.PROJECT_COST_LINE_ITEM_PHASE_PHASE_2) {
                        ae.Phase_1_Project_Costs__c -= oldRec.Cost_Estimate_Total__c;
                        if(ae.Phase_2_Project_Costs__c != null) {
                            ae.Phase_2_Project_Costs__c += newRec.Cost_Estimate_Total__c;
                        } else {
                            ae.Phase_2_Project_Costs__c = newRec.Cost_Estimate_Total__c;
                        }
                    }
                }else if(newRec.Cost_Estimate_Total__c == oldRec.Cost_Estimate_Total__c && oldRec.Phase__c != newRec.Phase__c) {
                    if(oldRec.Phase__c == HMA_CONSTANTS.PROJECT_COST_LINE_ITEM_PHASE_PHASE_2 && newRec.Phase__c == HMA_CONSTANTS.PROJECT_COST_LINE_ITEM_PHASE_PHASE_1) {
                        ae.Phase_2_Project_Costs__c -= oldRec.Cost_Estimate_Total__c;
                        if(ae.Phase_1_Project_Costs__c != null) {
                            ae.Phase_1_Project_Costs__c += newRec.Cost_Estimate_Total__c;
                        } else {
                            ae.Phase_1_Project_Costs__c = newRec.Cost_Estimate_Total__c;
                        }
                        
                    } else if(oldRec.Phase__c == HMA_CONSTANTS.PROJECT_COST_LINE_ITEM_PHASE_PHASE_1 && newRec.Phase__c == HMA_CONSTANTS.PROJECT_COST_LINE_ITEM_PHASE_PHASE_2) {
                        ae.Phase_1_Project_Costs__c -= oldRec.Cost_Estimate_Total__c;
                        if(ae.Phase_2_Project_Costs__c != null) {
                            ae.Phase_2_Project_Costs__c += newRec.Cost_Estimate_Total__c;
                        } else {
                            ae.Phase_2_Project_Costs__c = newRec.Cost_Estimate_Total__c;
                        }
                        
                    }
                }
                this.applicationExtensionMap.put(pcli.Project_Cost__r.Project_Site__r.Application_Extension__c, calculateOtherFieldValuesBasedOnTotalCost(ae));
            }
        }
        update this.applicationExtensionMap.values();
    }


    /* 
        Date : 8th June 2021
        Author : Rakesh
        This method calcualates the sum of project cost line items coresponding to
        application Extension on delete. 
    */

    private void calculateSumProjectCostLineItemsOnDelete(List<Project_Cost_Line_Item__c> costLineItems) {
        costLineItems = queryAgainAllTheCostLineItems();
        Set<Id> applicationExtensionIdSet = new Set<Id>();
        for(Project_Cost_Line_Item__c pcli : costLineItems) {
            if(String.valueOf(pcli.Project_Cost__r.RecordType.DeveloperName).equals(HMA_CONSTANTS.PROJECT_COST_RECORDTYPE_PROJECT) && (pcli.Project_Cost__r.Project_Budget__r.Type__c).equals(HMA_CONSTANTS.PROJECT_BUDGET_TYPE_PROJECT) && (pcli.Project_Cost__r.Project_Budget__r.Application_Extension__c != null)) {
                applicationExtensionIdSet.add(pcli.Project_Cost__r.Project_Budget__r.Application_Extension__c);
            } else if(String.valueOf(pcli.Project_Cost__r.RecordType.DeveloperName).equals(HMA_CONSTANTS.PROJECT_COST_RECORDTYPE_PROJECT_SITE) && (pcli.Project_Cost__r.Project_Site__r.Application_Extension__c != null)) {
                applicationExtensionIdSet.add(pcli.Project_Cost__r.Project_Site__r.Application_Extension__c);
            } // Add Management Cost condition is required 
        }
        prepareApplicationExtensionMap(applicationExtensionIdSet);
        for(Project_Cost_Line_Item__c pcli: costLineItems) {
            Application_Extension__c ae;
            if(String.valueOf(pcli.Project_Cost__r.RecordType.DeveloperName).equals(HMA_CONSTANTS.PROJECT_COST_RECORDTYPE_PROJECT) && (pcli.Project_Cost__r.Project_Budget__r.Type__c).equals(HMA_CONSTANTS.PROJECT_BUDGET_TYPE_PROJECT) && (pcli.Project_Cost__r.Project_Budget__r.Application_Extension__c != null)) {
                ae = this.applicationExtensionMap.get(pcli.Project_Cost__r.Project_Budget__r.Application_Extension__c);
                ae.Total_Project_Cost__c -= pcli.Cost_Estimate_Total__c;
                if(pcli.Phase__c == HMA_CONSTANTS.PROJECT_COST_LINE_ITEM_PHASE_PHASE_1) {
                    ae.Phase_1_Project_Costs__c -= pcli.Cost_Estimate_Total__c;                      
                } else if(pcli.Phase__c == HMA_CONSTANTS.PROJECT_COST_LINE_ITEM_PHASE_PHASE_2) {
                    ae.Phase_2_Project_Costs__c -= pcli.Cost_Estimate_Total__c;
                }
                this.applicationExtensionMap.put(pcli.Project_Cost__r.Project_Budget__r.Application_Extension__c, calculateOtherFieldValuesBasedOnTotalCost(ae));
            } else if(String.valueOf(pcli.Project_Cost__r.RecordType.DeveloperName).equals(HMA_CONSTANTS.PROJECT_COST_RECORDTYPE_PROJECT_SITE) && (pcli.Project_Cost__r.Project_Site__r.Application_Extension__c != null)) {
                ae = this.applicationExtensionMap.get(pcli.Project_Cost__r.Project_Site__r.Application_Extension__c);
                ae.Total_Project_Cost__c -= pcli.Cost_Estimate_Total__c;
                if(pcli.Phase__c == HMA_CONSTANTS.PROJECT_COST_LINE_ITEM_PHASE_PHASE_1) {
                    ae.Phase_1_Project_Costs__c -= pcli.Cost_Estimate_Total__c;                      
                } else if(pcli.Phase__c == HMA_CONSTANTS.PROJECT_COST_LINE_ITEM_PHASE_PHASE_2) {
                    ae.Phase_2_Project_Costs__c -= pcli.Cost_Estimate_Total__c;
                }
                this.applicationExtensionMap.put(pcli.Project_Cost__r.Project_Site__r.Application_Extension__c, calculateOtherFieldValuesBasedOnTotalCost(ae));
            }
        }
        update this.applicationExtensionMap.values();
    }

    /* 
        Date : 8th June 2021
        Author : Rakesh
        This method fetches application Extension record and creates a map of Application_Extension__c and it's Id as key.
    */
    private void prepareApplicationExtensionMap(Set<Id> appExtensionIdSet) {
        this.applicationExtensionMap = new Map<Id, application_extension__c>();
        if(appExtensionIdSet?.size() <= 0) return;
        List<Application_Extension__c> appExtensions = [SELECT Id, Total_Project_Cost__c, Non_Federal_Cost_Share_Match_Percentage__c,
                                                                Phase_1_Project_Costs__c, Phase_2_Project_Costs__c
                                                            FROM 
                                                                Application_Extension__c 
                                                            WHERE 
                                                                Id IN :(appExtensionIdSet)];
        for(Application_Extension__c ae : appExtensions) { 
            this.applicationExtensionMap.put(ae.Id, ae);
        }
    }

    /* 
        Date : 9th June 2021
        Author : Rakesh
        This is a utility method which queries related field of Project Cost Line Item using trigger context
    */
    private List<Project_Cost_Line_Item__c> queryAgainAllTheCostLineItems() {
        Set<Id> listIds = new Set<Id>();
        if(Trigger.newMap != NULL) listIds.addAll(Trigger.newMap.keySet());
        else listIds.addAll(Trigger.oldMap.keySet());
        return [SELECT Id, Phase__c, Cost_Estimate_Total__c, Project_Cost__r.Project_Budget__r.Application_Extension__c,
                        Project_Cost__r.Project_Budget__r.Type__c,
                        Project_Cost__r.Project_Site__r.Application_Extension__c, Project_Cost__r.RecordType.DeveloperName
                    FROM Project_Cost_Line_Item__c
                    WHERE Id IN :listIds];
    }

    /*
        Date : 10th June 2021
        Author : Rakesh
        This is a utility method which calculates the Non Federal Cost Share Match and Federal Share Request values
    */
    private Application_Extension__c calculateOtherFieldValuesBasedOnTotalCost(Application_Extension__c ae) {
        ae.Non_Federal_Cost_Share_Match__c = (ae.Total_Project_Cost__c * ae.Non_Federal_Cost_Share_Match_Percentage__c)/100;
        ae.Federal_Share_Request__c = ae.Total_Project_Cost__c - ae.Non_Federal_Cost_Share_Match__c;
        return ae;
    }
}