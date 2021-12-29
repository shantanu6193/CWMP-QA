import { LightningElement,api,track } from 'lwc';
import Utility from 'c/utility';
import getReimbursementReviewList from "@salesforce/apex/Mars_ReimbursementReviewCtrl.getReimbursementReviewList";
export default class MarsReimbursementReviewList extends Utility {
    @api accountId;
    reimbursementList = [];
    showHideReviewDetails = false;
    reimbursemenId;
    oldReimbursemenId;
    @track visibleRecords;
    initData() {
        let urlId = this.getURLParameter("id");
        this.accountId = urlId;
            this.executeAction(getReimbursementReviewList, {
                accountId: this.accountId
            }, (result) => {
                let expenseClaimList = [];
                result.forEach(element => {
                    let expenseClaim = {};
                    expenseClaim.Id = element.Id;
                    expenseClaim.Name = element.Name;
                    expenseClaim.Total_Reimbursement_Amount = element.Total_Reimbursement_Amount__c;
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
                //this.reimbursementList = result;
        });
    }
    viewRecord(event) {
        this.showHideReviewDetails = false;
        this.reimbursemenId = event.currentTarget.dataset.index;
        if(this.oldReimbursemenId !== this.reimbursemenId) {
            this.showHideReviewDetails = true;
            this.oldReimbursemenId = this.reimbursemenId;
        } else {
            this.oldReimbursemenId = undefined;
        }
        console.log('this.reimbursemenId==',this.reimbursemenId);
        
    }
    paginationHandler(event) {
        this.visibleRecords = event.detail.slicedRecords;
    }
    handelShowRecord(event) {
        this.showHideReviewDetails = false;
    }
}