import { LightningElement,track,api, wire} from 'lwc';
import Utility from 'c/utility';
import getTableRecordDetails from '@salesforce/apex/PageTableController.getTableRecordDetails';
import executeTableAction from '@salesforce/apex/PageTableController.executeTableAction';
import dynamicTableClassApex from '@salesforce/apex/PageLayoutCtrl.dynamicTableClassApex';
import updateObjectDetails from '@salesforce/apex/PageTableController.updateObjectDetails';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { refreshApex } from '@salesforce/apex';
import deleteTableRowRecord from '@salesforce/apex/PageTableController.deleteTableRowRecord';
import { CurrentPageReference } from 'lightning/navigation';
import { publish, MessageContext } from 'lightning/messageService';
import pageTableMessageChannel from '@salesforce/messageChannel/pageTableMessageChannel__c';

export default class PageTable extends Utility {
    @api pageFieldLocal;
    @api tableColumns;
    @api tableObjectName;
    @api tableRecordLimit;
    @api tableWhereClause;
    @api tableParentRelationshipFieldApi;
    @api tableName;
    @api tableMoreConfig;
    @api fieldChanged = false;
    @api grandParentRecord;
    @api isAllFieldsReadOnly;
    @api recordId;
    @api pageLayoutId;
    @api loggedInUserDetails;

    @api
    get programTemplatePageId(){
        return this.programTemplatePageIdLocal;
    }

    set programTemplatePageId(value){
        this.programTemplatePageIdLocal = value;
    }

    @track tableAdditionalConfig = {};
    @track tableRecordDetails = [];
    @track tableSummaryRecord;
    @track tableColumnNames;
    @track tableObjectMeta;
    @track tableObjectFields;
    //@track isSaveButtonVisible=true; 
    @track isDeleteConfirmationShow=false;
    @track rowIndexNumber;
    @track calculationFormulaFields = [];
    @track operatorToColumnFormulaFields = {"Sum":[], "Avg":[]};
    @track calculationFormulaMaxValue;
    @track formulaFields = [];
    @track operator;
    @track targetFormulaField;
    @track recordType;
    indexKey = 0;
    @track defaultRecordTypeId;
    @track programTemplatePageIdLocal;
    @track parentRecordLocal;
    @track userHideORShowActionsAccess = {};

    @track showTableNewAction = false;
    @track showActionColumnDelete = false;
    @track showActionColumnEdit = false;
    @track showActionColumn = false;
    @track requestForInformationModal = false;
    @track FEMARequestForInformationModal = false;

    showSaveEditConfirmationPopup = false;
    saveEditConfirmationPopupAction = '';
    currentEditRowIndex;
    @track isContactInformationModal = false;

    /**Page Table Message Channel*/
    @wire(MessageContext)
    messageContext;

    @wire(CurrentPageReference)
    setCurrentPageRef(currentPageReference) {
        if(currentPageReference && currentPageReference.state) {
          if(currentPageReference.state.id) {
                this.recordId = currentPageReference.state.id;
          }
          /*if(currentPageReference.state.programTemplatePageId) {
                this.programTemplatePageIdLocal = currentPageReference.state.programTemplatePageId;
          }*/
        }
    }

    @wire(getObjectInfo, {objectApiName: '$tableObjectName' })
    objectInfo({error, data}){
        this.showLoader = false;
        if(data){
            //console.log('objectInfo response: ',data);
            this.tableObjectMeta = data;
            this.tableObjectFields = data['fields'];
            this.findRecordTypeToEmptyRow();
        }else if(error){
            console.log('objectInfo error for tableObjectName: ',this.tableObjectName);
            console.log('objectInfo error: ',error);
        }
    }

    get isTableReadyToLoad(){
        if(this.tableObjectFields){
            return true;
        }
        return false;
    }

   initData(){
     this.prepareTableConfiguration();
     this.getTableObjectDetails();
     //console.log('grandParentRecord---', JSON.parse(JSON.stringify(this.grandParentRecord)));
      }

   get isTableNameAvailable(){
       return (this.tableName) ? true : false;
   }

    /***********************************************
    * Method Name : getTableColumnNames
    * Inputs :tableColumns
    * Description: This method used for get table column name Dynamically
    *********************************************/
   getTableColumnNames(tableColumns){
    let columnNames = [];
    for (let i=0; i<tableColumns.length; i+=1){
        if(tableColumns[i].fieldName!=null){
            columnNames.push(tableColumns[i].fieldName);
         }else{
                console.log('empty_fieldName : ',tableColumns[i].fieldName)
         }
    }
    return columnNames;  
  } 
  
    prepareTableConfiguration() {
        if(this.tableColumns){
            this.tableColumnNames = JSON.parse(this.tableColumns);
            //this.tableColumnNames.push(indexNo);
            //TODO-multiple targetformula field support
           //console.log('tableColumnNames in preparetable function:',this.tableColumnNames);
            this.tableColumnNames.forEach(obj => {
                if('formulaFields' in obj) {
                    //console.log('obj in table---', obj);
                    this.formulaFields = obj.formulaFields.split(',');
                    this.operator = obj.operator;
                    this.targetFormulaField = obj.fieldName;
                }
            });
        }
        if(this.tableMoreConfig) {
            this.tableAdditionalConfig = JSON.parse(this.tableMoreConfig);
            //console.log('additional Config---', this.tableAdditionalConfig);
            if(this.tableAdditionalConfig.summaryFields) {
                /* Used in if summaryRow = static*/
                this.calculationFormulaFields = this.tableAdditionalConfig.summaryFields[0]['formulaFields'].split(',');
                //console.log('summaryFields_calculationFormulaFields ---', this.calculationFormulaFields);
            }
            if(this.tableAdditionalConfig.columnSummaryFields && this.tableAdditionalConfig.summaryRowType == 'dynamic') {
                for(let i=0; i < this.tableAdditionalConfig.columnSummaryFields.length; i++) {
                    let summaryField= this.tableAdditionalConfig.columnSummaryFields[i];
                    if(summaryField['operator'] == 'Sum') {
                        this.operatorToColumnFormulaFields['Sum'].push(summaryField['formulaFields']);
                    }   //TODO: Need to Work on Avg
                    //this.columnFormulaFields.push(this.tableAdditionalConfig.columnSummaryFields[i]['formulaFields']);

                }
                //this.columnFormulaFields = this.tableAdditionalConfig.columnSummaryFields[0]['formulaFields'].split(',');
                //console.log('columnSummaryFields -', this.operatorToColumnFormulaFields);
            }
            this.checkTableActionAccess();
        }
    }
    checkTableActionAccess() {
        if(this.tableAdditionalConfig['checkTableActionAccess'] == true && this.tableAdditionalConfig['TableActionAccessClass']) {
            this.showLoader = true; 
            
            this.executeAction(dynamicTableClassApex, {recordId : this.recordId, className : this.tableAdditionalConfig['TableActionAccessClass'], pageFieldDeveloperName : this.pageFieldLocal['DeveloperName']}, (response) => {
                console.log('response_dynamicTableClassApex : ',response);
                this.userHideORShowActionsAccess = response;
                this.showTableNewAction = response['isNewActionAvailable'];
                this.showActionColumnDelete = response['isDeleteActionAvailable'];
                this.showActionColumnEdit = response['isEditActionAvailable'];
                this.showActionColumn = response['isActionColumnAvailable'];         
                console.log('showActionColumn 1: ', this.showActionColumn);      
                if(this.showActionColumn == false) {
                    this.hideActionColumnFromColumnList();                   
                }                      
                this.showLoader = false;      
            });
        }else if(this.showActionColumn == false && this.isAllFieldsReadOnly) {
            this.hideActionColumnFromColumnList();
        }
        console.log('tableColumnNames : ', this.tableColumnNames);        
    }

    hideActionColumnFromColumnList() {
                    for (let i=0; i<this.tableColumnNames.length; i+=1) {
                        if(this.tableColumnNames[i]['label'] == 'Action') {
                            this.tableColumnNames.splice(i, 1);
                        }
                    }
                }  
    /***********************************************
    * Method Name : getTableObjectDetails
    * Inputs :
    * Description: This method used to query the necessary details of table object
    *********************************************/
    @api getTableObjectDetails(){
        this.showLoader = true;
    let columnNames = this.getTableColumnNames(this.tableColumnNames);
        console.log('columnNames_ToPassApex : ',columnNames)
    let paramMap = {};
    paramMap['tableColumnNames'] = columnNames;
    paramMap['objectName'] = this.tableObjectName;
    paramMap['dataLimit'] = this.tableRecordLimit;
        paramMap['whereClause'] = this.prepareForWhereClause();
        paramMap['getParentRecordQuery'] = this.prepareWhereClauseParentRecord();
        console.log('paramMap---', paramMap);
        this.executeAction(getTableRecordDetails, paramMap, (response) => {
            console.log('response from getTableRecordDetail--',response); 
            if(response['recordList'] != null && response['recordList'].length > 0)
                this.tableRecordDetails = response['recordList'];
            if(response['parentRecordList'] != null && response['parentRecordList'].length > 0) {
                this.parentRecordLocal = response['parentRecordList'][0];
            } 
            this.setTableName();
            console.log('response_tableRecordDetails : ',this.tableRecordDetails); 
            this.prepareForTableDataConfiguration();            
            this.showLoader = false;      
        });
    } 

    setTableName() {
        //TODO-Check grand Parent Record as well
        console.log('table name--',(this.tableName && this.tableName.includes('__c')), this.tableName);
        if(this.tableName && this.tableName.includes('__c')) {
            if(this.parentRecordLocal && this.parentRecordLocal[this.tableName] != undefined) {
                this.tableName = this.parentRecordLocal[this.tableName];
            } else if(this.granParentRecord && this.grandParentRecord[this.tableName] != undefined) {
                this.tableName = this.grandParentRecord[this.tableName];
            }
        }
    }

    staticSummaryRowTable() {
        let tableIndex = 0;
        let recSummaryValue = {};
        let recordDetailsExceptSummary = [];
        let largeSumValue = 0;

        for(let i=0;i<this.tableRecordDetails.length;i++){
            if(this.checkForStaticSummaryRecord(this.tableRecordDetails[i])) {      //Check for Static Summary Record Row
                    recSummaryValue = JSON.parse(JSON.stringify(this.tableRecordDetails[i]));
                    console.log('recSumm---', recSummaryValue);
                    recSummaryValue['isEdit'] = false;
                    recSummaryValue['isSummaryRow'] = true;
                    //this.tableSummaryRecord = recSummaryValue;  
                }else {
                    let rec = JSON.parse(JSON.stringify(this.tableRecordDetails[i]));
                    if(this.tableAdditionalConfig.summaryFields[0]['operator'] == 'Sum' ) {                
                        let sumOfFields = this.getFilteredValue(rec[this.calculationFormulaFields[0]]) + this.getFilteredValue(rec[this.calculationFormulaFields[1]]);
                        if(this.tableAdditionalConfig.summaryFields[0]['value'] == 'Max') {
                            if(parseInt(sumOfFields) > parseInt(largeSumValue)) {
                                largeSumValue = parseInt(sumOfFields);
                            }
                        }                        
                    }
                if(this.isAllFieldsReadOnly) {
                    rec['isEdit'] = false;
                } else {
                    rec['isEdit'] = this.tableAdditionalConfig.isTableEditMode;
                }                
                    rec['tableIndexNumber'] = ++tableIndex;
                    rec['isSummaryRow'] = false;
                    recordDetailsExceptSummary.push(rec);
                }
        }
        if(recSummaryValue && recSummaryValue['isSummaryRow']){         //TODO : Remove Hard coded index of  calculationFormulaFields
            largeSumValue = largeSumValue + ( this.getFilteredValue(recSummaryValue[this.calculationFormulaFields[0]]) + this.getFilteredValue(recSummaryValue[this.calculationFormulaFields[1]]) );  //Adding Summary Row values in largeSumValue
            recSummaryValue['tableIndexNumber'] = ++tableIndex;     // Assume Table having only one Summary row
            recordDetailsExceptSummary.push(recSummaryValue);
            this.tableRecordDetails = recordDetailsExceptSummary;
        }
        this.calculationFormulaMaxValue = largeSumValue;
    }

    dynamicSummaryRowTable() {
        let tableIndex = 0;   
        let summaryRecordIndex = 0;
        let summaryRec;
        let columnNameToCalculatedValue = {};       //It holds the Summary Value Calculation for each iteration
        let recDetails = JSON.parse(JSON.stringify(this.tableRecordDetails));
        for(let i=0 ; i < recDetails.length; i++){
            if(recDetails[i]['isSummaryRow']) {     //Check for Summary Row
                summaryRec = recDetails[i];
                //summaryRec['tableIndexNumber'] =  recDetails.length;
                summaryRecordIndex = i;
            }else {
                /*If we configured multiple column for summary row */
                for(let c=0; c < this.tableAdditionalConfig.columnSummaryFields.length; c++) {      // For multiple columnSummaryFields 
                    if(this.tableAdditionalConfig.columnSummaryFields[c] && this.tableAdditionalConfig.columnSummaryFields[c]['operator']) {  
                        columnNameToCalculatedValue = this.calculateColumnSummaryValue(this.tableAdditionalConfig.columnSummaryFields[c]['operator'], this.tableAdditionalConfig.columnSummaryFields[c]['formulaFields'], recDetails[i], columnNameToCalculatedValue);      //Used for Perform calculation on Table Column according to operator
                    }
                }
                if(this.isAllFieldsReadOnly) {
                    recDetails[i]['isEdit'] = false;
                } else {
                    recDetails[i]['isEdit'] = this.tableAdditionalConfig.isTableEditMode;
                }
                
                recDetails[i]['isSummaryRow'] = false;
                recDetails[i]['tableIndexNumber'] = ++tableIndex;
            }
        }
        if(summaryRec) {
            recDetails.splice(summaryRecordIndex, 1);
            if(recDetails.length > 0) {
                recDetails.push(summaryRec);
            }            
        }else {
            if(recDetails.length > 0) {
                let columnSumRow = {};
                
                for(let k =0; k < this.tableAdditionalConfig.columnSummaryFields.length; k++) {
                    columnSumRow[this.tableAdditionalConfig.columnSummaryFields[k]['formulaFields']] = (columnNameToCalculatedValue[this.tableAdditionalConfig.columnSummaryFields[k]['formulaFields']] == '' ? 0 : columnNameToCalculatedValue[this.tableAdditionalConfig.columnSummaryFields[k]['formulaFields']]);
                }
                columnSumRow['isEdit'] = false;
                columnSumRow['isSummaryRow'] = true;
                recDetails.push(columnSumRow);          //Adding Summary Row
            }            
        }
        console.log('recDetails --- ', recDetails);
        this.tableRecordDetails = recDetails;        
    }

    withoutSummaryRowTable() {
        let tableIndex = 0;
        let recordDetailsWithoutSummaryRow = [];
        for(let i=0 ; i < this.tableRecordDetails.length; i++){
                let recWithoutSummaryRow = JSON.parse(JSON.stringify(this.tableRecordDetails[i]));
            if(this.isAllFieldsReadOnly) {
                recWithoutSummaryRow['isEdit'] = false;
            } else {
                recWithoutSummaryRow['isEdit'] = this.tableAdditionalConfig.isTableEditMode;
            }
            
                recWithoutSummaryRow['isSummaryRow'] = false;
                recWithoutSummaryRow['tableIndexNumber'] = ++tableIndex;
                recordDetailsWithoutSummaryRow.push(recWithoutSummaryRow);
            }            
        this.tableRecordDetails = recordDetailsWithoutSummaryRow;
        }        
    prepareForTableDataConfiguration() {        
        console.log('tableRecordDetails_prepareForTableDataConfiguration : ', this.tableRecordDetails);
        if(this.tableAdditionalConfig && this.tableAdditionalConfig.summaryRow && this.tableAdditionalConfig.summaryRowType == 'static') { 
            this.staticSummaryRowTable();       // For Static Summary Row in table
        } else if(this.tableAdditionalConfig && this.tableAdditionalConfig.summaryRow && this.tableAdditionalConfig.summaryRowType == 'dynamic') {
            this.dynamicSummaryRowTable();      // For Dynamic Summary Row in table which display calculated value of Column
        }else {
            this.withoutSummaryRowTable();      // For No Summary Row in table
        }
    }

    checkForStaticSummaryRecord(tableRowData) {
        let isSummaryRecord = true;
        for(let j=0; j<this.tableColumnNames.length; j++) {
            if(tableRowData[this.tableColumnNames[j]['fieldName']] == undefined) {
                tableRowData[this.tableColumnNames[j]['fieldName']] = '';
            }
            if(tableRowData[this.tableColumnNames[j]['fieldName']] != this.tableColumnNames[j]['summaryValue'] && this.tableColumnNames[j]['label'] != 'Action') {
                isSummaryRecord = false;
            }
        }
        return isSummaryRecord;
    }

    calculateColumnSummaryValue(operator, formulaField, recDetails, columnSumValue) {
        console.log('columnSumValue : ', columnSumValue);
        if(columnSumValue.hasOwnProperty(formulaField)) {
            if(operator == 'Sum') {
                columnSumValue[formulaField] = columnSumValue[formulaField] + recDetails[formulaField];
            }
        } else {
            columnSumValue[formulaField] = recDetails[formulaField];
        }
        return columnSumValue;
    }

    containsAllKey(obj, arr) {
        console.log('containsAllArray--', JSON.parse(JSON.stringify(obj)), JSON.parse(JSON.stringify(arr)));
        for(let str of arr) {
            console.log('str---', str);
            if(Object.keys(obj).includes(str) && (obj[str] != null && obj[str] != undefined) ) continue;
            else return false;
        }
        return true;
    }

    getFilteredValue(calculationValue) {
        if(calculationValue) {
            return parseInt(calculationValue);
        } else {
            return 0;
        }
           }  

    get isIndividualSaveButtonPresentTop() {
        if(this.tableAdditionalConfig != undefined && this.tableAdditionalConfig.SaveAction && this.tableAdditionalConfig.SaveActionLocation == 'Top') 
            return true;
        return false;
    }

    get isIndividualSaveButtonPresentBottom() {
        if(this.tableAdditionalConfig != undefined && this.tableAdditionalConfig.SaveAction && this.tableAdditionalConfig.SaveActionLocation == 'Bottom') 
            return true;
        return false;
    }

    get isNewActionPresentTop() {
        if(this.tableAdditionalConfig != undefined && this.tableAdditionalConfig.NewAction && this.tableAdditionalConfig.NewActionLocation == 'Top') {
            return true;
        }
        return false;
    }

    get isNewActionPresentBottom() {
        if(this.tableAdditionalConfig != undefined && this.tableAdditionalConfig.NewAction && this.tableAdditionalConfig.NewActionLocation == 'Bottom') 
            return true;
        return false;
    }
    get getNewActionLabel() {
        if(this.tableAdditionalConfig.NewAction && this.tableAdditionalConfig.NewActionLabel != '' && this.tableAdditionalConfig.NewActionLabel != undefined) {
            return this.tableAdditionalConfig.NewActionLabel;
        }
        return '';
    }
    get isNewActionButtonDisabled() {
        if(this.showTableNewAction && !(this.tableAdditionalConfig['ModalName'] == 'Maintenance Commitment' || this.tableAdditionalConfig['ModalName'] == 'Match Commitment')){
            return false;
        }
        if(this.isAllFieldsReadOnly){
            return true;
        }
        if(this.tableAdditionalConfig && this.tableAdditionalConfig['NewActionType'] && this.tableAdditionalConfig['NewActionType'] == 'Modal' && (this.tableAdditionalConfig['ModalName'] == 'Maintenance Commitment' || this.tableAdditionalConfig['ModalName'] == 'Match Commitment') && this.tableRecordDetails.length != 0) {
            return true;
        }
        if(this.tableAdditionalConfig['checkTableActionAccess'] == true && this.tableAdditionalConfig['TableActionAccessClass'] && !this.showTableNewAction) return true;
        return false;
    }
    get isParentFieldLabel() {
        if(this.tableAdditionalConfig != undefined && this.tableAdditionalConfig != null && this.tableAdditionalConfig.summaryFields != undefined) {
            return this.tableAdditionalConfig.summaryFields[0]['parentFieldLabel'] != '' && this.tableAdditionalConfig.summaryFields[0]['parentFieldLabel'] != undefined;
        }
        return false;
    }
    get getParentFieldLabel() {
        return this.tableAdditionalConfig.summaryFields[0]['parentFieldLabel'];
    }
    get getDynamicKey() {
        return ++ this.indexKey;
  } 

    prepareForWhereClause(){
      if(this.tableWhereClause){
            let updatedClause = this.tableWhereClause;
            if(updatedClause.includes('{recordId}')){
                updatedClause = updatedClause.replace('{recordId}', this.recordId);
            }
            return updatedClause;
        }
        return '';
    }

    prepareWhereClauseParentRecord() {
        if(this.tableAdditionalConfig && this.tableAdditionalConfig.GetParentRecord && this.tableAdditionalConfig.GetParentRecord != null) {
            let updatedClause = this.tableAdditionalConfig.GetParentRecord;
            if(this.tableAdditionalConfig.GetParentRecord.includes('{recordId}')) {
                updatedClause = updatedClause.replace('{recordId}', this.recordId);
            }            
            if(updatedClause.includes('{grandParentId}') && this.grandParentRecord && this.grandParentRecord.Id){
                updatedClause = updatedClause.replace('{grandParentId}', this.grandParentRecord.Id);
          }
            return updatedClause;
      }
      return '';
  }

    calculateCostEstimation(index, apiName) {  //TODO : Change the method name to generic
        let obj = JSON.parse(JSON.stringify(this.tableRecordDetails[index]));
        if((this.formulaFields.includes(apiName)) && this.containsAllKey(obj, this.formulaFields)) {
            if(this.operator == 'multiplication') {
                let mult = 1;
                for(let j=0; j<this.formulaFields.length; j++) {
                    mult = mult * parseFloat(obj[this.formulaFields[j]]);
                }
                if(!isNaN(mult)){
                    mult = parseFloat(mult).toFixed(2);
                    this.tableRecordDetails[index][this.targetFormulaField] = mult;
                }
            }
            this.calculateColumnChangedSummaryValue(this.targetFormulaField);
        }
    }

    findRecordTypeToEmptyRow() {
       if(this.tableObjectMeta && this.tableObjectMeta.recordTypeInfos) {
           for(const key in this.tableObjectMeta.recordTypeInfos) {
               //console.log('his.tableAdditionalConfig---',this.tableAdditionalConfig);
               if(this.tableObjectMeta.recordTypeInfos[key].name === this.tableAdditionalConfig.RecordTypeName) {
                   //console.log('this.tableObjectMeta.recordTypeInfos[key].recordTypeId---'+this.tableObjectMeta.recordTypeInfos[key].recordTypeId);
                   this.defaultRecordTypeId = this.tableObjectMeta.recordTypeInfos[key].recordTypeId;
                   //console.log('this.defaultRecordTypeId---'+this.defaultRecordTypeId);
               }
           }
       }
    }

    calculateProjectPlanDurationValueFromDelete(index) {
        let sum = 0;
        let max = 0;
        let obj;
        if(this.tableRecordDetails[index]) {
            obj = JSON.parse(JSON.stringify(this.tableRecordDetails[index]));
        }
        if(this.tableAdditionalConfig.summaryFields && this.containsAllKey(obj, this.calculationFormulaFields)) {
            for(let i=0; i<this.tableRecordDetails.length-1; i++) {
                //TODO if multiple summary fields are there in config
                if(this.tableAdditionalConfig.summaryFields[0].operator === 'Sum') {
                    sum = this.getFilteredValue(this.tableRecordDetails[i][this.calculationFormulaFields[0]]) + this.getFilteredValue(this.tableRecordDetails[i][this.calculationFormulaFields[1]]);
                    if(this.tableAdditionalConfig.summaryFields[0].value === 'Max' && max <= sum) {
                        max = sum;
                    }
                }
            }
            max += this.getFilteredValue(this.tableRecordDetails[(this.tableRecordDetails.length)-1][this.calculationFormulaFields[1]]);
            this.calculationFormulaMaxValue = max;
        }
    }
    
    calculateProjectPlanDurationValue(index, apiName) {
        let sum = 0;
        let max = 0;
        let obj = JSON.parse(JSON.stringify(this.tableRecordDetails[index]));
        if(this.tableAdditionalConfig.summaryFields && (this.calculationFormulaFields.includes(apiName)) && this.containsAllKey(obj, this.calculationFormulaFields)) {
            for(let i=0; i<this.tableRecordDetails.length-1; i++) {
                //TODO if multiple summary fields are there in config
                if(this.tableAdditionalConfig.summaryFields[0].operator === 'Sum') {
                    sum = this.getFilteredValue(this.tableRecordDetails[i][this.calculationFormulaFields[0]]) + this.getFilteredValue(this.tableRecordDetails[i][this.calculationFormulaFields[1]]);
                    if(this.tableAdditionalConfig.summaryFields[0].value === 'Max' && max <= sum) {
                        max = sum;
                    }
                }
            }
            max += this.getFilteredValue(this.tableRecordDetails[(this.tableRecordDetails.length)-1][this.calculationFormulaFields[1]]);
            this.calculationFormulaMaxValue = max;
        }
    }
    calculateColumnSummaryValueFormDelete() {
        if(this.tableAdditionalConfig.summaryRowType == 'dynamic' && this.operatorToColumnFormulaFields['Sum'].length > 0) {
            if(this.tableRecordDetails.length == 1 && this.tableRecordDetails[0]['isSummaryRow']) {
                this.tableRecordDetails.splice(0, 1);
                return;
            }
            for(let i=0; i < this.operatorToColumnFormulaFields['Sum'].length; i++) {
                this.calculateColumnChangedSummaryValue(this.operatorToColumnFormulaFields['Sum'][i]);
            }
        }        
    }
    calculateColumnChangedSummaryValue(apiName) {
        let sum = 0;
        /*if current field API name in this.operatorToColumnFormulaFields['Sum'] array*/
        if(this.tableAdditionalConfig && this.tableAdditionalConfig.summaryRow && this.tableAdditionalConfig.summaryRowType == 'dynamic' && this.operatorToColumnFormulaFields['Sum'].includes(apiName)) {
            for(let i=0; i< this.tableRecordDetails.length-1; i++) {
                for(let j=0; j<this.tableAdditionalConfig.columnSummaryFields.length; j++) {
                    if(this.tableAdditionalConfig.columnSummaryFields[j]['operator'] == 'Sum' && this.tableAdditionalConfig.columnSummaryFields[j]['formulaFields'] == apiName) {
                        sum = sum + this.getFilteredValue(this.tableRecordDetails[i][apiName]);
                    }
                }                
            }
            /*We are assuming summary row will be last row of the table*/
            this.tableRecordDetails[this.tableRecordDetails.length - 1][apiName] = sum;
        }
    }
    handleTableFieldChanged(event){
    let indexNo = event.detail['index'];
    let apiName = event.detail['apiName'];
        //console.log('event in handleTableField--', JSON.parse(JSON.stringify(event)));
    if(this.tableRecordDetails[indexNo]){
          this.tableRecordDetails[indexNo][apiName] = event.detail['apiValue'];
            //this.tableRecordDetails[indexNo][this.tableParentRelationshipFieldApi] = this.recordId;
            //console.log('AfterFieldChanged_tableRecordDetails', this.tableRecordDetails);
            //this.prepareForTableDataConfiguration();
            this.calculateCostEstimation(indexNo, apiName);
            this.calculateProjectPlanDurationValue(indexNo, apiName);
            this.calculateColumnChangedSummaryValue(apiName);
            setTimeout(() => { this.processMessageChannel(); }, 500);

        }
    }

    processMessageChannel(){
        /*
        "isMessageChannelEnabled": true,
        "messageChannelName":["TotalManagementCostCalculation"]
        */
        if(this.tableAdditionalConfig && this.tableAdditionalConfig['isMessageChannelEnabled']
            && this.tableAdditionalConfig['messageChannelName']){
                let messageChannelNameArray = this.tableAdditionalConfig['messageChannelName'];
                if(Array.isArray(messageChannelNameArray)){
                    for(let eventName in messageChannelNameArray){
                        let payLoad = {"eventName": messageChannelNameArray[eventName]};
                         publish(this.messageContext, pageTableMessageChannel, payLoad);
                    }
                }
        }
    }

    handleSendForSignatureClick(event) {
        if(this.fieldChanged == true) {
            this.showNotification('', 'You have unsaved changes on this page. Please save the record first and then click on Send for Signature', 'warning', 'dismissible');
            return;
        }
        let paramMap = {};
        paramMap['parentId'] = this.record.Id;
        paramMap['rowId'] = event.detail;
        paramMap['className'] = this.tableAdditionalConfig.sendForSignatureClassName;
        
        console.log('paramMap---', paramMap);
        this.showLoader = true;
        this.executeAction(executeTableAction, paramMap, (response) => {
            this.showLoader = false;
            console.log('response --',response);     
            if(response['isSuccess']){
                this.showSuccessNotification('Success','Document successfully sent for signature');
                this.getTableObjectDetails();
            }else{
                this.showErrorNotification('Error', 'Something went wrong! Please contact your administrator');
            }

        });
    }
   addTableRow() {
       console.log('add table row', this.parentRecordLocal);
        if(this.tableAdditionalConfig && this.tableAdditionalConfig['NewAction'] && this.tableAdditionalConfig['NewActionType'] && this.tableAdditionalConfig['NewActionType'] == 'Modal') {
            this.currentEditRowIndex = undefined;
            //this.isContactInformationModal = true;
            this.renderModalConditionally(true);
            return;
        }
       if(this.tableAdditionalConfig && this.tableAdditionalConfig['NewActionType']
            && this.tableAdditionalConfig['NewActionType'] == 'URL' && this.tableAdditionalConfig['NewActionURLParam'] != null){
            if(this.fieldChanged) {
                this.showSaveEditPopup('ADD');
            } else {
                this.handleAddRedirectUrl();
            }
           
           return;
       }
        let tableColumnAPINames = this.getTableColumnNames(this.tableColumnNames);
        let emptyTableRow = {};
        for(let i = 0; i < tableColumnAPINames.length; i++){
            emptyTableRow[tableColumnAPINames[i]] = '';
        }
        emptyTableRow['RecordTypeId'] = this.defaultRecordTypeId;
        emptyTableRow['isSummaryRow'] = false;//new row always not a summary row so value is false
        //Parent Id assign
        if(this.parentRecordLocal && this.parentRecordLocal['Id'] && this.tableAdditionalConfig['ParentAPIName']){
             emptyTableRow[this.tableAdditionalConfig['ParentAPIName']] = this.parentRecordLocal.Id;
        }
        this.tableRecordDetails.push(emptyTableRow);
        /*To recalculate row index and and add row before summary row*/
        this.prepareForTableDataConfiguration();
    }

    handleAddRedirectUrl(){
        let urlPageParam = this.tableAdditionalConfig['NewActionURLParam'];
        let urlPage = this.tableAdditionalConfig['NewActionURLPage'];
        if(urlPageParam.includes('{recordId}')){
            urlPageParam = urlPageParam.replace('{recordId}', this.recordId);
        }
        if(urlPageParam.includes('{parentProgramTemplatePageId}')){
            urlPageParam = urlPageParam.replace('{parentProgramTemplatePageId}', this.programTemplatePageId);
        }
        console.log('urlPageParam--------'+JSON.parse(JSON.stringify(urlPageParam)));
        console.log('redirectUrl--------'+urlPage);
        let temp = urlPageParam.split(',');
        let paramJson = {};
        for(let key in temp){
            console.log('temp[key]--------'+temp[key]);
            let keyValue = temp[key].split('=');
            paramJson[keyValue[0]] = keyValue[1];
        }
        console.log('paramJson====',paramJson);
        this.redirectToCommunityCustomPage(urlPage,paramJson);
    }

    handleRedirectEditUrl(index){
        let urlPageParam = this.tableAdditionalConfig['EditActionURLParam'];
        let urlPage = this.tableAdditionalConfig['EditActionURLPage'];
        if(urlPageParam.includes('{recordId}')){
            urlPageParam = urlPageParam.replace('{recordId}', this.recordId);
        }
        if(urlPageParam.includes('{rowId}')){
            urlPageParam = urlPageParam.replace('{rowId}', this.tableRecordDetails[index].Id);
        }

        if(urlPageParam.includes('{parentProgramTemplatePageId}')){
            urlPageParam = urlPageParam.replace('{parentProgramTemplatePageId}', this.programTemplatePageId);
        }
        console.log('urlPageParam--------'+JSON.parse(JSON.stringify(urlPageParam)));
        console.log('redirectUrl--------'+urlPage);
        let temp = urlPageParam.split(',');
        let paramJson = {};
        for(let key in temp){
            console.log('temp[key]--------'+temp[key]);
            let keyValue = temp[key].split('=');
            paramJson[keyValue[0]] = keyValue[1];
        }
        console.log('paramJson====',paramJson);
        this.redirectToCommunityCustomPage(urlPage,paramJson);
    }

    editTableRow(event) {
        console.log('editTableRow_IndexNumber : ', event.detail);
        //this.handleRedirectEditUrl(event.detail);/*pass index*/
        this.currentEditRowIndex = event.detail;
        if(this.tableAdditionalConfig && this.tableAdditionalConfig['EditActionType'] && this.tableAdditionalConfig['EditActionType'] == 'Modal') {
            //this.isContactInformationModal = true;
            this.renderModalConditionally(true);
            return;
        }
        if(this.tableAdditionalConfig && this.tableAdditionalConfig['EditActionType']
            && this.tableAdditionalConfig['EditActionType'] == 'URL' && this.tableAdditionalConfig['EditActionURLParam'] != null){
                if(this.fieldChanged) {
                    this.showSaveEditPopup('EDIT');
                } else  {
                    this.handleRedirectEditUrl(this.currentEditRowIndex);
                }
        }else{
            this.tableRecordDetails[this.currentEditRowIndex].isEdit = true;
            //refreshApex(this.tableRecordDetails);
            console.log('After_editTableRow_tableRecordDetails : ',  this.tableRecordDetails);
        }
    }
    deleteTableRow(event) {
        console.log('Delete_Index :  ', event.detail);
        this.rowIndexNumber = event.detail;
        this.isDeleteConfirmationShow=true;
    }
    
    handleDeleteConfirmationClick(event){
        console.log('this.rowIndexNumber---', this.rowIndexNumber);
        console.log('delete event detail---', event.detail);
        let action = event.detail;
        console.log('action in delte--', action);
        if(action.status == 'confirm') {
            //let tableRecords = this.tableRecordDetails;
            //let deletedTableRow = tableRecords.splice(this.rowIndexNumber,1);
            let deletedTableRow = this.tableRecordDetails.splice(this.rowIndexNumber,1);
            //TODO: remove for loop from below
            for(let i=this.rowIndexNumber; i<this.tableRecordDetails.length; i++) {
                this.tableRecordDetails[i]['tableIndexNumber'] = isNaN(parseInt(this.tableRecordDetails[i]['tableIndexNumber'])-1) ? '' : parseInt(this.tableRecordDetails[i]['tableIndexNumber'])-1;
            }

            if(deletedTableRow[0].Id) {
                this.executeAction(deleteTableRowRecord, {recordId : deletedTableRow[0].Id}, (response) => {
                    this.processMessageChannel();
                });
            } else {
                this.processMessageChannel();
            }
            this.calculateProjectPlanDurationValueFromDelete(this.rowIndexNumber);
            this.calculateColumnSummaryValueFormDelete();
            this.isDeleteConfirmationShow = false;
            console.log('Record deleted successfully');
            this.showSuccessNotification('Record deleted successfully', '');
        } else {
            this.isDeleteConfirmationShow = false;
        }
    }

     /**************************************************************************************
    * Method Name : tableData
    * Inputs :-
    * Description: This method used convert table tada in json and return 
    *****************************************************************************************/
    @api getTableDataPageTable(){
        let tableRecords = [...this.tableRecordDetails];
        for(let i=0; i<tableRecords.length; i++) {
            if(tableRecords[i].isSummaryRow) tableRecords.splice(i,1);
        }
        let fieldJson = {tableRecordDetails: tableRecords, tableObjectName: this.tableObjectName};
        console.log('getTableDataPageTable_tableRecordDetails : ', fieldJson);
        console.log('getTableDataPageTable_tableRecordDetails1 : ', JSON.parse(JSON.stringify(fieldJson)));
        return JSON.parse(JSON.stringify(fieldJson));   
    }
    
    /**************************************************************************************
    * Method Name : validateTable
    * Inputs :-
    * Description: This method used convert table tada in json and return 
    *****************************************************************************************/
    @api validateTable(){   
        console.log('page table validateTable');
        let pageTableRecordValid = true;
        this.template.querySelectorAll('c-page-table-cell').forEach((element) => {
            if(element.tableValidation() == false)
            {
                pageTableRecordValid = false;
            }
        });
        console.log('page table validateTable test ',pageTableRecordValid);
        return pageTableRecordValid;     
    }       

    get saveEditConfirmationShow() {
        return this.showSaveEditConfirmationPopup;
    }

    showSaveEditPopup(ACTION) {
        this.showSaveEditConfirmationPopup = true;
        this.saveEditConfirmationPopupAction = ACTION;
    }

    handleSaveEditConfirmationClick(event) {
        if(event.detail.status == 'confirm') {
            if (this.saveEditConfirmationPopupAction == 'ADD') {
                this.handleAddRedirectUrl();
            }else if (this.currentEditRowIndex != undefined && this.saveEditConfirmationPopupAction =='EDIT'){
                this.handleRedirectEditUrl(this.currentEditRowIndex);
          }
        } else {
            this.showSaveEditConfirmationPopup = false;
            this.currentEditRowIndex = undefined;
        }
    }
    /*Return the table records*/
    @api
    getTableRecords(){
        return this.tableRecordDetails;
    }

    //****TODO : Need to delete this */
    handleContactRoleInformation(event) {
        console.log('details : ', JSON.stringify(event.detail));
        this.getTableObjectDetails();
        this.handleCloseContactInformationModal();
    }
    handleUpdateTableRecord(event) {
        console.log('rfi_details : ', JSON.stringify(event.detail));
        this.getTableObjectDetails();
        this.handleCloseModal();
    }
    handleCloseContactInformationModal() {
        this.isContactInformationModal = false;
    }
    handleCloseModal() {
        this.requestForInformationModal = false;
        this.FEMARequestForInformationModal = false;
    }
    renderModalConditionally(showModal) {
        console.log('in renderModal function---',showModal);
        if(this.tableAdditionalConfig['ModalName'] == 'RFI Modal') {
            this.requestForInformationModal = showModal;
        } else if(this.tableAdditionalConfig['ModalName'] == 'FEMA RFI Modal') {
            this.FEMARequestForInformationModal = showModal;
        }else if((this.tableAdditionalConfig['ModalName'] == 'SubApplication User Roles') || (this.tableAdditionalConfig['ModalName'] == 'Maintenance Commitment')|| (this.tableAdditionalConfig['ModalName'] == 'Match Commitment')) {
            this.isContactInformationModal = showModal;
        }
    }

    get getContactRoleValue() {
        if(this.tableAdditionalConfig && this.tableAdditionalConfig['NewActionType'] && this.tableAdditionalConfig['NewActionType'] == 'Modal') {
            if(this.tableAdditionalConfig['ModalName'] == 'Maintenance Commitment') return 'Maintenance Commitment';
            if(this.tableAdditionalConfig['ModalName'] == 'Match Commitment') return 'Match Commitment';
        }
        return '';
    }
    get getTableRecordForEdit() {
        if(this.currentEditRowIndex && this.tableRecordDetails[this.currentEditRowIndex]) return this.tableRecordDetails[this.currentEditRowIndex];
        return '';
    }
    get getTableRecordIdForEdit() {
        console.log('edit_Test : ', this.currentEditRowIndex);
        console.log('tableRecordDetails : ', this.tableRecordDetails);
        if(this.currentEditRowIndex && this.tableRecordDetails[this.currentEditRowIndex]) return this.tableRecordDetails[this.currentEditRowIndex].Id;
        return '';
    }

    handleTableCellActions(event){
        console.log('handleTableCellActions : ', event.detail);
        let eventType = event.detail.type;
        if(eventType == 'columnClick'){
            let columnDetails = event.detail.columnDetails;
            let rowIndex = event.detail.rowIndex;
            if(columnDetails['clickableURLPage'] && columnDetails['clickableURLParam']){
                let paramJson = this.getColumnClickURLParams(columnDetails, rowIndex);
                this.navigateNavItemPage(columnDetails['clickableURLPage'], paramJson);
            }
        }
    }


     getColumnClickURLParams(columnDetails, rowIndex){
        let urlPageParam = columnDetails['clickableURLParam'];
        let urlPage = columnDetails['clickableURLPage'];
        if(urlPageParam.includes('{recordId}')){
            urlPageParam = urlPageParam.replace('{recordId}', this.recordId);
        }
        if(urlPageParam.includes('{rowId}')){
            urlPageParam = urlPageParam.replace('{rowId}', this.tableRecordDetails[rowIndex]['Id']);
        }

        if(urlPageParam.includes('{parentProgramTemplatePageId}')){
            urlPageParam = urlPageParam.replace('{parentProgramTemplatePageId}', this.programTemplatePageId);
        }
        console.log('urlPageParam--------'+JSON.parse(JSON.stringify(urlPageParam)));
        console.log('redirectUrl--------'+urlPage);
        let temp = urlPageParam.split(',');
        let paramJson = {};
        for(let key in temp){
            console.log('temp[key]--------'+temp[key]);
            let keyValue = temp[key].split('=');
            paramJson[keyValue[0]] = keyValue[1];
        }
        console.log('paramJson====',paramJson);
        return paramJson;
    }


}