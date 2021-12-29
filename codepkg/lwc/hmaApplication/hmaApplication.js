import { LightningElement, api, track, wire } from 'lwc';
import Utility from 'c/utility';
import processRecord from '@salesforce/apex/HMA_ApplicationCtrl.processRecord';
import processReadOnlyRecord from '@salesforce/apex/HMA_ApplicationCtrl.processReadOnlyRecord';
import getLoggedInUserContactRoleForApplication from '@salesforce/apex/HMA_ApplicationCtrl.getLoggedInUserContactRoleForApplication';
import { CurrentPageReference } from 'lightning/navigation';

export default class HmaApplication extends Utility {
    pageLayoutName = 'HMGPSubApplication';
    pageLayoutId = '';
    programTemplatePageId = '';

    nextPageLayoutSequence = 0;
    @track applicationRecord = {};
    @track accountRecord = {};
    @track showApplicationWorkSchedule = false;
    @track previousButtonLayout = '';
    @track stagesList = ["HMGPSubApplication", "HMGP_Sub_Application_Scope_of_Work_Step1", "HMGP_Sub_Application_Scope_of_Work_Step2", "WorkSchedule"];

    @track nextPageLayout;
    @track previousPageLayout;
    @track objectApiName;
    @track tableRecordDetails = [];
    @track workScheduleLineItems = [];
    @track projectCostLineItems = [];
    @track tableRecordMap = [];
    @track nextProgramTemplatePage;
    @track isAnyFieldsChange = false;
    @track isActionInProgress = false;
    @track isSubmitAllowed = false;
    @track isSaveAllowed = false;
    @track isAllFieldsReadOnly = false;
    @track hideFieldCustomAttributeRole = {
                           	"role": "FEMA Programmatic Analyst,FEMA EHP Analyst"
                           };

    initData() { 
    console.log('nextPageLayoutSequence init: '+this.nextPageLayoutSequence);
        window.scrollTo(0,0);
    }
    
    @wire(CurrentPageReference)
    setCurrentPageRef(currentPageReference) {
        if(currentPageReference && currentPageReference.state) {
          if(currentPageReference.state.id) {
            this.recordId = currentPageReference.state.id;
          }
          if(currentPageReference.state.sequence) {
            this.nextPageLayoutSequence = currentPageReference.state.sequence;
            console.log('nextPageLayoutSequence wire: '+this.nextPageLayoutSequence);
          }
          if(currentPageReference.state.pageLayoutId) {
            this.pageLayoutId = currentPageReference.state.pageLayoutId;
            console.log('pageLayoutId wire: '+this.pageLayoutId);
          }
          if(currentPageReference.state.programTemplatePageId) {
            this.programTemplatePageId = currentPageReference.state.programTemplatePageId;
            console.log('programTemplatePageId wire: '+this.programTemplatePageId);
          }
       }
   }
    /**
        Checking the role of the logged in user;
    */
    

   @wire(getLoggedInUserContactRoleForApplication,{applicationId:'$recordId'})
   wireGetContactRole({error, data}){
       this.showLoader = false;
       console.log('wireGetContactRole data: ',data);
       if(data){
           if(data['isSuccess']){
               let contactRole = data['contactRole'];
               let rolesArray = contactRole['Role__c'].split(";");
                this.prepareForHideFieldCustomAttributeRole(rolesArray);
                if(rolesArray.includes("Responsible Representative") && (contactRole.Application__r.Status__c =='Draft')){
                    this.isSubmitAllowed = true;
                }else if(rolesArray.includes("Contributor")){
                    this.isAllFieldsReadOnly = false;
                }else if(rolesArray.includes("Viewer")){
                    this.isAllFieldsReadOnly = true;
                }
                if(contactRole.Application__r.Status__c !='Draft'){
                    this.isAllFieldsReadOnly = true;
                }
                console.log('in wire function save button outside if---',rolesArray);
                console.log('condition if save button---',(rolesArray.includes("Responsible Representative") || rolesArray.includes("Primary Contact") || rolesArray.includes("Contributor")) && (contactRole.Application__r.Status__c == 'Draft'));
                if((rolesArray.includes("Responsible Representative") || rolesArray.includes("Primary Contact") || rolesArray.includes("Contributor")) && (contactRole.Application__r.Status__c == 'Draft')) {
                    console.log('in wire function save button true---',rolesArray);
                    this.isSaveAllowed = true;
               }
               //is_OPen_RFI (true) - isAllFieldsReadOnly(true) AND isSaveAllowed(true)
               console.log('contactRole.Application__r.Is_Any_Open_RFI__c : ',contactRole.Application__r.Is_Any_Open_RFI__c);
               if(contactRole.Application__r.Is_Any_Open_RFI__c && (rolesArray.includes("Responsible Representative") || rolesArray.includes("Primary Contact") || rolesArray.includes("Contributor"))) {
                    this.isAllFieldsReadOnly = false;
                    this.isSaveAllowed = true;
               }
                if(contactRole.Application__r.Status__c == 'FEMA Review' && 
                    contactRole.Application__r.Status_Reason__c == 'Submitted to FEMA' && 
                    (rolesArray.includes("FEMA EHP Analyst") || rolesArray.includes("FEMA Programmatic Analyst"))) {
                        this.isAllFieldsReadOnly = false;
                        this.isSaveAllowed = true;
                } else if(contactRole.Application__r.Status__c == 'FEMA Review' && 
                        contactRole.Application__r.Status_Reason__c == 'Submitted to FEMA' && 
                        rolesArray.includes("FEMA Viewer")) {
                            this.isAllFieldsReadOnly = true;
                            this.isSaveAllowed = false;
                }
                if(rolesArray.includes("FEMA EHP Analyst") || rolesArray.includes("FEMA Programmatic Analyst") || rolesArray.includes("FEMA Viewer")) {
                    this.isAllFieldsReadOnly = true;
                    this.isSaveAllowed = false;
                }
           }
       }else if(error){
           console.log('wireGetContactRole error: ',error);
       }
   }


    buttonAction(event){
        try {
        console.log('HmaApplication_Button action:--------- ',JSON.stringify(event.detail));
        let jsonObject = JSON.parse(JSON.stringify(event.detail));
        let record = this.template.querySelector("c-page-layout").returnCurrentRecord();
            let tableRecordDetails = this.template.querySelector("c-page-layout").collectTableData();
            this.projectCostLineItems = [];
            this.workScheduleLineItems = [];
            if(tableRecordDetails) {
                this.tableRecordDetails = JSON.parse(JSON.stringify(tableRecordDetails));
                this.prepareTableData();
            }
            this.objectApiName = this.template.querySelector("c-page-layout").getObjectApiName();
        this.recordLocal = JSON.parse(JSON.stringify(record));
        this.accountRecord = this.recordLocal.Subapplicant_Entity__r;
        this.applicationRecord = this.recordLocal;
        if(Object.keys(record).length > 0 && record.constructor === Object) {
            this.processEvent(jsonObject.buttonAction, jsonObject);            
        }
        } catch(e) {
            console.log(e);
        }
    }
    prepareForHideFieldCustomAttributeRole(rolesArray) {
        console.log('rolesArray-------', rolesArray);
        let roleString = '';
        for(let i=0; i< rolesArray.length; i++) {
            if(roleString == '') {
                roleString = rolesArray[i];
            } else {
                roleString = roleString + ',' + rolesArray[i];
            }            
        }
        console.log('roleString-------', roleString);
        this.hideFieldCustomAttributeRole.role = roleString;
        console.log('this.hideFieldCustomAttributeRole-------', this.hideFieldCustomAttributeRole);
    }
    prepareTableData() {
        let myMap = new Map()
        console.log('tableRecordDetails.length : ', this.tableRecordDetails.length);
        this.projectCostLineItems = [];
        this.workScheduleLineItems = [];
        for(let i=0; i< this.tableRecordDetails.length; i++) {
            let pageLayoutRecord = JSON.parse(JSON.stringify(this.tableRecordDetails[i]));
            for(let j=0; j< pageLayoutRecord.length; j++) {
                let lineItemRecords = JSON.parse(JSON.stringify(pageLayoutRecord[j].tableRecordDetails));
                if(pageLayoutRecord[j].tableObjectName == 'Work_Schedule_Line_Item__c') {
                    for(let k=0; k<lineItemRecords.length; k++) {
                        this.workScheduleLineItems.push(lineItemRecords[k]);
                    }
                }
                if(pageLayoutRecord[j].tableObjectName == 'Project_Cost_Line_Item__c') {
                    //Save logic for Project_Cost_Line_Item__c table
                    console.log('line item records---', lineItemRecords.length);
                    for(let pcLineItemIdx=0; pcLineItemIdx<lineItemRecords.length; pcLineItemIdx++) {
                        this.projectCostLineItems.push(lineItemRecords[pcLineItemIdx]);
                    }
                }
            }
        }
        //console.log('this.tableRecordMap------',this.tableRecordMap);
        console.log('this.workScheduleLineItems------',this.workScheduleLineItems);
        return myMap;
    }

    workScheduleButtonAction(event){
        let jsonObject = JSON.parse(JSON.stringify(event.detail));
        if(jsonObject.buttonAction == 'wlSaveAndContinue'){
            this.handleURLRedirect();
        }
    }

    processEvent(buttAction, jsonObject) {
        console.log('in processEvent ');
        if(this.isAllFieldsReadOnly){
            this.processReadOnlyRecordMethod(jsonObject, true);
        }else{
        if(buttAction == 'quickSave') {
            this.updateRecord(jsonObject, false);
            } else if(buttAction == 'Save & Continue') {
            this.updateRecord(jsonObject, true);
        } else if(buttAction == 'previous') {
            this.updateRecord(jsonObject, true);
        } else if(buttAction == 'submit') {
            this.updateRecord(jsonObject, true);
        }
    }
    }
    updateRecord(jsonObject, toRedirect) {
        this.isActionInProgress = true;
        this.executeAction(processRecord, { 'objectApiName':this.objectApiName, 'appRecord' : JSON.stringify(this.recordLocal), 'accRecord' : JSON.stringify(this.accountRecord), 'workScheduleLineItems' : JSON.stringify(this.workScheduleLineItems),
                           recordId: this.recordId, programTemplatePageId: jsonObject['programTemplatePageIdLocal'],
                            'projectCostLineItems' : JSON.stringify(this.projectCostLineItems), 'buttonAction': jsonObject.buttonAction}, (response) => {
            console.log('updateRecord_response: ',response);
            if(response.isSuccess) {
                this.isActionInProgress = false;
                this.isAnyFieldsChange = false;
                this.template.querySelector("c-page-layout").fieldChangesSaved();//to avoid pop up after save
                if(toRedirect && response['nextProgramTemplatePage'] != null) {
                    this.nextProgramTemplatePage = response['nextProgramTemplatePage'];
                this.handleRedirect(jsonObject);
                } else{
                    this.showSuccessNotification('Success','Record saved successfully');
            }
                if(jsonObject.buttonAction == 'submit') {
                    this.navigateRecordViewPage(this.recordId);
                }
                try {
                    this.refreshTable();
                } catch(e) {
                    console.log(e);
                }
            }
        }, (error) => {
            console.log('Error : ', error);
			this.isActionInProgress = false;
            this.showErrorNotification('', error.body.message);
        });
    }
    processReadOnlyRecordMethod(jsonObject, toRedirect) {
        this.isActionInProgress = true;
        this.executeAction(processReadOnlyRecord, { recordId: this.recordId, programTemplatePageId: jsonObject['programTemplatePageIdLocal'], 'buttonAction': jsonObject.buttonAction}, (response) => {
            console.log('updateRecord_response: ',response);
            if(response.isSuccess) {
                this.isActionInProgress = false;
                this.isAnyFieldsChange = false;
                if(toRedirect && response['nextProgramTemplatePage'] != null) {
                    this.nextProgramTemplatePage = response['nextProgramTemplatePage'];
                    this.handleRedirect(jsonObject);
                }
            }
        }, (error) => {
            console.log('Error : ', error);
            this.isActionInProgress = false;
            this.showErrorNotification('', error.body.message);
        });
    }


    refreshTable() {
        this.template.querySelectorAll("c-page-layout").forEach((element) => {
            element.refreshPageSection();
        });
    }

    handleRedirect(jsonObject){
            this.handleURLRedirect();
        }

    handleURLRedirect(){
        console.log('this.nextProgramTemplatePage-----',this.nextProgramTemplatePage);
        this.redirectToCommunityCustomPage('application-edit',{id:this.recordId, programTemplatePageId: this.nextProgramTemplatePage['Id']});
    }

    get getCurrentStage() {
        return this.pageLayoutName != '' ? this.pageLayoutName : 'WorkSchedule';
    }
}