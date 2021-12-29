/**
 * Created by harsh on 05-03-2021.
 */

import { LightningElement, track, api ,wire} from 'lwc';
import Utility from 'c/utility';
import { getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
//import { refreshApex } from '@salesforce/apex';
export default class PageTableCell extends Utility {

    @api tableRow;
    @api column;
    @api tableObjectName;
    @api index;
    @api fieldsMeta;
    @api fieldMetaAdditionalConfig;
    @api userHideShowActionsAccess;
    @api loggedInUserDetails;

    @track actionList = [];
    @track picklistValues = {};
    @track picklistField = false;
    @track calculateFormulaForAutoPopulateField;
    @track maxValueMismatchErrorMsg;
    @track checkboxVal = false;

    initData(){
        
        /*console.log('*********************** ',this.column.fieldName ,'- ROW(', this.index, ') ***********************');
        console.log('cell__column : ',JSON.parse(JSON.stringify(this.column)));
        console.log('cell__fieldsMeta: ',JSON.parse(JSON.stringify(this.fieldsMeta)));
        console.log('cell__tableRow: ',JSON.parse(JSON.stringify(this.tableRow)));        
        console.log('cell__tableObjectName: ',this.tableObjectName);
        console.log('cell__fieldMetaAdditionalConfig: ',JSON.parse(JSON.stringify(this.fieldMetaAdditionalConfig)));*/
        if(this.column.label == "Action") {
            this.actionList = this.column.actionList.split(','); 
            //console.log('ActionList - ', this.actionList);
        }
    }

    renderedCallback() {
        try{
            for(const key in this.fieldsMeta) {
                //give value to checkbox
                if(this.fieldsMeta[key].dataType == 'Boolean' && this.column.fieldName == key) {
                    if(this.tableRow[key]) {
                        this.template.querySelector('[data-field="'+key+'"]').checked = this.tableRow[key];
                    } else {
                        this.template.querySelector('[data-field="'+key+'"]').checked = false;
                    }
                }
            }
        } catch(e) {
            console.log(e);
        }    
    }

    get fieldValue(){
        if(this.column.formula) {
            return this.getValueDependOnFormula();
        }
        if(this.tableRow && this.column.fieldName){
            if(this.column.fieldName.includes('__r')){
                return this.getRelatedFieldValues();
            }
            return this.tableRow[this.column.fieldName];
        }
    }
    get isFieldValue() {
        if(!this.isCurrencyField && !this.isNumberField) return true;
        return false;
    }
    get maxFieldVal() {
        /* Sample JSON JSON format for below get method
            	"maxValue": [{
            		"tableColumnAPI": "Cost_Estimate_Total__c",
            		"type": "dynamic",
            		"fieldApiName": "Maximum_Eligible_Management_Cost__c",
            		"ErrorMessage": "This line item causes the total Management Cost Requested to exceed the Maximum Management Cost Allowed. You cannot request more than the Maximum Management Cost Allowed"
            	}],
            */
        let additionalConfig = JSON.parse(JSON.stringify(this.fieldMetaAdditionalConfig));
        let currentCol = JSON.parse(JSON.stringify(this.column));
        if(additionalConfig && additionalConfig.maxValue) {
            for(let i=0; i<additionalConfig.maxValue.length; i++) {
                if(currentCol.fieldName == additionalConfig.maxValue[i].tableColumnAPI) {
                    return this.getMaxValue(currentCol, additionalConfig.maxValue[i]);
                }
            }
        }
    }
    get fieldMaxLength() {
        return this.fieldsMeta[this.column.fieldName].length;
    }
    getMaxValue(currentCol, maxValueConfig) {
        this.maxValueMismatchErrorMsg = maxValueConfig.ErrorMessage;
        if(maxValueConfig.type == 'dynamic') {
            return parseInt(this.record[maxValueConfig.fieldApiName]);
        } 
        if(maxValueConfig.type == 'static') {
            return parseInt(maxValueConfig.staticValue);
        }
    }

    get getCheckboxFieldValue() {
        let checkboxField = JSON.parse(JSON.stringify(this.column));
        let tableRowDetail = JSON.parse(JSON.stringify(this.tableRow));
        console.log('columnss--', this.column, this.tableRow, checkboxField, tableRowDetail);
        for(const key in tableRowDetail) {
            console.log('key in checkbox--', key, checkboxField.fieldName);
            if(checkboxField.fieldName == key) {
                this.checkboxVal = tableRowDetail[key];
                console.log('checkbox val---', this.checkboxVal, tableRowDetail[key]);
                return this.checkboxVal;
            }
    }
        return this.checkboxVal;
    }
    get isEditMode() {
        if(this.tableRow.isEdit == true) return true;
        return false;
    }
    get showEditICON() {
        if(this.actionList && (this.actionList.includes('Edit') || this.actionList.includes('edit')) && this.column.label == "Action"  && !this.tableRow.isEdit) {
            return true;
        }
        return false; 
    }
    get showDeleteICON() {
        if(this.actionList && (this.actionList.includes('Delete') || this.actionList.includes('delete')) && this.column.label == "Action" && this.tableRow['isSummaryRow'] == false) {
            return true;
    }
        return false;
    }
    get isSendForSignatureButtonDisabled() {
        if(!this.userHideShowActionsAccess['isSendForSignatureAvailable']) return true;
        return false;
    }
        
    getValueDependOnFormula() {
        let formulaFields = [];
        if(this.column.formula.includes('*')) {
            formulaFields = this.column.formula.split('*');
            return parseInt(this.tableRow[formulaFields[0]]) * this.tableRow[formulaFields[1]];
    }
        return '';
        }
    getRelatedFieldValues(){
        let apiNameArray = this.column.fieldName.split('.');
        if(this.tableRow[apiNameArray[0]]) {
        return this.tableRow[apiNameArray[0]][apiNameArray[1]];
        } else {
            return '';
        }
        //return this.tableRow[apiNameArray[0]][apiNameArray[1]];
    }

    @wire(getPicklistValuesByRecordType, { 
            objectApiName:'$tableObjectName',
            recordTypeId: '$objectInfo.data.defaultRecordTypeId'
        })
        picklistFields({data,error}) {
            if(data) {
                if(this.getFieldDataType && this.getFieldDataType == 'Picklist') {
                    if(this.fieldMetaAdditionalConfig['summaryRow'] && this.fieldMetaAdditionalConfig['summaryRowType'] == 'static' && this.column['summaryValue'] == 'Closeout') {
                        this.processOnPicklistValues(data.picklistFieldValues[this.column.fieldName].values);
                    } else{
                        this.picklistValues = data.picklistFieldValues[this.column.fieldName].values;
                    }
                }
            }   
            else if(error){
                console.log('picklistValues_Error', error);
            }
        }

     @wire(getObjectInfo, {objectApiName: '$tableObjectName' })
    objectInfo 
    
    processOnPicklistValues(values) {
        let finalPicklist = [];
        for(let i=0; i< values.length; i++) {
            if(this.column['summaryValue'] != values[i].value) {
                finalPicklist.push(values[i]);
            }
        }
        this.picklistValues = finalPicklist;
    }

    handleTableCellFieldChange(event){
        let fieldJson = {apiName: this.column.fieldName, apiValue: event.target.value, index:this.index};
        console.log('Event_fieldJson : ', fieldJson); 
        this.fireTableCellFieldChangedEvent(fieldJson); 
    }
        
    handleTableCellCheckboxChange(event) {
        let fieldJson = {apiName: this.column.fieldName, apiValue: event.target.checked, index:this.index};
        console.log('Event_fieldJson checkbox: ', fieldJson); 
        this.template.querySelector('[data-field="Pre_Award_Cost__c"').checked = event.target.checked;
        //this.checkboxVal = event.target.checked;
        this.fireTableCellFieldChangedEvent(fieldJson); 
    }

    fireTableCellFieldChangedEvent(fieldJson){
        const tableFieldChanged = new CustomEvent('tablefieldchanged', {
            detail: fieldJson
        });
        this.dispatchEvent(tableFieldChanged);
    }
    handleEditTableRow(event) {
        console.log('Edit_accessKey - ', event.target.accessKey);
        const editTableRowEvent = new CustomEvent('edittablerow', {
            detail: event.target.accessKey
        });
        this.dispatchEvent(editTableRowEvent);
    }
    handleDeleteTableRow(event) {
        console.log('Delete_accessKey - ', event.target.accessKey);
        const deleteTableRowEvent = new CustomEvent('deletetablerow', {
            detail: event.target.accessKey
        });
        this.dispatchEvent(deleteTableRowEvent);
    }
    @api tableValidation(){
        let pageTableRecordValid = true;    
        this.template.querySelectorAll(".input").forEach(element => {
            let test =element.reportValidity();
            console.log('validation test1',test); 
           if(!element.reportValidity()){
            pageTableRecordValid = false; 
            }
        });
        console.log('validation test.....',pageTableRecordValid);
        return pageTableRecordValid; 
    }

    /************* Check Field Type ********/
    get isTextField(){
        if(this.getFieldDataType && this.getFieldDataType == 'String'){ return true;}
        return false;
    }

    get isEmailField(){
        if(this.getFieldDataType && this.getFieldDataType == 'Email'){ return true;}
        return false;
    }

    get isPicklistField(){
         if(this.getFieldDataType && this.getFieldDataType == 'Picklist'){         
            return true;
        }
        return false; 
    }

    get isNumberField(){
        if(this.getFieldDataType && this.getFieldDataType == 'Double'){ return true;}
        return false;
    }

    get isCurrencyField(){
        if(this.getFieldDataType && this.getFieldDataType == 'Currency'){ return true;}
        return false;
    }

    get isTextAreaField(){
    if(this.getFieldDataType && this.getFieldDataType == 'TextArea'){ return true;}
        return false;
    }
    get isCheckboxField(){
        if(this.getFieldDataType && this.getFieldDataType == 'Boolean'){ return true;}
        return false;
    }

    get getFieldDataType(){ 

        if(this.fieldsMeta && this.column.fieldName && this.fieldsMeta[this.column.fieldName] && this.fieldsMeta[this.column.fieldName]['dataType']){
            return this.fieldsMeta[this.column.fieldName]['dataType'];
        }
        return '';
    }

    //****TODO: Need to Delete these hardcoded methods */
    get isSignatureStatusIsDraft() {
        if(this.fieldMetaAdditionalConfig.isDocuSignEnabled && this.actionList.includes('Send for Signature') && this.column.label == "Action" && this.tableRow['Signature_Status__c'] == 'Draft') {
            return true;
        }
        return false;
    }
    get showSendForSignatureButton() {
        if(this.actionList && this.actionList.includes('Send for Signature') && this.column.label == "Action" && this.tableRow['Signature_Status__c'] == 'Draft') {
            return true;
        }
        return false;
    }
    handleSendForSignatureClick() {
        console.log('this.tableRow : ', this.tableRow.Id);
        const sendForSignatureClickEvent = new CustomEvent('sendforsignatureclick', {
            detail: this.tableRow.Id
        });
        this.dispatchEvent(sendForSignatureClickEvent);        
    }

    get isClickable(){
        if(this.column && this.column.clickable && this.column.clickableForRole){
            let clickableForRole = this.column.clickableForRole.split(",");
            if(clickableForRole.includes(this.loggedInUserDetails['UserRole']['Name'])){
                return true;
            }
        }
        return false;
    }

    columnClick(event){
        event.preventDefault();
        event.stopPropagation();
        const columnClick = new CustomEvent('tablecellevent', {
            detail: {'type':'columnClick', 'columnDetails':this.column, 'rowIndex': this.index}
        });
        this.dispatchEvent(columnClick);
    }


}