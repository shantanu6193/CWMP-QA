import { LightningElement, track } from 'lwc';
import Utility from 'c/utility';
import apexSearchIncident from '@salesforce/apex/Mars_ReimbursementCtrl.apexSearchIncident';
import getAgencyDetails from '@salesforce/apex/Mars_ReimbursementCtrl.getAgencyDetails';
import apexSearchStrikeTeam from '@salesforce/apex/Mars_ReimbursementCtrl.apexSearchStrikeTeam';
import createReimbursementRecord from '@salesforce/apex/Mars_ReimbursementCtrl.createReimbursementRecord';
import deleteFile from "@salesforce/apex/Mars_ReimbursementCtrl.deleteFile";
import apexSearchUnitNumber from '@salesforce/apex/Mars_ReimbursementCtrl.apexSearchUnitNumber';
import apexSearchIncidentRequestNumber from '@salesforce/apex/Mars_ReimbursementCtrl.apexSearchIncidentRequestNumber';
export default class MarsReimbursementForm extends Utility {

    //lookup related variables
    isMultiEntry = false;
    loadDataOnLookup = false;
    hasError = false;
    //loadDataOnLookupForStrikeTeam = true;
    showFilesTable = false;
    agencyId;
    disableSubmit = false;
    selectedIncidentRecordId;
    incidentOrderNumber = '';
    incidentRequestNumber = '';
    agencyDeatils;
    attachmentTypSelectedValues = [];
    currentIndex = 0;
    StrikeTeam;
    f42Id;
    incidentId;
    //strikeTeamRequired  = [];
    incidentRequired = [];
    hasErrorForFile = false;
    attachmentTypSelectedval = [];
    @track uploadedFiles = [];
    unitNumberList = [];
    incidentRequestNumberOptions = [];
    @track rows;
    initData() {
        let urlId = this.getURLParameter("id");
        this.agencyId = urlId;
        this.recordLocal.Incident__c = undefined;
        this.recordLocal.F_42__c = undefined;
        this.recordLocal.Account__c = this.agencyId;
        if (this.agencyId) {
            this.executeAction(getAgencyDetails, {
                'agencyId': this.agencyId
            }, (response) => {
                this.agencyDeatils = response;
            });
        }
        this.rows = []
        this.rows.push({index: this.currentIndex});
        this.currentIndex++;
    }
    addRow() {
        this.rows.push({
            index: this.currentIndex
        });
        this.currentIndex++;
    }
    removeRow(response) {
            let childIndex = response.detail.index;
            let totalMeal = 0;
            let totalLodging = 0;
            let totalAmount = 0;
            let totalMISC = 0;
            let currentIndex = 0;
            if(this.rows.length > 1 ) {
                let rowElements = this.template.querySelectorAll('c-mars-reimbursement-form-row');
                this.rows.splice(childIndex, 1);
                rowElements.forEach(element => {
                    const tableRow = element.getRecordDetails();
                    if (tableRow != undefined && childIndex != currentIndex) {
                        if (tableRow.Meal__c != undefined ) {
                            totalMeal = totalMeal + Number(tableRow.Meal__c);
                        }
                        if (tableRow.Lodging__c != undefined) {
                            totalLodging = totalLodging + Number(tableRow.Lodging__c);
                        }
                        if (tableRow.MISC__c != undefined) {
                            totalMISC = totalMISC + Number(tableRow.MISC__c);
                        }
                        if (tableRow.Amount__c != undefined) {
                            totalAmount = totalAmount + Number(tableRow.Amount__c);
                        }
                    }
                    currentIndex = currentIndex + 1;
                });
            } else if(this.rows.length == 1) {
                this.rows = [];
                this.currentIndex = 0;
                this.rows.push({index: this.currentIndex});
                this.currentIndex++;

            }
            
            this.recordLocal.Meal_Total__c = totalMeal;
            this.recordLocal.Lodging_Total__c = totalLodging;
            this.recordLocal.MISC_Total__c = totalMISC;
            this.recordLocal.Total_Reimbursement_Amount__c = totalAmount;
    }
        /*
         * Searches Incidents 
         */
    handleIncidentSearch(event) {
        apexSearchIncident({ searchTerm: event.detail.searchTerm })
            .then((results) => {
                this.template.querySelector('[data-lookup="Incident__c"]').setSearchResults(results);
            })
            .catch((error) => {
                this.error('Lookup Error', 'An error occured while searching with the lookup field.');
                console.error('Lookup error', JSON.stringify(error));
                this.errors = [error];
            });
    }

    handleIncidentChange(response) {
            if (response.detail != null && response.detail.selectedItem.id != undefined) {
                this.recordLocal.Incident__c = response.detail.selectedItem.id;
                this.incidentOrderNumber = response.detail.selectedItem.sObject.Order_No__c;
                this.incidentId = this.recordLocal.Incident__c;
                this.incidentRequired = [];
                this.getUnitNumber();
            } else {
                this.recordLocal.Incident__c = undefined;
                this.incidentOrderNumber = undefined;
                this.incidentRequestNumberOptions = [];
                this.unitNumberList = [];
            }
        }
        /*
         * Searches Strike Team
         */
    handleStrikeTeamSearch(event) {
        apexSearchStrikeTeam({ searchTerm: event.detail.searchTerm, incidentId: this.recordLocal.Incident__c })
            .then((results) => {
                this.template.querySelector('[data-lookup="StrikeTeam__c"]').setSearchResults(results);
            })
            .catch((error) => {
                this.error('Lookup Error', 'An error occured while searching with the lookup field.');
                console.error('Lookup error', JSON.stringify(error));
                this.errors = [error];
            });
    }
    getUnitNumber() {
            if(this.incidentId != undefined) {
               apexSearchUnitNumber({
                    incidentId: this.incidentId,
                    strickTeam: this.recordLocal.Strike_Team__c,
                    incidentRequestNumber: this.recordLocal.Incident_Request_Number__c
                })
                .then((result) => {
                    this.unitNumberList = result;
                    this.error = undefined;
                })
                .catch((error) => {
                    this.error = error;
                    console.log('error', this.error);
                    this.unitNumberList = []; 
                });
            } else {
                this.unitNumberList = []; 
            }
    }
    handleStrikeTeamChange(response) {
        if (response.detail != null && response.detail.selectedItem.id != undefined) {
            //this.recordLocal.Incident_Request_Number__c = response.detail.selectedItem.sObject.Incident_Request_Number__c;
            //this.recordLocal.F_42__c = response.detail.selectedItem.id;
            //this.recordLocal.Unit_Number__c = response.detail.selectedItem.sObject.ER_UNIT__c;
            this.recordLocal.Strike_Team__c = response.detail.selectedItem.sObject.Strike_Team__c;
            //this.strikeTeamRequired = []
            this.apexSearchIncidentRequestNumber();
            this.getUnitNumber();
        } else {
            //this.recordLocal.F_42__c = undefined;
            this.recordLocal.Incident_Request_Number__c = undefined;
            this.recordLocal.Unit_Number__c = undefined;
            this.recordLocal.Strike_Team__c = undefined;
            this.incidentRequestNumberOptions = [];
            this.unitNumberList = [];
        }
    }
    handleIncidentRequestNo(event) {
        this.recordLocal.Incident_Request_Number__c = event.target.value;
        this.getUnitNumber();
    }
    handleTotalCalculation(event, skipIndex) {
        //this.rows = [];
        let rowElements = this.template.querySelectorAll('c-mars-reimbursement-form-row');
        let totalMeal = 0;
        let totalLodging = 0;
        let totalAmount = 0;
        let totalMISC = 0;
        let currentIndex = 0;
        rowElements.forEach(element => {
            const tableRow = element.getRecordDetails();
            if (tableRow != undefined /*&& (!skipIndex || (skipIndex != tableRow.index))*/) {
                //this.rows.push(tableRow);
                if (tableRow.Meal__c != undefined) {
                    totalMeal = totalMeal + Number(tableRow.Meal__c);
                }
                if (tableRow.Lodging__c != undefined) {
                    totalLodging = totalLodging + Number(tableRow.Lodging__c);
                }
                if (tableRow.MISC__c != undefined) {
                    totalMISC = totalMISC + Number(tableRow.MISC__c);
                }
                if (tableRow.Amount__c != undefined) {
                    totalAmount = totalAmount + Number(tableRow.Amount__c);
                }
            }
            //currentIndex = currentIndex + 1;
        });
        this.recordLocal.Meal_Total__c = totalMeal;
        this.recordLocal.Lodging_Total__c = totalLodging;
        this.recordLocal.MISC_Total__c = totalMISC;
        this.recordLocal.Total_Reimbursement_Amount__c = totalAmount;
    }

    handleUploadFinished(event) {
        try {
            this.showFilesTable = true;
            let uploadedFile = event.detail.files;
            uploadedFile.forEach((element) => {
                element.Type = undefined;
                this.uploadedFiles.push(element)
            });
        } catch (e) {
            console.log('Error Uplaod file===>', e);
        }
    }
    saveRecord() {
        this.hasError = false;
        this.incidentRequired = [];
        if(this.recordLocal.Incident__c == undefined || this.recordLocal.Incident__c == '') {
            this.incidentRequired.push({ message: 'Complete this field.' });
            return;
        } 
        this.recordLocal.F_42__c = '';
        /*this.strikeTeamRequired = [];
        if(this.recordLocal.F_42__c == undefined || this.recordLocal.F_42__c == '') {
            this.strikeTeamRequired.push({ message: 'Complete this field.' });
            //this.showErrorNotification('Error', 'Please select Strike Team');
            return;
        } */
        if (this.validateInputs() == false) return;
        let saveRecord = this.getReibursLines();
        console.log('Parent==', JSON.stringify(this.recordLocal));
        console.log('Line Item==', JSON.stringify(saveRecord));
        console.log('hasError==',this.hasError);
        if (this.hasError == true) return;
        let signatureBlob = this.template.querySelector('[data-id="signature"]').getSignatureBlob();
        if (signatureBlob == undefined) {
            this.showErrorNotification('Please sign form');
            this.template.querySelector('[data-id="signature"]').refreshCanvas();
            return;
        }
        let fileRecordsToSave = this.validateFileType();
        if(fileRecordsToSave) {
            this.showErrorNotification('Error', 'Please select Attachment Type');
            return;
        }
        this.recordLocal.Attachment_Type__c = this.getAttachmentType();
        console.log('Attachment Type Str==',JSON.stringify(this.recordLocal.Attachment_Type__c));
        //this.showLoader= true;
        this.executeAction(createReimbursementRecord, {
            lineItemsString: JSON.stringify(saveRecord),
            objParentData: JSON.stringify(this.recordLocal),
            signatureBlob: signatureBlob,
            fileUpdateWrapper: JSON.stringify(this.uploadedFiles),
        }, (response) => {
            //this.disableSubmit = true;
            this.showSuccessNotification('Records Submitted Successfully.');
            this.showFilesTable = false;
            this.uploadedFiles = [];
            this.recordLocal.Meal_Total__c = undefined;
            this.recordLocal.Lodging_Total__c = undefined;
            this.recordLocal.MISC_Total__c = undefined;
            this.recordLocal.Total_Reimbursement_Amount__c = undefined;
            this.recordLocal.Incident_Request_Number__c = undefined;
            this.recordLocal.Unit_Number__c = undefined;
            this.incidentOrderNumber = undefined;
            this.recordLocal.Comments__c = undefined;
            this.recordLocal.Submission_Date__c = undefined;
            this.recordLocal.Printed_Name__c = undefined;
            this.initData();
        });
        
    }
    getReibursLines() {
        let recordsToSave = [];
        for (let i = 0; i < this.rows.length; i++) {
            let reimbursLine = this.template.querySelector('[data-id="' + i + '"]').getRecordDetails();
            if (reimbursLine == undefined) {
                this.hasError = true;
            } 
            delete reimbursLine.index;
            recordsToSave.push(reimbursLine);
        }
        return recordsToSave;
    }
    validateFileType() {
        try{
            if(this.uploadedFiles.length > 0) {
                for (let i = 0; i < this.uploadedFiles.length; i++) {
                    if (this.uploadedFiles[i].Type == undefined) {
                        return true;
                    }
                }
            }
        } catch(e) {
            console.log('error==',e);
        }
       
        return false;
    }
    handleSelectedvalues(event) {
        const selectedVal = event.detail.eventvalue;
        this.attachmentTypSelectedValues = [];
        selectedVal.forEach((element) => {
            this.attachmentTypSelectedValues.push(element)
        });
    }
    get attachmentType() {
        return [{
                label: 'Approval Documentation',
                value: 'Approval Documentation'
            },
            {
                label: 'Receipts',
                value: 'Receipts'
            },
            {
                label: 'Damage Claim',
                value: 'Damage Claim'
            },
            {
                label: 'Resource Order',
                value: 'Resource Order'
            },
            {
                label: 'Other',
                value: 'Other'
            },
        ];
    }
    get attachmentTypeSelect() {
        if (this.attachmentTypSelectedValues.length > 0)
            return false;
        else
            return true;
    }
    deleteAttachedFile(event) {
        event.preventDefault();
        const itemIndex = event.currentTarget.dataset.index;
        console.log('Delete row===>', itemIndex);
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
        /*this.executeAction(deleteFile, {
            contentVersionId: itemIndex
        }, (result) => {
            var index = this.uploadedFiles.findIndex(function(fileIndex) {
                return fileIndex.contentVersionId === itemIndex;
            });
            this.uploadedFiles.splice(index, 1)
            this.showSuccessNotification('File is deleted successfully')
            if (this.uploadedFiles.length == 0)
                this.showFilesTable = false;
        });*/
    }
    getAttachmentType(){
        let attachmentType ='';
        //let stringArray = this.attachmentTypSelectedval.toString().split(',');
        for(let i=0;i<this.uploadedFiles.length;i++){
            if(i==0 && attachmentType ==''){
                attachmentType = this.uploadedFiles[i].Type;
            } else {
                if(!attachmentType.includes(this.uploadedFiles[i].Type)){
                    attachmentType = attachmentType+','+ this.uploadedFiles[i].Type;
                }
            }
        }
        return attachmentType;
    }
    handleAttachmentChange(event) {
        const itemIndex = event.currentTarget.dataset.index;
        console.log('Attchment value ===',itemIndex);
        console.log('Attchment value 1 ===',event.target.value);
        for(let i=0;i<this.uploadedFiles.length;i++) { 
            if(this.uploadedFiles[i].contentVersionId == itemIndex) {
                this.uploadedFiles[i].Type = event.target.value;
            }
        }
    }
    apexSearchIncidentRequestNumber() {
        if(this.incidentId != undefined && this.recordLocal.Strike_Team__c != undefined) {
            apexSearchIncidentRequestNumber({
                incidentId: this.incidentId,
                strickTeam: this.recordLocal.Strike_Team__c,
            })
            .then((result) => {
                this.incidentRequestNumberOptions = result;
                this.error = undefined;
            })
            .catch((error) => {
                this.error = error;
                console.log('error', this.error);
                this.incidentRequestNumberOptions = []; 
            });
        } else {
            this.incidentRequestNumberOptions = []; 
        }
}
}