/**
 * Created by Ricky on 08-09-2021.
 */

import { LightningElement, wire, track, api } from 'lwc';
import Utility from 'c/utility';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import UId from '@salesforce/user/Id';

import UR_OBJECT from '@salesforce/schema/HH_Application__c';
import Is_the_property_in_the_floodplain from '@salesforce/schema/HH_Application__c.Is_the_property_in_the_floodplain__c';
import Income_Bracket from '@salesforce/schema/HH_Application__c.Income_Bracket__c';
import Homeowner_contribution_check_payment from '@salesforce/schema/HH_Application__c.Homeowner_contribution_check_payment__c';
import { getRecord, getRecordNotifyChange } from 'lightning/uiRecordApi';
import getRecordDetails from '@salesforce/apex/HH_UpdateTaxParcelAndFloodplain_Ctrl.getRecordDetails';
import updateTaxParcelAndFloodPlain from '@salesforce/apex/HH_UpdateTaxParcelAndFloodplain_Ctrl.updateTaxParcelAndFloodPlain';

import HH_TaxParcelNumber from '@salesforce/label/c.HH_TaxParcelNumber';
import HH_IsPropertyInFloodplain from '@salesforce/label/c.HH_IsPropertyInFloodplain';
import HH_TaxParcelUpdate_ComponentTitle from '@salesforce/label/c.HH_TaxParcelUpdate_ComponentTitle';
import HH_TexParcelUpdate_Component_SaveButton from '@salesforce/label/c.HH_TexParcelUpdate_Component_SaveButton';
import HH_EN_FillAllRequiredFieldErrorMessage from '@salesforce/label/c.HH_EN_FillAllRequiredFieldErrorMessage';
import HH_TaxParcel_EmailUpdateComponentName from '@salesforce/label/c.HH_TaxParcel_EmailUpdateComponentName';
import HH_Application_AssessorEmail from '@salesforce/label/c.HH_Application_AssessorEmail';
import HH_DetailsUpdatedSuccessfullMessage from '@salesforce/label/c.HH_DetailsUpdatedSuccessfullMessage';
import HH_EN_Application_Already_Submitted from '@salesforce/label/c.HH_EN_Application_Already_Submitted';
import HH_Email_Validation_Message from '@salesforce/label/c.HH_Email_Validation_Message';
import HH_EN_PhoneNumberMismatchError from '@salesforce/label/c.HH_EN_PhoneNumberMismatchError';
import HH_EN_Assessed_Value_of_the_Property from '@salesforce/label/c.HH_EN_Assessed_Value_of_the_Property';
import HH_EN_HERE from  '@salesforce/label/c.HH_EN_HERE';
import HH_Information_PDF from  '@salesforce/label/c.HH_Information_PDF';
import HH_Application_HomeownerHouseholdIncomeBracket from  '@salesforce/label/c.HH_Application_HomeownerHouseholdIncomeBracket';
import HH_EN_Value_must_be_numeric_0_9 from  '@salesforce/label/c.HH_EN_Value_must_be_numeric_0_9';
import HH_Application_Stage_HomeownerAgreement from  '@salesforce/label/c.HH_Application_Stage_HomeownerAgreement'; 
import HH_Application_HOContributionCheckPayment from  '@salesforce/label/c.HH_Application_HOContributionCheckPayment';
import HH_Application_HOContributionCheckPaymentAmount from  '@salesforce/label/c.HH_Application_HOContributionCheckPaymentAmount';

import HH_Application_Stage_Assessment from  '@salesforce/label/c.HH_Application_Stage_Assessment';
import HH_Application_Stage_CalOESReview from  '@salesforce/label/c.HH_Application_Stage_CalOESReview';
import HH_Application_Status_CommunityRFI from  '@salesforce/label/c.HH_Application_Status_CommunityRFI';
import HH_Application_Status_CalOESRFI from  '@salesforce/label/c.HH_Application_Status_CalOESRFI';
import HH_Application_Stage_CommunityReview from  '@salesforce/label/c.HH_Application_Stage_CommunityReview';
import HH_Application_Stage_CommunityDecision from  '@salesforce/label/c.HH_Application_Stage_CommunityDecision';

export default class HhUpdateTaxParcelAndFloodplain extends Utility {
    @api recordId; /** Variable to store the current record Id. */
    @track recordLocal = {}; /** Variable to store the record local upon Page reload. */
    showLoader = false; /** Variable to show  loader upon until the record gets Saved upon clicking the Save Changes button. */
    //isVisible = false; /** Variable to decide whether to show component on the page or not? */
    userId = UId /** Variable to store the current Logged In User. */
    //isVisibleTaxParcel = false; /* Variable to decide whether to show the Tax Parcel Component or not? */
    //isVisibleEmail = false; /* Variable to decide whether to show the Email Component or not? */
    isEditable = false; /* Variable to check if the details are editable in the current stage of teh record. */
    userType;


    /** Variable to store the imported custom Labels. */
    @track label = {
        HH_TaxParcelNumber,
        HH_IsPropertyInFloodplain,
        HH_TaxParcelUpdate_ComponentTitle,
        HH_TexParcelUpdate_Component_SaveButton,
        HH_EN_FillAllRequiredFieldErrorMessage,
        HH_Application_AssessorEmail,
        HH_TaxParcel_EmailUpdateComponentName,
        HH_DetailsUpdatedSuccessfullMessage,
        HH_EN_Application_Already_Submitted,
        HH_Email_Validation_Message,
        HH_EN_PhoneNumberMismatchError,
        HH_EN_Assessed_Value_of_the_Property,
        HH_EN_HERE,
        HH_Information_PDF,
        HH_Application_HomeownerHouseholdIncomeBracket,
        HH_EN_Value_must_be_numeric_0_9,
        HH_Application_Stage_Assessment,
        HH_Application_Stage_CalOESReview,
        HH_Application_Status_CommunityRFI,
        HH_Application_Status_CalOESRFI,
        HH_Application_Stage_CommunityReview,
        HH_Application_Stage_CommunityDecision,
        HH_Application_Stage_HomeownerAgreement,
        HH_Application_HOContributionCheckPayment,
        HH_Application_HOContributionCheckPaymentAmount
    }

    /** Wire method to get the object information and "Is YOu property in 100-Year Floodplain?" picklist values. */
    @wire(getObjectInfo, { objectApiName: UR_OBJECT }) objectInfo;
    @wire(getPicklistValues, {recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: Is_the_property_in_the_floodplain}) PropertyFloodplainOptions;
    @wire(getPicklistValues, {recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: Income_Bracket}) HomeownerHouseholdIncomeBracketOptions;
    @wire(getPicklistValues, {recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: Homeowner_contribution_check_payment}) HomeownerContributionCheckPayment;

    /** API method to get the updated record from Parent Component "Stage and Status Component". */
    @api
    getUpdatedRecord() { 
        this.retrieveData(this.recordId, this.userId);
    }

    /** connected callback method from Utility class to fetch the current record data. */
    initData() {
       this.retrieveData(this.recordId, this.userId);
    }

    /* This method is used to fetch the current record data upon page load by passing current record Id and Current Logged In user Id. */
    retrieveData(recordId,  userId) {
        this.showLoader = true;
        this.recordId = this.recordId == undefined ? null : this.recordId;
        this.executeAction(getRecordDetails , {'masterRecordId':this.recordId, 'userId':this.userId},
            (response) => {
                console.log('response ---> hh Application details --> ', response);
                this.recordLocal = response.hhApplication[0];
                this.isEditable = response.isEdit;
                this.userType = response.userType;

                console.log('this.userType --> ', this.userType);
                console.log('this.isEditable --> ', this.isEditable);
                /* Updating the Tax Parcel and EMail component visibility variable based on Current Stage of the Record. */
                //this.componentVisibility(this.recordLocal);
                this.showLoader = false;
            },(error)=>{
                if(error.body != undefined && error.body.message != undefined) {
                    this.showErrorNotification('Error Fetching Data 51',error.body.message);
                } else {
                    this.showErrorNotification('Error Fetching Data 53',error);
                }
                this.showLoader = false;
        });
    }

    /* Method to call Apex Class for updating the details on Record upon Save Changes button. */
    handleSubmit(event) {
        console.log('this.recordLocal --> 45 --> ', this.recordLocal);
        let allValid = this.validateInputs();
        let emailFieldCmp = this.template.querySelector('.emailField');
        if(emailFieldCmp != null){
            let emailValid = this.validateEmail();
            if(emailValid == false) {
                return;
            }
        }

        if(this.isEditable) {
        if(allValid) {
            this.showLoader = true;
            this.executeAction(updateTaxParcelAndFloodPlain , {'record' : JSON.stringify(this.recordLocal), 'userId': this.userId},
            (response) => {
                this.recordLocal = response.hhApplication[0];
                    this.isEditable = response.isEdit;
                    this.userType = response.userType;

                    //this.componentVisibility(this.recordLocal);
                getRecordNotifyChange([{recordId: this.recordId}]);

                this.showLoader = false;
                    this.showNotification('Success', this.label.HH_DetailsUpdatedSuccessfullMessage, 'success','dismissible');
            },(error)=>{
                console.log('error----',error);
                if(error.body != undefined && error.body.message != undefined) {
                        this.showNotification('Error', error.body.message, 'error', 'dismissible');
                } else {
                        this.showNotification('Error', error, 'error', 'dismissible');
                }
                this.showLoader = false;
            });
        }
        else {
                this.showNotification('', this.label.HH_EN_FillAllRequiredFieldErrorMessage,'error','dismissible');
        }
    }
        else {
            this.showNotificationwithMessageData('',this.label.HH_EN_Application_Already_Submitted, 'info', 'dismissible', this.label.HH_Information_PDF, this.label.HH_EN_HERE);
        }
    }

    /** This method is to decide whether to show Tax Parcel Component or Email Component for updating. */
    /**componentVisibility(recordLocal) {
        console.log('Tax Parcel Component condition is satisfied 166 ==> ', (this.userType == 'Community' || this.userType == 'Admin'));
        if(this.recordLocal != undefined && (((this.userType == 'Community' || this.userType == 'Admin') && (this.recordLocal.Stage__c == this.label.HH_Application_Stage_CommunityReview || (this.recordLocal.Stage__c == this.label.HH_Application_Stage_Assessment && this.recordLocal.Status__c == this.label.HH_Application_Status_CommunityRFI) || (this.recordLocal.Stage__c == this.label.HH_Application_Stage_CalOESReview && this.recordLocal.Status__c == this.label.HH_Application_Status_CalOESRFI))) || (this.userType == 'CalOES' && ((this.recordLocal.Stage__c == this.label.HH_Application_Stage_Assessment && this.recordLocal.Status__c == this.label.HH_Application_Status_CommunityRFI) || (this.recordLocal.Stage__c == this.label.HH_Application_Stage_CalOESReview && this.recordLocal.Status__c == this.label.HH_Application_Status_CalOESRFI)))) && this.isVisible == true) {
            this.isVisibleTaxParcel = true;
        }
        else {
            this.isVisibleTaxParcel = false;
        }
        if(this.recordLocal != undefined && this.recordLocal.Stage__c == this.label.HH_Application_Stage_CommunityDecision && this.isVisible == true) {
            this.isVisibleEmail = true;
        }
        else
         {
           this.isVisibleEmail = false;
         }
    }*/

    get isComponentVisible() {
        if((this.isAdditionalInfoFieldsVisible || this.isAssessorEmailFieldVisible || this.isContractInfoVisible) && this.isEditable == true) {
            return true;
        }
        return false;
    }

    get isAdditionalInfoFieldsVisible() {
//        if((((this.userType == 'Community' || this.userType == 'Admin') && (this.recordLocal.Stage__c == this.label.HH_Application_Stage_CommunityReview || (this.recordLocal.Stage__c == this.label.HH_Application_Stage_Assessment && this.recordLocal.Status__c == this.label.HH_Application_Status_CommunityRFI) || (this.recordLocal.Stage__c == this.label.HH_Application_Stage_CalOESReview && this.recordLocal.Status__c == this.label.HH_Application_Status_CalOESRFI))) || (this.userType == 'CalOES' && ((this.recordLocal.Stage__c == this.label.HH_Application_Stage_Assessment && this.recordLocal.Status__c == this.label.HH_Application_Status_CommunityRFI) || (this.recordLocal.Stage__c == this.label.HH_Application_Stage_CalOESReview && this.recordLocal.Status__c == this.label.HH_Application_Status_CalOESRFI)))) && this.isEditable == true) {
//            return true;
//        }
        if((this.recordLocal.Stage__c == this.label.HH_Application_Stage_CommunityReview || (this.recordLocal.Stage__c == this.label.HH_Application_Stage_Assessment && this.recordLocal.Status__c == this.label.HH_Application_Status_CommunityRFI) || (this.recordLocal.Stage__c == this.label.HH_Application_Stage_CalOESReview && this.recordLocal.Status__c == this.label.HH_Application_Status_CalOESRFI))) {
            return true;
        }
        return false;
    }

    get isAssessorEmailFieldVisible() {
        if(this.recordLocal != undefined && this.recordLocal.Stage__c == this.label.HH_Application_Stage_CommunityDecision && this.isEditable == true) {
            return true;
        }
        return false;
    }

    /** Sprint 9 Change */
    get isContractInfoVisible() {
        if(this.recordLocal != undefined && this.recordLocal.Stage__c == this.label.HH_Application_Stage_HomeownerAgreement) {
            return true;
        }
        return false; 
    }

    get isHomeOwnerCheckPaymentAmountVisible() {
        if(this.recordLocal.Homeowner_contribution_check_payment__c == 'Yes') {
            return true;
        }
        return false;
    }

    /** This method is for validating the Email field format - Standard was not working properly. */
    validateEmail() {
        let emailFieldCmp = this.template.querySelector('.emailField');
        console.log('emailFieldCmp --> ', emailFieldCmp);
        //let mailRegex =  /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        let mailRegex =  /^[^<>()[\]\\,;:\%#^\s@\"$&!@]+@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z0-9]+\.)+[a-zA-Z]{2,}))$/;
        let emailAddress =  this.recordLocal.Assessor_Email__c;
        let allValid = true;

        if(emailAddress == null || emailAddress == undefined || emailAddress == '') {
            emailFieldCmp.setCustomValidity(this.label.HH_EN_MissingFieldValueError);
            allValid = false;
        }
        else {
            let mailMatcher = mailRegex.test(emailAddress);
            if(mailMatcher == false ) {
                allValid = false;
                emailFieldCmp.setCustomValidity(this.label.HH_EN_PatternMismatchError);
            }else {
                emailFieldCmp.setCustomValidity('');
            }
        }
        emailFieldCmp.reportValidity();
        return allValid;
    }

}