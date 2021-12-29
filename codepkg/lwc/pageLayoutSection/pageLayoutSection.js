/**
 * Created by harsh on 27-01-2021.
 */

import { LightningElement, api, track } from 'lwc';
import Utility from 'c/utility';

export default class PageLayoutSection extends Utility {
    @api pageObjectInfo;
    @api objectDefaultRecordTypeId;
    @api pageSection;
    @api pageFields;
    @api relatedChildObjectDetails;
    @api fieldChanged = false;
    @api isAllFieldsReadOnly;
    @api hideFieldCustomAttribute;
    @api recordId;
    @api programTemplatePageId;
    @api pageLayoutId;
    @api loggedInUserDetails;

    initData(){
        //console.log('Test----',JSON.stringify(this.relatedChildObjectDetails));
        //console.log('Page Section Init Data -',JSON.parse(JSON.stringify(this.record)));
    }

    @api refreshPageField() {
        this.template.querySelectorAll("c-page-field").forEach((element) => {
            element.refreshPageTable();
        });
    }

    get pageFieldsLocal(){
        let temp = JSON.parse(JSON.stringify(this.pageFields[this.pageSection.Id]));
        //console.log('default record Type: ',this.pageObjectInfo.defaultRecordTypeId);
        for(let key in temp){
            temp[key]['columnSizeDef'] = this.getColumnSize(temp[key]);
            temp[key]['isPicklist'] = false;
            if(temp[key]['Field_Type__c'] == 'Picklist' || temp[key]['Field_Type__c'] == 'Multiselect'){
                temp[key]['isPicklist'] = true;
                temp[key]['picklistMetaInfo'] = {fieldApiName: temp[key]['Field_API_Name__c'], objectApiName: this.pageObjectInfo.apiName};
                temp[key]['defaultRecordTypeId'] = this.pageObjectInfo.defaultRecordTypeId;

                if(temp[key]['Field_API_Name__c'].includes('__r.')){
                    console.log('relational field exist: '+temp[key]['Field_API_Name__c']);
                    if(temp[key]['Related_To_Object_Name__c']){
                        let res = temp[key]['Field_API_Name__c'].split(".");
                        //let objectInfo = this.getRelationalFieldMetaInfo(res[0]);
                        temp[key]['picklistMetaInfo'] = {fieldApiName: res[1], objectApiName: temp[key]['Related_To_Object_Name__c']};
                        temp[key]['defaultRecordTypeId'] = this.relatedChildObjectDetails[temp[key]['Related_To_Object_Name__c']];
                        console.log('__r record type Id: ',temp[key]['defaultRecordTypeId']);
                    }
                }
            }
            /*For Latitude and Longitude fields which ends with __s*/ 
            if(temp[key]['Field_API_Name__c'] && temp[key]['Field_API_Name__c'].includes('__s') && this.pageObjectInfo && this.pageObjectInfo['fields']){
                 temp[key]['compoundComponentName'] = this.pageObjectInfo['fields'][temp[key]['Field_API_Name__c']]['compoundComponentName'];
            }
            temp[key]['isFieldHidden'] = this.isFieldHidden(temp[key]);
        }
        return temp;
    }

    getColumnSize(temp) {
        if(temp.Column_Size__c == 1) {
            return 'slds-col slds-large-size_12-of-12 slds-medium-size_12-of-12 slds-size_12-of-12  slds-p-vertical_medium';
        } else if(temp.Column_Size__c == 2) {
            return 'slds-col slds-large-size_6-of-12 slds-medium-size_6-of-12 slds-size_12-of-12  slds-p-vertical_medium';
        } else {
            return 'slds-col slds-large-size_6-of-12 slds-medium-size_6-of-12 slds-size_12-of-12  slds-p-vertical_medium';
        }
    }
    isFieldHidden(pageField){
        //console.log('record value: '+this.record[pageField.Hide_Field_API_Name__c]);
        /*console.log('record pageField Hide_Field_API_Name__c: '+pageField.Hide_Field_API_Name__c);
        console.log('record pageField Hide_Field_Value__c: '+pageField.Hide_Field_Value__c);
        console.log('record pageField Hide_Field_Operator__c: '+pageField.Hide_Field_Operator__c);*/
        let returnFlag = false;
        if(pageField.Hide_Field_Operator__c && pageField.Hide_Field_API_Name__c && pageField.Hide_Field_Value__c){
            let valueArray = pageField.Hide_Field_Value__c.split(",");
            let recordFieldValue = String(this.record[pageField.Hide_Field_API_Name__c]);

            if(this.record[pageField.Hide_Field_API_Name__c] && recordFieldValue.includes(";")){
                /*Checking for multiselect field*/
                let multiselectArrayValue = recordFieldValue.split(";");
                if(pageField.Hide_Field_Operator__c == 'Equal'){
                    return valueArray.some(item => multiselectArrayValue.includes(item));
                }else if(pageField.Hide_Field_Operator__c == 'Not Equal'){
                    return valueArray.some(item => !multiselectArrayValue.includes(item));
                }
                return true;

            }else if(pageField.Hide_Field_Operator__c == 'Equal' && valueArray.includes(String(this.record[pageField.Hide_Field_API_Name__c]))){
                returnFlag = true;
            }else if(pageField.Hide_Field_Operator__c == 'Not Equal' && !valueArray.includes(String(this.record[pageField.Hide_Field_API_Name__c]))){
                returnFlag = true;
            }else if(!this.record[pageField.Hide_Field_API_Name__c]){
                returnFlag = true;
            }
        }
        if(pageField.Hide_Field_Custom_Attribute__c && this.hideFieldCustomAttribute){
            let hideFieldCustomAttributeObj = JSON.parse(JSON.stringify(this.hideFieldCustomAttribute));
            let customAttributeMeta = JSON.parse(pageField.Hide_Field_Custom_Attribute__c);
            console.log('11-----', hideFieldCustomAttributeObj[customAttributeMeta.AttributeKey]);
            if(hideFieldCustomAttributeObj[customAttributeMeta.AttributeKey]) {
                let currentUserRole = hideFieldCustomAttributeObj[customAttributeMeta.AttributeKey].split(',');
                let metaAttributeRoles = customAttributeMeta.AttributeValue.split(',');
                console.log('metaAttributeRoles-----', metaAttributeRoles);
                if(customAttributeMeta.operation == 'NotIN') {
                    returnFlag = true;
                }
                for(let i=0; i< metaAttributeRoles.length; i++) {
                    console.log('operation-----', customAttributeMeta.operation);
                    console.log(i, '--------------', currentUserRole.includes(metaAttributeRoles[i]));
                    if(customAttributeMeta.operation == 'IN'  && currentUserRole.includes(metaAttributeRoles[i])) {
                        return true;
                    } else if(customAttributeMeta.operation == 'NotIN' && currentUserRole.includes(metaAttributeRoles[i])) {
                        returnFlag = false;
                    } 
                }
                
                console.log('returnFlag-----', returnFlag);
            }
        }
        return returnFlag;
    }

    fieldChangedChild(event){
        //console.log('page section event detail:', event.detail);
        const fieldChangedEvent = new CustomEvent('fieldchanged', {
            detail: event.detail,
        });
        this.dispatchEvent(fieldChangedEvent);
    }

    validatePageFields() {
        let isValid = true;
       // let isValidField;
        this.template
              .querySelectorAll('[data-custom="innerComponent"]')
              .forEach(element => {
                  let isFieldValid = element.validateInputs();
                  let isValidField = element.tableValidation();
                  console.log('isValidField test : ',isValidField);
                  
                  if(isFieldValid == false || isValidField == false){
                      isValid = false;
                  }
              });  
        console.log('isValid: ',isValid);
        return isValid;
    }

    @api
    validateSection(){
        return this.validatePageFields();
    }

    /**********************************************************************************
    * Method Name : pageLayoutSessionTableSave
    * Inputs :-
    * Description: This method retrive c-page-field component data and it store in array 
    ************************************************************************************/
     @api getTableRecords(){
        let tableJsonArray = [];
        this.template.querySelectorAll('c-page-field').forEach((element) => {
            let tableJsonData = element.getTableDataPageField();
            
            if(tableJsonData){
                tableJsonArray.push(JSON.parse(JSON.stringify(tableJsonData)));
            }
        });
       if(tableJsonArray.length > 0) {
            console.log('PageSection_tableJsonArray', tableJsonArray); 
            return tableJsonArray; 
        }
        return '';
    }

    @api
    getTableRecordsForCalculation(pageFieldDeveloperName){
        let pageField = this.template.querySelector('[data-field="'+pageFieldDeveloperName+'"]');
        return pageField.getTableRecordList();
    }

}