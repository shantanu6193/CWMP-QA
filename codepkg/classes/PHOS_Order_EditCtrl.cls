/***********************************************************************************************************************************
* Class Name   : PHOS_Order_EditCtrl
* Description  : This class for Process the order
* Author       : Pankaj
* Created On   : 03/29/2020
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Pankaj              03/29/2020      Initial Implementation
**************************************************************************************************************************************/

public without sharing class PHOS_Order_EditCtrl {

    /***********************************************
    * Method Name : saveOrder
    * Author : Pankaj
    * Inputs : Map<String, Object> paramMap
    * Description: This method upsert order and order products record and return map of Order and order products records
    *********************************************/
    @AuraEnabled
    public static Map<String, Object> saveOrder(String recordData, Boolean quickSave) {
        try {
            Order__c orderRec = (Order__c)JSON.deserialize(recordData, Order__c.class);
            List<Order_Product__c> orderItems = orderRec.Order_Products__r;
            /*Order__c orderRec = (Order__c)JSON.deserialize(String.valueOf(paramMap.get('Order')), Order__c.class);
            Boolean quickSave = (Boolean)paramMap.get('QuickSave');
            List<Order_Product__c> orderItems = (List<Order_Product__c>) JSON.deserialize(String.valueOf(paramMap.get('OrderItems')), List<Order_Product__c>.class);*/
            Boolean isCommunityUser = false;
            User user = ApexUtils.getCurrentUserDetails();
            if (String.isEmpty(user.AccountId) ) {
                //processRequestorAgencyForInternal(orderRec);
            } else {
                isCommunityUser = true;
                if(orderRec.Account__c == null) {
                    orderRec.Account__c = user.AccountId;
                }
                if(orderRec.Creator_Contact__c == null) {
                    orderRec.Creator_Contact__c = user.ContactId;
                }
            }
            Boolean submitRecordForApprovalProcess = false;
            if(quickSave == false) {
                if(orderRec.Status__c == PHOS_Constants.ORDER_STATUS_DRAFT || String.isEmpty(orderRec.Id)){
                    submitRecordForApprovalProcess = true;
                    if (UserInfo.getUserType() == 'Standard' || (user.Contact.Account.Entity_Type__c != null && user.Contact.Account.Entity_Type__c == 'Region' )) {
                        orderRec.Status__c = PHOS_Constants.ORDER_STATUS_CDPH_RESOURCE_REQUEST_SUPERVISOR_REVIEW;//'RDMHS Review';
                    } else if((user.Contact.Account.Parent.Entity_Type__c != null  && user.Contact.Account.Parent.Entity_Type__c == 'Region') ){
                        orderRec.Status__c = PHOS_Constants.ORDER_STATUS_RDMHS_REVIEW;
                    } else {
                        orderRec.Status__c = PHOS_Constants.ORDER_STATUS_MHOAC_REVIEW;
                    }
                }
            } else {
                if(String.isEmpty(orderRec.Status__c)) {
                    orderRec.Status__c = PHOS_Constants.ORDER_STATUS_DRAFT;
                }
            }
            if (String.isEmpty(orderRec.Id)) {
                submitRecordForApprovalProcess = true;
                if(orderRec.Order_Submitted_Date__c == null){
                    orderRec.Order_Submitted_Date__c = System.today();
                }

                orderRec.RecordTypeId = Schema.SObjectType.Order__c.getRecordTypeInfosByDeveloperName()
                        .get('PHOS').getRecordTypeId();
            } else {
                AppUtils.generateSnapshotInJSON(orderRec.Id);
                //delete orderItems which are deleted on UI
                List<String> orderItemIds = new List<String>();
                for (Order_Product__c orderItem : orderItems) {
                    if(String.isNotEmpty(orderItem.Id)) {
                        orderItemIds.add(orderItem.Id);
                    }
                }
                List<Order_Product__c> orderItemsToDelete = new List<Order_Product__c>();
                if (orderItemIds.size() == 0) {
                    orderItemsToDelete = [SELECT Id FROM Order_Product__c WHERE Order__c=:orderRec.Id];
                } else {
                    orderItemsToDelete = [SELECT Id FROM Order_Product__c WHERE Order__c=:orderRec.Id AND Id NOT IN :orderItemIds];
                }
                delete orderItemsToDelete;
            }
            orderRec.OwnerId = UserInfo.getUserId();

            upsert orderRec;

            processOrderItems(orderItems, orderRec);

            if(submitRecordForApprovalProcess && quickSave == false) {
                processApprovalRequest(orderRec, isCommunityUser, user);
            }

            //create entry into Resource Request Question & Answer object
            createQuestionsAndAnswers(orderRec);

            Order__c orderRec1 = [SELECT Id,Name FROM Order__c WHERE Id=:orderRec.Id];
            Map<String, Object> returnMap = new Map<String, Object>();
            returnMap.put('OrderRec', orderRec);
            returnMap.put('OrderNumber', orderRec1.Name);
            returnMap.put('OrderItems', orderItems);
            returnMap.put('Id', orderRec.Id);
            return returnMap;

        }catch(Exception ex){
            if(Test.isRunningTest()) {
                throw ex;
            }
            throw new AuraHandledException(ex.getMessage());
        }
    }
    /***********************************************
    * Method Name : createQuestionsAndAnswers
    * Author : Shivraj
    * Inputs : Order__c orderRec
    * Description: This method create entry into Resource Request Question & Answer object
    *********************************************/
    public static void createQuestionsAndAnswers(Order__c order) {
        Order__c orderRec = [SELECT Id,Additional_beds_Total_staff__c,Bed_to_staff_ratio_bed_staff__c, Does_site_need_personnel_to_keep_ICU__c,Total_ICU_beds_occupied__c,
                Have_you_attempted_to_transfer_patients__c, Have_you_cancelled_all_surgeries__c,
                Do_you_have_an_active_staffing_waiver__c, Would_you_be_able_to_accept_transfers__c, Is_this_for_a_GACH__c,
                Is_this_a_Medical_Staffing_Request__c,Allows_additional_ICU_or_M_S_T_beds__c,
                Average_time_of_T_to_T_for_ESI_Cat_3__c,How_many_total_staff_are_you_requesting__c, ICU_beds_available_in_the_County__c,
                Is_the_facility_a_specialty_center__c, Population_65_years_old_in_county__c, What_is_the_county_s_7_day_case_rate__c,
                What_is_the_county_s_population_density__c, First_date_of_Event__c, How_many_clients_expected__c, Is_allocation_amount_sufficient__c,
                What_is_closest_phase_tier__c,What_is_the_site_name__c,Clients_Anticipated_at_Site__c,Doses_Anticipated_per_Day__c,Doses_per_Day_Previous_Events__c,
                What_status_is_the_event_currently_in__c,Confirm_Compliance_Checkboxes__c,Compliance_Narrative__c,We_provide_staff_for_vaccination_events__c,
                What_of_County_population_vaccinated__c,Hospital_Burden_Score__c,Using_team_nursing_and_out_of_ratio__c,
                What_is_current_census_of_COVID_patients__c,What_is_current_total_patient_census__c
        FROM    Order__c WHERE Id =: order.Id];
        Map<String, Map<String, Decimal>> mapQuestionToQA = new Map<String, Map<String, Decimal>>();
        Map<String, String> mapQuestionAPIToQuestion = new Map<String, String>();
        List<Question_Answer_Rating__mdt> questionAnswerRatingsList = [SELECT Id, MasterLabel, Question__r.Question_Field_API_Name__c,Question__r.Question__c, Rating_Score__c,Override_Label__c FROM Question_Answer_Rating__mdt];
        for (Question_Answer_Rating__mdt  questionAnswersRatings : questionAnswerRatingsList) {
            if(questionAnswersRatings.Override_Label__c != null) {
                questionAnswersRatings.MasterLabel = questionAnswersRatings.Override_Label__c;
            }
            if(mapQuestionToQA.get(questionAnswersRatings.Question__r.Question_Field_API_Name__c) == null) {
                mapQuestionToQA.put(questionAnswersRatings.Question__r.Question_Field_API_Name__c, new Map<String, Decimal>());
            }
            mapQuestionToQA.get(questionAnswersRatings.Question__r.Question_Field_API_Name__c).put(questionAnswersRatings.MasterLabel, questionAnswersRatings.Rating_Score__c);
            mapQuestionAPIToQuestion.put(questionAnswersRatings.Question__r.Question_Field_API_Name__c, questionAnswersRatings.Question__r.Question__c);
        }

        List<Resource_Request_Question_Answer__c> resourceRequestQuestionAnswersInsertList = new List<Resource_Request_Question_Answer__c>();
        List<Resource_Request_Question_Answer__c> qaDeleteList = [SELECT Id FROM Resource_Request_Question_Answer__c where Order__c =: orderRec.Id];
        if(!qaDeleteList.isEmpty() && qaDeleteList != null) delete qaDeleteList;

        for(String questionAPIName : mapQuestionToQA.keySet()) {
            String answer = (String)orderRec.get(questionAPIName);
            if(String.isNotBlank(answer)) {
                Map<String, Decimal> mapAnswerToRating = mapQuestionToQA.get(questionAPIName);
                Resource_Request_Question_Answer__c requestQuestionAnswer = new Resource_Request_Question_Answer__c();
                requestQuestionAnswer.Question__c = mapQuestionAPIToQuestion.get(questionAPIName);
                requestQuestionAnswer.Order__c = orderRec.Id;
                requestQuestionAnswer.Answer__c = answer;
                requestQuestionAnswer.Rating_Score__c = mapAnswerToRating.get(answer);
                resourceRequestQuestionAnswersInsertList.add(requestQuestionAnswer);
            }
        }
        insert resourceRequestQuestionAnswersInsertList;
    }
    /***********************************************
    * Method Name : processOrderItems
    * Author : Pankaj
    * Inputs : List<Order_Product__c> orderItems, Order__c orderRec
    * Description: This method upsert the order products records
    *********************************************/
    private static void processOrderItems(List<Order_Product__c> orderItems, Order__c orderRec) {
        //List<String> productIds = new List<String>();
        for (Order_Product__c orderItem : orderItems) {
            if(String.isEmpty(orderItem.Product__c)) continue;
            if (String.isEmpty(orderItem.Order__c)) {
                orderItem.Order__c = orderRec.Id;
            }
            if (orderItem.Unit_Price__c == null) {
                orderItem.Unit_Price__c = 0;
            }
        }
        upsert orderItems;
    }

    /*IF account not exist then create new account or return exiting account based on account name*/
    /*private static void processRequestorAgencyForInternal(Order__c orderRec) {
        if(orderRec.Id != null) {
            //if account name is same as previous then skip
            Order__c oldOrderRec = [SELECT Requestor_Agency_Text__c FROM Order__c WHERE Id=:orderRec.Id];
            if(oldOrderRec.Requestor_Agency_Text__c == orderRec.Requestor_Agency_Text__c) return;
        }
        // check if account already exist. If not then create new account
        Account account = null;

        List<Account> accountList = [select id, name from Account where Name =:orderRec.Requestor_Agency_Text__c];
        if(accountList.size() > 0){
            account = accountList.get(0);
        }else{
            account = new Account(Name=orderRec.Requestor_Agency_Text__c);
            insert account;
        }
        if(orderRec.Account__c == null) {
            orderRec.Account__c = account.Id;
        }
    }*/

    /***********************************************
    * Method Name : processApprovalRequest
    * Author : Pankaj
    * Inputs : Order__c orderRec, Boolean isCommunityUser, User user
    * Description: This method call the Approval process method
    *********************************************/
    private static void processApprovalRequest(Order__c orderRec, Boolean isCommunityUser, User user) {
        // Submit on behalf of a specific submitter
        // Submit the record to specific process and skip the criteria evaluation
        System.debug('isCommunityUser-------'+isCommunityUser);
        if(isCommunityUser){
            system.debug('In RDMHS_Review_Process approval process');
            processRDMSHApprovalRequest(orderRec.Id, user, 'Submitting request for approval.');
            //req1.setProcessDefinitionNameOrId('RDMHS_Review_Process');
        }/*else{
            system.debug('In CDPH_Team_Review approval process');
            processCDPHTeamApprovalRequest(new List<Id>{orderRec.Id});
        }*/
    }

    /***********************************************
    * Method Name : submitForRDMSHApprovalRequest
    * Author : Pankaj
    * Inputs : String orderId, String comment
    * Description: This method update order record and call approval process method
    *********************************************/
    @AuraEnabled
    public static void submitForRDMSHApprovalRequest(String orderId, String comment) {
        Boolean isLocked = Approval.isLocked(orderId);
        if(isLocked == true) {
            throw new AuraHandledException('Record already in approval');
        }
        Order__c order = [Select Id, Status__c from Order__c where Id =: orderId];
        if(order.Status__c == PHOS_Constants.ORDER_STATUS_DRAFT || order.Status__c == PHOS_Constants.ORDER_STATUS_MHOAC_REVIEW || order.Status__c == PHOS_Constants.ORDER_STATUS_RDMHS_REVIEW) {
            User userRec = ApexUtils.getCurrentUserDetails();
             //CH01 Start
            // For call approval process RDMHS and MHOAC

            Order__c orderRec;
            /* if((userRec.Contact.Account.Parent.Entity_Type__c != null  && userRec.Contact.Account.Parent.Entity_Type__c == 'Region') ||  (userRec.Contact.Account.Entity_Type__c!= null && userRec.Contact.Account.Entity_Type__c == 'Region' ))
            {
                orderRec = new Order__c(Id=orderId, Status__c=PHOS_Constants.ORDER_STATUS_RDMHS_REVIEW);
                update orderRec;
             }else if(userRec.Contact.Account.Entity_Type__c!= null && userRec.Contact.Account.Entity_Type__c == 'County'){
                orderRec = new Order__c(Id=orderId, Status__c = PHOS_Constants.ORDER_STATUS_MHOAC_REVIEW);
                update orderRec;
            }*/
            if((userRec.Contact.Account.Parent.Entity_Type__c != null  && userRec.Contact.Account.Parent.Entity_Type__c == 'Region') ||  (userRec.Contact.Account.Entity_Type__c != null && userRec.Contact.Account.Entity_Type__c == 'Region' )){
                orderRec = new Order__c(Id=orderId, Status__c=PHOS_Constants.ORDER_STATUS_RDMHS_REVIEW);
                update orderRec;
            } else {
                orderRec = new Order__c(Id=orderId, Status__c = PHOS_Constants.ORDER_STATUS_MHOAC_REVIEW);
                update orderRec;
            }
            //CH01 End
           // orderRec = new Order__c(Id=orderId, Status__c=PHOS_Constants.ORDER_STATUS_RDMHS_REVIEW);
           // update orderRec;

            processRDMSHApprovalRequest(orderId, ApexUtils.getCurrentUserDetails(), comment);
        } else {
            throw new AuraHandledException('Order cannot be resubmitted once approved');
        }

    }

    /***********************************************
    * Method Name : orderApprovalRequestFromCountyUSER
    * Author : Pankaj
    * Inputs : List<Id> orderIds
    * Description: This method call approval process method
    *********************************************/
    @InvocableMethod(label='Order Approval Request from County USER' description='Order Approval Request from County USER')
    public static void orderApprovalRequestFromCountyUSER(List<Id> orderIds) {
        User userRec = ApexUtils.getCurrentUserDetails();
        if(userRec.ContactId != null) {
            String userType= userRec.Contact.Account.Entity_Type__c == 'County' ? 'County' : 'Medical Facility';
            processRDMSHApprovalRequest(orderIds[0], userRec, 'Order Approval From '+userType+' User');
        } else if(userRec.ContactId == null) {
            processRDMHSApprovalForInternal(orderIds[0], userRec, 'Order Approval From Internal User on behalf of MHOAC');
        }

    }

    /*private static User getCurrentUserDetails() {
        return [SELECT Id,AccountId,Account.ParentId,
                Contact.Account.Parent.Queue_Name__c,
                Contact.Account.Queue_Name__c
        FROM User WHERE Id=:UserInfo.getUserId()];
    }*/

    /***********************************************
    * Method Name : processRDMSHApprovalRequest
    * Author : Pankaj
    * Inputs : String orderId, User userRec, String comment
    * Description: This method submit record for approval 
    *********************************************/
    private static void processRDMSHApprovalRequest(String orderId, User userRec, String comment){
        if(userRec.Contact.Account.Entity_Type__c == 'Region') return;// Order created by Region user then no need for Approve
        String queueName = userRec.Contact.Account.Parent.Queue_Name__c;
        if(String.isEmpty( queueName )) {
            queueName = userRec.Contact.Account.Queue_Name__c;
        }
        if(String.isEmpty( queueName )) return;
        List<Group> queues = [SELECT Id FROM Group WHERE DeveloperName=:queueName AND Type='Queue'];
        if(queues.size() == 0) throw new AuraHandledException('Queue is empty'); //Todo throw exception instead of return - done
        List<Approval.ProcessSubmitRequest> approvalRequestList = new List<Approval.ProcessSubmitRequest>();
        List<Id> userIdsToApprove = new List<Id>();
        Approval.ProcessSubmitRequest req1 =new Approval.ProcessSubmitRequest();
        req1.setComments(comment);
        req1.setObjectId(orderId);
        //CH01 Start
        //order is created by County user then approve by RDMHS
        //if(userRec.Contact.Account.Entity_Type__c != null  && userRec.Contact.Account.Entity_Type__c == 'County'){
        if((userRec.Contact.Account.Parent.Entity_Type__c != null  && userRec.Contact.Account.Parent.Entity_Type__c == 'Region') ||  (userRec.Contact.Account.Entity_Type__c != null && userRec.Contact.Account.Entity_Type__c == 'Region' )){
            req1.setProcessDefinitionNameOrId(PHOS_Constants.ORDER_APPROVAL_RDMHS_REVIEW_PROCESS);
         }else { //order is created by Hospital user then approve by MHOAC
           req1.setProcessDefinitionNameOrId(PHOS_Constants.ORDER_APPROVAL_MHOAC_REVIEW_PROCESS);
        } 
        //CH01 End
       // req1.setProcessDefinitionNameOrId(PHOS_Constants.ORDER_APPROVAL_RDMHS_REVIEW_PROCESS);
        //System.assertEquals(userIdsToApprove.size(), 43);
        req1.setNextApproverIds(new List<String>{queues.get(0).Id});
        req1.setSkipEntryCriteria(true);

        approvalRequestList.add(req1);
        System.debug('approvalRequestList 204 => '+approvalRequestList);
        if(approvalRequestList.size() > 0) {
            Approval.process(approvalRequestList);
        }
    }
    
    /***********************************************
    * Method Name : processRDMHSApprovalForInternal
    * Author : Pankaj
    * Inputs : String orderId, User userRec, String comment
    * Description: This method submit record for approval for RDMHS user
    *********************************************/
    private static void processRDMHSApprovalForInternal(String orderId, User userRec, String comment){
        Map<String, String> mapQueueNameToID = new Map<String, String>();
        List<Approval.ProcessSubmitRequest> approvalRequestList = new List<Approval.ProcessSubmitRequest>();
        List<Group> queues = [SELECT Id,DeveloperName FROM Group WHERE Type='Queue'];
        String queueNameForApproval;
        for(Group queueName : queues) {
            mapQueueNameToID.put(queueName.DeveloperName, queueName.Id);
        }
        List<Order__c> orderRecord = [SELECT Id,Creator_Contact__r.Account.Parent.Queue_Name__c,Creator_Contact__r.Account.Parent.Parent.Queue_Name__c
                                        FROM Order__c WHERE Id =:orderId];
        if(String.isNotBlank(orderRecord[0].Creator_Contact__r.Account.Parent.Parent.Queue_Name__c)) {
            queueNameForApproval = orderRecord[0].Creator_Contact__r.Account.Parent.Parent.Queue_Name__c;
        } else {
            queueNameForApproval = orderRecord[0].Creator_Contact__r.Account.Parent.Queue_Name__c;
        }
        
        if(String.isNotBlank(queueNameForApproval)) {
            Approval.ProcessSubmitRequest req1 =new Approval.ProcessSubmitRequest();
            req1.setComments(comment);
            req1.setObjectId(orderId);
            req1.setProcessDefinitionNameOrId(PHOS_Constants.ORDER_APPROVAL_RDMHS_REVIEW_PROCESS);
            req1.setNextApproverIds(new List<String>{mapQueueNameToID.get(queueNameForApproval)});
            req1.setSkipEntryCriteria(true);
            approvalRequestList.add(req1);
            if(approvalRequestList.size() > 0) {
                Approval.process(approvalRequestList);
            }
        }
    }
    /*@InvocableMethod(label='Submit Request for CDPH' description='submit Request for CDPH')
    public static void processCDPHTeamApprovalRequest(List<Id> orderIds) {
        for(String orderId : orderIds) {
            //if(Approval.isLocked(orderId)) return;
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting request for approval.');
            req1.setObjectId(orderId);
            req1.setProcessDefinitionNameOrId('CDPH_Team_Review');
            req1.setSkipEntryCriteria(true);
            // Submit the approval request for the account
            Approval.ProcessResult result = Approval.process(req1, false);
        }

    }*/

    /*@AuraEnabled
    public static void updateStatus(String orderId) {
        Order order = new Order(Id=orderId, Status='CDPH Resource Request Supervisor Review');
        update order;
    }*/

    /***********************************************
    * Method Name : getOrders
    * Author : Pankaj
    * Inputs : String orderId
    * Description: This method return map of order and order products records
    *********************************************/
    @AuraEnabled
    public static Map<String, Object> getOrders(String orderId) {
        Map<String, Object> returnMap = new Map<String, Object>();
        Order__c orderRec = [
                SELECT
                        Account__c,
                        Account__r.Entity_Type__c,
                        Incident_Name__c,
                        Incident__c,
                        CreatedById,
                        CreatedDate,
                        Delivery_Recipient_First_Name_Text__c,Delivery_Recipient_Last_Name_Text__c,Delivery_Recipient_Title_Text__c,Delivery_Recipient_Email_Text__c,Delivery_Recipient_Phone_Text__c,
                        Description__c,
                        Id,
                        LastModifiedDate,
                        Name,
                        Requestor__c,Requestor_First_Name_Text__c,Requestor_Last_Name_Text__c,Requestor_Title_Text__c,Requestor_Email_Text__c,Requestor_Phone_Text__c,Requestor_Agency_Text__c,
                        Delivery_Recipient_Entity_Name__c,
                        Address_Geolocation__Latitude__s, Address_Geolocation__Longitude__s,
                        Shipping_City__c,
                        Shipping_Country__c,
                        Shipping_ZipPostal_Code__c,
                        Shipping_State__c,
                        Shipping_Street__c,
                        Shipping_Street_2__c,
                        Status__c,
                        County__c,
                        SuppliesEquipment__c,
                        Personnel__c,
                        Delivery_Notes__c,
                        Other_Request_Number_If_Applicable__c,
                        Mission_Request_Number_If_Applicable__c,
                        PHM_EOM_Confirmed__c,
                        RDMHS_Program_Confirmed__c,
                        Type_Of_Resource_Other__c,
                        Priority_for_Requests__c,
                        Actions_Taken_On_This_Request__c,
                        Industry__c,
                        Current_Stage__c,
                        Sub_Industry__c,
                        Creator_Contact__c,
                        Bed_to_staff_ratio_bed_staff__c, Does_site_need_personnel_to_keep_ICU__c,Total_ICU_beds_occupied__c,
                        Have_you_attempted_to_transfer_patients__c, Have_you_cancelled_all_surgeries__c,
                        Do_you_have_an_active_staffing_waiver__c, Would_you_be_able_to_accept_transfers__c, Is_this_for_a_GACH__c,
                        Is_this_a_Medical_Staffing_Request__c,Allows_additional_ICU_or_M_S_T_beds__c,
                        Average_time_of_T_to_T_for_ESI_Cat_3__c,How_many_total_staff_are_you_requesting__c,                    What_is_the_site_name__c,
                        Clients_Anticipated_at_Site__c,
                        Doses_Anticipated_per_Day__c,
                        Doses_per_Day_Previous_Events__c,
                        What_status_is_the_event_currently_in__c,
                        Confirm_Compliance_Checkboxes__c,
                        Compliance_Narrative__c,Using_team_nursing_and_out_of_ratio__c,
                        We_provide_staff_for_vaccination_events__c,
                        School_Requirements_Confirmation__c,
                        What_of_County_population_vaccinated__c,Hospital_Burden_Score__c,
                        What_is_current_total_patient_census__c,What_is_current_census_of_COVID_patients__c
                FROM Order__c WHERE Id=:orderId];
        List<Order_Product__c> orderItems = [
                SELECT
                        Cost__c,
                        CreatedById,
                        CreatedDate,
                        Description__c,
                        Estimated_time_of_Arrival__c,
                        Id,
                        IsDeleted,
                        LastModifiedById,
                        LastModifiedDate,
                        Order__c,
                        Name,
                        Product__c,
                        Product__r.Family,
                        Quantity__c,
                        Total_Price__c,
                        Tracking__c,
                        Unit_Price__c,
                        Item_Code__c,
                        Quantity_Filled__c,
                        Quantity_Approved__c,
                        Quantity_Back_Ordered__c,
                        Equivalent_Substitutes_Acceptable__c,
                        Delivered_On_Date__c,
                        Carrier_Tracking__c,
                        Fulfilment_Entity_Warehouse__c,
                        Product_Family__c,
                        Product_Name__c
                FROM Order_Product__c WHERE Order__c=:orderId];
        returnMap.put('Order', orderRec);
        returnMap.put('OrderItems', orderItems);
        Boolean showRecordLockedError = false;
        Boolean orderApproved = false;
        Boolean isLocked = Approval.isLocked(orderId);
        Boolean hasRecordAccess = ApexUtils.checkIfCurrentUserHasEditAccess(orderId);
        User userRec = ApexUtils.getCurrentUserDetails();
        Set<String> orderStatuses = new Set<String>{'Draft', 'MHOAC Review', 'RDMHS Review'};
        if(hasRecordAccess == true && isLocked == true){
            showRecordLockedError = ApexUtils.showErrorWhenRecordLocked(orderId);
        } else if(!orderStatuses.contains(orderRec.Status__c) && userRec.AccountId != null) {
            showRecordLockedError = true;
            orderApproved = true;
        }
        returnMap.put('ShowRecordLockedError',showRecordLockedError);
        returnMap.put('OrderApproved',orderApproved);
        if(userRec.AccountId != null) {
            returnMap.put('isCommunityUser',true);
        } else {
            returnMap.put('isCommunityUser',false);
        }
        boolean isCountyChild = false;
        if(userRec.Contact.Account.Parent.Entity_Type__c != null  && userRec.Contact.Account.Parent.Entity_Type__c == 'County'){
            isCountyChild = true;
        }
        returnMap.put('CountyChild',isCountyChild);
        return returnMap;
    }

    /***********************************************
    * Method Name : getRecipientContact
    * Author : Pankaj
    * Inputs : -
    * Description: This method return map of contact and user records
    *********************************************/
    @AuraEnabled
    public static Map<String, Object> getRecipientContact() {
        Map<String, Object> returnMap = new Map<String, Object>();
        /*Profile userProfile = [Select Name from Profile where Id =: UserInfo.getProfileId() ];
        String profileName = userProfile.name;*/
        Boolean isCommunityUser;
        if(ApexUtils.checkCommunityUser()){
            isCommunityUser = true;
        }
        else {
            isCommunityUser = false;
        }
        User user = [select id,AccountId, contactId,County__c from User where id =: UserInfo.getUserId()];
        if(user.contactId != null) {
            Contact contact = [select Id, FirstName, LastName, Title, Account.Name, Email, Phone, Account.Entity_Type__c,Account.ParentId,Account.Parent.Entity_Type__c,Account.Parent.Name from Contact where Id=:user.contactId];
            returnMap.put('contact', contact);
        }
        returnMap.put('IsCommunityUser',isCommunityUser);
        returnMap.put('user', user);
        return returnMap;
    }

    /***********************************************
    * Method Name : getVersion
    * Author : Pankaj
    * Inputs : String orderVersionId
    * Description: This method return map of order version
    *********************************************/
    @AuraEnabled
    public static Map<String, Object> getVersion(String orderVersionId){
        /*Map<String, Object> returnMap = new Map<String, Object>();
        system.debug('--orderVersionId= '+orderVersionId);
        Order_Version__c orderVersion = [SELECT Id,Order__c, Version_Data__c FROM Order_Version__c where Id=:orderVersionId];
        system.debug('--orderVersion= '+orderVersion);
        Order orderRec = (Order)JSON.deserialize(orderVersion.Version_Data__c, Order.class);
        //Map<String, Object> temp = (Map<String, Object>) JSON.deserializeUntyped(orderVersion.Version_Data__c);
        returnMap.put('orderRec', orderRec);
        returnMap.put('orderItems', orderRec.OrderItems);
        return returnMap;*/
        Map<String, Object> returnMap = PHOS_OrderVersionCtrl.getVersion(orderVersionId);
        return returnMap;
    }

    /***********************************************
    * Method Name : getPriorityOfRequests
    * Author : Pankaj
    * Inputs : -
    * Description: This method return list of strings from order's priority requests field
    *********************************************/
    @AuraEnabled
    public static List<String> getPriorityOfRequests(){
        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = Order__c.Priority_for_Requests__c.getDescribe();
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            options.add(p.getLabel());
        }
        return options;
    }

    /***********************************************
    * Method Name : getStateCodes
    * Author : Pankaj
    * Inputs : -
    * Description: This method return list of strings from order's shipping state field
    *********************************************/
    @AuraEnabled
    public static List<String> getStateCodes(){
        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = Order__c.Shipping_State__c.getDescribe();
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            options.add(p.getLabel());
        }
        return options;
    }

    /***********************************************
    * Method Name : getIncidentList
    * Author : Pankaj
    * Inputs : String available
    * Description: This method return list of map of strings from incidents 
    *********************************************/
    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getIncidentList(String available) {
        List<Map<String, String>> options = new List<Map<String, String>>();
        options.add(new Map<String, String>{'value' => '', 'label' => '--Select--'});
        for (Incident__c obj :[SELECT Id, Name FROM Incident__c WHERE isActive__c = true AND Available_for_Application__c =:available ] ) {
                options.add(new Map<String, String>{'value' => obj.Id, 'label' => obj.Name});
            }
        return options;
    }

    /***********************************************
    * Method Name : getCountyList
    * Author : Pankaj
    * Inputs : -
    * Description: This method return list of strings from order's county field 
    *********************************************/
    @AuraEnabled
    public static List<String> getCountyList(){
        List<String> options=new List<String>();
        Schema.DescribeFieldResult fieldResult = Order__c.County__c.getDescribe();
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry s:pList){                
            options.add(s.getLabel());   
        } 
        return options;
    }

    /***********************************************
    * Method Name : getEntityTypeList1
    * Author : Pankaj
    * Inputs : -
    * Description: This method return list of strings from Account 
    *********************************************/
    @AuraEnabled
    public static List<String> getEntityTypeList1(){
        List<String> options=new List<String>();
        Schema.DescribeFieldResult fieldResult = Account.Entity_Type__c.getDescribe();
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry s:pList){
            options.add(s.getLabel());
        }
        return options;
    }

    /***********************************************
    * Method Name : getOrderData
    * Author : Pankaj
    * Inputs : String orderId
    * Description: This method return's order and order products records
    *********************************************/
    @AuraEnabled
    public static Map<String, Object> getOrderData(String orderId) {
        Map<String, Object> returnMap = new Map<String, Object>();
        Order__c record = [SELECT
                        Account__c,
                        Account__r.Entity_Type__c,
                        Incident_Name__c,
                        Incident__c,
                        CreatedById,
                        CreatedDate,
                        Delivery_Recipient_First_Name_Text__c,Delivery_Recipient_Last_Name_Text__c,Delivery_Recipient_Title_Text__c,Delivery_Recipient_Email_Text__c,Delivery_Recipient_Phone_Text__c,
                        Description__c,
                        Id,
                        LastModifiedDate,
                        Name,
                        Requestor__c,Requestor_First_Name_Text__c,Requestor_Last_Name_Text__c,Requestor_Title_Text__c,Requestor_Email_Text__c,Requestor_Phone_Text__c,Requestor_Agency_Text__c,
                        Delivery_Recipient_Entity_Name__c,
                        Address_Geolocation__Latitude__s, Address_Geolocation__Longitude__s,
                        Shipping_City__c,
                        Shipping_Country__c,
                        Shipping_ZipPostal_Code__c,
                        Shipping_State__c,
                        Shipping_Street__c,
                        Shipping_Street_2__c,
                        Status__c,
                        County__c,
                        SuppliesEquipment__c,
                        Personnel__c,
                        Delivery_Notes__c,
                        Other_Request_Number_If_Applicable__c,
                        Mission_Request_Number_If_Applicable__c,
                        PHM_EOM_Confirmed__c,
                        RDMHS_Program_Confirmed__c,
                        Type_Of_Resource_Other__c,
                        Priority_for_Requests__c,
                        Actions_Taken_On_This_Request__c,
                        Industry__c,
                        Current_Stage__c,
                        Sub_Industry__c,
                        Creator_Contact__c,
                        Bed_to_staff_ratio_bed_staff__c, Does_site_need_personnel_to_keep_ICU__c,Total_ICU_beds_occupied__c,
                        Have_you_attempted_to_transfer_patients__c, Have_you_cancelled_all_surgeries__c,
                        Do_you_have_an_active_staffing_waiver__c, Would_you_be_able_to_accept_transfers__c, Is_this_for_a_GACH__c,
                        Is_this_a_Medical_Staffing_Request__c,Allows_additional_ICU_or_M_S_T_beds__c,
                        Average_time_of_T_to_T_for_ESI_Cat_3__c,How_many_total_staff_are_you_requesting__c,
                        Type_of_Personnel__c,
                        Total_Vaccinator_Staff_needed__c,
                        Specific_Vaccinator_Licenses_req_d__c,
                        Total_Logistics_Staff_needed__c,
                        Logistics_staff_tasks__c,
                        Total_Admin_Data_Staff_needed__c,
                        Admin_Data_Staff_Assignments__c,
                        Total_Security_Staff_needed__c,
                        Specific_language_preferred__c,
                        Language_specified__c,
                        First_date_of_Event__c,
                        Date_Time_staff_are_needed__c,
                        Address_for_staff__c,
                        Schedule_for_staff__c,
                        Vaccination_site_type__c,
                        Other_Vaccination_Site__c,
                        How_many_clients_expected__c,
                        Is_allocation_amount_sufficient__c,
                        What_is_closest_phase_tier__c,
                        Communication_with_Locals__c,
                        Any_unmet_communication_needs__c,
                        X2nd_Dose_plan_in_place__c,
                        X2nd_Dose_plan_detail__c,
                        Has_state_previously_helped__c,
                        How_many_clients_previously_helped__c,
                        What_is_the_site_name__c,
                        Clients_Anticipated_at_Site__c,
                        Doses_Anticipated_per_Day__c,
                        Doses_per_Day_Previous_Events__c,
                        What_status_is_the_event_currently_in__c,
                        Confirm_Compliance_Checkboxes__c,
                        Compliance_Narrative__c,Using_team_nursing_and_out_of_ratio__c,
                        We_provide_staff_for_vaccination_events__c,
                        School_Requirements_Confirmation__c,
                        Logistics_Task_Assignments__c,
                        What_of_County_population_vaccinated__c,Hospital_Burden_Score__c,
                        What_is_current_total_patient_census__c,What_is_current_census_of_COVID_patients__c,
                        Total_patient_divide_COVID_patient_censu__c,
                        (SELECT
                        Cost__c,
                        CreatedById,
                        CreatedDate,
                        Description__c,
                        Estimated_time_of_Arrival__c,
                        Id,
                        IsDeleted,
                        LastModifiedById,
                        LastModifiedDate,
                        Order__c,
                        Name,
                        Product__c,
                        Product__r.Name,
                        Product__r.Family,
                        Quantity__c,
                        Total_Price__c,
                        Tracking__c,
                        Unit_Price__c,
                        Item_Code__c,
                        Quantity_Filled__c,
                        Quantity_Approved__c,
                        Quantity_Back_Ordered__c,
                        Equivalent_Substitutes_Acceptable__c,
                        Delivered_On_Date__c,
                        Carrier_Tracking__c,
                        Fulfilment_Entity_Warehouse__c,
                        Product_Name__c,
                        Product_Family__c
                        FROM Order_Products__r ) FROM Order__c WHERE Id=:orderId];

        returnMap.put('Order', record);
        Boolean showRecordLockedError = false;
        Boolean orderApproved = false;
        Boolean isLocked = Approval.isLocked(orderId);
        Boolean hasRecordAccess = ApexUtils.checkIfCurrentUserHasEditAccess(orderId);
        User userRec = ApexUtils.getCurrentUserDetails();
        Set<String> orderStatuses = new Set<String>{'Draft', 'MHOAC Review', 'RDMHS Review'};
        if(hasRecordAccess == true && isLocked == true){
            showRecordLockedError = ApexUtils.showErrorWhenRecordLocked(orderId);
        } else if(!orderStatuses.contains(record.Status__c) && userRec.AccountId != null) {
            showRecordLockedError = true;
            orderApproved = true;
        } /*else if(userRec.AccountId != null){
            showRecordLockedError = true;
            orderApproved = true;
        }*/
        returnMap.put('ShowRecordLockedError',showRecordLockedError);
        returnMap.put('OrderApproved',orderApproved);
        if(userRec.AccountId != null) {
            returnMap.put('isCommunityUser',true);
        } else {
            returnMap.put('isCommunityUser',false);
        }
        boolean isCountyChild = false;
        if(userRec.Contact.Account.Parent.Entity_Type__c != null  && userRec.Contact.Account.Parent.Entity_Type__c == 'County'){
            isCountyChild = true;
        }
        returnMap.put('CountyChild',isCountyChild);
        return returnMap;
    }    
}