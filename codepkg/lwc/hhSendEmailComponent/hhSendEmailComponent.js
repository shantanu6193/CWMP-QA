import { LightningElement, track, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import sendEmailAction from '@salesforce/apex/SendEmailController.sendEmailAction';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import Utility from 'c/utility'; 
import templateBody from '@salesforce/apex/EmailTemplateSelectionHandler.getEmailTemplateBody';
import USER_ID from '@salesforce/user/Id';

import NAME_FIELD from '@salesforce/schema/User.Name';
import EMAIL_FIELD from '@salesforce/schema/User.Email';
import fromAddressOptions from '@salesforce/apex/SendEmailController.getCWMPFromAddressOptions';

import getApplicationData from '@salesforce/apex/HH_ApplicationCtrl.getApplicationRecord';


const fieldsVal = [];

export default class HhSendEmailComponent extends Utility {

    @api recordId;
    @api defaultFromEmail;
    @api defaultObjName;
    @api defaultObjId;
    @api emailTemplateFolder;
    @api applicantEmail;
    @api replyTo;

    @track toAddress = [];
    @track ccAddress = [];
    @track bccAddress = [];
    subjectVal = '';
    bodyVal = '';
    acceptedFormats = [];
    @track allUploadedFileNames = [];
    @track relatedRecordName = '';

    @track preferredLanguage = '';

    @track contDocIds = [];
    @track paraValMap = [];
    @track isShowEmailTemplateSelection;
    @track selectedTemplate;
    templateId = '';
    @track fromValue ='';
    @track application;

    @track
    selectOptions = [];
    @track overrideMsg;
    @track disableSend = false;

    get showComponent() {

        return true;
        
    }



    connectedCallback() {
            
        this.retrieveData();

    }
    

    initData(){
        this.isShowEmailTemplateSelection = false;
    }


    
        /* Retrieve Application and related Data*/
        retrieveData() {
           
            console.log('retrieveData:----- ');
            console.log(this.recordId);

            this.executeAction(getApplicationData, {'applicationId' : this.recordId}, 
                (response) => {
                    console.log('retrieveData Success:----- GET APP');
                        this.handleGetDataResponse(response);
  
                },(error)=>{
                    if(error.body != undefined && error.body.message != undefined) {
                        this.showErrorNotification('Error Fetching Data',error.body.message);
                    } else {
                        this.showErrorNotification('Error Fetching Data',error);
                    }
            });
        }
    

        handleGetDataResponse(response) {
            console.log(response.application.Applicant__r.Email);
            //this.toAddress = response.application.Applicant__r.Email;

            this.preferredLanguage = response.application.Applicant__r.Preferred_Language__c;
            
            console.log(response);


            this.relatedRecordName = response.application.Name;



        }





    
    @wire(fromAddressOptions, {'fromEmail':'$defaultFromEmail','applicationId':'$recordId'})
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
                //Let User Fill out From Email
                this.fromValue = data[data.length-1].value;
            }
            
        }
    }

    handleFromValueChange(event){
       this.fromValue =  event.detail.value;
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
        const isInputsCorrect = [...this.template.querySelectorAll('lightning-input')]
        .reduce((validSoFar, inputField) => {
            inputField.reportValidity();
            return validSoFar && inputField.checkValidity();
        }, true);

        if(!isInputsCorrect) {
            return;
        }
        this.disableSend = true;
        
        console.log('Entered Send Email Function.....');
        console.log('parentRecdId'+ this.recordId);
        console.log('toEmailIds'+ this.toAddress);
        console.log('ccEmailIds'+ this.bodyVal);
        console.log('subject'+ this.subjectVal);
        console.log('contentDocIds'+ this.contDocIds);
        console.log('templateId'+ this.templateId);
        console.log('fromEmailId'+ this.fromValue);
        console.log('bccEmailIds'+ this.bccAddress);

        
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
            this.showSuccessNotification('Success','Email sent successfully!');
            this.disableSend = false;
            // Refresh Account Detail Page
           // getRecordNotifyChange(this.recordId);
           this.handleClear();
        })
        .catch(error =>{
            this.disableSend = false;
            console.log('Error Block===='+error);
        })
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