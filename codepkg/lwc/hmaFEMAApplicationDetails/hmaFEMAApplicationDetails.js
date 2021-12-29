/**
 * Created by harsh on 05-08-2021.
 */

import { LightningElement, track, api, wire } from 'lwc';
import Utility from 'c/utility';
import getCurrentUserContactRole from '@salesforce/apex/HMA_FEMAApplicationDetailsCtrl.getCurrentUserContactRole';
import saveApplication from '@salesforce/apex/HMA_FEMAApplicationDetailsCtrl.saveApplication';
import CloneApplication from '@salesforce/apex/HMA_CloneApplicationCtrl.CloneApplication';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import APPLICATION_OBJ from '@salesforce/schema/Application__c';
import STATUS_FIELD from '@salesforce/schema/Application__c.Status__c';
import STATUS_REASON_FIELD from '@salesforce/schema/Application__c.Status_Reason__c';


export default class HmaFemaApplicationDetails extends Utility  {
    @api recordId;

    @track isSaveConfirmationShow = false;
    @track applicationRecord = {};
    @track isFEMAUser = false;
    @track isReadOnly= false;
    @track statusOptionsOriginal = [];
    @track statusOptions;
    @track statusReasonOptions = [];
    @track isSaveAllowed = false;
    @track femaUserStatusOptions = [{
                                   "label": "FEMA Review",
                                   "value": "FEMA Review"
                                   },
                                   {
                                   "label": "FEMA Decision",
                                   "value": "FEMA Decision"
                                   }
                                   ];
    @track isCloneInProgress = false;
    @track isCloneApplicationAllowed = false;

    @wire(getObjectInfo, { objectApiName: APPLICATION_OBJ }) objectInfo;

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: STATUS_FIELD}) statusOptions;

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: STATUS_REASON_FIELD})
    picklistStatusReasonOptions({error, data}){
        if(data){
            this.statusOptionsOriginal = data;
            this.handleStatusChange();
            console.log('statusReasonOptions response: ',data);
        }else if(error){
            console.log('statusReasonOptions error: ',error);
        }
    }

    @wire(getCurrentUserContactRole,{applicationId:'$recordId'})
    wireGetContactRole({error, data}){
        this.showLoader = false;
        console.log('wireGetContactRole data: ',data);
        if(data){
            if(data['isSuccess']){
                let contactRole = data['contactRole'];
                this.applicationRecord = JSON.parse(JSON.stringify(contactRole.Application__r));
                let rolesArray = contactRole['Role__c'].split(";");
                if(rolesArray.includes("FEMA EHP Analyst") || rolesArray.includes("FEMA Programmatic Analyst")){
                    this.isFEMAUser = true;
                }else{
                    this.isFEMAUser = false;
                    this.isReadOnly = true;
                }

                if(contactRole.Application__r.Status__c != 'FEMA Review' && contactRole.Application__r.Status__c != 'FEMA Decision') {
                    this.isReadOnly = true;
                }
                if(rolesArray.includes("Responsible Representative") || rolesArray.includes("Primary Contact")){
                    this.isCloneApplicationAllowed = true;
                }
                this.handleStatusChange();
            }
        }else if(error){
            console.log('wireGetContactRole error: ',error);
        }
   }
   fieldChangedEvent(event){
       console.log('---before---'+this.applicationRecord['Status__c']);
        this.applicationRecord[event.target.getAttribute('data-field')] = event.target.value;
        console.log('---after---'+this.applicationRecord['Status__c']);
        if(event.target.getAttribute('data-field') == 'Status__c'){
            this.handleStatusChange();
        }
   }
    get isCloneApplication() {
        if(this.isCloneApplicationAllowed == false) return false;
        if( this.applicationRecord['Is_this_project_phased__c'] == 'Yes' &&
            this.applicationRecord['Status_Reason__c'] == 'Approved' &&
            this.applicationRecord['Status__c'] == 'FEMA Decision' &&
                    this.applicationRecord['Project__c'] &&
                    (this.applicationRecord['Child_Application__c'] == undefined || this.applicationRecord['Child_Application__c'] == '')
                    ) {
                return true;
        }
        return false;
    }
    handleCloneApplication() {
        console.log('recordId  : ', this.recordId);
        this.showLoader = true;
        this.isCloneInProgress = true;
        this.executeAction(CloneApplication, {applicationId : this.recordId}, (response) => {
            console.log('response_CloneApplication : ',response);
            this.showLoader = false;
            this.isCloneInProgress = false;
            if(response['isSuccess'] == true) {
                this.showSuccessNotification('Subapplication has been cloned successfully.');
                setTimeout(function(){
                    location.reload();
                },2000);
            } else {
                this.showErrorNotification(response['error']);
            }
        });
    }
   handleStatusChange(){
       console.log('---handleStatusChange---'+this.applicationRecord['Status__c']);
       //if(this.applicationRecord['Status__c'] != 'Draft'){
            if(this.statusOptionsOriginal.controllerValues) {
                let key = this.statusOptionsOriginal.controllerValues[this.applicationRecord['Status__c']];
                console.log('---handleStatusChange key---'+key);
                this.statusReasonOptions = this.statusOptionsOriginal.values.filter(opt => opt.validFor.includes(key));
            }            
            
       //}
   }

   get isStatusReasonLoaded(){
       return this.statusReasonOptions.length > 0 ? true : false;
   }

    saveButtonClick(){
        this.isSaveConfirmationShow = true;
    }

    handleSaveConfirmationClick(event){
        console.log('delete event detail---', event.detail);
        let action = event.detail;
        if(event.detail.status == 'confirm') {
           this.processApplicationRecord();
        } else {
            this.isSaveConfirmationShow = false;
        }
    }

    processApplicationRecord(){
         this.executeAction(saveApplication, {applicationRecord : JSON.stringify(this.applicationRecord)}, (response) => {
            this.isSaveConfirmationShow = false;
            if(response['isSuccess']){
                 this.showSuccessNotification('Record saved successfully', '');
            }
         });
    }
}