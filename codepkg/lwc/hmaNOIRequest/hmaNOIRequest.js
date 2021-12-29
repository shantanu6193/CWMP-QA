import { LightningElement, track, api, wire} from 'lwc';
import submitRequest from '@salesforce/apex/HMANOIRequest_Ctrl.submitRequest';
import getRecordData from '@salesforce/apex/HMANOIRequest_Ctrl.getRecordData';
import getRecordTypes from '@salesforce/apex/HMANOIRequest_Ctrl.getRecordTypes';
import Utility from 'c/utility';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';

export default class EocNewRequest extends Utility {
    
    @track currentStage = '';
    @track recordId;
    @track isRecordLoaded = false;
    actionClicked = '';
    recordTypeList = [];
    recordTypeOptions = [];
    selectedRecordTypeId;
    selectedRecordTypeName;
    showModal = false;
    get stagesList() {
        /*if(this.record.Application_Type__c != 'Project' && this.record.Applicant_Type__c == 'Private Non-Profit') {
            return ['GeneralInfo','ProjectInfo','AdditionalInfo','Preview'];
        }
        else {
            return ['GeneralInfo','ProjectInfo','ActivityInfo','AdditionalInfo','Preview'];
        }*/
        return ['GeneralInfo','ProjectInfo','ActivityInfo','AdditionalInfo','Preview'];
    }
    @wire(CurrentPageReference)
    setCurrentPageRef(currentPageReference) {
        if(currentPageReference && currentPageReference.state && currentPageReference.state.currentStage) {
          if(currentPageReference.state.id) {
                this.recordId = currentPageReference.state.id;
          }
          this.retrieveData(currentPageReference.state.currentStage);
        }
    }

    initData() {
        this.retrieveData(this.currentStage);
        if(this.recordId == undefined || this.recordId == null){
            this.showModal = true;
            this.getRecordTypeList();
        }
    }

    getRecordTypeList(){
        this.executeAction(getRecordTypes,{}, (response) => {
        this.recordTypeList = response.RecordTypes;
        console.log('recordTypes------>',JSON.stringify(this.recordTypeList));
            let optionsValues = [];
            for(let i = 0; i < this.recordTypeList.length; i++) {
                optionsValues.push({
                    label: this.recordTypeList[i].MasterLabel,
                    value: this.recordTypeList[i].RecordType_Id__c
                })
            }
            this.recordTypeOptions = optionsValues;
            console.log('optionsValues ===> '+JSON.stringify(optionsValues));
       });
    }
    retrieveData(stageName) {
        let preAppId = this.getURLParameter("id");
        this.recordId = preAppId;
        console.log('stageName= '+stageName);
        if(preAppId){
            this.executeAction(getRecordData, {'recordId' : preAppId}, (response) => {
                this.handleGetDataResponse(response, stageName);
            });
        } else {
            this.currentStage = 'GeneralInfo';
        }
    }

    handleGetDataResponse(result, stageName) {
        debugger;
        this.record = result;
        this.recordLocal = result;
        this.currentStage = stageName;
        console.log('Parent record= '+JSON.stringify(this.record));
        let currentStageURL = this.getURLParameter("currentStage");
        if(currentStageURL) {
            this.currentStage = currentStageURL;
        } else {
             this.currentStage = 'GeneralInfo';
        }
        if(this.record.RecordTypeId != undefined || this.record.RecordTypeId != null) {
            this.selectedRecordTypeName = this.record.RecordType.Name;
        }
        /*this.template.querySelector('c-hma-n-o-i-path').handleStage(this.currentStage,'next',this.stagesList);*/
    }
    get isGeneralInfoStage() {
        if(this.currentStage == 'GeneralInfo') return true;
        return false;
    }
    get isProjectInfoStage() {
        if(this.currentStage == 'ProjectInfo') return true;
        return false;
    }
    get isActivityInfoStage() {
        if(this.currentStage == 'ActivityInfo') return true;
        return false;
    }
    get isAdditionalInfoStage() {
        if(this.currentStage == 'AdditionalInfo') return true;
        return false;
    }

    get isPreviewStage() {
        if(this.currentStage == 'Preview') return true;
        return false;
    }

    redirectToPrevious() {
        this.getData(true);
        this.actionClicked = 'Previous';
        this.processSaveCallback(this.record);
        //this.template.querySelector('c-hma-n-o-i-path').handleStage(this.currentStage,'prev');
    }

    redirectToNext() {
        if(this.getData(false) == false) {
            return;
        }
        this.actionClicked = 'Next';
        this.record.Current_Stage__c = this.currentStage;
        this.saveRecord(this.record);
        //this.template.querySelector('c-hma-n-o-i-path').handleStage(this.currentStage, 'next');
    }

    getData(isPrevious) {
        if(this.template.querySelector('[data-custom="innerComponent"]') != undefined) {
            if(isPrevious == true) {
                this.template.querySelector('[data-custom="innerComponent"]').skipAllValidations();
            } else {
                if(this.currentStage == 'AdditionalInfo') {
                    this.template.querySelector('[data-custom="innerComponent"]').skipInputValidations();
                    this.template.querySelector('[data-custom="innerComponent"]').enableCustomValidations();
                } else {
                    this.template.querySelector('[data-custom="innerComponent"]').enableAllValidations();
                }

            }
            let localRecord = this.template.querySelector('[data-custom="innerComponent"]').getRecordDetails();
            console.log('....lll',localRecord);
            if(localRecord != undefined) {
                this.record = localRecord;
                if(!this.checkPercentageApplicantMatchLimit()) return false;;
                return true;
            }
        }
        console.log('record--', JSON.parse(JSON.stringify(this.record)));
        if(this.currentStage != 'AdditionalInfo') {
            window.scrollTo(0,0);
            this.showNotification('Error', 'Please complete all required fields', 'error', 'dismissable');
        }
        return false;
    }
    checkPercentageApplicantMatchLimit() {
        if(this.record.Percentage_of_Applicant_Match__c < 25) {
            this.showErrorNotification('', 'Please make sure Percentage of Non Federal Cost Share at least 25%');
            return false;
        }
        return true;
    }
    submit() {
       /*let recordTosend = JSON.parse(JSON.stringify(this.record));
        if(recordTosend.Contact_Roles__r && !recordTosend.Contact_Roles__r.records) {
            recordTosend.Contact_Roles__r= {
                totalSize: recordTosend.Contact_Roles__r.length,
                done: true,
                records: recordTosend.Contact_Roles__r
            };
        }
        this.executeAction(submitRequest, { recordData : JSON.stringify(recordTosend)}, (response) => {this.handleSubmitResponse(response);});*/
        this.record.Status__c = 'Pending Review';
        this.record.Current_Stage__c = 'Record Submitted';
        this.actionClicked = 'Submit';
        this.saveRecord(this.record);
    }
	
    

    quickSave() {
        if(this.getData(false) == false) return;
        this.actionClicked = 'Quick Save';
        this.record.Current_Stage__c = this.currentStage;
        this.saveRecord(this.record);
    }

    saveRecord(record) {
        if(!record.Status__c) record.Status__c = 'Draft';
        let recordToSend = JSON.parse(JSON.stringify(record));
        if(recordToSend.Contact_Roles__r && !recordToSend.Contact_Roles__r.records) {
            recordToSend.Contact_Roles__r= {
                totalSize: recordToSend.Contact_Roles__r.length,
                done: true,
                records: recordToSend.Contact_Roles__r
            };
        }
        this.executeAction(submitRequest, {'recordData' : JSON.stringify(recordToSend)}, (response) => { this.processSaveCallback(response); });
    }

    processSaveCallback(response) {
        this.recordId = response.Id;
        if(this.actionClicked == 'Quick Save') {
            this.redirectToCommunityCustomPage('hma-noi-request', {'id' : this.recordId, 'currentStage' : this.currentStage});
        } else if(this.actionClicked == 'Next') {
            this.redirectToCommunityCustomPage('hma-noi-request', {'id' : this.recordId, 'currentStage' : this.getNextStage()});
            console.log('======(this.getNextStage()',this.getNextStage());
            //this.template.querySelector('c-hma-n-o-i-path').handleStage(this.getNextStage(), 'next');
        } else if(this.actionClicked == 'Previous') {
            this.redirectToCommunityCustomPage('hma-noi-request', {'id' : this.recordId, 'currentStage' : this.getPreviousStage()});
            console.log('======(this.getPreviousStage()',this.getPreviousStage());
            /*this.template.querySelector('c-hma-n-o-i-path').handleStage(this.getPreviousStage(),'prev',this.stagesList);*/
        } else if(this.actionClicked == 'Submit') {
            this.handleSubmitResponse(response);
       }
    }

    handleSubmitResponse(response) {
        this.navigateRecordViewPage(response.Id);
        this.showNotification('Success', 'Request submitted successfully', 'success', 'sticky');
        //this.redirectToCommunityHome();
    }

    getNextStage() {
        if(this.currentStage == 'GeneralInfo') return 'ProjectInfo';
        else if(this.currentStage == 'ProjectInfo') {
           if(this.stagesList.includes('ActivityInfo')){
               return 'ActivityInfo';
           }
           else {
               return 'AdditionalInfo';
           }
        }
        else if(this.currentStage == 'ActivityInfo') return 'AdditionalInfo';
        else if(this.currentStage == 'AdditionalInfo') return 'Preview';
    }

    getPreviousStage() {
        if(this.currentStage == 'Preview') return 'AdditionalInfo';
        else if(this.currentStage == 'AdditionalInfo') {
            if(this.stagesList.includes('ActivityInfo')){
                return 'ActivityInfo';
            }
            else {
                return 'ProjectInfo';
            }
        }
        else if(this.currentStage == 'ActivityInfo') return 'ProjectInfo';
        else if(this.currentStage == 'ProjectInfo') return 'GeneralInfo';
    }

    cancelRequest(){
        let preAppId = this.getURLParameter("id");
        if(preAppId){
            this.navigateRecordViewPage(preAppId);
            //this.showNotification('Success', 'Request submitted successfully', 'success', 'sticky');
        }else{
            this.redirectToCommunityHome();
            var urlString = window.location.href;
            var baseURL = urlString.substring(0, urlString.indexOf("/s"));
            window.location.href = baseURL;
        }
    }
    /*recordTypeChecked(event){
        this.selectedRecordTypeId = event.target.value;
        for(let i=0;i<this.recordTypeOptions.length;i++){
            if(this.selectedRecordTypeId == this.recordTypeOptions[i].value){
                this.selectedRecordTypeName = this.recordTypeOptions[i].label;
            }
        }
        console.log('label-------',this.selectedRecordTypeName);
    }*/
    closeModal(event) {
        let valid = true;
        if(this.selectedRecordTypeId == undefined) {
            this.showNotification('Error', 'Please select a Record Type', 'Error', 'dismissible');
            valid = false;
        }
        console.log('valid',valid);
        if(valid){
            this.showModal = false;
        }
    }
    redirectToListView(event) {
        this.navigateToObjectListView('Pre_Application__c');
    }
    recordTypeChange(event){
        this.selectedRecordTypeId = event.target.value;
        this.selectedRecordTypeName = event.target.label;
    }
}