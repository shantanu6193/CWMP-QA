import { LightningElement,api,wire,track } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import DOCUMENT__C_OBJECT from '@salesforce/schema/Document__c';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import DOCUMENT_TYPE_FIELD from '@salesforce/schema/Document__c.Document_Type__c';
import DOCUMENT_FORMAT_FIELD from '@salesforce/schema/Document__c.Document_Format__c';
import STATUS_FIELD from '@salesforce/schema/Document__c.Status__c';
import IS_REQUIRED_FIELD from '@salesforce/schema/Document__c.Is_Required__c';
import STAGE_FIELD from '@salesforce/schema/Document__c.Stage__c';
import Utility from 'c/utility';
import saveDocumentInfo from '@salesforce/apex/CustomDocumentCreateEdit.saveDocumentInfo';
import HH_EN_Proof_of_Rental from '@salesforce/label/c.HH_EN_Proof_of_Rental';
import HH_EN_Proof_of_Ownership from '@salesforce/label/c.HH_EN_Proof_of_Ownership';
import HH_EN_Property_Owner_ID from '@salesforce/label/c.HH_EN_Property_Owner_ID';
import HH_EN_Environmental_Checklist from '@salesforce/label/c.HH_EN_Environmental_Checklist';
import HH_EN_Home_Assessment_Report from '@salesforce/label/c.HH_EN_Home_Assessment_Report';
import HH_EN_Homeowner_Paper_Application from '@salesforce/label/c.HH_EN_Homeowner_Paper_Application';
import HH_EN_Homeowner_Appeal_Form from '@salesforce/label/c.HH_EN_Homeowner_Appeal_Form';
import HH_EN_Other from '@salesforce/label/c.HH_EN_Other';
import HH_EN_Executed_Tri_Party_Agreement from '@salesforce/label/c.HH_EN_Executed_Tri_Party_Agreement';

export default class  RecordEditFormProject extends Utility {

    @wire(getObjectInfo, { objectApiName:DOCUMENT__C_OBJECT  }) objectInfo;
    @wire(getPicklistValues, {recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName:DOCUMENT_TYPE_FIELD }) DocumentTypePicklistValues;
    @wire(getPicklistValues, {recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName:DOCUMENT_FORMAT_FIELD}) DocumentFormatPicklistValues;
    @wire(getPicklistValues, {recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName:STATUS_FIELD}) StatusPicklistValues;
    @wire(getPicklistValues, {recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName:IS_REQUIRED_FIELD}) IsRequiredPicklistValues;
    @wire(getPicklistValues, {recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName:STAGE_FIELD}) StagePicklistValues;
    @api documentrecordid;
    @track isEdit = false;
    @track recordLabel = 'Create Document';
    @api parentfieldname;
    @track isDisable = false;
    @api documentname;
    @api parentfieldvalue;
    @api docDetail;
    isCWMP = false;
    isHHApplication = false;
    isCWMPProject = false;
    @track label = {
            HH_EN_Proof_of_Rental,
            HH_EN_Proof_of_Ownership,
            HH_EN_Property_Owner_ID,
            HH_EN_Environmental_Checklist,
            HH_EN_Home_Assessment_Report,
            HH_EN_Homeowner_Paper_Application,
            HH_EN_Homeowner_Appeal_Form,
            HH_EN_Other,
            HH_EN_Executed_Tri_Party_Agreement
    }
    initData(){
        if(this.parentfieldname == 'HH_Application__c'){
            this.isHHApplication = true;
            this.isCWMP = true;
        }
        if(this.parentfieldname == 'CWMP_Project__c'){
            this.isCWMPProject =true;
            this.isCWMP = true;
        }
        if(this.documentrecordid != null){
            this.recordLocal = JSON.parse(JSON.stringify(this.docDetail));
            this.isEdit = true;
            this.recordLabel ='Edit Document';
        }
    }

    get docTypeValues() {
        if(this.isHHApplication){
        return [
            {label:this.label.HH_EN_Proof_of_Rental, value:'Proof of Rental'},
            {label:this.label.HH_EN_Property_Owner_ID, value:'Property Owner ID'},
            {label:this.label.HH_EN_Proof_of_Ownership, value:'Proof of Ownership'},
            {label:this.label.HH_EN_Home_Assessment_Report, value:'Home Assessment Report'},
            {label:this.label.HH_EN_Environmental_Checklist, value:'Environmental Checklist'},
            {label:this.label.HH_EN_Homeowner_Paper_Application, value:'Homeowner Paper Application'},
            {label:this.label.HH_EN_Homeowner_Appeal_Form, value:'Homeowner Appeal Form'},
                {label:this.label.HH_EN_Executed_Tri_Party_Agreement, value:'Executed Tri-Party Agreement'},
            {label:this.label.HH_EN_Other, value:'Other'}

        ];
    }
        if(this.isCWMPProject){
            return [
                {label:'Change Order', value:'Change Order'},
                {label:'Punch List', value:'Punch List'},
                {label:'Invoices', value:'Invoices'},
                {label:'Reimbursement Requested', value:'Reimbursement Requested'},
                {label:'Reimbursement Received', value:'Reimbursement Received'},
                {label:this.label.HH_EN_Other, value:'Other'}
            ];
        }
    }

    get docStageValue(){
        if(this.documentrecordid != null){
            return this.recordLocal.Stage__c;
        }else{
            return 'New';
        }
    }

    get docIsRequiredValue(){
        if(this.documentrecordid != null){
            return this.recordLocal.Is_Required__c;
        }else{
            return 'Optional';
        }
    }

    get docStatusValue(){
        if(this.documentrecordid != null){
            return this.recordLocal.Status__c;
        }else{
            return 'Active';
        }
    }

    get docTypeValue(){
        if(this.documentrecordid != null){
            return this.recordLocal.Document_Type__c;
        }else{
            return 'Blank';
        }
    }

    handleReset(event) {
        const inputFields = this.template.querySelectorAll(
            'lightning-input-field'
        );
        if (inputFields) {
            inputFields.forEach(field => {
                field.reset();
            });
        }
     }
     validation(){
         console.log('this.recordLocal]'+this.recordLocal['Document_Name__c']+'  bbbbbbb  '+this.recordLocal['Document_Type__c']);
         if(this.recordLocal['Document_Name__c'] == null || this.recordLocal['Document_Name__c'] == '' || this.recordLocal['Document_Name__c'] == undefined){
            let emailFieldCmp = this.template.querySelector('.docNameField');
            emailFieldCmp.setCustomValidity('Please fill Document Name');
            emailFieldCmp.reportValidity();
            this.isDisable = false;
            return false;
        }else if(this.recordLocal['Document_Type__c'] == null || this.recordLocal['Document_Type__c'] == '' || this.recordLocal['Document_Type__c'] == undefined){
            if(this.isCWMP ==true){
                    let emailFieldCmp = this.template.querySelector('.docTypeField');
                    emailFieldCmp.setCustomValidity('Please select Document type');
                    emailFieldCmp.reportValidity();
                    this.isDisable = false;
                    return false;
            }else{
            return true;
            }
         }else{
             return true;
         }
     }

    handleSave(){
        this.isDisable = true;
        console.log('this.validation() --- '+JSON.stringify(this.recordLocal));
        if(this.validation()){
           this.recordLocal[this.parentfieldname] = this.parentfieldvalue;
           console.log('this.this.recordLocal[this.parentfieldname]---'+this.recordLocal[this.parentfieldname]);
           this.executeAction(saveDocumentInfo,
                        {'documentDetail':JSON.stringify(this.recordLocal),'isEdit':this.isEdit},
                        (response) => {
                            this.showNotification('Success','Document Updated Successfully.','Success','Dismissible');
                            this.refreshDoc();
                            this.handleClose();
                        },(error) => {
                            this.isDisable = false;
                            if(error.body.message != undefined && error.body.message.includes('You can use only')){
                                this.showNotification('Error','You can use only -& / .: _, these special characters for Document Name.','Error','Dismissible');
                            }else{
                            this.showNotification('Error',error.body.message,'Error','Dismissible');
                            }
                       });
        }
    }

    handleClose() {
           const closemodal = new CustomEvent('closemodal', {
                   detail : null,
           });
           this.dispatchEvent(closemodal);
    }

    refreshDoc(){
        const refreshDoc = new CustomEvent('refreshdoc', {
                           detail : null,
                   });
                   this.dispatchEvent(refreshDoc);
    }
    }