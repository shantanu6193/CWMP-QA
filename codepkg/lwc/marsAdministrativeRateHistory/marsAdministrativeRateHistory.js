import { LightningElement,api } from 'lwc';
import Utility from 'c/utility';
import getAdminRateHistory from "@salesforce/apex/MARS_AdministrativeRateHistoryCtrl.getAdminRateHistory";
import getData from "@salesforce/apex/MARS_AdministrativeRateHistoryCtrl.getData";
export default class MarsAdministrativeRateHistory extends Utility {
    isViewModalOpen = false;
    @api recordId;
    adminRateRecords = [];
    adminRateLineRecord=[];  
    adminRateRecord=[];
    contentVersions=[];
    @api initData() {
            this.executeAction(getAdminRateHistory, {
                accountId: this.recordId
            }, (result) => {
                this.adminRateRecords = result;
        });
    }
    viewRecord(event){
        event.preventDefault();
        const itemIndex = event.currentTarget.dataset.index;
        console.log(itemIndex);
        //const addEvent = new CustomEvent('review', { detail: {recordId:event.target.value}});
        //this.dispatchEvent(addEvent);
        this.executeAction(getData, {
            agencyAdminRateId: itemIndex
            }, (result) => {
                console.log('Admin Rate Hist===>',JSON.stringify(result));
                this.adminRateLineRecord = result.adminRateLines;
                this.adminRateRecord = result.agencyAdminRate;
                this.contentVersions = result.contentVersions;
        });
        this.isViewModalOpen = true;
    }
    closeSubmitModal() {
        // to close modal set isViewModalOpen tarck value as false
        this.isViewModalOpen = false;
    }
    get showRejectReason(){
        if(this.adminRateRecord.Approval_Status__c == "Rejected") return true;
        else return false;
    }
    get hasFiles(){
        return this.contentVersions.length > 0;
    }

    printRecord(event) {
        const adminrecordId = event.currentTarget.dataset.index;
        window.open('/mars/apex/MARS_AdministrativeRate_PDF?id=' + adminrecordId);
    }
}