public with sharing class AwardTriggerHelper extends TriggerHelper{
    public override void processBeforeInsert(){
        //copyAwardPeriodFromProject();
    }
    public override void processAfterUpdate(){
        updateAwardsOfPendingPayments();
    }

    private void updateAwardsOfPendingPayments(){
        Set<Id> projectIds = new Set<Id>(); //To collect Proejct Id of the Award, in order to fetch current Active Award for it..
        Set<Id> awardIds = new Set<Id>(); // To collect Award ID , in order to fetch the Inactive Award Payment Requests..
        Set<Id> paymentIds = new Set<Id>(); // To collect Payment Request ID , in order to fetch the Inactive Award Payment Requests..
        List<Id> paymentRequestIds = new List<Id>(); // To collect Payment Request ID , in order to fetch the Inactive Award Payment Requests..
        List<Award__c> awardToUpdate = new List<Award__c>();
        Map<Id,Award__c> proejctIdToActiveAwardMap = new Map<Id,Award__c>();
        Map<Id, Award__c> awardToPaymentMap; // To fetch all the Payment Request and its related Payments...
        List<Payment_Request__c> paymentsToUpdate = new List<Payment_Request__c>(); //To collect the Payment Request for updating Award field..
        Map<Id,List<Payment_Request__c>> awardToPaymentRequestAndPayments = new Map<Id,List<Payment_Request__c>>(); //To Store Payment Request and related Payments with Award ID as Key...
        for(Award__c awardToProcess : (List<Award__c>)Trigger.new){
            Award__c oldAwardRecord = (Award__c)Trigger.oldMap.get(awardToProcess.Id); // Fetching the Old Award record from trigger.o;dMap in order to compare the Status..
            if(awardToProcess.Status__c != oldAwardRecord.Status__c && awardToProcess.Status__c == ALS_CONSTANTS.Award_Status_Inactive
                    && oldAwardRecord.Status__c == ALS_CONSTANTS.Award_Status_Active){ //Comparing the old and new Status of the Award Record...
                projectIds.add(awardToProcess.Project__c); //Collecting the Project Ids for the Award record..
                awardIds.add(awardToProcess.Id); //Collecting the Award record Id....
            }
        }
        if (projectIds.size() > 0) {
            //Fetching tha Active Award of the Project whose record Id is inn  "awardIds" collection and Project Id is in "projectIds" Collection...
            List<Award__c> activeAwardList = [SELECT Id, Project__c, Status__c
                                                FROM Award__c WHERE Project__c IN : projectIds
                                                AND Status__c =: ALS_CONSTANTS.Project_Status_Active];
            for(Award__c award : activeAwardList) {
                proejctIdToActiveAwardMap.put(award.Project__c , award); //Mapping the Project with its Active Award in a Map collection...
            }
            //Fetching Payment Requests of the Award...
            /* awardToPaymentMap = new Map<Id, Award__c>([SELECT Id, Project__c,
                                                            (SELECT Id, Award__c,Stage__c FROM Payment_Requests__r)
                                                        FROM Award__c WHERE Id IN : awardIds]); */
            //Fetching Payment Requests of the Award...
            awardToPaymentMap = new Map<Id, Award__c>([SELECT Id, Project__c,
                                                        (SELECT Id, Award__c,Stage__c FROM Payment_Requests__r
                                                            WHERE Stage__c =: ALS_CONSTANTS.PR_Stage_New
                                                            OR Stage__c =: ALS_CONSTANTS.PR_Stage_Processing
                                                            OR Stage__c =: ALS_CONSTANTS.PR_Stage_InReview
                                                            OR Stage__c =: ALS_CONSTANTS.PR_Stage_ReviewedNeedsInformation)
                                                        FROM Award__c WHERE Id IN : awardIds]);
            for (Award__c awardRecordToProcess  : awardToPaymentMap.values()) {
                for(Payment_Request__c paymentToProcess : awardRecordToProcess.Payment_Requests__r){
                    paymentIds.add(paymentToProcess.Id);
                }
            }

            //List<String> prFields = getAllFields(ALS_CONSTANTS.PR_ObjectAPIName); //Fetching all the fields of Payment Request Object..
            //List<String> paymentFields = getAllFields(ALS_CONSTANTS.Payment_ObjectAPIName); //Fetching all the fields of Payment Object..
            //Fetching the Data of Payment Request with all related Payments..
            //String query =' SELECT '+String.join( prFields, ',' ) + ',(SELECT '+String.join( paymentFields, ',' )+ ' FROM Payments__r)'  +' FROM Payment_Request__c';
            String query =' SELECT Id,Award__c,Stage__c' +' FROM Payment_Request__c';
            List<Payment_Request__c> prList=Database.query(query);

            //Iterating the collection to fetch all the PR and put it in a Map collection as Award as Key and PRS as value to it.....
            for(Payment_Request__c prRecord : prList){
                if(awardToPaymentRequestAndPayments.containsKey(prRecord.Award__c)){
                    Payment_Request__c[] pRequest = awardToPaymentRequestAndPayments.get(prRecord.Award__c);
                    pRequest.add(prRecord);
                    awardToPaymentRequestAndPayments.put(prRecord.Award__c, pRequest);
                }
                else{
                    Payment_Request__c[] pRequest = new Payment_Request__c[]{};
                    pRequest.add(prRecord);
                    awardToPaymentRequestAndPayments.put(prRecord.Award__c, pRequest);
                }
            }

            //Iterating the awardToPaymentMap collection in order to update the Award of the UnPaid Payment requests....
            for (Award__c awardRecordToProcess  : awardToPaymentMap.values()) {
                Award__c newActiveAward = proejctIdToActiveAwardMap.get(awardRecordToProcess.Project__c); // Fetching the new Active Award of the Project..
                //String prSnapshot = JSON.serialize(awardToPaymentRequestAndPayments.get(awardRecordToProcess.Id)); // Converting all the PRs and Payment of Old Award record into JSON Format...
                //awardRecordToProcess.PR_Snapashot__c = prSnapshot; //Storing the JSON into a Award object field..
                //awardToUpdate.add(awardRecordToProcess); //Adding the Award record to a collection for updating...
                for (Payment_Request__c paymentToProcess : awardRecordToProcess.Payment_Requests__r) {
                    if (!Approval.isLocked(paymentToProcess.Id)) { 
                        paymentToProcess.Award__c = newActiveAward.Id; //Updating the new Active Award to PR.....
                        paymentsToUpdate.add(paymentToProcess); //Adding PR to a collection to update it.....
                    }

                    /*if(paymentToProcess.Stage__c == ALS_CONSTANTS.PR_Stage_PaymentProcessing
                            || paymentToProcess.Stage__c == ALS_CONSTANTS.PR_Stage_InReview ){ //Checking for the PR stages in which the record is being in Approval locked...
                        if (Approval.isLocked(paymentToProcess.Id)) {
                            paymentRequestIds.add(paymentToProcess.Id); //Adding PR Id to collection in order to Unlock it before updating the Award adn then lock it back....
                            paymentToProcess.Award__c = newActiveAward.Id; //Updating the new Active Award to PR.....
                            paymentsToUpdate.add(paymentToProcess); //Adding PR to a collection to update it.....
                        }
                    }
                    else if (paymentToProcess.Stage__c != ALS_CONSTANTS.PR_Stage_ReturnedProjectPayment
                            && paymentToProcess.Stage__c != ALS_CONSTANTS.PR_Stage_Paid
                            && paymentToProcess.Stage__c != ALS_CONSTANTS.PR_Stage_Withdrawn) { //Checking for another Stages for which Award field of PR needs to be updated...
                        paymentToProcess.Award__c = newActiveAward.Id; //Updating the new Active Award to PR.....
                        paymentsToUpdate.add(paymentToProcess); //Adding PR to a collection to update it.....
                    }*/
                }
            }
            if (paymentsToUpdate.size() > 0) {
                //Updating the Old Active Awards...
                //update awardToUpdate; //Updating the Award record...
                update paymentsToUpdate; // Updating the PR records.....

                /*//To updated the unapproved Payment Request's Award to new Active Award....
                AwardTriggerHelper.InnerClassforUnlockingAndLocking innerClassObj = new AwardTriggerHelper.InnerClassforUnlockingAndLocking();
                List<Approval.UnlockResult> unlockPRLists = innerClassObj.unlockPaymentRequest(paymentRequestIds); //Unlocking the  locked PR record.....
                update paymentsToUpdate; // Updatin g the PR records.....
                List<Approval.LockResult> lockRecords = innerClassObj.lockPaymentRequest(paymentRequestIds); //Locking back the PR records which were Approval lock..
                */
            }
        }
    }

    //To fetch all the fields available on an Object...
    /*public static List<String> getAllFields(String objectName) {
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        List<String> selectFields = new List<String>();

        if (fMap != null){
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                selectFields.add(fd.getName());
            }
        }
        return selectFields;
    }*/
 }