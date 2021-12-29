/**
 * Created by Ricky on 01-09-2021.
 */

 import { LightningElement, wire, track, api } from 'lwc';
 import Utility from 'c/utility';
 import Id from '@salesforce/user/Id';
 //import {loadStyle} from 'lightning/platformResourceLoader';
 
 /** Importing Object info and Picklist fields information from object. */ 
 import { getObjectInfo } from 'lightning/uiObjectInfoApi';
 import { getPicklistValues } from 'lightning/uiObjectInfoApi';
 import UR_OBJECT from '@salesforce/schema/HH_Application__c';
 import Stage from '@salesforce/schema/HH_Application__c.Stage__c';
 import Status from '@salesforce/schema/HH_Application__c.Status__c';
 import Reasons_for_Rejected_Closed from '@salesforce/schema/HH_Application__c.Reasons_for_Rejected_Closed__c';
 
 import { getRecord, getRecordNotifyChange } from 'lightning/uiRecordApi';
 import UId from '@salesforce/user/Id';
 
 import getRecordDetails from '@salesforce/apex/HH_ApplicationStageAndStatusUpdate_Ctrl.getRecordDetails';
 import getAllowedStagesValues from '@salesforce/apex/HH_ApplicationStageAndStatusUpdate_Ctrl.getAllowedStagesValues';
 import updateStageAndStatus from '@salesforce/apex/HH_ApplicationStageAndStatusUpdate_Ctrl.updateStageAndStatus';
 
 import HH_StageAndStatusUpdate_Stage from '@salesforce/label/c.HH_StageAndStatusUpdate_Stage';
 import HH_StageAndStatusUpdate_StageReason from '@salesforce/label/c.HH_StageAndStatusUpdate_StageReason';
 import HH_StageAndStatusUpdate_ComponentTitle from '@salesforce/label/c.HH_StageAndStatusUpdate_ComponentTitle';
 import HH_StageAndStatusUpdate_Component_SaveButton from '@salesforce/label/c.HH_StageAndStatusUpdate_Component_SaveButton';
 import HH_DetailsUpdatedSuccessfullMessage from '@salesforce/label/c.HH_DetailsUpdatedSuccessfullMessage';
 import HH_Application_RejectionReason from '@salesforce/label/c.HH_Application_RejectionReason';
 import HH_EN_characters_remaining from '@salesforce/label/c.HH_EN_characters_remaining';
 import HH_Application_ReasonForRejectedClosed from '@salesforce/label/c.HH_Application_ReasonForRejectedClosed';
 import HH_Application_ReasonToWithdraw from '@salesforce/label/c.HH_Application_ReasonToWithdraw';
 
 import HH_Application_Stage_Draft from '@salesforce/label/c.HH_Application_Stage_Draft';
 import HH_Application_Stage_ApprovedConverted from '@salesforce/label/c.HH_Application_Stage_ApprovedConverted';
 import HH_Application_Stage_RejectedClosed from '@salesforce/label/c.HH_Application_Stage_RejectedClosed';
 import HH_Application_Stage_CommunityDecision from '@salesforce/label/c.HH_Application_Stage_CommunityDecision';
 import HH_Application_Stage_AssessmentDecision from '@salesforce/label/c.HH_Application_Stage_AssessmentDecision';
 import HH_Application_Stage_CalOESDecision from '@salesforce/label/c.HH_Application_Stage_CalOESDecision';
 import HH_Application_Stage_FEMADecision from '@salesforce/label/c.HH_Application_Stage_FEMADecision';
 import HH_Application_Status_New from '@salesforce/label/c.HH_Application_Status_New';
 import HH_Application_Status_AppealApprovedResubmit from '@salesforce/label/c.HH_Application_Status_AppealApprovedResubmit';
 import HH_Application_Status_Withdrawn from '@salesforce/label/c.HH_Application_Status_Withdrawn';
 import HH_Application_Status_RejectedDoesNotMeetCriteria from '@salesforce/label/c.HH_Application_Status_RejectedDoesNotMeetCriteria';
 import HH_Application_Status_RejectedNotEligible from '@salesforce/label/c.HH_Application_Status_RejectedNotEligible';
 import HH_EN_Application_Already_Submitted from '@salesforce/label/c.HH_EN_Application_Already_Submitted';
 import HH_Information_PDF from '@salesforce/label/c.HH_Information_PDF';
 import HH_EN_HERE from '@salesforce/label/c.HH_EN_HERE';
 
 export default class HhApplicationStageAndStatusUpdate extends Utility {
     @track stageList; /** Variable to store all the stage values. */
     @track StatusValueList; /* Variable to store all the Status values. */
     @api recordId; /** Variable to store the current record Id. */
     @track statusOptions; /** Variable to store the Status values allowed bases on selected Stage in Component. */
     @track allowedStagesList; /** Variable to store the allowed Stage in component based on Current  record Saved Stage value. */
     @track recordLocal = {}; /** Variable to store the record local upon Page reload. */
     @track showAdditionalInformation = false;
     showLoader = false; /** Variable to show  loader upon until the record gets Saved upon clicking the Save Changes button. */
     userId = UId; /** Variable to store the current Logged In User. */
     currentSavedStage; /* Variable to store the current record Stage which is Saved. */
     currentSavedStatus;
     rejectionReason; /** Variable to store the Rejection reason of selected Stage. */
     count = 1000;
 
     /** Variable to store all the imported Custom Labels. */
     @track label = {
         HH_StageAndStatusUpdate_Stage,
         HH_StageAndStatusUpdate_StageReason,
         HH_StageAndStatusUpdate_ComponentTitle,
         HH_StageAndStatusUpdate_Component_SaveButton,
         HH_DetailsUpdatedSuccessfullMessage,
         HH_Application_RejectionReason,
         HH_EN_characters_remaining,
         HH_Application_ReasonForRejectedClosed,
         HH_Application_ReasonToWithdraw,
         HH_Application_Stage_Draft,
         HH_Application_Stage_ApprovedConverted,
         HH_Application_Stage_RejectedClosed,
         HH_Application_Stage_CommunityDecision,
         HH_Application_Stage_AssessmentDecision,
         HH_Application_Stage_CalOESDecision,
         HH_Application_Stage_FEMADecision,
         HH_Application_Status_New,
         HH_Application_Status_AppealApprovedResubmit,
         HH_Application_Status_Withdrawn,
         HH_Application_Status_RejectedDoesNotMeetCriteria,
         HH_Application_Status_RejectedNotEligible,
         HH_EN_Application_Already_Submitted,
         HH_Information_PDF,
         HH_EN_HERE
     }
 
     /** Wire method to get the Object info and Stage and Status Picklist value from Record. */
     @wire(getObjectInfo, { objectApiName: UR_OBJECT }) objectInfo;
     @wire(getPicklistValues, {recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: Stage}) StageValueList;
     @wire(getPicklistValues, {recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: Reasons_for_Rejected_Closed}) rejectionReasonList;
     @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: Status})
     categoryInfo({ data, error }) {
         if (data) {
             console.log('data----',data);
             this.StatusValueList = data;
             this.retrieveData(this.recordId);
         }
         if (error) {
             console.log('error------->>>', error);
         }
     }
 
     /** Getter to decide whether to show teh Stage and Status component. */
     get showComponent() {
         if (this.recordLocal != undefined && this.currentSavedStage == this.label.HH_Application_Stage_Draft && this.currentSavedStatus != this.label.HH_Application_Status_New && this.isVisible == true) {
             return true;
         }
         else if(this.recordLocal != undefined && this.currentSavedStage != this.label.HH_Application_Stage_ApprovedConverted && this.currentSavedStage != this.label.HH_Application_Stage_RejectedClosed && this.currentSavedStage != this.label.HH_Application_Stage_Draft && this.isVisible == true) {
             return true;
         }
         return false;
     }
 
     /** Getter to decide whether to show Reason to Withdrawal Field. */
     get showWithdrawalReasonField() {
         if(this.recordLocal != undefined && this.recordLocal.Status__c == this.label.HH_Application_Status_Withdrawn && this.isVisible == true) {
             //this.characterCount();
             return true;
         }
         else {
         return false;
     }
     }
 
     /** Method to decide whether to show Rejection Reason field or not? */
     get showRejectionReasonTextField() {
         if(this.recordLocal.Status__c == this.label.HH_Application_Status_RejectedDoesNotMeetCriteria || this.recordLocal.Status__c == this.label.HH_Application_Status_RejectedNotEligible) {
             return true;
         }
         else {
             return false;
         }
     }
 
     /** Getter to decide whether to show Reasons for Rejected-Closed Field. */
     get showRejectionReasonPicklistField() {
         if(this.recordLocal.Stage__c == this.label.HH_Application_Stage_RejectedClosed) {
             return true;
         }
         else {
             return false;
         }
     }
 
     /** Method to check which Rejection Reason needs to be displayed on Component. */
     displayRejectionReasonValue() {
         if(this.recordLocal.Stage__c == this.label.HH_Application_Stage_CommunityDecision) {
             this.rejectionReason = this.recordLocal.Community_Rejection_Reason__c;
         }
         else if(this.recordLocal.Stage__c == this.label.HH_Application_Stage_AssessmentDecision) {
             this.rejectionReason = this.recordLocal.Assessment_Rejection_Reason__c;
         }
         else if(this.recordLocal.Stage__c == this.label.HH_Application_Stage_CalOESDecision) {
              this.rejectionReason = this.recordLocal.Cal_OES_Rejection_Reason__c;
         }
         else if(this.recordLocal.Stage__c == this.label.HH_Application_Stage_FEMADecision) {
              this.rejectionReason = this.recordLocal.FEMA_Rejection_Reason__c;
         }
         //this.characterCount();
     }
 
     /** Method to check which Rejection Reason needs to be stored in which field. */
     rejectionReasonValueChanged(event) {
         this.rejectionReason = event.target.value;
         //this.characterCount();
         if(this.recordLocal.Stage__c == this.label.HH_Application_Stage_CommunityDecision) {
             this.recordLocal.Community_Rejection_Reason__c = event.target.value;
         }
         else if(this.recordLocal.Stage__c == this.label.HH_Application_Stage_AssessmentDecision) {
             this.recordLocal.Assessment_Rejection_Reason__c = event.target.value;
         }
         else if(this.recordLocal.Stage__c == this.label.HH_Application_Stage_CalOESDecision) {
              this.recordLocal.Cal_OES_Rejection_Reason__c = event.target.value;
         }
         else if(this.recordLocal.Stage__c == this.label.HH_Application_Stage_FEMADecision) {
              this.recordLocal.FEMA_Rejection_Reason__c = event.target.value;
         }
     }
 
     /** This method is getting called upon Reason to Withdraw field change.
     This method is created seperately because we need to have remaining character count out of 1000. */
     reasonToWithdrawFieldChanged(event) {
         this.recordLocal.Reason_To_Withdraw__c = event.target.value;
         //this.characterCount();
     }
 
     /** Method to decide whether to show Stage-Reason field or not? */
     get statusFieldVisibility() {
         if(this.statusOptions.length > 0) {
             return true;
         }
         return false;
     }
 
     initData() {
        //this.retrieveData(this.recordId);
     }
 
     /** Method to fetch the current record data in order to display the currently save values in Component. */
     retrieveData(recordId) {
         this.showLoader = true;
         this.recordId = this.recordId == undefined ? null : this.recordId;
         console.log('this.recordId -----> 75 --> ', this.recordId);
         this.showAdditionalInformation = false;
         this.executeAction(getRecordDetails , {'masterRecordId':this.recordId, 'userId':this.userId},
             (response) => {
                 console.log('response ---> hh Application details --> ', response);
                 this.recordLocal = response.hhApplication[0];
                 this.allowedStagesList = response.allowedStagesList;
                 this.isVisible = response.isVisible;
 
                 this.currentSavedStage = this.recordLocal.Stage__c;
                 this.currentSavedStatus = this.recordLocal.Status__c;
                 this.stageDependentValues();
 
                 this.displayRejectionReasonValue();
 
                 //this.characterCount();
 
                 this.showLoader = false;
                 this.showAdditionalInformation = true;
             },(error)=>{
                 if(error.body != undefined && error.body.message != undefined && error.body.message.includes('Application not editable')) {
                     this.showNotificationwithMessageData('',this.label.HH_EN_Application_Already_Submitted, 'info', 'dismissible', this.label.HH_Information_PDF, this.label.HH_EN_HERE);
                 }
                 else if(error.body != undefined && error.body.message != undefined) {
                     this.showErrorNotification('Error Fetching Data',error.body.message);
                 } else {
                     this.showErrorNotification('Error Fetching Data',error);
                 }
                 this.showLoader = false;
                 this.showAdditionalInformation = true;
                 if(this.template.querySelector('[data-custom="innerComponent"]') != null) {
                     this.template.querySelector('[data-custom="innerComponent"]').getUpdatedRecord();
                 }
         });
     }
 
     /** Method to get the dependent Stage-Reason upon Stage change. */
     stageChanged(event) {
         this.recordLocal.Stage__c = event.target.value;
         this.recordLocal.Status__c = null;
         this.stageDependentValues();
         this.displayRejectionReasonValue();
     }
 
     stageDependentValues() {
         let key = this.StatusValueList.controllerValues[this.recordLocal.Stage__c];
         this.statusOptions = this.StatusValueList.values.filter(opt => opt.validFor.includes(key));
        if(this.currentSavedStage == this.label.HH_Application_Stage_Draft && this.currentSavedStatus == this.label.HH_Application_Status_AppealApprovedResubmit && this.recordLocal.Stage__c == this.label.HH_Application_Stage_Draft) {
            let options = [];
            let draftOption = this.statusOptions[1];
            options.push(draftOption);
            let draftOption2 = this.statusOptions[2];
            options.push(draftOption2);
            this.statusOptions = options;
        }
        else if(this.currentSavedStage == this.label.HH_Application_Stage_Draft && this.currentSavedStatus == this.label.HH_Application_Status_Withdrawn && this.recordLocal.Stage__c == this.label.HH_Application_Stage_Draft) {
            let options = [];
            let draftOption = this.statusOptions[2];
            options.push(draftOption);
            this.statusOptions = options;
        }
        else if(this.recordLocal.Stage__c == this.label.HH_Application_Stage_Draft) {
             let options = [];
             let draftOption = this.statusOptions[1];
             options.push(draftOption);
             this.statusOptions = options;
         }
     }
 
     /** Method to decide whether to Show Rejection Reason o not upon Status changed to Rejected.  */
     statusChanged(event) {
         this.recordLocal.Status__c = event.target.value;
         this.displayRejectionReasonValue();
         //this.characterCount();
     }
 
     /* Method to set the selected Stage value as Title in order to show Selected value upon Mouseover. */
     getStageTitle(event){
         console.log('....test....'+event.target.value);
         if(this.StageValueList.data.values) {
             this.StageValueList.data.values.forEach(selectionList => {
                 if(selectionList.value == event.target.value) {
                     this.title = selectionList.label;
                 }
             });
         }
     }
 
     /* Method to set the selected Stage-Reason value as Title in order to show Selected value upon Mouseover. */
     getStageReasonTitle(event){
         console.log('....test....'+event.target.value);
         if(this.StatusValueList.values) {
             this.StatusValueList.values.forEach(selectionList => {
                 if(selectionList.value == event.target.value) {
                     this.title = selectionList.label;
                 }
             });
         }
     }
 
     /* Method to call Apex Class for updating the details on Record upon Save Changes button. */
     getReasonForRejectionTitle(event){
         console.log('....test....'+event.target.value);
         if(this.rejectionReasonList.data.values) {
             this.rejectionReasonList.data.values.forEach(selectionList => {
                 if(selectionList.value == event.target.value) {
                     this.title = selectionList.label;
                 }
             });
         }
     }
 
     /* Method to call Apex Class for updating the details on Record upon Save Changes button. */
     handleSubmit() {
         let allValid = this.validateInputs();
         console.log('allValid----',allValid);
         console.log('recordLocal----',this.recordLocal);
         this.showAdditionalInformation = false;
         if(allValid) {
             this.showLoader = true;
             this.executeAction(updateStageAndStatus , {'record': JSON.stringify(this.recordLocal), 'userId':this.userId},
             (response) => {
                 this.recordLocal = response.hhApplication[0];
                 this.allowedStagesList = response.allowedStagesList;
                 this.isVisible = response.isVisible;
 
                 /** To get the dependent Stage-Reason for selected Stage value in component. */
                 let key = this.StatusValueList.controllerValues[this.recordLocal.Stage__c];
                 this.statusOptions = this.StatusValueList.values.filter(opt => opt.validFor.includes(key));
                 this.displayRejectionReasonValue();
 
                 //this.characterCount();
 
                 this.currentSavedStage = this.recordLocal.Stage__c;
                 this.currentSavedStatus = this.recordLocal.Status__c;
                 this.stageDependentValues();
                 getRecordNotifyChange([{recordId: this.recordId}]);
                 this.showLoader = false;
                 this.showNotification('Success', this.label.HH_DetailsUpdatedSuccessfullMessage, 'success','dismissible');
                 this.showAdditionalInformation = true;
                 if(this.template.querySelector('[data-custom="innerComponent"]') != null) {
                     this.template.querySelector('[data-custom="innerComponent"]').getUpdatedRecord();
                 }
             },(error)=>{
                 console.log('error---- ',error.body.message);
                 if(error.body != undefined && error.body.message != undefined && error.body.message.includes('Application not editable')) {
                     this.showNotificationwithMessageData('',this.label.HH_EN_Application_Already_Submitted, 'info', 'dismissible', this.label.HH_Information_PDF, this.label.HH_EN_HERE);
                     this.retrieveData(this.recordId);
                 }
                 else if(error.body != undefined && error.body.message != undefined) {
                     //this.showErrorNotification('',error.body.message, 'Error','sticky');
                     this.showNotification('', error.body.message, 'error', 'dismissible');
                     this.retrieveData(this.recordId);
                 } else {
                     //this.showErrorNotification('',error, 'Error','sticky');
                     this.showNotification('', error, 'error', 'dismissible');
                     this.retrieveData(this.recordId);
                 }
                 this.showLoader = false;
                 this.showAdditionalInformation = true;
             }); 
         }
     }
 
     /* Method to pass the updated record to child component. */
     passUpdatedRecord(event) {
         console.log('Parent --> this.recordLocal.Stage__c---> ', this.recordLocal); 
         this.template.querySelector('[data-custom="innerComponent"]').getUpdatedRecord();
     }
 
     characterCount() {
         if(this.rejectionReason){
             console.log('this.rejectionReason.length ==> ',this.rejectionReason.length);
             this.count = 1000 - this.rejectionReason.length ;
         }
         else if(this.recordLocal.Reason_To_Withdraw__c){
             console.log('this.recordLocal.Reason_To_Withdraw__c.length  ==> ',this.recordLocal.Reason_To_Withdraw__c.length );
             this.count = 1000 - this.recordLocal.Reason_To_Withdraw__c.length ;
         }
     }
 
     @api
     reloadData() {
         this.retrieveData(this.recordId);
     }
 }