import { LightningElement, api, track } from 'lwc';
import Utility from 'c/utility';
import updateRFIRecordAndSendNotification from '@salesforce/apex/HMA_RequestForInformationCtrl.updateRFIRecordAndSendNotification';
import getRFIRecordDetails from '@salesforce/apex/HMA_RequestForInformationCtrl.getRFIRecordDetails';
import getRFIRelatedDocuments from '@salesforce/apex/HMA_RequestForInformationCtrl.getRFIRelatedDocuments';
import deleteContentDocument from '@salesforce/apex/DocumentUploadCtrl.deleteContentDocument';

export default class hmaRFIModal extends Utility {
    @api showModal;
    @api applicationId;
    @api tableAdditionalConfig;
    @api editRFIRecordId;

    @track relatedDocuments = [];
    @track downloadUrl;
    initData(){
        this.getRFIRecordDetail();
        this.getUploadedDocuments();
        //this.recordLocal = JSON.parse(JSON.stringify(this.editRFIRecord));
    }

    getRFIRecordDetail() {
        this.executeAction(getRFIRecordDetails, {rfiRecordId : this.editRFIRecordId}, (response) => {
            console.log('response_getRFIRecordDetails : ', JSON.parse(JSON.stringify(response)));
            if(response.isSuccess) {
                if(response.rfiRecord) {
                    this.recordLocal = response.rfiRecord;
                }                
            }
        });
    }
    getUploadedDocuments() {
        this.executeAction(getRFIRelatedDocuments, {recordId : this.editRFIRecordId}, (response) => {
            console.log('response_getRFIRelatedDocuments : ', JSON.parse(JSON.stringify(response)));
            if(response.isSuccess) {                
                this.relatedDocuments = response['documents'];
                for(let i=0; i< this.relatedDocuments.length; i++) {
                    let documentOwnerRole = this.relatedDocuments[i].CreatedBy.UserRole.Name;
                    if(documentOwnerRole == 'HMA Analyst' || documentOwnerRole == 'HMA Manager') {
                        this.relatedDocuments[i]['isDeleteAllow'] = false;
                    }else {
                        this.relatedDocuments[i]['isDeleteAllow'] = true;
                    }
                }
                console.log('relatedDocuments : ', this.relatedDocuments);
            }
        });
    }
    isStatusSendToSubApplicantORTimeExtRequested() {
        if(this.recordLocal.Status__c && (this.recordLocal.Status__c == 'Sent to Subapplicant' || this.recordLocal.Status__c == 'Time Extension Requested')) {
            return true;
        }
        return false;
    }
    get isSubApplicantCommentDisabled() {
        if(this.isStatusSendToSubApplicantORTimeExtRequested()) return false;
        return true;
    }
    get isSaveDisabled() {
        if(this.isStatusSendToSubApplicantORTimeExtRequested() ) return false;
        return true;
    }
    get isSubmitDisabled() {
        if(this.isStatusSendToSubApplicantORTimeExtRequested()) return false;
        return true;
    }
    get isRequestForExtensionDisabled() {
        if(this.recordLocal.Status__c && this.recordLocal.Status__c == 'Sent to Subapplicant') return false;
        return true;
    }
    get isFileUploadPresent() {
        if(this.isStatusSendToSubApplicantORTimeExtRequested()) return true;
        return false;
    }
    get isFileDeletePresent() {
        if(this.isStatusSendToSubApplicantORTimeExtRequested()) return true;
        return false;
    }
    handleCloseClick() {
        this.fireCloseModalEvent();
    }

    handleSaveClick() {
        this.processOnRFIRecord('Save');
    }

    handleSubmitClick() {        
        this.processOnRFIRecord('Submit');
    }
    
    handleRequestForExtensionClick() {
        this.processOnRFIRecord('RequestForExtension');
    }
    handleUploadFinished(event) {
        console.log('dataValue : ',event.target.getAttribute("data-value"));
        console.log('uploadedFiles-', event.detail.files);
        this.getUploadedDocuments();
    }
    handleDeleteContentDocument(event) {
        console.log('dataValue_delete_icon : ',event.target.getAttribute("data-value"));
        this.deleteContentDocument(event.target.getAttribute("data-value"));
        
    }
    handleDownloadDocument(event) {
        console.log('dataValue_Download_icon : ',event.target.getAttribute("data-value"));
        let contentVersionId = event.target.getAttribute("data-value");
        if(contentVersionId) {
            this.downloadUrl = '/sfc/servlet.shepherd/version/download/' + contentVersionId;
            window.open(this.downloadUrl);
        }
        
    }
    processOnRFIRecord(buttonAction) {
        let validationResponse = this.validateInputs();
        if(validationResponse == false) return;
        this.executeAction(updateRFIRecordAndSendNotification, {rfiRecord : JSON.stringify(this.recordLocal), applicationId : this.applicationId, actionName : buttonAction}, (response) => {
            console.log('response_updateRFIRecordAndSendNotification : ', JSON.parse(JSON.stringify(response)));
            if(response.isSuccess) {
                if(buttonAction == 'Save') {
                    this.showSuccessNotification('Request for Information Saved Successfully');
                }
                if(buttonAction == 'Submit') {
                    this.showSuccessNotification('Request for Information Submitted Successfully');
                }
                if(buttonAction == 'RequestForExtension') {
                    this.showSuccessNotification('Request for Extension has beed Submitted Successfully');
                }

                this.updateRFIRecords(JSON.parse(JSON.stringify(response)));
            }
        });
    }

    updateRFIRecords(rfiRecord) {
        const updateRFIRecords = new CustomEvent('updaterfirecord', {
            detail: rfiRecord
        });
        this.dispatchEvent(updateRFIRecords);
    }

    fireCloseModalEvent() {
        const closeModalEvent = new CustomEvent('closemodal', {
            detail: false
        });
        this.dispatchEvent(closeModalEvent);
    }
    closeModal() {
        this.fireCloseModalEvent();
    }
    deleteContentDocument(contentDocId) {
        this.executeAction(deleteContentDocument, {contentDocId : contentDocId, linkedEntityId : this.editRFIRecordId}, (response) => {
            console.log('response_deleteContentDocument : ', JSON.parse(JSON.stringify(response)));
            if(response) {
                this.getUploadedDocuments();
            }
        });

        // deleteContentDocument({'contentDocId' : contentDocId, 'linkedEntityId' : editRFIRecordId})
        //     .then(result => {
        //         this.getUploadedDocuments();
        //     }).catch(error => {
        //         console.log('Delete content Doc Error -=-=-=-=--=--=: ', error);
        //     });
   }
   
}