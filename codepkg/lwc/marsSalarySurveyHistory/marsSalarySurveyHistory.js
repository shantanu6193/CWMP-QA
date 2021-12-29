/**
 * Created by Pankaj on 08-04-2021.
 */

import { LightningElement, wire, api } from 'lwc';
import Utility from 'c/utility';
import getAgencySalarySurveyHistory from "@salesforce/apex/MARS_SalarySurveyHistoryCtrl.getAgencySalarySurveyHistory";
import getData from "@salesforce/apex/MARS_SalarySurveyHistoryCtrl.getData";
export default class MarsSalarySurveyHistory extends Utility {
    isViewModalOpen = false;
    @api recordId;
    salarySurveyRecords = [];
    salarySurveyLineItemRecord=[];
    salarySurveyRecord=[];
    contentVersions=[];
    historyRecordId;
    @api initData() {
            this.executeAction(getAgencySalarySurveyHistory, {
                accountId: this.recordId
            }, (result) => {
                this.salarySurveyRecords = result;
        });
    }
    viewRecord(event){
        event.preventDefault();
        const itemIndex = event.currentTarget.dataset.index;
        this.historyRecordId = event.currentTarget.dataset.index;
        this.executeAction(getData, {
            agencySalarySurveyId: itemIndex
            }, (result) => {
                this.salarySurveyLineItemRecord = result.salarySurveyLines;
                this.salarySurveyRecord = result.salarySurvey;
                this.contentVersions = result.contentVersions;
        });
        this.isViewModalOpen = true;
    }
    closeSubmitModal() {
        // to close modal set isViewModalOpen tarck value as false
        this.isViewModalOpen = false;
    }
    /*get showRejectReason(){
        if(this.salarySurveyRecord.Status__c == "Rejected") return true;
        else return false;
    }*/
    get hasFiles(){
        return this.contentVersions.length > 0;
    }
    printRecord(event) {
        const salarySurveyId = event.currentTarget.dataset.index;
        window.open('/mars/apex/MARS_AgencySalarySurveyPDF?id=' + salarySurveyId);
    }
}