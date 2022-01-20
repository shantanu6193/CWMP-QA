import { api,track,wire } from 'lwc';
import searchAccountRole from '@salesforce/apex/HH_CreateUpdateAccountRoleCtrl.searchAccountRole';
import saveDetails from '@salesforce/apex/HH_CreateUpdateAccountRoleCtrl.saveDetails';
import getDetails from '@salesforce/apex/HH_CreateUpdateAccountRoleCtrl.getDetails';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import Utility from 'c/utility';
import HH_EN_Phone_pattern_validation from '@salesforce/label/c.HH_EN_Phone_pattern_validation';
import HH_EN_Value_must_be_numeric_0_9 from '@salesforce/label/c.HH_EN_Value_must_be_numeric_0_9';
import HH_EN_MissingFieldValueError from '@salesforce/label/c.HH_EN_MissingFieldValueError';
import US_State_Codes__c from '@salesforce/schema/HH_Application__c.US_State_Codes__c'; 
import HHApp_OBJECT from '@salesforce/schema/HH_Application__c';
import HHAccRole_OBJECT from '@salesforce/schema/Account_Role__c';
import accRoleStatus from '@salesforce/schema/Account_Role__c.Status__c';

export default class HhCreateUpdateAccountRole extends Utility {

@api parentRecordId;
@api selectRecordId;
@track disableSave = false;
@track showRequiredError = false;
@track accountRoleDetail={};
@track accountDetail={};
@track showDetails = false;
@track label = {
    HH_EN_Value_must_be_numeric_0_9,
    HH_EN_MissingFieldValueError,
    HH_EN_Phone_pattern_validation
}

@wire(getObjectInfo, { objectApiName: HHAccRole_OBJECT }) hhAccRoleInfo;
@wire(getPicklistValues, {
    recordTypeId: '$hhAccRoleInfo.data.defaultRecordTypeId',
    fieldApiName: accRoleStatus
})
accRoleStatus;
@wire(getObjectInfo, { objectApiName: HHApp_OBJECT }) hhAppInfo;
@wire(getPicklistValues, {
    recordTypeId: '$hhAppInfo.data.defaultRecordTypeId',
    fieldApiName: US_State_Codes__c
})
uSStateCodes;

contractorRequired = [];
loadLookupDataOnLoad =true;
isMultiEntry=false;
drawIndex = 0;
orderChangeIndex = 0;
@track isMailingAddressRequired = false;



initData(){
    this.executeAction(getDetails , {'parentRecordId': this.parentRecordId, 'accountRoleId': this.selectRecordId == undefined ? null:this.selectRecordId},
    (response) => {
        
        console.log('this.accountRoleDetail.CWMP_Application__c--- '+this.accountRoleDetail.CWMP_Application__c);
        console.log('this.accountRoleDetail.CWMP_Project__c--- '+this.accountRoleDetail.CWMP_Project__c);

        this.recordLocal.draws = [];
        this.recordLocal.orderChanges = []; 
        this.isParentProject = response.isParentProject;
        if(response.isEdit && response.isParentProject) {
            this.showDetails = true;
        }
        if(response.isEdit) {
            this.accountRoleDetail = response.accRoleRecord;
            this.accountDetail = response.accRecord;
            this.recordLocal.draws = response.draws;
            this.recordLocal.orderChanges = response.orderChanges;
            if(this.accountRoleDetail.Was_a_draw_requested__c == 'Yes') {
                this.recordLocal.showDrawTable = true;
            }
            if(this.accountRoleDetail.Was_a_change_order_requested__c == 'Yes') {
                this.recordLocal.showChangeOrderTable = true;
            }
            this.massageDrawRecords();
            this.massageOrderChangeRecords();
        }
    },(error)=>{
        if(error.body != undefined && error.body.message != undefined) {
            this.showErrorNotification('',error.body.message);
        } else {
            this.showErrorNotification('',error);
        }
    });     
}

handleAccountRoleSearch(event) {
    console.log('results--1111--22'+event.detail.searchTerm);
    let initailSelection;
    this.executeAction(searchAccountRole , {'searchTerm':event.detail.searchTerm},
    (response) => {
        console.log('results----', response);
        response.forEach(acc => {
            if(this.recordLocal.Account__c != undefined &&
                acc.id == this.recordLocal.Account__c) {
                    initailSelection = acc;
            }
        });
        this.template.querySelector('[data-lookup="Account__c"]').setSearchResults(response);
        if(initailSelection != undefined) {
            this.template.querySelector('[data-lookup="Account__c"]').setSelection(initailSelection);
        }
        
    },(error)=>{
        if(error.body != undefined && error.body.message != undefined) {
            this.showErrorNotification('',error.body.message);
        } else {
            this.showErrorNotification('',error);
        }
    });       
}

    /** This method is for validating the Email field format - Standard was not working properly. */
    validateEmail() {

        let emailFieldCmp = this.template.querySelector('[data-field="Email_Address__c"]');
        let mailRegex =  /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        let emailAddress =  this.accountDetail.Email_Address__c;
        let allValid = true;

        if(emailAddress == null || emailAddress == undefined || emailAddress == '') {
            emailFieldCmp.setCustomValidity(this.label.HH_EN_MissingFieldValueError);
            allValid = false;
        }
        else {
            let mailMatcher = mailRegex.test(emailAddress);
            console.log('mailMatcher --> 291 --> ', mailMatcher);
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

massageDrawRecords (){
    let drawsLength = this.recordLocal.draws.length;
    let defaultRowsToAdd = drawsLength <= 2 ? 2 - drawsLength : 0;
    if(drawsLength > 0) {
        for (let i = 0; i < this.recordLocal.draws.length; i++) {
            const element = this.recordLocal.draws[i]['index'] = 'd'+this.drawIndex;
            this.drawIndex++;
        }
    }
    if(defaultRowsToAdd > 0) {
        for (let i = 0; i < defaultRowsToAdd; i++) {
            let draw = {};
            draw['index'] = 'd'+this.drawIndex;
            draw['Account_Role__c'] = this.selectRecordId;
            this.recordLocal.draws.push(draw);
            this.drawIndex++;
        }
    }  
}

massageOrderChangeRecords (){
    let orderChangeLength = this.recordLocal.orderChanges.length;
    let defaultRowsToAdd = orderChangeLength <= 3 ? 3 - orderChangeLength : 0;
    if(orderChangeLength > 0) {
        for (let i = 0; i < this.recordLocal.orderChanges.length; i++) {
            const element = this.recordLocal.orderChanges[i]['index'] = 'o'+this.orderChangeIndex;
            this.orderChangeIndex++;
        }
    }
    if(defaultRowsToAdd > 0) {
        for (let i = 0; i < defaultRowsToAdd; i++) {
            let orderchange = {};
            orderchange['index'] = 'o'+this.orderChangeIndex;
            orderchange['Account_Role__c'] = this.selectRecordId;
            this.recordLocal.orderChanges.push(orderchange);
            this.orderChangeIndex++;
        }
    }  
}

extractRecords() {
    this.skipInputFieldValidation = false;
    let validated = true;
    for(let i=0; i<this.recordLocal.draws.length; i++) {
        let dataIndex = this.recordLocal.draws[i].index;
        if(this.template.querySelector('[data-id="'+dataIndex+'"]') != null) {
            let drawRec = this.template.querySelector('[data-id="'+dataIndex+'"]').getRecord();
            if(drawRec == undefined) {
                validated = false;
            }
        }
    }
    for(let i=0; i<this.recordLocal.orderChanges.length; i++) {
        let dataIndex = this.recordLocal.orderChanges[i].index;
        if(this.template.querySelector('[data-id="'+dataIndex+'"]') != null) {
            let orderChangeRec = this.template.querySelector('[data-id="'+dataIndex+'"]').getRecord();
            if(orderChangeRec == undefined) {
                validated = false;
            }
        }
    }
    if(validated == false) {
        return validated;
    }
    for(let i=0; i<this.recordLocal.draws.length; i++) {
        let dataIndex = this.recordLocal.draws[i].index;
        if(this.template.querySelector('[data-id="'+dataIndex+'"]') != null) {
            let drawRec = this.template.querySelector('[data-id="'+dataIndex+'"]').getRecord();
            if  (drawRec.Date__c != undefined && drawRec.Amount__c != undefined) {
                this.recordLocal.draws[i] = drawRec;
            }
        } else {
            this.recordLocal.draws = [];
        }
        
    }
    for(let i=0; i<this.recordLocal.orderChanges.length; i++) {
        let dataIndex = this.recordLocal.orderChanges[i].index;
        if(this.template.querySelector('[data-id="'+dataIndex+'"]') != null) {
            let orderChangeRec = this.template.querySelector('[data-id="'+dataIndex+'"]').getRecord();
            this.recordLocal.orderChanges[i] = orderChangeRec;
        } else {
            this.recordLocal.orderChanges = [];
        }
    }
    return true;
}



handleAddDraw() {
    let draw = {};
    draw['index'] = 'd'+this.drawIndex;
    draw['Account_Role__c'] = this.selectRecordId;
    this.recordLocal.draws.push(draw);
    this.drawIndex++;
}

nullCheckValidation(event){
        let checkNullString = event.target.value.trim();
        let contactField = this.template.querySelector('[data-field="'+event.target.getAttribute('data-field')+'"]');
        contactField.setCustomValidity('');
        contactField.reportValidity();
        if(checkNullString.length == 0 && event.target.getAttribute('data-field') != 'BillingStreet') {
            event.target.value = null;
            contactField.setCustomValidity(this.label.HH_EN_MissingFieldValueError);
            contactField.reportValidity();
        }else if(event.target.getAttribute('data-field') == 'BillingStreet'){
            if(checkNullString.length == 0){
                event.target.value = null;
                this.isMailingAddressRequired = false;
            }else{
                this.isMailingAddressRequired = true;
            }
        }
}


handleDeleteDraw(event) {
    let childIndex = event.detail.index;
    if( this.recordLocal.draws.length > 1) {
            this.recordLocal.draws.splice(childIndex, 1);
    }
}

handleAddOrder() {
    let draw = {};
    draw['index'] = 'o'+this.orderChangeIndex;
    draw['Account_Role__c'] = this.selectRecordId;
    this.recordLocal.orderChanges.push(draw);
    this.orderChangeIndex++;
}

handleDeleteOrder(event) {
    let childIndex = event.detail.index;
    if( this.recordLocal.orderChanges.length > 1) {
            this.recordLocal.orderChanges.splice(childIndex, 1);
    }
}

handleContractorChange(response) {
    if(!response.detail){
        console.log('-----------------3333333');
        this.accountDetail = {};
        this.showRequiredError =true;
    }
    if(response.detail != null && response.detail.selectedItem.id != undefined) {
        console.log('----------222222-  '+JSON.stringify(response.detail));
        this.accountDetail['Id'] = response.detail.selectedItem.id;
        this.accountDetail = response.detail.selectedItem.sObject;
        this.showRequiredError =false;
    }
}

fireEventTocloseModal() {
    const cancelEvent = new CustomEvent('closemodal', {
        detail: {
        }
    });
    this.dispatchEvent(cancelEvent);
}

handleAccountRoleDetail(e){
    this.showHideTables(e);
    this.accountRoleDetail[e.target.getAttribute('data-field')] = e.target.value;
    let inputField = this.template.querySelector('[data-field="'+e.target.getAttribute('data-field')+'"]');
    inputField.setCustomValidity('');
    inputField.reportValidity();
}

showHideTables(e) {
    if(e.target.getAttribute('data-field') == 'Was_a_draw_requested__c' && e.target.value == 'Yes') {
        this.recordLocal.showDrawTable = true;
    } else if (e.target.getAttribute('data-field') == 'Was_a_draw_requested__c' && e.target.value == 'No') {
        this.recordLocal.showDrawTable = false;
    }
    if(e.target.getAttribute('data-field') == 'Was_a_change_order_requested__c' && e.target.value == 'Yes') {
        this.recordLocal.showChangeOrderTable = true;
    } else if (e.target.getAttribute('data-field') == 'Was_a_change_order_requested__c' && e.target.value == 'No') {
        this.recordLocal.showChangeOrderTable = false;
    }
}

handleAccountDetail(e){
    this.accountDetail[e.target.getAttribute('data-field')] = e.target.value;
    let inputField = this.template.querySelector('[data-field="'+e.target.getAttribute('data-field')+'"]');
    inputField.setCustomValidity('');
    inputField.reportValidity();
    if(e.target.getAttribute('data-field') == 'BillingStreet'){
           if(e.target.value){
                this.isMailingAddressRequired = true;
           } else{
                this.isMailingAddressRequired = false;
           }
    }
}

handleClear(e){
        this.accountDetail = {};
        this.accountRoleDetail = {};
        this.template.querySelector('[data-lookup="Account__c"]').handleClearSelection();
}

get yesNoValues() {
    return [
        {label:'Yes', value:'Yes'},
        {label:'No', value:'No'},
    ];
}

getData() {
    let drawToSave = [];
    let changeOrderToSave = [];
    if(this.validateInputs() && this.extractRecords()) {
        for (let i = 0; i < this.recordLocal.draws.length; i++) {
            let draw =  Object.assign({}, this.recordLocal.draws[i]);
            delete draw['index'];
            if(draw.Date__c != undefined && draw.Amount__c != undefined) {
                drawToSave.push(draw);  
            }
        }
        for (let i = 0; i < this.recordLocal.orderChanges.length; i++) {
            let changeOrder = Object.assign({}, this.recordLocal.orderChanges[i]);
            delete changeOrder['index'];
            if(changeOrder.Has_Homeowner_provided_check_payment__c != undefined &&
                changeOrder.Homeowner_check_payment_amount__c != undefined) {
                    changeOrderToSave.push(changeOrder);
            }
        }
    } else {
        return false;
    }
    this.accountRoleDetail['Draws__r'] = drawToSave;
    if(drawToSave && !drawToSave.records) {
        this.accountRoleDetail['Draws__r']= {
            totalSize: drawToSave.length,
            done: true,
            records: drawToSave
        };
    }
    this.accountRoleDetail['Order_changes__r'] = changeOrderToSave;
    if(changeOrderToSave && !changeOrderToSave.records) {
        this.accountRoleDetail['Order_changes__r']= {
            totalSize: changeOrderToSave.length,
            done: true,
            records: changeOrderToSave
        };
    }
    return true;
}

handleSave(){
    this.disableSave = true;
    if(this.getData()){
        this.executeAction(saveDetails , {'parentRecordId':this.parentRecordId,'accountRoleDetail':JSON.stringify(this.accountRoleDetail),'accountDetail':JSON.stringify(this.accountDetail)},
        (response) => {
            console.log('results----', response);
            if(!this.isEdit){
            this.showSuccessNotification('Success','Record created successfully !');
            }else{
                this.showSuccessNotification('Success','Record updated successfully !');
            }
            this.fireEventTocloseModal();
        },(error)=>{
            if(error.body != undefined && error.body.message != undefined) {
                this.showErrorNotification('',error.body.message);
            } else {
                this.showErrorNotification('Error',error);
                this.disableSave = false;
            }
        });    
    }else{
        this.disableSave = false;
        this.showErrorNotification('','Please fill all required fields');
    }   
}



get isEdit(){
    if(this.selectRecordId !=null){
        return true;
    }else{
        return false;
    }
}
}