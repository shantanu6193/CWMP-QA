/***********************************************************************************************************************************
* Class Name   : ProductDistributionPlanHelper
* Description  : This is helper class for product distribution plan trigger
* Author       : Pankaj
* Created On   : 09/02/2020
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Pankaj              09/02/2020      Initial Implementation
**************************************************************************************************************************************/

public without sharing class ProductDistributionPlanHelper extends TriggerHelper {
    
    /***********************************************
    * Method Name : processBeforeInsert
    * Author : Pankaj
    * Inputs : -
    * Description: This method call before records are inserting
    *********************************************/
    public override void processBeforeInsert()  {
        createFacility();
    }

    /***********************************************
    * Method Name : processBeforeUpdate
    * Author : Pankaj
    * Inputs : -
    * Description: This method call before records are updating
    *********************************************/
    public override void processBeforeUpdate() {
        createFacility();
    }

    /***********************************************
    * Method Name : createFacility
    * Author : Pankaj
    * Inputs : -
    * Description: This method create facility records
    *********************************************/
    private void createFacility() {
        List<Product_Distribution_Plan__c> planRecordsList = (List<Product_Distribution_Plan__c>)Trigger.new;
        Map<Id, Product_Distribution_Plan__c> oldPlanRecordsList = (Map<Id, Product_Distribution_Plan__c>)Trigger.oldMap;
        List<Product_Distribution_Plan__c> recordsToProcess = new List<Product_Distribution_Plan__c>();
        for(Product_Distribution_Plan__c planRecord : planRecordsList) {
            if(planRecord.Facility_Name__c == null) continue;
            if(((oldPlanRecordsList == null || oldPlanRecordsList.get(planRecord.Id) == null ||
                    (oldPlanRecordsList.get(planRecord.Id).Facility_Name__c != planRecord.Facility_Name__c)) && planRecord.Facility__c == null)) {
                recordsToProcess.add(planRecord);
            }
        }
        if(recordsToProcess.isEmpty()) return;
        List<Account> accListToInsert = new List<Account>();
        Map<String, Id> accNameToID = new Map<String, Id>();
        for(Product_Distribution_Plan__c planRecord : recordsToProcess) {
            Account acc = new Account();
            acc.Name = planRecord.Facility_Name__c;
            acc.ParentId = planRecord.County__c;
            acc.Entity_Type__c = 'Health Care Facility';
            acc.Entity_Id__c = planRecord.Facility_Code__c;
            //acc.Facility_Type__c = planRecord.Facility_Type__c;
            acc.Facility_Category__c = planRecord.Facility_Category__c;
            accListToInsert.add(acc);
        }
        insert accListToInsert;

        for(Account acc : [Select Id, Name from Account where Id IN :accListToInsert]) {
            accNameToID.put(acc.Name, acc.Id);
        }
        for(Product_Distribution_Plan__c planRecord : recordsToProcess) {
            if(planRecord.Facility__c == null) {
                planRecord.Facility__c = accNameToID.get(planRecord.Facility_Name__c);
            }
        }
    }
}