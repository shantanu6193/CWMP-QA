/**
 * Created by harsh on 28-01-2021.
 */

import { LightningElement, api, track, wire } from 'lwc';
import Utility from 'c/utility';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import search from '@salesforce/apex/PageLayoutCtrl.search';
import getListofTable from '@salesforce/apex/PageLayoutCtrl.getListofTable';
import { publish, MessageContext} from 'lightning/messageService';
import documentUploadMessageChannel from '@salesforce/messageChannel/HMGPDocumentUploadMessageChannel__c';

export default class PageField extends Utility {
    @api objectDefaultRecordTypeId;
    @api pageFieldDetails;
    @api fieldApiNameValue;
    @api picklistMetaInfo;
    @api allPageFields;
    @api documentTypesExcluded;
    @api fieldChanged = false;
    @api isAllFieldsReadOnly;
    @api recordId;
    @api programTemplatePageId;
    @api pageLayoutId;
    @api loggedInUserDetails;

    @track pageFieldLocal = {};
    @track picklistValues = {};
    @track multiSelect = [];
    @track dualListSelectedValues = [];
    @track isMultiEntry = false;
    @track loadLookupDataOnLoad = true;
    @track lookupSelection = [];
    @track lookupErrors = [];
    @track lookupSearchLocalArray = [];
    @track calculatedFieldLength = 0;
    @track picklistSelectedValues;
    @track isEventInProgress = false;
    @track multiTableList = [];
    @track minValueMismatchErrorMsg;
    @track maxValueMismatchErrorMsg;

    @track parseDocumentTableColumns = [];
    @track parseDocumentTableDocumentTypes = [];

    @wire(getPicklistValues, { recordTypeId: '$objectDefaultRecordTypeId', fieldApiName: '$picklistMetaInfo'})
    picklistWire({error, data}){
        console.log('objectDefaultRecordTypeId: '+this.objectDefaultRecordTypeId);
        console.log('picklistMetaInfo: ',this.picklistMetaInfo);
        if(data){
            this.picklistValues = data;
            console.log('picklistValues response: ',data);
        }else if(error){
            console.log('picklistValues error: ',error);
        }
    }

    @wire(MessageContext)
    messageContext;

    initData(){
        if(this.pageFieldDetails){
            this.pageFieldLocal = JSON.parse(JSON.stringify(this.pageFieldDetails));
            //this.recordLocal[this.pageFieldLocal.Field_API_Name__c] = 'test data'; //temp added will change later
        }
        this.prepareMultiSelectedValues();
        this.prepareForTextAreaFieldLength();
        this.prepareForLatitude();
        //Prepare multiple table query for displaying list of table
        this.prepareListOfTable();
        if(this.pageFieldLocal.Field_Type__c == 'Document upload table'){
            this.findDocumentTypeForFilter();
        }
    }
        
    @api refreshPageTable() {
        //this.template.querySelector("c-page-table").getTableObjectDetails();
       this.template.querySelectorAll('c-page-table').forEach((element) => {
           element.getTableObjectDetails();
       });
    }

    findDocumentTypeForFilter(){
        let documentTypesExcluded = [];
        for(let key in this.allPageFields){
            let pageFieldPicklist = this.allPageFields[key];
            for(let pageFieldKey in pageFieldPicklist){
                let pageField = pageFieldPicklist[pageFieldKey];
                if(pageField && pageField.Field_Type__c == 'Picklist' && pageField.Enable_Field_Specific_Doc__c){
                    if(this.record[pageField.Field_API_Name__c] == pageField.Field_Criteria_value__c){
                        //do nothing
                    }else{
                        if(pageField.Field_Specific_Value__c){
                            let arr = pageField.Field_Specific_Value__c.split(",");
                            documentTypesExcluded.push(...arr);
                        }
                    }
                }
            }
        }
        this.documentTypesExcluded = documentTypesExcluded;
    }

    fieldChangedEvent(event){
        if(this.pageFieldLocal && this.pageFieldLocal.Field_Type__c == 'Text Area') {
        this.calculatedFieldLength = event.target.value.length;
        }        
        let fieldJson = {apiName: this.pageFieldLocal.Field_API_Name__c, apiValue: event.target.value};
        if(this.isCheckboxField){
            fieldJson['apiValue'] = event.target.checked;
        }else if(this.isMultiselectField){
            this.selectedValues = '';
            for(let key in event.detail.value) {
                this.selectedValues += event.detail.value[key]+";";
            }
            fieldJson['apiValue'] = this.selectedValues;
        }else if(this.isPicklistField){
            this.isPicklistDocumentSpecifiedEnabled(event.target.value);
        }

        this.fireFieldChangeEvent(fieldJson);
        //TODO: check field type
        if(this.pageFieldLocal.Enable_Field_Formula__c){
            this.recordLocal[this.pageFieldLocal.Field_API_Name__c] = event.target.value;
            this.evaluateFormula();
        }
    }

    isPicklistDocumentSpecifiedEnabled(fieldValue){
        if(this.pageFieldLocal.Enable_Field_Specific_Doc__c){
            /*Check is Enable Field Specific Doc if yes then publish message*/
             if(this.pageFieldLocal.Field_Criteria_value__c == fieldValue){
                const payload = { DocumentTypes: this.pageFieldLocal.Field_Specific_Value__c, action: "add" };
                publish(this.messageContext, documentUploadMessageChannel, payload);
            }else{
                const payload = { DocumentTypes: this.pageFieldLocal.Field_Specific_Value__c, action: "remove" };
                publish(this.messageContext, documentUploadMessageChannel, payload);
            }
       }
    }

    /*Formula field calculation*/
    evaluateFormula(){
        let formulaArray = JSON.parse(this.pageFieldLocal.Field_Formula_Configuration__c);
        if(formulaArray && formulaArray.length > 0){
            for(var i=0; i<formulaArray.length; i++){
               let formulaDetails = JSON.parse(JSON.stringify(formulaArray[i]));
               let fieldArray = formulaDetails['fields'].split(',');
               let formula = String(formulaDetails['formula']);
               for(var x=0; x < fieldArray.length; x++){
                   if(this.recordLocal[fieldArray[x]]){
                     if(formula.includes(fieldArray[x])){
                        formula = formula.replace(String(fieldArray[x]), this.recordLocal[fieldArray[x]]);	///change to dynamic use this.recordLocal
                     }
                   }
               }
               //Evaluate formula
               let formulaValue = eval(formula);
               this.recordLocal[formulaDetails['valueAssignTo']] = formulaValue;
               let fieldJson = {apiName: formulaDetails['valueAssignTo'], apiValue: formulaValue};
                this.fireFieldChangeEvent(fieldJson);
            }
        }
    }

    fireFieldChangeEvent(fieldJson){
        const fieldChangedEvent = new CustomEvent('fieldchanged', {
            detail: fieldJson
        });
        this.dispatchEvent(fieldChangedEvent);
    }
    get isReadOnly() {
        if(this.isAllFieldsReadOnly) return true;
        return this.pageFieldLocal.Is_Read_Only__c;
    }
    get isPageFieldLoaded(){
        return !(Object.keys(this.pageFieldLocal).length === 0 && this.pageFieldLocal.constructor === Object);
    }
    get fieldHelpText() {
        if(this.isPageFieldLoaded && this.pageFieldLocal.Help_Text__c) return true;
        return false;
    }

    get fieldPlaceholder() {
        if(this.isPageFieldLoaded && this.pageFieldLocal && this.pageFieldLocal.Placeholder__c) {
            return this.pageFieldLocal.Placeholder__c;
        }
        return '';
    }
    get fieldValidationPattern() {
        if(this.isPageFieldLoaded && this.pageFieldLocal && this.pageFieldLocal.Validation_Pattern__c) {
            return this.pageFieldLocal.Validation_Pattern__c;
        }
        return '[^]*'; // Default pattern for No pattern limitations
    }
    get fieldPatternErrorMessage() {
        if(this.isPageFieldLoaded && this.pageFieldLocal && this.pageFieldLocal.Validation_Error_Message__c) {
            return this.pageFieldLocal.Validation_Error_Message__c;
        }
        return 'Your entry does not match the allowed pattern.';
    }
    get fieldMaxLength() {
        
        if(this.isPageFieldLoaded && this.pageFieldLocal && this.pageFieldLocal.Max_Length__c) {
            return this.pageFieldLocal.Max_Length__c;
        }
        return 255;
    }

    get getFieldApiValue(){
        if(this.isPageFieldLoaded && this.pageFieldLocal.Field_API_Name__c){
            console.log('field recordLocal: ',JSON.parse(JSON.stringify(this.recordLocal)));
            console.log('field pageFieldLocal: ',this.pageFieldLocal.Field_API_Name__c);
            console.log('field value: ',this.recordLocal[this.pageFieldLocal.Field_API_Name__c]);

            if(this.pageFieldLocal.Field_API_Name__c.includes('__r')){
                let res = this.pageFieldLocal.Field_API_Name__c.split(".");
                if(res.length == 2 && this.recordLocal[res[0]] && this.recordLocal[res[0]][res[1]]){
                    return this.recordLocal[res[0]][res[1]];
                }else if(res.length == 3 && this.recordLocal[res[0]]){
                    let grandParentRecord = this.recordLocal[res[0]];
                    if(grandParentRecord[res[1]] && grandParentRecord[res[1]][res[2]]){
                         return grandParentRecord[res[1]][res[2]];
                    }
                }
                return '';
            }
            /*added below line to reflect formula calculated value changes  */
            this.recordLocal[this.pageFieldLocal.Field_API_Name__c] = this.record[this.pageFieldLocal.Field_API_Name__c];
            if(this.recordLocal[this.pageFieldLocal.Field_API_Name__c] && (this.isLatitudeField || this.isLongitudeField)){
                this.recordLocal[this.pageFieldLocal.Field_API_Name__c] = this.record[this.pageFieldLocal.Field_API_Name__c];
                let value = Number(this.recordLocal[this.pageFieldLocal.Field_API_Name__c]);
                    value = value.toFixed(6);
                    if(this.isLongitudeField){
                       var checkSymbol = value.charAt(value[0]);
                       if(checkSymbol != '-') {
                           value = '-' + value;
                       }
                    }else if(this.isLatitudeField){
                       var checkSymbol = value.charAt(value[0]);
                       if(checkSymbol != '+') {
                           value = '+' + value;
                       }
                    }
                    return value;
            }
            return this.recordLocal[this.pageFieldLocal.Field_API_Name__c];
        }else{
            return ''
        }
    }

    /*Picklist field related methods */
    get isPicklistField(){
        if(this.isPageFieldLoaded && this.pageFieldLocal.Field_Type__c == 'Picklist'){
            return true;
        }
        return false;
    }

	 get picklistOptions(){
	        if(this.isPageFieldLoaded && this.picklistValues && this.picklistValues.values && this.pageFieldLocal && this.pageFieldLocal.Controller_Field__c){
	            let updatedValues = [];
	            let key = this.picklistValues.controllerValues[this.record[this.pageFieldLocal.Controller_Field__c]];
	            updatedValues = this.picklistValues.values.filter(opt => opt.validFor.includes(key));
	            if(updatedValues){
                console.log('picklistOptions updatedValues size: '+updatedValues.length);
                if(updatedValues != undefined && updatedValues.length == 1){//If picklist having only value then set as default value
                    this.recordLocal[this.pageFieldLocal.Field_API_Name__c] = updatedValues[0].value;
                }
	                return updatedValues;
	            }
	        }
	        return this.picklistValues.values;
    }

    @api
    populateDependentValue() {
        if(this.isPageFieldLoaded && this.picklistValues && this.picklistValues.values && this.pageFieldLocal && this.pageFieldLocal.Controller_Field__c) {
            let updatedValues = [];
            let key = this.picklistValues.controllerValues[this.record[this.pageFieldLocal.Controller_Field__c]];
            updatedValues = this.picklistValues.values.filter(opt => opt.validFor.includes(key));
            let fieldJson = {apiName: this.pageFieldLocal.Field_API_Name__c, apiValue: updatedValues[0].value};
            this.fireFieldChangeEvent(fieldJson);
        }
    }

    get isControlledFieldValueChanged(){
        if(this.pageFieldLocal && this.pageFieldLocal.Controller_Field__c && this.recordLocal[this.pageFieldLocal.Controller_Field__c]) {
            return true;
        }
        return false;
    }

    /*User Defined Picklist field related methods */
    get isUserDefinedPicklistField(){
        if(this.isPageFieldLoaded && this.pageFieldLocal.Field_Type__c == 'User Defined Picklist'){
            return true;
        }
        return false;
    }

    get isUserDefinedPicklistOptionsLoaded(){
        return this.userDefinedPicklistOptions.length > 0 ? true : false;
    }

    get userDefinedPicklistOptions(){
        if(this.isPageFieldLoaded && this.pageFieldLocal && this.pageFieldLocal.User_Defined_Picklist_Values__c){
            return JSON.parse(this.pageFieldLocal.User_Defined_Picklist_Values__c);
        }
        return [];
    }

    /*Latitude field related methods */
    get isLatitudeField(){
        if(this.isPageFieldLoaded && this.pageFieldLocal.Field_Type__c == 'Latitude'){
            return true;
        }
        return false;
    }
    latitudeBlur(event) {
        //fieldValidationPattern
        console.log('latitudeBlur-----',JSON.stringify(event));
        var validPattern = new RegExp(/^(\+)?(?:90(?:(?:\.0{1,6})?)|(?:[0-9]|[1-8][0-9])(?:(?:\.[0-9]{1,6})?))$/);
        let value = event.target.value;
        if(value.length > 0) {
            if(!validPattern.test(value)) {
                event.target.setCustomValidity(this.fieldPatternErrorMessage);
                event.target.reportValidity();
            }
            else{
                event.target.setCustomValidity('');
                if(value != undefined && value != '' && value != '+') {
                    value = Number(value);
                    value = value.toFixed(6);
                    var checkSymbol = value.charAt(value[0]);
                    if(checkSymbol != '+') {
                        value = '+' + value;
                    }
                    event.target.reportValidity();
                    this.recordLocal[this.pageFieldLocal.Field_API_Name__c] = value;
                    let fieldJson = {apiName: this.pageFieldLocal.Field_API_Name__c, apiValue: value};
                    this.fireFieldChangeEvent(fieldJson);
                }
            }
        }

    }

    removeZeros(event) {
        let value = event.target.value;
        //let field = event.target.dataset.field;
        if(value != undefined && value != ''){
            value = parseFloat(value);
            this.recordLocal[this.pageFieldLocal.Field_API_Name__c] = value;
            /*let fieldJson = {apiName: this.pageFieldLocal.Field_API_Name__c, apiValue: value};
            this.fireFieldChangeEvent(fieldJson);*/
        }
    }

    /*Longitude field related methods */
    get isLongitudeField(){
        if(this.isPageFieldLoaded && this.pageFieldLocal.Field_Type__c == 'Longitude'){
            return true;
        }
        return false;
    }

    longitudeBlur(event){
        var validPattern = new RegExp(/^(-)?(?:180(?:(?:\.0{1,6})?)|(?:[0-9]|[1-9][0-9]|1[0-7][0-9])(?:(?:\.[0-9]{1,6})?))$/);
        let value = event.target.value;
        console.log('velue----',value);
        if(value.length > 0) {
           if(!validPattern.test(value)) {
               event.target.setCustomValidity(this.fieldPatternErrorMessage);
               event.target.reportValidity();
           }
           else{
               event.target.setCustomValidity('');
               if(value != undefined && value != '' && value != '-') {
                   value = Number(value);
                   value = value.toFixed(6);
                   var checkSymbol = value.charAt(value[0]);
                   if(checkSymbol != '-') {
                       value = '-' + value;
                   }
                   event.target.reportValidity();
                   this.recordLocal[this.pageFieldLocal.Field_API_Name__c] = value;
                   let fieldJson = {apiName: this.pageFieldLocal.Field_API_Name__c, apiValue: value};
                    this.fireFieldChangeEvent(fieldJson);
               }
           }
        }

    }

    /*Text field related methods */
    get isTextField(){
        if(this.isPageFieldLoaded && this.pageFieldLocal.Field_Type__c == 'Text'){
            return true;
        }
        return false;
    }
    prepareForLatitude() {
        if(this.pageFieldLocal && this.pageFieldLocal.compoundComponentName && this.pageFieldLocal.compoundComponentName == 'Latitude') {
            console.log('Location_compoundComponentName : ',this.pageFieldLocal.compoundComponentName);
            this.recordLocal[this.pageFieldLocal.Field_API_Name__c] = '+' + this.recordLocal[this.pageFieldLocal.Field_API_Name__c];
        }
    }

    /*Checkbox field related methods */
    get isCheckboxField(){
        if(this.isPageFieldLoaded && this.pageFieldLocal.Field_Type__c == 'Checkbox'){
            return true;
        }
        return false;
    }

    /*Date field related methods */
    get isDateField(){
        if(this.isPageFieldLoaded && this.pageFieldLocal.Field_Type__c == 'Date'){
            return true;
        }
        return false;
    }

    /*TextArea field related methods */
    get isTextAreaField(){
        if(this.isPageFieldLoaded && this.pageFieldLocal.Field_Type__c == 'Text Area'){
            return true;
        }
        return false;
    }
    prepareForTextAreaFieldLength() {
        if(this.recordLocal[this.pageFieldLocal.Field_API_Name__c] && this.pageFieldLocal.Field_Type__c == 'Text Area') {
            this.calculatedFieldLength = this.recordLocal[this.pageFieldLocal.Field_API_Name__c].length;
        }
    }

    /*Currency field related methods */
    get isCurrencyField(){
        if(this.isPageFieldLoaded && this.pageFieldLocal.Field_Type__c == 'Currency'){
            return true;
        }
        return false;
    }

    get minFieldValue(){
        if(this.isPageFieldLoaded && this.pageFieldLocal.Enabled_Minimum_Value__c && this.pageFieldLocal.Minimum_Value_Configuration__c){
            return this.evaluateMinValueFormula();
        }
        return 0;
    }

    get maxFieldValue(){
        if(this.isPageFieldLoaded && this.pageFieldLocal.Enabled_Maximum_Value__c && this.pageFieldLocal.Maximum_Value_Configuration__c){
            return this.evaluateMaxValueFormula();
        }
        return;
    }

    evaluateMaxValueFormula(){
       let configJson = JSON.parse(this.pageFieldLocal.Maximum_Value_Configuration__c);
       console.log('max configJson---------',configJson);
       if(configJson['errorMessage']){
           this.maxValueMismatchErrorMsg = configJson['errorMessage'];
       }
       if(configJson['fields']){
            let fieldArray = configJson['fields'].split(',');
            let formula = String(configJson['maxValueFormula']);
            let formulaFieldAPIReplacedWithValue = [];
            for(var x=0; x < fieldArray.length; x++){
                if(this.recordLocal[fieldArray[x]]){
                    console.log('max  fieldArray[x]-------',fieldArray[x]);
                  if(formula.includes(fieldArray[x])){
                     console.log('-----max formula-----'+x +' ',formula);
                     formula = formula.replace(String(fieldArray[x]), this.recordLocal[fieldArray[x]]);
                     console.log('-----max formula after-----'+x +' ',formula);
                     formulaFieldAPIReplacedWithValue.push(true);
                  }
                }
            }
            //Evaluate formula
            if(formulaFieldAPIReplacedWithValue.length == fieldArray.length){//if all formula field value changed then
             let formulaValue = eval(formula);
             if(isNaN(formulaValue) == false){
                  console.log('-----max formulaValue-----',formulaValue);
                return formulaValue;
             }
            }
       }
       if(configJson['maxValue']){
           return configJson['maxValue'];
       }

    }

    evaluateMinValueFormula(){
       let configJson = JSON.parse(this.pageFieldLocal.Minimum_Value_Configuration__c);
       console.log('configJson---------',configJson);
       if(configJson['errorMessage']){
           this.minValueMismatchErrorMsg = configJson['errorMessage'];
       }
       let fieldArray = configJson['fields'].split(',');
       console.log('fieldArray-------',fieldArray);
       let formula = String(configJson['minValueFormula']);
       let formulaFieldAPIReplacedWithValue = [];
       for(var x=0; x < fieldArray.length; x++){
           if(this.recordLocal[fieldArray[x]]){
             console.log('fieldArray[x]-------',fieldArray[x]);
             console.log('formula.includes(fieldArray[x])-------',formula.includes(fieldArray[x]));
             if(formula.includes(fieldArray[x])){
                console.log('-----formula-----'+x +' ',formula);
                formula = formula.replace(String(fieldArray[x]), this.recordLocal[fieldArray[x]]);	///change to dynamic use this.recordLocal
                console.log('-----formula after-----'+x +' ',formula);
                formulaFieldAPIReplacedWithValue.push(true);
             }
           }
       }
       //Evaluate formula
       if(formulaFieldAPIReplacedWithValue.length == fieldArray.length){//if all formula field value changed then
       let formulaValue = eval(formula);
       console.log('-----formulaValue-----',formulaValue);
       //formulaDetails[i]['valueAssignTo'] =
      if(isNaN(formulaValue) == false){
          return formulaValue;
      }
    }

    }



    /*Number field related methods */
    get isNumberField(){
        if(this.isPageFieldLoaded && this.pageFieldLocal.Field_Type__c == 'Number'){
            return true;
        }
        return false;
    }
    
    /*Percent field related methods */
    get isPercentField(){
        if(this.isPageFieldLoaded && this.pageFieldLocal.Field_Type__c == 'Percent'){
            return true;
        }
        return false;
    }

    /*Multiselect field related methods */
    get isMultiselectField(){
        if(this.isPageFieldLoaded && this.pageFieldLocal.Field_Type__c == 'Multiselect'){
            return true;
        }
        return false;
    }
    prepareMultiSelectedValues() {
        if(this.isPageFieldLoaded && this.isMultiselectField && this.pageFieldLocal.Field_API_Name__c && this.recordLocal[this.pageFieldLocal.Field_API_Name__c]){
            this.dualListSelectedValues = this.recordLocal[this.pageFieldLocal.Field_API_Name__c].split(';');
         }
    }
    /*Lookup field related methods */
    get isLookupField(){
        if(this.isPageFieldLoaded && this.pageFieldLocal.Field_Type__c == 'Lookup'){
            return true;
        }
        return false;
    }
    /* Document Table related fields */
    get isDocumentUploadField() {
        //console.log('Document_this.pageFieldLocal:', this.pageFieldLocal.Document_Table_Columns__c);
        if(this.isPageFieldLoaded && this.pageFieldLocal.Field_Type__c == 'Document upload table'){            
            return true;
        }
        return false;
    }
    get parseDocumentColumns() {
        return JSON.parse(this.pageFieldLocal.Document_Table_Columns__c);
    }

    handleLookupSearch(event){
        event.detail['className'] = this.pageFieldLocal.Search_Class_Name__c;
        console.log('this.pageFieldLocal.Search_Class_Name__c: ',this.pageFieldLocal.Search_Class_Name__c);
        console.log('event.detail: ',JSON.stringify(event.detail));
        search(event.detail)
            .then((results) => {
                console.log('results----', results);
                let dataLookup = '[data-lookup="'+this.pageFieldLocal.Field_API_Name__c+'"]';
                this.template.querySelector(dataLookup).setSearchResults(results);
                this.lookupSearchLocalArray = JSON.parse(JSON.stringify(results));
                this.setLookupValue();//set default value if any
            })
            .catch((error) => {
                console.error('Lookup error', JSON.stringify(error));
                this.errors = [error];
            });
    }

    handleLookupSelectionChange(response) {
        console.log('response--', response.detail);
        if(response.detail != null && response.detail.selectedItem.id != undefined ) {
            let fieldJson = {apiName: this.pageFieldLocal.Field_API_Name__c, apiValue: response.detail.selectedItem.id};
            const fieldChangedEvent = new CustomEvent('fieldchanged', {
                detail: fieldJson
            });
            this.dispatchEvent(fieldChangedEvent);
        }
        else {
            console.log('in else');
            let fieldJson = {apiName: this.pageFieldLocal.Field_API_Name__c, apiValue: ''};
            const fieldChangedEvent = new CustomEvent('fieldchanged', {
                detail: fieldJson
            });
            this.dispatchEvent(fieldChangedEvent);
            this.lookupSelection = [];
        }
    }

    setLookupValue(){
        this.lookupSelection = [];
        if(this.record[this.pageFieldLocal.Field_API_Name__c]){
            for (var i = 0; i < this.lookupSearchLocalArray.length; i++){
              if (this.lookupSearchLocalArray[i].id == this.record[this.pageFieldLocal.Field_API_Name__c]){
                 console.log('found result: ',JSON.stringify(this.lookupSearchLocalArray[i]));
                 this.lookupSelection.push(this.lookupSearchLocalArray[i]);
              }
            }
        }
    }

    /*Static content field related methods */
    get isStaticField(){
        if(this.isPageFieldLoaded && this.pageFieldLocal.Field_Type__c == 'Static Content'){
            return true;
        }
        return false;
    }

    /*Blank field related methods */
    get isBlankField(){
        if(this.isPageFieldLoaded && this.pageFieldLocal.Field_Type__c == 'Blank'){
            return true;
        }
        return false;
    }


    /***************************************************************************
    * Method Name : getTableData
    * Inputs :-
    * Description: This method used retrieve  table data from c-page-table component
    ******************************************************************************/
    @api getTableDataPageField(){
        if(this.isMultiTableField) {
            let fieldJson = {tableRecordDetails: [], tableObjectName: ''};
            let allTableRecords = [];
        this.template.querySelectorAll('c-page-table').forEach((element) => {
                let eleTableDetail = element.getTableDataPageTable();
                console.log('elementDetail--', JSON.parse(JSON.stringify(eleTableDetail)));
                fieldJson.tableObjectName = eleTableDetail.tableObjectName;
                for(let i=0; i<eleTableDetail.tableRecordDetails.length; i++) {
                    console.log('elementDetail in for loop--', JSON.parse(JSON.stringify(eleTableDetail.tableRecordDetails[i])));
                    allTableRecords.push(eleTableDetail.tableRecordDetails[i]);
            }
        });
            fieldJson.tableRecordDetails = allTableRecords;
            console.log('fieldJson --- ', JSON.parse(JSON.stringify(fieldJson)));
            return JSON.parse(JSON.stringify(fieldJson));
        } else if(this.isTableField) {
            let tableDetails;
            this.template.querySelectorAll('c-page-table').forEach((element) => {
                tableDetails = element.getTableDataPageTable();
            });
            if(tableDetails){
                console.log('PageField_jsonData', JSON.parse(JSON.stringify(tableDetails)));
                return JSON.parse(JSON.stringify(tableDetails));
        }
    }

        return '';
    }

    @api tableValidation(){          
        let pageTableRecordValid = true ;     
        this.template.querySelectorAll('c-page-table').forEach((element) => {
           if(element.validateTable() == false){
            pageTableRecordValid = false; 
           }    
       });   
       console.log('page field tableValidation test',pageTableRecordValid);
       return pageTableRecordValid;     
    }
    get isTableField() {
        if(this.isPageFieldLoaded && this.pageFieldLocal.Field_Type__c == 'Table'){
            return true;
        }
        return false;
    }

    get isMultiTableField() {
        if(this.isPageFieldLoaded && this.pageFieldLocal.Field_Type__c == 'Multiple Table' && this.multiTableList.length > 0) return true;
        return false;
    }

    prepareListOfTable() {
        try{
            //console.log('in prepare list of table', (this.isPageFieldLoaded));
            if(this.isPageFieldLoaded && this.pageFieldLocal.Field_Type__c == 'Multiple Table') {
                let updatedQuery = this.pageFieldLocal.Multiple_Table_Query__c;
                //console.log('updatedquery--', updatedQuery);
                if(updatedQuery.includes('{recordId}')){
                    updatedQuery = updatedQuery.replace('{recordId}', this.record.Id);
                    getListofTable({
                        'query' : updatedQuery
                    }).then(result => {
                            /*console.log('prepareListofTable result---', result);
                            console.log('prepareListofTable result---', result['recordDetails'].length);*/
                            if(result['isSuccess'] && result['recordDetails'].length > 0) {
                                this.multiTableList = [];
                                this.multiTableList = result['recordDetails'];
                            }
                        }).catch(error => {
                            this.errors = error;
                            console.log('error in prepareListofTable--', JSON.parse(JSON.stringify(this.errors)));
                        });
                }
            }
        } catch(e) {
            console.log('error---',e);
        }
    }

    @api
    getTableRecordList(){
        /*Currently gave support for only single table*/
        console.log('In page table field');
        if(this.isTableField){
            return this.template.querySelector("c-page-table").getTableRecords();
        }
        return [];
    }
}