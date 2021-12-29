/***********************************************************************************************************************************
* Class Name   : REAL_UpdateAwardRecordNewFieldsBatch
* Description  : This batch job is created to update the Award record new fields which are created for Docu Gen requirements.
* Author       : Ricky
* Created On   : 17/07/2020
* Modification Log:
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Ricky              17/07/2020       Initial Implementation
**************************************************************************************************************************************/

public with sharing class REAL_UpdateAwardRecordNewFieldsBatch implements Database.Batchable<SObject>, Schedulable {
    private final String query;

    public REAL_UpdateAwardRecordNewFieldsBatch(String query) {
        this.query = query;
    }

    // Schedulable method
    public void execute(SchedulableContext ctx) {
        Database.executeBatch(new REAL_UpdateAwardRecordNewFieldsBatch(query));
    }

    // Database.Batchable methods
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<SObject> scope) {
        List<Project__c> projectWithRelatedAwardList = (List<Project__c>) scope;
        List<Award__c> awardToUpdateList = new List<Award__c>();

        for (Project__c  projectRecordToProcess : projectWithRelatedAwardList) {
            Award__c updatedAwardRecord = new Award__c();

            for (Award__c awardToProcess : projectRecordToProcess.Awards__r) {

                awardToProcess.State_Admin__c = projectRecordToProcess.StateAdmin__c == null ? 0.00 : projectRecordToProcess.StateAdmin__c;
                awardToProcess.Federal_Retention_Share__c = projectRecordToProcess.Federal_Retention__c == null ? 0.00 : projectRecordToProcess.Federal_Retention__c;
                awardToProcess.State_Retention_Share__c = projectRecordToProcess.State_Retention__c == null ? 0.00 : projectRecordToProcess.State_Retention__c;

                Decimal femaShare = awardToProcess.FEMA_Share__c == null ? 0.00 : awardToProcess.FEMA_Share__c;
                Decimal stateShare = awardToProcess.State_Share__c == null ? 0.00 : awardToProcess.State_Share__c;
                Decimal supplementAmount = awardToProcess.Supplement_Award__c == null ? 0.00 : awardToProcess.Supplement_Award__c;
                Decimal newObligatedAmount = awardToProcess.AmountObligated__c == null ? 0.00 : awardToProcess.AmountObligated__c;

                if (awardToProcess.Amendment_Request__c == null) {
                    awardToProcess.Supplement_Number__c = projectRecordToProcess.Supplement_Number__c == null ? null : projectRecordToProcess.Supplement_Number__c;
                    awardToProcess.Federal_Project_Amount__c = ((newObligatedAmount * femaShare)/100)?.setScale(2,system.RoundingMode.DOWN);
                    awardToProcess.State_Project_Amount__c = ((newObligatedAmount * stateShare)/100)?.setScale(2,system.RoundingMode.DOWN);
                    awardToProcess.State_Admin_Amount__c = ((awardToProcess.State_Project_Amount__c * awardToProcess.State_Admin__c)/100)?.setScale(2,system.RoundingMode.DOWN);
                    awardToProcess.Federal_Supplement_Amount__c = awardToProcess.Federal_Project_Amount__c;
                    awardToProcess.State_Supplement_Amount__c = awardToProcess.State_Project_Amount__c;
                    awardToProcess.State_Admin_Supplement_Amount__c = awardToProcess.State_Admin_Amount__c;
                    awardToProcess.FDSR__c = projectRecordToProcess.Project_Number__c == null ? null : projectRecordToProcess.Project_Number__c;
                    awardToProcess.Supplement_Award__c = awardToProcess.AmountObligated__c == null ? 0.00 : awardToProcess.AmountObligated__c;
                    awardToProcess.Previous_Amount_Obligated__c = 0;

                    updatedAwardRecord.Federal_Project_Amount__c = awardToProcess.Federal_Project_Amount__c == null ? 0.00 : awardToProcess.Federal_Project_Amount__c;
                    updatedAwardRecord.State_Project_Amount__c = awardToProcess.State_Project_Amount__c == null ? 0.00 : awardToProcess.State_Project_Amount__c;
                    updatedAwardRecord.State_Admin_Amount__c = awardToProcess.State_Admin_Amount__c == null ? 0.00 : awardToProcess.State_Admin_Amount__c;
                }
                else if (awardToProcess.Amendment_Request__c != null) {
                    awardToProcess.Supplement_Number__c = awardToProcess.Amendment_Request__r.SupplementNumber__c == null ? null : awardToProcess.Amendment_Request__r.SupplementNumber__c;
                    awardToProcess.Federal_Project_Amount__c = ((newObligatedAmount * femaShare)/100)?.setScale(2,system.RoundingMode.DOWN);
                    awardToProcess.State_Project_Amount__c = ((newObligatedAmount * stateShare)/100)?.setScale(2,system.RoundingMode.DOWN);
                    awardToProcess.State_Admin_Amount__c = ((awardToProcess.State_Project_Amount__c * awardToProcess.State_Admin__c)/100)?.setScale(2,system.RoundingMode.DOWN);
                    awardToProcess.Federal_Supplement_Amount__c = (awardToProcess.Federal_Project_Amount__c - updatedAwardRecord.Federal_Project_Amount__c)?.setScale(2,system.RoundingMode.DOWN);
                    awardToProcess.State_Supplement_Amount__c = (awardToProcess.State_Project_Amount__c - updatedAwardRecord.State_Project_Amount__c)?.setScale(2,system.RoundingMode.DOWN);
                    awardToProcess.State_Admin_Supplement_Amount__c = (awardToProcess.State_Admin_Amount__c - updatedAwardRecord.State_Admin_Amount__c)?.setScale(2,system.RoundingMode.DOWN);
                    awardToProcess.FDSR__c = awardToProcess.Amendment_Request__r.FDSR__c == null ? null : awardToProcess.Amendment_Request__r.FDSR__c;

                    updatedAwardRecord.Federal_Project_Amount__c = awardToProcess.Federal_Project_Amount__c == null ? 0.00 : awardToProcess.Federal_Project_Amount__c;
                    updatedAwardRecord.State_Project_Amount__c = awardToProcess.State_Project_Amount__c == null ? 0.00 : awardToProcess.State_Project_Amount__c;
                    updatedAwardRecord.State_Admin_Amount__c = awardToProcess.State_Admin_Amount__c == null ? 0.00 : awardToProcess.State_Admin_Amount__c;
                }

                /** Updating the Previous Obligated Amount fields. */
                awardToProcess.Previous_Amount_Obligated__c = (newObligatedAmount
                        - supplementAmount)?.setScale(2,system.RoundingMode.DOWN);
                awardToProcess.Previous_Federal_Amount_Obligated__c = (awardToProcess.Federal_Project_Amount__c
                        - awardToProcess.Federal_Supplement_Amount__c)?.setScale(2,system.RoundingMode.DOWN);
                awardToProcess.Previous_State_Amount_Obligated__c = (awardToProcess.State_Project_Amount__c
                        - awardToProcess.State_Supplement_Amount__c)?.setScale(2,system.RoundingMode.DOWN);
                awardToProcess.Previous_State_Admin_Amount_Obligated__c = (awardToProcess.State_Admin_Amount__c
                        - awardToProcess.State_Admin_Supplement_Amount__c)?.setScale(2,system.RoundingMode.DOWN);

                awardToProcess.Total_Obligated_Amount__c = (awardToProcess.Federal_Project_Amount__c + awardToProcess.State_Project_Amount__c
                        + awardToProcess.State_Admin_Amount__c)?.setScale(2,system.RoundingMode.DOWN);
                awardToProcess.Total_Obligated_Supplement_Amount__c = (awardToProcess.Federal_Supplement_Amount__c + awardToProcess.State_Supplement_Amount__c
                        + awardToProcess.State_Admin_Supplement_Amount__c)?.setScale(2,system.RoundingMode.DOWN);

                awardToProcess.Federal_Retention__c = ((awardToProcess.Federal_Supplement_Amount__c
                        * awardToProcess.Federal_Retention_Share__c)/100)?.setScale(2,system.RoundingMode.DOWN);
                awardToProcess.State_Retention__c = ((awardToProcess.State_Supplement_Amount__c
                        * awardToProcess.State_Retention_Share__c)/100)?.setScale(2,system.RoundingMode.DOWN);

                awardToProcess.Federal_Amount_Available__c = (awardToProcess.Federal_Supplement_Amount__c
                        - awardToProcess.Federal_Retention__c)?.setScale(2,system.RoundingMode.DOWN);
                awardToProcess.State_Amount_Available__c = (awardToProcess.State_Supplement_Amount__c
                        - awardToProcess.State_Retention__c)?.setScale(2,system.RoundingMode.DOWN);

                awardToProcess.Sum_of_State_and_Federal__c = (awardToProcess.Federal_Supplement_Amount__c
                        + awardToProcess.State_Supplement_Amount__c)?.setScale(2,system.RoundingMode.DOWN);
                awardToProcess.Sum_of_State_and_Admin_Supplement__c = (awardToProcess.State_Supplement_Amount__c
                        + awardToProcess.State_Admin_Supplement_Amount__c)?.setScale(2,system.RoundingMode.DOWN);

                awardToProcess.Sum_of_State_and_Federal_to_Date__c = (awardToProcess.Federal_Project_Amount__c
                        + awardToProcess.State_Project_Amount__c)?.setScale(2,system.RoundingMode.DOWN);
                awardToProcess.Sum_of_State_and_Admin_to_Date__c = (awardToProcess.State_Project_Amount__c
                        + awardToProcess.State_Admin_Amount__c)?.setScale(2,system.RoundingMode.DOWN);
                awardToUpdateList.add(awardToProcess);
            }
        }
        if (awardToUpdateList?.size() > 0) {
            update awardToUpdateList;
        }
    }

    public void finish(Database.BatchableContext bc) {
    }
}