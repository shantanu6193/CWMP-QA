import { LightningElement, api, track, wire} from 'lwc';
import Utility from 'c/utility';
import getFiles from '@salesforce/apex/HMA_ApplicationCtrl.getFiles';
import fileUpload from '@salesforce/apex/HMA_ApplicationCtrl.fileUpload';
import removeFile from '@salesforce/apex/HMA_ApplicationCtrl.removeFile';
import getWorkScheduleLineItem from '@salesforce/apex/HMA_ApplicationCtrl.getWorkScheduleLineItem';
import getApplication from '@salesforce/apex/HMA_ApplicationCtrl.getApplication';
import updateLineItems from '@salesforce/apex/HMA_ApplicationCtrl.updateLineItems';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import WORK_SCHEDULE_LINE_ITEM_OBJ from '@salesforce/schema/Work_Schedule_Line_Item__c';
import PHASE_FIELD from '@salesforce/schema/Work_Schedule_Line_Item__c.Phase__c';
import START_MONTH_FIELD from '@salesforce/schema/Work_Schedule_Line_Item__c.Start_Month__c';
import DURATION_MONTHS_FIELD from '@salesforce/schema/Work_Schedule_Line_Item__c.Duration_Months__c';
import { CurrentPageReference } from 'lightning/navigation';

export default class ApplicationWorkSchedule extends Utility {
    //@api record;
    //@track recordId = "a0Ar0000003v7tUEAQ";
    @api previousLayout;
    @track appRecord = {};
    @track uploadedFiles = [];

    @track keyIndex = 0;  
    @track workScheduleId;
    @track picklistValues = {};
    @track startMonthPicklistValues = {};
    @track durationMonthPicklistValues = {};
    @track workSchedule = [];
    @track workScheduleLineItems = [];
    @track closeoutLineItem = [] ;
    @track calculatedDuration = 0;
    @track durationLimitError = 'Total project duration must not exceed a 36 month period of performance';
    @track visibleFileConfirmationModal = false;
    @track visibleLineItemConfirmationModal = false;
    @track lineItemConfirmationModalOriMessage = '';

    @wire(getObjectInfo, { objectApiName: WORK_SCHEDULE_LINE_ITEM_OBJ }) objectInfo;
    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: PHASE_FIELD})
    picklistPhaseWire({error, data}){
        if(data){
            console.log('Application Record : ',this.appRecord);
            console.log('picklistPhaseWire.values : ',data.values);
            this.preparePhasePicklist(data.values);            
            console.log('Final_picklistPhaseWire : ',this.picklistValues);

        }else if(error){
            console.log('picklistPhaseWire_error: ',error);
        }
    }
    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: START_MONTH_FIELD})
    picklistStartMonthWire({error, data}){
        if(data){
            console.log('picklistStartMonthWire : ',data);
            this.startMonthPicklistValues = data;
        }else if(error){
            console.log('picklistStartMonthWire_error: ',error);
        }
    }
    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: DURATION_MONTHS_FIELD})
    picklistDurationMonthWire({error, data}){
        if(data){
            console.log('picklistDurationMonthWire : ',data);
            this.durationMonthPicklistValues = data;
        }else if(error){
            console.log('picklistDurationMonthWire_error: ',error);
        }
    }

    @wire(CurrentPageReference)
    setCurrentPageRef(currentPageReference) {
        if(currentPageReference && currentPageReference.state && currentPageReference.state.id) {
          if(currentPageReference.state.id) {
                this.recordId = currentPageReference.state.id;
          }
        }
    }

    @wire(getApplication, {appId : '$recordId'})
    wiredgetApplication({ error, data }) {
        if (data) {
            console.log('getApplication_data :',data);
            this.appRecord = data.application;
            if(data.workSchedules.length > 0) {
                //this.workScheduleId = data.workSchedules[0].Id;
            }            
        } else if (error) {
            console.log('getApplication_error :',error);
        }
    } 

    initData() { 
        window.scrollTo(0,0);
        if(this.recordId) {
            this.getWorkScheduleLineItem();
        }
    }
    getWorkScheduleLineItem() {
        this.executeAction(getWorkScheduleLineItem, {'appId' : this.recordId}, (response) => {
            console.log('getWorkScheduleLineItem_response: ',response);
            if(response.length > 0) {
                this.workSchedule.push(JSON.parse(JSON.stringify(response[0].Work_Schedule__r)));
                console.log('getWorkScheduleLineItem_workSchedule : ',this.workSchedule);
                this.workScheduleId = this.workSchedule[0].Id;                
                this.getRelatedFiles();
                this.processOnWorkScheduleLineItemData(response, '');
            }            
        });
    }
    addLineItemRow(event) { 
        this.keyIndex+1;  
        this.processOnWorkScheduleLineItemData(this.workScheduleLineItems, event.target.title);
        console.log('addRow_workScheduleLineItems :',this.workScheduleLineItems);
    }
    
    removeLineItemRow(accessKey){       
        if(this.workScheduleLineItems.length>=1){             
             this.workScheduleLineItems.splice(accessKey,1);
             this.keyIndex-1;
             this.processOnWorkScheduleLineItemData(this.workScheduleLineItems, '');
        }
    }
    fieldChangeHandler(event){
        if(event.target.name === 'Phase__c'){
            this.workScheduleLineItems[event.target.accessKey].Phase__c = event.target.value;
        }else if(event.target.name === 'Task_Name__c'){
            this.workScheduleLineItems[event.target.accessKey].Task_Name__c = event.target.value;
        }else if(event.target.name === 'Description__c'){
            this.workScheduleLineItems[event.target.accessKey].Description__c = event.target.value;
        }
        else if(event.target.name === 'Start_Month__c'){
            this.workScheduleLineItems[event.target.accessKey].Start_Month__c = event.target.value;
            this.processOnWorkScheduleLineItemData(this.workScheduleLineItems);
        }
        else if(event.target.name === 'Duration_Months__c'){
            this.workScheduleLineItems[event.target.accessKey].Duration_Months__c = event.target.value;
            this.processOnWorkScheduleLineItemData(this.workScheduleLineItems);
        }
    }
    
    redirectToPrevious() {
        if(!this.validateTableFields()) return;
        this.saveLineItemRecords();
        const previousLayoutEvent = new CustomEvent('previouslayoutevent', {
            detail: this.previousLayout,
        });
        this.dispatchEvent(previousLayoutEvent);
    }
    quickSave() {
        if(!this.validateTableFields()) return;
        this.saveLineItemRecords();
    }
    saveAndContinue() {
        if(!this.validateTableFields()) return;
        this.saveLineItemRecords();        
    }
    saveLineItemRecords() {
        this.workSchedule[0].Project_Plan_Duration_In_Months__c = parseInt(this.calculatedDuration);
        this.executeAction(updateLineItems, {'lineItemRecords' : JSON.stringify(this.workScheduleLineItems), 'workScheduleRecord' : JSON.stringify(this.workSchedule)}, (response) => {
            console.log('updateLineItems_response: ',response);
        });
    }
    validateTableFields() {
        let isValid = true;
        this.template.querySelectorAll(".input").forEach(element => {
            if(!element.reportValidity() || this.isDurationLimitError) {
                isValid = false;
            }
          });
          console.log('isValid : ',isValid);
          return isValid;
    }
    processOnWorkScheduleLineItemData(lineItemData, addLineItem) {
        let tableIndex = 0;
        let lineItems = [];
        let largeSumValue = 0;
        for(var i=0; i<lineItemData.length; i++) {
            if(lineItemData[i].Phase__c == 'Closeout') {
                let closeoutJsonObj = JSON.parse(JSON.stringify(lineItemData[i]));
                this.closeoutLineItem = closeoutJsonObj;
            } else {
                let otherJsonObj = JSON.parse(JSON.stringify(lineItemData[i]));
                otherJsonObj['TableIndex'] = ++tableIndex;
                let sumOfMonths = parseInt(otherJsonObj.Start_Month__c) + parseInt(otherJsonObj.Duration_Months__c);
                if(parseInt(sumOfMonths) > parseInt(largeSumValue)) {
                    largeSumValue = parseInt(sumOfMonths);
                }
                lineItems.push(otherJsonObj);
            }
        }
        if(addLineItem == 'addLineItem') {
            lineItems.push({    
                Phase__c : '',        
                Task_Name__c: '',
                Description__c: '',
                Start_Month__c: '',
                Duration_Months__c:'',
                TableIndex: ++tableIndex,
                Work_Schedule__c: this.workScheduleId
            });
        }
        this.calculatedDuration = parseInt(largeSumValue) + 3;
        this.workScheduleLineItems = lineItems;
        console.log('AfterProcess_calculatedDuration : ',this.calculatedDuration);
        console.log('AfterProcess_workScheduleLineItems : ',this.workScheduleLineItems);
    }
    preparePhasePicklist(values) {
        let otherPicklistArray = [];
        let phasePicklistArray = [];
        let phasePlanPicklistArray = [];
        for(let key in values){
            let valueArray = JSON.parse(JSON.stringify(values[key]));
            if((this.appRecord && this.appRecord.Application_Type__c == 'Planning') && !(valueArray.value == 'Phase 1' || valueArray.value == 'Phase 2' || valueArray.value == 'Closeout')) {
                phasePlanPicklistArray.push(valueArray);
            } else if((this.appRecord && this.appRecord.Application_Type__c != 'Planning') && (valueArray.value == 'Phase 1' || valueArray.value == 'Phase 2')) {
                phasePicklistArray.push(valueArray);
            } else {
                otherPicklistArray.push(valueArray);
            }           
        }
        if(this.appRecord && this.appRecord.Application_Type__c == 'Planning') {
            this.picklistValues = phasePlanPicklistArray;
        } else if(this.appRecord && this.appRecord.Application_Type__c != 'Planning') {
            this.picklistValues = phasePicklistArray;
        } else {
            this.picklistValues = otherPicklistArray;
        }
    }
    get getDisbleIndex() {
        return this.workScheduleLineItems.length + 1;
    }    
    get acceptedFormats() {
        return ['.zip'];
    }
   /* get phaseColumnTitle() {
        if(this.isSubAppTypePlanning) {
            return 'Phase Plan';
        } else if(!this.isProjectPhasedNo) {
            return 'Phase';
        } 
        return '';
    }*/
    get isProjectPhasedNo() {
        let AccountArray = [];
        for(let key in this.appRecord.Subapplicant_Entity__r) {
            let jsonRecord = this.appRecord.Subapplicant_Entity__r[key];
            AccountArray.push(jsonRecord);
        }
        if(!this.isSubAppTypePlanning && AccountArray[0] == 'No') {
            return true;
        } else {
            return false;
        }
    }
    get isSubAppTypePlanning() {
        return this.appRecord.Application_Type__c == 'Planning' ? true : false;
    }
    get isFileUploaded() {
        if(this.uploadedFiles.length > 0) return true;
        return false;
    }
    get isDurationLimitError() {
        if(parseInt(this.calculatedDuration) > 36) {
            return true;
        }
        return false;
    }
    getUrl() {
        let baseUrl = 'https://'+location.host+'/';
        return baseUrl;
    }

    prepareFileURL(fileData) {
        let file = [];
        let baseUrl = this.getUrl();
        for(let key in fileData){
            let jsonObj = JSON.parse(JSON.stringify(fileData[key]));
            jsonObj.FileType = jsonObj.FileType.toLowerCase();
            jsonObj['url'] = baseUrl+'sfc/servlet.shepherd/document/download/'+jsonObj.ContentDocumentId;
            file.push(jsonObj);
        }
        this.uploadedFiles = file;
    }
    handleUploadFinished(event) {
        let docId = event.detail.files[0].documentId;
        if(event.detail.files.length > 0 && docId != '') {
            this.executeAction(fileUpload, {'documentId' : docId}, (response) => {
                console.log('response_fileUpload----',response);
                if(response) {
                    this.prepareFileURL(response);
                }
            });  
        }
    }   
    getRelatedFiles() {
        let jsonObj = [];
        jsonObj.push('GANTT Chart');
        this.executeAction(getFiles, {'workScheduleId' : this.workScheduleId, 'documentType' : JSON.stringify(jsonObj) }, (response) => {
            console.log(' getFiles_response: -----',response);
            if(response.length > 0){
                this.prepareFileURL(response);      
            } else {
                this.uploadedFiles = [];
            }
        });
    }
    
    handleRemoveFile() {
        
        this.executeAction(removeFile, {'contentDocId' : this.uploadedFiles[0].ContentDocumentId}, (response) => {
            console.log('removeFile_response: -----',response);
            if(response == true) {
                this.uploadedFiles = [];
                this.showSuccessNotification('File removed successfully', '');
            } else {
                this.showErrorNotification('File was not removed', '');
            }
        });
    }
    handleRemoveFileClick() {
        this.visibleFileConfirmationModal = true;
    }
    handleFileConfirmationClick(event) {
        let action = event.detail;
        if(action.status == 'confirm') {
            this.handleRemoveFile();
        }
        this.visibleFileConfirmationModal = false;
    }
    handleRemoveLineItemClick(event) {
        this.LineItemConfirmationModalOriMessage = event.target.accessKey;
        this.visibleLineItemConfirmationModal = true;        
    }
    handleLineItemConfirmationClick(event) {
        let action = event.detail;
        if(action.status == 'confirm') {
            this.removeLineItemRow(action.originalMessage);
        }
        this.visibleLineItemConfirmationModal = false;  
    }
}