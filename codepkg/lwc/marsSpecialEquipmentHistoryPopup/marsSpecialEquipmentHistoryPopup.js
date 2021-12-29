import { LightningElement,api } from 'lwc';
import Utility from 'c/utility';
import getData from "@salesforce/apex/MARS_SpecialEquipmentHistoryCtrl.getData";
export default class MarsSpecialEquipmentHistoryPopup extends Utility {
    splEquipLineItemRecord=[];
    splEquipRecord=[]; 
    contentVersions=[];
    @api recordId;
    isViewModalOpen;
    signIMGURL;
    isPrint = false;
    initData() {
        if(this.recordId == undefined) {
            this.recordId = this.getURLParameter("id");
            this.isPrint = true;
        }
        if(this.recordId != undefined) {
            console.log('Id==',this.recordId);
            this.executeAction(getData, {
                agencySplEquipId: this.recordId
                }, (result) => {
                    console.log('sp=',JSON.stringify(result));
                    this.splEquipLineItemRecord = result.splEquipLines;
                    this.splEquipRecord = result.splEquipSurvey;
                    this.contentVersions = result.contentVersions;
                    this.signIMGURL = result.signature;
            });
            this.isViewModalOpen = true;
        }
        if(this.isPrint) {
            setTimeout(function(){
                window.print(); 
                window.close(); 
            },2000);
        }
    }
    closeSubmitModal(event) {
        // to close modal set isViewModalOpen tarck value as false
        this.dispatchEvent(new CustomEvent('closepopup'));
    
    }
    get hasFiles(){
        return this.contentVersions.length > 0;
    }
    get isImage(){
        if(this.signIMGURL != null || this.signIMGURL != undefined || this.signIMGURL != '') return true;
        else return false; 
    }
    handlePrint() {
        let Url = '/mars/s/special-equipment-print?id='+ this.recordId;
        window.open(Url);
    }
}