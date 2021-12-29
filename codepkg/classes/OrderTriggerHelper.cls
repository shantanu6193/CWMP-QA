/***********************************************************************************************************************************
* Class Name   : OrderTriggerHelper
* Description  : This is helper class for order trigger
* Author       : Pankaj
* Created On   : 08/07/2020
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Pankaj               08/07/2020      Initial Implementation
**************************************************************************************************************************************/

public without sharing class OrderTriggerHelper extends TriggerHelper {
    /***********************************************
    * Method Name : processBeforeInsert
    * Author : Pankaj
    * Inputs : -
    * Description: This method call before records are inserting
    *********************************************/
    public override void processBeforeInsert()  {
        updateRequestorParentAgency(Trigger.new);
        setOrderStatusOnPriorityRequestForOrdeSourceDynamics(Trigger.new);
    }

    /***********************************************
    * Method Name : processBeforeUpdate
    * Author : Pankaj
    * Inputs : -
    * Description: This method call before records are updating
    *********************************************/
    public override void processBeforeUpdate() {
        updateRequestorParentAgency(Trigger.new);
        setMACSQuestionsToBlank();
    }

    /***********************************************
    * Method Name : processBeforeDelete
    * Author : Pankaj
    * Inputs : -
    * Description: This method call before records are deleted
    *********************************************/
    public override void processBeforeDelete() {
         //CH0 Start
         updateOrderStatusNotDraft(Trigger.old);
         //CH0 End
    }

    /***********************************************
    * Method Name : processAfterInsert
    * Author : Pankaj
    * Inputs : -
    * Description: This method call after records are inserted
    *********************************************/
    public override void processAfterInsert()  {
        sendReddinetOrderForApprovalInsert();
        shrareOrderToPublicGroup();
    }

    /***********************************************
    * Method Name : processAfterUpdate
    * Author : Pankaj
    * Inputs : -
    * Description: This method call after records are updated
    *********************************************/
    public override void processAfterUpdate() {
        sendReddinetOrderForApprovalUpdate();
        shrareOrderToPublicGroup();
    }

    /***********************************************
    * Method Name : processAfterDelete
    * Author : Pankaj
    * Inputs : -
    * Description: This method call after records are deleted
    *********************************************/
    public override void processAfterDelete() {
    }

    /***********************************************
    * Method Name : processAfterUndelete
    * Author : Pankaj
    * Inputs : -
    * Description: This method call after records are undeleted
    *********************************************/
    public override void processAfterUndelete() {
    }

    public static Boolean isParentSet = false;
    
    /***********************************************
    * Method Name : updateRequestorParentAgency
    * Author : Pankaj
    * Inputs : List<Order__c> orderList
    * Description: This method populate order field from account
    *********************************************/
    public static void updateRequestorParentAgency(List<Order__c> orderList){
        if(isParentSet) return;
        isParentSet = true;
        Set<Id> contactIds = new Set<Id>();
        for(Order__c newOrder :  orderList){
            if(String.isNotBlank(newOrder.Creator_Contact__c)) {
                Order__c oldOrder;
                if(String.isNotBlank(newOrder.Id)) {
                    oldOrder = (Order__c)Trigger.oldMap.get(newOrder.Id);
                }
                if(oldOrder != null && oldOrder.Creator_Contact__c != newOrder.Creator_Contact__c) {
                    contactIds.add(newOrder.Creator_Contact__c);
                }else if(oldOrder == null) {
                    contactIds.add(newOrder.Creator_Contact__c);
                }
            }
        }
        if(!contactIds.isEmpty()) {
            List<Contact> contactList = [select Id,AccountId,Account.Parent.Account_Name__c from Contact where Id In :contactIds];
            Map<Id, String> contactIdToParentName = new Map<Id, String>();

            for(Contact con : contactList) {
                if(String.isNotBlank(con.Account.Parent.Account_Name__c)) {
                    contactIdToParentName.put(con.Id, con.Account.Parent.Account_Name__c);
                }
            }

            for(Order__c newOrder :  orderList){
                if(String.isNotBlank(contactIdToParentName.get(newOrder.Creator_Contact__c))) {
                    newOrder.Requestor_Parent_Agency__c = contactIdToParentName.get(newOrder.Creator_Contact__c);
                }
            }
        }
    }


    public static void shrareOrderToPublicGroup(){
        List<Id> uerIds = new List<Id>();
        List<Id> portalUserUds = new List<Id>();
        for(Order__c newOrder : (List<Order__c>)Trigger.new) {
            uerIds.add(newOrder.CreatedById);
        }
        for(User userRec : [SELECT ID FROM User WHERE Id IN:uerIds AND AccountId != NULL]) {
            portalUserUds.add(userRec.ID);
        }

        Set<Id> orderIdSet = new Set<Id>();
        if(Trigger.isUpdate) {
            for(Order__c newOrder : (List<Order__c>)Trigger.new){
                Order__c oldOrder = (Order__c)Trigger.oldMap.get(newOrder.Id);
                //if(String.isNotBlank(newOrder.Creator_Contact__c)) {
                    if(oldOrder.Status__c != newOrder.Status__c  && newOrder.Status__c != 'Draft' && (portalUserUds.Contains(newOrder.CreatedById) || newOrder.Order_Source__c ==  PHOS_Constants.ORDER_SOURCE_REDDINET )) {
                        orderIdSet.add(newOrder.Id);
                    }
                //}
            }
        } else if(Trigger.isInsert) {
            for(Order__c newOrder : (List<Order__c>)Trigger.new){
                if((portalUserUds.Contains(newOrder.CreatedById) || newOrder.Order_Source__c ==  PHOS_Constants.ORDER_SOURCE_REDDINET ) && newOrder.Status__c != 'Draft') {
                    orderIdSet.add(newOrder.Id);
                }
            }
        }
        if(orderIdSet.size() == 0) return;

        List<Order__c> orderList = [SELECT Id,Creator_Contact__c,Account__c,Account__r.Entity_Type__c,Account__r.Account_PHOS_Order_Public_Group__c,Account__r.ParentId,Account__r.Parent.Entity_Type__c,Account__r.Parent.Account_PHOS_Order_Public_Group__c
                                    ,Account__r.Parent.ParentId, Account__r.Parent.Parent.Entity_Type__c,Account__r.Parent.Parent.Account_PHOS_Order_Public_Group__c FROM Order__c WHERE Id IN : orderIdSet]; 
        
        if(orderList.size() == 0) return;                           
        Set<String> publicGroupdevloperNames = new Set<String>();

        for(Order__c order : orderList){
             //For region Account
            if(order.Account__r.Parent.Parent.Account_PHOS_Order_Public_Group__c != null) {
                publicGroupdevloperNames.add(order.Account__r.Parent.Parent.Account_PHOS_Order_Public_Group__c);
            }
            //For County Account
            if(order.Account__r.Parent.Account_PHOS_Order_Public_Group__c != null) {
                publicGroupdevloperNames.add(order.Account__r.Parent.Account_PHOS_Order_Public_Group__c);
            }

            //if Order created by County then share with public group
            if(order.Account__r.Account_PHOS_Order_Public_Group__c != null) {
                publicGroupdevloperNames.add(order.Account__r.Account_PHOS_Order_Public_Group__c);
            }
        }


        List<Group> GroupListById = [SELECT Id,Name,DeveloperName from Group where DeveloperName =: publicGroupdevloperNames and Type = 'Regular'];
        if(GroupListById.size() == 0) return;
       
        Map<String,Id> publicGroupMapById = new Map<String,Id>();

        for(Group grp : GroupListById ){

            publicGroupMapById.put(grp.DeveloperName, grp.Id);
        }

        List<Case> createCaseList = new List<Case>();
        List<Order__Share> orderShareList = new List<Order__Share>();

        for(Order__c orderRec : orderList) {
            //For County Account
            if(orderRec.Account__r.ParentId != null && orderRec.Account__r.Parent.Account_PHOS_Order_Public_Group__c != null) {
                Order__Share cs = new Order__Share();
                cs.ParentId = orderRec.Id;
                cs.UserOrGroupId = publicGroupMapById.get(orderRec.Account__r.Parent.Account_PHOS_Order_Public_Group__c);
                cs.AccessLevel  = 'Edit';
                cs.RowCause = Schema.Order__Share.RowCause.Order_Apex_Sharing__c;
                orderShareList.add(cs);
            } 
            //For Region Account
           if(orderRec.Account__r.Parent.ParentId != null && orderRec.Account__r.Parent.Parent.Account_PHOS_Order_Public_Group__c != null) { 
                Order__Share cs = new Order__Share();
                cs.ParentId = orderRec.Id;
                cs.UserOrGroupId = publicGroupMapById.get(orderRec.Account__r.Parent.Parent.Account_PHOS_Order_Public_Group__c);
                cs.AccessLevel  = 'Edit';
                cs.RowCause = Schema.Order__Share.RowCause.Order_Apex_Sharing__c;
                orderShareList.add(cs);
            } 
            if ((orderRec.Account__r.Entity_Type__c == 'County' &&orderRec.Account__r.ParentId == null) ||(orderRec.Account__r.Parent.Entity_Type__c=='County' && orderRec.Account__r.Parent.ParentId == null) || (orderRec.Account__r.Entity_Type__c != 'Region' && orderRec.Account__r.ParentId== null)) {
                Case newCase = new Case();
                newCase.Subject = 'Automated generated PHOS missing Parent Account';
                newCase.Priority = 'High';
                newCase.AccountId = orderRec.Account__c;
                newCase.Order__c = orderRec.Id;
                newCase.Status = 'New'; 
                createCaseList.add(newCase);
            }
        }

        if(createCaseList != null && !createCaseList.isEmpty()) {
            insert createCaseList;
        }

        if(orderShareList != null && !orderShareList.isEmpty()) {
            insert orderShareList;
        }
        System.debug('Inside trigger');
    }
    //CH0 Start
    /***********************************************
    * Method Name : updateOrderStatusNotDraft
    * Author : Pankaj
    * Inputs : List<Order__c> orderList
    * Description: This method showing error message if user delete order and order status is not Draft 
    *********************************************/
    public static void updateOrderStatusNotDraft(List<Order__c> orderList){
        
        for(Order__c orderrecord :  orderList){
               if(orderrecord.Status__c!='Draft'){
                orderrecord.addError('Order cannot be deleted');
               }
            }
        
    }
    //CH0 End
    /***********************************************
    * Method Name : sendReddinetOrderForApprovalInsert
    * Author : Shivraj
    * Description: This method sends order for approval to the MHOAC's on Insert
    *********************************************/
    public static void sendReddinetOrderForApprovalInsert(){
        List<Order__c> ordersToProcess = new List<Order__c>();
        for(Order__c order : (List<Order__c>)Trigger.new) {
            if(order.Order_Source__c == PHOS_Constants.ORDER_SOURCE_REDDINET && order.Status__c == PHOS_Constants.ORDER_STATUS_MHOAC_REVIEW) {
                ordersToProcess.add(order);
            }
        }
        if(!ordersToProcess.isEmpty() && ordersToProcess != null) {
            orderForApprovalRedinnet(ordersToProcess);
        }

    }
    /***********************************************
    * Method Name : setMACSQuestionsToBlank
    * Author : Shivraj
    * Description: This method sets MACS Questions to blank
    *********************************************/
    public static void setMACSQuestionsToBlank(){
       for(Order__c order : (List<Order__c>)Trigger.new) {
            Order__c oldOrder = (Order__c)Trigger.oldMap.get(order.Id);
            if(oldOrder.Personnel__c != order.Personnel__c && oldOrder.Personnel__c == true && order.Personnel__c == false) {
                order.What_is_the_county_s_7_day_case_rate__c = '';
                order.ICU_beds_available_in_the_County__c = '';
                order.What_is_the_county_s_population_density__c = '';
                order.Population_65_years_old_in_county__c = '';
                order.Is_the_facility_a_specialty_center__c = '';
            }
        }
    }
    /***********************************************
    * Method Name : sendReddinetOrderForApprovalUpdate
    * Author : Shivraj
    * Description: This method sends order for approval to the MHOAC's on Update
    *********************************************/
    public static void sendReddinetOrderForApprovalUpdate(){
        List<Order__c> ordersToProcess = new List<Order__c>();

        for(Order__c order : (List<Order__c>)Trigger.new) {
            Order__c oldOrder = (Order__c)Trigger.oldMap.get(order.Id);
            if(oldOrder.Status__c != order.Status__c && oldOrder.Status__c != PHOS_Constants.ORDER_STATUS_RDMHS_REVIEW && order.Order_Source__c == PHOS_Constants.ORDER_SOURCE_REDDINET && order.Status__c == PHOS_Constants.ORDER_STATUS_MHOAC_REVIEW) {
                ordersToProcess.add(order);
            }
        }
        if(!ordersToProcess.isEmpty() && ordersToProcess != null) {
            orderForApprovalRedinnet(ordersToProcess);
        }

    }
    
    /***********************************************
    * Method Name : setOrderStatusOnPriorityRequestForOrdeSourceDynamics
    * Author : Pankaj
    * Inputs : List<Order__c> orderList
    * Description: This method populate Status  field order source is Dynamic and Priority is Emergency
    *********************************************/

    public static void setOrderStatusOnPriorityRequestForOrdeSourceDynamics(List<Order__c> orderList){
        for(Order__c newOrder :  orderList){
           
           if(newOrder.Order_Source__c != PHOS_Constants.ORDER_SOURCE_DYNAMICS) continue; 
            if(newOrder.Priority_for_Requests__c == PHOS_Constants.ORDER_PRIORITY_EMERGENCY){

                newOrder.Status__c = PHOS_Constants.ORDER_STATUS_CDPH_RESOURCE_REQUEST_SUPERVISOR_REVIEW;

            } else if(newOrder.Priority_for_Requests__c != PHOS_Constants.ORDER_PRIORITY_EMERGENCY && newOrder.OrderThresholdMeet__c == 'Yes'){

                newOrder.Status__c = PHOS_Constants.ORDER_STATUS_CDPH_RESOURCE_REQUEST_SUPERVISOR_REVIEW;

            } else if(newOrder.Priority_for_Requests__c != PHOS_Constants.ORDER_PRIORITY_EMERGENCY && newOrder.OrderThresholdMeet__c == 'No'){

                newOrder.Status__c = PHOS_Constants.ORDER_PRODUCT_STATUS_FULLFILLEDANDCLOSED;
            }
        }

    }
    
    public static void orderForApprovalRedinnet(List<Order__c> ordersToProcess) {
        List<Approval.ProcessSubmitRequest> approvalRequestList = new List<Approval.ProcessSubmitRequest>();
        Map<String, String> mapQueueNameToID = new Map<String, String>();
        List<Group> queues = [SELECT Id,DeveloperName FROM Group WHERE Type='Queue'];
        for(Group queueName : queues) {
            mapQueueNameToID.put(queueName.DeveloperName, queueName.Id);
        }
        for(Order__c order : [SELECT Id, Account__r.Parent.Queue_Name__c FROM Order__c WHERE ID IN: ordersToProcess]) {
            if(order.Account__r.Parent.Queue_Name__c == null) continue; 
            Approval.ProcessSubmitRequest req1 =new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting request for approval');
            req1.setObjectId(order.Id);
            req1.setProcessDefinitionNameOrId(PHOS_Constants.ORDER_APPROVAL_MHOAC_REVIEW_PROCESS);
            req1.setNextApproverIds(new List<String>{mapQueueNameToID.get(order.Account__r.Parent.Queue_Name__c)});
            req1.setSkipEntryCriteria(true);
            approvalRequestList.add(req1);
        }
        System.debug('approvalRequestList 204 => '+approvalRequestList);
        if(approvalRequestList.size() > 0) {
            Approval.process(approvalRequestList);
        }
    }
}