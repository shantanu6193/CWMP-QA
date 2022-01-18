public without sharing class HH_CreateUpdateAccountRoleCtrl {

        @AuraEnabled(Cacheable=true)
        public static List<LookupSearchResult> searchAccountRole(String searchTerm) {
            searchTerm = searchTerm.replace(' ','%');
            system.debug('searchTerm===='+searchTerm);
            String query = 'select Id, Name, Email_Address__c, Phone, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, BillingStreet, BillingCity, BillingState, BillingPostalCode from Account WHERE Entity_Type__c = \'Contractor\'';
            if(String.isNotEmpty(searchTerm)) {
                query += ' AND Name like\'%' + searchTerm + '%\'' ;
            }
            system.debug('query===='+query);
            List<Account> acc = Database.query(query);
            List<LookupSearchResult> results = searchAccounts(acc, true);
            System.debug('results---' + results);
            return results;
        }
    
        private static List<LookupSearchResult> searchAccounts( List<Account> accs, Boolean showSubtitle) {
            // Prepare results
            List<LookupSearchResult> results = new List<LookupSearchResult>();
            // Extract Accounts & convert them into LookupSearchResult
            String accIcon = 'standard:Account';
            for (Account acc : accs) {
                results.add(
                        new LookupSearchResult(
                                acc.Id,
                                'Account',
                                accIcon,
                                acc.Name,
                                null,
                                acc
                        )
                );
            }
            // Optionnaly sort all results on title
            results.sort();
            System.debug('results---' + results);
            return results;
        }

        
        @AuraEnabled
        public static void saveDetails(String parentRecordId, String accountDetail,String accountRoleDetail) {
            Account accountDetails = (Account) JSON.deserialize(accountDetail, Account.class);//Deserialization of Account Record
            Account_Role__c accountRoleDetails = (Account_Role__c) JSON.deserialize(accountRoleDetail, Account_Role__c.class);//Deserialization of Account_Role__c Record
            String objectName = ApexUtils.getObjectNameByRecordId(parentRecordId);
            if(objectName == HH_CONSTANTS.HHApplication_Object_APIName) {
                accountRoleDetails.CWMP_Application__c = parentRecordId;
            } else if(objectName == HH_CONSTANTS.CWMPProject_API_Name) {
                accountRoleDetails.CWMP_Project__c = parentRecordId;
            }
            List<Draw__c> draws = accountRoleDetails.Draws__r;
            List<Order_Change__c> orderChanges = accountRoleDetails.Order_changes__r; 
            System.debug('accountDetails.Name--- '+accountDetails.Name);
            if(accountDetails.Name != null){
                if(accountDetails.Id == null) {
                    accountDetails.Entity_Type__c = HH_CONSTANTS.AccountRole_Role_Contractor;
                }
            upsert accountDetails; 
            System.debug('accountDetails.Id--- '+accountDetails.Id);
            accountRoleDetails.Account__c = accountDetails.Id;
            accountRoleDetails.Role__c = HH_CONSTANTS.AccountRole_Role_Contractor;
            if(accountRoleDetails.Status__c == null){
                accountRoleDetails.Status__c = HH_CONSTANTS.AccountRole_Status_Active;
            }
            upsert accountRoleDetails;
            deleteDraws(accountRoleDetails.Id, draws);
            deleteOrderChanges(accountRoleDetails.Id,orderChanges);
            if(draws.size() > 0 ) {
                upsert draws;
            }
            if(orderChanges.size() > 0 ) {
                upsert orderChanges;
            }
            System.debug('accountRoleDetails--- '+accountRoleDetails.Id);
        }
        
        }

        @AuraEnabled
        public static Map<String,Object> getDetails(String parentRecordId, String accountRoleId) {
            Map<String,Object> resultMap = new Map<String,Object>();
            String objectName = ApexUtils.getObjectNameByRecordId(parentRecordId);
            if(objectName == HH_CONSTANTS.CWMPProject_API_Name) {
                resultMap.put('isParentProject',true);
            } else {
                resultMap.put('isParentProject',false);
            }
            resultMap.put('isEdit', false);
            if(accountRoleId != null){
                Account_Role__c accRoleRecord =[Select Id,Account__c,Account__r.Name,
                                                Account__r.Email_Address__c, Account__r.Phone, 
                                                Account__r.ShippingStreet, Account__r.ShippingCity,
                                                Account__r.ShippingState, Account__r.ShippingPostalCode,
                                                Account__r.BillingStreet, Account__r.BillingCity,
                                                Account__r.BillingState, Account__r.BillingPostalCode,
                                                Current_Contract_Amount__c,CWMP_Application__c,
                                                CWMP_Project__c,Original_Contract_Amount__c,Point_of_Contact__c,
                                                Role__c,SOW_Completed_Date__c,Status__c,
                                                Was_a_change_order_requested__c,Was_a_draw_requested__c from Account_Role__c 
                                                where Id =:accountRoleId];
                if(accRoleRecord.Id != null && accRoleRecord?.Account__c != null){
                    resultMap.put('accRoleRecord',accRoleRecord);
                    resultMap.put('accRecord',accRoleRecord?.Account__r);
                    resultMap.put('orderChanges',fetchChangeOrders(accountRoleId));
                    resultMap.put('draws', fetchDraws(accountRoleId));
                    resultMap.put('isEdit', true);
                    return resultMap;
                }
            }
            return resultMap;
        }


        private static List<Order_Change__c> fetchChangeOrders(String accountRoleId){ 
            return [SELECT Id, Has_Homeowner_provided_check_payment__c, Homeowner_check_payment_amount__c,Account_Role__c 
                    FROM Order_Change__c WHERE Account_Role__c =:accountRoleId];
        }

        private static List<Draw__c> fetchDraws(String accountRoleId){ 
            return [SELECT Id, Date__c, Amount__c, Account_Role__c 
                    FROM Draw__c WHERE Account_Role__c =:accountRoleId ORDER BY CreatedDate];
        }

        /***********************************************
        * Method Name : deleteDraws
        * Author : Shantanu
        * Inputs : String accountRoleId, List<Draw__c> draws
        * Description: This method will delete existings Draws which are deleted from UI.
        *********************************************/
        private static void deleteDraws(String accountRoleId, List<Draw__c> draws)  {
            List<String> existingDrawIds = new List<String>();
            for (Draw__c draw : draws) {
                if(String.isNotEmpty(draw.Id)) {
                    existingDrawIds.add(draw.Id);
                }    
            }
            List<Draw__c> drawsToDelete = new List<Draw__c>();
            if (draws.size() == 0 && existingDrawIds.size() == 0) {
                drawsToDelete = [SELECT Id FROM Draw__c WHERE Account_Role__c=:accountRoleId];
            } else {
                drawsToDelete = [SELECT Id FROM Draw__c WHERE Account_Role__c=:accountRoleId AND Id NOT IN :existingDrawIds];
            }
            if (drawsToDelete.size() > 0 ) {
                delete drawsToDelete;
            }
        }


        /***********************************************
        * Method Name : deleteDraws
        * Author : Shantanu
        * Inputs : String accountRoleId, List<Order_Change__c> draws
        * Description: This method will delete existings Order changes which are deleted from UI.
        *********************************************/
        private static void deleteOrderChanges(String accountRoleId, List<Order_Change__c> draws)  {
            List<String> existingOrderIds = new List<String>();
            for (Order_Change__c draw : draws) {
                if(String.isNotEmpty(draw.Id)) {
                    existingOrderIds.add(draw.Id);
                }    
            }
            List<Order_Change__c> orderChangeToDelete = new List<Order_Change__c>();
            if (draws.size() == 0 && existingOrderIds.size() == 0) {
                orderChangeToDelete = [SELECT Id FROM Order_Change__c WHERE Account_Role__c=:accountRoleId];
            } else {
                orderChangeToDelete = [SELECT Id FROM Order_Change__c WHERE Account_Role__c=:accountRoleId AND Id NOT IN :existingOrderIds];
            }
            if (orderChangeToDelete.size() > 0 ) {
                delete orderChangeToDelete;
            }
        }
}