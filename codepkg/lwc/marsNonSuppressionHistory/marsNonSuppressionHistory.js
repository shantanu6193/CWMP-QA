/**
 * Created by Pankaj on 08-04-2021.
 */

import { LightningElement, wire, api } from 'lwc';
import Utility from 'c/utility';
import getAgencyNonSuppressionHistory from "@salesforce/apex/MARS_NonSuppressionHistoryCtrl.getAgencyNonSuppressionHistory";
import getData from "@salesforce/apex/MARS_NonSuppressionHistoryCtrl.getData";
export default class MarsSalarySurveyHistory extends Utility {
    isViewModalOpen = false;
    @api recordId;
    nonSuppRecords = [];
    nonSuppLineItemRecord=[];
    nonSuppRecord=[];
    contentVersions=[];
    @api initData() {
            this.executeAction(getAgencyNonSuppressionHistory, {
                accountId: this.recordId
            }, (result) => {
                this.nonSuppRecords = result;
        });
    }
    viewRecord(event){
        event.preventDefault();
        const itemIndex = event.currentTarget.dataset.index;
        console.log(itemIndex);
        //const addEvent = new CustomEvent('review', { detail: {recordId:event.target.value}});
        //this.dispatchEvent(addEvent);
        this.executeAction(getData, {
            agencyNonSuppId: itemIndex
            }, (result) => {
                console.log(result)
                this.nonSuppLineItemRecord = result.nonSuppLines;
                this.nonSuppRecord = result.nonSuppSurvey;
                this.contentVersions = result.contentVersions;
        });
        this.isViewModalOpen = true;
    }
    closeSubmitModal() {
        // to close modal set isViewModalOpen tarck value as false
        this.isViewModalOpen = false;
    }
    get showRejectReason(){
        if(this.nonSuppRecord.Approval_Status__c == "Rejected") return true;
        else return false;
    }
    get showSalaryRateCol(){
        //if(this.nonSuppRecord.Approval_Status__c == "Approved") return true;
        if(this.nonSuppRecord.Approval_Status__c == "Revised" || this.nonSuppRecord.Approval_Status__c == "Approved") return true;
        else return false;
    }
    get showRejectedAndPendingForApproval(){
        if(this.nonSuppRecord.Approval_Status__c == "Pending Review" || this.nonSuppRecord.Approval_Status__c == "Rejected") return true;
        else return false;
    }
    get hasFiles(){
        return this.contentVersions.length > 0;
    }

    printRecord(event){
        console.log('printRecord');
        event.preventDefault(); 
        console.log(event);
        const itemIndex = event.currentTarget.dataset.index;
        // const items = this.agreementRecords.filter(item => item.Id === itemIndex);
        // console.log(JSON.stringify(items[0]));
        window.open('/mars/apex/MARS_NonSuppressionPDF?id=' + itemIndex);

    }
}