import {
    LightningElement,
    api,
    track
} from 'lwc';
import Utility from 'c/utility';
import getFiles from "@salesforce/apex/MARS_SurveyLineItemsDataTableCtrl.getFiles"; //SurveyLineItemsDataTableController
import createAgreeLineItem from "@salesforce/apex/MARS_ResourceAgreementCtrl.createAgreeLineItem";
import deleteFile from "@salesforce/apex/MARS_ResourceAgreementCtrl.deleteFile";
import getData from "@salesforce/apex/MARS_ResourceAgreementCtrl.getData";
import { updateDataflowJob } from 'lightning/analyticsWaveApi';
export default class MarsResourceAgreement extends Utility {
    @api objectName;
    @api fieldSetName;
    @api recordId;
    @api headerTitle;
    isDisabled = false;
    minDate;
    startDate;
    endDate;
    isLoading = true;
    currentIndex = 1;
    productsMap;
    productFamily;
    isQuantityEditable;
    fulfilmentOptions;
    @track agreementList;
    agreementTypSelectedValues = [];
    showFilesTable = false;
    @track uploadedFiles = [];
    disableSubmit = false;
    agreementTypSelectedval = [];
    error;
    agreementRestrictOTOptionsImp = ["Chief", "Deputy Chief", "Division Chief", "Assistant Chief"];
    initData() {
        this.executeAction(getData, {
            accountId: this.recordId
        }, (result) => {
            this.disableSubmit = result.disableSubmit;
        });
        //let last = new Date(new Date().getFullYear(), new Date().getMonth(), new Date().getDate());
        //this.minDate = last.toISOString().slice(0, 10);
        this.minDate = this.todayDateInYYYYMMDD();
        this.futureDate = this.todayDateInYYYYMMDD();
        if (this.startDate == undefined)
            this.startDate = this.minDate;
        if (this.endDate == undefined)
            //this.endDate = this.minDate;
            if (this.agreementList == undefined) {
                this.agreementList = [];
                this.agreementList.push({
                    index: 0
                });
            } else if (this.agreementList != undefined) {
            for (let i = 0; i < this.agreementList.length; i++) {
                this.agreementList[i].index = this.currentIndex;
                this.currentIndex++;
            }
        }
        //this.skipCustomLogicValidation = true;
    }

    handleUploadFinished(event) {
        try {
            this.showFilesTable = true;
            let uploadedFile = event.detail.files
            let attachmentType = this.agreementTypSelectedValues.toString();
            this.agreementTypSelectedval.push(attachmentType);
            uploadedFile.forEach((element) => {
                element.Type = attachmentType;
                this.uploadedFiles.push(element)
            });
        } catch (e) {
            console.log('Error Uplaod file===>', e);
        }
    }
    get attachmentType() {
        return [{
                label: 'MOU',
                value: 'MOU'
            },
            {
                label: 'GBR',
                value: 'GBR'
            },
            {
                label: 'MOA',
                value: 'MOA'
            },
            {
                label: 'Other',
                value: 'Other'
            },
        ];
    }
    get acceptedFormats() {
        return ['.pdf', '.csv'];
    }
    handleFutureDateChange(event) {
        this.futureDate = event.target.value;
    }
    handleAttachmentChange(event) {
        this.Type__c = event.target.value;
        this.isDisabled = false;

    }

    /*
     * Add empty row
     */
    handleAddItem(response) {
        this.agreementList.push({
            index: this.currentIndex
        });
        this.currentIndex++;
    }

    /*
     * Delete selected row
     */
    handleDeleteItem(response) {
        let childIndex = response.detail.index;
        if (this.agreementList.length > 1) {
            this.agreementList.splice(childIndex, 1);
        } else if (this.agreementList.length == 1) {
            this.agreementList = undefined;
            this.agreementList = [];
            this.agreementList.push({
                index: 0
            });
        }
    }
    validateCustomInput() {
        let isSuccess = true;
        if (this.agreementList == undefined ||
            this.agreementList.length < 1) {
            isSuccess = false;
            this.showErrorNotification('Error', 'Please add atleast one Record')
        }
        return isSuccess;
    }
    handleSelectedvalues(event) {
        const selectedVal = event.detail.eventvalue;
        this.agreementTypSelectedValues = [];
        selectedVal.forEach((element) => {
            this.agreementTypSelectedValues.push(element)
        });
    }
    get agreementTypeSelect() {
        if (this.agreementTypSelectedValues.length > 0)
            return false;
        else
            return true;
    }
    hasError;
    getAgreementLines() {
        let recordsToSave = [];

        for (let i = 0; i < this.agreementList.length; i++) {
            let agreement = this.template.querySelector('[data-id="' + i + '"]').getRecordDetails();
            if (agreement == undefined) {
                this.hasError = true;
            }
            let titleName = agreement.Name;
            let containsPTPVal = this.agreementRestrictOTOptionsImp.some(function (arrVal) {
                return titleName === arrVal;
            });
            if(!containsPTPVal && agreement.PTP__c == false) {
                this.hasError = true;
                this.showErrorNotification('Please select Portal-To-Portal for '+ agreement.Name);
                return recordsToSave;
            }
            delete agreement.index;
            //agreement.Start_Date__c = this.startDate;
            //agreement.End_Date__c = this.endDate;
            recordsToSave.push(agreement);
        }
        return recordsToSave;
    }

    saveRecord() {
        if (this.validateInputs() == false) return;
        this.hasError = false;
        let recordsToSave = this.getAgreementLines();
        if (this.hasError == true) return;
        let agreementType = this.convertListToString();
        if(agreementType == undefined || agreementType == '') {
            this.showErrorNotification('Please Select Agreement Type');
            return;
        }
        if(this.uploadedFiles == undefined || this.uploadedFiles.length == 0) {
            this.showErrorNotification('Please Upload Files');
            return;
        }

        this.executeAction(createAgreeLineItem, {
            agreementList: JSON.stringify(recordsToSave),
            accountId: this.recordId,
            startDate: this.startDate,
            endDate: this.endDate,
            fileUpdateWrapper: JSON.stringify(this.uploadedFiles),
            agreementType: agreementType
        }, (response) => {
            this.disableSubmit = true;
            this.uploadedFiles = undefined;
            this.startDate = undefined;
            this.endDate = undefined;
            this.showFilesTable = false;
            this.agreementList = [];
            this.currentIndex = 1;
            this.agreementList.push({
                index: 0
            });
            this.showSuccessNotification('Agency Rate Agreement Line Item created successfully')
            this.template.querySelector("c-mars-resource-agreement-history").initData();
        });
    }
    handelStartDate(event) {
        this.startDate = event.target.value;
        const std = new Date(this.startDate);
        const end = new Date(this.endDate);
        const mnd = new Date(this.minDate);
        let startDateCmp = this.template.querySelector(".startdate");
        if (std < mnd) {
            startDateCmp.setCustomValidity("Please select a future date");
            startDateCmp.reportValidity();
            return false;
        } else if (this.endDate != undefined && std > end) {
            startDateCmp.setCustomValidity("Start date should be less than End date");
            startDateCmp.reportValidity();
            return false;
        } else {
            startDateCmp.setCustomValidity("");
            startDateCmp.reportValidity();
            let endDateCmp = this.template.querySelector(".enddate");
            if (std <= end) {
                endDateCmp.setCustomValidity("");
                endDateCmp.reportValidity();
            }
            return true;
        }
    }
    handelEndDate(event) {
        this.endDate = event.target.value;
        let endDateCmp = this.template.querySelector(".enddate");
        if (this.endDate != null) {
            const std = new Date(this.startDate);
            const end = new Date(this.endDate);
            const mnd = new Date(this.minDate);
            if (end < mnd) {
                endDateCmp.setCustomValidity("Please select a future date");
                endDateCmp.reportValidity();
                return false;
            } else if (std > end) {
                endDateCmp.setCustomValidity("End date should be greater than Start date");
                endDateCmp.reportValidity();
                return false;
            } else {
                endDateCmp.setCustomValidity("");
                endDateCmp.reportValidity();
                let startDateCmp = this.template.querySelector(".startdate");
                if (std <= end) {
                    startDateCmp.setCustomValidity("");
                    startDateCmp.reportValidity();
                }
                return true;
            }
        } else {
            endDateCmp.setCustomValidity("");
            endDateCmp.reportValidity();
        }
    }
    deleteAttachedFile(event) {
        //event.preventDefault();
        const itemIndex = event.currentTarget.dataset.index;
        deleteFile({ contentVersionId: itemIndex })
            .then((result) => {
                var index = this.uploadedFiles.findIndex(function (fileIndex) {
                    return fileIndex.contentVersionId === itemIndex;
                });
                this.uploadedFiles.splice(index, 1)
                this.showSuccessNotification('File is deleted successfully');
                if (this.uploadedFiles.length == 0)
                    this.showFilesTable = false;
            })
            .catch((error) => {
                this.showErrorNotification('File is not deleted');
            });
        /*const itemIndex = event.currentTarget.dataset.index;
        this.executeAction(deleteFile, {
            contentVersionId: itemIndex
        }, (result) => {
            var index = this.uploadedFiles.findIndex(function (fileIndex) {
                return fileIndex.contentVersionId === itemIndex;
            });
            this.uploadedFiles.splice(index, 1)
            this.showSuccessNotification('File is deleted successfully')
            if (this.uploadedFiles.length == 0)
                this.showFilesTable = false;
        });*/
    }
    convertListToString() {
        let agreemntType = '';
        let stringArray = this.agreementTypSelectedValues.toString().split(',');
        for (let i = 0; i < stringArray.length; i++) {
            if (i == 0 && agreemntType == '') {
                agreemntType = stringArray[i];
            } else {
                if (!agreemntType.includes(stringArray[i])) {
                    agreemntType = agreemntType + ',' + stringArray[i];
                }
            }
        }
        return agreemntType;
    }
}