global with sharing class Phos_OrderSharingBatch implements  Database.Batchable<sObject>, Database.Stateful{
    public String filterClause;

    global Phos_OrderSharingBatch (String filterClause){
        this.filterClause = filterClause;
    } 

    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id,Account__c,CreatedById,Account__r.Entity_Type__c,Account__r.Account_PHOS_Order_Public_Group__c,Account__r.ParentId,Account__r.Parent.Entity_Type__c,Account__r.Parent.Account_PHOS_Order_Public_Group__c,Account__r.Parent.ParentId, Account__r.Parent.Parent.Entity_Type__c,Account__r.Parent.Parent.Account_PHOS_Order_Public_Group__c FROM Order__c ';
        If(filterClause != null){
            query = query+filterClause;
        }
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<Order__c> scope){
        
		//List<Case> createCaseList = new List<Case>();
        List<Order__Share> orderShareList = new List<Order__Share>();

        List<Id> uerIds = new List<Id>();
        List<Id> portalUserUds = new List<Id>();
        for(Order__c orders : scope) {
            uerIds.add(orders.CreatedById);
        }
        for(User userRec : [SELECT ID FROM User WHERE Id IN:uerIds AND AccountId != NULL]) {
            portalUserUds.add(userRec.ID);
        }
		System.debug('portalUserUds='+portalUserUds.size());
        Set<String> publicGroupdevloperNames = new Set<String>();

        for(Order__c order : scope){
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
		System.debug('publicGroupdevloperNames='+publicGroupdevloperNames.size());
        List<Group> GroupListById = [SELECT Id,Name,DeveloperName from Group where DeveloperName =: publicGroupdevloperNames and Type = 'Regular'];
        if(GroupListById.size() == 0) return;
        System.debug('GroupListById='+GroupListById.size());
        Map<String,Id> publicGroupMapById = new Map<String,Id>();

        for(Group grp : GroupListById ){

            publicGroupMapById.put(grp.DeveloperName, grp.Id);
            System.debug('DeveloperName='+grp.DeveloperName+' Gp id='+grp.Id);
        }


        for(Order__c orderRec : scope) {
            //For County Account
            //if(orderRec.Creator_Contact__c == null) continue;
            if(portalUserUds.Contains(orderRec.CreatedById) && orderRec.Account__r.Account_PHOS_Order_Public_Group__c != null){
                Order__Share cs = new Order__Share();
                cs.ParentId = orderRec.Id;
                cs.UserOrGroupId = publicGroupMapById.get(orderRec.Account__r.Account_PHOS_Order_Public_Group__c);
                cs.AccessLevel  = 'Edit';
                cs.RowCause = Schema.Order__Share.RowCause.Order_Apex_Sharing__c;
                orderShareList.add(cs);
            }
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
           
        }

       

        if(orderShareList != null && !orderShareList.isEmpty()) {
            insert orderShareList;
        }
    }
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }
}