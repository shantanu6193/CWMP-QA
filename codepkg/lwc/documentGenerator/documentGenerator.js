/**
 * Created by Pankaj on 2021-06-06.
 */

import { LightningElement, api, wire, track } from 'lwc';
import getDocumentConfig from '@salesforce/apex/DocumentGeneratorCtrl.getDocumentConfig';
import getDocusignUrl from '@salesforce/apex/DocumentGeneratorCtrl.getDocuSignUrl';
import Utility from 'c/utility';
import apexSearchPrimaryObject from '@salesforce/apex/DocumentGeneratorCtrl.apexSearchPrimaryObject';
import updateRelatedObj from '@salesforce/apex/DocumentGeneratorCtrl.updateRelatedObj';
import handleRelatedObjRel from '@salesforce/apex/DocumentGeneratorCtrl.handleRelatedObjRel';
import { getRecord } from "lightning/uiRecordApi";

const fields = ['RecordTypeId'];

export default class DocumentGenerator extends Utility {
    @api module='';
    @api recordId;
    @api filterCriteria='';
    @api filterCriteria2='';

    @track iframeURL;
    @track documentConfigs = [];
    value='All';
    showLookupField = false;
    showLookupLabel;
    showLookupFieldAPIName;
    showLookupFieldFilterCriteria;

    showLookupRelatedField1 = false;
    showLookupRelatedLabel1;
    showLookupRelatedFieldAPIName1;
    showLookupRelatedFieldFilterCriteria1;

    showLookupRelatedField2 = false;
    showLookupRelatedLabel2;
    showLookupRelatedFieldAPIName2;
    showLookupRelatedFieldFilterCriteria2;

    showLookupRelatedField3 = false;
    showLookupRelatedLabel3;
    showLookupRelatedFieldAPIName3;
    showLookupRelatedFieldFilterCriteria3;
    @track selectedRecordId;
    @track selectedRecordId1;
    @track selectedRecordId2;
    @track selectedRecordId3;
    @track selectedDocumentId;
    // @track recordTypeIdName ='Fedral';

    // @wire(getRecord, { recordId: '$recordId', fields })
    // getsobjectRec({ error, data }){
    //     if(data){
    //         //alert('This RecordType Value==='+data.recordTypeInfo.name);
    //         this.recordTypeIdName = data.recordTypeInfo.name;
    //     }else if(error) {
    //         var result = JSON.parse(JSON.stringify(error));
    //         console.log('error: ', result);
    //     }
    // };

    /*@wire(getDocumentConfig, { moduleName: '$module',filterCriteria: '$filterCriteria',recordId: '$recordId' })
    wiredConfig({ error, data }) {
        console.log('--', data);
        if (data) {
            this.documentConfigs = data;
        } else if (error) {
        }
    }*/

    @wire(getDocumentConfig, { moduleName: '$module',filterCriteria: '$filterCriteria',filterCriteria2: '$filterCriteria2',recordId: '$recordId' })
        wiredConfig({ error, data }) {
            console.log('--', data);
            if (data) {
                this.documentConfigs = data;
            } else if (error) {
            }
        }

    // @wire(getDocusignUrl, { SourceId: 'a0V35000001D4AwEAK' })
    // getParams({ data, error }){
    //     if(data){
    //         this.iframeURL = data;
    //        // this.iframeURL = this.iframeURL.replace('{RecordId}', this.recordId);
    //         console.log('passed recordId = ', this.recordId);
    //         console.log('Docusign Url = ', this.iframeURL);
    //         console.log('data:: ', data);
    //     }
    //     if(error){
    //         console.log('you have errors with Apex');
    //     }
    // }

    get moduleForDocument(){
        let pickListOptions = [];
        for(let i=0; i<this.documentConfigs.length; i++) {
            let picklistOption = {'label':this.documentConfigs[i].Module__c, 'value':this.documentConfigs[i].Id};
            pickListOptions.push(picklistOption);
        }
        return pickListOptions;
    }

    get documentsToGenerate() {
        let pickListOptions = [];
        for(let i=0; i<this.documentConfigs.length; i++) {
            let picklistOption = {'label':this.documentConfigs[i].Document_Name__c, 'value':this.documentConfigs[i].Id};
            pickListOptions.push(picklistOption);    
        }
        return pickListOptions;
    }

    handleDocumentChange(event) {
        let paramMap = {};
        paramMap['docId'] = event.target.value;
        this.selectedDocumentId = event.target.value;   // Holding of DocuId......
        paramMap['SourceID'] = this.recordId;
        this.executeAction(getDocusignUrl, paramMap, (response)=>{
            console.log('Result Block DocusignURL ===='+response);
            this.iframeURL = '';
            this.iframeURL = response.pageRefURL;
            if(response.Primaray_Object_API_Name__c && response.ShowPrimarayLookup === 'true'){
                this.showLookupField = true;
                this.showLookupFieldAPIName = response.Primaray_Object_API_Name__c;
            }else{
                this.showLookupField = false;
            }

            if(response.Primary_Object_Label__c){
                this.showLookupLabel = response.Primary_Object_Label__c;
            }

            if(response.Primaray_Object_Filter_Clauses__c){
               this.showLookupFieldFilterCriteria = response.Primaray_Object_Filter_Clauses__c; 
            }

            //RelatedObj1
            if(response.Related_Object1_API_Name__c && response.ShowRelObj1Lookup === 'true'){
                this.showLookupRelatedField1 = true;
                this.showLookupRelatedFieldAPIName1 = response.Related_Object1_API_Name__c;
            }else{
                this.showLookupRelatedField1 = false;
            }

            if(response.Related_Object1_Label__c){
                this.showLookupRelatedLabel1 = response.Related_Object1_Label__c;
            }

            if(response.Related_Object1_Filter_Clauses__c){
               this.showLookupRelatedFieldFilterCriteria1 = response.Related_Object1_Filter_Clauses__c; 
            }

             //RelatedObj2
            if(response.Related_Object2_API_Name__c && response.ShowRelObj2Lookup === 'true'){
                this.showLookupRelatedField2 = true;
                this.showLookupRelatedFieldAPIName2 = response.Related_Object2_API_Name__c;
            }else{
                this.showLookupRelatedField2 = false;
            }

            if(response.Related_Object2_Label__c){
                this.showLookupRelatedLabel2 = response.Related_Object2_Label__c;
            }

            if(response.Related_Object2_Filter_Clauses__c){
               this.showLookupRelatedFieldFilterCriteria2 = response.Related_Object2_Filter_Clauses__c; 
            }

             //RelatedObj3
            if(response.Related_Object3_API_Name__c && response.ShowRelObj3Lookup === 'true'){
                this.showLookupRelatedField3 = true;
                this.showLookupRelatedFieldAPIName3 = response.Related_Object3_API_Name__c;
            }else{
                this.showLookupRelatedField3 = false;
            }

            if(response.Related_Object3_Label__c){
                this.showLookupRelatedLabel3 = response.Related_Object3_Label__c;
            }

            if(response.Related_Object3_Filter_Clauses__c){
               this.showLookupRelatedFieldFilterCriteria3 = response.Related_Object3_Filter_Clauses__c; 
            }
        });
        // let selectedDocumentId = event.target.value;
        // let selectedDocument;
        // this.iframeURL = '';
        // for(let i=0; i<this.documentConfigs.length; i++) {
        //     if(this.documentConfigs[i].Doc_Generate_URL__c) {
        //         this.iframeURL = this.documentConfigs[i].Doc_Generate_URL__c;
        //     }
        // }
    }

    generateDocument() {
        let validateResult = this.validateLookupValue();
        if(validateResult == true){
            let paramMap = {};
            paramMap['relatedObj1Id'] = this.selectedRecordId1;
            paramMap['relatedObj2Id'] = this.selectedRecordId2;
            paramMap['relatedObj3Id'] = this.selectedRecordId3;
            paramMap['defaultRecordId'] = this.recordId;
            paramMap['primaryRecId'] = this.selectedRecordId;
            paramMap['seclectedDocId'] = this.selectedDocumentId;

            this.executeAction(updateRelatedObj, paramMap, (response)=>{
                console.log('Result Block updateRelatedObj ===='+response);
                let newUpdateIframURL = new URL(this.iframeURL,'https://javascript.info');
                
                if(newUpdateIframURL) {
                    newUpdateIframURL.searchParams.set('recordId', this.selectedRecordId != null ? this.selectedRecordId : this.recordId);
                    newUpdateIframURL.searchParams.set('Project__c.Id', this.selectedRecordId != null ? this.selectedRecordId : this.recordId);
                    newUpdateIframURL.searchParams.set('%7BRecordId%7D', this.selectedRecordId != null ? this.selectedRecordId : this.recordId);
                     //this.iframeURL = this.iframeURL.replace('Project__c.Id',  this.selectedRecordId != null ? this.selectedRecordId : this.recordId);
                    // this.iframeURL = this.iframeURL.replace('%7BRecordId%7D', this.selectedRecordId != null ? this.selectedRecordId : this.recordId);
                   // this.iframeURL = this.iframeURL.replace('recordId', this.selectedRecordId != null ? this.selectedRecordId : this.recordId);
                }
                const iframeVal = newUpdateIframURL.toString().replace('https://javascript.info','');
                console.log('iframe URL ==='+iframeVal);
                const generateDocEvent = new CustomEvent('generateClicked', {
                    detail: {iframeVal},
                });

                // Fire the custom event
                this.dispatchEvent(generateDocEvent); 
            });
        }
    }

    validateLookupValue(){
        console.log('#selectedDocumentId :',this.selectedDocumentId);
        if(this.selectedDocumentId == undefined ){
            this.showErrorNotification('Error', 'Please select Document from the dropdown');
            return false;
        }

        if(this.selectedRecordId == undefined && this.showLookupField){
            this.showErrorNotification('Validation for Primary Lookup','Please Select value from Related lookup1');
            return false;
        }

        if(this.selectedRecordId1 == undefined  &&  this.showLookupRelatedField1 == true){
            this.showErrorNotification('Validation for Related Lookup1','Please Select value from Related lookup1');
            return false;
        }

        if(this.selectedRecordId2 == undefined &&  this.showLookupRelatedField2 == true){
            this.showErrorNotification('Validation for Related Lookup2','Please Select value from Related lookup2');
            return false;
        }

        if(this.selectedRecordId3 == undefined &&  this.showLookupRelatedField3 == true){
            this.showErrorNotification('Validation for Related Lookup3','Please Select value from Related lookup3');
            return false;
        }

        // this.template.querySelectorAll('c-lookup').forEach(element => {
        //     element.reportValidity();
        // });  
        // let searchlookup1 = this.template.querySelector('.showlookup1');

        // if(this.selectedRecordId1 == undefined){
        //     searchlookup1.setCustomValidity('Name1 value is required');
        // } else{
        //     searchlookup1.setCustomValidity('');
        // }
        // searchlookup1.reportValidity();

        // if(searchlookup2 == undefined){
        //     searchlookup2.setCustomValidity("Name2 value is required");
        // } 
        // searchlookup2.reportValidity();

        // if(searchlookup3 == undefined){
        //     searchlookup3.setCustomValidity("Name3 value is required");
        // } 
        // searchlookup3.reportValidity();
        return true;
    }

    clearSelection(event){
       
       
        this.template.querySelectorAll('lightning-combobox').forEach(each => {
            each.value = null;
            
        });
        this.selectedDocumentId = undefined;
        this.showLookupField = false;
        this.showLookupRelatedField1 = false;
        this.showLookupRelatedField2 = false;
        this.showLookupRelatedField3 = false;
        this.selectedRecordId = undefined;
        this.selectedRecordId1 = undefined;
        this.selectedRecordId2 = undefined;
        this.selectedRecordId3 = undefined;
        // //this.template.querySelector('[data-lookup='+this.showLookupFieldAPIName+']').setSearchResults(undefined);
        // this.cleanSearchTerm = newSearchTerm.trim().replace(/\*/g, '');
        // event.detail.searchTerm = '';
    }

    handlePrimaryRecordSearch(event){
        console.log('event------------',event.detail.searchTerm);
        apexSearchPrimaryObject({searchTerm: event.detail.searchTerm, 'searchFilterClauses':this.showLookupFieldFilterCriteria, 'searchObjAPIName':this.showLookupFieldAPIName,
                                'mergeRecIdReplacer':this.recordId})
        .then((results) => {
            console.log('results----', results);
            this.template.querySelector('[data-lookup='+this.showLookupFieldAPIName+']').setSearchResults(results);
        })
        .catch((error) => {
            this.error('Lookup Error', 'An error occured while searching with the lookup field.');
            console.error('Lookup error', JSON.stringify(error));
            this.errors = [error];
        });
    }

    handlePrimaryRecordSearchChange(response){
       
        if(response.detail){
            this.selectedRecordId = response.detail.selectedItem.id;
            //this.getCloseOutTask();
        }else{
           
            this.selectedRecordId = undefined;
           
           // this.template.querySelector('[data-lookup='+this.showLookupFieldAPIName+']').setSearchResults(undefined);
           // this.clearSelection();
        }
    }

    handleRelatedRecord1Search(event){
        console.log('event------------',event.detail.searchTerm);
        apexSearchPrimaryObject({searchTerm: event.detail.searchTerm, 'searchFilterClauses':this.showLookupRelatedFieldFilterCriteria1, 'searchObjAPIName':this.showLookupRelatedFieldAPIName1,
                                'mergeRecIdReplacer':this.recordId})
        .then((results) => {
            console.log('results----', results);
            this.template.querySelector('[data-lookup='+this.showLookupRelatedFieldAPIName1+']').setSearchResults(results);
        })
        .catch((error) => {
            this.error('Lookup Error', 'An error occured while searching with the lookup field.');
            console.error('Lookup error', JSON.stringify(error));
            this.errors = [error];
        });
    }

    handleRelatedRecord1SearchChange(response){
        if(response.detail){
            this.selectedRecordId1 = response.detail.selectedItem.id;
            //this.getCloseOutTask();
        }else{
            this.selectedRecordId1 = undefined;
            this.clearSelection();
        }
    }

    handleRelatedRecord2Search(event){
        console.log('event------------',event.detail.searchTerm);
        apexSearchPrimaryObject({searchTerm: event.detail.searchTerm, 'searchFilterClauses':this.showLookupRelatedFieldFilterCriteria2, 'searchObjAPIName':this.showLookupRelatedFieldAPIName2,
                                'mergeRecIdReplacer':this.recordId})
        .then((results) => {
            console.log('results----', results);
            this.template.querySelector('[data-lookup='+this.showLookupRelatedFieldAPIName2+']').setSearchResults(results);
        })
        .catch((error) => {
            this.error('Lookup Error', 'An error occured while searching with the lookup field.');
            console.error('Lookup error', JSON.stringify(error));
            this.errors = [error];
        });
    }

    handleRelatedRecord2SearchChange(response){
        if(response.detail){
            this.selectedRecordId2 = response.detail.selectedItem.id;
            //this.getCloseOutTask();
            /*if(showLookupRelatedLabel2  == 'Amendment Request' && showLookupRelatedLabel1 == 'Payment Request'){
                handleRelatedObjRel({'defaultRecId':this.recordId, 'relObj1':this.selectedRecordId1, 'relObj2':this.selectedRecordId2})
                .then((results) => {
                    console.log('results Search Change2----', results);
                })
                .catch((error) => {
                    this.error('Lookup Error', 'An error occured Related Comparison.');
                    console.error('Lookup error', JSON.stringify(error));
                    this.errors = [error];
                })
            }*/
        }else{
            this.selectedRecordId2 = undefined;
            this.clearSelection();
        }
    }

    handleRelatedRecord3Search(event){
        console.log('event------------',event.detail.searchTerm);
        apexSearchPrimaryObject({searchTerm: event.detail.searchTerm, 'searchFilterClauses':this.showLookupRelatedFieldFilterCriteria3, 'searchObjAPIName':this.showLookupRelatedFieldAPIName3,
                                'mergeRecIdReplacer':this.recordId})
        .then((results) => {
            console.log('results----', results);
            this.template.querySelector('[data-lookup='+this.showLookupRelatedFieldAPIName3+']').setSearchResults(results);
        })
        .catch((error) => {
            this.error('Lookup Error', 'An error occured while searching with the lookup field.');
            console.error('Lookup error', JSON.stringify(error));
            this.errors = [error];
        });        
    }

    handleRelatedRecord3SearchChange(response){
        if(response.detail){
            this.selectedRecordId3 = response.detail.selectedItem.id;
            //this.getCloseOutTask();
        }else{
            this.selectedRecordId3 = undefined;
            this.clearSelection();
        }
    }
}