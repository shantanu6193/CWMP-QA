/**
 * Created by Pankaj on 01-05-2020.
 */

import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import logErrorMsg from '@salesforce/apex/ExceptionLogController.logErrorMessage';
import isGuestUser from '@salesforce/apex/UtilityCtrl.isGuestUser';


export default class Utility extends NavigationMixin(LightningElement) {
    // record passed from parent component. It is optional.
    @api record = {};
    // use this variable to bind in components
    @track recordLocal = {};

    @api programName = '';
    @api className = '';
    @api methodName = '';


    // add loading html if we want to add loading icons
    showLoader = false;

    skipInputFieldValidation = false;
    skipCustomLogicValidation = false;

    hasInitiated = false;

    /*
    * InitData method creation to work like connectedCallback()
    */
    connectedCallback() {
        //this.orderDetail = this.orderDetailUsingParameter.clone();
        if(this.hasInitiated == false) {
            this.hasInitiated = true;
            this.initializeRecordVariable();
            if(this.initData) {
                this.initData();
            }
        }
        if(this.handledOnLoadCallBack) {
            this.handledOnLoadCallBack();
        }
    }

    /*
    * Get URL parameter
    */
    getURLParameter(paramName) {
        return ((new URL(window.location.href)).searchParams.get(paramName))
    }

    /*
    * Initializes record variable
    */
    initializeRecordVariable() {
        if(this.record != undefined) {
            this.recordLocal = JSON.parse(JSON.stringify(this.record));
        }
    }

    /*
    * Sets input value
    */
    fieldChanged(event){
        this.recordLocal[event.target.getAttribute('data-field')] = event.target.value;
    }

    /*
    * Sets checkbox value
    */
    fieldChecked(event){
        this.recordLocal[event.target.getAttribute('data-field')] = event.target.checked;
    }

    /*
    * Sets radio value
    */

    fieldRadioSelection(event){
        this.recordLocal[event.target.getAttribute('data-field')] = event.detail.value;
    }



    allInputsValidated = true;

    /*
    * Gets value from recordLocal variable
    */
    @api
    getRecordDetails() {
        //console.log('Child paramMap---',this.orderDetail);
        if(this.updateRecordLocal) {
            this.updateRecordLocal();
        }
        let allInputFieldValid = true;
        if(this.skipInputFieldValidation == false) {
            allInputFieldValid = this.validateInputs();
        }

        let customLogicValid = true;
        if(this.skipCustomLogicValidation == false && this.validateCustomInput) {
            customLogicValid = this.validateCustomInput();
        }

        if(allInputFieldValid == false || customLogicValid == false) {
            return undefined;
        }

        if(this.allInputsValidated == false) {
            return undefined;
        }

        return this.recordLocal;
    }

    /*
    * Setter method to set record local
    */
    @api
    setRecordDetails(recordLocal) {
        this.recordLocal = recordLocal;
    }

    /*
    * Skips all validation
    */
    @api
    skipAllValidations() {
        this.skipInputFieldValidation = true;
        this.skipCustomLogicValidation = true;
    }

    /*
    * Enables validation
    */
    @api
    enableAllValidations() {
        this.skipInputFieldValidation = false;
        this.skipCustomLogicValidation = false;
    }

    /*
    * Skips input validation
    */
    @api
    skipInputValidations() {
        this.skipInputFieldValidation = true;;
    }

    /*
    * Enables input validation
    */
    @api
    enableInputValidations() {
        this.skipInputFieldValidation = false;
    }

    /*
    * Skips custom validation
    */
    @api
    skipCustomValidations() {
        this.skipCustomLogicValidation = true;;
    }

    /*
    * Enables custom validation
    */
    @api
    enableCustomValidations() {
        this.skipCustomLogicValidation = false;
    }

    /*
    * Redirect to community home page
    */
    redirectToCommunityHome = () => {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Home'
            }
         });
    }

    /*
    * Redirect to custom community page
    */
    redirectToCommunityCustomPage = (namedPage, stateJSON) => {
        //https://developer.salesforce.com/docs/component-library/documentation/en/lwc/lwc.reference_page_reference_type
        if(stateJSON == undefined) {
            stateJSON = {};
        }
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: namedPage,
            },
            state: stateJSON
        });
    }

    /*
    * Log out community user and redirect to login page
    */
    logoutCommunityUser = () => {
        this[NavigationMixin.Navigate]({
            type: 'comm__loginPage',
            attributes: {
                actionName: 'logout'
            }
         });
    }

    /*
    * Redirect to login page
    */
    redirectToCommunityLoginPage = () => {
        this[NavigationMixin.Navigate]({
            type: 'comm__loginPage',
            attributes: {
                actionName: 'login'
            }
         });
    }

    /*
    * Redirect to record page
    */
    navigateRecordViewPage = (recordId) => {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                actionName: 'view'
            }
        });
    }

    /*
    * Redirect to custom tab. Visualforce tabs, web tabs, Lightning Pages, and Lightning Component tabs are
    */
    navigateNavItemPage(pageName, paramJson){
        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                apiName: pageName
            },
            state: paramJson
        });
    }

    /*
    * Redirect to List view
    */
    navigateToObjectListView = (objectApiName) => {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: objectApiName,
                actionName: 'list'
            },
            state: {
                filterName: 'Recent'
            },
        });
    }

    navigateToListView = (objectApiName,state) => {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: objectApiName,
                actionName: 'list'
            },
            state:state,
        });
    }

    /**
     * Preview file
     */
    navigateToFilePreview = (fileUrl) => {
        console.log('###: Utility: fileURL: ' + JSON.stringify(fileUrl))
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: fileUrl,
            }
        }, false);
    }

    navigateToComponent = (componentName,state) => {
        this[NavigationMixin.Navigate]({
            type: "standard__component",
            attributes: {
                componentName: componentName
            },
            state:state,
        });
    }


    redirectToTabPage = (tabPage, stateJSON) => {
    //https://developer.salesforce.com/docs/component-library/documentation/en/lwc/lwc.reference_page_reference_type
    if(stateJSON == undefined) {
        stateJSON = {};
    }
        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                apiName: tabPage,
            },
            state: stateJSON
        });
    }


    /*
    * Show custom toast
    */
    showNotification = (_title, _message, _variant, _mode) => {
         const evt = new ShowToastEvent({
             title: _title,
             message: _message,
             variant: _variant,
             mode: _mode
         });
         this.dispatchEvent(evt);
    };

    /*
    * Show success toast
    */
    showNotificationwithMessageData = (_title, _message, _variant, _mode, _url, _label) => {
        const event = new ShowToastEvent({
            title: _title,
            message: _message,
            variant: _variant,
            mode: _mode,
            messageData: [
                '',
                {
                    url: _url,
                    label: _label,
                },
            ],
        });
        this.dispatchEvent(event);
   };

    /*
    * Show success toast
    */
    showSuccessNotification = (_title, _message) => {
         const evt = new ShowToastEvent({
             title: _title,
             message: _message,
             variant: 'success',
         });
         this.dispatchEvent(evt);
    };

    /*
    * Show error toast
    */
    showErrorNotification = (_title, _message) => {
         const evt = new ShowToastEvent({
             title: _title,
             message: _message,
             variant: 'error',
         });
         this.dispatchEvent(evt);
    };
	
	/* method refresh the screen */
    refreshScreen(){
        eval("$A.get('e.force:refreshView').fire();");
    }

    /*
    * Used to get data from apex
    */
    executeAction = (method, params, onSuccess, onError) => {
        this.showLoader = true;
        method(params)
        .then(response => {
            this.showLoader = false;
            onSuccess(response);
        }).catch(error => {
            this.showLoader = false;
            if(error.body && error.body.message && error.body.message.includes('You do not have access to the Apex class named')) {
                console.log(error.body.message);
                isGuestUser()
                .then(result => {
                    console.log('isGuestUser : ',result);
                    if(result) {
                        location.reload();
                    }
                })
                .catch(error => {
                    let errorMessage = error.body && error.body.message ? error.body.message : 'Something went wrong, please contact your administrator.';
                    this.showNotification('Error', errorMessage, 'error'); 
                   
                });
            } else {
                if(onError) {
                    onError(error);
                } else {
                    let errorMessage = error.body && error.body.message ? error.body.message : 'Something went wrong, please contact your administrator.';
                    console.error('Method ' + errorMessage);
                    this.showNotification('Error', errorMessage, 'error');
                }
                if(error.body != undefined && error.body.exceptionType != 'System.AuraHandledException'){
                    logErrorMsg({
                        className: this.className,
                        methodName: '',
                        exceptionMessage:error.body.message,
                        stackTrace:error.body.stackTrace,
                        programName: this.programName

                    })
                    .then(result => {

                    })
                    .catch(error => {

                        window.scrollTo(0,0);
                    });
                }
            }
        });
    };

    /*
    * Validate input fields which has class input
    */
    @api
    validateInputs(){
        const allValid = [...this.template.querySelectorAll('.input')]
            .reduce((validSoFar, inputCmp) => {
                        inputCmp.reportValidity();
                        return validSoFar && inputCmp.checkValidity();
            }, true);
        return allValid;
    }

    /*
    * Sets field null
    */
    setFieldsToBlank(field) {
        this.recordLocal[field] = null;
    }
    /* method refresh the screen */
    refreshScreen(){
        eval("$A.get('e.force:refreshView').fire();");
    }
        
    /*
    * Sets date field in YYYYMMDD Formate
    */
    todayDateInYYYYMMDD() {
        var today = new Date();
        var dd = today.getDate();

        var mm = today.getMonth() + 1;
        var yyyy = today.getFullYear();
        if (dd < 10) {
            dd = '0' + dd;
        }

        if (mm < 10) {
            mm = '0' + mm;
        }
        //today = mm + '/' + dd + '/' + yyyy;
        today = yyyy + '-' + mm + '-' + dd;
        return today;
    }
   
}