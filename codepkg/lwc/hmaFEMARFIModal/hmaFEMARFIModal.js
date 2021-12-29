import { LightningElement, api, track, wire } from 'lwc';
import Utility from 'c/utility';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import REQUEST_FOR_INFORMATION_OBJECT from '@salesforce/schema/Request_For_Information__c';
import RFI_TYPE_FIELD from '@salesforce/schema/Request_For_Information__c.RFI_Type__c';
import  STATUS_FIELD from '@salesforce/schema/Request_For_Information__c.Status__c';
import updateRFIRecordAndSendNotification from '@salesforce/apex/HMA_RequestForInformationCtrl.updateRFIRecordAndSendNotification';
import attachUploadedFilesToRFI from '@salesforce/apex/HMA_RequestForInformationCtrl.attachUploadedFilesToRFI';
import getRFIRecordDetails from '@salesforce/apex/HMA_RequestForInformationCtrl.getRFIRecordDetails';
import getRFIRelatedDocuments from '@salesforce/apex/HMA_RequestForInformationCtrl.getRFIRelatedDocuments';
import deleteContentDocument from '@salesforce/apex/HMA_RequestForInformationCtrl.deleteContentDocument';


export default class HmaFEMARFIModal extends Utility {
    @api showModal;
    @api applicationId;
    @api tableAdditionalConfig;
    @api editFEMARFIRecordId;

    @track rfiRecordId;
    @track rfiTypeOriginalValues;
    @track rfiStatusOriginalValues;
    @track rfiDeadline;
    @track rfiStatus;
    @track rfiTypePicklistOptions = [];
    @track statusPicklistOptions = [];
    @track contentDocumentIds = [];
    @track relatedDocuments = [];
    @track hmaRecordTypeId;

    disableRfiType = false;
    
    @wire(getObjectInfo, { objectApiName: REQUEST_FOR_INFORMATION_OBJECT })
    rfiData({error, data}) {
        if(data){
            const rtis = data.recordTypeInfos;
            this.hmaRecordTypeId = Object.keys(rtis).find(rti => rtis[rti].name === 'HMA');
        }else if(error){
            console.log('Error while getting REQUEST_FOR_INFORMATION_OBJECT')
        }
    }

    /**Used for gat RFI Type picklist values */
    @wire(getPicklistValues, {
            recordTypeId: '$hmaRecordTypeId',
            fieldApiName: RFI_TYPE_FIELD
        }
    )rfiTypeData({error, data}){
        if(data) {
            console.log('RFITypePicklistValues: ', data.values);
            this.rfiTypeOriginalValues = data;
            let specifiedPicklistValues = ['FEMA OES Programmatic', 
                                            'FEMA OES EHP'];
            this.rfiTypePicklistOptions = this.getSpecifiedPicklistValues(data.values, specifiedPicklistValues);
        } else if(error) {
            console.log('error_RFITypePicklistValues: ', error);
        }
    };

    /**Used for gat Status picklist values */
    @wire(getPicklistValues, {
            recordTypeId: '$hmaRecordTypeId',
            fieldApiName: STATUS_FIELD
        }
    )statusData({error, data}){
        if(data) {
            console.log('StatusPicklistValues: ', data.values);
            this.rfiStatusOriginalValues = data;
            this.populateDependentValue();
        } else if(error) {
            console.log('error_StatusPicklistValues: ', error);
        }
    };

    initData(){
        if(this.editFEMARFIRecordId) {
            this.rfiRecordId = this.editFEMARFIRecordId;
            this.getFEMARFIRecordDetail();
            this.getUploadedDocuments();
        }        
    }


    rfiTypeFieldChanged(event){
        this.recordLocal[event.target.getAttribute('data-field')] = event.target.value;
        this.populateDependentValue();
    }

    populateDependentValue() {
        if(this.rfiStatusOriginalValues && this.rfiStatusOriginalValues.values) {
            let updatedValues = [];
            let key = this.rfiStatusOriginalValues.controllerValues[this.recordLocal['RFI_Type__c']];
            updatedValues = this.rfiStatusOriginalValues.values.filter(opt => opt.validFor.includes(key));
            this.statusPicklistOptions = updatedValues;
            console.log('updatedValues--------'+updatedValues);
        }
    }

    getSpecifiedPicklistValues(values, specificValues) {
        let resultPicklistValues = [];
        for(let i=0; i< values.length; i++) {
            
            if(specificValues.includes(values[i].value)) {
                resultPicklistValues.push(values[i]);
            }
        }
        console.log('resultPicklistValues--------: ', resultPicklistValues);
        return resultPicklistValues;
    }
    getFEMARFIRecordDetail() {
        this.executeAction(getRFIRecordDetails, {rfiRecordId : this.rfiRecordId}, (response) => {
            console.log('response_getFEMARFIRecordDetail : ', JSON.parse(JSON.stringify(response)));
            if(response.isSuccess) {
                if(response.rfiRecord) {
                    this.recordLocal = response.rfiRecord;
                    this.rfiDeadline = this.recordLocal.RFI_Deadline__c;
                    this.rfiStatus = this.recordLocal.Status__c;
                    this.populateDependentValue();
                }                
            }
        });
    }
    getUploadedDocuments() {
        this.executeAction(getRFIRelatedDocuments, {recordId : this.rfiRecordId}, (response) => {
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
    isStatusFEMADraft() {
        if(this.recordLocal['Status__c'] && this.recordLocal['Status__c'] == 'FEMA Draft') return true;
        return false;
    }

    //If status is FEMA Draft then only rfi type will be enabled else it will be disabled
    get isRFITypeDisabled() {
        if(this.isStatusHide || this.isStatusFEMADraft()) {
            this.disableRfiType = false;
        } else {
            this.disableRfiType = true;
        }
        return this.disableRfiType;
    }
    get isSaveDisabled() {
        if(this.isStatusFEMADraft() || !this.editFEMARFIRecordId || this.recordLocal['Status__c'] == 'FEMA Time Extension Accepted' || this.recordLocal['Status__c'] == 'FEMA Time Extension Rejected'
            || this.recordLocal['Status__c'] == 'FEMA Programmatic RFI Accepted' || this.recordLocal['Status__c'] == 'FEMA Programmatic RFI Rejected'
            || this.recordLocal['Status__c'] == 'FEMA EHP RFI Accepted' || this.recordLocal['Status__c'] == 'FEMA EHP RFI Rejected') return false;
        return true;
    }
    get isSubmitDisabled() {
       if(this.isStatusFEMADraft() || !this.editFEMARFIRecordId) return false;
        return true;
    }
    get isStatusHide() {
        if(!this.editFEMARFIRecordId) return true;
        return false;
    }
    get isStatusDisabled() {
        if(this.isStatusFEMADraft()) return true;
        return false;
    }
    get isFileUploadPresent() {
        if(this.isStatusFEMADraft() || !this.editFEMARFIRecordId) return true;
        return false;
    }
	get isFileDeletePresent() {
		if(this.isStatusFEMADraft() || !this.editFEMARFIRecordId) return true;
		return false;
	}
    
    handleCloseClick() {
        this.fireCloseModalEvent();
    }

    handleSaveClick() {
        this.processOnFEMARFIRecord('Save');
    }

    handleSubmitClick() {        
        this.processOnFEMARFIRecord('FEMASubmit');
    }
    
    handleUploadFinished(event) {
        console.log('dataValue : ',event.target.getAttribute("data-value"));
        console.log('uploadedFiles-', event.detail.files);
        let file = event.detail.files[0];
        if(event.target.getAttribute("data-value") == '' || event.target.getAttribute("data-value") == undefined) {
            this.contentDocumentIds.push(file.documentId);
            let fileName = file.name;
            let splitName = fileName.split('.');
            file['Title'] = splitName[0];
            file['FileType'] = splitName[1];
            file['Id'] = file.contentVersionId;
            file['ContentDocumentId'] = file.documentId;
            file['isDeleteAllow'] = true;
            console.log('Final_file------', file);
            this.relatedDocuments.push(file);
        } else {
            this.getUploadedDocuments();
        }
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
    // fieldChangedEvent(event) {
    //     let fieldName = event.target.getAttribute("data-field");
    //     this.recordLocal[fieldName] = event.target.value;
    //     console.log(' this.recordLocal : ', JSON.parse(JSON.stringify( this.recordLocal)));
    // }
    processOnFEMARFIRecord(buttonAction) {
        console.log('recordLocal--------', JSON.parse(JSON.stringify(this.recordLocal)));
        let validationResponse = this.validateInputs();
        let rfiDeadlineValidation = this.validateDeadline();
        if(validationResponse == false) return;
        if(rfiDeadlineValidation == false) return;

        if(!this.recordLocal["Id"]){
            this.recordLocal["recordTypeId"] = this.hmaRecordTypeId;
        }
        this.executeAction(updateRFIRecordAndSendNotification, {rfiRecord : JSON.stringify(this.recordLocal), applicationId : this.applicationId, actionName : buttonAction}, (response) => {
            console.log('response_processOnFEMARFIRecord : ', JSON.parse(JSON.stringify(response)));
            if(response.isSuccess) {
                if(this.contentDocumentIds.length > 0) {
                    this.rfiRecordId = response.rfiRecord.Id;
                    this.attachUploadedDocumentsToRFIRecord();
                }
                if(buttonAction == 'Save') {
                    this.showSuccessNotification('Request for Information Saved Successfully');
                }
                if(buttonAction == 'Submit') {
                    this.showSuccessNotification('Request for Information Submitted Successfully');
                }
                if(buttonAction == 'RequestForExtension') {
                    this.showSuccessNotification('Request for Extension has beed Submitted Successfully');
                }

                this.updateFEMARFIRecords(JSON.parse(JSON.stringify(response)));
            }
        });
    }
    attachUploadedDocumentsToRFIRecord() {
        this.executeAction(attachUploadedFilesToRFI, {contentDocumentIds : this.contentDocumentIds, rfiId : this.rfiRecordId}, (response) => {
            console.log('response_attachUploadedFilesToRFI : ', JSON.parse(JSON.stringify(response)));
            if(response.isSuccess) {
                this.getUploadedDocuments();
            }
        });
    }

    updateFEMARFIRecords(rfiRecord) {
        const updateFEMARFIRecords = new CustomEvent('updatefemarfirecord', {
            detail: rfiRecord
        });
        this.dispatchEvent(updateFEMARFIRecords);
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
        this.executeAction(deleteContentDocument, {contentDocId : contentDocId}, (response) => {
            console.log('response_deleteContentDocument : ', JSON.parse(JSON.stringify(response)));
            if(response.isSuccess) {
                if(this.rfiRecordId) {
                    this.getUploadedDocuments();
                } else if(response.contentDocId){
                    let documents = this.relatedDocuments;
                    for(let i=0; i< documents.length; i++) {
                        if(documents[i].ContentDocumentId == response.contentDocId) {
                            this.relatedDocuments.splice(i, 1);
                        }
                    }
                }                
            }
        });
   }

    validateDeadline() {
        let rfiRecord = JSON.parse(JSON.stringify(this.recordLocal));
        const nowDate = new Date();
        const deadline = new Date(rfiRecord.RFI_Deadline__c);
        let stringToday = nowDate.getFullYear()+'/'+nowDate.getMonth()+'/'+nowDate.getDate();
        const todayDate = new Date(stringToday);
        let stringDeadline =  deadline.getFullYear()+'/'+deadline.getMonth()+'/'+deadline.getDate();
        const deadlineRFI = new Date(stringDeadline);

        console.log('nowDate---',todayDate,'--deadline--',deadlineRFI,'--condition--',deadlineRFI < todayDate);
        if(rfiRecord != undefined && rfiRecord != '') {
            if(deadlineRFI < todayDate) {
                this.showErrorNotification('Error', 'RFI Deadline cannot be a past date');
                return false;
            }
            if((this.rfiStatus == 'FEMA Time Extension Requested' && rfiRecord.Status__c == 'FEMA Time Extension Accepted' ) && (this.rfiDeadline >= rfiRecord.RFI_Deadline__c)) {
            this.showErrorNotification('Error', 'Approved Time Extension Notice must include the new RFI Due Date');
            return false;
            }
        }
        return true;
    }

}