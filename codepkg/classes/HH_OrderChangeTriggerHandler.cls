public with sharing class HH_OrderChangeTriggerHandler extends TriggerHandler implements TriggerInterface  {
    /***********************************************
    * Method Name : processafterInsert
    * Author : Sushant.
    * Inputs : -
    * Description: This method call after records are inserting
    *********************************************/
    public override void afterInsert() {
        updateCurrentContractAmountOnAccRole();
    }

    /***********************************************
    * Method Name : processafterUpdate
    * Author : Sushant.
    * Inputs : -
    * Description: This method call after records are updating
    *********************************************/
    public override void afterUpdate() {
        updateCurrentContractAmountOnAccRole();
    }

    /***********************************************
    * Method Name : processafterDelete
    * Author : Sushant.
    * Inputs : -
    * Description: This method call after records are deleting
    *********************************************/
    public override void afterDelete() {
        updateCurrentContractAmountOnAccRole();
    }

    /***********************************************
    * Method Name : updateCurrentContractAmountOnAccRole
    * Author : Sushant.
    * Inputs : -
    * Description: Update Current_Contract_Amount__c field on Account Role after Insertion/Updation/Deletion of Order Change.
    *********************************************/
    private void updateCurrentContractAmountOnAccRole() {
        Set<Id> accRoleIds = new Set<Id>();
        if (Trigger.isInsert) {
            for (Order_Change__c orderChangeToProcess : (List<Order_Change__c>) Trigger.new) {
                if (orderChangeToProcess.Homeowner_check_payment_amount__c != null) {
                    accRoleIds.add(orderChangeToProcess.Account_Role__c);
                }
            }
        }

        if (Trigger.isUpdate) {
            for (Order_Change__c orderChangeToProcess : (List<Order_Change__c>) Trigger.new) {
                Order_Change__c oldRecord = (Order_Change__c) Trigger.oldMap.get(orderChangeToProcess.Id);
                if (orderChangeToProcess.Homeowner_check_payment_amount__c != oldRecord.Homeowner_check_payment_amount__c) {
                    accRoleIds.add(orderChangeToProcess.Account_Role__c);
                }
            }
        }

        if (Trigger.isDelete) {
            for (Order_Change__c orderChangeToProcess : (List<Order_Change__c>) Trigger.old) {
                if (orderChangeToProcess.Homeowner_check_payment_amount__c != null) {
                    accRoleIds.add(orderChangeToProcess.Account_Role__c);
                }
            }
        }

        List<Account_Role__c> accRolesToUpdate = new List<Account_Role__c>();
        if(accRoleIds.size() > 0){
            Map<Id,Account_Role__c> accRoleIdToAccRoleMap = new Map<Id,Account_Role__c>([SELECT Id, Original_Contract_Amount__c, Current_Contract_Amount__c, (SELECT Id, Homeowner_check_payment_amount__c FROM Order_Changes__r) FROM Account_Role__c WHERE Id IN:accRoleIds]);
            for(String accRole:accRoleIdToAccRoleMap?.keySet()){
                Account_Role__c accRoleRecord = accRoleIdToAccRoleMap?.get(accRole);
                List<Order_Change__c> orderChangeRecords = accRoleIdToAccRoleMap?.get(accRole)?.Order_Changes__r;
                if(orderChangeRecords?.size() > 0){
                    Decimal totalAmount = 0;
                    for(Order_Change__c oC: orderChangeRecords){
                        totalAmount += oC?.Homeowner_check_payment_amount__c == null ? 0.00 : oC?.Homeowner_check_payment_amount__c;
                    }
                    accRoleRecord.Current_Contract_Amount__c = accRoleRecord?.Original_Contract_Amount__c  == null ? 0.00 : accRoleRecord?.Original_Contract_Amount__c  + totalAmount ;
                    accRolesToUpdate.add(accRoleRecord);
                }
            }
            if(accRolesToUpdate.size() > 0){
                update accRolesToUpdate;
            }
        }
    }
}