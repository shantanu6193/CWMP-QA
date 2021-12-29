/**
 * Created by Pankaj on 08-04-2021.
 */

import { LightningElement, wire, api } from 'lwc';
import Utility from 'c/utility';
import getAgencySplEquipHistory from "@salesforce/apex/MARS_SpecialEquipmentHistoryCtrl.getAgencySpecialEquipHistory";
//import getData from "@salesforce/apex/MARS_SpecialEquipmentHistoryCtrl.getData";
export default class MarsSplEquipHistory extends Utility {
    isViewModalOpen = false;
    @api recordId;
    splEquipRecords = [];
    historyRecordId;
    @api initData() {
            this.executeAction(getAgencySplEquipHistory, {
                accountId: this.recordId
            }, (result) => {
                this.splEquipRecords = result;
        });
    }
    viewRecord(event){
        event.preventDefault();
        //const itemIndex = event.currentTarget.dataset.index;
        this.historyRecordId = event.currentTarget.dataset.index;
        /*this.executeAction(getData, {
            agencySplEquipId: itemIndex
            }, (result) => {
                console.log(result)
                this.splEquipLineItemRecord = result.splEquipLines;
                this.splEquipRecord = result.splEquipSurvey;
                this.contentVersions = result.contentVersions;
        });*/
        this.isViewModalOpen = true;
    }
    closeSubmitModal() {
        // to close modal set isViewModalOpen tarck value as false
        this.isViewModalOpen = false;
    }
    get showRejectReason(){
        if(this.splEquipRecord.Approval_Status__c == "Rejected") return true;
        else return false;
    }
    get hasFiles(){
        return this.contentVersions.length > 0;
    }

    printRecord(event) {
        const specialEquipId = event.currentTarget.dataset.index;
        window.open('/mars/apex/MARS_SpecialEquipment_PDF?id=' + specialEquipId);
    }
}