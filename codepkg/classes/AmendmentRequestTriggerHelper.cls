public without sharing class AmendmentRequestTriggerHelper extends TriggerHelper {
    /** Used for Amendment Update Operation in order to avoid recursion */
    List<Amendment_Request__c> amendmentToUpdateGlobalList = new List<Amendment_Request__c>();
    /** Used for Amendment Delete operation in order to avoid recursion */
    List<Project__c> projectToUpdateGlobalList = new List<Project__c>();

    /*********************************************
	* Method Name : processBeforeInsert
	* Description: This method is used To perform all the operation, which needs to be performed before inserting an Amendment.
	*********************************************/
    public override void processBeforeInsert() {
        /** This method is used To update the Program Name Prefix on Amendment FDSR which in configured from Metadata. */
        updateProgramPrefixOnProjectVersionOfAmendment();

        /** This method is used to update the "New Obligated Amount" based on provided "Supplement Award" */
        updateNewObligatedAmountFromSupplementAmount();

        updateManagerDetailsOnAmendmentRecord();
    }

    /*********************************************
	* Method Name : processAfterInsert
	* Description: This method is used To perform all the operation, which needs to be performed after inserting an Amendment.
	*********************************************/
    public override void processAfterInsert() {
        /** This method is used To update Latest Amendment FDSR/Project Version and Supplement Number on Project. */
        updateLatestAmendmentVersionOnProject();

        /** This method is used To inactive the old award for the Project and create a new Active Award, whenever an Amendment is created */
        inactiveOldAwardsCreateNewActiveAward();
    }

    /*********************************************
	* Method Name : processBeforeUpdate
	* Description: This method is used To perform all the operation, which needs to be performed before updating an Amendment.
	*********************************************/
    public override void processBeforeUpdate() {
        /** This method is used To update Latest Amendment FDSR/Project Version and Supplement Number on Project. */
        updateProgramPrefixOnProjectVersionOfAmendment();

        /** This method is used to update the "New Obligated Amount" based on provided "Supplement Award" */
        updateNewObligatedAmountFromSupplementAmount();

        updateManagerDetailsOnAmendmentRecord();
    }

    /*********************************************
	* Method Name : processAfterUpdate
	* Description: This method is used To perform all the operation, which needs to be performed after updating an Amendment.
	*********************************************/
    public override void processAfterUpdate() {
        /** This method is used to update the FDSR and Supplement Number of the Award record if it is updated on Amendment */
        updateFdsrAndSupplementNumberOfRelatedAward();

        /** This method is used To update Latest Amendment FDSR/Project Version and Supplement Number on Project. */
        updateLatestAmendmentVersionOnProject();

        /** Ticket No - 525 */
        /** This method is used to auto update Subsequent Amendments, Subsequent Awards and Project record,
         * when Amendment Type is updated on an Amendment record. */
        updateSubSequentAmendmentAwardAndProjectUponAmendmentTypeUpdate();

        /** This method is used to update the Sub Sequent Amendment, Awards and Project upon Amendment update */
        updateSubSequentAmendmentAwardAndProjectUponAmendmentUpdate();
    }

    /*********************************************
	* Method Name : processBeforeDelete
	* Description: This method is used To perform all the operation, which needs to be performed before deleting an Amendment.
	*********************************************/
    public override void processBeforeDelete() {
        /** This method is used To update Latest Amendment FDSR/Project Version and Supplement Number on Project. */
        updateLatestAmendmentVersionOnProject();

        /** This method is used to auto update Subsequent Amendments, Subsequent Awards and Project,
         * and delete the related Award record fo the Amendment record before the Amendment gets deleted. */
        updateAmendmentAwardAndProjectUponAmendmentDelete();
    }

    /*********************************************
	* Method Name : inactiveOldAwardsCreateNewActiveAward
	* Called From Method : ProcessAfterInsert
	* Author : Ricky
	* Inputs : -
	* Description: This method is used To inactive the old award for the Project and create a new Active Award,
	*              and Copy the Amended value to Project whenever an Amendment is created.
	*********************************************/
     private void inactiveOldAwardsCreateNewActiveAward() {
         Set<Id> projectIds = new Set<Id>(); /** To collect the Project Ids fro which Amendment is requested */
         Set<Id> awardIds = new Set<Id>(); /** To collect all the old Award Id for Collecting the related Payment request attached to it */
         Map<Id,Project__c> proejctToAwardMap; /** To collect the related Active Award of Project */
         Map<Id,Award__c> awardToPaymentMap; /** To collect al the Payment Request related to the Old Active Award */
         List<Project__c> projectsToUpdate = new List<Project__c>(); /** To Update the Project grant Award period */
         List<Award__c> awardToInsert = new List<Award__c>(); /** To insert new Active Award for the Project */
         List<Award__c> awardToDeactivate = new List<Award__c>(); /** To Deactivate the old Active Award for the Project */

         /** Iterating Trigger.new to Collect the Project Ids for which Amendment is requested*/
         for (Amendment_Request__c arToProcess : (List<Amendment_Request__c>)Trigger.new) {
             projectIds.add(arToProcess.Project__c);
         }
         /** fetching the Project and it's active Award data */
         proejctToAwardMap = new Map<Id,Project__c>([SELECT Id, Name, Start_Date__c, State_Project_Award__c, Federal_Project_Award__c,
                                End_Date__c, FEMA_Share__c, State_Share__c, StateAdmin__c, Federal_Retention__c, State_Retention__c,
                                Total_Project_Award__c, TotalProjectStateAdminShare__c,
                                (SELECT Id, Name, Status__c, FEMA_Share__c, State_Share__c FROM Awards__r
                                    WHERE Status__c =: ALS_CONSTANTS.Award_Status_Active)
                                FROM Project__c WHERE Id IN : projectIds]);
         /** fetching the Award and it's related Payment Requests */
         awardToPaymentMap = new Map<Id,Award__c>([SELECT Id, Name, Project__c, Status__c, FEMA_Share__c, State_Share__c, (SELECT Id,Award__c FROM Payment_Requests__r)
         FROM Award__c WHERE Project__c IN : projectIds AND Status__c =: ALS_CONSTANTS.Award_Status_Active]);

         for (Amendment_Request__c amendmentToProcess : (List<Amendment_Request__c>)Trigger.new) {
                /** Fetching the Project Record from Map, which is associated with this Amendment */
                Project__c projectToProcess = proejctToAwardMap.get(amendmentToProcess.Project__c);
                /** Updating Project record based on Amendment Type if the requested Amendment is of type "Time Extension" */
                if (amendmentToProcess.AmendmentType__c == ALS_CONSTANTS.Amendment_Type_TimeExtension) {
                    /** Calling the method to create Award record and Adding to the collection for Inserting */
                    awardToInsert.add(createActiveAwardOnAmendmentCreation(amendmentToProcess, projectToProcess));

                    projectToProcess.Start_Date__c = amendmentToProcess.TimeExtensionStartDate__c;
                    projectToProcess.End_Date__c = amendmentToProcess.TimeExtensionEndDate__c;
                }
                /** Updating Project record based on Amendment Type if the requested Amendment is of type "Money Extension" */
                else if (amendmentToProcess.AmendmentType__c == ALS_CONSTANTS.Amendment_Type_MoneyExtension) {
                    /** Calling the method to create Award record and Adding to the collection for Inserting */
                    awardToInsert.add(createActiveAwardOnAmendmentCreation(amendmentToProcess, projectToProcess));

                    projectToProcess.Total_Project_Award__c = amendmentToProcess.NewObligatedAmount__c == null ? 0.00 : amendmentToProcess.NewObligatedAmount__c;

                    //Ticket no - 374 - Start
                    projectToProcess.State_Project_Award__c = ((projectToProcess.Total_Project_Award__c
                            * (projectToProcess.State_Share__c == null? 0.00 : projectToProcess.State_Share__c))/100)?.setScale(2,system.RoundingMode.DOWN);
                    projectToProcess.Federal_Project_Award__c = ((projectToProcess.Total_Project_Award__c
                            * (projectToProcess.FEMA_Share__c == null? 0.00 : projectToProcess.FEMA_Share__c))/100)?.setScale(2,system.RoundingMode.DOWN);
                    //Ticket no - 374 - End
                }
                /** Updating Project record based on Amendment Type if the requested Amendment is of type "FEMA Percentage Change Extension" */
                else if (amendmentToProcess.AmendmentType__c == ALS_CONSTANTS.Amendment_Type_PercentageChange) {
                    /** Calling the method to create Award record and Adding to the collection for Inserting */
                    awardToInsert.add(createActiveAwardOnAmendmentCreation(amendmentToProcess, projectToProcess));

                    projectToProcess.FEMA_Share__c = amendmentToProcess.FEMA_Share__c == null? 0.00 : amendmentToProcess.FEMA_Share__c;
                    projectToProcess.State_Share__c = amendmentToProcess.State_Share__c == null? 0.00 : amendmentToProcess.State_Share__c;

                    //Ticket no - 374 - Start
                    projectToProcess.State_Project_Award__c = (((projectToProcess.Total_Project_Award__c == null ? 0.00 : projectToProcess.Total_Project_Award__c)
                                                                        * projectToProcess.State_Share__c)/100)?.setScale(2,system.RoundingMode.DOWN);
                    projectToProcess.Federal_Project_Award__c = (((projectToProcess.Total_Project_Award__c == null ? 0.00 : projectToProcess.Total_Project_Award__c)
                                                                        * projectToProcess.FEMA_Share__c)/100)?.setScale(2,system.RoundingMode.DOWN);
                    //Ticket no - 374 - End
                }
                /** Updating Project record based on Amendment Type if the requested Amendment is of type "Money Extension and Cost Share Change" */
                else if (amendmentToProcess.AmendmentType__c == ALS_CONSTANTS.Amendment_Type_MoneyExtensionAndCostShareChange) {
                    /** Calling the method to create Award record and Adding to the collection for Inserting */
                    awardToInsert.add(createActiveAwardOnAmendmentCreation(amendmentToProcess, projectToProcess));

                    projectToProcess.Total_Project_Award__c = amendmentToProcess.NewObligatedAmount__c == null ? 0.00 : amendmentToProcess.NewObligatedAmount__c;
                    projectToProcess.FEMA_Share__c = amendmentToProcess.FEMA_Share__c == null? 0.00 : amendmentToProcess.FEMA_Share__c;
                    projectToProcess.State_Share__c = amendmentToProcess.State_Share__c == null? 0.00 : amendmentToProcess.State_Share__c;
                    projectToProcess.State_Project_Award__c = ((projectToProcess.Total_Project_Award__c * projectToProcess.State_Share__c)/100)?.setScale(2,system.RoundingMode.DOWN);
                    projectToProcess.Federal_Project_Award__c = ((projectToProcess.Total_Project_Award__c * projectToProcess.FEMA_Share__c)/100)?.setScale(2,system.RoundingMode.DOWN);
                }
                /** Updating Project record based on Amendment Type if the requested Amendment is of type "Money Extension and Time Extension" */
                else if (amendmentToProcess.AmendmentType__c == ALS_CONSTANTS.Amendment_Type_MoneyExtensionAndTimeExtension) {
                    /** Calling the method to create Award record and Adding to the collection for Inserting */
                    awardToInsert.add(createActiveAwardOnAmendmentCreation(amendmentToProcess, projectToProcess));

                    projectToProcess.Total_Project_Award__c = amendmentToProcess.NewObligatedAmount__c == null ? 0.00 : amendmentToProcess.NewObligatedAmount__c;
                    projectToProcess.State_Project_Award__c = ((projectToProcess.Total_Project_Award__c
                                                    * (projectToProcess.State_Share__c == null? 0.00 : projectToProcess.State_Share__c))/100)?.setScale(2,system.RoundingMode.DOWN);
                    projectToProcess.Federal_Project_Award__c = ((projectToProcess.Total_Project_Award__c
                                                    * (projectToProcess.FEMA_Share__c == null? 0.00 : projectToProcess.FEMA_Share__c))/100)?.setScale(2,system.RoundingMode.DOWN);
                    projectToProcess.Start_Date__c = amendmentToProcess.TimeExtensionStartDate__c;
                    projectToProcess.End_Date__c = amendmentToProcess.TimeExtensionEndDate__c;
                }
                projectsToUpdate.add(projectToProcess); /** Adding the Project Record to Update the value based on the Amendment requested */

            /** Updating Old Active Award as Inactive */
            for(Award__c awardToProcess : projectToProcess.Awards__r)
            {
                awardIds.add(awardToProcess.Id);
                awardToProcess.Status__c = ALS_CONSTANTS.Award_Status_Inactive;
                awardToDeactivate.add(awardToProcess); /** Adding the award record to collection for Updating */
            }
        }
        if (awardToInsert.size() > 0) {
            insert awardToInsert; /** Inserting new Active Award for the Project record for which Amendment is requested */
        }
        if (awardToDeactivate.size() > 0) {
            update awardToDeactivate; /** Updating old Active Award for the Project record for which Amendment is requested */
        }
         if (projectsToUpdate.size() > 0) {
             update projectsToUpdate; /** Updating the Project record for which Amendment is requested */
         }
    }

    /*********************************************
    * Method Name : createActiveAwardOnAmendmentCreation
    * Called From Method : inactiveOldAwardsCreateNewActiveAward
    * Author : Ricky
    * Inputs : - 1. Amendment_Request__c amendmentToProcess - Amendment Record, Which is created
    *            2. Project__c projectToProcess - project record, on Which Amendment is created.
    * Description: This method is used to update the "New Obligated Amount" of Amendment based on "Supplement Award"
    *********************************************/
    private static Award__c createActiveAwardOnAmendmentCreation(Amendment_Request__c amendmentToProcess, Project__c projectToProcess) {
        /** Creating a new Active Award record with updated values from the Project and Amendment */
        Award__c award = new Award__c();
        award.Project__c = projectToProcess.Id;
        award.Amendment_Request__c = amendmentToProcess.Id;
        award.Status__c = ALS_CONSTANTS.Award_Status_Active;
        if(amendmentToProcess.FDSR__c != null) {
            award.FDSR__c = amendmentToProcess.FDSR__c;
        }
        if(amendmentToProcess.SupplementNumber__c != null) {
            award.Supplement_Number__c =  amendmentToProcess.SupplementNumber__c;
        }
        if (amendmentToProcess.Reviewed_By_Manager__c == ALS_CONSTANTS.Picklist_Yes) {
            award.Manager_User__c = amendmentToProcess.Manager_User__c;
            award.Manager_Approved_Date__c = amendmentToProcess.Manager_Approved_Date__c;
        }
        else {
            award.Manager_User__c = null;
            award.Manager_Approved_Date__c = null;
        }

        if (amendmentToProcess.AmendmentType__c == ALS_CONSTANTS.Amendment_Type_MoneyExtension
                || amendmentToProcess.AmendmentType__c == ALS_CONSTANTS.Amendment_Type_MoneyExtensionAndTimeExtension
                || amendmentToProcess.AmendmentType__c == ALS_CONSTANTS.Amendment_Type_MoneyExtensionAndCostShareChange) {
            award.Supplement_Award__c = amendmentToProcess.SupplementAward__c == null ? 0.00 : amendmentToProcess.SupplementAward__c;
            award.AmountObligated__c = amendmentToProcess.NewObligatedAmount__c == null ? 0.00 : amendmentToProcess.NewObligatedAmount__c;
        }
        else {
            award.Supplement_Award__c = 0;
            award.AmountObligated__c = projectToProcess.Total_Project_Award__c == null ? 0.00 : projectToProcess.Total_Project_Award__c;
        }

        /** If Amendment includes Time Extension then to copy the Start Date and End Date from Amendment or else from project. */
        if (amendmentToProcess.AmendmentType__c == ALS_CONSTANTS.Amendment_Type_TimeExtension
                || amendmentToProcess.AmendmentType__c == ALS_CONSTANTS.Amendment_Type_MoneyExtensionAndTimeExtension ) {
            award.AwardStartDate__c = amendmentToProcess.TimeExtensionStartDate__c;
            award.AwardEndDate__c = amendmentToProcess.TimeExtensionEndDate__c;
        }
        else  {
        award.AwardStartDate__c = projectToProcess.Start_Date__c;
        award.AwardEndDate__c = projectToProcess.End_Date__c;
        }

        if (amendmentToProcess.AmendmentType__c == ALS_CONSTANTS.Amendment_Type_PercentageChange
                || amendmentToProcess.AmendmentType__c == ALS_CONSTANTS.Amendment_Type_MoneyExtensionAndCostShareChange) {
            award.FEMA_Share__c = amendmentToProcess.FEMA_Share__c == null ? 0.00 : amendmentToProcess.FEMA_Share__c;
            award.State_Share__c = amendmentToProcess.State_Share__c == null ? 0.00 : amendmentToProcess.State_Share__c;
        }
        else {
            award.FEMA_Share__c = projectToProcess.FEMA_Share__c == null ? 0.00 : projectToProcess.FEMA_Share__c;
            award.State_Share__c = projectToProcess.State_Share__c == null ? 0.00 : projectToProcess.State_Share__c;
        }

        award.State_Admin__c = projectToProcess.StateAdmin__c == null ? 0.00 : projectToProcess.StateAdmin__c;
        award.Federal_Retention_Share__c = projectToProcess.Federal_Retention__c == null ? 0.00 : projectToProcess.Federal_Retention__c;
        award.State_Retention_Share__c =  projectToProcess.State_Retention__c == null ? 0.00 : projectToProcess.State_Retention__c;

        if (amendmentToProcess.AmendmentType__c == ALS_CONSTANTS.Amendment_Type_PercentageChange
                || amendmentToProcess.AmendmentType__c == ALS_CONSTANTS.Amendment_Type_MoneyExtension
                || amendmentToProcess.AmendmentType__c == ALS_CONSTANTS.Amendment_Type_MoneyExtensionAndCostShareChange
                || amendmentToProcess.AmendmentType__c == ALS_CONSTANTS.Amendment_Type_MoneyExtensionAndTimeExtension ) {
            award.Federal_Project_Amount__c = ((award.AmountObligated__c
                    * award.FEMA_Share__c)/100)?.setScale(2,system.RoundingMode.DOWN);
            award.Federal_Supplement_Amount__c = (award.Federal_Project_Amount__c
                    - (projectToProcess.Federal_Project_Award__c == null ? 0.00 : projectToProcess.Federal_Project_Award__c))?.setScale(2,system.RoundingMode.DOWN);
            award.State_Project_Amount__c = ((award.AmountObligated__c
                    * award.State_Share__c)/100)?.setScale(2,system.RoundingMode.DOWN);
            award.State_Supplement_Amount__c = (award.State_Project_Amount__c
                    - (projectToProcess.State_Project_Award__c == null ? 0.00 : projectToProcess.State_Project_Award__c))?.setScale(2,system.RoundingMode.DOWN);
            award.State_Admin_Amount__c = ((award.State_Project_Amount__c
                    * award.State_Admin__c)/100)?.setScale(2,system.RoundingMode.DOWN);
            award.State_Admin_Supplement_Amount__c = (award.State_Admin_Amount__c
                    - (projectToProcess.TotalProjectStateAdminShare__c == null ? 0.00 : projectToProcess.TotalProjectStateAdminShare__c))?.setScale(2,system.RoundingMode.DOWN);
        }
        /** If the Amendment does not includes Money changes, then to copy the Amounts from Project. */
        else {
            award.Federal_Project_Amount__c = (projectToProcess.Federal_Project_Award__c == null ? 0.00 : projectToProcess.Federal_Project_Award__c)?.setScale(2,system.RoundingMode.DOWN);
            award.Federal_Supplement_Amount__c = 0;
            award.State_Project_Amount__c = (projectToProcess.State_Project_Award__c == null ? 0.00 : projectToProcess.State_Project_Award__c)?.setScale(2,system.RoundingMode.DOWN);
            award.State_Supplement_Amount__c = 0;
            award.State_Admin_Amount__c =(projectToProcess.TotalProjectStateAdminShare__c == null ? 0.00 : projectToProcess.TotalProjectStateAdminShare__c)?.setScale(2,system.RoundingMode.DOWN);
            award.State_Admin_Supplement_Amount__c = 0;
        }

        /** Updating the Previous Obligated Amount fields. */
        award.Previous_Amount_Obligated__c = (award.AmountObligated__c
                - award.Supplement_Award__c)?.setScale(2,system.RoundingMode.DOWN);
        award.Previous_Federal_Amount_Obligated__c = (award.Federal_Project_Amount__c
                - award.Federal_Supplement_Amount__c)?.setScale(2,system.RoundingMode.DOWN);
        award.Previous_State_Amount_Obligated__c = (award.State_Project_Amount__c
                - award.State_Supplement_Amount__c)?.setScale(2,system.RoundingMode.DOWN);
        award.Previous_State_Admin_Amount_Obligated__c = (award.State_Admin_Amount__c
                - award.State_Admin_Supplement_Amount__c)?.setScale(2,system.RoundingMode.DOWN);

        /** Updating the the other field which are dependant on Federal, State and Admin Amount and Retentions of Supplement
         * and Total Obligated Amount. */
        award.Total_Obligated_Amount__c = (award.Federal_Project_Amount__c + award.State_Project_Amount__c
                + award.State_Admin_Amount__c)?.setScale(2,system.RoundingMode.DOWN);
        award.Total_Obligated_Supplement_Amount__c = (award.Federal_Supplement_Amount__c + award.State_Supplement_Amount__c
                + award.State_Admin_Supplement_Amount__c)?.setScale(2,system.RoundingMode.DOWN);

        award.Federal_Retention__c = ((award.Federal_Supplement_Amount__c
                * award.Federal_Retention_Share__c)/100)?.setScale(2,system.RoundingMode.DOWN);
        award.State_Retention__c = ((award.State_Supplement_Amount__c
                * award.State_Retention_Share__c)/100)?.setScale(2,system.RoundingMode.DOWN);

        award.Federal_Amount_Available__c = (award.Federal_Supplement_Amount__c
                - award.Federal_Retention__c)?.setScale(2,system.RoundingMode.DOWN);
        award.State_Amount_Available__c = (award.State_Supplement_Amount__c
                - award.State_Retention__c)?.setScale(2,system.RoundingMode.DOWN);

        award.Sum_of_State_and_Federal__c = (award.Federal_Supplement_Amount__c
                + award.State_Supplement_Amount__c)?.setScale(2,system.RoundingMode.DOWN);
        award.Sum_of_State_and_Admin_Supplement__c = (award.State_Supplement_Amount__c
                + award.State_Admin_Supplement_Amount__c)?.setScale(2,system.RoundingMode.DOWN);

        award.Sum_of_State_and_Federal_to_Date__c = (award.Federal_Project_Amount__c
                + award.State_Project_Amount__c)?.setScale(2,system.RoundingMode.DOWN);
        award.Sum_of_State_and_Admin_to_Date__c = (award.State_Project_Amount__c
                + award.State_Admin_Amount__c)?.setScale(2,system.RoundingMode.DOWN);
        /** Return Statement */
        return award;
    }

    /*********************************************
	* Method Name : updateNewObligatedAmountFromSupplementAmount
	* Called From Method : ProcessBeforeInsert, ProcessBeforeUpdate
	* Author : Ricky
	* Inputs : -
	* Description: This method is used to update the "New Obligated Amount" of Amendment based on "Supplement Award"
	*********************************************/
    private void updateNewObligatedAmountFromSupplementAmount() {
        Set<Id> projectIds = new Set<Id>(); /** To collect the Project Ids */
        /** To collect the Amendment Request to Process - When project field is not null */
        Map<Id, Amendment_Request__c> amendmentsToProcess = new Map<Id, Amendment_Request__c>();
        /** While Insert - All the Amendment record of the Amendment Type, which consist of Supplement Award value. */
        if (Trigger.isInsert) {
            for (Amendment_Request__c amendment : (List<Amendment_Request__c>)Trigger.new) {
                if (amendment.Project__c != null) { /** Condition to check if the Project is given for Amendment */
                    /** Condition to check if the Amendment type is Money Extension/Money Extension and Time Extension/Money Extension and FEMA Percentage Change */
                    if (amendment.AmendmentType__c == ALS_CONSTANTS.Amendment_Type_MoneyExtension
                            || amendment.AmendmentType__c == ALS_CONSTANTS.Amendment_Type_MoneyExtensionAndTimeExtension
                            || amendment.AmendmentType__c == ALS_CONSTANTS.Amendment_Type_MoneyExtensionAndCostShareChange) {
                        //currentUserIds.add(UserInfo.getUserId()); /** Adding the current user Id to collection */
                        projectIds.add(amendment.Project__c); /** Adding the Project Id to collection */
                        amendmentsToProcess.put(amendment.Id, amendment); /** Adding the Amendment record to collection */
                    }
                }
                else {
                    amendment.addError('Please select a Project for the Amendment Request.');
                }
            }
        }

        /** While Update - If Supplement Award value changed */
        if (Trigger.isUpdate) {
            for (Amendment_Request__c amendment : (List<Amendment_Request__c>)Trigger.new) {
                Amendment_Request__c oldRecord = (Amendment_Request__c) Trigger.oldMap.get(amendment.Id);
                if (amendment.AmendmentType__c == oldRecord.AmendmentType__c
                        && (amendment.AmendmentType__c == ALS_CONSTANTS.Amendment_Type_MoneyExtension
                            || amendment.AmendmentType__c == ALS_CONSTANTS.Amendment_Type_MoneyExtensionAndTimeExtension
                            || amendment.AmendmentType__c == ALS_CONSTANTS.Amendment_Type_MoneyExtensionAndCostShareChange)
                        && amendment.SupplementAward__c != oldRecord.SupplementAward__c) {
                    projectIds.add(amendment.Project__c); /** Adding the Project Id to collection */
                    amendmentsToProcess.put(amendment.Id, amendment); /** Adding the Amendment record to collection */
                }
            }
        }

        /** Condition to check null pointer exception in Project Id collection */
        if (projectIds.size() > 0) {
            Map<Id, Award__c> amendmentIdToAwardMap = new Map<Id, Award__c>();
            if (Trigger.isUpdate) {
                /** In Update fetching the Award record and arranging it with Amendment Id as key and Award record as value in Map collection */
                List<Award__c> awardList = [SELECT Id, Amendment_Request__c, Status__c FROM Award__c WHERE Amendment_Request__c IN : Trigger.newMap.keySet()];
                for (Award__c award : awardList) {
                    amendmentIdToAwardMap.put(award.Amendment_Request__c, award);
                }
            }
            /** fetching the Project record whose Id are available in collection */
            Map<Id, Project__c> idToProjectMap = new Map<Id, Project__c>([SELECT Id, Total_Project_Award__c FROM Project__c WHERE Id IN : projectIds]);
            for (Amendment_Request__c amendmentToProcess : amendmentsToProcess.values()) { /** Iterating the Amendments to process */
                Project__c project = idToProjectMap.get(amendmentToProcess.Project__c); /** Fetching the Project record from collection */
                /** To check null pointer exception of Total Project Award f the Project */
                Decimal projectAward = project.Total_Project_Award__c == null ? 0.00 : project.Total_Project_Award__c;
                /** To check null pointer exception of Supplement Award of Amendment */
                Decimal supplementAmount = amendmentToProcess.SupplementAward__c == null ? 0.00 : amendmentToProcess.SupplementAward__c;
                /** While Insert - Updating the New Obligated Amount of Amendment based on given Supplement Award */
                if (Trigger.isInsert) {
                    amendmentToProcess.NewObligatedAmount__c = projectAward + supplementAmount;
                }
                /** While Update - Updating the New Obligated Amount of Amendment based on new Supplement Award */
                else if (Trigger.isUpdate) {
                    Amendment_Request__c oldRecord = (Amendment_Request__c) Trigger.oldMap.get(amendmentToProcess.Id);
                    Decimal oldSupplementAmount = oldRecord.SupplementAward__c == null ? 0.00 : oldRecord.SupplementAward__c;
                    if (oldRecord.SupplementAward__c != amendmentToProcess.SupplementAward__c) {
                        amendmentToProcess.NewObligatedAmount__c = (oldRecord.NewObligatedAmount__c + supplementAmount - oldSupplementAmount);
                    }
                }
            }
        }
    }



    /*********************************************
	* Method Name : updateFdsrOfRelatedAward
	* Called From Method : ProcessAfterUpdate
	* Author : Ricky
	* Inputs : -
	* Description: This method is used to auto update FDSR of the related Award record if The FDSR of Amendment gets updated.
	*********************************************/
    private void updateFdsrAndSupplementNumberOfRelatedAward() {
        /** To collect the Amendments whose FDSR has been Updated */
        Map<Id, Amendment_Request__c> amendmentIdToAmendmentMap = new Map<Id, Amendment_Request__c>();
        for (Amendment_Request__c amendment : (List<Amendment_Request__c>)Trigger.new) {
            Amendment_Request__c oldRecord = (Amendment_Request__c) Trigger.oldMap.get(amendment.Id);
            if(oldRecord.FDSR__c != amendment.FDSR__c
                    || oldRecord.SupplementNumber__c != amendment.SupplementNumber__c
                    || oldRecord.Reviewed_By_Manager__c != amendment.Reviewed_By_Manager__c) {
                amendmentIdToAmendmentMap.put(amendment.Id, amendment); //Adding the Amendment record to Map collection...
            }
        }
        /** Condition to check null pointer exception for the Amendment collection whose FDSR ahs been updated */
        if(amendmentIdToAmendmentMap.size() > 0) {
            /** Fetching the Amendment record and its related Award */
            Map<Id, Amendment_Request__c> amendmentIdToAmendmentWithAwardMap = new Map<Id, Amendment_Request__c>([SELECT Id, FDSR__c,
                                                                            SupplementNumber__c, Reviewed_By_Manager__c, Manager_User__c,
                                                                            Manager_Approved_Date__c,
                                                                            (SELECT Id, FDSR__c, Supplement_Number__c,
                                                                                Manager_User__c, Manager_Approved_Date__c FROM Awards__r)
                                                                            FROM Amendment_Request__c
                                                                            WHERE Id IN : amendmentIdToAmendmentMap.keySet()]);
            /** To collect the Award on which FDSR has been updated as Per Amendment */
            List<Award__c> awardsToUpdateList = new List<Award__c>();
            for (Amendment_Request__c amendment : amendmentIdToAmendmentMap.values()) {
                if(amendmentIdToAmendmentWithAwardMap?.get(amendment.Id)?.Awards__r?.size() == 1) {
                    /** Fetching the related Award of the Amendment from Map Collection */
                    Award__c awardToUpdate = amendmentIdToAmendmentWithAwardMap.get(amendment.Id).Awards__r[0];

                    /** Updating the FDSR of the Award */
                    if(amendment.FDSR__c != null) {
                        awardToUpdate.FDSR__c = amendment.FDSR__c;
                    }
                    else if(amendment.FDSR__c == null) {
                        awardToUpdate.FDSR__c = null;
                    }
                    /** Updating the Supplement Number of the Award */
                    if(amendment.SupplementNumber__c != null) {
                        awardToUpdate.Supplement_Number__c =  amendment.SupplementNumber__c;
                    }
                    else if(amendment.SupplementNumber__c == null) {
                        awardToUpdate.Supplement_Number__c =  null;
                    }
                    if (amendment.Reviewed_By_Manager__c == ALS_CONSTANTS.Picklist_Yes) {
                        awardToUpdate.Manager_User__c = amendment.Manager_User__c;
                        awardToUpdate.Manager_Approved_Date__c = amendment.Manager_Approved_Date__c;
                    }
                    else {
                        awardToUpdate.Manager_User__c = null;
                        awardToUpdate.Manager_Approved_Date__c = null;
                    }
                    awardsToUpdateList.add(awardToUpdate); /** Adding Award record to collection */
                }
            }
            if(awardsToUpdateList.size() > 0) { /** Condition to check null pointer exception for the Award Collection */
                update awardsToUpdateList; /** Updating the List of Awards */
            }
        }
    }

    /** Ticket No - 525 - Start */
    /*********************************************
	* Method Name : updateSubSequentAmendmentAwardAndProjectUponAmendmentUpdate
	* Called From Method : processAfterUpdate
	* Author : Ricky
	* Inputs : -
	* Description: This method is used to auto update Subsequent Amendments, Subsequent Awards and Project record.
	*********************************************/
    private void updateSubSequentAmendmentAwardAndProjectUponAmendmentUpdate() {
        Set<Id> projectIds  = new Set<Id>(); /** To collect the project Id of the Amendment */
        /**To collect the Amendment which are getting updated*/
        Map<Id, Amendment_Request__c> idToUpdatedAmendmentRequestMap = new Map<Id, Amendment_Request__c>();

        for (Amendment_Request__c amendment : (List<Amendment_Request__c>)Trigger.new) {
            /**Fetching the old record of Amendment in order to compare the values*/
            Amendment_Request__c oldRecord = (Amendment_Request__c)Trigger.oldMap.get(amendment.Id);
            /**Condition to check the values changes based on Amendment type....
             * 1. To check if the Amendment Type is same for the Amendment record.
             * 2. Supplement Award Change - Money Extension, Money and Time Extension, Money and Cost Share change Amendment.
             * 3. Start Date and End Date - Time Extension, Money and Time Extension Amendment.
             * 4. FEMA Share% and State Share% - FEMA Percentage Change, Money and Cost Share change Amendment*/
            if(amendment.AmendmentType__c == oldRecord.AmendmentType__c && amendment.Project__c != null
                    && (((amendment.AmendmentType__c == ALS_CONSTANTS.Amendment_Type_MoneyExtension
                                || amendment.AmendmentType__c == ALS_CONSTANTS.Amendment_Type_MoneyExtensionAndTimeExtension
                                || amendment.AmendmentType__c == ALS_CONSTANTS.Amendment_Type_MoneyExtensionAndCostShareChange)
                            && amendment.SupplementAward__c != oldRecord.SupplementAward__c)
                        || ((amendment.AmendmentType__c == ALS_CONSTANTS.Amendment_Type_TimeExtension
                                || amendment.AmendmentType__c == ALS_CONSTANTS.Amendment_Type_MoneyExtensionAndTimeExtension)
                            && (amendment.TimeExtensionStartDate__c != oldRecord.TimeExtensionStartDate__c
                                || amendment.TimeExtensionEndDate__c != oldRecord.TimeExtensionEndDate__c))
                        || ((amendment.AmendmentType__c == ALS_CONSTANTS.Amendment_Type_PercentageChange
                                || amendment.AmendmentType__c == ALS_CONSTANTS.Amendment_Type_MoneyExtensionAndCostShareChange)
                            && (amendment.FEMA_Share__c != oldRecord.FEMA_Share__c
                                || amendment.State_Share__c != oldRecord.State_Share__c)))) {
                if (amendment.Project__c != null) { /**Condition to make sure that Project field is not null on Amendment*/
                    projectIds.add(amendment.Project__c); /**Adding Project ID to collection*/
                    idToUpdatedAmendmentRequestMap.put(amendment.Id, amendment); /**Adding Amendment record to collection*/
                }
                else {
                    amendment.addError('Please select a Project for the Amendment Request.'); //Error to select the Project...
                }
            }
        }

        /**Condition to check the null pointer exception for "projectIds" collection to process further */
        if (projectIds.size() > 0) {
            /**To collect the Amendment record to be updated due to one Amendment update*/
            List<Amendment_Request__c> amendmentToUpdateList = new List<Amendment_Request__c>();
            List<Project__c> projectToUpdateList = new List<Project__c>(); /**To collect the Projects to update*/
            List<Award__c> awardToUpdateList = new List<Award__c>(); /**To collect the Awards to update*/
            /**Fetching the Project records and its related Amendment records in order to update the remaining Amendments*/
            Map<Id, Project__c> projectIdToProjectWithAmendmentsMap = new Map<Id, Project__c>([SELECT Id, Name, Total_Project_Award__c, FEMA_Share__c,
                                                State_Share__c, StateAdmin__c, Start_Date__c, End_Date__c, State_Project_Award__c, Federal_Project_Award__c,
                                                (SELECT Id, Name, SupplementAward__c, NewObligatedAmount__c, AmendmentType__c, SupplementNumber__c,
                                                        Project__r.FundingSource__c,
                                                        FEMA_Share__c, State_Share__c, TimeExtensionStartDate__c, TimeExtensionEndDate__c, FDSR__c
                                                        FROM Amendment_Requests__r ORDER BY FDSR__c ASC)
                                                FROM Project__c WHERE Id IN :projectIds]);

            /**Fetching the Amendment Requests and its related Awards*/
            Map<Id, Amendment_Request__c> idToAmendmentWithAwardMap = new Map<Id, Amendment_Request__c>([SELECT Id, SupplementNumber__c, FDSR__c,
                                                        (SELECT Id, Name, Status__c, Supplement_Award__c, AmountObligated__c, FEMA_Share__c, State_Share__c,
                                                                Project__r.FundingSource__c, Amendment_Request__r.AmendmentType__c, Previous_Amount_Obligated__c,
                                                                Amendment_Request__r.FEMA_Share__c, Amendment_Request__r.State_Share__c,
                                                                Federal_Project_Amount__c,  State_Project_Amount__c, State_Admin_Amount__c,
                                                                Federal_Supplement_Amount__c, State_Supplement_Amount__c, State_Admin_Supplement_Amount__c,
                                                                State_Retention_Share__c, Federal_Retention_Share__c, State_Admin__c, Project__r.Name,
                                                                AwardStartDate__c, AwardEndDate__c FROM Awards__r)
                                                        FROM Amendment_Request__c WHERE Project__c IN :projectIds]);

            for (Amendment_Request__c amendmentToProcess : idToUpdatedAmendmentRequestMap.values()) {
                /**Fetching the Project of the Amendment in order to find the List of Amendments related to this Project*/
                Project__c project = projectIdToProjectWithAmendmentsMap.get(amendmentToProcess.Project__c);
                /**Fetching the list of Amendment of the Project record*/
                List<Amendment_Request__c> amendmentListOfProject = project.Amendment_Requests__r;
                List<Award__c> updatedAwardList = new List<Award__c>(); /**To collect the Award record to update*/
                /** Fetching the latest Amendment Award from the idToAmendmentWithAwardMap collection */
                Award__c latestAmendmentAward = idToAmendmentWithAwardMap.get(amendmentListOfProject[amendmentListOfProject.size()-1].Id).Awards__r[0];
                /** Condition to check if this Amendment is available in the Global List of Amendment in order to avoid the recursion */
                if(!amendmentToUpdateGlobalList.contains(amendmentToProcess)) {
                    amendmentToUpdateGlobalList.add(amendmentToProcess);
                    /**Changes on Project Award and Other Amendments for "Additional Funding" Amendment*/
                    if (amendmentToProcess.AmendmentType__c == ALS_CONSTANTS.Amendment_Type_MoneyExtension) {
                        /** Method calling to update the Sub Sequent Amendment Amount */
                        List<Amendment_Request__c> AmendmentWithUpdatedAmountList = updateSubSequentAmendmentsAmount(amendmentListOfProject,
                                amendmentToProcess);
                        if(AmendmentWithUpdatedAmountList?.size() > 0) {
                            amendmentToUpdateList.addAll(AmendmentWithUpdatedAmountList);
                            amendmentToUpdateGlobalList.addAll(AmendmentWithUpdatedAmountList);
                        }
                        /** Method calling to update the Sub Sequent Award Amount */
                        List<Award__c> awardWithUpdatedAmountList = updateSubSequentAwardAmountNew(amendmentListOfProject,
                                idToAmendmentWithAwardMap, amendmentToProcess, updatedAwardList);
                        awardToUpdateList.addAll(awardWithUpdatedAmountList);
                        /** Method calling to update the final changes on Project Amount */
                        Project__c projectRecordUpdate = updateProjectRecord(project, latestAmendmentAward);
                        projectToUpdateList.add(projectRecordUpdate);
                    }
                    else if (amendmentToProcess.AmendmentType__c == ALS_CONSTANTS.Amendment_Type_TimeExtension) {
                        /** Method calling to update the Sub Sequent Award Time */
                        List<Award__c> awardWithUpdatedTimeList = updateSubSequentAwardTime(amendmentListOfProject,
                                idToAmendmentWithAwardMap, amendmentToProcess,updatedAwardList);
                        awardToUpdateList.addAll(awardWithUpdatedTimeList);
                        /** Method calling to update the final changes on Project Amount */
                        Project__c projectRecordUpdate = updateProjectRecord(project, latestAmendmentAward);
                        projectToUpdateList.add(projectRecordUpdate);

                    }
                    else if (amendmentToProcess.AmendmentType__c == ALS_CONSTANTS.Amendment_Type_PercentageChange) {

                        List<Award__c> awardWithUpdatedAmountList = updateSubSequentAwardAmountNew(amendmentListOfProject,
                                idToAmendmentWithAwardMap, amendmentToProcess, updatedAwardList);

                        /** Method calling to update the Sub Sequent Award Cost Shares */
                        List<Award__c> awardWithUpdatedCostSharesList = updateSubSequentAwardCostShare(amendmentListOfProject,
                                idToAmendmentWithAwardMap, amendmentToProcess, updatedAwardList);
                        awardToUpdateList.addAll(awardWithUpdatedCostSharesList);
                        /** Method calling to update the final changes on Project Amount */
                        Project__c projectRecordUpdate = updateProjectRecord(project, latestAmendmentAward);
                        projectToUpdateList.add(projectRecordUpdate);
                    }
                    else if (amendmentToProcess.AmendmentType__c == ALS_CONSTANTS.Amendment_Type_MoneyExtensionAndTimeExtension) {
                        /** Method calling to update the Sub Sequent Amendment Amount */
                        List<Amendment_Request__c> AmendmentWithUpdatedAmountList = updateSubSequentAmendmentsAmount(amendmentListOfProject,
                                amendmentToProcess);
                        if(AmendmentWithUpdatedAmountList?.size() > 0) {
                            amendmentToUpdateList.addAll(AmendmentWithUpdatedAmountList);
                            amendmentToUpdateGlobalList.addAll(AmendmentWithUpdatedAmountList);
                        }
                        /** Method calling to update the Sub Sequent Award Amount */
                        /*List<Award__c> awardWithUpdatedAmountList = updateSubSequentAwardAmount(amendmentListOfProject,
                                idToAmendmentWithAwardMap, amendmentToProcess, updatedAwardList);*/
                        List<Award__c> awardWithUpdatedAmountList = updateSubSequentAwardAmountNew(amendmentListOfProject,
                                idToAmendmentWithAwardMap, amendmentToProcess, updatedAwardList);
                        /** Method calling to update the Sub Sequent Award Time */
                        List<Award__c> awardWithUpdatedTimeList = updateSubSequentAwardTime(amendmentListOfProject,
                                idToAmendmentWithAwardMap, amendmentToProcess, awardWithUpdatedAmountList);
                        awardToUpdateList.addAll(awardWithUpdatedTimeList);
                        /** Method calling to update the final changes on Project Amount */
                        Project__c projectRecordUpdate = updateProjectRecord(project, latestAmendmentAward);
                        projectToUpdateList.add(projectRecordUpdate);
                    }
                    else if (amendmentToProcess.AmendmentType__c == ALS_CONSTANTS.Amendment_Type_MoneyExtensionAndCostShareChange) {
                        /** Method calling to update the Sub Sequent Award Amount */
                        /*List<Award__c> awardWithUpdatedAmountList = updateSubSequentAwardAmount(amendmentListOfProject,
                                idToAmendmentWithAwardMap, amendmentToProcess, updatedAwardList);*/
                        List<Award__c> awardWithUpdatedAmountList = updateSubSequentAwardAmountNew(amendmentListOfProject,
                                idToAmendmentWithAwardMap, amendmentToProcess, updatedAwardList);
                        /** Method calling to update the Sub Sequent Award Cost Shares */
                        List<Award__c> awardWithUpdatedCostSharesList = updateSubSequentAwardCostShare(amendmentListOfProject,
                                idToAmendmentWithAwardMap, amendmentToProcess, awardWithUpdatedAmountList);
                        awardToUpdateList.addAll(awardWithUpdatedCostSharesList);
                        /** Method calling to update the final changes on Project Amount */
                        Project__c projectRecordUpdate = updateProjectRecord(project, latestAmendmentAward);
                        projectToUpdateList.add(projectRecordUpdate);
                    }
                }
            }
            /**Updating the Sub sequent Amendments */
            if(amendmentToUpdateList.size() > 0) {
                update amendmentToUpdateList;
            }
            /**Updating Award records */
            if(awardToUpdateList.size() > 0) {
                update awardToUpdateList;
            }
            /**Updating Project records */
            if(projectToUpdateList.size() > 0) {
                update projectToUpdateList;
            }
        }
    }

    /*********************************************
	* Method Name : updateSubSequentAmendmentsAmount
	* Called From Method : updateSubSequentAmendmentAwardAndProjectUponAmendmentUpdate
	* Author : Ricky
	* Inputs : - 1. List<Amendment_Request__c> amendmentsToUpdate - List of Amendments available on the Project
	*            2. Amendment_Request__c amendmentToProcess - Amendment record which got updated
	* Description: This method is used to auto calculate the Subsequent Amendments Amount
	*               based on updated "New Obligated Amount" of the Updated Amendment.
	*********************************************/
    private static List<Amendment_Request__c> updateSubSequentAmendmentsAmount(List<Amendment_Request__c> amendmentsToUpdate,
            Amendment_Request__c amendmentToProcess) {
        /** To collect the Amendment in which changes are made */
        List<Amendment_Request__c> updateSubSequentAmendmentsToUpdateList = new List<Amendment_Request__c>();
        Decimal previousAwardAmount; /** Temporary value to Store the updated value of Amount */
        for (Amendment_Request__c amendment : amendmentsToUpdate) {
            /** Condition to check if the current Amendment is the Amendment in which changes has been made by user
                Checking the Amendment Types as only changes in Supplement Award affect the sub Sequent Amendments */
            if(amendment.FDSR__c == amendmentToProcess.FDSR__c
                    && (amendment.AmendmentType__c == ALS_CONSTANTS.Amendment_Type_MoneyExtension
                    || amendment.AmendmentType__c == ALS_CONSTANTS.Amendment_Type_MoneyExtensionAndTimeExtension
                    || amendment.AmendmentType__c == ALS_CONSTANTS.Amendment_Type_MoneyExtensionAndCostShareChange)) {
                previousAwardAmount = amendmentToProcess.NewObligatedAmount__c;
            }
            /** Condition to check if the current Amendment is the sub sequent Amendment to the Amendment in which changes has been made by user
                Checking the Amendment Types in oreder to make changes in the sub Sequent Amendments Amount */
            else if (amendment.FDSR__c > amendmentToProcess.FDSR__c
                    && (amendment.AmendmentType__c == ALS_CONSTANTS.Amendment_Type_MoneyExtension
                        || amendment.AmendmentType__c == ALS_CONSTANTS.Amendment_Type_MoneyExtensionAndTimeExtension
                        || amendment.AmendmentType__c == ALS_CONSTANTS.Amendment_Type_MoneyExtensionAndCostShareChange)) {
                /** Temp variable to check the null pointer exception of the Supplement Award field on Amendment */
                Decimal supplementAward = amendment.SupplementAward__c == null ? 0.00 : amendment.SupplementAward__c;
                /** Updating the New Obligated Amount on Amendment based on updated Supplement Award */
                amendment.NewObligatedAmount__c = supplementAward + previousAwardAmount;
                updateSubSequentAmendmentsToUpdateList.add(amendment);
                previousAwardAmount = amendment.NewObligatedAmount__c;
            }
        }
        /** Return statement */
        if(updateSubSequentAmendmentsToUpdateList.size() > 0) {
            return updateSubSequentAmendmentsToUpdateList;
        }
        else {
            return null;
        }
    }

    /*********************************************
	* Method Name : updateSubSequentAwardAmountNew
	* Called From Method : updateSubSequentAmendmentAwardAndProjectUponAmendmentUpdate
	* Author : Ricky
	* Inputs : - 1. List<Amendment_Request__c> amendmentsToUpdate - List of Amendments available on the Project
	*            2. Map<Id, Amendment_Request__c> idToAmendmentWithAwardMap - Amendment with their related Award record,
	*                                                                           In order to fetch the related Award of Amendment.
	*            3. Amendment_Request__c amendmentToProcess - Amendment record which got updated
	*            4. List<Award__c> updatedAwardList - Award Record List with Updated values,
	*                                                   In case the Award record has been updated before for other value,
	*                                                   In order to carry forward that result.
	* Description: This method is used to auto calculate the Subsequent Award Time
	*               based on updated Time value of the Updated Amendment.
	*********************************************/
    private static List<Award__c> updateSubSequentAwardAmountNew(List<Amendment_Request__c> amendmentsOfProjectList,
            Map<Id, Amendment_Request__c> idToAmendmentWithAwardMap, Amendment_Request__c amendmentToProcess, List<Award__c> updatedAwardList) {

        Award__c previousAwardRecord = new Award__c(); /** Temporary value to Store the updated value of Amount */
        for(Amendment_Request__c amendment : amendmentsOfProjectList) {
            /** Fetching Award of the current Amendment from idToAmendmentWithAwardMap collection */
            Award__c awardToUpdate = idToAmendmentWithAwardMap.get(amendment.Id).Awards__r[0];
            /** Condition to check if the current Amendment is the Amendment in which changes has been made by user
                Checking the Amendment Types in order to updates Amount on Award record */
            if(amendment.FDSR__c == amendmentToProcess.FDSR__c
                    && (amendment.AmendmentType__c == ALS_CONSTANTS.Amendment_Type_MoneyExtension
                        || amendment.AmendmentType__c == ALS_CONSTANTS.Amendment_Type_MoneyExtensionAndTimeExtension
                        || amendment.AmendmentType__c == ALS_CONSTANTS.Amendment_Type_MoneyExtensionAndCostShareChange
                        || amendment.AmendmentType__c == ALS_CONSTANTS.Amendment_Type_PercentageChange)) {
                Award__c awardToBeUpdated = new Award__c();
                if (updatedAwardList?.contains(awardToUpdate)) {
                    awardToBeUpdated = updatedAwardList.get(updatedAwardList.indexOf(awardToUpdate));
                    updatedAwardList.remove(updatedAwardList.indexOf(awardToUpdate));
                }
                else {
                    awardToBeUpdated = awardToUpdate;
                }

                if (amendment.AmendmentType__c != ALS_CONSTANTS.Amendment_Type_PercentageChange) {
                    awardToBeUpdated.Supplement_Award__c = amendmentToProcess.SupplementAward__c;
                    awardToBeUpdated.AmountObligated__c = amendmentToProcess.NewObligatedAmount__c;
                }
                else if (amendment.AmendmentType__c == ALS_CONSTANTS.Amendment_Type_PercentageChange) {
                    awardToBeUpdated.AmountObligated__c = awardToUpdate.AmountObligated__c == null ? 0.00 : awardToUpdate.AmountObligated__c;
                }

                if (amendment.AmendmentType__c == ALS_CONSTANTS.Amendment_Type_PercentageChange
                        || amendment.AmendmentType__c == ALS_CONSTANTS.Amendment_Type_MoneyExtensionAndCostShareChange) {
                    previousAwardRecord.FEMA_Share__c = amendment.FEMA_Share__c == null ? 0.00 : amendment.FEMA_Share__c;
                    previousAwardRecord.State_Share__c = amendment.State_Share__c == null ? 0.00 : amendment.State_Share__c;
                    previousAwardRecord.State_Admin__c = awardToUpdate.State_Admin__c == null ? 0.00 : awardToUpdate.State_Admin__c;
                }
                else {
                    previousAwardRecord.FEMA_Share__c = awardToUpdate.FEMA_Share__c == null ? 0.00 : awardToUpdate.FEMA_Share__c;
                    previousAwardRecord.State_Share__c = awardToUpdate.State_Share__c == null ? 0.00 : awardToUpdate.State_Share__c;
                    previousAwardRecord.State_Admin__c = awardToUpdate.State_Admin__c == null ? 0.00 : awardToUpdate.State_Admin__c;
                }

                Decimal federalProjectAward = awardToBeUpdated.Federal_Project_Amount__c == null ? 0.00 : awardToBeUpdated.Federal_Project_Amount__c;
                Decimal stateProjectAward = awardToBeUpdated.State_Project_Amount__c == null ? 0.00 : awardToBeUpdated.State_Project_Amount__c;
                Decimal adminProjectAward = awardToBeUpdated.State_Admin_Amount__c == null ? 0.00 : awardToBeUpdated.State_Admin_Amount__c;

                awardToBeUpdated.Federal_Project_Amount__c = ((awardToBeUpdated.AmountObligated__c * previousAwardRecord.FEMA_Share__c)/100)?.setScale(2,system.RoundingMode.DOWN);
                awardToBeUpdated.State_Project_Amount__c = ((awardToBeUpdated.AmountObligated__c * previousAwardRecord.State_Share__c)/100)?.setScale(2,system.RoundingMode.DOWN);
                awardToBeUpdated.State_Admin_Amount__c = ((awardToBeUpdated.State_Project_Amount__c * previousAwardRecord.State_Admin__c)/100)?.setScale(2,system.RoundingMode.DOWN);
                awardToBeUpdated.Federal_Supplement_Amount__c += (awardToBeUpdated.Federal_Project_Amount__c - federalProjectAward)?.setScale(2,system.RoundingMode.DOWN);
                awardToBeUpdated.State_Supplement_Amount__c += (awardToBeUpdated.State_Project_Amount__c - stateProjectAward)?.setScale(2,system.RoundingMode.DOWN);
                awardToBeUpdated.State_Admin_Supplement_Amount__c += (awardToBeUpdated.State_Admin_Amount__c - adminProjectAward)?.setScale(2,system.RoundingMode.DOWN);

                awardToBeUpdated.Total_Obligated_Amount__c = (awardToBeUpdated.Federal_Project_Amount__c
                        + awardToBeUpdated.State_Project_Amount__c + awardToBeUpdated.State_Admin_Amount__c)?.setScale(2,system.RoundingMode.DOWN);
                awardToBeUpdated.Total_Obligated_Supplement_Amount__c = (awardToBeUpdated.Federal_Supplement_Amount__c
                        + awardToBeUpdated.State_Supplement_Amount__c + awardToBeUpdated.State_Admin_Supplement_Amount__c)?.setScale(2,system.RoundingMode.DOWN);

                awardToBeUpdated.Federal_Retention__c = ((awardToBeUpdated.Federal_Supplement_Amount__c
                        * awardToBeUpdated.Federal_Retention_Share__c)/100)?.setScale(2,system.RoundingMode.DOWN);
                awardToBeUpdated.State_Retention__c = ((awardToBeUpdated.State_Supplement_Amount__c
                        * awardToBeUpdated.State_Retention_Share__c)/100)?.setScale(2,system.RoundingMode.DOWN);

                awardToBeUpdated.Federal_Amount_Available__c = (awardToBeUpdated.Federal_Supplement_Amount__c
                        - awardToBeUpdated.Federal_Retention__c)?.setScale(2,system.RoundingMode.DOWN);
                awardToBeUpdated.State_Amount_Available__c = (awardToBeUpdated.State_Supplement_Amount__c
                        - awardToBeUpdated.State_Retention__c)?.setScale(2,system.RoundingMode.DOWN);

                awardToBeUpdated.Sum_of_State_and_Federal__c = (awardToBeUpdated.Federal_Supplement_Amount__c
                        + awardToBeUpdated.State_Supplement_Amount__c)?.setScale(2,system.RoundingMode.DOWN);
                awardToUpdate.Sum_of_State_and_Admin_Supplement__c = (awardToUpdate.State_Supplement_Amount__c
                        + awardToUpdate.State_Admin_Supplement_Amount__c)?.setScale(2,system.RoundingMode.DOWN);

                awardToUpdate.Sum_of_State_and_Federal_to_Date__c = (awardToUpdate.Federal_Project_Amount__c
                        + awardToUpdate.State_Project_Amount__c)?.setScale(2,system.RoundingMode.DOWN);
                awardToUpdate.Sum_of_State_and_Admin_to_Date__c = (awardToUpdate.State_Project_Amount__c
                        + awardToUpdate.State_Admin_Amount__c)?.setScale(2,system.RoundingMode.DOWN);

                updatedAwardList.add(awardToBeUpdated);

                previousAwardRecord.AmountObligated__c = awardToBeUpdated.AmountObligated__c == null ? 0.00 : awardToBeUpdated.AmountObligated__c;
                previousAwardRecord.Federal_Project_Amount__c = awardToBeUpdated.Federal_Project_Amount__c == null ? 0.00 : awardToBeUpdated.Federal_Project_Amount__c;
                previousAwardRecord.State_Project_Amount__c = awardToBeUpdated.State_Project_Amount__c == null ? 0.00 : awardToBeUpdated.State_Project_Amount__c;
                previousAwardRecord.State_Admin_Amount__c = awardToBeUpdated.State_Admin_Amount__c == null ? 0.00 : awardToBeUpdated.State_Admin_Amount__c;
            }
            /** Condition to check if the current Amendment is the sub sequent  to the Amendment in which changes has been made by user
                Checking the Amendment Types in order to updates Amount on Award record */
            else if(amendment.FDSR__c > amendmentToProcess.FDSR__c
                    && (amendment.AmendmentType__c == ALS_CONSTANTS.Amendment_Type_MoneyExtension
                        || amendment.AmendmentType__c == ALS_CONSTANTS.Amendment_Type_MoneyExtensionAndTimeExtension
                        || amendment.AmendmentType__c == ALS_CONSTANTS.Amendment_Type_MoneyExtensionAndCostShareChange
                        || amendment.AmendmentType__c ==  ALS_CONSTANTS.Amendment_Type_PercentageChange)) {
                Award__c awardToBeUpdated = new Award__c();
                if (updatedAwardList?.contains(awardToUpdate)) {
                    awardToBeUpdated = updatedAwardList.get(updatedAwardList.indexOf(awardToUpdate));
                    updatedAwardList.remove(updatedAwardList.indexOf(awardToUpdate));
                }
                else {
                    awardToBeUpdated = awardToUpdate;
                }
                Decimal adminShare = awardToBeUpdated.State_Admin__c == null? 0.00 : awardToBeUpdated.State_Admin__c;

                /** Condition to check -
                 * 1. If Amendment Type is not Percentage Change - To copy the Supplement Amount and New Obligated Amount from Amendment.
                 * 2. If Amendment Type is Percentage Change - As in Percentage change Amendment Amount Obligated is same as previous Award */
                if(amendment.AmendmentType__c !=  ALS_CONSTANTS.Amendment_Type_PercentageChange) {
                    awardToBeUpdated.Supplement_Award__c = amendment.SupplementAward__c;
                    awardToBeUpdated.AmountObligated__c = previousAwardRecord.AmountObligated__c + amendment.SupplementAward__c;
                    previousAwardRecord.AmountObligated__c = awardToBeUpdated.AmountObligated__c == null ? 0.00 : awardToBeUpdated.AmountObligated__c;

                    //amountObligated = awardToBeUpdated.AmountObligated__c == null? 0.00 : awardToBeUpdated.AmountObligated__c;
                }
                else if(amendment.AmendmentType__c ==  ALS_CONSTANTS.Amendment_Type_PercentageChange) {
                    awardToBeUpdated.AmountObligated__c = previousAwardRecord.AmountObligated__c == null? 0.00 : previousAwardRecord.AmountObligated__c;
                    //amountObligated = awardToBeUpdated.AmountObligated__c == null? 0.00 : awardToBeUpdated.AmountObligated__c;
                }

                /** 1. If the Amendment Type includes Percentage change, then copy the Cost Share% from Amendment.
                 * 2. Or else to copy Cost Share% from previous Award. */
                if (amendment.AmendmentType__c == ALS_CONSTANTS.Amendment_Type_MoneyExtensionAndCostShareChange
                        ||amendment.AmendmentType__c == ALS_CONSTANTS.Amendment_Type_PercentageChange) {
                    awardToBeUpdated.FEMA_Share__c = amendment.FEMA_Share__c == null ? 0.00 : amendment.FEMA_Share__c;
                    awardToBeUpdated.State_Share__c = amendment.State_Share__c == null ? 0.00 : amendment.State_Share__c;

                    previousAwardRecord.FEMA_Share__c = awardToBeUpdated.FEMA_Share__c;
                    previousAwardRecord.State_Share__c = awardToBeUpdated.State_Share__c;
                }
                else {
                    awardToBeUpdated.FEMA_Share__c = previousAwardRecord.FEMA_Share__c == null? 0.00 : previousAwardRecord.FEMA_Share__c;
                    awardToBeUpdated.State_Share__c = previousAwardRecord.State_Share__c == null? 0.00 : previousAwardRecord.State_Share__c;
                }

                if (amendment.Project__r.FundingSource__c == ALS_CONSTANTS.Project_FundingSource_FederalOnly
                        || amendment.Project__r.FundingSource__c == ALS_CONSTANTS.Project_FundingSource_FederalAndState) {
                    awardToBeUpdated.Federal_Project_Amount__c = ((previousAwardRecord.AmountObligated__c
                            * previousAwardRecord.FEMA_Share__c)/100)?.setScale(2,system.RoundingMode.DOWN);
                    awardToBeUpdated.Federal_Supplement_Amount__c = (awardToBeUpdated.Federal_Project_Amount__c
                            - previousAwardRecord.Federal_Project_Amount__c)?.setScale(2,system.RoundingMode.DOWN);

                    previousAwardRecord.Federal_Project_Amount__c = awardToBeUpdated.Federal_Project_Amount__c == null ? 0.00 : awardToBeUpdated.Federal_Project_Amount__c;
                }
                if (amendment.Project__r.FundingSource__c == ALS_CONSTANTS.Project_FundingSource_StateOnly
                        || amendment.Project__r.FundingSource__c == ALS_CONSTANTS.Project_FundingSource_FederalAndState) {
                    awardToBeUpdated.State_Project_Amount__c = ((previousAwardRecord.AmountObligated__c
                            * previousAwardRecord.State_Share__c)/100)?.setScale(2,system.RoundingMode.DOWN);
                    awardToBeUpdated.State_Supplement_Amount__c = (awardToBeUpdated.State_Project_Amount__c
                            - previousAwardRecord.State_Project_Amount__c)?.setScale(2,system.RoundingMode.DOWN);
                    awardToBeUpdated.State_Admin_Amount__c = ((awardToBeUpdated.State_Project_Amount__c
                            * adminShare)/100)?.setScale(2,system.RoundingMode.DOWN);
                    awardToBeUpdated.State_Admin_Supplement_Amount__c = (awardToBeUpdated.State_Admin_Amount__c
                            - previousAwardRecord.State_Admin_Amount__c)?.setScale(2,system.RoundingMode.DOWN);

                    previousAwardRecord.State_Project_Amount__c = awardToBeUpdated.State_Project_Amount__c == null ? 0.00 : awardToBeUpdated.State_Project_Amount__c;
                    previousAwardRecord.State_Admin_Amount__c = awardToBeUpdated.State_Admin_Amount__c == null ? 0.00 : awardToBeUpdated.State_Admin_Amount__c;
                }

                /** Updating the Previous Obligated Amount fields. */
                awardToBeUpdated.Previous_Amount_Obligated__c = (awardToBeUpdated.AmountObligated__c
                        - awardToBeUpdated.Supplement_Award__c)?.setScale(2,system.RoundingMode.DOWN);
                awardToBeUpdated.Previous_Federal_Amount_Obligated__c = (awardToBeUpdated.Federal_Project_Amount__c
                        - awardToBeUpdated.Federal_Supplement_Amount__c)?.setScale(2,system.RoundingMode.DOWN);
                awardToBeUpdated.Previous_State_Amount_Obligated__c = (awardToBeUpdated.State_Project_Amount__c
                        - awardToBeUpdated.State_Supplement_Amount__c)?.setScale(2,system.RoundingMode.DOWN);
                awardToBeUpdated.Previous_State_Admin_Amount_Obligated__c = (awardToBeUpdated.State_Admin_Amount__c
                        - awardToBeUpdated.State_Admin_Supplement_Amount__c)?.setScale(2,system.RoundingMode.DOWN);

                /** Calculating the Federal, State and Admin Amount dependent fields - Used for Docu gen Templates. */
                awardToBeUpdated.Total_Obligated_Amount__c = (awardToBeUpdated.Federal_Project_Amount__c + awardToBeUpdated.State_Project_Amount__c
                        + awardToBeUpdated.State_Admin_Amount__c)?.setScale(2,system.RoundingMode.DOWN);
                awardToBeUpdated.Total_Obligated_Supplement_Amount__c = (awardToBeUpdated.Federal_Supplement_Amount__c + awardToBeUpdated.State_Supplement_Amount__c
                        + awardToBeUpdated.State_Admin_Supplement_Amount__c)?.setScale(2,system.RoundingMode.DOWN);

                awardToBeUpdated.Federal_Retention__c = ((awardToBeUpdated.Federal_Supplement_Amount__c
                        * awardToBeUpdated.Federal_Retention_Share__c)/100)?.setScale(2,system.RoundingMode.DOWN);
                awardToBeUpdated.State_Retention__c = ((awardToBeUpdated.State_Supplement_Amount__c
                        * awardToBeUpdated.State_Retention_Share__c)/100)?.setScale(2,system.RoundingMode.DOWN);
                awardToBeUpdated.Federal_Amount_Available__c = (awardToBeUpdated.Federal_Supplement_Amount__c
                        - awardToBeUpdated.Federal_Retention__c)?.setScale(2,system.RoundingMode.DOWN);
                awardToBeUpdated.State_Amount_Available__c = (awardToBeUpdated.State_Supplement_Amount__c
                        - awardToBeUpdated.State_Retention__c)?.setScale(2,system.RoundingMode.DOWN);

                awardToBeUpdated.Sum_of_State_and_Federal__c = (awardToBeUpdated.Federal_Supplement_Amount__c
                        + awardToBeUpdated.State_Supplement_Amount__c)?.setScale(2,system.RoundingMode.DOWN);
                awardToBeUpdated.Sum_of_State_and_Admin_Supplement__c = (awardToBeUpdated.State_Supplement_Amount__c
                        + awardToBeUpdated.State_Admin_Supplement_Amount__c)?.setScale(2,system.RoundingMode.DOWN);

                awardToUpdate.Sum_of_State_and_Federal_to_Date__c = (awardToUpdate.Federal_Project_Amount__c
                        + awardToUpdate.State_Project_Amount__c)?.setScale(2,system.RoundingMode.DOWN);
                awardToUpdate.Sum_of_State_and_Admin_to_Date__c = (awardToUpdate.State_Project_Amount__c
                        + awardToUpdate.State_Admin_Amount__c)?.setScale(2,system.RoundingMode.DOWN);

                updatedAwardList.add(awardToBeUpdated); /** Adding Award record in the list for updating. */
            }
            /** Condition to check if the current Amendment is the Amendment in which changes has been made by user
             * If the Amendment Type is does not include Money Changes/Percentage Amendment Types,
             * then updating the Award record based on the Amount from previous record */
            else if(amendment.FDSR__c > amendmentToProcess.FDSR__c) {
                Award__c awardToBeUpdated = new Award__c();
                if (updatedAwardList?.contains(awardToUpdate)) {
                    awardToBeUpdated = updatedAwardList.get(updatedAwardList.indexOf(awardToUpdate));
                    updatedAwardList.remove(updatedAwardList.indexOf(awardToUpdate));
                }
                else {
                    awardToBeUpdated = awardToUpdate;
                }
                awardToBeUpdated.Supplement_Award__c = 0;
                awardToBeUpdated.AmountObligated__c = previousAwardRecord.AmountObligated__c == null? 0.00 : previousAwardRecord.AmountObligated__c;
                awardToBeUpdated.Federal_Project_Amount__c = previousAwardRecord.Federal_Project_Amount__c?.setScale(2,system.RoundingMode.DOWN);
                awardToBeUpdated.State_Project_Amount__c = previousAwardRecord.State_Project_Amount__c?.setScale(2,system.RoundingMode.DOWN);
                awardToBeUpdated.State_Admin_Amount__c = previousAwardRecord.State_Admin_Amount__c?.setScale(2,system.RoundingMode.DOWN);
                awardToBeUpdated.Federal_Supplement_Amount__c = 0;
                awardToBeUpdated.State_Supplement_Amount__c = 0;
                awardToBeUpdated.State_Admin_Supplement_Amount__c = 0;

                /** Updating the Previous Obligated Amount fields. */
                awardToBeUpdated.Previous_Amount_Obligated__c = (awardToBeUpdated.AmountObligated__c
                        - awardToBeUpdated.Supplement_Award__c)?.setScale(2,system.RoundingMode.DOWN);
                awardToBeUpdated.Previous_Federal_Amount_Obligated__c = (awardToBeUpdated.Federal_Project_Amount__c
                        - awardToBeUpdated.Federal_Supplement_Amount__c)?.setScale(2,system.RoundingMode.DOWN);
                awardToBeUpdated.Previous_State_Amount_Obligated__c = (awardToBeUpdated.State_Project_Amount__c
                        - awardToBeUpdated.State_Supplement_Amount__c)?.setScale(2,system.RoundingMode.DOWN);
                awardToBeUpdated.Previous_State_Admin_Amount_Obligated__c = (awardToBeUpdated.State_Admin_Amount__c
                        - awardToBeUpdated.State_Admin_Supplement_Amount__c)?.setScale(2,system.RoundingMode.DOWN);

                awardToBeUpdated.Total_Obligated_Amount__c = (awardToBeUpdated.Federal_Project_Amount__c + awardToBeUpdated.State_Project_Amount__c
                        + awardToBeUpdated.State_Admin_Amount__c)?.setScale(2,system.RoundingMode.DOWN);
                awardToBeUpdated.Total_Obligated_Supplement_Amount__c = 0;

                awardToBeUpdated.Sum_of_State_and_Federal_to_Date__c = (awardToBeUpdated.Federal_Project_Amount__c
                        + awardToBeUpdated.State_Project_Amount__c)?.setScale(2,system.RoundingMode.DOWN);
                awardToBeUpdated.Sum_of_State_and_Admin_to_Date__c = (awardToBeUpdated.State_Project_Amount__c
                        + awardToBeUpdated.State_Admin_Amount__c)?.setScale(2,system.RoundingMode.DOWN);

                awardToBeUpdated.Federal_Retention__c = 0;
                awardToBeUpdated.State_Retention__c = 0;

                awardToBeUpdated.Federal_Amount_Available__c = 0;
                awardToBeUpdated.State_Amount_Available__c = 0;

                awardToBeUpdated.Sum_of_State_and_Federal__c = 0;
                awardToBeUpdated.Sum_of_State_and_Admin_Supplement__c = 0;

                updatedAwardList.add(awardToBeUpdated);
            }
        }
        /** Return Statement */
        if(updatedAwardList.size() > 0) {
            return updatedAwardList;
        }
        else {
            return null;
        }
    }

    /*********************************************
	* Method Name : updateSubSequentAwardTime
	* Called From Method : updateSubSequentAmendmentAwardAndProjectUponAmendmentUpdate
	* Author : Ricky
	* Inputs : - 1. List<Amendment_Request__c> amendmentsToUpdate - List of Amendments available on the Project
	*            2. Map<Id, Amendment_Request__c> idToAmendmentWithAwardMap - Amendment with their related Award record,
	*                                                                           In order to fetch the related Award of Amendment.
	*            3. Amendment_Request__c amendmentToProcess - Amendment record which got updated
	*            4. List<Award__c> updatedAwardList - Award Record List with Updated values,
	*                                                   In case the Award record has been updated before for other value,
	*                                                   In order to carry forward that result.
	* Description: This method is used to auto calculate the Subsequent Award Time
	*               based on updated Time value of the Updated Amendment.
	*********************************************/
    private static List<Award__c> updateSubSequentAwardTime(List<Amendment_Request__c> amendmentsOfProjectList,
            Map<Id, Amendment_Request__c> idToAmendmentWithAwardMap, Amendment_Request__c amendmentToProcess, List<Award__c> updatedAwardList) {
        for(Amendment_Request__c amendment : amendmentsOfProjectList) {
            /** Fetching Award of the current Amendment from idToAmendmentWithAwardMap collection */
            Award__c awardToUpdate = idToAmendmentWithAwardMap.get(amendment.Id).Awards__r[0];
            /** Condition to check if the current Amendment is the Amendment in which changes has been made by user
                Checking the Amendment Types in order to updates Time on Award record */
            if(amendment.FDSR__c == amendmentToProcess.FDSR__c
                    && (amendment.AmendmentType__c == ALS_CONSTANTS.Amendment_Type_TimeExtension
                    || amendment.AmendmentType__c == ALS_CONSTANTS.Amendment_Type_MoneyExtensionAndTimeExtension)) {
                if (updatedAwardList?.contains(awardToUpdate)) {
                    Award__c awardToBeUpdate = updatedAwardList.get(updatedAwardList.indexOf(awardToUpdate));
                    awardToBeUpdate.AwardStartDate__c = amendmentToProcess.TimeExtensionStartDate__c;
                    awardToBeUpdate.AwardEndDate__c = amendmentToProcess.TimeExtensionEndDate__c;

                    updatedAwardList.remove(updatedAwardList.indexOf(awardToUpdate));
                    updatedAwardList.add(awardToBeUpdate);
                }
                else {
                    awardToUpdate.AwardStartDate__c = amendmentToProcess.TimeExtensionStartDate__c;
                    awardToUpdate.AwardEndDate__c = amendmentToProcess.TimeExtensionEndDate__c;
                    updatedAwardList.add(awardToUpdate);
                }
            }
            /** Condition to check if the current Amendment is the sub sequent to the Amendment in which changes has been made by user
                Checking the Amendment Type which includes Time Extension Amendment, In order to stop updating the Next Awards */
            else if(amendment.FDSR__c > amendmentToProcess.FDSR__c
                    && (amendment.AmendmentType__c == ALS_CONSTANTS.Amendment_Type_TimeExtension
                    || amendment.AmendmentType__c == ALS_CONSTANTS.Amendment_Type_MoneyExtensionAndTimeExtension)) {
                break;
            }
            /** Condition to check if the current Amendment is  sub sequent the Amendment in which changes has been made by user
                If the Amendment Type is other than the Time includes Changes Amendment Types, Updating the only Award records */
            else if(amendment.FDSR__c > amendmentToProcess.FDSR__c
                    && amendment.AmendmentType__c != ALS_CONSTANTS.Amendment_Type_TimeExtension
                    && amendment.AmendmentType__c != ALS_CONSTANTS.Amendment_Type_MoneyExtensionAndTimeExtension){
                if (updatedAwardList?.contains(awardToUpdate)) {
                    Award__c awardToBeUpdate = updatedAwardList.get(updatedAwardList.indexOf(awardToUpdate));
                    awardToBeUpdate.AwardStartDate__c = amendmentToProcess.TimeExtensionStartDate__c;
                    awardToBeUpdate.AwardEndDate__c = amendmentToProcess.TimeExtensionEndDate__c;
                    updatedAwardList.remove(updatedAwardList.indexOf(awardToUpdate));
                    updatedAwardList.add(awardToBeUpdate);
                }
                else {
                    awardToUpdate.AwardStartDate__c = amendmentToProcess.TimeExtensionStartDate__c;
                    awardToUpdate.AwardEndDate__c = amendmentToProcess.TimeExtensionEndDate__c;
                    updatedAwardList.add(awardToUpdate);
                }
            }
        }
        /** Return statement */
        if(updatedAwardList.size() > 0) {
            return updatedAwardList;
        }
        else {
            return null;
        }
    }

    /*********************************************
	* Method Name : updateSubSequentAwardCostShare
	* Called From Method : updateSubSequentAmendmentAwardAndProjectUponAmendmentUpdate
	* Author : Ricky
	* Inputs : - 1. List<Amendment_Request__c> amendmentsToUpdate - List of Amendments available on the Project
	*            2. Map<Id, Amendment_Request__c> idToAmendmentWithAwardMap - Amendment with their related Award record,
	*                                                                           In order to fetch the related Award of Amendment.
	*            3. Amendment_Request__c amendmentToProcess - Amendment record which got updated
	*            4. List<Award__c> updatedAwardList - Award Record List with Updated values,
	*                                                   In case the Award record has been updated before for other value,
	*                                                   In order to carry forward that result.
	* Description: This method is used to auto calculate the Subsequent Award Cost Shares
	*               based on updated Cost Share value of the Updated Amendment.
	*********************************************/
    private static List<Award__c> updateSubSequentAwardCostShare(List<Amendment_Request__c> amendmentsOfProjectList,
            Map<Id, Amendment_Request__c> idToAmendmentWithAwardMap, Amendment_Request__c amendmentToProcess, List<Award__c> updatedAwardList) {
        for(Amendment_Request__c amendment : amendmentsOfProjectList) {
            /** Fetching Award of the current Amendment from idToAmendmentWithAwardMap collection */
            Award__c awardToUpdate = idToAmendmentWithAwardMap.get(amendment.Id).Awards__r[0];
            /** Condition to check if the current Amendment is the Amendment in which changes has been made by user
                Checking the Amendment Types in order to updates Cost Shares on Award record */
            if(amendment.FDSR__c == amendmentToProcess.FDSR__c
                    && (amendment.AmendmentType__c == ALS_CONSTANTS.Amendment_Type_PercentageChange
                    || amendment.AmendmentType__c == ALS_CONSTANTS.Amendment_Type_MoneyExtensionAndCostShareChange)) {

                if (updatedAwardList?.contains(awardToUpdate)) {
                    Award__c awardToBeUpdate = updatedAwardList.get(updatedAwardList.indexOf(awardToUpdate));
                    awardToBeUpdate.FEMA_Share__c = amendmentToProcess.FEMA_Share__c;
                    awardToBeUpdate.State_Share__c = amendmentToProcess.State_Share__c;

                    updatedAwardList.remove(updatedAwardList.indexOf(awardToUpdate));
                    updatedAwardList.add(awardToBeUpdate);
                }
                else {
                    awardToUpdate.FEMA_Share__c = amendmentToProcess.FEMA_Share__c;
                    awardToUpdate.State_Share__c = amendmentToProcess.State_Share__c;
                    updatedAwardList.add(awardToUpdate);
                }
            }
            /** Condition to check if the current Amendment is the sub sequent to the Amendment in which changes has been made by user
            Checking the Amendment Type which includes Cost Share Extension Amendment, In order to stop updating the Next Awards */
            else if(amendment.FDSR__c > amendmentToProcess.FDSR__c
                    && (amendment.AmendmentType__c == ALS_CONSTANTS.Amendment_Type_PercentageChange
                    || amendment.AmendmentType__c == ALS_CONSTANTS.Amendment_Type_MoneyExtensionAndCostShareChange)) {
                break;
            }
            /** Condition to check if the current Amendment is  sub sequent the Amendment in which changes has been made by user
                If the Amendment Type is other than the Cost Share includes Changes Amendment Types, Updating the only Award records */
            else if(amendment.FDSR__c > amendmentToProcess.FDSR__c
                    && amendment.AmendmentType__c != ALS_CONSTANTS.Amendment_Type_PercentageChange
                    && amendment.AmendmentType__c != ALS_CONSTANTS.Amendment_Type_MoneyExtensionAndCostShareChange){
                if (updatedAwardList?.contains(awardToUpdate)) {
                    Award__c awardToBeUpdate = updatedAwardList.get(updatedAwardList.indexOf(awardToUpdate));
                    awardToBeUpdate.FEMA_Share__c = amendmentToProcess.FEMA_Share__c;
                    awardToBeUpdate.State_Share__c = amendmentToProcess.State_Share__c;
                    updatedAwardList.remove(updatedAwardList.indexOf(awardToUpdate));
                    updatedAwardList.add(awardToBeUpdate);
                }
                else {
                    awardToUpdate.FEMA_Share__c = amendmentToProcess.FEMA_Share__c;
                    awardToUpdate.State_Share__c = amendmentToProcess.State_Share__c;
                    updatedAwardList.add(awardToUpdate);
                }
            }
        }
        /** Return statement */
        if(updatedAwardList.size() > 0) {
            return updatedAwardList;
        }
        else {
            return null;
        }
    }

    /*********************************************
	* Method Name : updateProjectRecord
	* Called From Method : updateSubSequentAmendmentAwardAndProjectUponAmendmentUpdate, updateAmendmentAwardAndProjectUponAmendmentDelete
	* Author : Ricky
	* Inputs : - 1. Project__c projectToUpdate - Project record of the Amendment which got updated/Deleted
	*            2. Award__c lastAmendmentAward - latest Award record with updated values
	* Description: This method is used to auto calculate the Subsequent Award Cost Shares
	*               based on updated Cost Share value of the Updated Amendment.
	*********************************************/
    private static Project__c updateProjectRecord(Project__c projectToUpdate, Award__c lastAmendmentAward) {
        /** Updating the Project records based on latest Award record values */
        projectToUpdate.Start_Date__c = lastAmendmentAward.AwardStartDate__c;
        projectToUpdate.End_Date__c = lastAmendmentAward.AwardEndDate__c;
        projectToUpdate.State_Share__c = lastAmendmentAward.State_Share__c == null ? 0.00 : lastAmendmentAward.State_Share__c;
        projectToUpdate.FEMA_Share__c = lastAmendmentAward.FEMA_Share__c == null ? 0.00 : lastAmendmentAward.FEMA_Share__c;
        projectToUpdate.Total_Project_Award__c = lastAmendmentAward.AmountObligated__c == null ? 0.00 : lastAmendmentAward.AmountObligated__c;
        projectToUpdate.Federal_Project_Award__c = ((projectToUpdate.Total_Project_Award__c
                * projectToUpdate.FEMA_Share__c)/100)?.setScale(2,system.RoundingMode.DOWN);
        projectToUpdate.State_Project_Award__c = ((projectToUpdate.Total_Project_Award__c
                * projectToUpdate.State_Share__c)/100)?.setScale(2,system.RoundingMode.DOWN);
        /** Return statement */
        return projectToUpdate;
    }

    /*********************************************
	* Method Name : updateSubSequentAmendmentAwardAndProjectUponAmendmentTypeUpdate
	* Called From Method : processAfterUpdate
	* Author : Ricky
	* Inputs : -
	* Description: This method is used to auto update Subsequent Amendments, Subsequent Awards and Project record,
	*               when Amendment Type is updated on an Amendment record..
	*********************************************/
    private void updateSubSequentAmendmentAwardAndProjectUponAmendmentTypeUpdate() {
        Set<Id> projectIds = new Set<Id>(); /** To collect the Project of Amendment Request whose Amendment Type is updated */
        for(Amendment_Request__c amendment : (List<Amendment_Request__c>)Trigger.new) {
            Amendment_Request__c oldRecord = (Amendment_Request__c) Trigger.oldMap.get(amendment.Id);
            /** Condition 1 - To make sure that the Project field is not Null
             * Condition 2 -  TO check if the Amendment Type is updated */
            if(amendment.Project__c != null
                    && amendment.AmendmentType__c != oldRecord.AmendmentType__c) {
                projectIds.add(amendment.Project__c); /** Adding Project ID to Set collection */
            }
        }
        /** Condition to check for Null Pointer Exception of Project Id collection */
        if(projectIds.size() > 0) {
            /** To collect the Amendment to be updated after an Amendment Type is updated */
            List<Amendment_Request__c> amendmentToUpdateList = new List<Amendment_Request__c>();
            List<Project__c> projectToUpdateList = new List<Project__c>(); /** To collect the Project record to be updated */
            List<Award__c> awardToUpdateList = new List<Award__c>(); /** To collect the Award to be updated after an Amendment is updated */

            /** Fetching the Project record and its associated Awards and Amendments */
            Map<Id, Project__c> idToProjectWithAmendmentMap = new Map<Id, Project__c>([SELECT Id, Name, Start_Date__c, End_Date__c, FEMA_Share__c,
                                        State_Share__c, Total_Project_Award__c, State_Project_Award__c, Federal_Project_Award__c,
                                        (SELECT Id, Name, FEMA_Share__c, State_Share__c, Supplement_Award__c, AmountObligated__c, Project__r.FundingSource__c,
                                                Federal_Project_Amount__c, State_Project_Amount__c, State_Admin_Amount__c,
                                                Federal_Retention_Share__c, State_Retention_Share__c, State_Admin__c, Previous_Amount_Obligated__c,
                                                AwardStartDate__c, AwardEndDate__c, Amendment_Request__c, Amendment_Request__r.AmendmentType__c,
                                                Amendment_Request__r.FEMA_Share__c, Amendment_Request__r.State_Share__c, Project__r.StateAdmin__c,
                                                Amendment_Request__r.SupplementAward__c, Amendment_Request__r.NewObligatedAmount__c,
                                                Amendment_Request__r.TimeExtensionStartDate__c, Amendment_Request__r.TimeExtensionEndDate__c,
                                                Amendment_Request__r.FDSR__c
                                                FROM Awards__r ORDER BY Amendment_Request__r.FDSR__c ASC)
                                        FROM Project__c WHERE Id IN :projectIds]);

            /** Iterating the Projects whose Amendments Type is updated */
            for (Project__c project : idToProjectWithAmendmentMap.values()) {
                /** Checking the global list of Project in order to avoid recursion. */
                if (!projectToUpdateGlobalList.contains(project)) {
                    projectToUpdateGlobalList.add(project);
                    List<Award__c> awardOfProjectList = project?.Awards__r;
                    /** Method calling to update the Sub Sequent Amendment Amount */
                    List<Amendment_Request__c> amendmentRequestToUpdateList =
                            updateOtherAmendmentAmountOnAmendmentDeleteOrAmendmentTypeUpdate(awardOfProjectList);
                    /** Method calling to update the Sub Sequent Award record */
                    List<Award__c> awardsToUpdate = updateAwardRecordOnAmendmentDeleteOrAmendmentTypeUpdateNewUpdated(awardOfProjectList);
                    if (amendmentRequestToUpdateList?.size() > 0) {
                        amendmentToUpdateList.addAll(amendmentRequestToUpdateList);
                    }
                    if (awardsToUpdate?.size() > 0) {
                        awardToUpdateList.addAll(awardsToUpdate);
                    }
                }
                /** Method calling to update the Project record with updated value. */
                project = updateProjectRecord(project, project?.Awards__r[project?.Awards__r?.size() - 1]);
                projectToUpdateList.add(project);
            }
            /** Checking for null pointer exception of "awardToUpdateList" before updating the Awards */
            if(awardToUpdateList.size() > 0) {
                update awardToUpdateList;
            }
            /** Checking for null pointer exception of "amendmentToUpdateList" before updating the Amendments */
            if (amendmentToUpdateList.size() > 0) {
                update amendmentToUpdateList;
            }
            /** Checking for null pointer exception of "projectToUpdateList" before updating the Projects */
            if (projectToUpdateList.size() > 0) {
                update projectToUpdateList;
            }
        }
    }

    /*********************************************
	* Method Name : updateAmendmentAwardAndProjectUponAmendmentDelete
	* Called From Method : processBeforeDelete
	* Author : Ricky
	* Inputs : -
	* Description: This method is used to auto update Subsequent Amendments, Subsequent Awards and Project,
	 *             and delete the related Award record fo the Amendment record before the Amendment gets deleted.
	*********************************************/
    private void updateAmendmentAwardAndProjectUponAmendmentDelete() {
        Set<Id> projectIds = new Set<Id>(); /** To collect the Project of Amendment Request(to be Deleted) */
        /** To Collect the Amendment Request to be Deleted */
        Map<Id, Amendment_Request__c> idToAmendmentToDeleteMap = new Map<Id, Amendment_Request__c>();
        for(Amendment_Request__c amendment : (List<Amendment_Request__c>)Trigger.old) {
            if(amendment.Project__c != null) { /** Condition to make sure that the Project field is not Null */
                projectIds.add(amendment.Project__c); /** Adding Project ID to Set collection */
                idToAmendmentToDeleteMap.put(amendment.Id, amendment); /** Adding Amendment Record to Msp Collection */
            }
        }
        /** Condition to check for Null Pointer Exception of Project Id collection */
        if(projectIds.size() > 0) {
            /** To collect the Amendment to be updated after an Amendment is deleted */
            List<Amendment_Request__c> amendmentToUpdateList = new List<Amendment_Request__c>();
            List<Project__c> projectToUpdateList = new List<Project__c>(); /** To collect the Project record to be updated */
            List<Award__c> awardToUpdateList = new List<Award__c>(); /** To collect the Award to be updated after an Amendment is deleted */
            List<Payment_Request__c> prToUpdateList = new List<Payment_Request__c>(); /** To collect the Payment Request to be updated */
            List<Award__c> awardToDeleteList = new List<Award__c>(); /** To collect the Award which are associated to the Amendment to be deleted */
            /** To put a Project Id and its related PR to be updated in a Map */
            Map<Id, List<Payment_Request__c>> projectIdToPrListMap = new Map<Id, List<Payment_Request__c>>();
            List<Id> prListToUnlock = new List<Id>(); /** To collect the PR Id which are to locked in order to unlock it before updating */

            /** Fetching the associated Award of the Amendment to be deleted and its associated PR in order to update the Award field */
            Map<Id, Award__c> idToAwardWithPrMap = new Map<Id, Award__c>([SELECT Id, Name, Project__c, Amendment_Request__c,
                                                        (SELECT Id, Award__c FROM Payment_Requests__r)
                                                        FROM Award__c WHERE Amendment_Request__c IN : idToAmendmentToDeleteMap.keySet()]);
            /** Iterating "idToAwardWithPrMap" values, to put a Project Id and its related PR to be updated in a Map */
            for(Award__c award : idToAwardWithPrMap.values()) {
                if(idToAmendmentToDeleteMap.containsKey(award.Amendment_Request__c)) {
                    awardToDeleteList.add(award);
                    if(!projectIdToPrListMap.containsKey(award.Project__c)) {
                        List<Payment_Request__c> prList = new List<Payment_Request__c>();
                        prList.addAll(award.Payment_Requests__r);
                        projectIdToPrListMap.put(award.Project__c, prList);
                    }
                    else {
                        List<Payment_Request__c> prList = projectIdToPrListMap.get(award.Project__c);
                        prList.addAll(award.Payment_Requests__r);
                        projectIdToPrListMap.put(award.Project__c, prList);
                    }
                }
            }

            /** Fetching the Project record and its associated Awards and Amendments except the one to be deleted */
            Map<Id, Project__c> idToProjectWithAmendmentMap = new Map<Id, Project__c>([SELECT Id, Name, Start_Date__c, End_Date__c, FEMA_Share__c,
                                        State_Share__c, Total_Project_Award__c, State_Project_Award__c, Federal_Project_Award__c,
                                        (SELECT Id, Name, FEMA_Share__c, State_Share__c, Supplement_Award__c, AmountObligated__c, AwardStartDate__c,
                                                AwardEndDate__c, Federal_Project_Amount__c, State_Project_Amount__c, State_Admin_Amount__c,
                                                Project__r.FundingSource__c, State_Admin__c, Federal_Retention_Share__c, State_Retention_Share__c,
                                                Amendment_Request__c, Amendment_Request__r.Name, Amendment_Request__r.AmendmentType__c,
                                                Amendment_Request__r.FEMA_Share__c, Amendment_Request__r.State_Share__c,
                                                Amendment_Request__r.SupplementAward__c, Amendment_Request__r.NewObligatedAmount__c,
                                                Amendment_Request__r.TimeExtensionStartDate__c, Amendment_Request__r.TimeExtensionEndDate__c,
                                                Amendment_Request__r.FDSR__c FROM Awards__r
                                                WHERE Amendment_Request__c NOT IN : idToAmendmentToDeleteMap.keySet()
                                                ORDER BY Amendment_Request__r.FDSR__c ASC)
                                        FROM Project__c WHERE Id IN : projectIds]);

            /** Iterating the Projects whose Amendments is to be deleted */
            for (Project__c project : idToProjectWithAmendmentMap.values()) {
                /** Checking the global list of Project in order to avoid recursion. */
                if (!projectToUpdateGlobalList.contains(project)) {
                    projectToUpdateGlobalList.add(project);
                    List<Award__c> awardOfProjectList = project?.Awards__r;
                    /** Method calling to update the Sub Sequent Amendment Amount */
                    List<Amendment_Request__c> amendmentRequestToUpdateList =
                            updateOtherAmendmentAmountOnAmendmentDeleteOrAmendmentTypeUpdate(awardOfProjectList);
                    /*List<Amendment_Request__c> amendmentRequestToUpdateList =
                            updateOtherAmendmentAmountOnAmendmentDeleteOrAmendmentTypeUpdateNew(awardOfProjectList);*/
                    /** Method calling to update the Sub Sequent Award record */
                    //List<Award__c> awardsToUpdate = updateAwardRecordOnAmendmentDeleteOrAmendmentTypeUpdate(awardOfProjectList);
                    //List<Award__c> awardsToUpdate = updateAwardRecordOnAmendmentDeleteOrAmendmentTypeUpdateNew(awardOfProjectList);
                    List<Award__c> awardsToUpdate = updateAwardRecordOnAmendmentDeleteOrAmendmentTypeUpdateNewUpdated(awardOfProjectList);
                    if(amendmentRequestToUpdateList?.size() > 0) {
                        amendmentToUpdateList.addAll(amendmentRequestToUpdateList);
                    }
                    if(awardsToUpdate?.size() > 0) {
                        awardToUpdateList.addAll(awardsToUpdate);
                    }
                }
                /** Method calling to update the project record with updated value by passing the latest Award record. */
                project = updateProjectRecord(project, project?.Awards__r[project?.Awards__r?.size()-1]);
                projectToUpdateList.add(project);

                /** Fetching the PR and Updating Award field of PR */
                if(projectIdToPrListMap?.get(project.Id)?.size() > 0) {
                    for(Payment_Request__c pRequest : projectIdToPrListMap?.get(project.Id)) {
                        if(pRequest.Award__c != project?.Awards__r[project?.Awards__r?.size()-1].Id) {
                            /** Adding the PR id to collection in order to unlock it before updating it and then lock it back */
                            if(Approval.isLocked(pRequest.Id)) {
                                prListToUnlock.add(pRequest.Id);
                            }
                            pRequest.Award__c = project?.Awards__r[project?.Awards__r?.size()-1].Id; /** Updating the Award field of PR */
                            prToUpdateList.add(pRequest); /** Adding PR to collection in order to update */
                        }
                    }
                }
            }
            /** Checking for null pointer exception of "awardToUpdateList" before updating the Awards */
            if(awardToUpdateList.size() > 0) {
                update awardToUpdateList;
            }
            /** Checking for null pointer exception of "amendmentToUpdateList" before updating the Amendments */
            if (amendmentToUpdateList.size() > 0) {
                update amendmentToUpdateList;
            }
            /** Checking for null pointer exception of "prToUpdateList" and "prListToUnlock"  in order to unlock the locked Prs before updating */
            if (prToUpdateList.size() > 0 && prListToUnlock.size() > 0) {
                RecordLockUnlockClass recordLockUnlock = new RecordLockUnlockClass();
                recordLockUnlock.unlockRecord(prListToUnlock);
                update prToUpdateList;
                recordLockUnlock.lockRecord(prListToUnlock);
            }
            /** Checking for null pointer exception of "prToUpdateList" before updating the PR when there is no any Locked PR */
            else if (prToUpdateList.size() > 0) {
                update prToUpdateList;
            }
            /** Checking for null pointer exception of "projectToUpdateList" before updating the Projects */
            if (projectToUpdateList.size() > 0) {
                update projectToUpdateList;
            }
            /** Checking for null pointer exception of "awardToDeleteList" before updating the Awards */
            if(awardToDeleteList.size() > 0) {
                delete awardToDeleteList;
            }
        }
    }

    /*********************************************
	* Method Name : updateOtherAmendmentAmountOnAmendmentDeleteOrAmendmentTypeUpdate
	* Called From Method : updateAmendmentAwardAndProjectUponAmendmentDelete
	* Author : Ricky
	* Inputs : - 1. List<Award__c> awardToUpdateList - List of Award it consists their related Amendment details.
	*                                                   Award record has sequence of Ascending FDSR of the related Amendment Request.
	* Description: This method is used to auto update Subsequent Amendments Amount before the Amendment gets deleted.
	*********************************************/
    private static List<Amendment_Request__c> updateOtherAmendmentAmountOnAmendmentDeleteOrAmendmentTypeUpdate(List<Award__c> awardToUpdateList) {
        List<Amendment_Request__c> amendmentRequestToUpdateList = new List<Amendment_Request__c>();
        Decimal updatedObligatedAmount;
        /** Condition to check if the Project only one Award except the one which is associated to the Amendment to be deleted */
        if (awardToUpdateList?.size() == 1) {
            /** Taking the first element of the related Award from Project as it has only one Award */
            Award__c award = awardToUpdateList[0];
            /** Updating the Award status to Active */
            award.Status__c = ALS_CONSTANTS.Award_Status_Active;
        }
        /** Condition to check if the Project more than one Award except the one which is associated to the Amendment to be deleted */
        else if(awardToUpdateList?.size() > 1) {
            for (Award__c awardToUpdate : awardToUpdateList) {
                /** Condition to check if the current Award is the Initial Award of the Project **/
                if(awardToUpdate.Id == awardToUpdateList[0].Id) {
                    /** Storing the Award record values into a temporary variable order to update the next Amendments and Awards */
                    updatedObligatedAmount = awardToUpdate.AmountObligated__c;
                }
                /** Condition to verify that the Amendment field is not null on the Award and Amendment is of type,
                 *  which can impact Amount of sub Sequent Amendment/Award or Project record. */
                if(awardToUpdate.Amendment_Request__c != null
                        && (awardToUpdate.Amendment_Request__r.AmendmentType__c  == ALS_CONSTANTS.Amendment_Type_MoneyExtension
                            || awardToUpdate.Amendment_Request__r.AmendmentType__c  == ALS_CONSTANTS.Amendment_Type_MoneyExtensionAndTimeExtension
                            || awardToUpdate.Amendment_Request__r.AmendmentType__c  == ALS_CONSTANTS.Amendment_Type_MoneyExtensionAndCostShareChange)) {
                    /** Updating the Award record as per the updated value of Amendment */
                    awardToUpdate.Amendment_Request__r.NewObligatedAmount__c = updatedObligatedAmount + awardToUpdate.Amendment_Request__r.SupplementAward__c;
                    updatedObligatedAmount = awardToUpdate.Amendment_Request__r.NewObligatedAmount__c;
                    amendmentRequestToUpdateList.add(awardToUpdate.Amendment_Request__r);
                }
                 /** For other Amendments updating the Amount value to 0. */
                else if(awardToUpdate.Amendment_Request__c != null) {
                    awardToUpdate.Amendment_Request__r.SupplementAward__c = 0;
                    awardToUpdate.Amendment_Request__r.NewObligatedAmount__c = 0;
                    amendmentRequestToUpdateList.add(awardToUpdate.Amendment_Request__r);
                }
            }
        }
        /** Return statement */
        return amendmentRequestToUpdateList;
    }

    private static List<Award__c> updateAwardRecordOnAmendmentDeleteOrAmendmentTypeUpdateNewUpdated (List<Award__c> awardToUpdateList) {
        /** Temporary variable to store the updated value of Award record */
        Award__c awardUpdatedValueTempVar = new Award__c();
        /** Condition to check if the Project only one Award except the one which is associated to the Amendment to be deleted */
        if (awardToUpdateList?.size() == 1) {
            /** Taking the first element of the related Award from Project as it has only one Award */
            Award__c award = awardToUpdateList[0];
            /** Updating the Award status to Active */
            award.Status__c = ALS_CONSTANTS.Award_Status_Active;
            awardUpdatedValueTempVar = award;
        }
        else if(awardToUpdateList?.size() > 1) {
            for (Award__c awardToUpdate : awardToUpdateList) {
                /** Condition to check if the current Award is the Initial Award of the Project */
                if(awardToUpdate.Id == awardToUpdateList[0].Id
                        && awardToUpdate.Amendment_Request__c == null) {
                    /** Storing the Award record values into a temporary variable order to update the next Amendments and Awards */
                    awardUpdatedValueTempVar = awardToUpdate;
                }
                /** Condition to check the Amendment Request field is not null on Award record */
                else if(awardToUpdate.Amendment_Request__c != null) {
                    /** 1. Condition to check if the Amendment includes Supplement Award Changes.
                     * - As these are the Amendment Type where Supplement Award is going to be copied from Amendment.
                     * 2. Or else to Supplement Award is 0 and New Obligated Amount to be copied from previous Award record.*/
                    if(awardToUpdate.Amendment_Request__r.AmendmentType__c  == ALS_CONSTANTS.Amendment_Type_MoneyExtension
                            || awardToUpdate.Amendment_Request__r.AmendmentType__c  == ALS_CONSTANTS.Amendment_Type_MoneyExtensionAndTimeExtension
                            || awardToUpdate.Amendment_Request__r.AmendmentType__c  == ALS_CONSTANTS.Amendment_Type_MoneyExtensionAndCostShareChange) {

                            awardToUpdate.Supplement_Award__c = awardToUpdate.Amendment_Request__r.SupplementAward__c;
                            awardToUpdate.AmountObligated__c = awardToUpdate.Amendment_Request__r.NewObligatedAmount__c;

                        /** Copying the updated New Obligated Amount value in a temporary variable,
                         * in order to process the Sub Sequent Award records. */
                            awardUpdatedValueTempVar.AmountObligated__c = awardToUpdate.Amendment_Request__r.NewObligatedAmount__c == null ? 0.00 : awardToUpdate.Amendment_Request__r.NewObligatedAmount__c;
                        }
                    else {
                        awardToUpdate.Supplement_Award__c = 0;
                        awardToUpdate.AmountObligated__c = awardUpdatedValueTempVar.AmountObligated__c;
                    }

                    /** 1. Condition to check if the Amendment includes Time Changes - In order to copy the Time values from Amendment.
                     * 2. Or else to copy from previous Award record. */
                    if(awardToUpdate.Amendment_Request__r.AmendmentType__c  == ALS_CONSTANTS.Amendment_Type_TimeExtension
                            || awardToUpdate.Amendment_Request__r.AmendmentType__c  == ALS_CONSTANTS.Amendment_Type_MoneyExtensionAndTimeExtension) {
                        awardToUpdate.AwardStartDate__c = awardToUpdate.Amendment_Request__r.TimeExtensionStartDate__c;
                        awardToUpdate.AwardEndDate__c = awardToUpdate.Amendment_Request__r.TimeExtensionEndDate__c;

                        /** Copying the updated Time value in a temporary variable in order to process the Sub Sequent Award records. */
                        awardUpdatedValueTempVar.AwardStartDate__c = awardToUpdate.Amendment_Request__r.TimeExtensionStartDate__c;
                        awardUpdatedValueTempVar.AwardEndDate__c = awardToUpdate.Amendment_Request__r.TimeExtensionEndDate__c;
                    }
                    else {
                        awardToUpdate.AwardStartDate__c = awardUpdatedValueTempVar.AwardStartDate__c;
                        awardToUpdate.AwardEndDate__c = awardUpdatedValueTempVar.AwardEndDate__c;
                    }
                    /** 1. Condition to check if the Amendment includes Cost Shares Changes - In order to copy the Cost Share% from Amendment.
                     * 2. Or else to copy from previous Award record. */
                    if(awardToUpdate.Amendment_Request__r.AmendmentType__c  == ALS_CONSTANTS.Amendment_Type_PercentageChange
                            || awardToUpdate.Amendment_Request__r.AmendmentType__c  == ALS_CONSTANTS.Amendment_Type_MoneyExtensionAndCostShareChange) {
                        awardToUpdate.FEMA_Share__c = awardToUpdate.Amendment_Request__r.FEMA_Share__c;
                        awardToUpdate.State_Share__c = awardToUpdate.Amendment_Request__r.State_Share__c;

                        /** Copying the updated Cost Share value in a temporary variable in order to process the Sub Sequent Award records. */
                        awardUpdatedValueTempVar.FEMA_Share__c = awardToUpdate.Amendment_Request__r.FEMA_Share__c == null ? 0.00 : awardToUpdate.Amendment_Request__r.FEMA_Share__c;
                        awardUpdatedValueTempVar.State_Share__c = awardToUpdate.Amendment_Request__r.State_Share__c == null ? 0.00 : awardToUpdate.Amendment_Request__r.State_Share__c;
                    }
                    else {
                        awardToUpdate.FEMA_Share__c = awardUpdatedValueTempVar.FEMA_Share__c;
                        awardToUpdate.State_Share__c = awardUpdatedValueTempVar.State_Share__c;
                    }
                }
                /** Condition to check the If the Amendment includes the Money changes or Cost Share changes
                 * - These Amendment Type includes the changes in the Federal, State and Admin Shares.
                 * - These fields are used for Docu gen Templates. */
                if (awardToUpdate.Amendment_Request__r.AmendmentType__c  == ALS_CONSTANTS.Amendment_Type_MoneyExtension
                        || awardToUpdate.Amendment_Request__r.AmendmentType__c  == ALS_CONSTANTS.Amendment_Type_MoneyExtensionAndTimeExtension
                        || awardToUpdate.Amendment_Request__r.AmendmentType__c  == ALS_CONSTANTS.Amendment_Type_MoneyExtensionAndCostShareChange
                        || awardToUpdate.Amendment_Request__r.AmendmentType__c  == ALS_CONSTANTS.Amendment_Type_PercentageChange) {

                    awardToUpdate.Federal_Project_Amount__c = ((awardUpdatedValueTempVar.AmountObligated__c
                            * awardUpdatedValueTempVar.FEMA_Share__c)/100)?.setScale(2,system.RoundingMode.DOWN);
                    awardToUpdate.Federal_Supplement_Amount__c = (awardToUpdate.Federal_Project_Amount__c
                            - awardUpdatedValueTempVar.Federal_Project_Amount__c)?.setScale(2,system.RoundingMode.DOWN);
                    awardToUpdate.State_Project_Amount__c = ((awardUpdatedValueTempVar.AmountObligated__c
                            * awardUpdatedValueTempVar.State_Share__c)/100)?.setScale(2,system.RoundingMode.DOWN);
                    awardToUpdate.State_Supplement_Amount__c = (awardToUpdate.State_Project_Amount__c
                            - awardUpdatedValueTempVar.State_Project_Amount__c)?.setScale(2,system.RoundingMode.DOWN);
                    awardToUpdate.State_Admin_Amount__c = ((awardToUpdate.State_Project_Amount__c
                            * awardToUpdate.State_Admin__c)/100)?.setScale(2,system.RoundingMode.DOWN);
                    awardToUpdate.State_Admin_Supplement_Amount__c = (awardToUpdate.State_Admin_Amount__c
                            - awardUpdatedValueTempVar.State_Admin_Amount__c)?.setScale(2,system.RoundingMode.DOWN);

                    awardToUpdate.Total_Obligated_Amount__c = (awardToUpdate.Federal_Project_Amount__c + awardToUpdate.State_Project_Amount__c
                            + awardToUpdate.State_Admin_Amount__c)?.setScale(2,system.RoundingMode.DOWN);
                    awardToUpdate.Total_Obligated_Supplement_Amount__c = (awardToUpdate.Federal_Supplement_Amount__c
                            + awardToUpdate.State_Supplement_Amount__c + awardToUpdate.State_Admin_Supplement_Amount__c)?.setScale(2,system.RoundingMode.DOWN);

                    awardToUpdate.Federal_Retention__c = ((awardToUpdate.Federal_Supplement_Amount__c
                            * awardToUpdate.Federal_Retention_Share__c)/100)?.setScale(2,system.RoundingMode.DOWN);
                    awardToUpdate.State_Retention__c = ((awardToUpdate.State_Supplement_Amount__c
                            * awardToUpdate.State_Retention_Share__c)/100)?.setScale(2,system.RoundingMode.DOWN);
                    awardToUpdate.Federal_Amount_Available__c = (awardToUpdate.Federal_Supplement_Amount__c
                            - awardToUpdate.Federal_Retention__c)?.setScale(2,system.RoundingMode.DOWN);
                    awardToUpdate.State_Amount_Available__c = (awardToUpdate.State_Supplement_Amount__c
                            - awardToUpdate.State_Retention__c)?.setScale(2,system.RoundingMode.DOWN);

                    awardToUpdate.Sum_of_State_and_Federal__c = (awardToUpdate.Federal_Supplement_Amount__c
                            + awardToUpdate.State_Supplement_Amount__c)?.setScale(2,system.RoundingMode.DOWN);
                    awardToUpdate.Sum_of_State_and_Admin_Supplement__c = (awardToUpdate.State_Supplement_Amount__c
                            + awardToUpdate.State_Admin_Supplement_Amount__c)?.setScale(2,system.RoundingMode.DOWN);

                    awardToUpdate.Sum_of_State_and_Federal_to_Date__c = (awardToUpdate.Federal_Project_Amount__c
                            + awardToUpdate.State_Project_Amount__c)?.setScale(2,system.RoundingMode.DOWN);
                    awardToUpdate.Sum_of_State_and_Admin_to_Date__c = (awardToUpdate.State_Project_Amount__c
                            + awardToUpdate.State_Admin_Amount__c)?.setScale(2,system.RoundingMode.DOWN);

                    /** Copying the updated Amount value in a temporary variable in order to compare in the Sub Sequent Award records. */
                    awardUpdatedValueTempVar.Federal_Project_Amount__c = awardToUpdate.Federal_Project_Amount__c;
                    awardUpdatedValueTempVar.State_Project_Amount__c = awardToUpdate.State_Project_Amount__c;
                    awardUpdatedValueTempVar.State_Admin_Amount__c = awardToUpdate.State_Admin_Amount__c;
                }
                /** If the Award is not Initial Award and does not includes Money/Cost Share changes,
                 * then update the Award amount from previous Award record. */
                else {
                    awardToUpdate.Federal_Project_Amount__c = awardUpdatedValueTempVar.Federal_Project_Amount__c?.setScale(2,system.RoundingMode.DOWN);
                    awardToUpdate.Federal_Supplement_Amount__c = 0;
                    awardToUpdate.State_Project_Amount__c = awardUpdatedValueTempVar.State_Project_Amount__c?.setScale(2,system.RoundingMode.DOWN);
                    awardToUpdate.State_Supplement_Amount__c = 0;
                    awardToUpdate.State_Admin_Supplement_Amount__c = awardUpdatedValueTempVar.State_Admin_Amount__c?.setScale(2,system.RoundingMode.DOWN);
                    awardToUpdate.State_Admin_Supplement_Amount__c = 0;

                    awardToUpdate.Total_Obligated_Amount__c = (awardToUpdate.Federal_Project_Amount__c
                            + awardToUpdate.State_Project_Amount__c + awardToUpdate.State_Admin_Amount__c)?.setScale(2,system.RoundingMode.DOWN);
                    awardToUpdate.Total_Obligated_Supplement_Amount__c = 0;

                    awardToUpdate.Sum_of_State_and_Federal_to_Date__c = (awardToUpdate.Federal_Project_Amount__c
                            + awardToUpdate.State_Project_Amount__c)?.setScale(2,system.RoundingMode.DOWN);
                    awardToUpdate.Sum_of_State_and_Admin_to_Date__c = (awardToUpdate.State_Project_Amount__c
                            + awardToUpdate.State_Admin_Amount__c)?.setScale(2,system.RoundingMode.DOWN);

                    awardToUpdate.Federal_Retention__c = 0;
                    awardToUpdate.State_Retention__c = 0;

                    awardToUpdate.Federal_Amount_Available__c = 0;
                    awardToUpdate.State_Amount_Available__c = 0;

                    awardToUpdate.Sum_of_State_and_Federal__c = 0;
                    awardToUpdate.Sum_of_State_and_Admin_Supplement__c = 0;
                }

                /** Updating the Previous Obligated Amount fields. */
                awardToUpdate.Previous_Amount_Obligated__c = (awardToUpdate.AmountObligated__c
                        - awardToUpdate.Supplement_Award__c)?.setScale(2,system.RoundingMode.DOWN);
                awardToUpdate.Previous_Federal_Amount_Obligated__c = (awardToUpdate.Federal_Project_Amount__c
                        - awardToUpdate.Federal_Supplement_Amount__c)?.setScale(2,system.RoundingMode.DOWN);
                awardToUpdate.Previous_State_Amount_Obligated__c = (awardToUpdate.State_Project_Amount__c
                        - awardToUpdate.State_Supplement_Amount__c)?.setScale(2,system.RoundingMode.DOWN);
                awardToUpdate.Previous_State_Admin_Amount_Obligated__c = (awardToUpdate.State_Admin_Amount__c
                        - awardToUpdate.State_Admin_Supplement_Amount__c)?.setScale(2,system.RoundingMode.DOWN);

                /** Condition check if the current Award record is the last Award in the List in order to activate the Status of theAward */
                if(awardToUpdate.Id == awardToUpdateList[awardToUpdateList.size()-1].Id) {
                    awardToUpdate.Status__c = ALS_CONSTANTS.Award_Status_Active;
                }
            }
            /** Removing the first element from the list in order to avoid updation of the initial Award of Project */
            awardToUpdateList.remove(0);
        }
        /** Return statement */
        return awardToUpdateList;
    }
	
    /** Ticket No - 525 - End */
    /*********************************************
	* Method Name : updateProgramPrefixOnProjectVersionOfAmendment
	* Called From Method : Before Insert, Before Update
	* Author : Ricky
	* Inputs : -
	* Description: This method is used To update the Manager user Details, who had Reviewed the Amendment Request.
	*********************************************/
    private void updateManagerDetailsOnAmendmentRecord() {
        /** Collection to store the Amendment record which needs to be processed. */
        List<Amendment_Request__c> amendmentToProcessList = new List<Amendment_Request__c>();
        /** To include all the Record while inserting the record. */
        if (Trigger.isInsert) {
            amendmentToProcessList = Trigger.new;
        }
        /** To include only those Record on which Reviewed by Manager field has been changed.. */
        if (Trigger.isUpdate) {
            for (Amendment_Request__c amendmentToProcess : (List<Amendment_Request__c>) Trigger.new) {
                Amendment_Request__c oldRecord = (Amendment_Request__c) Trigger.oldMap.get(amendmentToProcess.Id);
                if (oldRecord.Reviewed_By_Manager__c != amendmentToProcess.Reviewed_By_Manager__c) {
                    amendmentToProcessList.add(amendmentToProcess);
                }
            }
        }
        if (amendmentToProcessList?.size() > 0) {
            for (Amendment_Request__c amendmentToProcess : amendmentToProcessList) {
                /** 1. If the Reviewed By Manger Picklist field value is Yes
                 * - Then copy Current User in Manager User field and Current Date in Manager Approved Date field.
                 * 2. Or else If the Reviewed By Manger Picklist field value is No
                 * - Then Set the Manager User and Manager Approved Date field to null. */
                if (amendmentToProcess.Reviewed_By_Manager__c == ALS_CONSTANTS.Picklist_Yes) {
                    amendmentToProcess.Manager_User__c = UserInfo.getUserId();
                    amendmentToProcess.Manager_Approved_Date__c = Date.today();
                }
                else if (amendmentToProcess.Reviewed_By_Manager__c == ALS_CONSTANTS.Picklist_No) {
                    amendmentToProcess.Manager_User__c = null;
                    amendmentToProcess.Manager_Approved_Date__c = null;
                }
            }
        }
    }

    /*********************************************
	* Method Name : updateProgramPrefixOnProjectVersionOfAmendment
	* Called From Method : Before Insert, Before Update
	* Author : Ricky
	* Inputs : -
	* Description: This method is used To update Latest Amendment FDSR/Project Version and Supplement Number on Project.
	*********************************************/
    private void updateLatestAmendmentVersionOnProject() {
        Set<Id> projectIds = new Set<Id>(); /* Set collection to collect the Project Id of the Amendment which needs to be processed. */
        /* Collection to collect the Amendment records which needs to be processed. */
        Map<Id, Amendment_Request__c> amendmentToBeDeletedMap = new Map<Id, Amendment_Request__c>();
        /** While inserting the record -
         * 1. Project field is not empty on Amendment.
           2. FDSR or Supplement Number field is not null on the Amendment. */
        if (Trigger.isInsert) {
            for (Amendment_Request__c amendmentToProcess : (List<Amendment_Request__c>) Trigger.new) {
                if (amendmentToProcess.Project__c != null
                        && (amendmentToProcess.FDSR__c != null
                            || amendmentToProcess.SupplementNumber__c != null)) {
                    projectIds.add(amendmentToProcess.Project__c);
                }
            }
        }
        /* While updating the record - Either FDSR or Supplement Number has been changed on Amendment. */
        if (Trigger.isUpdate) {
            for (Amendment_Request__c amendmentToProcess : (List<Amendment_Request__c>) Trigger.new) {
                Amendment_Request__c oldRecord = (Amendment_Request__c) Trigger.oldMap.get(amendmentToProcess.Id);
                if ((oldRecord.FDSR__c != amendmentToProcess.FDSR__c
                            || oldRecord.SupplementNumber__c != amendmentToProcess.SupplementNumber__c)
                        && amendmentToProcess.Project__c != null
                        && (amendmentToProcess.FDSR__c != null || amendmentToProcess.SupplementNumber__c != null)) {
                    projectIds.add(amendmentToProcess.Project__c);
                }
            }
        }
        /* While Deleting the record - Either FDSR or Supplement Number is not null on the Amendment. */
        if (Trigger.isDelete) {
            for (Amendment_Request__c amendmentToProcess : (List<Amendment_Request__c>) Trigger.old) {
                if (amendmentToProcess.Project__c != null
                        && (amendmentToProcess.FDSR__c != null
                            || amendmentToProcess.SupplementNumber__c != null)) {
                    projectIds.add(amendmentToProcess.Project__c);
                    amendmentToBeDeletedMap.put(amendmentToProcess.Id, amendmentToProcess);
                }
            }
        }

        if(projectIds?.size() > 0) {
            List<Project__c> projectWithLatestAmendmentList = new List<Project__c>();
            /** Querying the Project with its latest Amendment record.
              The reason to query it in If-Else block is to avoid the Amendment record which is getting deleted in case of Delete. */
            if (amendmentToBeDeletedMap?.size() > 0) {
                projectWithLatestAmendmentList = [SELECT Id, Name, Project_Number__c, Supplement_Number__c , Latest_Project_Version__c,
                                                                    Latest_Supplement_Number__c,
                                                                    (SELECT Id, FDSR__c, SupplementNumber__c FROM Amendment_Requests__r
                                                                        WHERE Id NOT IN : amendmentToBeDeletedMap.keySet()
                                                                        ORDER BY FDSR__c DESC LIMIT 1)
                                                                    FROM Project__c WHERE Id IN :projectIds];
            }
            else {
                projectWithLatestAmendmentList = [SELECT Id, Name, Project_Number__c, Supplement_Number__c , Latest_Project_Version__c,
                                                                    Latest_Supplement_Number__c,
                                                                    (SELECT Id, FDSR__c, SupplementNumber__c FROM Amendment_Requests__r
                                                                        ORDER BY FDSR__c DESC LIMIT 1)
                                                                    FROM Project__c WHERE Id IN :projectIds];
            }
            List<Project__c> projectToUpdateList = new List<Project__c>();
            for(Project__c project : projectWithLatestAmendmentList) {
                /** Condition to check If there is no any Amendment available on the Project
                 * - In order to copy the Project Number and Supplement Number into Latest Project version and Latest Supplement Number field respectively.*/
                if (project?.Amendment_Requests__r?.size() == 0) {
                    if(project.Project_Number__c != null) {
                        project.Latest_Project_Version__c = project.Project_Number__c;
                    }
                    else {
                        project.Latest_Project_Version__c = null;
                    }
                    if(project.Supplement_Number__c != null) {
                        project.Latest_Supplement_Number__c = project.Supplement_Number__c;
                    }
                    else {
                        project.Latest_Supplement_Number__c = null;
                    }
                    projectToUpdateList.add(project);
                }
                /** Condition to check If there is an Amendment available on the Project
                 * - In order to copy the Project version and Supplement Number into Latest Project version and Latest Supplement Number field respectively.*/
                if (project?.Amendment_Requests__r?.size() == 1) {
                    Amendment_Request__c latestAmendment = project?.Amendment_Requests__r[0];
                    /** Condition 1 - To check of the Latest project version on Project is not equal to Latest Amendment FDSR.
                     * Condition 2 - To check FDSR is available on Latest Amendment record.
                       Or else update Latest Project version on Project to null. */
                    if (project.Latest_Project_Version__c != latestAmendment.FDSR__c
                            && latestAmendment.FDSR__c != null) {
                        project.Latest_Project_Version__c = latestAmendment.FDSR__c;
                    }
                    else if (latestAmendment.FDSR__c == null) {
                        project.Latest_Project_Version__c = null;
                    }
                    /** Condition 1 - To check of the Latest Supplement Number on Project is not equal to Latest Amendment Supplement Number.
                     * Condition 2 - To check Supplement Number is available on Latest Amendment record.
                       Or else update Latest Supplement Number on Project to null. */
                    if (project.Latest_Supplement_Number__c != latestAmendment.SupplementNumber__c
                            && latestAmendment.SupplementNumber__c != null) {
                        project.Latest_Supplement_Number__c = latestAmendment.SupplementNumber__c;
                    }
                    else if (latestAmendment.SupplementNumber__c == null) {
                        project.Latest_Supplement_Number__c = null;
                    }
                    projectToUpdateList.add(project); /* Adding Project record to collection for Updating. */
                }
            }
            if(projectToUpdateList?.size() > 0) {
                update projectToUpdateList;
            }
        }
    }

    /*********************************************
	* Method Name : updateProgramPrefixOnProjectVersionOfAmendment
	* Called From Method : Before Insert, Before Update
	* Author : Ricky
	* Inputs : -
	* Description: This method is used To update the Program Name Prefix on Amendment FDSR which in configured from Metadata.
	*********************************************/
    private void updateProgramPrefixOnProjectVersionOfAmendment() {
        Set<Id> projectIds = new Set<Id>();
        List<Amendment_Request__c> amendmentToProcessList = new List<Amendment_Request__c>();
        /** While Inserting the record -
         * 1. Project field is not null.
          * 2. FDSR of the Amendment is not null.*/
        if (Trigger.isInsert) {
            for (Amendment_Request__c amendmentToProcess : (List<Amendment_Request__c>) Trigger.new) {
                if (amendmentToProcess.Project__c != null
                        && amendmentToProcess.FDSR__c != null) {
                    projectIds.add(amendmentToProcess.Project__c);
                    amendmentToProcessList.add(amendmentToProcess);
                }
            }
        }
        /** While Updating the record -
         * 1. Project field is not null.
          * 2. FDSR of the Amendment is changed.
          * 3. FDSR of the Amendment record is not null.*/
        if (Trigger.isUpdate) {
            for (Amendment_Request__c amendmentToProcess : (List<Amendment_Request__c>) Trigger.new) {
                Amendment_Request__c oldRecord = (Amendment_Request__c)Trigger.oldMap.get(amendmentToProcess.Id);
                if (oldRecord.FDSR__c != amendmentToProcess.FDSR__c
                        && amendmentToProcess.Project__c != null
                        && amendmentToProcess.FDSR__c != null) {
                    projectIds.add(amendmentToProcess.Project__c);
                    amendmentToProcessList.add(amendmentToProcess);
                }
            }
        }

        if (projectIds?.size() > 0) {
            /** Fetching the Project record in order to fetch the Program name of the Project record. */
            Map<Id, Project__c> projectIdToProgramNameMap = new Map<Id, Project__c>([SELECT Id, Name, Program_Name__r.Master_Label_Program_Name__c
                                                            FROM Project__c WHERE Id IN : projectIds]);
            //Map<String, Program_Config__mdt>  programConfigMap = (Map<String, Program_Config__mdt>) Program_Config__mdt.getAll();
            /* Fetching the Program Prefix metadata. */
            List<Program_Config__mdt>  programConfigList = [SELECT Id, Label, Program_Prefix__c FROM Program_Config__mdt];
            Map<String, String> programNameToPrfixMap = new Map<String, String>();
            /* Arranging the Metadata record in Program name as key and Prefix as the value. */
            if (programConfigList?.size() > 0) {
                for (Program_Config__mdt programConfig : programConfigList) {
                    programNameToPrfixMap.put(programConfig.Label, programConfig.Program_Prefix__c);
                }
            }
            /* Updating the Program prefix values in FDSR of the Amendment record. */
            for (Amendment_Request__c amendmentToProcess : amendmentToProcessList) {
                Project__c projectOfAmendment = projectIdToProgramNameMap?.get(amendmentToProcess.Project__c);
                /** This condition is null check to make sure that the Program name prefix available in Metadata. */
                if (programNameToPrfixMap?.get(projectOfAmendment.Program_Name__r.Master_Label_Program_Name__c) != null
                        && !amendmentToProcess.FDSR__c.startsWith(programNameToPrfixMap?.get(projectOfAmendment.Program_Name__r.Master_Label_Program_Name__c))) {
                    amendmentToProcess.FDSR__c = programNameToPrfixMap?.get(projectOfAmendment.Program_Name__r.Master_Label_Program_Name__c)
                            + '-' + amendmentToProcess.FDSR__c;
                }
            }
        }
    }
}