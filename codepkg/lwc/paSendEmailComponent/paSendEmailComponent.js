import { LightningElement, track, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import sendEmailAction from '@salesforce/apex/SendEmailController.sendEmailAction';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import Utility from 'c/utility'; 
import templateBody from '@salesforce/apex/EmailTemplateSelectionHandler.getEmailTemplateBody';
import USER_ID from '@salesforce/user/Id';

import NAME_FIELD from '@salesforce/schema/User.Name';
import EMAIL_FIELD from '@salesforce/schema/User.Email';
import fromAddressOptions from '@salesforce/apex/SendEmailController.getFromAddressOptions';


const fieldsVal = [];
export default class PaSendEmailComponent extends Utility {

    @api recordId;
    @api defaultFromEmail;
    @api defaultObjName;
    @api defaultObjId;
    // This emailFrom property is not being used
    @api emailFrom;
    @api emailTo;
    @api replyTo;
    @track toAddress = [];
    @track ccAddress = [];
    @track bccAddress = [];
    subjectVal = '';
    bodyVal = '';
    acceptedFormats = [];
    @track allUploadedFileNames = [];
    @track relatedRecordName = '';
    @track contDocIds = [];
    @track paraValMap = [];
    @track isShowEmailTemplateSelection;
    @track selectedTemplate;
    templateId = '';
    @track fromValue;

    @track
    selectOptions = [];
    @track overrideMsg;

    connectedCallback() {
            
        if(this.defaultObjName){
            fieldsVal.push(this.defaultObjName);
        }

        if(this.defaultObjId){
            fieldsVal.push(this.defaultObjId);
        }
    }

    initData(){
        this.isShowEmailTemplateSelection = false;
        this.programName = 'Public Assistance';
        this.className = 'SendEmailController';
    }

    @wire(fromAddressOptions, {'fromEmail':'$defaultFromEmail'})
    fromAddressOptionVal({
        error,
        data
    }){
        if(error){
            this.error = error;
        } else if(data){
            for(const list of data){
                const option = {
                    label: list.key,
                    value: list.value
                };
               this.selectOptions = [ ...this.selectOptions, option ];
            }
            if(data.length > 0) {
                this.fromValue = data[0].value;
            }
        }
    }

    handleFromValueChange(event){
       this.fromValue =  event.detail.value;
    }

    @wire(getRecord, { recordId: '$recordId', fields:  fieldsVal})
    projectInfo({
        error,
        data
    }) {
        if (error) {
           this.error = error ; 
        } else if (data) {
            this.relatedRecordName = data.fields.Name.value;
        }
    }

    get acceptedFormats(){
        return ['.pdf', '.png'];
    }

    get isAttachedFiles(){
        return this.allUploadedFileNames.length === 0 ? false : true;
    }

    //Handle of File onuploadfinish event
    handleUploadFinished(event){
        // Get the list of uploaded files
        
        console.log('Entered Upload Finish Section.....');
        const uploadedFiles = event.detail.files;
        console.log('uploadedFiles Val ===>'+uploadedFiles);
        let uploadedFileNames = '';
        let contDocId = '';
        for(let i = 0; i < uploadedFiles.length; i++) {
            uploadedFileNames += uploadedFiles[i].name + '';
            contDocId = uploadedFiles[i].documentId;
            this.allUploadedFileNames.push(uploadedFileNames);
            this.contDocIds.push(contDocId);
        }
        
    }


    // Handle of To Address Changes..
    handleToAddressChanges(event){
        let toAddressVal = 
        this.toAddress = event.target.value;
    }
    // Handle of Cc Address Changes...
    handleCcAddressChanges(event){
        this.ccAddress = event.target.value;
    }

    handleBccAddressChanges(event){
        this.bccAddress = event.target.value;
    }
    // Handle of Subject Changes....
    handleSubjectValChange(event){
        this.subjectVal = event.target.value;
    }
    // Handle of Body Changes.....
    handleBodyValChange(event){
        this.bodyVal = event.target.value;
    }

    // Final Sending of Email...
    sendEmail(){
        console.log('Entered Send Email Function.....');
        const isInputsCorrect = [...this.template.querySelectorAll('lightning-input')]
            .reduce((validSoFar, inputField) => {
                inputField.reportValidity();
                return validSoFar && inputField.checkValidity();
            }, true);
        
        if(isInputsCorrect){
            this.paraValMap = {'parentRecdId': this.recordId, 'toEmailIds':this.toAddress, 'ccEmailIds':this.ccAddress,
                                'body':this.bodyVal, 'subject':this.subjectVal, 'contentDocIds':this.contDocIds, 
                                'templateId': this.templateId, 'fromEmailId': this.fromValue, 'bccEmailIds':this.bccAddress,
                                'replyTo':this.replyTo};
            console.log('The New ParaValMap---->'+this.paraValMap);   
            sendEmailAction({paramsMap: this.paraValMap})
            .then(result => {
                this.toAddress = [];
                this.ccAddress = [];
                this.bccAddress = [];
                this.subjectVal = '';
                this.bodyVal = '';
                this.allUploadedFileNames = [];
                this.contDocIds = [];
                // Show success messsage
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Success',
                    message: 'Email is sent successfully!',
                    variant: 'success'
                }),);
                // Refresh Account Detail Page
            // getRecordNotifyChange(this.recordId);
            this.handleClear();
            })
            .catch(error =>{
                console.log('Error Block===='+error);
            })
        }
    }

    handleClear(event) {
        eval("$A.get('e.force:refreshView').fire();");
    }

    showEmailTemplates(){
        console.log('Entered Show Email Template True.....');
        this.checkBodyContent();
        
    }

    checkBodyContent(){
        if(this.bodyVal){
            this.overrideMsg = true;
            this.isShowEmailTemplateSelection  = false;
            this.isModalOpen = false;
        }else{
            this.overrideMsg = false;
        this.isShowEmailTemplateSelection  = true;
        this.isModalOpen = true;
    }
    }
    handleSelectedTemplateInfo(event){
        this.bodyVal = '';
        this.selectedTemplate = event.detail.selectedtemplate;

        //get Template body Info.....
        templateBody({emailTemplateId:this.selectedTemplate, recordId:this.recordId})
        .then(result =>{
            console.log('Result Block handleSelectedTemplateInfo===='+result);
            this.bodyVal += '\n' +  result.Body;
            this.subjectVal = result.Subject;
            this.templateId = this.selectedTemplate;
        })
        .catch(error =>{
            console.log('Error Block handleSelectedTemplateInfo===='+error);
        })
    }

    modalCloseHandler(){
        this.isShowEmailTemplateSelection  = false;
    }

    clearContent(){
        this.toAddress = [];
        this.ccAddress = [];
        this.bccAddress = [];
        this.subjectVal = '';
        this.bodyVal = '';
        this.allUploadedFileNames = [];
        this.contDocIds = [];
    }

    handleClick(event){
        if(event.target.name ==='warningModal'){
            console.log('event.detail.status val==='+event.detail.status);  
            console.log('event.detail.status val==='+event.detail.originalMessage);   

            if(event.detail.status === 'confirm') {
                this.overrideMsg = false;
                this.isShowEmailTemplateSelection  = true;
                this.isModalOpen = true;
            }else if(event.detail.status === 'cancel'){
                this.overrideMsg = false;
            }
        }else {
            
        }
    }

}