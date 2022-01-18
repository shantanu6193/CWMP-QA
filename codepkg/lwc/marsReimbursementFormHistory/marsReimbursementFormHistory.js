import { LightningElement,api } from 'lwc';
import Utility from 'c/utility';
import getReimbursementHistory from "@salesforce/apex/Mars_ReimbursementHistoryCtrl.getReimbursementHistory";
import getData from "@salesforce/apex/Mars_ReimbursementHistoryCtrl.getData";
export default class MarsReimbursementFormHistory extends Utility {
    isViewModalOpen = false;
    @api recordId;
    reimbursementList = [];
    reimbursementLineRecords = [];  
    reimbursRecord = [];
    contentVersions = [];
    imageUrl;
    initData() {
            this.executeAction(getReimbursementHistory, {
                accountId: this.recordId
            }, (result) => {
                let expenseClaimList = [];
                result.forEach(element => {
                    let expenseClaim = {};
                    expenseClaim.Id = element.Id;
                    expenseClaim.Name = element.Name;
                    expenseClaim.Total_Reimbursement_Amount = element.Total_Reimbursement_Amount_Rollup__c;
                    expenseClaim.Printed_Name = element.Printed_Name__c;
                    expenseClaim.Submission_Date = element.Submission_Date__c;
                    expenseClaim.Status =  element.Status__c;
                    expenseClaim.Strike_Team =  element.Strike_Team__c;
                    expenseClaim.Incident_Order_Number = element.Incident_Order_Number__c
                    expenseClaim.Incident_Request_Number = element.Incident_Request_Number__c;
                    expenseClaim.IncidentName = element.Incident__r.Name;
                    expenseClaimList.push(expenseClaim);
                });
                this.reimbursementList = expenseClaimList;
        });
    }
    viewRecord(event){
        event.preventDefault();
        const itemIndex = event.currentTarget.dataset.index;
        console.log(itemIndex);
        this.executeAction(getData, {
            reimbursemenId: itemIndex
            }, (result) => {
                console.log('ReimbursementLineItems===>',JSON.stringify(result));
                this.reimbursementLineRecords = result.ReimbursementLineItems;
                this.imageUrl = result.signature;
                //this.reimbursRecord = result.Reimbursement;
                this.contentVersions = result.contentVersions;
                    let expenseClaim = {};
                    expenseClaim.Id = result.Reimbursement.Id;
                    expenseClaim.Name = result.Reimbursement.Name;
                    expenseClaim.Total_Reimbursement_Amount = result.Reimbursement.Total_Reimbursement_Amount_Rollup__c;
                    expenseClaim.Printed_Name = result.Reimbursement.Printed_Name__c;
                    expenseClaim.Submission_Date = result.Reimbursement.Submission_Date__c;
                    expenseClaim.Status =  result.Reimbursement.Status__c ;
                    expenseClaim.Approver_Comments = result.Reimbursement.Approver_Comments__c;
                    expenseClaim.MACIDs = result.Reimbursement.MACIDs__c;
                    expenseClaim.Strike_Team = result.Reimbursement.Strike_Team__c ;
                    expenseClaim.Incident_Order_Number = result.Reimbursement.Incident_Order_Number__c
                    expenseClaim.Incident_Request_Number = result.Reimbursement.Incident_Request_Number__c;
                    expenseClaim.Unit_Number = result.Reimbursement.Unit_Number__c;
                    expenseClaim.IncidentName = result.Reimbursement.Incident__r.Name;
                    expenseClaim.Comments = result.Reimbursement.Comments__c;
                    expenseClaim.Meal_Total = result.Reimbursement.Meal_Total_Rollup__c;
                    expenseClaim.MISC_Total =  result.Reimbursement.MISC_Total_Rollup__c;
                    expenseClaim.Lodging_Total =  result.Reimbursement.Lodging_Total_Rollup__c;
                    expenseClaim.Mutual_Aid_Staff_Comments = result.Reimbursement.Mutual_Aid_Staff_Comments__c;
            this.reimbursRecord = expenseClaim;
        });
        
        this.isViewModalOpen = true;
    }
    closeSubmitModal() {
        // to close modal set isViewModalOpen tarck value as false
        this.isViewModalOpen = false;
    }
    get showRejectReason(){
        if(this.reimbursRecord.Approver_Comments__c != undefined || this.reimbursRecord.Approver_Comments__c != null) return true;
        else return false;
    }
    get hasFiles(){
        return this.contentVersions.length > 0;
    }
}