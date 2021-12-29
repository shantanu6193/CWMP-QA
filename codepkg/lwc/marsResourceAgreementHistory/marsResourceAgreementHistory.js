import { LightningElement,api,track } from 'lwc';
import Utility from 'c/utility';
import getAgreementHistory from "@salesforce/apex/MARS_ResourceAgreementHistoryCtrl.getAgreementHistory";
import getData from "@salesforce/apex/MARS_ResourceAgreementHistoryCtrl.getData";
export default class MarsResourceAgreementHistory extends Utility {
    isViewModalOpen = false;
    @api recordId;
    @track agreementRecords = [];
    agreementLineRecords=[];
    agreementRecord=[]; 
    agreementRateId;
    contentVersions=[];
    isEditable = false;
    agreementType='Agreement Type';
    agreementList=[];
    @api initData() {
            this.executeAction(getAgreementHistory, {
                accountId: this.recordId
            }, (result) => {                
                this.agreementRecords = result;
                for(let i=0;i<this.agreementRecords.length;i++) {
                    if(this.agreementRecords[i].Approval_Status__c=='Approved' || this.agreementRecords[i].Approval_Status__c=='Expired' || this.agreementRecords[i].Approval_Status__c=='Rejected') {
                        this.agreementRecords[i].isPrint = true;
                    } 
                    else {
                        this.agreementRecords[i].isPrint = false;
                    }
                }
        });
    }
    viewRecord(event){
        event.preventDefault();
        const itemIndex = event.currentTarget.dataset.index;
        this.agreementRateId = itemIndex;
        this.executeAction(getData, {
            agreementId: itemIndex
            }, (result) => {
                this.agreementLineRecords = result.agreementLines;
                this.agreementRecord = result.agreementRec;
                this.contentVersions = result.contentVersions;
        });
        this.isViewModalOpen = true;
    }
    closeSubmitModal() {
        // to close modal set isViewModalOpen tarck value as false
        this.isViewModalOpen = false;
    }
    /*get showRejectReason(){
        if(this.agreementRecord.Approval_Status__c == "Rejected") return true;
        else return false;
    }*/
    get hasFiles(){
        return this.contentVersions.length > 0;
    }

    printRecord(event) {
        event.preventDefault();        
        const itemIndex = event.currentTarget.dataset.index;
        const items = this.agreementRecords.filter(item => item.Id === itemIndex);
        console.log(JSON.stringify(items[0]));;
        var status = items[0].Approval_Status__c;
        console.log(status);
        if (status=='Approved'||status=='Expired'){
            window.open('/mars/apex/MARS_ApprovedAgreementPDF?id=' + itemIndex);
        } else if (status=='Rejected') {
            window.open('/mars/apex/MARS_DeniedAgreementPDF?id=' + itemIndex);
        } else {
            this.showNotification('Error', 'Unable to print this agreement.', 'error', 'dismissable');
            //window.open('/mars/apex/MARS_ApprovedAgreementPDF?id=' + this.agreementRateId);
        }                
    }
}