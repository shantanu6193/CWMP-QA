/**
 * Created by harsh on 28-01-2021.
 */

import { LightningElement, track, wire, api } from 'lwc';
import Utility from 'c/utility';
import getPageDetails from '@salesforce/apex/PageLayoutCtrl.getPageDetails';
import getLoggedInUsrDetails from '@salesforce/apex/PageLayoutCtrl.getLoggedInUsrDetails';
//import getNextPageDetails from '@salesforce/apex/PageLayoutCtrl.getNextPageDetails';
import getProjectSitePageDetailsByPageLayoutId from '@salesforce/apex/PageLayoutCtrl.getProjectSitePageDetailsByPageLayoutId';

import getPageLayoutDetails from '@salesforce/apex/PageLayoutCtrl.getPageLayoutDetails';
import getRecordData from '@salesforce/apex/PageLayoutCtrl.getRecordDetails';
import getFieldDependencies from '@salesforce/apex/PageLayoutCtrl.getFieldDependencies';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { CurrentPageReference } from 'lightning/navigation';
import updateObjectDetails from '@salesforce/apex/PageTableController.updateObjectDetails';
import { subscribe, APPLICATION_SCOPE, MessageContext} from 'lightning/messageService';
import pageTableMessageChannel from '@salesforce/messageChannel/pageTableMessageChannel__c';

export default class PageLayout extends Utility {
    /*if any action/callback in progress then pass true/false value
    Used to disable button after click*/
    @api isActionInProgress = false;
    @api isAllFieldsReadOnly;
    @api nextButtonLabel;
    @api hideFieldCustomAttribute;
    @api recordId;
    @api isSubmitDisabled;
    @api isSaveDisabled;
    @api isBackButtonAllowed = false;

    @track isSubmitAllowedLocal = true;
    @track isSaveAllowedLocal = true;
    @track isSubmitConfirmationShow = false;
    @track pageLayoutId;
    @track pageTemplateDeveloperNameLocal;
    @track pageLayoutSequenceLocal;
    @track pageLayoutIdLocal;
    @track nextPageLayoutSequence;
    @track previousPageLayoutSequence;
    objectApiNameValue;
    relatedObjectApiNameValue;
    objectDefaultRecordTypeId;
    submitMessage = '';
    @track objectInfoValue = {};
    @track pageLayoutDetails = {};
    @track pageLayoutRelatedObjects = [];
    @track childRelatedObjectRecordTypes = [];
    @track relatedObjectInfo = {};
    showLoader = true;
    @track tableRecords = [];
    @track dependentFieldValueArray = [];
    @track programTemplatePageIdLocal;
    @track isAnyFieldsChangeLocal;
    @track messageChannelNameArray;
    @track pageFieldSectionMap = {};
    @track loggedInUserDetails = {};

    /*Wire Methods*/
   @wire(getLoggedInUsrDetails, {})
   wireuser({error,data}) {
        if (error) {
            console.log('error while getting logged in user details');
        } else if (data) {
            if(data['success']){
                this.loggedInUserDetails = data['userDetails'];
                console.log('---loggedInUserDetails--',this.loggedInUserDetails);
            }
       }
    }

    @wire(CurrentPageReference)
    setCurrentPageRef(currentPageReference) {
        if(currentPageReference && currentPageReference.state) {
          if(currentPageReference.state.id) {
                this.recordId = currentPageReference.state.id;
                console.log('recordId_: '+this.recordId);
                //this.retrieveData();
          }
          if(currentPageReference.state.pageLayoutId) {
                this.pageLayoutId = currentPageReference.state.pageLayoutId;
                this.pageLayoutIdLocal = currentPageReference.state.pageLayoutId;
                console.log('pageLayoutId: '+this.pageLayoutId);
               if(currentPageReference.state.projectSiteId) {
                   this.recordId = currentPageReference.state.projectSiteId;
               }
          }else if(currentPageReference.state.c__pageLayoutId) {
                this.pageLayoutId = currentPageReference.state.c__pageLayoutId;
                this.pageLayoutIdLocal = currentPageReference.state.c__pageLayoutId;
                console.log('pageLayoutId: '+this.pageLayoutId);
               if(currentPageReference.state.c__projectSiteId) {
                   this.recordId = currentPageReference.state.c__projectSiteId;
               }
          }

        }
    }

    @wire(getPageDetails,{recordId:'$recordId', programTemplatePageId : '$programTemplatePageId'})
    wirePageDetails({error, data}){
        this.showLoader = false;
        if(data){
            console.log('wirePageDetails response: ',data);
            this.programTemplatePageIdLocal = data['programTemplatePage']['Id'];
            console.log('wirePageDetails programTemplatePageIdLocal: ',this.programTemplatePageIdLocal);
            this.pageLayoutDetails = data;
            this.submitMessage = (data['programTemplatePage']['Submit_Confirmation_Message__c'] != '' || data['programTemplatePage']['Submit_Confirmation_Message__c'] != undefined) ? data['programTemplatePage']['Submit_Confirmation_Message__c'] : 'Are you sure you want to submit this record?';
            this.objectApiNameValue = this.pageLayoutDetails['pageLayoutObject'];
            this.relatedObjectInfo = this.pageLayoutDetails['relatedSObjectsMetaInfo'];
            this.pageLayoutIdLocal = data['pageLayout']['Id'];
            this.retrieveData();
            this.subscribeToMessageChannelForPageField();
        }else if(error){
            console.log('wirePageDetails error: ',error);
        }
    }
    /**Used to get project site page details*/
    @wire(getProjectSitePageDetailsByPageLayoutId,{pageLayoutId:'$pageLayoutId'})
    wireSitePageDetails({error, data}){
        this.showLoader = false;
        if(data){
            console.log('wireSitePageDetails response: ',data);
            //this.programTemplatePageIdLocal = data['programTemplatePage']['Id'];
            //console.log('wireSitePageDetails programTemplatePageIdLocal: ',this.programTemplatePageIdLocal);
            this.pageLayoutDetails = data;
            this.objectApiNameValue = this.pageLayoutDetails['pageLayoutObject'];
            this.relatedObjectInfo = this.pageLayoutDetails['relatedSObjectsMetaInfo'];
            this.pageLayoutIdLocal = data['pageLayout']['Id'];
            console.log('---------pageLayoutIdLocal----'+this.pageLayoutIdLocal);
            this.retrieveData();
            this.subscribeToMessageChannelForPageField();
        }else if(error){
            console.log('wireSitePageDetails error: ',error);
        }
    }

    @wire(getObjectInfo, {objectApiName: '$objectApiNameValue' })
    objectInfo({error, data}){
        this.showLoader = false;
        if(data){
            console.log('getObjectInfo response: ',data);
            console.log('defaultRecordTypeId response: ',data.defaultRecordTypeId);
            this.objectDefaultRecordTypeId = data.defaultRecordTypeId;
            this.objectInfoValue = JSON.parse(JSON.stringify(data));
            console.log('objectInfoValue response: ',this.objectInfoValue);
            this.prepareDependantPicklistArray();
        }else if(error){
            console.log('getObjectInfo error for objectApiNameValue: ',this.objectApiNameValue);
            console.log('getObjectInfo error: ',error);
        }
    }
    renderedCallback(){
        console.log('----renderCallback----');
    }

    @wire(MessageContext)
    messageContext;

     /*Subscript PageTableMessageChannel*/
     subscribeToPageTableMessageChannel() {
         console.log('page layout subscribeToPageTableMessageChannel----');
         if (!this.subscription) {
             this.subscription = subscribe(
                 this.messageContext,
                 pageTableMessageChannel,
                 (message) => this.handleTableMessageChannel(message),
                 { scope: APPLICATION_SCOPE }
             );
             console.log('page layout subscribeToPageTableMessageChannel subscribed successfully----');
         }
     }

    initData(){
        window.scrollTo(0,0);
        console.log('pageLayoutDeveloperName: '+this.pageLayoutDeveloperName);
        console.log('recordId : ',this.recordId);
        if(this.isSaveDisabled) {
            this.isSaveAllowedLocal = !this.isSaveDisabled;
        }
        if(this.isSubmitDisabled) {
            this.isSubmitAllowedLocal = !this.isSubmitDisabled;
        }
    }


    get nextButtonLabelLocal(){
        if(this.isAllFieldsReadOnly){ return 'Next';}
        return 'Save & Continue';
    }

    @api refreshPageSection() {
        //this.template.querySelector("c-page-layout-section").refreshPageField();
        this.template.querySelectorAll('c-page-layout-section').forEach((element) => {
            element.refreshPageField();
        });
    }

    @api
    get pageTemplateDeveloperName(){
        return this.pageTemplateDeveloperNameLocal;
    }

    @api
    get pageLayoutSequence(){
        return this.pageLayoutSequenceLocal;
          }

    set pageLayoutSequence(value){
        console.log('pageLayoutSequence value: '+value);
        this.pageLayoutSequenceLocal = value;
        }

    @api
    get programTemplatePageId(){
        return this.programTemplatePageIdLocal;
    }

    set programTemplatePageId(value){
        console.log('programTemplatePageId value: '+value);
        this.programTemplatePageIdLocal = value;
    }

    @api
    get isAnyFieldsChange(){
        return this.isAnyFieldsChangeLocal;
    }

    set isAnyFieldsChange(value){
        this.isAnyFieldsChangeLocal = value;
        }

    @api
    fieldChangesSaved(){
        this.isAnyFieldsChangeLocal = false;
    }

    @api
    get isSubmitAllowed(){
        return this.isSubmitAllowedLocal;
    }

    set isSubmitAllowed(value){
        this.isSubmitAllowedLocal = value;
    }

    @api
    get isSaveAllowed() {
        return this.isSaveAllowedLocal;
    }

    set isSaveAllowed(value) {
        this.isSaveAllowedLocal = value;
    }

    prepareRelatedObjects(){
        let fields = this.objectInfoValue['fields'];
        if(this.pageLayoutDetails['relatedObjects']){
            let index = 0;
            for(let key in this.pageLayoutDetails['relatedObjects']){
                console.log('Field:',this.pageLayoutDetails['relatedObjects'][key]);
                let apiFieldName = this.pageLayoutDetails['relatedObjects'][key].replace("__r", "__c");
                let fieldMetadata = fields[apiFieldName];
                console.log('Field metadata:',JSON.stringify(fieldMetadata));
                if(fieldMetadata['dataType'] == 'Reference'){
                    let referenceInfo = {'referenceAPIName':fieldMetadata['referenceToInfos'][0]['apiName'], 'relationshipName': fieldMetadata['relationshipName']};
                    referenceInfo['key'] = 'key_'+index;
                    index++;
                    this.pageLayoutRelatedObjects.push(referenceInfo);
                    /*this.relatedObjectInfo[fieldMetadata['referenceToInfos'][0]['apiName']] = fieldMetadata['relationshipName'];
                    this.relatedObjectApiNameValue = referenceInfo.referenceAPIName;*/
                }
            }
        }
        console.log('this.pageLayoutRelatedObjects: ',JSON.stringify(this.pageLayoutRelatedObjects));
    }

    storeRecordTypeInfo(event){
        console.log('event', JSON.stringify(event));
        this.childRelatedObjectRecordTypes.push(JSON.parse(JSON.stringify(event.detail)));
    }

    handleConfirmationClick(event) {
        let action = event.detail;
        if(action.status == 'confirm') {
            this.submitAction();
            this.isSubmitConfirmationShow = false;
        } else {
            this.isSubmitConfirmationShow = false;
        }
    }

    /*Getter Methods*/
    get pageSectionLocal(){
        if(!this.pageLayoutDetails['pageSections']) return [];
        let pageSections = [];
        console.log('pageSections',JSON.stringify(this.pageLayoutDetails['pageSections']));
        for(let i=0; i <= this.pageLayoutDetails['pageSections'].length; i++){
            if(this.pageLayoutDetails['pageSections'][i] && this.pageLayoutDetails['pageSections'][i]['pageSectionObj']){
                let pageSection = JSON.parse(JSON.stringify(this.pageLayoutDetails['pageSections'][i]['pageSectionObj']));
                pageSection['isSectionHidden'] = this.isSectionHidden(pageSection);
                console.log('pageSection---------------------',pageSection);
                pageSections.push(pageSection);
            }
        }
        return pageSections;
    }

    isSectionHidden(pageSection){
            /*console.log('record value: ',this.record);
            console.log('record pageSection Developer Name: '+pageSection.DeveloperName);
            console.log('record pageSection Hide_Field_API_Name__c: '+pageSection.Hide_Field_API_Name__c);
            console.log('record pageSection Hide_Field_Value__c: '+pageSection.Hide_Field_Value__c);
            console.log('record pageSection Hide_Field_Operator__c: '+pageSection.Hide_Field_Operator__c);
            console.log('record pageSection Hide_Field_API_Name_2__c: '+pageSection.Hide_Field_API_Name_2__c);
            console.log('record pageSection Hide_Field_Value_2__c: '+pageSection.Hide_Field_Value_2__c);
            console.log('record pageSection Hide_Field_Operator_2__c: '+pageSection.Hide_Field_Operator_2__c);*/

            let returnFlag = false;
            if(pageSection.Hide_Field_Operator__c && pageSection.Hide_Field_API_Name__c && pageSection.Hide_Field_Value__c
               && pageSection.Hide_Field_Operator_2__c && pageSection.Hide_Field_API_Name_2__c && pageSection.Hide_Field_Value_2__c){
                   console.log('first If ');
                let hideField1 = pageSection.Hide_Field_Value__c.split(",");
                let hideField2 = pageSection.Hide_Field_Value_2__c.split(",");
                console.log('hideField1 ',hideField1);
                console.log('hideField2 ',hideField2);

                let fieldValueToCompare1 = this.getFieldAPIValue(pageSection.Hide_Field_API_Name__c);
                let fieldValueToCompare2 = this.getFieldAPIValue(pageSection.Hide_Field_API_Name_2__c);

                console.log('this.record[pageSection.Hide_Field_API_Name__c]: ',fieldValueToCompare1);
                console.log('this.record[pageSection.Hide_Field_Value_2__c]: ',fieldValueToCompare2);
                let condition1 = this.checkCondition(pageSection.Hide_Field_Operator__c, hideField1, fieldValueToCompare1);
                let condition2 = this.checkCondition(pageSection.Hide_Field_Operator_2__c, hideField2, fieldValueToCompare2);

                console.log('condition1: ',condition1);
                console.log('condition2: ',condition2);
                if(condition1 || condition2){
                    returnFlag = true;
                }
            }else if(pageSection.Hide_Field_Operator__c && pageSection.Hide_Field_API_Name__c && pageSection.Hide_Field_Value__c){
                console.log('first else If ');
                console.log('this.record[pageSection.Hide_Field_API_Name__c]: ',this.record[pageSection.Hide_Field_API_Name__c]);

                let valueArray = pageSection.Hide_Field_Value__c.split(",");
                //if(pageSection.Hide_Field_Operator__c == 'Equal' && String(this.record[pageSection.Hide_Field_API_Name__c]) == pageSection.Hide_Field_Value__c){
                if(pageSection.Hide_Field_Operator__c == 'Equal' && valueArray.includes(String(this.record[pageSection.Hide_Field_API_Name__c]))){
                    returnFlag = true;
                }else if(pageSection.Hide_Field_Operator__c == 'Not Equal' && !valueArray.includes(String(this.record[pageSection.Hide_Field_API_Name__c]))){
                    returnFlag = true;
                }else if(!this.record[pageSection.Hide_Field_API_Name__c]){
                    returnFlag = true;
                }

            }
            return returnFlag;
    }

    getFieldAPIValue(fieldApiName){
        console.log('fieldApiName:'+fieldApiName);
        if(fieldApiName.includes('__r')){
            let tempArray = this.getRelatedFieldArray(fieldApiName);
            console.log('tempArray:'+tempArray);
            if(this.record[tempArray[0]] && this.record[tempArray[0]][tempArray[1]]){
              return String(this.record[tempArray[0]][tempArray[1]]);
            }else{
                return undefined;
            }
        }
        return String(this.record[fieldApiName]);
    }

    getRelatedFieldArray(fieldApiName){
        return fieldApiName.split('.');
    }


    checkCondition(conditionType, valuesToCompare, fieldValues){
        if(conditionType == 'Equal' && valuesToCompare.includes(fieldValues)){
            return true;
        }else if(conditionType == 'Not Equal' && !valuesToCompare.includes(fieldValues)){
            return true;
        }
        return false;
    }

    get isPageLayoutLoaded(){
        if(this.recordId == undefined && !(Object.keys(this.pageLayoutDetails).length === 0 && this.pageLayoutDetails.constructor === Object) && !(Object.keys(this.objectInfoValue).length === 0 && this.objectInfoValue.constructor === Object)){
            return true;
        }else if(this.recordId && Object.keys(this.record).length > 0){
            return true;
        }
        return false;
        //return !(Object.keys(this.pageLayoutDetails).length === 0 && this.pageLayoutDetails.constructor === Object) && !(Object.keys(this.objectInfoValue).length === 0 && this.objectInfoValue.constructor === Object); // this.objectDefaultRecordTypeId != undefined
    }

    get isReadyForGetRelatedObjectMetaInfo(){
        return !(Object.keys(this.pageLayoutDetails).length === 0 && this.pageLayoutDetails.constructor === Object) && !(Object.keys(this.objectInfoValue).length === 0 && this.objectInfoValue.constructor === Object); // this.objectDefaultRecordTypeId != undefined
    }

    get renderSaveAndContinue(){
        if(this.pageLayoutDetails && this.pageLayoutDetails.programTemplatePage && this.pageLayoutDetails.programTemplatePage.Page_Previous_Next_Button__c != 'Last Page'){
            return true;
        }
        return false;
    }

    get renderPreviousButton(){
        if(this.pageLayoutDetails && this.pageLayoutDetails.programTemplatePage && this.pageLayoutDetails.programTemplatePage.Page_Previous_Next_Button__c != 'First Page'){
            return true;
        }
        return false;
    }

    get renderBackButton() {
        return this.isBackButtonAllowed;
    }

    get renderSubmitButton(){
        if(this.pageLayoutDetails && this.pageLayoutDetails.programTemplatePage && this.pageLayoutDetails.programTemplatePage.Page_Previous_Next_Button__c == 'Last Page'){
            return true;
        }
        return false;
    }



    get isPageReadyToLoad(){
        if(!(Object.keys(this.pageLayoutDetails).length === 0 && this.pageLayoutDetails.constructor === Object)
            && !(Object.keys(this.objectInfoValue).length === 0 && this.objectInfoValue.constructor === Object) ){
            if(this.pageLayoutDetails['relatedObjects'].length == 0){
                return true;
            }else if(this.pageLayoutDetails['relatedObjects'].length > 0 && this.childRelatedObjectRecordTypes.length > 0 && this.pageLayoutDetails['relatedObjects'].length == this.childRelatedObjectRecordTypes.length){
                return true;
            }
        }
        return false;
    }

    @api
    returnCurrentRecord(){
        if(this.record) return this.record;
        return {};
    }

    @api
    getObjectApiName(){
        return this.pageLayoutDetails['pageLayoutObject'];
    }

    @api
    retrieveData(){
        console.log('retrieveData this.recordId'+ this.recordId);
        console.log('retrieveData this.pageLayoutIdLocal '+ this.pageLayoutIdLocal);
        if(this.recordId && this.pageLayoutIdLocal){
            this.showLoader = true;
            this.record = {};
            this.executeAction(getRecordData, {'recordId' : this.recordId, 'pageLayoutId': this.pageLayoutIdLocal}, (response) => {
                console.log('retrieveData response: ',response);
                this.showLoader = false;
                if(response['isSuccess']){
                    this.record = response['recordDetails'];
                    this.recordLocal = response['recordDetails'];
                }
            });
        }
    }

    validateRecord() {
        let isValid = true;
        if(this.template.querySelector('[data-custom="innerComponent"]') != undefined) {
            let localRecord = {};
            this.template.querySelectorAll('[data-custom="innerComponent"]').forEach(element => {
                if(element.validateSection() == false){
                    isValid = false;
                }
            });
        }
        console.log('is valid record: ',isValid);
        /*Relative fields are not covered*/
        if(this.pageLayoutDetails['pageValidations']){
            for(let i=0; i<this.pageLayoutDetails['pageValidations'].length; i++){
                let validationRecord = this.pageLayoutDetails['pageValidations'][i];
                let fields = validationRecord['Field_API_Name__c'].split(",");
                let expression = validationRecord['Expression__c'];
                let isAllFieldsAPIValueFound = true;
                for(let key in fields){
                    if(!this.record[fields[key]]){
                        isAllFieldsAPIValueFound = false;
                        /*this.showErrorNotification("Error", "Please fill all required fields");
                        return false;*/
                    }
                    expression = expression.replace(fields[key], this.record[fields[key]]);
                }
                if(isAllFieldsAPIValueFound && eval(expression)){
                    this.showErrorNotification("Error", validationRecord['Error_Message__c']);
                    return false;
                }
            }
        }
        return isValid;
    }

    quickSave(){
        if(this.validateRecord() == false) {
            this.scrollToTopOfPage();
            return;
        }
        console.log('page layout record: ',this.record);
        console.log('page layout recordLocal: ',this.recordLocal);
        let detailJson = {  buttonAction: 'quickSave',

                            redirectType: this.pageLayoutDetails['pageRedirectType'],
                            redirectTo: this.pageLayoutDetails['pageRedirectTo'],
                            nextPageLayoutSequence: this.pageLayoutDetails['pageSequence'],
                            nextPageLayout: this.pageLayoutDetails['nextPageLayout'],
                            programTemplatePageIdLocal: this.programTemplatePageIdLocal
                         };
        this.fireButtonActionEvent(detailJson);
    }

    saveAndContinue(event){
        if(this.validateRecord() == false) {
            this.scrollToTopOfPage();
            return;
        }
        console.log('page layout record: ',this.record);
        console.log('page layout recordLocal: ',this.recordLocal);
        let detailJson = {buttonAction: event.currentTarget.name,
                          recordLocal: this.recordLocal,
                          redirectType: this.pageLayoutDetails['pageRedirectType'],
                          redirectTo: this.pageLayoutDetails['pageRedirectTo'],
                          nextPageLayoutSequence: this.pageLayoutDetails['pageSequence'],
                          nextPageLayout: this.pageLayoutDetails['nextPageLayout'],
                          programTemplatePageIdLocal: this.programTemplatePageIdLocal
                          };
        this.fireButtonActionEvent(detailJson);
    }

    ///To Show submit button confirmation modal
    showSubmitConfirmation() {
        if(this.submitMessage != '' && this.submitMessage != undefined) {
            this.isSubmitConfirmationShow = true;
        } else {
            this.isSubmitConfirmationShow = false;
            this.submitAction();
        }
    }

    submitAction(){
        if(this.validateRecord() == false) {
            this.scrollToTopOfPage();
            return;
        }
        console.log('page layout record: ',this.record);
        console.log('page layout recordLocal: ',this.recordLocal);
        let detailJson = {buttonAction: 'submit',
                          programTemplatePageIdLocal: this.programTemplatePageIdLocal
                          };
        this.fireButtonActionEvent(detailJson);
    }

    redirectToPrevious(){
        //if(this.validateRecord() == false) return;
        let detailJson = {buttonAction: 'previous',
                          recordLocal: this.recordLocal,
                          redirectType: this.pageLayoutDetails['pageRedirectType'],
                          redirectTo: this.pageLayoutDetails['pageRedirectToPrevious'],
                          nextPageLayoutSequence: this.pageLayoutDetails['pageSequence'],
                          nextPageLayout: this.pageLayoutDetails['previousPageLayout'],
                          programTemplatePageIdLocal: this.programTemplatePageIdLocal
                          };
        this.fireButtonActionEvent(detailJson);
    }

    redirectToBackNoSave() {
        let detailJson = {buttonAction: 'back',
                          recordLocal: this.recordLocal,
                          programTemplatePageIdLocal: this.programTemplatePageIdLocal
                          };
        this.fireButtonActionEvent(detailJson);
    }

    get previousPageSequence(){
        let pageVal = this.pageLayoutSequence - 2;
        if(pageVal > 0){
            return pageVal;
        }else{
            return 0;
        }
        return 0;
    }


    fireButtonActionEvent(detailJson){
        console.log('button_Action_Test -------------',detailJson);
        const fieldChangedEvent = new CustomEvent('buttonactionevent', {
            detail: detailJson,
        });
        this.dispatchEvent(fieldChangedEvent);
        
    }

    fieldChangedChild(event){
        this.isAnyFieldsChangeLocal = true;
        console.log('event.detail:', JSON.stringify(event.detail));
         if(event.detail['apiName'].includes('__r')){
             try{
                 let res = event.detail['apiName'].split(".");
                  if(this.recordLocal[res[0]]){
                      let temp = this.recordLocal[res[0]];
                      temp[res[1]] = event.detail['apiValue'];
                  }else{
                      this.recordLocal[res[0]] = {};
                      this.recordLocal[res[0]][res[1]] = event.detail['apiValue'];
                  }
             }catch(e){
                 console.log('error in ', JSON.stringify(e));
             }
         }else{
            this.recordLocal[event.detail['apiName']] = event.detail['apiValue'];
            console.log('isControllingField: '+this.isControllingField(event.detail['apiName']));
            if(this.isControllingField(event.detail['apiName'])){
                let controllingField = event.detail['apiName'];
                let dependentFieldValues = this.dependentFieldValueArray[controllingField];
                for(let dependentField in this.objectInfoValue['dependentFields'][controllingField]){
                    let values = dependentFieldValues[dependentField];
                    if(values[this.recordLocal[event.detail['apiName']]].length == 1){
                        this.recordLocal[dependentField] = values[this.recordLocal[event.detail['apiName']]][0];
                    }
                }
            }
         }

         //this.record[event.detail['apiName']] = event.detail['apiValue'];
         this.record = JSON.parse(JSON.stringify(this.recordLocal));

         //this.recordLocal = JSON.parse(JSON.stringify(this.record));
         console.log('record fieldChangedChild:', JSON.stringify(this.record));
         console.log('recordLocal fieldChangedChild:', JSON.stringify(this.recordLocal));
    }

    prepareDependantPicklistArray(){
        for(let controllingField in this.objectInfoValue['dependentFields']){
            console.log('prepareDependantPicklistArray controllingField: '+controllingField);
            for(let dependentField in this.objectInfoValue['dependentFields'][controllingField]){
                console.log('prepareDependantPicklistArray dependentField: '+dependentField);
                this.getDependantFieldValues(controllingField, dependentField);
            }
        }
    }

    /**********************************************************************************
    * Method Name : collectTableData
    * Inputs :-
    * Description: This method retrive c-page-layout-section component data and perform table operation 
    ************************************************************************************/
    @api collectTableData(){
        console.log('PageLayout_collectTableData');
        let tableDetails = [];
        this.template.querySelectorAll('c-page-layout-section').forEach((element) => {
            try{
                let tableJsonData =  element.getTableRecords(); 
                if(tableJsonData){
                    tableDetails.push(JSON.parse(JSON.stringify(tableJsonData)));
                }
            }catch (error){
                console.log('PageLayout_collectTableData error : ',error);
            }
        });
        if(tableDetails.length > 0){
            console.log('PageLayout_tableDetails', JSON.parse(JSON.stringify(tableDetails))); 
            return JSON.parse(JSON.stringify(tableDetails));  
        }
        return '';
    }

    getDependantFieldValues(controllingField, dependentField){
        console.log('check existing value: '+ this.dependentFieldValueArray[controllingField]);
        if(this.objectApiNameValue && this.dependentFieldValueArray[controllingField] == undefined){
            this.showLoader = true;
            this.executeAction(getFieldDependencies, {'objectName' : this.objectApiNameValue, 'controllingField': controllingField, 'dependentField': dependentField}, (response) => {
                this.showLoader = false;
                if(this.dependentFieldValueArray[controllingField] == undefined){
                    this.dependentFieldValueArray[controllingField] = [];
            }
                this.dependentFieldValueArray[controllingField][dependentField] = response;
                    console.log('getDependantFieldValues dependentFieldValueArray: ',this.dependentFieldValueArray);
        });
        }
    }

    isControllingField(controllingField){
        if(this.objectInfoValue['dependentFields'] && this.objectInfoValue['dependentFields'][controllingField]){
            return true;
       }
        return false;
    }

    subscribeToMessageChannelForPageField(){
        if(this.pageLayoutDetails['subScribeMessageChannel']){
            this.subscribeToPageTableMessageChannel();
            this.prepareMessageChannelConfigByChannelEventName();
            this.preparePageFieldAndSectionNameMap();
        }
    }

    handleTableMessageChannel(payLoad){
        console.log('------payLoad-----',JSON.stringify(payLoad));
        if(this.messageChannelNameArray[payLoad['eventName']]){
           console.log('eventName found in array');
           let config = this.messageChannelNameArray[payLoad['eventName']];
           /*
           config=
           assignedTo: "Total_Management_Cost_Requested__c"
           sum: [{
           FieldAPIName: "Cost_Estimate_Total__c"
           fieldType: "PageTable"
           operationType: "sum"
           pageFieldDeveloperName: "Pre_Award_Table"}]
           */
           if(config['sum']){//if sum
                this.calculateSum(config);
           }
        }
    }

    prepareMessageChannelConfigByChannelEventName(){
        let channelEventNameJson = {};
        if(this.pageLayoutDetails['pageFields']){
            for(let sectionId in this.pageLayoutDetails['pageFields']){
                for(let pageFieldKey in this.pageLayoutDetails['pageFields'][sectionId]){
                    let pageField = this.pageLayoutDetails['pageFields'][sectionId][pageFieldKey];
                    if(pageField['Enable_Channel_Message__c']){
                        let jsonObj = JSON.parse(pageField['Channel_Event_Config__c']);
                        jsonObj['assignedTo'] = pageField['Field_API_Name__c'];//Used to assigned value
                        channelEventNameJson[pageField['Channel_Event_Name__c']] = jsonObj;
                    }
                }
            }
        }
        this.messageChannelNameArray = channelEventNameJson;
        console.log('===channelEventNameJson===',channelEventNameJson);
    }

    preparePageFieldAndSectionNameMap(){
        for(let key in this.pageLayoutDetails['pageFields']){
            let pageFieldArray = this.pageLayoutDetails['pageFields'][key];
            for(let pageField in pageFieldArray){
                //if(pageField.DeveloperName && pageField.Page_Section__r.DeveloperName){}
                this.pageFieldSectionMap[pageFieldArray[pageField].DeveloperName] = pageFieldArray[pageField].Page_Section__r.DeveloperName;
            }
        }
        console.log('pageFieldSectionMap-----------',JSON.parse(JSON.stringify(this.pageFieldSectionMap)));
    }

    calculateSum(config){
         /*
                   config=
                   assignedTo: "Total_Management_Cost_Requested__c"
                   sum: [{
                   fieldAPIName: "Cost_Estimate_Total__c"
                   fieldType: "PageTable"
                   operationType: "sum"
                   pageFieldDeveloperName: "Pre_Award_Table"}]
                   */
        let sumConfigArray = config['sum'];
        let total = 0;
        for(let key in sumConfigArray){
            /*If Page Table*/
            if(sumConfigArray[key]['fieldType'] == 'PageTable'){
                total = total + this.pageTableCalculation(sumConfigArray[key]);
            }
        }
        this.recordLocal[config['assignedTo']] = total;
    }

    pageTableCalculation(pageTableCalculationConfig){
        /*1) Get Table records
          2) loop over records
          3) calculate sum and return */
        let pageTableSectionName = this.pageFieldSectionMap[pageTableCalculationConfig['pageFieldDeveloperName']];
        let section = this.template.querySelector('[data-section="'+pageTableSectionName+'"]');
        let tableRecords = section.getTableRecordsForCalculation(pageTableCalculationConfig['pageFieldDeveloperName']);
        console.log(pageTableCalculationConfig['pageFieldDeveloperName']+'------',tableRecords.length);
        let sumValue = 0;
        for(let i=0; i<tableRecords.length; i++){
            let recTbl =  JSON.parse(JSON.stringify(tableRecords[i]));
            if(recTbl['isSummaryRow'] == false){
            if(pageTableCalculationConfig['operationType'] == 'sum'){
                let recordFieldValue = parseFloat(recTbl[pageTableCalculationConfig['fieldAPIName']]);//.toFixed(2);
                if( isNaN(recordFieldValue) == false){
                    sumValue = sumValue + recordFieldValue;
                }
            }else if(pageTableCalculationConfig['operationType'] == 'multiplication'){
                let fieldAPINames = pageTableCalculationConfig['fieldAPIName'].split(",");
                let isAllValueFound = true;
                let formula = pageTableCalculationConfig['formula'];
                    for(let indx in fieldAPINames){
                        if(recTbl[fieldAPINames[indx]]){
                            formula = formula.replace(fieldAPINames[indx], recTbl[fieldAPINames[indx]]);
                    }else{
                        isAllValueFound = false;
                    }
                }
                if(isAllValueFound){
                    return eval(formula);
                }else{
                    console.log("all fields not found-------------");
                    }
                }
            }
        }
        return sumValue;
    }

    scrollToTopOfPage() {
        window.scrollTo(0,0);
    }


}