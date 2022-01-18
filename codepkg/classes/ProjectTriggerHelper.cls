/**
* Created by nehab on 06-10-2020.
*/
public with sharing class ProjectTriggerHelper extends TriggerHelper{
    List<Project__c> projectToPutOnHoldGlobalList = new List<Project__c>();
    public override void processBeforeInsert()  {
        //Fetch the Funding opportunity details and populates the Project
        fetchProgramAndIncident();

        /** This method is used to update the Program name Prefix to project Number. (Prefix for the Program is configured from metadata) */
        updateProgramNamePrefixToProjectVersion();

        //This method is used to calculate the FEMA Share %, State Share %, Federal Project Award and State Project Award based on selection of "Reverse Calculation" Checkbox...
        calculateStateAndFederalCostShare();

        //To automatically update "Pay to State Admin" vale to "Yes", If "Eligible for State Admin Share" value is "Yes"....
        autoUpdatePayToStateAdmin();

        //To calculate Local Share% of the Project..
        calculateLocalSharePercentage();

        //To assign Project's State Retention and Federal Retention bassed on Program and Project Type(Small or Large)...
        projectRetention();

        /** This method is used to update the Total Federal Retention, Total State Retention, Federal Project Award W/o retention and
         * State Project Award W/o Retention field on Project record. and Project. */
        updateRetentionAndProjectAwardWithoutRetentionField();

        //To create the Incident Sub - Recipient Stage junction record if the junction  doesn't exist with same SubRecipient and Incident available on the Project...
        //createIncidentSubRecipientStageRecord(); //Sequencing is important as we need Incident id for this method...
        createIncidentSubRecipientSummaryRecord();

        updateManagerDetailsOnProjectRecord();
 /** This method is used to copy the latest Project version and Latest Supplement Number from Project number and Supplement Number field,
         * if there is no any Amendment available on the Project. */
        updateLatestProjectVersionAndSupplementNumber();
        
         // update Percent Complete To Date when  percent to complete field value is zero or null
        updatePercentCompleteToDate();
    }

    public override void processBeforeUpdate()  {
        /** This method is used to auto populate Program and Incident value into Project record, Upon selecting Funding Opp. */
        fetchProgramAndIncident();

        /** This method is used to update the Program name Prefix to project Number. (Prefix for the Program is configured from metadata) */
        updateProgramNamePrefixToProjectVersion();
        //Story No - 374
        //To through custom validation Error based on "Reverse Calculation" checkbox and the value change of "FEMA Share %/State Share %" or "Federal Project Award/State Project Award"...
        //reverseCalculationCheckBoxValidation();

        //This method is used to calculate the FEMA Share %, State Share %, Federal Project Award and State Project Award based on selection of "Reverse Calculation" Checkbox...
        calculateStateAndFederalCostShare();

        //To automatically update "Pay to State Admin" vale to "Yes", If "Eligible for State Admin Share" value is "Yes"....
        autoUpdatePayToStateAdmin(); //Should get executed before calculateLocalSharePercentage() method bacause the value depends upon this method..

        //To calculate Local Share% of the Project..
        calculateLocalSharePercentage();

        //To create the Incident Subrecipient Stage junction record if the juction  doesn't exist with same SubRecipient and Incident available on the Project...
        //createIncidentSubRecipientStageRecord(); //Sequencing is important as we need Incident id for this method...
        createIncidentSubRecipientSummaryRecord();

        // To prevent the user from changing project stage to Active Payment untill all the documents are uploaded...
        preventStageChangeWithoutDocUpload();

        //If a Payment Request is created for the Proejct, then user cannot change the Funding Source...
        //User should not be able to change the "Funding opportunity" of the Project...
        preventChangingFundingOpportunity();

        //To move Project Status to ON - hold If Deobligation causes Negative balance in the Project...
        //deobligatedProjectOnHold();
        putDeObligatedProjectOnHold();

        //To Allow user to change "State Admin %" and "Pay to State Admin", Only if the Entity type of Account is "City, County or Special District"....
        //preventChangingStateAdminAndPaytoStateAdmin();

        //To assign Project's State Retention and Federal Retention bassed on Program and Project Type(Small or Large)...
        projectRetention();
        
		/** This method is used to update the Total Federal Retention, Total State Retention, Federal Project Award W/o retention and
         * State Project Award W/o Retention field on Project record. and Project. */
        updateRetentionAndProjectAwardWithoutRetentionField();
        //To allow changing Project's Amount when it is "New" or "Obligating" or "Compliance verification" and there is nom Amendment...
        //preventChangingProjectAmount();

        //Todo Add Comments and Ticket No-
        //Story No - 378
        //This method is used to check if there is any "Approved/In Review" PR on the Project without marking Project to Withdrawn Stage...
        preventProjectWithdrawnWithApprovedOrInReviewPr();

        updateManagerDetailsOnProjectRecord();
 /** This method is used to copy the latest Project version and Latest Supplement Number from Project number and Supplement Number field,
         * if there is no any Amendment available on the Project. */
        updateLatestProjectVersionAndSupplementNumber();
        
          // update Percent Complete To Date when  percent to complete field value is zero or null
        updatePercentCompleteToDate();

        //Prevent & convey msg, if user tried to update Percent Complete To Date below 100%, when any CR or CT concerned with it
        preventPercentCompleteToDateUpdate();

         //Prevent & convey msg, if user tried to update Project name and if user is not system admin user and is in pa app 
        preventProjectNameToUpdate();

    }

    public override void processAfterInsert()  {
        //Create document after creation of project
        createDocuments(); //As per Sprint 5/6 requirement Automation is not needed anymore for Document creation...
        createNewAwardOnProjectCreation(); //This method is used to create an Award upon Project creation....
        //customRollUpOnIncidentForInsertAndUpdate(); //This method is used to Roll up the Projects Amount on Incident whenever a Project is created/Updated/Undeleted....
        createIncidentSubRecipientSummaryRecord();

        /** This method is used to Roll up the Projects Amount on Incident whenever a Project is created/Updated/Undeleted. */
        //customRollUpOfAmountOnIncidentForInsertAndUpdate();
        customRollUpOfAmountOnIncidentForInsertAndUpdateNew();

        /** This method is used to update the Roll up from project to Incident Sub Recipient Summary record
         * upon Insertion/Updation/Undeletion of Project. */
        //customRollUpOnIncidentSubRecipientSummary();
        customRollUpOnIncidentSubRecipientSummaryNew();
        shareProjectRecords();
    }

    public override void processAfterUpdate()  {
        createDocuments();
        updateSubRecipientInfoOnPR(); //This method is used to update the Sub Recipient Name and Email field on PR if Obligating Sub Recipient has been changed on PR..
        updateTotalAdminShareAmountOfPaymentRequest();
        updateStateCostShareAndFederalCostShareOfPaymentRequest(); //To update "State and Federal Amounts" Of Payment Request, If in Project some specific Fields are changing.....
        updateActiveAward(); // To update Active Award Period and Amount if the value changes on Project...
		/** This method is used to auto Withdraw the related PR upon Project Withdrawal. */
        updateRelatedPrsToWithdrawnUponProjectWithdrawn();
        //customRollUpOnIncidentForInsertAndUpdate(); //This method is used to Roll up the Projects Amount on Incident whenever a Project is created/Updated/Undeleted....
        createIncidentSubRecipientSummaryRecord();
		/** Ticket No - 563 */
        /** This method is used to update the State Cost Share Flag on Inc Sub Recipient Summary record
         * upon change of State Amount Requested/Admin Amount Requested on Project. */
        stateCostShareFlagUpdateOnSummaryRecord();
      
        /** This method is used to Roll up the Projects Amount on Incident whenever a Project is created/Updated/Undeleted. */
        //customRollUpOfAmountOnIncidentForInsertAndUpdate();
        customRollUpOfAmountOnIncidentForInsertAndUpdateNew();

        /** This method is used to update the Rollups from project to Incident Sub Recipient Summary record
         * upon Insertion/Updation/Undeletion of Project. */
        //customRollUpOnIncidentSubRecipientSummary();
        customRollUpOnIncidentSubRecipientSummaryNew();
        checkLastSmallProjectPercentage();
        shareProjectRecords();

       
        percenToCompleteDateUpdated();
    }

    public override void processBeforeDelete() {
        //customRollUpOnIncidentForDelete(); //This method is used to Roll up the Projects Amount on Incident whenever a Project is deleted....
        customRollUpOfAmountOnIncidentForDelete();
	/** Ticket No - 563 */
        /** This method is used to update the State Cost Share Flag on Inc Sub Recipient Summary record
         * upon change of State Amount Requested/Admin Amount Requested on Project. */
        stateCostShareFlagUpdateOnSummaryRecord();
      
        /** This method is used to update the Rollups from project to Incident Sub Recipient Summary record upon Deletion of Project. */
        //customRollUpOnIncidentSubRecipientSummaryOnDelete();
        customRollUpOnIncidentSubRecipientSummaryOnDeleteNew();
    }

    public override void processAfterUndelete() {
        //customRollUpOnIncidentForInsertAndUpdate(); //This method is used to Roll up the Projects Amount on Incident whenever a Project is created/Updated/Undeleted....
		/** This method is used to update the State Cost Share Flag on Inc Sub Recipient Summary record
         * upon change of State Amount Requested/Admin Amount Requested on Project. */
        stateCostShareFlagUpdateOnSummaryRecord();
       
        /** This method is used to Roll up the Projects Amount on Incident whenever a Project is created/Updated/Undeleted. */
        //customRollUpOfAmountOnIncidentForInsertAndUpdate();
        customRollUpOfAmountOnIncidentForInsertAndUpdateNew();

        /** This method is used to update the Rollups from project to Incident Sub Recipient Summary record
         * upon Insertion/Updation/Undeletion of Project. */
        //customRollUpOnIncidentSubRecipientSummary();
        customRollUpOnIncidentSubRecipientSummaryNew();
         
	}

    private  void createIncidentSubRecipientSummaryRecord() {
        List<Project__c> projectList = new List<Project__c>(); //To store the list of Project to process...
        Set<Id> subRecipientIds = new Set<Id>();
        Set<Id> incidentIds = new Set<Id>();
        if (Trigger.isInsert) {
            for (Project__c project : (List<Project__c>)Trigger.new) {
                if(project.Incident_Name__c != null
                        && (Trigger.isBefore || (Trigger.isAfter && project.Incident_Subrecipient_Summary__c == null) )) {
                    projectList.add(project); //Adding the Project record to the collection....
                    subRecipientIds.add(project.Obligating_Sub_Recipient__c);
                    incidentIds.add(project.Incident_Name__c);
                }
            }
        }
        if (Trigger.isUpdate) {
            for (Project__c project : (List<Project__c>)Trigger.new){
                Project__c oldRecord = (Project__c) Trigger.oldMap.get(project.Id); //fetching the old Project record...
                //Condition to check if the Obligating Sub-Recipient/Incident has been changed....
                if (project.Incident_Name__c != null && (project.Incident_Name__c != oldRecord.Incident_Name__c
                        || project.Obligating_Sub_Recipient__c != oldRecord.Obligating_Sub_Recipient__c
                        || project.Incident_Subrecipient_Summary__c == null)) {
                    projectList.add(project); //Adding the Project record to the collection....
                    subRecipientIds.add(project.Obligating_Sub_Recipient__c);
                    incidentIds.add(project.Incident_Name__c);
                }
            }
        }

        if (subRecipientIds.size() > 0 && incidentIds.size() > 0) {
            //fetching Incident Sub Recipient Junction record whose Incident/SubRecipient Id are in Set collection....
            // Ticket No - Updated for 563 - Start - added (Cumulative_State_Cost_Share_Flag__c) field in query
            // Ticket No - Updated for 926 - To update Obligated State Share Flag - Start  - added (Obligated_State_Share__c) field in query.
            List<Incident_Subrecipient_Stage__c> summaryRecordList = [SELECT Id, Name, Incident__c, Account__c, Cumulative_State_Cost_Share_Flag__c,
                                                                        Obligated_State_Share__c FROM Incident_Subrecipient_Stage__c
                                                                        WHERE Account__c IN : subRecipientIds
                                                                        AND Incident__c IN : incidentIds];
            //Map collection to arrange the Summary record as "IncidentId + Sub Recipient Id as key" and Summary record as value.
            Map<String, Incident_Subrecipient_Stage__c> incidentSubRecipientIdToSummaryRecordMap = new Map<String, Incident_Subrecipient_Stage__c>();
            if(summaryRecordList.size() > 0) {
                for (Incident_Subrecipient_Stage__c summaryRecord : summaryRecordList) {
                    String key = (String)summaryRecord.Incident__c + (String)summaryRecord.Account__c;
                    incidentSubRecipientIdToSummaryRecordMap.put(key, summaryRecord);
                }
            }
            List<Incident_Subrecipient_Stage__c> summaryRecordToInsertList = new List<Incident_Subrecipient_Stage__c>();
            for (Project__c project : projectList) {
                String key = (String)project.Incident_Name__c + (String)project.Obligating_Sub_Recipient__c;
                Incident_Subrecipient_Stage__c summaryRecord = incidentSubRecipientIdToSummaryRecordMap?.get(key);
                if (summaryRecord == null && Trigger.isAfter) {
                    Incident_Subrecipient_Stage__c summaryRecordToInsert = new Incident_Subrecipient_Stage__c();
                    // Preparing the Name for Summary record "Declaration Number - FIPS Number".
                    // If the Declaration Number and FIPS both rae available on Project - "Declaration Number - FIPS Number".
                    // If Only Declaration Number is available and FIPS not available on Project - "Declaration Number".
                    // If Only FIPS is available and Declaration Number not available on Project - "FIPS Number".
                    String summaryName = '';
                    if (project.Declaration_Number__c != null) {
                        summaryName += project.Declaration_Number__c;
                    }
                    if (project.FIPS_ID__c != null
                            && (summaryName != null && summaryName != '')) {
                        summaryName += ('-(' + project.FIPS_ID__c + ')');
                    }
                    else if(project.FIPS_ID__c != null
                            && (summaryName == null || summaryName == '')) {
                        summaryName += project.FIPS_ID__c;
                    }
                    summaryRecordToInsert.Name = summaryName;
                    summaryRecordToInsert.Incident__c = project.Incident_Name__c;
                    summaryRecordToInsert.Account__c = project.Obligating_Sub_Recipient__c;
                    summaryRecordToInsertList.add(summaryRecordToInsert);
                }
                else if(summaryRecord != null && Trigger.isBefore) {
                    project.Incident_Subrecipient_Summary__c = summaryRecord.Id;
					project.Cumulative_State_Cost_Share_Flag__c = summaryRecord.Cumulative_State_Cost_Share_Flag__c; //Updated for Ticket No - 563
                    project.Obligated_State_Share__c = summaryRecord.Obligated_State_Share__c; //Updated for Ticket No - 926
                }
            }
            /** Ticket No - Updated for 926 - To update Obligated State Share Flag - End */
  			/** Ticket No - Updated for 563 - End */
            if (summaryRecordToInsertList.size() > 0) {
                insert summaryRecordToInsertList;
            }
        }
    }

    //To auto populate Program and Incident value into Project reocord, Upon selecting Funding Opp...
    private void fetchProgramAndIncident(){
        //Create the Set to store the id of the Funding opp records, which is associated to project record...
        Set<Id> FundingOppsIDs = new Set<Id>();
        for(Project__c pr : (List<Project__c>)Trigger.new){

            if(Trigger.isInsert && pr.Funding_Opportunity_Name__c !=null){ //Checking for Funding Opp null pointer exception....
                FundingOppsIDs.add(pr.Funding_Opportunity_Name__c); //Adding Id to the collection...
            }
            if(Trigger.isUpdate && pr.Funding_Opportunity_Name__c !=null &&  ((Project__c) Trigger.oldMap.get(pr.Id)).Funding_Opportunity_Name__c!=pr.Funding_Opportunity_Name__c){
                FundingOppsIDs.add(pr.Funding_Opportunity_Name__c); //Adding Id to the collection...
            }
        }

        if(!FundingOppsIDs.isEmpty()){
            //Create a collection to fetch the all the Funding Opp record data, whose Ids are available in Set Collection(FundingOppsIDs).....
            Map<Id,Funding_Opportunity__c> MapFundingOpps=new Map<Id,Funding_Opportunity__c>([SELECT Id, Name,Program_Name__c,Incident_Name__c, Incident_Name__r.Declaration_Number__c FROM Funding_Opportunity__c
                                                                                              WHERE Id IN : FundingOppsIDs]);

            for(Project__c pr : (List<Project__c>)Trigger.new){
                //Get the related record from collection....
                Funding_Opportunity__c fundingOpp = MapFundingOpps.get(pr.Funding_Opportunity_Name__c);

                //Update the values in Project record...
                pr.Program_Name__c = fundingOpp?.Program_Name__c;
                pr.Incident_Name__c = fundingOpp?.Incident_Name__c;
            }
        }
    }

    //To calculate Local Share% of the Project.....
    private void calculateLocalSharePercentage(){
        List<Project__c> toProcessList = new List<Project__c>();
        if(Trigger.isInsert){
            toProcessList = Trigger.new;
        }
        if(Trigger.isUpdate && Trigger.isBefore){
            for(Project__c project :(List<Project__c>)Trigger.new){
                Project__c projectOld = (Project__c) Trigger.oldMap.get(project.Id); //Fetching old Project record from Collection...
                //Condition to check if Funding Source / FEMA Share / State Share / State Admin Share / Pay To State Admin has been changed for the Project record...
                if(project.FundingSource__c!=projectOld.FundingSource__c || project.State_Share__c!=projectOld.State_Share__c
                         || project.FEMA_Share__c!=projectOld.FEMA_Share__c || project.PaytoStateAdmin__c != projectOld.PaytoStateAdmin__c
                           || project.StateAdmin__c!=projectOld.StateAdmin__c  ){
                    toProcessList.add(project); //Adding the Project record to the collection for processing...
                }
            }
        }
        if (toProcessList.size() > 0) {
            for (Project__c projectToProcess : toProcessList) { //Iterating Project to Process list collection....
                //Condition to check if the State Share and FEMA share of the Project is not null....
                if(projectToProcess.FEMA_Share__c!=null && projectToProcess.State_Share__c!=null ) {
                    projectToProcess.Local_Share__c = 100 - (projectToProcess.FEMA_Share__c + projectToProcess.State_Share__c); //Calculation of the Local Share Percentage of the Project.....
                }
                //Condition to check if the FEMA share of the Project is not null....
                else if(projectToProcess.FEMA_Share__c!=null) {
                    projectToProcess.Local_Share__c = 100 - (projectToProcess.FEMA_Share__c ); //Calculation of the Local Share Percentage of the Project.....
                }
                //Condition to check if the State Share of the Project is not null....
                else if(projectToProcess.State_Share__c!=null) {
                    projectToProcess.Local_Share__c = 100 - (projectToProcess.State_Share__c ); //Calculation of the Local Share Percentage of the Project.....
                }
            }
        }
    }

    /*********************************************
	* Method Name : createNewAwardOnProjectCreation
	* Called From Method : After Insert
	* Author : Ricky
	* Inputs : -
	* Description: This method is used to create an Active Award upon Project creation.
	*********************************************/
    private void createNewAwardOnProjectCreation(){
        List<Award__c> awardToInsert = new List<Award__c>(); //To collect the Award record to insert.....
        for(Project__c projectToProcess : (List<Project__c>)Trigger.new){
            Award__c award = new Award__c(); //Creating an Award record for the Project...
            award.Project__c = projectToProcess.Id;
            award.Status__c = ALS_CONSTANTS.Award_Status_Active;
            award.AwardStartDate__c = projectToProcess.Start_Date__c;
            award.AwardEndDate__c = projectToProcess.End_Date__c;
            award.Supplement_Award__c = projectToProcess.Total_Project_Award__c == null ? 0.00 : projectToProcess.Total_Project_Award__c;
            award.AmountObligated__c = projectToProcess.Total_Project_Award__c == null ? 0.00 : projectToProcess.Total_Project_Award__c;
            award.Previous_Amount_Obligated__c = 0;
			award.Obligated_State_Share__c = projectToProcess.Obligated_State_Share__c;
            award.Previous_Federal_Amount_Obligated__c = 0;
            award.Previous_State_Amount_Obligated__c = 0;
            award.Previous_State_Admin_Amount_Obligated__c = 0;

            award.Federal_Project_Amount__c = projectToProcess.Federal_Project_Award__c == null ? 0.00 : projectToProcess.Federal_Project_Award__c;
            award.Federal_Supplement_Amount__c = projectToProcess.Federal_Project_Award__c == null ? 0.00 : projectToProcess.Federal_Project_Award__c;
            award.State_Project_Amount__c = projectToProcess.State_Project_Award__c == null ? 0.00 : projectToProcess.State_Project_Award__c;
            award.State_Supplement_Amount__c = projectToProcess.State_Project_Award__c == null ? 0.00 : projectToProcess.State_Project_Award__c;
            award.State_Admin_Amount__c = projectToProcess.TotalProjectStateAdminShare__c == null ? 0.00 : projectToProcess.TotalProjectStateAdminShare__c;
            award.State_Admin_Supplement_Amount__c = projectToProcess.TotalProjectStateAdminShare__c == null ? 0.00 : projectToProcess.TotalProjectStateAdminShare__c;

            award.FEMA_Share__c = projectToProcess.FEMA_Share__c == null ? 0.00 : projectToProcess.FEMA_Share__c;
            award.State_Share__c = projectToProcess.State_Share__c == null ? 0.00 : projectToProcess.State_Share__c;
            award.State_Admin__c = projectToProcess.StateAdmin__c == null ? 0.00 : projectToProcess.StateAdmin__c;
            award.Federal_Retention_Share__c = projectToProcess.Federal_Retention__c == null ? 0.00 : projectToProcess.Federal_Retention__c;
            award.State_Retention_Share__c =  projectToProcess.State_Retention__c == null ? 0.00 : projectToProcess.State_Retention__c;

            award.Federal_Retention__c = ((award.Federal_Supplement_Amount__c
                    * award.Federal_Retention_Share__c)/100)?.setScale(2,system.RoundingMode.DOWN);
            award.State_Retention__c = ((award.State_Supplement_Amount__c
                    * award.State_Retention_Share__c)/100)?.setScale(2,system.RoundingMode.DOWN);
            award.Federal_Amount_Available__c = (award.Federal_Supplement_Amount__c
                    - award.Federal_Retention__c)?.setScale(2,system.RoundingMode.DOWN);
            award.State_Amount_Available__c = (award.State_Supplement_Amount__c
                    - award.State_Retention__c)?.setScale(2,system.RoundingMode.DOWN);

            award.Total_Obligated_Amount__c = (award.Federal_Project_Amount__c
                    + award.State_Project_Amount__c + award.State_Admin_Amount__c)?.setScale(2,system.RoundingMode.DOWN);
            award.Total_Obligated_Supplement_Amount__c = (award.Federal_Supplement_Amount__c
                    + award.State_Supplement_Amount__c + award.State_Admin_Supplement_Amount__c)?.setScale(2,system.RoundingMode.DOWN);

            award.Sum_of_State_and_Federal_to_Date__c = (award.Federal_Project_Amount__c
                    + award.State_Project_Amount__c)?.setScale(2,system.RoundingMode.DOWN);
            award.Sum_of_State_and_Admin_to_Date__c = (award.State_Project_Amount__c
                    + award.State_Admin_Amount__c)?.setScale(2,system.RoundingMode.DOWN);

            award.Sum_of_State_and_Federal__c = (award.Federal_Supplement_Amount__c
                    + award.State_Supplement_Amount__c)?.setScale(2,system.RoundingMode.DOWN);
            award.Sum_of_State_and_Admin_Supplement__c = (award.State_Supplement_Amount__c
                    + award.State_Admin_Supplement_Amount__c)?.setScale(2,system.RoundingMode.DOWN);
            
            if(projectToProcess.Project_Number__c != null) {
                award.FDSR__c = projectToProcess.Project_Number__c;
            }
            if(projectToProcess.Supplement_Number__c != null) {
                award.Supplement_Number__c =  projectToProcess.Supplement_Number__c;
            }

            if (projectToProcess.Reviewed_By_Manager__c == ALS_CONSTANTS.Picklist_Yes) {
                award.Manager_User__c = projectToProcess.Manager_User__c;
                award.Manager_Approved_Date__c = projectToProcess.Manager_Approved_Date__c;
            }
            else {
                award.Manager_User__c = null;
                award.Manager_Approved_Date__c = null;
            }
            awardToInsert.add(award); //Adding the Award record to collection for Inserting...
        }
        if (awardToInsert.size() > 0) {
            insert awardToInsert; //Inserting the Award records...
        }
    }

    /*********************************************
	* Method Name : updateActiveAward
	* Called From Method : After Update
	* Author : Ricky
	* Inputs : -
	* Description: This method is used to update Active Award Period and Amount if the value changes on Project,
	*               if there is no Amendment exists in the project
	*               or else just updates the Project number to FDSR of Initial Award of the Project. */
    private void updateActiveAward(){
        Map<Id, Project__c> idToProjectMap = new Map<Id, Project__c>(); //To collect the Project record for processing.
        Map<Id, Project__c> idToProjectAwardAmendmentMap = new Map<Id, Project__c>(); //To fetch the Project record data.
        List<Award__c> awardToUpdate = new List<Award__c>(); //To collect the Award records to update.
        for (Project__c projectToProcess : (List<Project__c>)Trigger.new) {
            Project__c oldProjectRecord = (Project__c)Trigger.oldMap.get(projectToProcess.Id); //Fetching the old Project record.
            //Condition to check field changes on Project which need to be reflected on Award record.
            //Incident Sub Recipient Summary field change is included to update the Obligated Share Flag on Award record.
            if (projectToProcess.Total_Project_Award__c != oldProjectRecord.Total_Project_Award__c
                    || projectToProcess.Start_Date__c != oldProjectRecord.Start_Date__c
                    || projectToProcess.End_Date__c != oldProjectRecord.End_Date__c
                    || projectToProcess.FEMA_Share__c != oldProjectRecord.FEMA_Share__c
                    || projectToProcess.State_Share__c != oldProjectRecord.State_Share__c
                    || projectToProcess.StateAdmin__c != oldProjectRecord.StateAdmin__c
                    || projectToProcess.Federal_Retention__c != oldProjectRecord.Federal_Retention__c
                    || projectToProcess.State_Retention__c != oldProjectRecord.State_Retention__c
                    || projectToProcess.Reviewed_By_Manager__c != oldProjectRecord.Reviewed_By_Manager__c
					|| projectToProcess.Incident_Subrecipient_Summary__c != oldProjectRecord.Incident_Subrecipient_Summary__c
                    || projectToProcess.Project_Number__c != oldProjectRecord.Project_Number__c
                    || projectToProcess.Supplement_Number__c != oldProjectRecord.Supplement_Number__c) {
                idToProjectMap.put(projectToProcess.Id, projectToProcess); //Adding the Project record into collection for processing....
            }
        }
        if (idToProjectMap.size() > 0) {
            //Fetching the Project record adn its related Active Award and Amendment records data...
            idToProjectAwardAmendmentMap = new Map<Id, Project__c>([SELECT Id, Name, Start_Date__c, End_Date__c,Total_Project_Award__c, Obligated_State_Share__c,
                                            (SELECT Id FROM Amendment_Requests__r),
                                            (SELECT Id, Name, Status__c, AwardStartDate__c, AwardEndDate__c, AmountObligated__c FROM Awards__r
                                            ORDER BY CreatedDate ASC) FROM Project__c WHERE Id IN : idToProjectMap.keySet()]);
            //WHERE Status__c =: ALS_CONSTANTS.Award_Status_Active) FROM Project__c WHERE Id IN : idToProjectMap.keySet()]);

            for (Project__c projectToProcess : idToProjectMap.values()) { //Iterating the Project record to process....
                Project__c oldProjectRecord = (Project__c)Trigger.oldMap.get(projectToProcess.Id); //Fetching the old Project record...
                Project__c project = idToProjectAwardAmendmentMap.get(projectToProcess.Id); // Fetching the Project record data from Map collection...
                if(project.Amendment_Requests__r.size() == 0
                        && project.Awards__r[0].Status__c == ALS_CONSTANTS.Award_Status_Active) { // Condition to check if there is no Amendment record for the Project...

                    Award__c awardToProcess = project.Awards__r[0];
                    //Updating the Award record values...
                    awardToProcess.AwardStartDate__c = project.Start_Date__c;
                    awardToProcess.AwardEndDate__c = project.End_Date__c;
                    awardToProcess.Supplement_Award__c = project.Total_Project_Award__c == null ? 0.00 : project.Total_Project_Award__c;
                    awardToProcess.AmountObligated__c = project.Total_Project_Award__c == null ? 0.00 : project.Total_Project_Award__c;
					awardToProcess.Obligated_State_Share__c = project.Obligated_State_Share__c;
                    awardToProcess.Previous_Amount_Obligated__c = 0;
                    awardToProcess.Previous_Federal_Amount_Obligated__c = 0;
                    awardToProcess.Previous_State_Amount_Obligated__c = 0;
                    awardToProcess.Previous_State_Admin_Amount_Obligated__c = 0; 

                    awardToProcess.Federal_Supplement_Amount__c = projectToProcess.Federal_Project_Award__c == null ? 0.00 : projectToProcess.Federal_Project_Award__c;
                    awardToProcess.Federal_Project_Amount__c = projectToProcess.Federal_Project_Award__c == null ? 0.00 : projectToProcess.Federal_Project_Award__c;
                    awardToProcess.State_Supplement_Amount__c = projectToProcess.State_Project_Award__c == null ? 0.00 : projectToProcess.State_Project_Award__c;
                    awardToProcess.State_Project_Amount__c = projectToProcess.State_Project_Award__c == null ? 0.00 : projectToProcess.State_Project_Award__c;
                    awardToProcess.State_Admin_Supplement_Amount__c = projectToProcess.TotalProjectStateAdminShare__c == null ? 0.00 : projectToProcess.TotalProjectStateAdminShare__c;
                    awardToProcess.State_Admin_Amount__c = projectToProcess.TotalProjectStateAdminShare__c == null ? 0.00 : projectToProcess.TotalProjectStateAdminShare__c;

                    awardToProcess.FEMA_Share__c = projectToProcess.FEMA_Share__c == null ? 0.00 : projectToProcess.FEMA_Share__c;
                    awardToProcess.State_Share__c = projectToProcess.State_Share__c == null ? 0.00 : projectToProcess.State_Share__c;
                    awardToProcess.State_Admin__c = projectToProcess.StateAdmin__c == null ? 0.00 : projectToProcess.StateAdmin__c;
                    awardToProcess.Federal_Retention_Share__c = projectToProcess.Federal_Retention__c == null ? 0.00 : projectToProcess.Federal_Retention__c;
                    awardToProcess.State_Retention_Share__c =  projectToProcess.State_Retention__c == null ? 0.00 : projectToProcess.State_Retention__c;

                    awardToProcess.Federal_Retention__c = ((awardToProcess.Federal_Supplement_Amount__c
                            * awardToProcess.Federal_Retention_Share__c)/100)?.setScale(2,system.RoundingMode.DOWN);
                    awardToProcess.State_Retention__c = ((awardToProcess.State_Supplement_Amount__c
                            * awardToProcess.State_Retention_Share__c)/100)?.setScale(2,system.RoundingMode.DOWN);
                    awardToProcess.Federal_Amount_Available__c = (awardToProcess.Federal_Supplement_Amount__c
                            - awardToProcess.Federal_Retention__c)?.setScale(2,system.RoundingMode.DOWN);
                    awardToProcess.State_Amount_Available__c = (awardToProcess.State_Supplement_Amount__c
                            - awardToProcess.State_Retention__c)?.setScale(2,system.RoundingMode.DOWN);

                    awardToProcess.Total_Obligated_Amount__c = (awardToProcess.Federal_Project_Amount__c
                            + awardToProcess.State_Project_Amount__c + awardToProcess.State_Admin_Amount__c)?.setScale(2,system.RoundingMode.DOWN);
                    awardToProcess.Total_Obligated_Supplement_Amount__c = (awardToProcess.Federal_Supplement_Amount__c
                            + awardToProcess.State_Supplement_Amount__c + awardToProcess.State_Admin_Supplement_Amount__c)?.setScale(2,system.RoundingMode.DOWN);

                    awardToProcess.Sum_of_State_and_Federal_to_Date__c = (awardToProcess.Federal_Project_Amount__c
                            + awardToProcess.State_Project_Amount__c)?.setScale(2,system.RoundingMode.DOWN);
                    awardToProcess.Sum_of_State_and_Admin_to_Date__c = (awardToProcess.State_Project_Amount__c
                            + awardToProcess.State_Admin_Amount__c)?.setScale(2,system.RoundingMode.DOWN);

                    awardToProcess.Sum_of_State_and_Federal__c = (awardToProcess.Federal_Supplement_Amount__c
                            + awardToProcess.State_Supplement_Amount__c)?.setScale(2,system.RoundingMode.DOWN);
                    awardToProcess.Sum_of_State_and_Admin_Supplement__c = (awardToProcess.State_Supplement_Amount__c
                            + awardToProcess.State_Admin_Supplement_Amount__c)?.setScale(2,system.RoundingMode.DOWN);
                    if(projectToProcess.Project_Number__c != null) {
                        awardToProcess.FDSR__c =  projectToProcess.Project_Number__c;
                    }
                    else {
                        awardToProcess.FDSR__c =  null;
                    }
                    if(projectToProcess.Supplement_Number__c != null) {
                        awardToProcess.Supplement_Number__c =  projectToProcess.Supplement_Number__c;
                    }
                    else {
                        awardToProcess.Supplement_Number__c =  null;
                    }
                    if (projectToProcess.Reviewed_By_Manager__c == ALS_CONSTANTS.Picklist_Yes) {
                        awardToProcess.Manager_User__c = projectToProcess.Manager_User__c;
                        awardToProcess.Manager_Approved_Date__c = projectToProcess.Manager_Approved_Date__c;
                    }
                    else {
                        awardToProcess.Manager_User__c = null;
                        awardToProcess.Manager_Approved_Date__c = null;
                    }
                    awardToUpdate.add(awardToProcess); //Adding the Award record to collection for updating.....
                }
                // Condition to check if Amendment request exists on Project,
                // then to update Only Project Number and Supplement Number on Initial Award record.
                else if(project.Amendment_Requests__r.size() > 0
                        && (oldProjectRecord.Project_Number__c != projectToProcess.Project_Number__c
                            || oldProjectRecord.Supplement_Number__c != projectToProcess.Supplement_Number__c )) {
                    Award__c awardToProcess = project.Awards__r[0];
                    if(projectToProcess.Project_Number__c != null) {
                        awardToProcess.FDSR__c =  projectToProcess.Project_Number__c;
                    }
                    else {
                        awardToProcess.FDSR__c =  null;
                    }
                    if(projectToProcess.Supplement_Number__c != null) {
                        awardToProcess.Supplement_Number__c =  projectToProcess.Supplement_Number__c;
                    }
                    else {
                        awardToProcess.Supplement_Number__c =  null;
                    }
                    if (projectToProcess.Reviewed_By_Manager__c == ALS_CONSTANTS.Picklist_Yes) {
                        awardToProcess.Manager_User__c = projectToProcess.Manager_User__c;
                        awardToProcess.Manager_Approved_Date__c = projectToProcess.Manager_Approved_Date__c;
                    }
                    else {
                        awardToProcess.Manager_User__c = null;
                        awardToProcess.Manager_Approved_Date__c = null;
                    }
                    awardToUpdate.add(awardToProcess);
                }
            }
            if(awardToUpdate.size() > 0){
                update awardToUpdate; //updating the Award record...
            }
        }
    }

    //Create documents from project.....
    private void createDocuments() {
        Map<Id, Project__c> idToProjectMapForProcessing = new Map<Id, Project__c>();
        List<String> programNameList = new List<String>(); //To collect the Program Id of the Projects....
        Set<String> accountList = new Set<String>();
        Set<Id> projectIds = new Set<Id>(); //To collect the Project Ids...
        if (Trigger.isInsert) {
            for(Project__c project : (List<Project__c>)Trigger.new){
                if(project.External_Id__c == null ||
                        (project.External_Id__c !=null && project.Allow_System_Calculation__c == true)) {
                    idToProjectMapForProcessing.put(project.Id, project);
                }
            }
        }
        if (Trigger.isUpdate) {
            Map<Id, Project__c> projectIdToProjectMap = new Map<Id, Project__c>();
            for(Project__c project : (List<Project__c>)Trigger.new) {
                Project__c oldRecord = (Project__c) Trigger.oldMap.get(project.Id);
                if(project.Allow_System_Calculation__c != oldRecord.Allow_System_Calculation__c
                        && project.Allow_System_Calculation__c == true
                        && project.External_Id__c != null) {
                    projectIdToProjectMap.put(project.Id, project);
                }
            }
            Map<Id, Project__c> idToProjectWithDocumentsMap = new Map<Id, Project__c>([SELECT Id, (SELECT Id, ProjectId__c FROM Documents__r)
                                                                FROM Project__c WHERE Id IN : projectIdToProjectMap.keySet()]);
            for (Project__c projectToProcess : projectIdToProjectMap.values()) {
                Project__c projectwithDocument = idToProjectWithDocumentsMap.get(projectToProcess.Id);
                if (projectwithDocument.Documents__r.size() == 0) {
                    idToProjectMapForProcessing.put(projectToProcess.Id, projectToProcess);
                }
            }
        }

        if (idToProjectMapForProcessing.size() > 0) {
            for(Project__c project : idToProjectMapForProcessing.values()){
                if(project.Program_Name__c != null) { //Condition to check Program null pointer exception...
                    programNameList.add(project.Program_Name__c);
                    projectIds.add(project.Id);
                }
            }
            new CreateProjectDocumentPlatformEvent().handle(projectIds); //Calling the Class to create tge Project record Document....
        }
    }

    // To prevent the user from changing project stage to Active Payment until all the active documents are uploaded...
    private void preventStageChangeWithoutDocUpload() {
        Map<Id, Project__c> projectToProcessMap = new Map<Id, Project__c>(); //To collect the Project records for processing....
        for (Project__c pRecord : (List<Project__c>)Trigger.new) {
            Project__c oldProjectRecord = (Project__c) (Trigger.oldMap.get(pRecord.Id)); //Fetching old recprd data from Trigger.OldMap...
            //Condition to check if the stage value is changed to "Active Payment"....
            if ((oldProjectRecord.Stage__c != pRecord.Stage__c) && pRecord.Stage__c == ALS_CONSTANTS.Project_Stage_ActivePayment) {
                projectToProcessMap.put(pRecord.Id, pRecord); //Adding the Project record to map collection for processing...
            }
        }
        if (projectToProcessMap.size() > 0) {
            //Fetching the Project record data and its related Document records...
            Map<Id, Project__c> idToProjectWithDocumentMap = new Map<Id, Project__c>([SELECT Id, Stage__c, (SELECT Id, Document_Name__c,
                                                        Status__c, Is_Required__c, Stage__c, ProjectId__c FROM Documents__r) FROM Project__c
                                                            WHERE Id IN :projectToProcessMap.keySet()]);
            for (Project__c projectToProcess : projectToProcessMap.values()) { //Iterating Project record to Process values...
                Project__c projectWithDocument = idToProjectWithDocumentMap.get(projectToProcess.Id); //Fetching the Project Record data from map collection....
                if(projectWithDocument.Documents__r.size() > 0) { //To check null pointer exception..
                    for(Document__c doc : projectWithDocument.Documents__r) { //Iterating the Project Document records.....
                        if(doc.Status__c == ALS_CONSTANTS.Document_Status_Active && doc.Is_Required__c == ALS_CONSTANTS.Document_IsRequired_Required
                                && doc.Stage__c != ALS_CONSTANTS.Document_Stage_Uploaded ) { //To check each Required and Active Document stage is Uploaded.....
                            projectToProcess.addError('All "Active" and "Required" Documents must be uploaded to Mark stage as "Active Payment".');
                        }
                    }
                }
            }
        }
    }

    private void putDeObligatedProjectOnHold() {
        Map<Id, Project__c> onHoldProjectMap = new Map<Id, Project__c>();
        Set<Id> subRecipientIds = new Set<Id>();
        for (Project__c project : (List<Project__c>) Trigger.new) {
            Project__c oldProject = (Project__c) Trigger.oldMap.get(project.Id);
            if((project.External_Id__c==null || (project.External_Id__c !=null && project.Allow_System_Calculation__c == true))
                    && ((project.FederalAmountAvailable__c != oldProject.FederalAmountAvailable__c && project.FederalAmountAvailable__c < 0)
                            || (project.StateAmountAvailable__c != oldProject.StateAmountAvailable__c && project.StateAmountAvailable__c < 0)
                            || (project.AvailableAdminAmount__c != oldProject.AvailableAdminAmount__c && project.AvailableAdminAmount__c < 0)
                            || (project.AmountAvailable__c != oldProject.AmountAvailable__c && project.AmountAvailable__c < 0))
                    && project.Status__c != ALS_CONSTANTS.Project_Status_OnHoldDebtRecovery) {
                project.Status__c = ALS_CONSTANTS.Project_Status_OnHoldDebtRecovery;// Updating Project Status...
                if(!projectToPutOnHoldGlobalList.contains(project)) {
                    projectToPutOnHoldGlobalList.add(project);
                    onHoldProjectMap.put(project.Id, project);
                    subRecipientIds.add(project.Obligating_Sub_Recipient__c);
                }
            }
        }
        if (onHoldProjectMap.size() > 0) {
            putRelatedProjectOnHoldBasedOnProgramName(onHoldProjectMap, subRecipientIds); //Calling the method to put related Project on Hold.....
        }
    }

    private void putRelatedProjectOnHoldBasedOnProgramName(Map<Id, Project__c> onHoldProjectMap, Set<Id> subRecipientIds) {
        List<Project__c> projectsToUpdate = new List<Project__c>(); // TO collects the Projects To put on hold...
        //To fetch all the Accounts whose Id is in  "subRecipientIds" Collection...
        Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, Name,
                                                                    (SELECT Id, Name, Program_Name__c, Program_Name__r.Name,
                                                                            Program_Name__r.Master_Label_Program_Name__c, Status__c,
                                                                            Program_Name__r.Parent_Program__r.Name,
                                                                            Program_Name__r.Parent_Program__r.Master_Label_Program_Name__c
                                                                            FROM Projects1__r WHERE  External_Id__c = NULL)
                                                            FROM Account WHERE Id IN : subRecipientIds]);
        //Fetching the Project record Whose Id are available in collection.....
        Map<Id,Project__c> projectMap = new Map<Id,Project__c>([SELECT Id, Name, Status__c , Obligating_Sub_Recipient__c, Program_Name__c,
                                            Program_Name__r.Name, Program_Name__r.Master_Label_Program_Name__c,
                                            Program_Name__r.Parent_Program__r.Name, Program_Name__r.Parent_Program__r.Master_Label_Program_Name__c
                                            FROM Project__c WHERE Id IN : onHoldProjectMap.keySet()]);
        for(Project__c projectToProcess : projectMap.values()) {
            Account accountToProcess = accountMap.get(projectToProcess?.Obligating_Sub_Recipient__c); //Fetching the Sub Recipient record from Map collection...
            //Condition to put HMA Projects on Hold....
            // If the Project whose Available Amount went negative is of HMA Program -
            // Then all the HMA Projects under that Sub Recipient will go On-Hold
            if(projectToProcess?.Program_Name__r?.Parent_Program__r?.Master_Label_Program_Name__c == ALS_CONSTANTS.Program_HMA) {
                for (Project__c projectToPutOnHold : accountToProcess.Projects1__r) {
                    if(projectToPutOnHold.Id != projectToProcess.Id
                            && projectToPutOnHold.Program_Name__r.Parent_Program__r.Master_Label_Program_Name__c == ALS_CONSTANTS.Program_HMA
                            && !projectToPutOnHoldGlobalList.contains(projectToPutOnHold)
                            && projectToPutOnHold.Status__c != ALS_CONSTANTS.Project_Status_OnHoldDebtRecovery){
                        projectToPutOnHold.Status__c = ALS_CONSTANTS.Project_Status_OnHoldDebtRecovery;
                        projectToPutOnHoldGlobalList.add(projectToPutOnHold);
                        projectsToUpdate.add(projectToPutOnHold); //Adding the Project record to collection...
                    }
                }
            }
            //Condition to put CDAA(State Funding) Projects on Hold....
            // If the Project whose Available Amount went negative is of CDAA(State Only) Program -
            // Then all the Projects under that Sub Recipient will go On-Hold regardless of of Any Programs.
            else if(projectToProcess.Program_Name__r.Master_Label_Program_Name__c == ALS_CONSTANTS.Program_CDAA) {
                for (Project__c projectToPutOnHold : accountToProcess.Projects1__r) {
                    if (projectToPutOnHold.Id != projectToProcess.Id && !projectToPutOnHoldGlobalList.contains(projectToPutOnHold)
                            && projectToPutOnHold.Status__c != ALS_CONSTANTS.Project_Status_OnHoldDebtRecovery) {
                        projectToPutOnHold.Status__c = ALS_CONSTANTS.Project_Status_OnHoldDebtRecovery;
                        projectToPutOnHoldGlobalList.add(projectToPutOnHold);
                        projectsToUpdate.add(projectToPutOnHold); //Adding the Project record to collection...
                    }
                }
            }
            //Condition to put PA Projects on Hold....
            // If the Project whose Available Amount went negative is of PA Program -
            // Then all the PA Projects under that Sub Recipient will go On-Hold
            else if(projectToProcess.Program_Name__r.Parent_Program__r.Master_Label_Program_Name__c == ALS_CONSTANTS.Program_PA) {
                for (Project__c projectToPutOnHold : accountToProcess.Projects1__r) {
                    if(projectToPutOnHold.Id != projectToProcess.Id
                            && projectToPutOnHold.Program_Name__r.Parent_Program__r.Master_Label_Program_Name__c == ALS_CONSTANTS.Program_PA
                            && !projectToPutOnHoldGlobalList.contains(projectToPutOnHold)
                            && projectToPutOnHold.Status__c != ALS_CONSTANTS.Project_Status_OnHoldDebtRecovery){
                        projectToPutOnHold.Status__c = ALS_CONSTANTS.Project_Status_OnHoldDebtRecovery;
                        projectToPutOnHoldGlobalList.add(projectToPutOnHold);
                        projectsToUpdate.add(projectToPutOnHold); //Adding the Project record to collection...
                    }
                }
            }
        }
        if(projectsToUpdate.size() > 0) {
            update projectsToUpdate; //Updating the Project records to move Status to ON Hold - Debt Recovery....
        }
    }

    //To automatically update "Pay to State Admin" vale to "Yes", If "Eligible for State Admin Share" value is "Yes"....
    private void autoUpdatePayToStateAdmin() {
        for (Project__c project : (List<Project__c>)Trigger.new) {
            if (project.PaytoStateAdmin__c == ALS_CONSTANTS.Picklist_Yes) { //Condition to check if Pay to State Admin is Yes...
                project.EligibleforStateAdminShare__c = ALS_CONSTANTS.Picklist_Yes; //Updating Eligible for State Admin Share fields...
                if (project.StateAdmin__c == 0) { //Condition to check if the State Admin Share value is 0...
                    project.StateAdmin__c = 10; //Assigning State Admin share as 10%....
                }
            }
            else if (project.PaytoStateAdmin__c == ALS_CONSTANTS.Picklist_No) { //Condition to check if Pay to State Admin is No...
                project.StateAdmin__c = 0; //Assigning State Admin share as 0%....
            }
        }
    }

    //This method is used to update the Sub Recipient Name and Email field and Incident Name on PR if Obligating Sub Recipient has been changed on PR..
    private void updateSubRecipientInfoOnPR(){
        Set<Id> subRecipientIds = new Set<Id>(); //TO collect the Sub recipient IDs...
        Map<Id, Project__c> projectsToProcess = new Map<Id, Project__c>(); //To collect the Project record for processing...
        //Map<Id, Account> idToAccountMap = new Map<Id, Account>(); //To fetch the Sub Recipient data....
        for (Project__c projectRecord : (List<Project__c>)Trigger.new) {
            Project__c OldProjectRecord = (Project__c) Trigger.oldMap.get(projectRecord.Id); //Fetching the old Project record...
            if(projectRecord.Obligating_Sub_Recipient__c != OldProjectRecord.Obligating_Sub_Recipient__c
                    || (projectRecord.Incident_Name__c != null && projectRecord.Incident_Name__c != OldProjectRecord.Incident_Name__c)){ //Condition to check if the Sub Recipient has been changed...
                projectsToProcess.put(projectRecord.Id, projectRecord); //Adding Project record to collection....
                subRecipientIds.add(projectRecord.Obligating_Sub_Recipient__c); //Adding Sub Recipient Id to collection...
            }
        }
        if (subRecipientIds.size() > 0) {
            //Fetching the Payment Request record whose Projects Is are available in Map Collection KeySet...
            List<Payment_Request__c> prsToProcessList = [SELECT Id, Name, Project__c, Project__r.Obligating_Sub_Recipient__c,
                    Project__r.Obligating_Sub_Recipient__r.Name, Project__r.Obligating_Sub_Recipient__r.Email_Address__c, Project__r.Incident_Name__c
                    FROM Payment_Request__c WHERE Project__c IN : projectsToProcess.keySet()];
            //Fetching Sub Recipient Info....
            //idToAccountMap = new Map<Id, Account>([SELECT Id, Name, Email_Address__c FROM Account WHERE Id IN : subRecipientIds]);
            List<Payment_Request__c> prsToUpdate = new List<Payment_Request__c>();
            if (prsToProcessList.size() > 0) {
                for (Payment_Request__c prToProcess : prsToProcessList) { //Iterating PRs To Process list.....
                    //Project__c project = projectsToProcess.get(prToProcess.Project__c);
                    //Account suRecipient = idToAccountMap.get(prToProcess.Project__r.Obligating_Sub_Recipient__c); //Fetching the Sub Recipient record from Map collection.....
                    //Updating Sub Recipient info on PR...
                    if (!Approval.isLocked(prToProcess.Id)) {
                        prToProcess.ObligatedSubRecipient__c = prToProcess.Project__r.Obligating_Sub_Recipient__c;
                        prToProcess.Sub_Recipient_Name__c = prToProcess.Project__r.Obligating_Sub_Recipient__r.Name; //suRecipient.Name
                        prToProcess.Sub_Recipient_Email__c = prToProcess.Project__r.Obligating_Sub_Recipient__r.Email_Address__c; //suRecipient.Email_Address__c
                        prToProcess.IncidentName__c = prToProcess.Project__r.Incident_Name__c;
                        prsToUpdate.add(prToProcess);
                    }
                }

                // This block updates the payment Request. for the records that fails to update the PR, Shows the errors on Project Record
                if (prsToUpdate.size() > 0) {
                    //update prsToUpdate;
                    Database.SaveResult[] srList = Database.update(prsToUpdate, false);
                    Integer count = 0;
                    for (Database.SaveResult sr : srList) {
                        if (!sr.isSuccess()) {
                            for (Database.Error err : sr.getErrors()) {
                               Id id= prsToUpdate[count].Project__c;
                               Trigger.newMap.get(id).addError(err.message);
                                count++;
                            }
                        }
                    }
                }
            }
        }
    }

    /*********************************************
	* Method Name : updateTotalAdminShareAmountOfPaymentRequest
	* Called From Method : AfterUpdate
	* Author : Ricky
	* Inputs : -
	* Description: This method is used to update the Total Admin Share Amount on PR which are not locked and Admin Payment is allowed,
	*               if Admin Share/Approved Admin Amount is changed on Project. */
    private void updateTotalAdminShareAmountOfPaymentRequest() {
        // Map collection to collect the Project record on Which Total State Admin Share is changed or Admin Amount Approved is changed on Project,
        // In order to update the Admin Payment Allowed PR Admin Share value.
        Map<Id, Project__c> projectToProcessMap = new Map<Id, Project__c>();
        for (Project__c projectRecord : (List<Project__c>)Trigger.new) {
            Project__c OldProjectRecord = (Project__c) Trigger.oldMap.get(projectRecord.Id); //Fetching the old Project record...
            if (projectRecord.TotalProjectStateAdminShare__c != OldProjectRecord.TotalProjectStateAdminShare__c
                    //Updated the code for Ticket - 370 - Start
                    || projectRecord.Total_Admin_Amount_Approved__c != OldProjectRecord.Total_Admin_Amount_Approved__c) {
                projectToProcessMap.put(projectRecord.Id, projectRecord);
            }
        }

        if (projectToProcessMap.size() > 0) {
            List<Payment_Request__c> prListToUpdate = new List<Payment_Request__c>();
            List<Payment_Request__c> prListToProcess = [SELECT Id, External_Id__c , Project__c, Total_Admin_Amount_Approved__c,
                    TotalAdminShareAmount__c, Allow_Admin_Payment__c FROM Payment_Request__c WHERE Project__c IN : projectToProcessMap.keySet()];
            if (prListToProcess.size() > 0) {
                for (Payment_Request__c payRequest : prListToProcess) {
                    Project__c project = projectToProcessMap.get(payRequest.Project__c);
                    if (payRequest.External_Id__c == null
                            && project.PaytoStateAdmin__c == ALS_CONSTANTS.Picklist_Yes
                            && payRequest.Allow_Admin_Payment__c == true
                            && !Approval.isLocked(payRequest.Id)) {
                        //payRequest.TotalAdminShareAmount__c = project.AvailableAdminAmount__c;
                        payRequest.TotalAdminShareAmount__c = project.Net_Admin_Amount_Available__c.setScale(2,system.RoundingMode.DOWN);
                        //Updated the code for Ticket - 370 - End
                        prListToUpdate.add(payRequest);
                    }
                    else if (payRequest.External_Id__c == null
                            && (payRequest.Allow_Admin_Payment__c == false ||  project.PaytoStateAdmin__c == ALS_CONSTANTS.Picklist_No)
                            && !Approval.isLocked(payRequest.Id)) {
                        payRequest.TotalAdminShareAmount__c = 0 ;
                        prListToUpdate.add(payRequest);
                    }
                }
                //update prListToUpdate;

                Database.SaveResult[] results = Database.update(prListToUpdate, false);
                Integer count = 0;
                for (Database.SaveResult result : results) {
                    if (!result.isSuccess()) {
                        for (Database.Error err : result.getErrors()) {
                            Id id= prListToUpdate[count].Project__c;
                            Trigger.newMap.get(id).addError(err.message);
                            count++;
                        }
                    }
                }
            }
        }
    }

    //To update "State and Federal Amounts" Of Payment Request, If in Project some specific Fields are changing.....
    private void updateStateCostShareAndFederalCostShareOfPaymentRequest(){
        Set<Id> projectIds = new Set<Id>(); //Set collection to store the Project Ids...
        for (Project__c projectRecord : (List<Project__c>)Trigger.new) {
            Project__c OldProjectRecord = (Project__c)Trigger.oldMap.get(projectRecord.Id);
            //Condition to check for changes in the Project Field which can effect the related PR records...
            //To check the changes of Funding Source, Eligible for State Admin Share. Pay to State Admin, State Share , State Retention, State Admin..
            if (projectRecord.FundingSource__c != OldProjectRecord.FundingSource__c
                    || projectRecord.Total_Project_Award__c != OldProjectRecord.Total_Project_Award__c
                    || projectRecord.EligibleforStateAdminShare__c != OldProjectRecord.EligibleforStateAdminShare__c
                    || projectRecord.PaytoStateAdmin__c != OldProjectRecord.PaytoStateAdmin__c
                    || projectRecord.State_Share__c != OldProjectRecord.State_Share__c
                    || projectRecord.StateAdmin__c != OldProjectRecord.StateAdmin__c
                    || projectRecord.State_Retention__c != OldProjectRecord.State_Retention__c
                    || projectRecord.FEMA_Share__c != OldProjectRecord.FEMA_Share__c
                    || projectRecord.Federal_Retention__c != OldProjectRecord.Federal_Retention__c
                    //|| projectRecord.TotalAmountDisbursed__c != OldProjectRecord.TotalAmountDisbursed__c
                    //Updated the code for Ticket - 370 - Start
                    || projectRecord.Total_State_Amount_Approved__c != OldProjectRecord.Total_State_Amount_Approved__c
                    || projectRecord.Total_Federal_Amount_Approved__c != OldProjectRecord.Total_Federal_Amount_Approved__c
                    || projectRecord.AdminAmountDisbursed__c != OldProjectRecord.AdminAmountDisbursed__c
                    || projectRecord.TotalProjectStateAdminShare__c != OldProjectRecord.TotalProjectStateAdminShare__c) {

                              projectIds.add(projectRecord.Id); //Adding the Project record Id to collection....
            }
        }
        if (projectIds.size() > 0) {
            //Fetching the Project and its related PR records....
            List<Project__c> projectList = [SELECT Id, Name, External_Id__c, State_Share__c ,State_Retention__c, FEMA_Share__c,
                    Federal_Retention__c, Program_Name__r.Name, EligibleforStateAdminShare__c, TotalProjectStateAdminShare__c ,
                    PaytoStateAdmin__c,StateAdmin__c, FundingSource__c, AvailableAdminAmount__c, Total_State_Amount_Approved__c,
                    Total_Federal_Amount_Approved__c, Total_Admin_Amount_Approved__c , Net_Admin_Amount_Available__c,
                    (SELECT Id, Name, External_Id__c, Allow_Admin_Payment__c, Project__c, PaymentType__c, TotalAdminShareAmount__c, StateCostShare__c,
                            StateRetentionShare__c, StateEstimatedPaymentAmount__c, StateAdminShare__c, ExpenditurestoDate__c,
                            StateAmountDisbursed__c, FederalShareCost__c, FederalRetentionShare__c, FederalEstimatedPaymentAmount__c,
                            FederalAmountDisbursed__c FROM Payment_Requests__r WHERE External_Id__c = NULL) //toDo To add condition for External Id as null...
                    FROM Project__c WHERE Id IN : projectIds];

            //List to collect the PR record to Update....
            List<Payment_Request__c> PaymentRequestToUpdateList = new List<Payment_Request__c>();

            for (Project__c projectRecordToProcess : projectList) {
                for (Payment_Request__c PaymentToProcess : projectRecordToProcess.Payment_Requests__r) {
                    if (!Approval.isLocked(PaymentToProcess.Id) && PaymentToProcess.External_Id__c == null){
                        //Checking for null pointer exceptions...
                        Decimal expenditureToDate = PaymentToProcess.ExpenditurestoDate__c == null?0.00:PaymentToProcess.ExpenditurestoDate__c;
                        Decimal stateShare = projectRecordToProcess.State_Share__c == null?0.00:projectRecordToProcess.State_Share__c;
                        Decimal stateRetention = projectRecordToProcess.State_Retention__c == null?0.00:projectRecordToProcess.State_Retention__c;
                        Decimal stateAdminShare = projectRecordToProcess.StateAdmin__c == null?0.00:projectRecordToProcess.StateAdmin__c;
                        Decimal federalShare = projectRecordToProcess.FEMA_Share__c == null?0.00:projectRecordToProcess.FEMA_Share__c;
                        Decimal federalRetention = projectRecordToProcess.Federal_Retention__c == null?0.00:projectRecordToProcess.Federal_Retention__c;
                        Decimal federalAmountApprovedToDate = projectRecordToProcess.Total_Federal_Amount_Approved__c == null ? 0.00 : projectRecordToProcess.Total_Federal_Amount_Approved__c;
                        Decimal stateAmountApprovedToDate = projectRecordToProcess.Total_State_Amount_Approved__c == null ? 0.00 : projectRecordToProcess.Total_State_Amount_Approved__c;

                        /** Ticket - 969 - Start */
                        Decimal adminAmountApprovedToDate = projectRecordToProcess.Total_Admin_Amount_Approved__c == null ? 0.00 : projectRecordToProcess.Total_Admin_Amount_Approved__c;
                        Decimal totalAdminShareOfPr = PaymentToProcess.TotalAdminShareAmount__c == null ? 0.00 : PaymentToProcess.TotalAdminShareAmount__c;

PaymentToProcess.In_Review_State_Amount_Approved__c = stateAmountApprovedToDate?.setScale(2,system.RoundingMode.DOWN);
                        PaymentToProcess.In_Review_State_Share__c = stateShare?.setScale(2,system.RoundingMode.DOWN);
                        PaymentToProcess.In_Review_State_Retention__c = stateRetention?.setScale(2,system.RoundingMode.DOWN);

                        PaymentToProcess.In_Review_Federal_Amount_Approved__c = federalAmountApprovedToDate?.setScale(2,system.RoundingMode.DOWN);
                        PaymentToProcess.In_Review_FEMA_Share__c = federalShare?.setScale(2,system.RoundingMode.DOWN);
                        PaymentToProcess.In_Review_Federal_Retention__c = federalRetention?.setScale(2,system.RoundingMode.DOWN);

                        PaymentToProcess.In_Review_Admin_Amount_Approved__c = adminAmountApprovedToDate?.setScale(2,system.RoundingMode.DOWN);
                        PaymentToProcess.Review_Pending_Admin_Amount_Available__c = (projectRecordToProcess.Net_Admin_Amount_Available__c  == null ? 0.00 : projectRecordToProcess.Net_Admin_Amount_Available__c)?.setScale(2,system.RoundingMode.DOWN);

                        /*PaymentToProcess.InReview_State_and_Admin_Amount_Approved__c = (PaymentToProcess.In_Review_State_Amount_Approved__c
                                + PaymentToProcess.In_Review_Admin_Amount_Approved__c)?.setScale(2,system.RoundingMode.DOWN);
                        PaymentToProcess.InReview_State_and_Fed_Amount_Approved__c = (PaymentToProcess.In_Review_State_Amount_Approved__c
                                + PaymentToProcess.In_Review_Federal_Amount_Approved__c)?.setScale(2,system.RoundingMode.DOWN);
                        PaymentToProcess.In_Review_Total_Amount_Approved__c = (PaymentToProcess.In_Review_State_Amount_Approved__c
                                + PaymentToProcess.In_Review_Federal_Amount_Approved__c + PaymentToProcess.In_Review_Admin_Amount_Approved__c)?.setScale(2,system.RoundingMode.DOWN);*/

                        PaymentToProcess.Reviewed_Federal_Amount_Approved_to_Date__c = federalAmountApprovedToDate?.setScale(2,system.RoundingMode.DOWN);
                        PaymentToProcess.Reviewed_State_Amount_Approved_to_Date__c = stateAmountApprovedToDate?.setScale(2,system.RoundingMode.DOWN);
                        PaymentToProcess.Reviewed_Admin_Amount_Approved_to_Date__c = adminAmountApprovedToDate?.setScale(2,system.RoundingMode.DOWN);
                        PaymentToProcess.Reviewed_State_and_Admin_Amount_Approved__c = (PaymentToProcess.Reviewed_State_Amount_Approved_to_Date__c
                                + PaymentToProcess.Reviewed_Admin_Amount_Approved_to_Date__c)?.setScale(2,system.RoundingMode.DOWN);
                        PaymentToProcess.Reviewed_State_and_Fed_Amount_Approved__c = (PaymentToProcess.Reviewed_Federal_Amount_Approved_to_Date__c
                                + PaymentToProcess.Reviewed_State_Amount_Approved_to_Date__c)?.setScale(2,system.RoundingMode.DOWN);
                        PaymentToProcess.Reviewed_Total_Amount_Approved__c = (PaymentToProcess.Reviewed_Federal_Amount_Approved_to_Date__c
                                + PaymentToProcess.Reviewed_State_Amount_Approved_to_Date__c
                                + PaymentToProcess.Reviewed_Admin_Amount_Approved_to_Date__c)?.setScale(2,system.RoundingMode.DOWN);
                        /** Ticket - 969 - End */

                        //Calculation for Admin Only Payment PR...
                        if (PaymentToProcess.ExpenditurestoDate__c == 0
                                && PaymentToProcess.Allow_Admin_Payment__c == true
                                && PaymentToProcess.PaymentType__c == ALS_CONSTANTS.PR_PaymentType_Reimbursement) {
                            //Updating State Estimated Payment Amount value with Total Admin Share Amount of the PR...
                            PaymentToProcess.StateEstimatedPaymentAmount__c = PaymentToProcess.TotalAdminShareAmount__c;

                            //Setting remaining field value as 0...
                            PaymentToProcess.StateCostShare__c = 0;
                            PaymentToProcess.StateRetentionShare__c = 0;
                            PaymentToProcess.FederalShareCost__c = 0;
                            PaymentToProcess.FederalRetentionShare__c = 0;
                            PaymentToProcess.FederalEstimatedPaymentAmount__c = 0;
                        }
                        else if (PaymentToProcess.PaymentType__c != ALS_CONSTANTS.PR_PaymentType_FinalPayment
                                && PaymentToProcess.PaymentType__c != ALS_CONSTANTS.PR_PaymentType_Offset
                                && PaymentToProcess.PaymentType__c != ALS_CONSTANTS.PR_PaymentType_ReturnedProjectPayment) {
                            //Calculating State Share of PR...
                            if (projectRecordToProcess.FundingSource__c == ALS_CONSTANTS.Project_FundingSource_StateOnly
                                    || projectRecordToProcess.FundingSource__c == ALS_CONSTANTS.Project_FundingSource_FederalAndState) {
                                //State Cost Share...
                                PaymentToProcess.StateCostShare__c = ((expenditureToDate * stateShare)/100).setScale(2,system.RoundingMode.DOWN);
                                //State retention Share....
                                PaymentToProcess.StateRetentionShare__c = ((PaymentToProcess.StateCostShare__c * stateRetention)/100).setScale(2,system.RoundingMode.DOWN);
                                //State Admin Share....
                                if (projectRecordToProcess.PaytoStateAdmin__c == ALS_CONSTANTS.Picklist_Yes ) {
                                    PaymentToProcess.StateAdminShare__c = ((PaymentToProcess.StateCostShare__c * stateAdminShare)/100).setScale(2,system.RoundingMode.DOWN);
                                }

                                //State Estimated Payment Amount....
                                PaymentToProcess.StateEstimatedPaymentAmount__c = (PaymentToProcess.StateCostShare__c - PaymentToProcess.StateRetentionShare__c
                                        - stateAmountApprovedToDate + totalAdminShareOfPr).setScale(2,system.RoundingMode.DOWN);
                            }
                            else {
                                PaymentToProcess.StateCostShare__c = 0;
                                PaymentToProcess.StateRetentionShare__c = 0;
                                PaymentToProcess.StateAdminShare__c = 0;
                                PaymentToProcess.StateEstimatedPaymentAmount__c = 0;
                                PaymentToProcess.ApprovedStatePaymentAmount__c = 0;
                            }

                            //Calculating Federal Shares...
                            if (projectRecordToProcess.FundingSource__c == ALS_CONSTANTS.Project_FundingSource_FederalOnly || projectRecordToProcess.FundingSource__c == ALS_CONSTANTS.Project_FundingSource_FederalAndState) {
                                //Calculating "Federal Cost Share"...
                                PaymentToProcess.FederalShareCost__c = ((PaymentToProcess.ExpenditurestoDate__c * federalShare)/100).setScale(2,system.RoundingMode.DOWN);
                                //Calculating "Federal Retention Share"..
                                PaymentToProcess.FederalRetentionShare__c = ((PaymentToProcess.FederalShareCost__c * federalRetention)/100).setScale(2,system.RoundingMode.DOWN);
                                //Calculating "Federal Estimated Payment Amount"....
                                PaymentToProcess.FederalEstimatedPaymentAmount__c = (PaymentToProcess.FederalShareCost__c
                                        - PaymentToProcess.FederalRetentionShare__c - federalAmountApprovedToDate).setScale(2,system.RoundingMode.DOWN);
                            }
                            else {
                                PaymentToProcess.FederalShareCost__c = 0;
                                PaymentToProcess.FederalRetentionShare__c = 0;
                                PaymentToProcess.FederalEstimatedPaymentAmount__c = 0;
                                PaymentToProcess.ApprovedFederalPaymentAmount__c = 0;
                            }
                        }
                        PaymentRequestToUpdateList.add(PaymentToProcess); //Adding the PR to collection for Updating...
                    }
                }
            }
            //Updated the code for Ticket - 370 - End

            if(PaymentRequestToUpdateList.size() > 0) {
                //update PaymentRequestToUpdateList; //Updating the PR records...
                Database.SaveResult[] results = Database.update(PaymentRequestToUpdateList, false);
                Integer count = 0;
                for (Database.SaveResult result : results) {
                    if (!result.isSuccess()) {
                        for (Database.Error err : result.getErrors()) {
                            Id id= PaymentRequestToUpdateList[count].Project__c;
                            Trigger.newMap.get(id).addError(err.message);
                            count++;
                        }
                    }
                }
            }
        }
    }

    //If a Payment Request is created for the Proejct, then user cannot change the Funding Source...
    //User should not be able to change the "Funding opportunity" of the Project...
    private void preventChangingFundingOpportunity() {
        Map<Id, Project__c> idToProjectMap = new Map<Id, Project__c>(); //To collect the Project record for Processing.....
        Set<Id> currentUserIds = new Set<Id>(); //To collect the current user Id...
        for(Project__c projectRecordToProcess : (List<Project__c>)Trigger.new ){
            Project__c oldProjectRecord = (Project__c)Trigger.oldMap.get(projectRecordToProcess.Id); //Fetching the old Project record from Trigger.oldMap collection....
            //Condition to check if the Disaster Grant/Funding Source has been changed on the Project.....
            if (projectRecordToProcess.Funding_Opportunity_Name__c != oldProjectRecord.Funding_Opportunity_Name__c) {
                idToProjectMap.put(projectRecordToProcess.Id, projectRecordToProcess); //Adding the Project record to collection for processing....
                currentUserIds.add(UserInfo.getUserId()); //Adding the current user Id to collection....
            }
        }
        if (idToProjectMap.size() > 0) {
            //Fetching the user Information....
            Map<Id,User> currentUserInfo = new Map<Id,User>([SELECT Id,Name, ProfileId, Profile.Name FROM User WHERE Id IN:currentUserIds]);
            //Fetching the Project and its related PR info...
            Map<Id, Project__c> projectMap = new Map<Id, Project__c>([SELECT Id, Name, (SELECT Id, Name FROM Payment_Requests__r) FROM Project__c WHERE Id IN : idToProjectMap.keySet()]);

            for(Project__c projectRecordToProcess : idToProjectMap.values()){ //Itearting the Projects to process collection....
                User currentUser = currentUserInfo.get(UserInfo.getUserId()); //Fetching the current user info from Map collection....
                Project__c oldProejctRecord = (Project__c)Trigger.oldMap.get(projectRecordToProcess.Id); //Fetching the old Project info from Trigger.oldMap collection....
                Project__c projectRecordToCompare = projectMap.get(projectRecordToProcess.Id); //Fetching the Project reocrd from map collection...
                //Condition to check if the Funding Opportunity has been changed on the Project.....
                if(oldProejctRecord.Funding_Opportunity_Name__c != null
                        && projectRecordToProcess.Funding_Opportunity_Name__c != oldProejctRecord.Funding_Opportunity_Name__c
                        && currentUser.Profile.Name != ALS_CONSTANTS.ProfileName_SystemAdmin){
                    projectRecordToProcess.addError('You cannot change "Funding Opportunity" of the Project.');
                }
            }
        }
    }

    /*********************************************
	* Method Name : customRollUpOfAmountOnIncidentForInsertAndUpdate
	* Called From Method : AfterInsert, AfterUpdate, AfterUndelete
	* Author : Ricky
	* Inputs : -
	* Description: This method is used to Roll up the Projects Amount on Incident whenever a Project is created/Updated/Undeleted. */
    /*private void customRollUpOfAmountOnIncidentForInsertAndUpdate() {
        Set<Id> incidentIds = new Set<Id>(); //To collect the Incident Ids...
        if (Trigger.isInsert || Trigger.isUndelete) { //Condition to check if the record is getting Inserted/Undeleted....
            for(Project__c projectRecord : (List<Project__c>) Trigger.new) {
                if (projectRecord.Incident_Name__c != null) {
                    incidentIds.add(projectRecord.Incident_Name__c);
                }
            }
        }
        if (Trigger.isUpdate) { //Condition to check if the record is getting Updated....
            for(Project__c projectRecord : (List<Project__c>) Trigger.new) {
                Project__c oldRecord = (Project__c) Trigger.oldMap.get(projectRecord.Id);
                //Condition to check Project record field changes Which needs to be Roll up on Incident record.
                if (projectRecord.Incident_Name__c != oldRecord.Incident_Name__c
                        || projectRecord.Total_Project_Award__c != oldRecord.Total_Project_Award__c
                        || projectRecord.TotalAmountDisbursed__c != oldRecord.TotalAmountDisbursed__c
                        || projectRecord.AmountAvailable__c != oldRecord.AmountAvailable__c
                        || projectRecord.State_Project_Award__c != oldRecord.State_Project_Award__c
                        || projectRecord.Federal_Project_Award__c != oldRecord.Federal_Project_Award__c
                        || projectRecord.TotalProjectFederalAward__c != oldRecord.TotalProjectFederalAward__c
                        || projectRecord.TotalProjectStateAward__c != oldRecord.TotalProjectStateAward__c
                        || projectRecord.TotalProjectStateAdminShare__c != oldRecord.TotalProjectStateAdminShare__c
                        || projectRecord.TotalProjectLocalAward__c != oldRecord.TotalProjectLocalAward__c
                        || projectRecord.Total_Federal_Amount_Requested__c != oldRecord.Total_Federal_Amount_Requested__c
                        || projectRecord.Total_State_Amount_Requested__c != oldRecord.Total_State_Amount_Requested__c
                        || projectRecord.Total_Admin_Amount_Requested__c != oldRecord.Total_Admin_Amount_Requested__c
                        || projectRecord.Total_Federal_Amount_Approved__c != oldRecord.Total_Federal_Amount_Approved__c
                        || projectRecord.Total_State_Amount_Approved__c != oldRecord.Total_State_Amount_Approved__c
                        || projectRecord.Total_Admin_Amount_Approved__c != oldRecord.Total_Admin_Amount_Approved__c
                        || projectRecord.Federal_Retention_To_Date__c != oldRecord.Federal_Retention_To_Date__c
                        || projectRecord.State_Retention_To_Date__c != oldRecord.State_Retention_To_Date__c
                        || projectRecord.Net_Federal_Amount_Available__c != oldRecord.Net_Federal_Amount_Available__c
                        || projectRecord.Net_State_Amount_Available__c != oldRecord.Net_State_Amount_Available__c
                        || (projectRecord.Stage__c != oldRecord.Stage__c
                            && (projectRecord.Stage__c == ALS_CONSTANTS.Project_Stage_Withdrawn
                                || oldRecord.Stage__c == ALS_CONSTANTS.Project_Stage_Withdrawn))) {
                    if (projectRecord.Incident_Name__c != null) {
                        incidentIds.add(projectRecord.Incident_Name__c);
                    }
                    if (projectRecord.Incident_Name__c != oldRecord.Incident_Name__c
                            && oldRecord.Incident_Name__c != null) {
                        incidentIds.add(oldRecord.Incident_Name__c);
                    }
                }
            }
        }
        if (incidentIds.size() > 0) {
            List<Incident__c> incidentList = [SELECT Id, Total_Net_Incident_Amount_Available__c, Total_Incident_Amount_Awarded__c, Total_Incident_Amount_Disbursed__c,
                    Total_Incident_Amount_Available__c, Total_Local_Share_Amount_Obligated__c, Total_Admin_Amount_Requested__c,
                    Total_State_Amount_Requested__c, Total_Federal_Amount_Requested__c, Total_Admin_Amount_Approved__c,
                    Total_State_Amount_Approved__c, Total_Federal_Amount_Approved__c, Net_Federal_Amount_Available__c,
                    Net_State_Amount_Available__c, Net_Admin_Amount_Available__c FROM Incident__c  WHERE Id IN : incidentIds];
            List<AggregateResult> resultList = [SELECT Incident_Name__c, SUM(Total_Project_Award__c)totalAwardedAmount,
                    SUM(TotalAmountDisbursed__c)totalDisbursedAmount, SUM(AmountAvailable__c)totalAvailableAmount, SUM(TotalProjectLocalAward__c)totalProjectLocalAward,
                    SUM(Total_Admin_Amount_Requested__c)totalAdminAmountRequested, SUM(Total_State_Amount_Requested__c)totalStateAmountRequested,
                    SUM(Total_Federal_Amount_Requested__c)totalFederalAmountRequested, SUM(Total_Admin_Amount_Approved__c)totalAdminAmountApproved,
                    SUM(Total_State_Amount_Approved__c)totalStateAmountApproved, SUM(Total_Federal_Amount_Approved__c)totalFederalAmountApproved,
                    SUM(Net_Federal_Amount_Available__c)netFederalAmountAvailable, SUM(Net_State_Amount_Available__c)netStateAmountAvailable,
                    SUM(Net_Admin_Amount_Available__c)netAdminAmountAvailable, SUM(Total_Net_Amount_Available__c)totalNetAmountAvailable FROM Project__c
                    WHERE Incident_Name__c IN  : incidentIds AND Stage__c !=: ALS_CONSTANTS.Project_Stage_Withdrawn GROUP BY Incident_Name__c];
            //if (resultList.size() > 0) {
                Map<Id, AggregateResult> incidentIdToAggregateResult = new Map<Id, AggregateResult>();
                if (resultList.size() > 0) {
                    for (AggregateResult result : resultList) {
                        Id incidentId = (Id) result.get('Incident_Name__c');
                        incidentIdToAggregateResult.put(incidentId, result);
                    }
                }
                for (Incident__c incident : incidentList) {
                    AggregateResult result = incidentIdToAggregateResult?.get(incident.Id);
                    Decimal totalAwardedAmount = (Decimal) result?.get('totalAwardedAmount');
                    Decimal totalDisbursedAmount = (Decimal) result?.get('totalDisbursedAmount');
                    Decimal totalAvailableAmount = (Decimal) result?.get('totalAvailableAmount');

                    Decimal totalProjectLocalAward = (Decimal) result?.get('totalProjectLocalAward');
                    Decimal totalAdminAmountRequested = (Decimal) result?.get('totalAdminAmountRequested');
                    Decimal totalStateAmountRequested = (Decimal) result?.get('totalStateAmountRequested');
                    Decimal totalFederalAmountRequested = (Decimal) result?.get('totalFederalAmountRequested');
                    Decimal totalAdminAmountApproved = (Decimal) result?.get('totalAdminAmountApproved');
                    Decimal totalStateAmountApproved = (Decimal) result?.get('totalStateAmountApproved');
                    Decimal totalFederalAmountApproved = (Decimal) result?.get('totalFederalAmountApproved');

                    Decimal totalNetAmountAvailable = (Decimal) result?.get('totalNetAmountAvailable');
                    Decimal netFederalAmountAvailable = (Decimal) result?.get('netFederalAmountAvailable');
                    Decimal netStateAmountAvailable = (Decimal) result?.get('netStateAmountAvailable');
                    Decimal netAdminAmountAvailable = (Decimal) result?.get('netAdminAmountAvailable');

                    //Updating the values in Incident record...
                    incident.Total_Incident_Amount_Awarded__c = (totalAwardedAmount == null? 0.00 : totalAwardedAmount).setScale(2,system.RoundingMode.DOWN);
                    incident.Total_Incident_Amount_Disbursed__c = (totalDisbursedAmount == null? 0.00 : totalDisbursedAmount).setScale(2,system.RoundingMode.DOWN);
                    incident.Total_Incident_Amount_Available__c = (totalAvailableAmount == null? 0.00 : totalAvailableAmount).setScale(2,system.RoundingMode.DOWN);
                    incident.Total_Local_Share_Amount_Obligated__c = (totalProjectLocalAward == null? 0.00 : totalProjectLocalAward).setScale(2,system.RoundingMode.DOWN);

                    incident.Total_Federal_Amount_Requested__c = (totalFederalAmountRequested == null? 0.00 : totalFederalAmountRequested).setScale(2,system.RoundingMode.DOWN);
                    incident.Total_State_Amount_Requested__c = (totalStateAmountRequested == null? 0.00 : totalStateAmountRequested).setScale(2,system.RoundingMode.DOWN);
                    incident.Total_Admin_Amount_Requested__c = (totalAdminAmountRequested == null? 0.00 : totalAdminAmountRequested).setScale(2,system.RoundingMode.DOWN);
                    incident.Total_Federal_Amount_Approved__c = (totalFederalAmountApproved == null? 0.00 : totalFederalAmountApproved).setScale(2,system.RoundingMode.DOWN);
                    incident.Total_State_Amount_Approved__c = (totalStateAmountApproved == null? 0.00 : totalStateAmountApproved).setScale(2,system.RoundingMode.DOWN);
                    incident.Total_Admin_Amount_Approved__c = (totalAdminAmountApproved == null? 0.00 : totalAdminAmountApproved).setScale(2,system.RoundingMode.DOWN);

                    incident.Total_Net_Incident_Amount_Available__c	 = (totalNetAmountAvailable == null? 0.00 : totalNetAmountAvailable).setScale(2,system.RoundingMode.DOWN);
                    incident.Net_Federal_Amount_Available__c = (netFederalAmountAvailable == null? 0.00 : netFederalAmountAvailable).setScale(2,system.RoundingMode.DOWN);
                    incident.Net_State_Amount_Available__c = (netStateAmountAvailable == null? 0.00 : netStateAmountAvailable).setScale(2,system.RoundingMode.DOWN);
                    incident.Net_Admin_Amount_Available__c = (netAdminAmountAvailable == null? 0.00 : netAdminAmountAvailable).setScale(2,system.RoundingMode.DOWN);
                }
                update incidentList;
            //}
        }
    }*/

    private void customRollUpOfAmountOnIncidentForInsertAndUpdateNew () {
        Set<Id> incidentIds = new Set<Id>(); //To collect the Incident Ids...
        if (Trigger.isInsert || Trigger.isUndelete) { //Condition to check if the record is getting Inserted/Undeleted....
            for(Project__c projectRecord : (List<Project__c>) Trigger.new) {
                if (projectRecord.Incident_Name__c != null
                        && projectRecord.Total_Project_Award__c != null
                        && projectRecord.Total_Project_Award__c != 0) {
                    incidentIds.add(projectRecord.Incident_Name__c);
    }
            }
        }
        if (Trigger.isUpdate) { //Condition to check if the record is getting Updated....
            for(Project__c projectRecord : (List<Project__c>) Trigger.new) {
                Project__c oldRecord = (Project__c) Trigger.oldMap.get(projectRecord.Id);
                //Condition to check Project record field changes Which needs to be Roll up on Incident record.
                if (projectRecord.Incident_Name__c != oldRecord.Incident_Name__c
                        || projectRecord.Total_Project_Award__c != oldRecord.Total_Project_Award__c
                        || projectRecord.State_Project_Award__c != oldRecord.State_Project_Award__c
                        || projectRecord.Federal_Project_Award__c != oldRecord.Federal_Project_Award__c
                        || projectRecord.TotalProjectStateAdminShare__c != oldRecord.TotalProjectStateAdminShare__c
                        || projectRecord.TotalProjectLocalAward__c != oldRecord.TotalProjectLocalAward__c
                        || projectRecord.Total_Federal_Amount_Requested__c != oldRecord.Total_Federal_Amount_Requested__c
                        || projectRecord.Total_State_Amount_Requested__c != oldRecord.Total_State_Amount_Requested__c
                        || projectRecord.Total_Admin_Amount_Requested__c != oldRecord.Total_Admin_Amount_Requested__c
                        || projectRecord.Total_Federal_Amount_Approved__c != oldRecord.Total_Federal_Amount_Approved__c
                        || projectRecord.Total_State_Amount_Approved__c != oldRecord.Total_State_Amount_Approved__c
                        || projectRecord.Total_Admin_Amount_Approved__c != oldRecord.Total_Admin_Amount_Approved__c
                        || projectRecord.Federal_Retention_To_Date__c != oldRecord.Federal_Retention_To_Date__c
                        || projectRecord.State_Retention_To_Date__c != oldRecord.State_Retention_To_Date__c
                        || projectRecord.Net_Federal_Amount_Available__c != oldRecord.Net_Federal_Amount_Available__c
                        || projectRecord.Net_State_Amount_Available__c != oldRecord.Net_State_Amount_Available__c
                        || projectRecord.Net_Admin_Amount_Available__c != oldRecord.Net_Admin_Amount_Available__c
                        || (projectRecord.Stage__c != oldRecord.Stage__c
                        && (projectRecord.Stage__c == ALS_CONSTANTS.Project_Stage_Withdrawn
                        || oldRecord.Stage__c == ALS_CONSTANTS.Project_Stage_Withdrawn))) {
                    if (projectRecord.Incident_Name__c != null) {
                        incidentIds.add(projectRecord.Incident_Name__c);
                    }
                    if (projectRecord.Incident_Name__c != oldRecord.Incident_Name__c
                            && oldRecord.Incident_Name__c != null) {
                        incidentIds.add(oldRecord.Incident_Name__c);
                    }
                }
            }
        }
        if (incidentIds.size() > 0) {
            List<AggregateResult> resultList = [SELECT Incident_Name__c, SUM(Total_Project_Award__c)totalAwardedAmount,
                    SUM(Total_Amount_Approved__c)totalDisbursedAmount, SUM(Total_Net_Amount_Available__c)totalAvailableAmount, SUM(TotalProjectLocalAward__c)totalProjectLocalAward,
                    SUM(Total_Admin_Amount_Requested__c)totalAdminAmountRequested, SUM(Total_State_Amount_Requested__c)totalStateAmountRequested,
                    SUM(Total_Federal_Amount_Requested__c)totalFederalAmountRequested, SUM(Total_Admin_Amount_Approved__c)totalAdminAmountApproved,
                    SUM(Total_State_Amount_Approved__c)totalStateAmountApproved, SUM(Total_Federal_Amount_Approved__c)totalFederalAmountApproved,
                    SUM(Net_Federal_Amount_Available__c)netFederalAmountAvailable, SUM(Net_State_Amount_Available__c)netStateAmountAvailable,
                    SUM(Net_Admin_Amount_Available__c)netAdminAmountAvailable, SUM(Total_Net_Amount_Available__c)totalNetAmountAvailable FROM Project__c
            WHERE Incident_Name__c IN  : incidentIds AND Stage__c !=: ALS_CONSTANTS.Project_Stage_Withdrawn GROUP BY Incident_Name__c];
            //if (resultList.size() > 0) {
            Map<Id, AggregateResult> incidentIdToAggregateResult = new Map<Id, AggregateResult>();
            List<Incident__c> incidentToUpdateList = new List<Incident__c>();
            if (resultList.size() > 0) {
                for (AggregateResult result : resultList) {
                    Id incidentId = (Id) result.get('Incident_Name__c');
                    Incident__c incident = new Incident__c();
                    incident.Id = incidentId;

                    //Fetching the values from Aggregate result record.
                    Decimal totalAwardedAmount = (Decimal) result?.get('totalAwardedAmount');
                    Decimal totalDisbursedAmount = (Decimal) result?.get('totalDisbursedAmount');
                    Decimal totalAvailableAmount = (Decimal) result?.get('totalAvailableAmount');

                    Decimal totalProjectLocalAward = (Decimal) result?.get('totalProjectLocalAward');
                    Decimal totalAdminAmountRequested = (Decimal) result?.get('totalAdminAmountRequested');
                    Decimal totalStateAmountRequested = (Decimal) result?.get('totalStateAmountRequested');
                    Decimal totalFederalAmountRequested = (Decimal) result?.get('totalFederalAmountRequested');
                    Decimal totalAdminAmountApproved = (Decimal) result?.get('totalAdminAmountApproved');
                    Decimal totalStateAmountApproved = (Decimal) result?.get('totalStateAmountApproved');
                    Decimal totalFederalAmountApproved = (Decimal) result?.get('totalFederalAmountApproved');

                    Decimal totalNetAmountAvailable = (Decimal) result?.get('totalNetAmountAvailable');
                    Decimal netFederalAmountAvailable = (Decimal) result?.get('netFederalAmountAvailable');
                    Decimal netStateAmountAvailable = (Decimal) result?.get('netStateAmountAvailable');
                    Decimal netAdminAmountAvailable = (Decimal) result?.get('netAdminAmountAvailable');

                    //Updating the values in Incident record...
                    incident.Total_Incident_Amount_Awarded__c = (totalAwardedAmount == null? 0.00 : totalAwardedAmount).setScale(2,system.RoundingMode.DOWN);
                    incident.Total_Incident_Amount_Disbursed__c = (totalDisbursedAmount == null? 0.00 : totalDisbursedAmount).setScale(2,system.RoundingMode.DOWN);
                    incident.Total_Incident_Amount_Available__c = (totalAvailableAmount == null? 0.00 : totalAvailableAmount).setScale(2,system.RoundingMode.DOWN);
                    incident.Total_Local_Share_Amount_Obligated__c = (totalProjectLocalAward == null? 0.00 : totalProjectLocalAward).setScale(2,system.RoundingMode.DOWN);

                    incident.Total_Federal_Amount_Requested__c = (totalFederalAmountRequested == null? 0.00 : totalFederalAmountRequested).setScale(2,system.RoundingMode.DOWN);
                    incident.Total_State_Amount_Requested__c = (totalStateAmountRequested == null? 0.00 : totalStateAmountRequested).setScale(2,system.RoundingMode.DOWN);
                    incident.Total_Admin_Amount_Requested__c = (totalAdminAmountRequested == null? 0.00 : totalAdminAmountRequested).setScale(2,system.RoundingMode.DOWN);
                    incident.Total_Federal_Amount_Approved__c = (totalFederalAmountApproved == null? 0.00 : totalFederalAmountApproved).setScale(2,system.RoundingMode.DOWN);
                    incident.Total_State_Amount_Approved__c = (totalStateAmountApproved == null? 0.00 : totalStateAmountApproved).setScale(2,system.RoundingMode.DOWN);
                    incident.Total_Admin_Amount_Approved__c = (totalAdminAmountApproved == null? 0.00 : totalAdminAmountApproved).setScale(2,system.RoundingMode.DOWN);

                    incident.Total_Net_Incident_Amount_Available__c	 = (totalNetAmountAvailable == null? 0.00 : totalNetAmountAvailable).setScale(2,system.RoundingMode.DOWN);
                    incident.Net_Federal_Amount_Available__c = (netFederalAmountAvailable == null? 0.00 : netFederalAmountAvailable).setScale(2,system.RoundingMode.DOWN);
                    incident.Net_State_Amount_Available__c = (netStateAmountAvailable == null? 0.00 : netStateAmountAvailable).setScale(2,system.RoundingMode.DOWN);
                    incident.Net_Admin_Amount_Available__c = (netAdminAmountAvailable == null? 0.00 : netAdminAmountAvailable).setScale(2,system.RoundingMode.DOWN);

                    incidentToUpdateList.add(incident);
                }
            }
            if (incidentToUpdateList?.size() > 0) {
                update incidentToUpdateList;
            }
        }
    }

    /*********************************************
	* Method Name : customRollUpOfAmountOnIncidentForDelete
	* Called From Method : BeforeDelete
	* Author : Ricky
	* Inputs : -
	* Description: This method is used to Roll up the Projects Amount on Incident whenever a Project is Deleted. */
    private void customRollUpOfAmountOnIncidentForDelete() {
        Set<Id> incidentIds = new Set<Id>();
        Set<Id> projectIds =  new Set<Id>();
        for(Project__c projectRecord : (List<Project__c>) Trigger.old) {
            if (projectRecord.Incident_Name__c != null) {
                incidentIds.add(projectRecord.Incident_Name__c);
                projectIds.add(projectRecord.Id);
            }
        }
        if (incidentIds.size() > 0) {
            List<Incident__c> incidentList = [SELECT Id, Total_Incident_Amount_Awarded__c, Total_Incident_Amount_Disbursed__c,
                    Total_Incident_Amount_Available__c, Total_Local_Share_Amount_Obligated__c, Total_Admin_Amount_Requested__c,
                    Total_State_Amount_Requested__c, Total_Federal_Amount_Requested__c, Total_Admin_Amount_Approved__c,
                    Total_State_Amount_Approved__c, Total_Federal_Amount_Approved__c, Net_Federal_Amount_Available__c,
                    Net_State_Amount_Available__c, Net_Admin_Amount_Available__c, Total_Net_Incident_Amount_Available__c
                    FROM Incident__c  WHERE Id IN : incidentIds];
            List<AggregateResult> resultList = [SELECT Incident_Name__c, SUM(Total_Project_Award__c)totalAwardedAmount,
                    SUM(Total_Amount_Approved__c)totalDisbursedAmount, SUM(Total_Net_Amount_Available__c)totalAvailableAmount,
                    SUM(TotalProjectLocalAward__c)totalProjectLocalAward,
                    SUM(Total_Admin_Amount_Requested__c)totalAdminAmountRequested, SUM(Total_State_Amount_Requested__c)totalStateAmountRequested,
                    SUM(Total_Federal_Amount_Requested__c)totalFederalAmountRequested, SUM(Total_Admin_Amount_Approved__c)totalAdminAmountApproved,
                    SUM(Total_State_Amount_Approved__c)totalStateAmountApproved, SUM(Total_Federal_Amount_Approved__c)totalFederalAmountApproved,
                    SUM(Net_Federal_Amount_Available__c)netFederalAmountAvailable, SUM(Net_State_Amount_Available__c)netStateAmountAvailable,
                    SUM(Net_Admin_Amount_Available__c)netAdminAmountAvailable, SUM(Total_Net_Amount_Available__c)totalNetAmountAvailable
                    FROM Project__c WHERE Incident_Name__c IN  : incidentIds AND Id IN :projectIds
                    AND Stage__c !=: ALS_CONSTANTS.Project_Stage_Withdrawn GROUP BY Incident_Name__c];
                Map<Id, AggregateResult> incidentIdToAggregateResult = new Map<Id, AggregateResult>();
                if (resultList.size() > 0) {
                    for (AggregateResult result : resultList) {
                        Id incidentId = (Id) result.get('Incident_Name__c');
                        incidentIdToAggregateResult.put(incidentId, result);
                    }
                }
                for (Incident__c incident : incidentList) {
                    AggregateResult result = incidentIdToAggregateResult?.get(incident.Id);
                    Decimal totalAwardedAmount = (Decimal) result?.get('totalAwardedAmount');
                    Decimal totalDisbursedAmount = (Decimal) result?.get('totalDisbursedAmount');
                    Decimal totalAvailableAmount = (Decimal) result?.get('totalAvailableAmount');
                    Decimal totalProjectLocalAward = (Decimal) result?.get('totalProjectLocalAward');

                    Decimal totalAdminAmountRequested = (Decimal) result?.get('totalAdminAmountRequested');
                    Decimal totalStateAmountRequested = (Decimal) result?.get('totalStateAmountRequested');
                    Decimal totalFederalAmountRequested = (Decimal) result?.get('totalFederalAmountRequested');
                    Decimal totalAdminAmountApproved = (Decimal) result?.get('totalAdminAmountApproved');
                    Decimal totalStateAmountApproved = (Decimal) result?.get('totalStateAmountApproved');
                    Decimal totalFederalAmountApproved = (Decimal) result?.get('totalFederalAmountApproved');

                    Decimal totalNetAmountAvailable = (Decimal) result?.get('totalNetAmountAvailable');
                    Decimal netFederalAmountAvailable = (Decimal) result?.get('netFederalAmountAvailable');
                    Decimal netStateAmountAvailable = (Decimal) result?.get('netStateAmountAvailable');
                    Decimal netAdminAmountAvailable = (Decimal) result?.get('netAdminAmountAvailable');

                    //Updating the values in Incident record...
                    incident.Total_Incident_Amount_Awarded__c -= (totalAwardedAmount == null? 0.00 : totalAwardedAmount).setScale(2,system.RoundingMode.DOWN);
                    incident.Total_Incident_Amount_Disbursed__c -= (totalDisbursedAmount == null? 0.00 : totalDisbursedAmount).setScale(2,system.RoundingMode.DOWN);
                    incident.Total_Incident_Amount_Available__c -= (totalAvailableAmount == null? 0.00 : totalAvailableAmount).setScale(2,system.RoundingMode.DOWN);
                    incident.Total_Local_Share_Amount_Obligated__c -= (totalProjectLocalAward == null? 0.00 : totalProjectLocalAward).setScale(2,system.RoundingMode.DOWN);

                    incident.Total_Federal_Amount_Requested__c -= (totalFederalAmountRequested == null? 0.00 : totalFederalAmountRequested).setScale(2,system.RoundingMode.DOWN);
                    incident.Total_State_Amount_Requested__c -= (totalStateAmountRequested == null? 0.00 : totalStateAmountRequested).setScale(2,system.RoundingMode.DOWN);
                    incident.Total_Admin_Amount_Requested__c -= (totalAdminAmountRequested == null? 0.00 : totalAdminAmountRequested).setScale(2,system.RoundingMode.DOWN);
                    incident.Total_Federal_Amount_Approved__c -= (totalFederalAmountApproved == null? 0.00 : totalFederalAmountApproved).setScale(2,system.RoundingMode.DOWN);
                    incident.Total_State_Amount_Approved__c -= (totalStateAmountApproved == null? 0.00 : totalStateAmountApproved).setScale(2,system.RoundingMode.DOWN);
                    incident.Total_Admin_Amount_Approved__c -= (totalAdminAmountApproved == null? 0.00 : totalAdminAmountApproved).setScale(2,system.RoundingMode.DOWN);

                    incident.Total_Net_Incident_Amount_Available__c	 -= (totalNetAmountAvailable == null? 0.00 : totalNetAmountAvailable).setScale(2,system.RoundingMode.DOWN);
                    incident.Net_Federal_Amount_Available__c -= (netFederalAmountAvailable == null? 0.00 : netFederalAmountAvailable).setScale(2,system.RoundingMode.DOWN);
                    incident.Net_State_Amount_Available__c -= (netStateAmountAvailable == null? 0.00 : netStateAmountAvailable).setScale(2,system.RoundingMode.DOWN);
                    incident.Net_Admin_Amount_Available__c -= (netAdminAmountAvailable == null? 0.00 : netAdminAmountAvailable).setScale(2,system.RoundingMode.DOWN);
                }
                update incidentList;
            //}
        }
    }

    /*********************************************
	* Method Name : projectRetention
	* Called From Method : BeforeInsert, Before Update
	* Author : Ricky
	* Inputs : -
	* Description: This method is used to assign the retention value on Project whenever the Project is created/Updated. */
    private void projectRetention() {
        Set<Id> incidentIds = new Set<Id>(); //To collect the Incident Ids...
        Set<Id> programIds = new Set<Id>(); //To collect the Program Ids....
        Set<Id> subRecipientIds = new Set<Id>(); //To collect the Sub Recipient Ids....
        List<Project__c> projectListToProcess = new List<Project__c>(); //To collect the Project List to process.....
        if (Trigger.isInsert) {
            //projectListToProcess = Trigger.new;
            for(Project__c projectRec: (List<Project__c>)Trigger.new){
                if(projectRec.External_Id__c == null ||
                        (projectRec.External_Id__c != null && projectRec.Allow_System_Calculation__c == true)){
                    projectListToProcess.add(projectRec);
                }
            }
        }
        if (Trigger.isUpdate) {
            for (Project__c projectRecordToProcess : (List<Project__c>)Trigger.new){
                Project__c oldRecord = (Project__c)Trigger.oldMap.get(projectRecordToProcess.Id); //Fetching the Old Project record from Trigger.oldMap collection...
                //Condition to check the Project field changes which can effect the retention values....
                //Exclude records for ExternalID Not NUll
                if ((projectRecordToProcess.Program_Name__c != oldRecord.Program_Name__c
                        || projectRecordToProcess.Incident_Name__c != oldRecord.Incident_Name__c
                        || projectRecordToProcess.Percent_Complete__c != oldRecord.Percent_Complete__c
                        || projectRecordToProcess.FundingSource__c != oldRecord.FundingSource__c
                        || projectRecordToProcess.State_Share__c != oldRecord.State_Share__c
                        || projectRecordToProcess.FEMA_Share__c != oldRecord.FEMA_Share__c
                        || projectRecordToProcess.Total_Project_Award__c != oldRecord.Total_Project_Award__c
                        || projectRecordToProcess.Damage_Category__c != oldRecord.Damage_Category__c
                        || projectRecordToProcess.Obligating_Sub_Recipient__c != oldRecord.Obligating_Sub_Recipient__c
                        || projectRecordToProcess.Allow_System_Calculation__c != oldRecord.Allow_System_Calculation__c)
                        && (projectRecordToProcess.External_Id__c == null ||
                        (projectRecordToProcess.External_Id__c != null && projectRecordToProcess.Allow_System_Calculation__c == true))) {

                    projectListToProcess.add(projectRecordToProcess); //Adding the Project record to collection for processing....
                }
            }
        }

        if (projectListToProcess.size() > 0) {
            for (Project__c projectRecordToProcess : projectListToProcess) { //Iterating the Project to process list.....
                subRecipientIds.add(projectRecordToProcess.Obligating_Sub_Recipient__c); //Adding the Sub Recipient Id to collection.....
                if (projectRecordToProcess.Program_Name__c != null) { //Condition to check if the Program field in not null.....
                    programIds.add(projectRecordToProcess.Program_Name__c); //Adding the Program Id to collection....
                }
                if (projectRecordToProcess.Incident_Name__c != null) { //Condition to check if the Program field in not null.....
                    incidentIds.add(projectRecordToProcess.Incident_Name__c); //Adding the Incident Id to collection....
                }
            }
            //Fetching the Sub Recipient Record Data....
            Map<Id, Account> idToAccountMap = new Map<Id, Account>([SELECT Id, Name ,Sub_Recipient_FIPS__c FROM Account
                                                    WHERE Id IN : subRecipientIds]);
            //Fetching Incident record data....
            Map<Id,Incident__c> incidentMap = new Map<Id,Incident__c>([SELECT Id, Name, Declaration_Number__c, Federal_Small_Project_Threshold__c,
                                                        State_Small_Project_Threshold__c FROM Incident__c WHERE Id IN : incidentIds]);
            //Fetching Program record data....
            Map<Id,Program__c> programMap = new Map<Id,Program__c>([SELECT Id, Name, Master_Label_Program_Name__c, Parent_Program__c,
                                                                    Parent_Program__r.Name, Parent_Program__r.Master_Label_Program_Name__c
                                                    FROM Program__c WHERE Id IN : programIds]);

            for (Project__c projectRecordToProcess : projectListToProcess) { //Iterating Project to process field....
                Account subRecipient = idToAccountMap.get(projectRecordToProcess.Obligating_Sub_Recipient__c); //Fetching Sub Recipient info from map collection....
                Program__c programToProcess = programMap.get(projectRecordToProcess.Program_Name__c); //Fetching Program info from map collection....
                Incident__c incidentToProcess = incidentMap.get(projectRecordToProcess.Incident_Name__c); //Fetching the Incident record from Map collection.....
                
                Decimal federalSmallProjectThreshold = incidentToProcess?.Federal_Small_Project_Threshold__c == null ? 0.00 : incidentToProcess?.Federal_Small_Project_Threshold__c;
                //updateWasEverLargeFieldOnProject(projectRecordToProcess, federalSmallProjectThreshold);

                /** Updated for Ticket No - 569 - Start */
                //Fetching Retention for "Cal OES" Sub Recipient...
                List<ALS_Cal_OES_FIPS__mdt> calOESFIPS = new List<ALS_Cal_OES_FIPS__mdt>();
                if(subRecipient?.Sub_Recipient_FIPS__c != null) {
                    calOESFIPS = [SELECT Id__c FROM ALS_Cal_OES_FIPS__mdt WHERE Type__c = 'FIPS'
                                                         AND Id__c = :subRecipient.Sub_Recipient_FIPS__c];
                }
                if (calOESFIPS?.size()>0) { //Condition to check if the FIPS Id of the Sub Recipient is Of Cal OES....
                    if (projectRecordToProcess.FundingSource__c == ALS_CONSTANTS.Project_FundingSource_FederalAndState 
                            || projectRecordToProcess.FundingSource__c == ALS_CONSTANTS.Project_FundingSource_FederalOnly) {
                        projectRecordToProcess.Federal_Retention__c = 0;
                    }
                    if (projectRecordToProcess.FundingSource__c == ALS_CONSTANTS.Project_FundingSource_FederalAndState 
                            || projectRecordToProcess.FundingSource__c == ALS_CONSTANTS.Project_FundingSource_StateOnly) {
                        projectRecordToProcess.State_Retention__c = 0;
                    }
                }
                /** Updated for Ticket No - 569 - End */
                //Retention for Damage Category "Z: Management Costs"...
                else if (projectRecordToProcess.Damage_Category__c != null
                        && projectRecordToProcess.Damage_Category__c.contains(ALS_CONSTANTS.Project_DamageCategory_ZManagement)) {
                    if (projectRecordToProcess.FundingSource__c == ALS_CONSTANTS.Project_FundingSource_FederalAndState
                            || projectRecordToProcess.FundingSource__c == ALS_CONSTANTS.Project_FundingSource_FederalOnly) {
                        projectRecordToProcess.Federal_Retention__c = 10;
                    }
                    else {
                        projectRecordToProcess.Federal_Retention__c = 0;
                    }
                    if (projectRecordToProcess.FundingSource__c == ALS_CONSTANTS.Project_FundingSource_FederalAndState
                            || projectRecordToProcess.FundingSource__c == ALS_CONSTANTS.Project_FundingSource_StateOnly) {
                        projectRecordToProcess.State_Retention__c = 10;
                    }
                    else {
                        projectRecordToProcess.State_Retention__c = 0;
                    }
                }
                //Retention for HMA Projects...
                else if (programToProcess?.Parent_Program__r.Master_Label_Program_Name__c == ALS_CONSTANTS.Program_HMA
                        && projectRecordToProcess.Percent_Complete__c == 100) {
                    projectRecordToProcess.Federal_Retention__c = 0;
                    projectRecordToProcess.State_Retention__c = 0;
                }
                else if (programToProcess?.Parent_Program__r.Master_Label_Program_Name__c == ALS_CONSTANTS.Program_HMA
                        && projectRecordToProcess.Percent_Complete__c < 100) {
                    if (projectRecordToProcess.FundingSource__c == ALS_CONSTANTS.Project_FundingSource_FederalAndState
                            || projectRecordToProcess.FundingSource__c == ALS_CONSTANTS.Project_FundingSource_FederalOnly) {
                        projectRecordToProcess.Federal_Retention__c = 10;
                    }
                    else {
                        projectRecordToProcess.Federal_Retention__c = 0;
                    }
                    if (projectRecordToProcess.FundingSource__c == ALS_CONSTANTS.Project_FundingSource_FederalAndState
                            || projectRecordToProcess.FundingSource__c == ALS_CONSTANTS.Project_FundingSource_StateOnly) {
                        projectRecordToProcess.State_Retention__c = 10;
                    }
                    else {
                        projectRecordToProcess.State_Retention__c = 0;
                    }
                }
                //Retention based on Large/Small Projects...
                else if (projectRecordToProcess.Incident_Name__c != null) {
                    //Calling another method to decide whether the Project is Small/Large....
                    //False indicates - Small Project and True indicate - Large Project.....
                    Boolean isLarge = isLargeProject(projectRecordToProcess, incidentToProcess);
                    //Retention Share for PA Federal Project ...
                    if (programToProcess?.Master_Label_Program_Name__c == ALS_CONSTANTS.Program_PA_Federal
                            && (projectRecordToProcess.FundingSource__c == ALS_CONSTANTS.Project_FundingSource_FederalAndState
                                || projectRecordToProcess.FundingSource__c == ALS_CONSTANTS.Project_FundingSource_FederalOnly)) {
                        //For Incident whose declaration Number is less than or equal to 4382 / greater than or equal to 4407....
                        if (incidentToProcess.Declaration_Number__c <= '4382'
                                || incidentToProcess.Declaration_Number__c >= '4407') {
                            if (isLarge == true && projectRecordToProcess.Percent_Complete__c < 100) {
                                projectRecordToProcess.Federal_Retention__c = 10;
                            }
                            else if (isLarge == false || (isLarge == true
                                    && projectRecordToProcess.Percent_Complete__c == 100)){
                                projectRecordToProcess.Federal_Retention__c = 0;
                            }
                        }
                    }
                    //Retention Share for CDAA State Only Project ...
                    else if (programToProcess?.Master_Label_Program_Name__c == ALS_CONSTANTS.Program_CDAA
                            && (projectRecordToProcess.FundingSource__c == ALS_CONSTANTS.Project_FundingSource_FederalAndState
                            || projectRecordToProcess.FundingSource__c == ALS_CONSTANTS.Project_FundingSource_StateOnly)) {
                        //For Incident whose declaration Number is less than or equal to 4382....
                        if (incidentToProcess.Declaration_Number__c <= '4382') {
                            if (projectRecordToProcess.Percent_Complete__c < 100){
                                projectRecordToProcess.State_Retention__c = 10;
                            }
                            else if (projectRecordToProcess.Percent_Complete__c == 100){
                                projectRecordToProcess.State_Retention__c = 0;
                            }
                        }
                        //For Incident whose declaration Number is greater than or equal to 4407....
                        else if (incidentToProcess.Declaration_Number__c >= '4407') {
                            if (isLarge == true && projectRecordToProcess.Percent_Complete__c == 100){
                                projectRecordToProcess.State_Retention__c = 0;
                            }
                            else if (isLarge == false
                                    || (projectRecordToProcess.Percent_Complete__c < 100 && isLarge == true)){
                                projectRecordToProcess.State_Retention__c = 10;
                            }
                        }
                    }
                }
            }
        }
    }

    //This method is used to decide whether the Project is Large/Small....
    /** Condition to check the Large Project is been chnage as per Requested by Client.
     * Code is been added to update the Was Ever Large Field on the Project as per the requirement from PA Project Closeout requirement. */
    private Boolean isLargeProject(Project__c project, Incident__c incident) {
        Decimal  totalProjectAward = project.Total_Project_Award__c == null ? 0.00 : project.Total_Project_Award__c;
        Decimal  federalProjectThreshold = incident.Federal_Small_Project_Threshold__c == null ? 0.00 : incident.Federal_Small_Project_Threshold__c;

        if(project.FundingSource__c == ALS_CONSTANTS.Project_FundingSource_StateOnly) {
            return true;
        }
        else if((project.FundingSource__c == ALS_CONSTANTS.Project_FundingSource_FederalAndState 
                    || project.FundingSource__c == ALS_CONSTANTS.Project_FundingSource_FederalOnly) 
                && totalProjectAward >= federalProjectThreshold) {
            return true;
        }
        else { 
            return false;
        }

        /*Decimal projectAwardState;
        Decimal projectAwardFederal;

        //Calculating Federal Project Award and State Project Award.....
        if (project.State_Share__c != null && project.Total_Project_Award__c != null) {
            projectAwardState = ((project.Total_Project_Award__c * project.State_Share__c)/100).setScale(2,system.RoundingMode.DOWN);
        }
        if (project.FEMA_Share__c != null && project.Total_Project_Award__c != null) {
            projectAwardFederal = ((project.Total_Project_Award__c * project.FEMA_Share__c)/100).setScale(2,system.RoundingMode.DOWN);
        }

        Boolean isLargeProject = false; //Variable to decide whether the Project is Large/Small...
        //Condition to check for Funding Source - "Federal and State" Project...
        if (project.FundingSource__c == ALS_CONSTANTS.Project_FundingSource_FederalAndState) {
            if (projectAwardState > incident.State_Small_Project_Threshold__c
                    && projectAwardFederal > incident.Federal_Small_Project_Threshold__c) {
                isLargeProject = true;
            }
            else {
                isLargeProject = false;
            }
        }
        //Condition to check for Funding Source - "Federal Only" Project...
        else if (project.FundingSource__c == ALS_CONSTANTS.Project_FundingSource_FederalOnly) {
            if (projectAwardFederal > incident.Federal_Small_Project_Threshold__c) {
                isLargeProject = true;
            }
            else {
                isLargeProject = false;
            }
        }
        //Condition to check for Funding Source - "State Only" Project...
        else if (project.FundingSource__c == ALS_CONSTANTS.Project_FundingSource_StateOnly) {
            if (projectAwardState > incident.State_Small_Project_Threshold__c) {
                isLargeProject = true;
            }
            else {
                isLargeProject = false;
            }
        }
        return isLargeProject; //Variable to return the value about Large/Small Project.... */
    }

    /*private void updateWasEverLargeFieldOnProject(Project__c project, Decimal federalSmallProjectThreshold) {
        Decimal  totalProjectAward = project.Total_Project_Award__c == null ? 0.00 : project.Total_Project_Award__c;
        Decimal  federalProjectThreshold = federalSmallProjectThreshold == null ? 0.00 : federalSmallProjectThreshold;

        if(project.FundingSource__c == ALS_CONSTANTS.Project_FundingSource_StateOnly) {
            project.Was_Ever_Large__c = true;
        }
        else if((project.FundingSource__c == ALS_CONSTANTS.Project_FundingSource_FederalAndState 
                    || project.FundingSource__c == ALS_CONSTANTS.Project_FundingSource_FederalOnly) 
                && totalProjectAward >= federalProjectThreshold 
                && project.Was_Ever_Large__c == false) {
            project.Was_Ever_Large__c = true;
        }
    }*/

    /*********************************************
	* Method Name : customRollUpOnIncidentSubRecipientSummary
	* Called From Method : AfterInsert, AfterUpdate, AfterUndelete
	* Author : Sushant
	* Inputs : -
	* Description: This method is used to update the Rollups from project to Incident Sub Recipient Summary record
	*               upon Insertion/Updation/Undeletion of updateTotalAdminShareAmountOfPaymentRequestProject. */
    /*private void customRollUpOnIncidentSubRecipientSummary() {
        List<Project__c> projectsToProcess = new List<Project__c>();
        List<Id> incidentId = new List<Id>();
        List<Id> accountId = new List<Id>();
        if (Trigger.isInsert || Trigger.isUndelete) {
            projectsToProcess = Trigger.new;
        }
        if (Trigger.isUpdate) {
            for (Project__c projectRecord : (List<Project__c>) Trigger.new) {
                Project__c oldRecord = (Project__c) Trigger.oldMap.get(projectRecord.Id);
                if (projectRecord.Incident_Name__c != null
                        && (projectRecord.Incident_Name__c != oldRecord.Incident_Name__c
                            || projectRecord.Incident_Subrecipient_Summary__c != oldRecord.Incident_Subrecipient_Summary__c
                            || projectRecord.AmountAvailable__c != oldRecord.AmountAvailable__c
                        || projectRecord.AvailableAdminAmount__c != oldRecord.AvailableAdminAmount__c
                            || projectRecord.Total_Project_Award__c != oldRecord.Total_Project_Award__c
                            || projectRecord.Federal_Project_Award__c != oldRecord.Federal_Project_Award__c
                            || projectRecord.State_Project_Award__c != oldRecord.State_Project_Award__c
                            || projectRecord.TotalProjectStateAdminShare__c != oldRecord.TotalProjectStateAdminShare__c
                            || projectRecord.Federal_Retention_To_Date__c != oldRecord.Federal_Retention_To_Date__c
                            || projectRecord.State_Retention_To_Date__c != oldRecord.State_Retention_To_Date__c
                        || (projectRecord.Stage__c != oldRecord.Stage__c &&
                            (projectRecord.Stage__c == ALS_CONSTANTS.Project_Stage_Withdrawn
                                    || oldRecord.Stage__c == ALS_CONSTANTS.Project_Stage_Withdrawn)))) {
                    projectsToProcess.add(projectRecord);
                }
            }
        }

        if (projectsToProcess?.size() > 0) {
        for(Project__c prj :projectsToProcess){
            if(prj.Incident_Name__c != null){
                incidentId.add(prj.Incident_Name__c);
                accountId.add(prj.Obligating_Sub_Recipient__c);
            }
        }
            if(incidentId.size() > 0 && accountId.size() >0 ) {

                List<AggregateResult> results = [SELECT Incident_Name__c,Obligating_Sub_Recipient__c ,
                        SUM(FederalAmountAvailable__c)FederalAmountAvailable,
                        SUM(StateAmountAvailable__c)StateAmountAvailable,
                        SUM(AvailableAdminAmount__c)AvailableAdminAmount,
                        SUM(Total_Project_Award__c)TotalProjectAward,
                        SUM(Federal_Project_Award__c)FederalProjectAward,
                        SUM(State_Project_Award__c)StateProjectAward,
                        SUM(TotalProjectStateAdminShare__c)StateAdminShare,
                        SUM(Federal_Retention_To_Date__c)FederalRetentionToDate,
                        SUM(State_Retention_To_Date__c)StateRetentionToDate
                FROM Project__c
                WHERE Incident_Name__c IN : incidentId
                AND Obligating_Sub_Recipient__c IN : accountId
                                                AND Stage__c !=: ALS_CONSTANTS.Project_Stage_Withdrawn
                                                GROUP BY Incident_Name__c,Obligating_Sub_Recipient__c ];
                List<Incident_Subrecipient_Stage__c> incidentSubrecipientStage =[SELECT Id,Incident__c,Account__c,Available_Federal_Amount__c,
                                                                                Available_State_Admin_Amount__c,Available_State_Amount__c
                                                                                FROM Incident_Subrecipient_Stage__c
                                                                                WHERE Account__c IN:accountId AND Incident__c IN:incidentId];

                Map<String,Incident_Subrecipient_Stage__c> mapIncidentSubIdToStageRecord = new Map<String,Incident_Subrecipient_Stage__c>();
               if(incidentSubrecipientStage.size() > 0){
                    for(Incident_Subrecipient_Stage__c incSubstage:incidentSubrecipientStage){
                        String key = (String)incSubstage.Incident__c + (String)incSubstage.Account__c;
                        mapIncidentSubIdToStageRecord.put(key,incSubstage)  ;
                    }
                }
                List<Incident_Subrecipient_Stage__c> stageRecordsToUpdate = new List<Incident_Subrecipient_Stage__c>();
                for(AggregateResult aggResult :results){
                    Id incidentIds = (Id)aggResult.get('Incident_Name__c');
                    Id subRecipientId = (Id)aggResult.get('Obligating_Sub_Recipient__c');
                    String key = (String)incidentIds + (String)subRecipientId;
                    Incident_Subrecipient_Stage__c stageRecord = mapIncidentSubIdToStageRecord?.get(key);
                    Decimal federalAmountAvailable = (Decimal)aggResult?.get('FederalAmountAvailable');
                    Decimal stateAmountAvailable = (Decimal)aggResult?.get('StateAmountAvailable');
                    Decimal adminAmountAvailable = (Decimal)aggResult?.get('AvailableAdminAmount');

                    Decimal totalProjectAward = (Decimal)aggResult?.get('TotalProjectAward');
                    Decimal federalProjectAward = (Decimal)aggResult?.get('FederalProjectAward');
                    Decimal stateProjectAward = (Decimal)aggResult?.get('StateProjectAward');
                    Decimal stateAdminShare = (Decimal)aggResult?.get('StateAdminShare');
                    Decimal federalRetentionToDate = (Decimal)aggResult?.get('FederalRetentionToDate');
                    Decimal stateRetentionToDate = (Decimal)aggResult?.get('StateRetentionToDate');

                    stageRecord.Available_Federal_Amount__c = (federalAmountAvailable == null?0.00:federalAmountAvailable).setScale(2,system.RoundingMode.DOWN);
                    stageRecord.Available_State_Amount__c = (stateAmountAvailable == null?0.00:stateAmountAvailable).setScale(2,system.RoundingMode.DOWN);
                    stageRecord.Available_State_Admin_Amount__c = (adminAmountAvailable == null?0.00:adminAmountAvailable).setScale(2,system.RoundingMode.DOWN);

                    stageRecord.Total_Amount_Obligated__c = (totalProjectAward == null?0.00:totalProjectAward).setScale(2,system.RoundingMode.DOWN);
                    stageRecord.Total_Federal_Amount_Obligated__c = (federalProjectAward == null?0.00:federalProjectAward).setScale(2,system.RoundingMode.DOWN);
                    stageRecord.Total_State_Amount_Obligated__c = (stateProjectAward == null?0.00:stateProjectAward).setScale(2,system.RoundingMode.DOWN);
                    stageRecord.Total_Admin_Amount_Obligated__c = (stateAdminShare == null?0.00:stateAdminShare).setScale(2,system.RoundingMode.DOWN);
                    stageRecord.Total_Federal_Retention_to_Date__c = (federalRetentionToDate == null?0.00:federalRetentionToDate).setScale(2,system.RoundingMode.DOWN);
                    stageRecord.Total_State_Retention_to_Date__c = (stateRetentionToDate == null?0.00:stateRetentionToDate).setScale(2,system.RoundingMode.DOWN);

                    stageRecordsToUpdate.add(stageRecord);
                }
                update stageRecordsToUpdate;
            }
        }
    }*/

    private void customRollUpOnIncidentSubRecipientSummaryNew() {
        Set<Id> summaryIds = new Set<Id>(); // Collection to collect the Summary record Id from Project record.
        // While Insert/UnDelete - checking if the "Incident Sub Recipient Summary" field is not null on Project record.
        if (Trigger.isInsert || Trigger.isUndelete) {
            for (Project__c projectRecord : (List<Project__c>) Trigger.new) {
                if(projectRecord.Incident_Subrecipient_Summary__c != null
                        && projectRecord.Total_Project_Award__c != null
                        && projectRecord.Total_Project_Award__c != 0 ) {
                    summaryIds.add(projectRecord.Incident_Subrecipient_Summary__c);
                }
            }
        }
        // While Update - Checking the Values changes which can impact the Summary record Roll Ups. // Checking if the
        if (Trigger.isUpdate) {
            for (Project__c projectRecord : (List<Project__c>) Trigger.new) {
                Project__c oldRecord = (Project__c) Trigger.oldMap.get(projectRecord.Id);
                if (projectRecord.Incident_Subrecipient_Summary__c != oldRecord.Incident_Subrecipient_Summary__c
                        || projectRecord.Program_Name__c != oldRecord.Program_Name__c
                        || projectRecord.Net_Federal_Amount_Available__c != oldRecord.Net_Federal_Amount_Available__c
                        || projectRecord.Net_State_Amount_Available__c != oldRecord.Net_State_Amount_Available__c
                        || projectRecord.Net_Admin_Amount_Available__c != oldRecord.Net_Admin_Amount_Available__c
                        || projectRecord.Total_Project_Award__c != oldRecord.Total_Project_Award__c
                        || projectRecord.Federal_Project_Award__c != oldRecord.Federal_Project_Award__c
                        || projectRecord.State_Project_Award__c != oldRecord.State_Project_Award__c
                        || projectRecord.TotalProjectStateAdminShare__c != oldRecord.TotalProjectStateAdminShare__c
                        || projectRecord.Total_Federal_Retention__c != oldRecord.Total_Federal_Retention__c
                        || projectRecord.Total_State_Retention__c != oldRecord.Total_State_Retention__c
                        || projectRecord.Federal_Retention_To_Date__c != oldRecord.Federal_Retention_To_Date__c
                        || projectRecord.State_Retention_To_Date__c != oldRecord.State_Retention_To_Date__c
                        || (projectRecord.Stage__c != oldRecord.Stage__c &&
                        (projectRecord.Stage__c == ALS_CONSTANTS.Project_Stage_Withdrawn
                                || oldRecord.Stage__c == ALS_CONSTANTS.Project_Stage_Withdrawn))) {
                    if(projectRecord.Incident_Subrecipient_Summary__c != null) {
                        summaryIds.add(projectRecord.Incident_Subrecipient_Summary__c);
                    }
                    if(projectRecord.Incident_Subrecipient_Summary__c != oldRecord.Incident_Subrecipient_Summary__c
                            && oldRecord.Incident_Subrecipient_Summary__c !=  null) {
                        summaryIds.add(oldRecord.Incident_Subrecipient_Summary__c);
                    }
                }
            }
        }

        if (summaryIds?.size() > 0) {
            List<AggregateResult> results = [SELECT Incident_Subrecipient_Summary__c,
                                                    SUM(Net_Federal_Amount_Available__c)FederalAmountAvailable,
                                                    SUM(Net_State_Amount_Available__c)StateAmountAvailable,
                                                    SUM(Net_Admin_Amount_Available__c)AvailableAdminAmount,
                                                    SUM(Total_Project_Award__c)TotalProjectAward,
                                                    SUM(Federal_Project_Award__c)FederalProjectAward,
                                                    SUM(State_Project_Award__c)StateProjectAward,
                                                    SUM(TotalProjectStateAdminShare__c)StateAdminShare,
                                                    SUM(Total_Federal_Retention__c)TotalFederalRetention,
                                                    SUM(Total_State_Retention__c)TotalStateRetention,
                                                    SUM(Federal_Project_Award_W_O_Retention__c)FederalProjectAwardWithoutRetention,
                                                    SUM(State_Project_Award_W_O_Retention__c)StateProjectAwardWithoutRetention,
                                                    SUM(Federal_Retention_To_Date__c)FederalRetentionToDate,
                                                    SUM(State_Retention_To_Date__c)StateRetentionToDate,
                                                    SUM(Total_Retention_To_Date__c)TotalRetentionToDate
                                                FROM Project__c
                                                WHERE Incident_Subrecipient_Summary__c IN : summaryIds
                                                AND Stage__c !=: ALS_CONSTANTS.Project_Stage_Withdrawn
                                                GROUP BY Incident_Subrecipient_Summary__c];

            // Fetching the aggregate result for the Project which are of PA programs.
            List<AggregateResult> paResults = [SELECT Incident_Subrecipient_Summary__c, SUM(Federal_Project_Award__c)PaFederalProjectAward,
                                                        SUM(State_Project_Award__c)PaStateProjectAward,
                                                        SUM(TotalProjectStateAdminShare__c)PaAdminProjectAward
                                                FROM Project__c WHERE Incident_Subrecipient_Summary__c IN : summaryIds
                                                AND Stage__c !=: ALS_CONSTANTS.Project_Stage_Withdrawn
                                                AND (Program_Name__r.Parent_Program__r.Master_Label_Program_Name__c =: ALS_CONSTANTS.Program_PA
                                                     OR Program_Name__r.Parent_Program__r.Master_Label_Program_Name__c =: ALS_CONSTANTS.Program_PA_StateOnly)
                                                GROUP BY Incident_Subrecipient_Summary__c];
            // Collection to collect the Aggregate result in order of Summary id as key and aggregate result record as value.
            Map<Id, AggregateResult> summaryIdToPaSummaryRecordMap = new Map<Id, AggregateResult>();
            if (paResults?.size() > 0) {
                for (AggregateResult aggResult :paResults) {
                    Id summaryId = (Id)aggResult.get('Incident_Subrecipient_Summary__c');
                    summaryIdToPaSummaryRecordMap.put(summaryId, aggResult);
                }
            }

            List<Incident_Subrecipient_Stage__c> stageRecordsToUpdate = new List<Incident_Subrecipient_Stage__c>();
            for(AggregateResult aggResult :results) {
                Id summaryId = (Id)aggResult.get('Incident_Subrecipient_Summary__c');
                Incident_Subrecipient_Stage__c stageRecord = new Incident_Subrecipient_Stage__c();
                stageRecord.Id = summaryId;

                // Fetching the values from Aggregate Result record.
                Decimal federalAmountAvailable = (Decimal)aggResult?.get('FederalAmountAvailable');
                Decimal stateAmountAvailable = (Decimal)aggResult?.get('StateAmountAvailable');
                Decimal adminAmountAvailable = (Decimal)aggResult?.get('AvailableAdminAmount');

                Decimal totalProjectAward = (Decimal)aggResult?.get('TotalProjectAward');
                Decimal federalProjectAward = (Decimal)aggResult?.get('FederalProjectAward');
                Decimal stateProjectAward = (Decimal)aggResult?.get('StateProjectAward');
                Decimal stateAdminShare = (Decimal)aggResult?.get('StateAdminShare');
                Decimal totalFederalRetention = (Decimal)aggResult?.get('TotalFederalRetention');
                Decimal totalStateRetention = (Decimal)aggResult?.get('TotalStateRetention');
                Decimal federalAwardWithoutRetention = (Decimal)aggResult?.get('FederalProjectAwardWithoutRetention');
                Decimal stateAwardWithoutRetention = (Decimal)aggResult?.get('StateProjectAwardWithoutRetention');
                Decimal federalRetentionToDate = (Decimal)aggResult?.get('FederalRetentionToDate');
                Decimal stateRetentionToDate = (Decimal)aggResult?.get('StateRetentionToDate');
                Decimal totalRetentionToDate = (Decimal)aggResult?.get('TotalRetentionToDate');

                // Updating the Summary record values.
                stageRecord.Available_Federal_Amount__c = (federalAmountAvailable == null?0.00: federalAmountAvailable).setScale(2,system.RoundingMode.DOWN);
                stageRecord.Available_State_Amount__c = (stateAmountAvailable == null?0.00: stateAmountAvailable).setScale(2,system.RoundingMode.DOWN);
                stageRecord.Available_State_Admin_Amount__c = (adminAmountAvailable == null?0.00: adminAmountAvailable).setScale(2,system.RoundingMode.DOWN);

                stageRecord.Total_Amount_Obligated__c = (totalProjectAward == null?0.00: totalProjectAward).setScale(2,system.RoundingMode.DOWN);
                stageRecord.Total_Federal_Amount_Obligated__c = (federalProjectAward == null?0.00: federalProjectAward).setScale(2,system.RoundingMode.DOWN);
                stageRecord.Total_State_Amount_Obligated__c = (stateProjectAward == null?0.00: stateProjectAward).setScale(2,system.RoundingMode.DOWN);
                stageRecord.Total_Admin_Amount_Obligated__c = (stateAdminShare == null?0.00: stateAdminShare).setScale(2,system.RoundingMode.DOWN);
                stageRecord.Total_Federal_Retention__c = (totalFederalRetention == null?0.00: totalFederalRetention).setScale(2,system.RoundingMode.DOWN);
                stageRecord.Total_State_Retention__c = (totalStateRetention == null?0.00: totalStateRetention).setScale(2,system.RoundingMode.DOWN);
                stageRecord.Total_Federal_Award_W_O_Retention__c = (federalAwardWithoutRetention == null?0.00: federalAwardWithoutRetention).setScale(2,system.RoundingMode.DOWN);
                stageRecord.Total_State_Award_W_O_Retention__c = (stateAwardWithoutRetention == null?0.00: stateAwardWithoutRetention).setScale(2,system.RoundingMode.DOWN);
                stageRecord.Total_Federal_Retention_to_Date__c = (federalRetentionToDate == null?0.00: federalRetentionToDate).setScale(2,system.RoundingMode.DOWN);
                stageRecord.Total_State_Retention_to_Date__c = (stateRetentionToDate == null?0.00: stateRetentionToDate).setScale(2,system.RoundingMode.DOWN);
                stageRecord.Total_Retention_To_Date__c = (totalRetentionToDate == null?0.00: totalRetentionToDate).setScale(2,system.RoundingMode.DOWN);

                // Fetching the Aggregate Result for PA Project in order to update PA Roll Ups on Summary record.
                AggregateResult paResult = summaryIdToPaSummaryRecordMap?.get(summaryId);
                // Fetching the values from Aggregate Result record for PA projects...
                Decimal paFederalProjectAward = (Decimal)paResult?.get('PaFederalProjectAward');
                Decimal paStateProjectAward = (Decimal)paResult?.get('PaStateProjectAward');
                Decimal paAdminProjectAward = (Decimal)paResult?.get('PaAdminProjectAward');

                stageRecord.PA_Federal_Amount_Obligated__c = (paFederalProjectAward == null?0.00: paFederalProjectAward).setScale(2,system.RoundingMode.DOWN);
                stageRecord.PA_State_Amount_Obligated__c = (paStateProjectAward == null?0.00: paStateProjectAward).setScale(2,system.RoundingMode.DOWN);
                stageRecord.PA_State_Admin_Amount_Obligated__c = (paAdminProjectAward == null?0.00: paAdminProjectAward).setScale(2,system.RoundingMode.DOWN);

                stageRecordsToUpdate.add(stageRecord);
            }
            if (stageRecordsToUpdate?.size() > 0) {
                update stageRecordsToUpdate;
            }
        }
  	}

    /*********************************************
	* Method Name : customRollUpOnIncidentSubRecipientSummaryOnDelete
	* Called From Method : BeforeDelete
	* Author : Sushant
	* Inputs : -
	* Description: This method is used to update the Rollups from project to Incident Sub Recipient Summary record upon Deletion of Project. */
    /*private void customRollUpOnIncidentSubRecipientSummaryOnDelete() {
        List<Id> incidentId = new List<Id>();
        List<Id> accountId = new List<Id>();
        Map<Id, Project__c> prjToProcess = new Map<Id, Project__c>();
        for (Project__c projects : (List<Project__c>) Trigger.old) {
            if(projects.Incident_Name__c != null){
                prjToProcess.put(projects.Id, projects);
            }
        }
        if (prjToProcess?.size() > 0) {
        for(Project__c prj :prjToProcess.values()){
            incidentId.add(prj.Incident_Name__c);
            accountId.add(prj.Obligating_Sub_Recipient__c);
        }
            if(incidentId.size() > 0 && accountId.size() >0 ) {
            List<AggregateResult> results = [SELECT Incident_Name__c,Obligating_Sub_Recipient__c ,
                        SUM(FederalAmountAvailable__c)FederalAmountAvailable,
                        SUM(StateAmountAvailable__c)StateAmountAvailable,
                        SUM(AvailableAdminAmount__c)AvailableAdminAmount,
                        SUM(Total_Project_Award__c)TotalProjectAward,
                        SUM(Federal_Project_Award__c)FederalProjectAward,
                        SUM(State_Project_Award__c)StateProjectAward,
                        SUM(TotalProjectStateAdminShare__c)StateAdminShare,
                        SUM(Federal_Retention_To_Date__c)FederalRetentionToDate,
                        SUM(State_Retention_To_Date__c)StateRetentionToDate
                                            FROM Project__c WHERE Id IN :prjToProcess.keySet()
                AND Incident_Name__c IN : incidentId
                AND Obligating_Sub_Recipient__c IN : accountId
                AND Stage__c !=: ALS_CONSTANTS.Project_Stage_Withdrawn
                                            GROUP BY Incident_Name__c,Obligating_Sub_Recipient__c ];

            List<Incident_Subrecipient_Stage__c> incidentSubrecipientStage =[SELECT Id,Incident__c,Account__c,Available_Federal_Amount__c,
                        Available_State_Admin_Amount__c, Available_State_Amount__c, Total_Amount_Obligated__c,
                        Total_Federal_Amount_Obligated__c, Total_State_Amount_Obligated__c, Total_Federal_Retention_to_Date__c,
                        Total_State_Retention_to_Date__c, Total_Admin_Amount_Obligated__c
                FROM Incident_Subrecipient_Stage__c WHERE Account__c IN:accountId AND Incident__c IN:incidentId];

            Map<String,Incident_Subrecipient_Stage__c> mapIncidentSubIdToStageRecord = new Map<String,Incident_Subrecipient_Stage__c>();
            if(incidentSubrecipientStage.size() > 0){
                for(Incident_Subrecipient_Stage__c incSubstage:incidentSubrecipientStage){
                    String key = (String)incSubstage.Incident__c + (String)incSubstage.Account__c;
                    mapIncidentSubIdToStageRecord.put(key,incSubstage)  ;
                }
            }
            List<Incident_Subrecipient_Stage__c> stageRecordsToUpdate = new List<Incident_Subrecipient_Stage__c>();
            for(AggregateResult aggResult :results){
                Id incidentIds = (Id)aggResult.get('Incident_Name__c');
                Id subRecipientId = (Id)aggResult.get('Obligating_Sub_Recipient__c');
                String key = (String)incidentIds + (String)subRecipientId;
                Incident_Subrecipient_Stage__c stageRecord = mapIncidentSubIdToStageRecord?.get(key);

                Decimal federalAmountAvailable = (Decimal)aggResult.get('FederalAmountAvailable');
                Decimal stateAmountAvailable = (Decimal)aggResult.get('StateAmountAvailable');
                Decimal adminAmountAvailable = (Decimal)aggResult.get('AvailableAdminAmount');

                    Decimal totalProjectAward = (Decimal)aggResult?.get('TotalProjectAward');
                    Decimal federalProjectAward = (Decimal)aggResult?.get('FederalProjectAward');
                    Decimal stateProjectAward = (Decimal)aggResult?.get('StateProjectAward');
                    Decimal stateAdminShare = (Decimal)aggResult?.get('StateAdminShare');
                    Decimal federalRetentionToDate = (Decimal)aggResult?.get('FederalRetentionToDate');
                    Decimal stateRetentionToDate = (Decimal)aggResult?.get('StateRetentionToDate');

                stageRecord.Available_Federal_Amount__c -= (federalAmountAvailable == null?0.00:federalAmountAvailable).setScale(2,system.RoundingMode.DOWN);
                stageRecord.Available_State_Amount__c -= (stateAmountAvailable == null?0.00:stateAmountAvailable).setScale(2,system.RoundingMode.DOWN);
                stageRecord.Available_State_Admin_Amount__c -= (adminAmountAvailable == null?0.00:adminAmountAvailable).setScale(2,system.RoundingMode.DOWN);

                    stageRecord.Total_Amount_Obligated__c -= (totalProjectAward == null?0.00:totalProjectAward).setScale(2,system.RoundingMode.DOWN);
                    stageRecord.Total_Federal_Amount_Obligated__c -= (federalProjectAward == null?0.00:federalProjectAward).setScale(2,system.RoundingMode.DOWN);
                    stageRecord.Total_State_Amount_Obligated__c -= (stateProjectAward == null?0.00:stateProjectAward).setScale(2,system.RoundingMode.DOWN);
                    stageRecord.Total_Admin_Amount_Obligated__c -= (stateAdminShare == null?0.00:stateAdminShare).setScale(2,system.RoundingMode.DOWN);
                    stageRecord.Total_Federal_Retention_to_Date__c -= (federalRetentionToDate == null?0.00:federalRetentionToDate).setScale(2,system.RoundingMode.DOWN);
                    stageRecord.Total_State_Retention_to_Date__c -= (stateRetentionToDate == null?0.00:stateRetentionToDate).setScale(2,system.RoundingMode.DOWN);

                stageRecordsToUpdate.add(stageRecord);
            }
            update stageRecordsToUpdate;
        }
    }
    }*/

    private void customRollUpOnIncidentSubRecipientSummaryOnDeleteNew() {
        Set<Id> summaryIds = new Set<Id>(); // Collection to collect the Summary record Id of the Project record.
        Map<Id, Project__c> projectIdToProjectToProcessMap = new Map<Id, Project__c>(); // Collection to collect the Project record,
        // which needs to be queried while querying the Aggregate result as the This method is called in Before Delete Trigger.
        // Only the record Which are getting deleted those sums will gets reduced from Incident record.
        for (Project__c projects : (List<Project__c>) Trigger.old) {
            if(projects.Incident_Subrecipient_Summary__c != null) {
                projectIdToProjectToProcessMap.put(projects.Id, projects);
                summaryIds.add(projects.Incident_Subrecipient_Summary__c);
            }
        }
        if (summaryIds?.size() > 0) {
            // Querying the Aggregate result data for the Project which are getting deleted.
            List<AggregateResult> results = [SELECT Incident_Subrecipient_Summary__c,
                                                        SUM(Net_Federal_Amount_Available__c)FederalAmountAvailable,
                                                        SUM(Net_State_Amount_Available__c)StateAmountAvailable,
                                                        SUM(Net_Admin_Amount_Available__c)AvailableAdminAmount,
                                                        SUM(Total_Project_Award__c)TotalProjectAward,
                                                        SUM(Federal_Project_Award__c)FederalProjectAward,
                                                        SUM(State_Project_Award__c)StateProjectAward,
                                                        SUM(TotalProjectStateAdminShare__c)StateAdminShare,
                                                        SUM(Total_Federal_Retention__c)TotalFederalRetention,
                                                        SUM(Total_State_Retention__c)TotalStateRetention,
                                                        SUM(Federal_Project_Award_W_O_Retention__c)FederalProjectAwardWithoutRetention,
                                                        SUM(State_Project_Award_W_O_Retention__c)StateProjectAwardWithoutRetention,
                                                        SUM(Federal_Retention_To_Date__c)FederalRetentionToDate,
                                                        SUM(State_Retention_To_Date__c)StateRetentionToDate,
                                                        SUM(Total_Retention_To_Date__c)TotalRetentionToDate
                                                FROM Project__c WHERE Incident_Subrecipient_Summary__c IN : summaryIds
                                                AND Id IN : projectIdToProjectToProcessMap.keySet()
                                                AND Stage__c !=: ALS_CONSTANTS.Project_Stage_Withdrawn
                                                GROUP BY Incident_Subrecipient_Summary__c];

            List<AggregateResult> paResults = [SELECT Incident_Subrecipient_Summary__c, SUM(Federal_Project_Award__c)PaFederalProjectAward,
                                                        SUM(State_Project_Award__c)PaStateProjectAward,
                                                        SUM(TotalProjectStateAdminShare__c)PaAdminProjectAward
                                                FROM Project__c WHERE Incident_Subrecipient_Summary__c IN : summaryIds
                                                AND Id IN : projectIdToProjectToProcessMap.keySet()
                                                AND Stage__c !=: ALS_CONSTANTS.Project_Stage_Withdrawn
                                                AND Program_Name__r.Parent_Program__r.Master_Label_Program_Name__c =: ALS_CONSTANTS.Program_PA
                                                GROUP BY Incident_Subrecipient_Summary__c];
            Map<Id, AggregateResult> summaryIdToPaSummaryRecordMap = new Map<Id, AggregateResult>();
            if (paResults?.size() > 0) {
                for (AggregateResult aggResult :paResults) {
                    Id summaryId = (Id)aggResult.get('Incident_Subrecipient_Summary__c');
                    summaryIdToPaSummaryRecordMap.put(summaryId, aggResult);
                }
            }

            // Querying the Incident Sub Recipient Summary record whose Project is getting deleted in or4der to deduct the Amount from Roll Up.
            Map<Id, Incident_Subrecipient_Stage__c> summaryIdToSummaryRecordMap = new Map<Id, Incident_Subrecipient_Stage__c>([SELECT Id,
                                                    Incident__c, Account__c, Available_Federal_Amount__c, Available_State_Admin_Amount__c,
                                                    Available_State_Amount__c, Total_Amount_Obligated__c, Total_Federal_Amount_Obligated__c,
                                                    PA_Federal_Amount_Obligated__c, PA_State_Amount_Obligated__c, PA_State_Admin_Amount_Obligated__c,
                                                    Total_State_Amount_Obligated__c, Total_Federal_Retention__c, Total_State_Retention__c,
                                                    Total_Admin_Amount_Obligated__c, Total_State_Award_W_O_Retention__c,
                                                    Total_Federal_Award_W_O_Retention__c, Total_Retention_To_Date__c,
                                                    Total_Federal_Retention_to_Date__c, Total_State_Retention_to_Date__c
                                                FROM Incident_Subrecipient_Stage__c WHERE Id IN : summaryIds]);
            // Collection to store the Summary record to Update.
            List<Incident_Subrecipient_Stage__c> stageRecordsToUpdate = new List<Incident_Subrecipient_Stage__c>();
            for(AggregateResult aggResult :results) {
                Id summaryId = (Id)aggResult.get('Incident_Subrecipient_Summary__c');
                // Fetching the Summary record from Map collection whose Id is available in current Aggregate result data.
                Incident_Subrecipient_Stage__c stageRecord = summaryIdToSummaryRecordMap?.get(summaryId);

                // Fetching the data from Aggregate query, In order to deduct the Amounts from the Summary record.
                Decimal federalAmountAvailable = (Decimal)aggResult.get('FederalAmountAvailable');
                Decimal stateAmountAvailable = (Decimal)aggResult.get('StateAmountAvailable');
                Decimal adminAmountAvailable = (Decimal)aggResult.get('AvailableAdminAmount');

                Decimal totalProjectAward = (Decimal)aggResult?.get('TotalProjectAward');
                Decimal federalProjectAward = (Decimal)aggResult?.get('FederalProjectAward');
                Decimal stateProjectAward = (Decimal)aggResult?.get('StateProjectAward');
                Decimal stateAdminShare = (Decimal)aggResult?.get('StateAdminShare');
                Decimal totalFederalRetention = (Decimal)aggResult?.get('TotalFederalRetention');
                Decimal totalStateRetentionToDate = (Decimal)aggResult?.get('TotalStateRetention');
                Decimal federalAwardWithoutRetention = (Decimal)aggResult?.get('FederalProjectAwardWithoutRetention');
                Decimal stateAwardWithoutRetention = (Decimal)aggResult?.get('StateProjectAwardWithoutRetention');
                Decimal federalRetentionToDate = (Decimal)aggResult?.get('FederalRetentionToDate');
                Decimal stateRetentionToDate = (Decimal)aggResult?.get('StateRetentionToDate');
                Decimal totalRetentionToDate = (Decimal)aggResult?.get('TotalRetentionToDate');

                // Updating the Summary record Roll Up fields...
                stageRecord.Available_Federal_Amount__c -= (federalAmountAvailable == null?0.00:federalAmountAvailable).setScale(2,system.RoundingMode.DOWN);
                stageRecord.Available_State_Amount__c -= (stateAmountAvailable == null?0.00:stateAmountAvailable).setScale(2,system.RoundingMode.DOWN);
                stageRecord.Available_State_Admin_Amount__c -= (adminAmountAvailable == null?0.00:adminAmountAvailable).setScale(2,system.RoundingMode.DOWN);

                stageRecord.Total_Amount_Obligated__c -= (totalProjectAward == null?0.00:totalProjectAward).setScale(2,system.RoundingMode.DOWN);
                stageRecord.Total_Federal_Amount_Obligated__c -= (federalProjectAward == null?0.00:federalProjectAward).setScale(2,system.RoundingMode.DOWN);
                stageRecord.Total_State_Amount_Obligated__c -= (stateProjectAward == null?0.00:stateProjectAward).setScale(2,system.RoundingMode.DOWN);
                stageRecord.Total_Admin_Amount_Obligated__c -= (stateAdminShare == null?0.00:stateAdminShare).setScale(2,system.RoundingMode.DOWN);
                stageRecord.Total_Federal_Retention__c = (totalFederalRetention == null?0.00: totalFederalRetention).setScale(2,system.RoundingMode.DOWN);
                stageRecord.Total_State_Retention__c = (totalStateRetentionToDate == null?0.00: totalStateRetentionToDate).setScale(2,system.RoundingMode.DOWN);
                stageRecord.Total_Federal_Award_W_O_Retention__c -= (federalAwardWithoutRetention == null?0.00: federalAwardWithoutRetention).setScale(2,system.RoundingMode.DOWN);
                stageRecord.Total_State_Award_W_O_Retention__c -= (stateAwardWithoutRetention == null?0.00: stateAwardWithoutRetention).setScale(2,system.RoundingMode.DOWN);
                stageRecord.Total_Federal_Retention_to_Date__c -= (federalRetentionToDate == null?0.00: federalRetentionToDate).setScale(2,system.RoundingMode.DOWN);
                stageRecord.Total_State_Retention_to_Date__c -= (stateRetentionToDate == null?0.00: stateRetentionToDate).setScale(2,system.RoundingMode.DOWN);
                stageRecord.Total_Retention_To_Date__c -= (totalRetentionToDate == null?0.00: totalRetentionToDate).setScale(2,system.RoundingMode.DOWN);

                // Fetching the Aggregate Result for PA Project in order to update PA Roll Ups on Summary record.
                AggregateResult paResult = summaryIdToPaSummaryRecordMap?.get(summaryId);
                // Fetching the values from Aggregate Result record for PA projects...
                Decimal paFederalProjectAward = (Decimal)paResult?.get('PaFederalProjectAward');
                Decimal paStateProjectAward = (Decimal)paResult?.get('PaStateProjectAward');
                Decimal paAdminProjectAward = (Decimal)paResult?.get('PaAdminProjectAward');

                stageRecord.PA_Federal_Amount_Obligated__c -= (paFederalProjectAward == null?0.00: paFederalProjectAward).setScale(2,system.RoundingMode.DOWN);
                stageRecord.PA_State_Amount_Obligated__c -= (paStateProjectAward == null?0.00: paStateProjectAward).setScale(2,system.RoundingMode.DOWN);
                stageRecord.PA_State_Admin_Amount_Obligated__c -= (paAdminProjectAward == null?0.00: paAdminProjectAward).setScale(2,system.RoundingMode.DOWN);

                stageRecordsToUpdate.add(stageRecord);
            }
            if(stageRecordsToUpdate?.size() > 0) {
                update stageRecordsToUpdate;
            }
        }
    }

    //This method is used to check if there is any "Approved/In Review" PR on the Project without marking Project to Withdrawn Stage...
    //Story No - 378 - Start
    private void preventProjectWithdrawnWithApprovedOrInReviewPr() {
        //todo Rename ProjectToProcessMap
        Map<Id, Project__c> projectIdToProjectToProcessMap = new Map<Id, Project__c>();
        for (Project__c project : (List<Project__c>) Trigger.new) {
            Project__c oldRecord = (Project__c)Trigger.oldMap.get(project.Id);
            if(project.Stage__c != oldRecord.Stage__c && project.Stage__c == ALS_CONSTANTS.Project_Stage_Withdrawn) {
                projectIdToProjectToProcessMap.put(project.Id, project);
            }
        }
        if(projectIdToProjectToProcessMap.size() > 0) {
            List<String> stageList = new List<String>();
            stageList.add(ALS_CONSTANTS.PR_Stage_Paid);
            stageList.add(ALS_CONSTANTS.PR_Stage_InReview);
            stageList.add(ALS_CONSTANTS.PR_Stage_ReturnedProjectPayment);
            stageList.add(ALS_CONSTANTS.PR_Stage_PaymentProcessing);
            //todo Add comments - what data is to be fetched..
            Map<Id, Project__c> projectIdToProjectWithPrMap = new Map<Id, Project__c>([SELECT Id, Name, Stage__c,
                                                            (SELECT Id, Name, Stage__c FROM Payment_Requests__r
                                                            WHERE Stage__c !=: ALS_CONSTANTS.PR_Stage_Withdrawn
                                                            AND Stage__c IN : stageList)
                                                        FROM Project__c WHERE Id IN : projectIdToProjectToProcessMap.keySet()]);
            for (Project__c project : projectIdToProjectToProcessMap.values()) {
                //todo Comments
                if (projectIdToProjectWithPrMap.get(project.Id).Payment_Requests__r.size() > 0) {
                    project.addError('There are Payment Request, which are "Approved/In Review" on this Project.');
                }
            }
        }
    }

    /*********************************************
	* Method Name : updateRelatedPrsToWithdrawnUponProjectWithdrawn
	* Called From Method : AfterUpdate
	* Author : Ricky
	* Inputs : -
	* Description: This method is used to auto Withdraw the related PR upon Project Withdrawal. */
    private void updateRelatedPrsToWithdrawnUponProjectWithdrawn() {
        Map<Id, Project__c> projectIdToProjectToProcessMap = new Map<Id, Project__c>();
        for (Project__c project : (List<Project__c>) Trigger.new) {
            Project__c oldRecord = (Project__c) Trigger.oldMap.get(project.Id);
            if(oldRecord.Stage__c != project.Stage__c && project.Stage__c == ALS_CONSTANTS.Project_Stage_Withdrawn) {
                projectIdToProjectToProcessMap.put(project.Id, project);
            }
        }
        if(projectIdToProjectToProcessMap.size() > 0) {
            List<Payment_Request__c> prListToUpdate = [SELECT Id, Stage__c, Project__c FROM Payment_Request__c
                                                                WHERE Project__c IN : projectIdToProjectToProcessMap.keySet()
                                                                AND Stage__c !=: ALS_CONSTANTS.PR_Stage_Withdrawn];
            List<Id> prsToLock = new List<Id>();
            if(prListToUpdate?.size() > 0) {
                for (Payment_Request__c paymentRequest : prListToUpdate) {
                    paymentRequest.Stage__c = ALS_CONSTANTS.PR_Stage_Withdrawn;
                    paymentRequest.Reason_To_Withdraw__c = ALS_CONSTANTS.PR_ReasonToAutoWithdraw;

                    prsToLock.add(paymentRequest.Id);
                }
            }

            Database.SaveResult[] results = Database.update(prListToUpdate, false);
                Integer count = 0;
                for (Database.SaveResult result : results) {
                    if(!result.isSuccess()) {
                        for(Database.Error err : result.getErrors()) {
                            Trigger.newMap.get(prListToUpdate[count].Project__c).addError(err.getMessage());
                        }
                    }
                }

                RecordLockUnlockClass recordLockUnlock = new RecordLockUnlockClass();
                recordLockUnlock.lockRecord(prsToLock); //Locking the Payment Requests...
        }

    }

    

    //Story No - 374 - Start
    /*private void reverseCalculationCheckBoxValidation() {
        Map<Id, Project__c> idToProjectRecordMap = new Map<Id, Project__c>();
        //Set<Id> currentUserId = new Set<Id>();
        for(Project__c project : (List<Project__c>) Trigger.new) {
            Project__c oldRecord = (Project__c)Trigger.oldMap.get(project.Id);
            if(oldRecord.Reverse_Calculation__c	!= project.Reverse_Calculation__c
                    || oldRecord.Federal_Project_Award__c != project.Federal_Project_Award__c
                    || oldRecord.State_Project_Award__c	!= project.State_Project_Award__c
                    || oldRecord.FEMA_Share__c != project.FEMA_Share__c
                    || oldRecord.State_Share__c != project.State_Share__c) {
                idToProjectRecordMap.put(project.Id, project);
            }
        }

        if(idToProjectRecordMap.size() > 0) {
            for(Project__c project : idToProjectRecordMap.values()) {
                Project__c oldRecord = (Project__c)Trigger.oldMap.get(project.Id);
                if(project.Reverse_Calculation__c == true &&
                        (oldRecord.FEMA_Share__c != project.FEMA_Share__c
                        || oldRecord.State_Share__c != project.State_Share__c)) {
                    project.addError('You cannot change the "State Share %" or "FEMA Share %" when "Reverse Calculation" checkbox is checked.');
                }
                if(project.Reverse_Calculation__c == false &&
                        (oldRecord.Federal_Project_Award__c != project.Federal_Project_Award__c
                                || oldRecord.State_Project_Award__c != project.State_Project_Award__c)) {
                    project.addError('You cannot change the "State Project Award" or "Federal Project Award" when "Reverse Calculation" checkbox is unchecked.');
                }
            }
        }
    }*/

    //This method is used to calculate the FEMA Share %, State Share %, Federal Project Award and State Project Award based on selection of "Reverse Calculation" Checkbox...
    private void calculateStateAndFederalCostShare() {
        List<Project__c> projectToProcessList = new List<Project__c>();
        if(Trigger.isInsert) {
            for(Project__c project : (List<Project__c>) Trigger.new) {
                projectToProcessList = Trigger.new;
            }
        }
        if(Trigger.isUpdate) {
            for(Project__c project : (List<Project__c>) Trigger.new) {
                Project__c oldRecord = (Project__c) Trigger.oldMap.get(project.Id);
                if(oldRecord.Reverse_Calculation__c	!= project.Reverse_Calculation__c
                        || oldRecord.FundingSource__c != project.FundingSource__c
                        || oldRecord.Total_Project_Award__c != project.Total_Project_Award__c
                        || oldRecord.Federal_Project_Award__c != project.Federal_Project_Award__c
                        || oldRecord.State_Project_Award__c	!= project.State_Project_Award__c
                        || oldRecord.FEMA_Share__c != project.FEMA_Share__c
                        || oldRecord.State_Share__c != project.State_Share__c) {
                    projectToProcessList.add(project);
                }
            }
        }
        if(projectToProcessList.size() > 0) {
            for(Project__c projectToProcess : projectToProcessList) {
                Decimal TotalProjectAward = projectToProcess.Total_Project_Award__c == null ? 0.00 : projectToProcess.Total_Project_Award__c;
                Decimal stateProjectAward = projectToProcess.State_Project_Award__c == null ? 0.00 : projectToProcess.State_Project_Award__c;
                Decimal federalProjectAward = projectToProcess.Federal_Project_Award__c == null ? 0.00 : projectToProcess.Federal_Project_Award__c;
                Decimal stateCostShare = projectToProcess.State_Share__c == null ? 0.00 : projectToProcess.State_Share__c;
                Decimal femaCostShare = projectToProcess.FEMA_Share__c == null ? 0.00 : projectToProcess.FEMA_Share__c;

                if(projectToProcess.Reverse_Calculation__c == true) {
                    if(projectToProcess.FundingSource__c == ALS_CONSTANTS.Project_FundingSource_FederalAndState
                            || projectToProcess.FundingSource__c == ALS_CONSTANTS.Project_FundingSource_FederalOnly) {
                        projectToProcess.FEMA_Share__c = (federalProjectAward * 100)/TotalProjectAward;
                    }
                    if(projectToProcess.FundingSource__c == ALS_CONSTANTS.Project_FundingSource_FederalAndState
                            || projectToProcess.FundingSource__c == ALS_CONSTANTS.Project_FundingSource_StateOnly) {
                        projectToProcess.State_Share__c = (stateProjectAward * 100)/TotalProjectAward;
                    }
                }
                else {
                    if(projectToProcess.FundingSource__c == ALS_CONSTANTS.Project_FundingSource_FederalAndState
                            || projectToProcess.FundingSource__c == ALS_CONSTANTS.Project_FundingSource_FederalOnly) {
                        projectToProcess.Federal_Project_Award__c = (TotalProjectAward * femaCostShare)/100;
                    }
                    if(projectToProcess.FundingSource__c == ALS_CONSTANTS.Project_FundingSource_FederalAndState
                            || projectToProcess.FundingSource__c == ALS_CONSTANTS.Project_FundingSource_StateOnly) {
                        projectToProcess.State_Project_Award__c = (TotalProjectAward * stateCostShare)/100;
                    }
                }
            }
        }
    }
    //Story No - 374 - End

    /** Ticket No - 563 - Start */
    /*********************************************
	* Method Name : stateCostShareFlagUpdateOnSummaryRecord
	* Called From Method : AfterUpdate, AfterDelete, AfterUnDelete
	* Author : Ricky
	* Inputs : -
	* Description: This method is used to update the State Cost Share Flag on Inc Sub Recipient Summary record
	*               upon change of State Amount Requested/Admin Amount Requested on Project. */
    private void stateCostShareFlagUpdateOnSummaryRecord() {
        Map<Id, Project__c> projectIdToProjectMap = new Map<Id, Project__c>();
        Set<Id> summaryRecordId = new Set<Id>(); 
        if (Trigger.isUpdate) {
            for (Project__c project : (List<Project__c>) Trigger.new) {
                Project__c oldRecord = (Project__c) Trigger.oldMap.get(project.Id);
                if (project.Incident_Subrecipient_Summary__c != null
                        && (project.Incident_Subrecipient_Summary__c != oldRecord.Incident_Subrecipient_Summary__c
                            || project.Total_State_Amount_Requested__c != oldRecord.Total_State_Amount_Requested__c
                            || project.Total_Admin_Amount_Requested__c != oldRecord.Total_Admin_Amount_Requested__c
                            || (project.Stage__c != oldRecord.Stage__c
                                && (project.Stage__c == ALS_CONSTANTS.Project_Stage_Withdrawn
                                    || oldRecord.Stage__c == ALS_CONSTANTS.Project_Stage_Withdrawn)))) {
                    projectIdToProjectMap.put(project.Id, project);
                    if (project.Incident_Subrecipient_Summary__c != null) {
                        summaryRecordId.add(project.Incident_Subrecipient_Summary__c);
                    }
                    if (project.Incident_Subrecipient_Summary__c != oldRecord.Incident_Subrecipient_Summary__c
                            && oldRecord.Incident_Subrecipient_Summary__c != null) {
                        summaryRecordId.add(oldRecord.Incident_Subrecipient_Summary__c);
                    }
                }
            }
        }
        if (Trigger.isDelete) {
            for (Project__c project : (List<Project__c>) Trigger.old) {
                if (project.Incident_Subrecipient_Summary__c != null
                        && project.Stage__c != ALS_CONSTANTS.Project_Stage_Withdrawn
                        && ((project.StateAmountAvailable__c != 0 && project.StateAmountAvailable__c != null)
                            || (project.AvailableAdminAmount__c != 0 && project.AvailableAdminAmount__c != null))) {
                    summaryRecordId.add(project.Incident_Subrecipient_Summary__c);
                }
            }
        }
        if (Trigger.isUndelete) {
            for (Project__c project : (List<Project__c>) Trigger.new) {
                if (project.Incident_Subrecipient_Summary__c != null
                        && project.Stage__c != ALS_CONSTANTS.Project_Stage_Withdrawn
                        && ((project.StateAmountAvailable__c != 0 && project.StateAmountAvailable__c != null)
                        || (project.AvailableAdminAmount__c != 0 && project.AvailableAdminAmount__c != null))) {
                    summaryRecordId.add(project.Incident_Subrecipient_Summary__c);
                }
            }
        }

        if (summaryRecordId?.size() > 0) {
            List<AggregateResult> results = [SELECT Incident_Subrecipient_Summary__c, SUM(Total_State_Amount_Requested__c)stateAmount,
                                                SUM(Total_Admin_Amount_Requested__c)adminAmount FROM Project__c
                                                WHERE Incident_Subrecipient_Summary__c IN : summaryRecordId
                                                AND Stage__c !=: ALS_CONSTANTS.Project_Stage_Withdrawn
                                                GROUP BY Incident_Subrecipient_Summary__c];
            List<Incident_Subrecipient_Stage__c> summaryRecordToUpdateList = new List<Incident_Subrecipient_Stage__c>();
            if (results?.size() > 0) {
                for (AggregateResult result : results) {
                    Decimal stateAmount = (Decimal) (result?.get('stateAmount') == null ? 0.00 : result?.get('stateAmount'));
                    Decimal adminAmount = (Decimal) (result?.get('adminAmount') == null ? 0.00 : result?.get('adminAmount'));
                    Id summaryId = (Id) result?.get('Incident_Subrecipient_Summary__c');

                    Decimal cumulativeAmount = (stateAmount + adminAmount)?.setScale(2,system.RoundingMode.DOWN);
                    Incident_Subrecipient_Stage__c summaryRecordToUpdate = new Incident_Subrecipient_Stage__c();
                    summaryRecordToUpdate.Id = summaryId;

                    if (cumulativeAmount >= 2500) {
                        summaryRecordToUpdate.Cumulative_State_Cost_Share_Flag__c = true;
                        summaryRecordToUpdateList.add(summaryRecordToUpdate);
                    }
                    else {
                        summaryRecordToUpdate.Cumulative_State_Cost_Share_Flag__c = false;
                        summaryRecordToUpdateList.add(summaryRecordToUpdate);
                    }
                }
            }
            if (summaryRecordToUpdateList?.size() > 0) {
                update summaryRecordToUpdateList;
            }
        }
    }
    /** Ticket No - 563 - End */
	
	/*********************************************
	* Method Name : updateManagerDetailsOnProjectRecord
	* Called From Method : BeforeInsert, BeforeUpdate
	* Author : Ricky
	* Inputs : -
	* Description: This method is used to update the Manger User and Manager Approved Date on Project record,
	               based on "Reviewed By Manager" field. */
    private void updateManagerDetailsOnProjectRecord() {
        // Collection to collect the Project record which needs to be processed.
        List<Project__c> projectToProcessList = new List<Project__c>();
        // While insert - Taking all project record for processing.
        if (Trigger.isInsert) {
            projectToProcessList = Trigger.new;
        }
        // While Update - Collection only those Project record whose "Reviewed By Manager" field value is chnaged.
        if (Trigger.isUpdate) {
            for (Project__c projectToProcess : (List<Project__c>) Trigger.new) {
                Project__c oldRecord = (Project__c) Trigger.oldMap.get(projectToProcess.Id);
                if (oldRecord.Reviewed_By_Manager__c != projectToProcess.Reviewed_By_Manager__c) {
                    projectToProcessList.add(projectToProcess);
                }
            }
        }
        if (projectToProcessList?.size() > 0) {
            for (Project__c projectToProcess : projectToProcessList) {
                // Condition to check if the "Reviewed By Manager" picklist field value is Yes,
                // then to copy the Current User in Manager User field and Current date in Manager Approved Date field.
                if (projectToProcess.Reviewed_By_Manager__c == ALS_CONSTANTS.Picklist_Yes) {
                    projectToProcess.Manager_User__c = UserInfo.getUserId();
                    projectToProcess.Manager_Approved_Date__c = Date.today();
                }
                // Else if "Reviewed By Manager" picklist field value is No, Then to Set Manger user and Manager Approved Date field value to null.
                else if (projectToProcess.Reviewed_By_Manager__c == ALS_CONSTANTS.Picklist_No) {
                    projectToProcess.Manager_User__c = null;
                    projectToProcess.Manager_Approved_Date__c = null;
                }
            }
        }
    }
	
	/*********************************************
	* Method Name : updateProgramNamePrefixToProjectVersion
	* Called From Method : BeforeInsert, BeforeUpdate
	* Author : Ricky
	* Inputs : -
	* Description: This method is used to update the Program name Prefix to project Number.
	*               (Prefix for the Program is configured from metadata) */
    private void updateProgramNamePrefixToProjectVersion() {
        Set<Id> programIds = new Set<Id>(); // Collection to collect the Program Ids of the Project.
        List<Project__c> projectToProcessList = new List<Project__c>(); // Collection to collect the Project record to Process.
        // While Insert - Condition to check is Program Name and Project Number field is not null on the Project record.
        if(Trigger.isInsert) {
            for (Project__c projectToProcess : (List<Project__c>) Trigger.new) {
                if (projectToProcess.Program_Name__c != null
                        && projectToProcess.Project_Number__c != null) {
                    programIds.add(projectToProcess.Program_Name__c);
                    projectToProcessList.add(projectToProcess);
                }
            }
        }
        // While Insert - Condition to check is Project Number field value is changed on the Project record.
        // Program Name and Project Number field is not null on the Project record.
        if (Trigger.isUpdate) {
            for (Project__c projectToProcess : (List<Project__c>) Trigger.new) {
                Project__c oldRecord = (Project__c)Trigger.oldMap.get(projectToProcess.Id);
                if (oldRecord.Project_Number__c != projectToProcess.Project_Number__c
                        && projectToProcess.Program_Name__c != null
                        && projectToProcess.Project_Number__c != null) {
                    programIds.add(projectToProcess.Program_Name__c);
                    projectToProcessList.add(projectToProcess);
                }
            }
        }

        if (programIds?.size() > 0) {
            // Fetching the Program details in order to get the parent Program Master labels from the record.
            Map<Id, Program__c> programIdToProgramNameMap = new Map<Id, Program__c>([SELECT Id, Name, Master_Label_Program_Name__c
                                                                FROM Program__c WHERE Id IN : programIds]);
            //Map<String, Program_Config__mdt>  programConfigMap = (Map<String, Program_Config__mdt>) Program_Config__mdt.getAll();
            // Fetching the Program Config Metadata in order to get the Prefix for the Programs.
            List<Program_Config__mdt>  programConfigList = [SELECT Id, Label, Program_Prefix__c FROM Program_Config__mdt];
            // Map collection to arrange the Metadata record in the order as Program Name Label as key and Prefix as Value.
            Map<String, String> programNameToPrfixMap = new Map<String, String>();
            if (programConfigList?.size() > 0) {
                for (Program_Config__mdt programConfig : programConfigList) {
                    programNameToPrfixMap.put(programConfig.Label, programConfig.Program_Prefix__c);
                }
            }
            for (Project__c projectToProcess : projectToProcessList) {
                Program__c programOfProject = programIdToProgramNameMap?.get(projectToProcess.Program_Name__c);
                // Condition to check if the Prefix for the Current Project's Program name is available in Metadata(In Map collection).
                // Project record Project Number field already not starts with Program Name Prefix.
                // Then appending the Program name Prefix to the Project Number field.
                /*if (programNameToPrfixMap?.get(programOfProject.Parent_Program__r.Master_Label_Program_Name__c) != null
                        && !projectToProcess.Project_Number__c.startsWith(programNameToPrfixMap?.get(programOfProject.Parent_Program__r.Master_Label_Program_Name__c))) {
                    projectToProcess.Project_Number__c = programNameToPrfixMap?.get(programOfProject.Parent_Program__r.Master_Label_Program_Name__c)
                            + '-' + projectToProcess.Project_Number__c;
                }*/
                if (programNameToPrfixMap?.get(programOfProject.Master_Label_Program_Name__c) != null
                        && !projectToProcess.Project_Number__c.startsWith(programNameToPrfixMap?.get(programOfProject.Master_Label_Program_Name__c))) {
                    projectToProcess.Project_Number__c = programNameToPrfixMap?.get(programOfProject.Master_Label_Program_Name__c)
                            + '-' + projectToProcess.Project_Number__c;
                }
            }
        }
    }

    /*********************************************
	* Method Name : updateLatestProjectVersionAndSupplementNumber
	* Called From Method : BeforeInsert, BeforeUpdate
	* Author : Ricky
	* Inputs : -
	* Description: This method is used to copy the latest Project version and Latest Supplement Number from Project number
	               and Supplement Number field, if there is no any Amendment available on the Project. */
    private void updateLatestProjectVersionAndSupplementNumber() {
        // Map collection to collect the Project record to process.
        Map<Id, Project__c> projectIdToProjectToProcessMap = new Map<Id, Project__c>();
        // While Insert - Condition to check -
        // If the Project Number field is not null, then to copy the Project Number field into Latest Project Version field.
        // If the Supplement Number field is not null, then to copy the Supplement Number field into Latest Supplement Number field.
        if (Trigger.isInsert) {
            for (Project__c projectToProcess : (List<Project__c>) Trigger.new) {
                if (projectToProcess.Project_Number__c != null) {
                    projectToProcess.Latest_Project_Version__c = projectToProcess.Project_Number__c;
                }
                else {
                    projectToProcess.Latest_Project_Version__c = null;
                }
                if (projectToProcess.Supplement_Number__c != null) {
                    projectToProcess.Latest_Supplement_Number__c = projectToProcess.Supplement_Number__c;
                }
                else {
                    projectToProcess.Latest_Supplement_Number__c = null;
                }
            }
        }
        // While Update - Condition to check if the Project Number/Supplement Number of the Project got changed on Project record.
        if (Trigger.isUpdate) {
            for (Project__c projectToProcess : (List<Project__c>) Trigger.new) {
                Project__c oldRecord = (Project__c)Trigger.oldMap.get(projectToProcess.Id);
                if (oldRecord.Project_Number__c != projectToProcess.Project_Number__c
                        || oldRecord.Supplement_Number__c != projectToProcess.Supplement_Number__c) {
                    projectIdToProjectToProcessMap.put(projectToProcess.Id, projectToProcess);
                }
            }
        }
        if (projectIdToProjectToProcessMap?.size() > 0) {
            // Fetching the Project record and its related Amendment records, In orde to not copy the Project Number and Supplement Number
            // field value to Latest Project Version and Latest Supplement Number field if Amendment record exists on Project.
            Map<Id, Project__c> projectIdToProjectWithAmendmentMap = new Map<Id, Project__c>([SELECT Id, Name,
                                                            Project_Number__c, Supplement_Number__c,
                                                                (SELECT Id FROM Amendment_Requests__r) FROM Project__c
                                                            WHERE Id IN : projectIdToProjectToProcessMap.keySet()]);
            for (Project__c projectToProcess : projectIdToProjectToProcessMap.values()) {
                Project__c projectToProcessWithRelatedAmendment = projectIdToProjectWithAmendmentMap?.get(projectToProcess.Id);
                // Checking if the Amendment Request does not exist on current Project record.
                if (projectToProcessWithRelatedAmendment?.Amendment_Requests__r?.size() == 0) {
                    // Updating the Latest Project Version field value on Project.
                    if (projectToProcess.Project_Number__c != null) {
                        projectToProcess.Latest_Project_Version__c = projectToProcess.Project_Number__c;
                    }
                    else {
                        projectToProcess.Latest_Project_Version__c = null;
                    }
                    // Updating the Latest Supplement Number field value on Project.
                    if (projectToProcess.Supplement_Number__c != null) {
                        projectToProcess.Latest_Supplement_Number__c = projectToProcess.Supplement_Number__c;
                    }
                    else {
                        projectToProcess.Latest_Supplement_Number__c = null;
                    }
                }
            }
        }
    }
	
	/*********************************************
	* Method Name : updateRetentionAndProjectAwardWithoutRetentionField
	* Called From Method : BeforeInsert, BeforeUpdate
	* Author : Ricky
	* Inputs : -
	* Description: This method is used to update the Total Federal Retention, Total State Retention,
	               Federal Project Award W/o retention and State Project Award W/o Retention field on Project record. and Project. */
    private void updateRetentionAndProjectAwardWithoutRetentionField() {
        // Collection to collect the Project record which needs to be processed.
        List<Project__c> projectToProcessList = new List<Project__c>();
        // Condition to check - While Insert -  Federal Project Award/State Project Award/Federal Retention%/State Retention% is not null on record.
        if (Trigger.isInsert) {
            for(Project__c projectToProcess : (List<Project__c>) Trigger.new) {
                if(projectToProcess.Federal_Project_Award__c != null
                        || projectToProcess.State_Project_Award__c != null
                        || projectToProcess.Federal_Retention__c != null
                        || projectToProcess.State_Retention__c != null) {
                    projectToProcessList.add(projectToProcess);
                }
            }
        }
        // Condition to check - While Update -  Federal Project Award/State Project Award/Federal Retention%/State Retention% is changed on record.
        if (Trigger.isUpdate) {
            for(Project__c projectToProcess : (List<Project__c>) Trigger.new) {
                Project__c oldRecord = (Project__c) Trigger.oldMap.get(projectToProcess.Id);
                if(projectToProcess.Federal_Project_Award__c != oldRecord.Federal_Project_Award__c
                        || projectToProcess.State_Project_Award__c != oldRecord.State_Project_Award__c
                        || projectToProcess.Federal_Retention__c != oldRecord.Federal_Retention__c
                        || projectToProcess.State_Retention__c != oldRecord.State_Retention__c) {
                    projectToProcessList.add(projectToProcess);
                }
            }
        }
        if(projectToProcessList?.size() > 0) {
            for(Project__c projectToProcess : projectToProcessList) {
                // Temporary Variables to avoid null pointer Exceptions..
                Decimal federalProjectAward = projectToProcess.Federal_Project_Award__c == null ? 0.00 : projectToProcess.Federal_Project_Award__c;
                Decimal stateProjectAward = projectToProcess.State_Project_Award__c == null ? 0.00 : projectToProcess.State_Project_Award__c;
                Decimal federalRetention = projectToProcess.Federal_Retention__c == null ? 0.00 : projectToProcess.Federal_Retention__c;
                Decimal stateRetention = projectToProcess.State_Retention__c == null ? 0.00 : projectToProcess.State_Retention__c;

                // Updating the field values..
                projectToProcess.Total_Federal_Retention__c = ((federalProjectAward * federalRetention)/100)?.setScale(2,system.RoundingMode.DOWN);
                projectToProcess.Total_State_Retention__c = ((stateProjectAward * stateRetention)/100)?.setScale(2,system.RoundingMode.DOWN);
                projectToProcess.Federal_Project_Award_W_O_Retention__c = (federalProjectAward - projectToProcess.Total_Federal_Retention__c)?.setScale(2,system.RoundingMode.DOWN);
                projectToProcess.State_Project_Award_W_O_Retention__c = (stateProjectAward - projectToProcess.Total_State_Retention__c)?.setScale(2,system.RoundingMode.DOWN);
            }
        }
    }
    
    /***********************************************
    * Method Name : checkLastSmallProjectPercentage
    * Author : Prajakta
    * Inputs : -
    * Description: This method will check old and new percent complete to date value. This method get fired when funding source is not equal to state only .
    *********************************************/
    private void checkLastSmallProjectPercentage(){
        Set<Id> cdaaProjectIncidentIds = new Set<Id>(); //To collect the Incident Ids...
        Set<Id> cdaaProjectProjectsPercentageValueChanged = new Set<Id>(); //To collect the Program Ids....
        Set<Id> cdaaProjectSubRecipientIds = new Set<Id>(); //To collect the Sub Recipient Ids....
        Set<Id> incidentIds = new Set<Id>(); //To collect the Incident Ids...
        Set<Id> projectsPercentagValueChanged = new Set<Id>(); //To collect the Program Ids....
        Set<Id> subRecipientIds = new Set<Id>(); //To collect the Sub Recipient Ids....
        List<Project__c> projectList =  (List<Project__c>)Trigger.new;
        String fundingSourceType;
        if (Trigger.isUpdate) {
            for (Project__c projectRecord : projectList) {
                if(String.isNotEmpty(projectRecord.Program_Name_For_Flow__c)){
                    fundingSourceType = projectRecord.Program_Name_For_Flow__c;
                }

                system.debug('fundingSourceType'+fundingSourceType);
                Project__c oldRecord = (Project__c) Trigger.oldMap.get(projectRecord.Id);
                    if(oldRecord.Percent_Complete_To_Date__c != 100 && projectRecord.Percent_Complete_To_Date__c == 100 && projectRecord.Program_Name_For_Flow__c == 'PA - Federal' && projectRecord.Was_Ever_Large__c == false){
                        projectsPercentagValueChanged.add(projectRecord.Id);
                        incidentIds.add(projectRecord.Incident_Name__c);
                        subRecipientIds.add(projectRecord.Obligating_Sub_Recipient__c);
                    }
                    if(oldRecord.Percent_Complete_To_Date__c != 100 && projectRecord.Percent_Complete_To_Date__c == 100 && projectRecord.Program_Name_For_Flow__c == 'CDAA (State Funding)' ){
                        system.debug('oldRecord.Percent_Complete_To_Date__c'+oldRecord.Percent_Complete_To_Date__c);
                        system.debug('projectRecord.Percent_Complete_To_Date__c'+projectRecord.Percent_Complete_To_Date__c);
                        system.debug('projectRecord.Id'+projectRecord.Id);
                        cdaaProjectProjectsPercentageValueChanged.add(projectRecord.Id);
                        cdaaProjectIncidentIds.add(projectRecord.Incident_Name__c);
                        cdaaProjectSubRecipientIds.add(projectRecord.Obligating_Sub_Recipient__c);
                    }
            }
            if(cdaaProjectProjectsPercentageValueChanged.size() > 0){
                PA_SystemContextHelper.checkPercentageOfCDAAProjects(projectList,cdaaProjectIncidentIds,cdaaProjectSubRecipientIds,fundingSourceType);

            }

            if(projectsPercentagValueChanged.size() > 0){
                PA_SystemContextHelper.checkPercentageOfFederalProjects(projectList,incidentIds,subRecipientIds,fundingSourceType);

            }

        }
    }

   //CALOESPA-588
    /***********************************************
    * Method Name : updatePercentCompleteToDate
    * Author : Dayal
    * Inputs : -
    * Description: this method update Percent Complete To Date  field on project when it blank or Null Or 0
    *********************************************/
    private void  updatePercentCompleteToDate(){
        List<Project__c> projectList =  (List<Project__c>)Trigger.new;    
        for (Project__c projectRecord : projectList) {                     
            if( (projectRecord.Percent_Complete_To_Date__c == null || projectRecord.Percent_Complete_To_Date__c == 0) && projectRecord.Percent_Complete__c != null){
                projectRecord.Id = projectRecord.Id;                      
                projectRecord.Percent_Complete_To_Date__c = Double.valueOf(projectRecord.Percent_Complete__c);
            }
                               
        }                    
                
    } 

    /***********************************************
    * Method Name : shareProjectRecords
    * Author : Prajakta
    * Inputs : -
    * Description: this method shared the project reocrds
    *********************************************/
    private void shareProjectRecords(){
        List<String> projectIdList = new List<String>();

        if (Trigger.isInsert) {
            for (Project__c project : (List<Project__c>)Trigger.new) {
                if(project.Stage__c != PA_CONSTANTS.PA_PROJECT_NEW_STATUS){
                    projectIdList.add(project.Id);
                }
            }
        }
        if (Trigger.isUpdate) {
            for (Project__c project : (List<Project__c>)Trigger.new){
                Project__c oldRecord = (Project__c) Trigger.oldMap.get(project.Id); //fetching the old Project record...
                if(project.Stage__c != PA_CONSTANTS.PA_PROJECT_NEW_STATUS && oldRecord.Stage__c == PA_CONSTANTS.PA_PROJECT_NEW_STATUS ){
                    projectIdList.add(project.Id);
                }
            }
        }
        ProjectSharingHelper.shareNewProjectRecords(projectIdList);
    }

     /****************************************************************************************************************
    * Method Name : percenToCompleteDateUpdated
    * Author : Dayal
    * Inputs : -
    * Description: Percent complete to date is updated from 100 to any lower value,
                   then delete the Project Closeout linked to the Project and remove the data for
                  �Project Completion Date� and �Date Project was marked 100% Complete� as well.
    ******************************************************************************************************************/
    private void percenToCompleteDateUpdated(){
        List<Project__c> projectIdList = new List<Project__c>();
        
        if (Trigger.isUpdate) {
            for (Project__c project : (List<Project__c>)Trigger.new) {
                Project__c oldRecord = (Project__c) Trigger.oldMap.get(project.Id); //fetching the old Project record...
               // check Percent complete to date is updated from 100 to any lower value,
                if( oldRecord.Percent_Complete_To_Date__c == 100.00 && (project.Percent_Complete_To_Date__c < oldRecord.Percent_Complete_To_Date__c)) {
                   // check if this project contain project closoeut or not
                   List<Project_Closeout__c> projectCloseOutList = [SELECT Id, Name  FROM Project_Closeout__c  where Project_Name__r.Id =: project.Id];
                 
                   if(projectCloseOutList.size() > 0) {
                        delete projectCloseOutList;
                   }

                   Project__c projectData = new Project__c(Id = project.Id, Project_Completion_Date__c = null, Date_Project_Marked_100_Complete__c = null);
                   projectIdList.add(projectData);
                }
            }

            if(projectIdList.size() > 0) {
                PA_SystemContextHelper.upsertProject(projectIdList);
            }
        }
}

	private void preventPercentCompleteToDateUpdate(){
        for (Project__c project : (List<Project__c>)Trigger.new) {
                Project__c oldProject = (Project__c) Trigger.oldMap.get(project.Id); 
                // check Percent complete to date is updated from 100 to any lower value,
                if( oldProject.Percent_Complete_To_Date__c == 100.00 && (project.Percent_Complete_To_Date__c < 100) ) {
                    // check if any CR or CT concerned with project
                    if(String.IsNotBlank(project.Closeout_Request__c) || String.IsNotBlank(project.CloseOut_Task__c)){
                        project.addError('You cannot update the Percent Complete to Date as this Project is still linked to Closeout Request/Closeout Task. Remove Project from Closeout Request/Closeout Task to update this field');
                    }
                }
        }
    }


     /****************************************************************************************************************
    * Method Name : preventProjectNameToUpdate
    * Author : Dayal
    * Inputs : -
    * Description: Only Real Team User can chage the project Name
    ******************************************************************************************************************/
   
    private void preventProjectNameToUpdate(){
        Id profileId= userinfo.getProfileId();
        Boolean hasprojectEditAccess  = FeatureManagement.checkPermission('projectEditAccess');            
       
        for (Project__c project : (List<Project__c>)Trigger.new) {
                Project__c oldProject = (Project__c) Trigger.oldMap.get(project.Id); 
                // check the project name is change or not
                if( oldProject.Name != project.Name  && hasprojectEditAccess == false) {
                    // check if any CR or CT concerned with project
                        project.addError('You do not have permission to change Project  Name');                   
                }                  
        }   
        
    }        
}