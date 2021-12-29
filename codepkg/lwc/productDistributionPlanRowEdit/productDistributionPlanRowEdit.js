/**
 * Created by Shivraj on 27-08-2020.
 */

import { LightningElement, api, wire } from 'lwc';
import Utility from 'c/utility';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import FACILITY_CATEGORY_FIELD from '@salesforce/schema/Account.Facility_Category__c';
import getCounty from '@salesforce/apex/PHOS_DistributionCtrl.getCounty';

export default class ProductDistributionPlanRowEdit extends Utility {
    currentIndex = 1;
    countyList = [];
    countyOptions = [];
    totalActualQuantityDistribution;
    totalProposedQuantityDistribution;
    isAsc = true;
    isDsc = false;
    sortedDirection = 'asc';
    sortedColumn;

    @wire(getObjectInfo, { objectApiName: ACCOUNT_OBJECT }) objectInfo;
    @wire(getPicklistValues, {recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: FACILITY_CATEGORY_FIELD}) facilityCategoryPicklistValues;

    /*
    * Sets index to each recordLocal.Product_Distribution_Plans__r record if recordLocal.Product_Distribution_Plans__r not empty
    */
    initData() {
        if(this.recordLocal != undefined && this.recordLocal.Product_Distribution_Plans__r == undefined) {
            //this.recordLocal.Product_Distribution_Plans__r = [];
            //this.recordLocal.Product_Distribution_Plans__r.push({index : 0});
        } else if(this.recordLocal != undefined && this.recordLocal.Product_Distribution_Plans__r != undefined) {
            for(let i =0; i<this.recordLocal.Product_Distribution_Plans__r.length; i++) {
                this.recordLocal.Product_Distribution_Plans__r[i].index = this.currentIndex;
                this.currentIndex++;
            }
        }
        this.skipCustomLogicValidation = true;

        this.executeAction(getCounty, {}, (response) => {
        this.countyList = response.CountyList;
        let countyValues = [];
        for(let i = 0; i < this.countyList.length; i++) {
          countyValues.push({
              label: this.countyList[i].Name,
              value: this.countyList[i].Id
          })
        }
        this.countyOptions = countyValues;
        });

    }

    /*
    * Checks recordLocal.Product_Distribution_Plans__r is empty or not
    */
    get hasData() {
        if(this.recordLocal == undefined || this.recordLocal.Product_Distribution_Plans__r == undefined) {
            return false;
        }
        return true;
    }

    /*
    * Add empty row with index 0
    */
    addFirstPlan(event) {
        this.recordLocal.Product_Distribution_Plans__r = [];
        this.recordLocal.Product_Distribution_Plans__r.push({index : 0});
    }

    /*
    * Add empty row
    */
    handleAddPlan(response) {
        this.recordLocal.Product_Distribution_Plans__r.push({index : this.currentIndex});
        this.currentIndex++;
    }

    /*
    * Delete selected row
    */
    handleDeletePlan(response){
        let childIndex = response.detail.index;
        if(this.recordLocal.Product_Distribution_Plans__r.length > 1) {
            this.recordLocal.Product_Distribution_Plans__r.splice(childIndex, 1);
        } else if(this.recordLocal.Product_Distribution_Plans__r.length == 1) {
            this.recordLocal.Product_Distribution_Plans__r = undefined;
            //this.recordLocal.Product_Distribution_Plans__r.splice(childIndex, 1);
            //this.recordLocal.Product_Distribution_Plans__r.push({});
        }

    }

    /*
    * Get records from child component
    */
    updateLisToParentComponentList() {
        if(this.recordLocal.Product_Distribution_Plans__r != undefined) {
            for(let i=0; i<this.recordLocal.Product_Distribution_Plans__r.length; i++) {
                let planRec = this.template.querySelector('[data-id="'+i+'"]').getRecordDetails();
                //console.log('planRec------',planRec);
                if(planRec == undefined) {
                    return undefined;
                }
                //delete planRec.index;
                this.recordLocal.Product_Distribution_Plans__r[i] = planRec;
            }
        }
        //console.log('this.recordLocal---', JSON.stringify(this.recordLocal));
        return this.recordLocal;
    }

    /*
    * Get records from child component
    */
    updateRecordLocal() {
        this.allInputsValidated = true;
        let recordLocal = this.updateLisToParentComponentList();
        if(recordLocal == undefined) {
            this.allInputsValidated = false;
        } else {
            this.recordLocal = recordLocal;
        }
    }

    handleProposedQuantityChange(response) {
        this.totalProposedQuantityDistribution = 0;
        this.recordLocal.Total_Proposed_Quantity__c = 0;
        let recordList =  this.template.querySelectorAll('[data-custom="innerComponent"]');
        for(let i=0; i<recordList.length; i++) {
            let planRec = recordList[i].getRecordLocal();
            if(planRec.Proposed_Quantity_Distribution__c) {
                this.totalProposedQuantityDistribution = this.totalProposedQuantityDistribution + parseFloat(planRec.Proposed_Quantity_Distribution__c);
            }
        }
        this.recordLocal.Total_Proposed_Quantity__c = this.totalProposedQuantityDistribution;
    }

    handleActualQuantityChange(response) {
        this.totalActualQuantityDistribution = 0;
        this.recordLocal.Total_Actual_Quantity__c = 0;
        let recordList =  this.template.querySelectorAll('[data-custom="innerComponent"]');
        for(let i=0; i<recordList.length; i++) {
            let planRec = recordList[i].getRecordLocal();
            if(planRec.Actual_Quantity_Distribution__c) {
                this.totalActualQuantityDistribution = this.totalActualQuantityDistribution + parseFloat(planRec.Actual_Quantity_Distribution__c);
            }
        }
        this.recordLocal.Total_Actual_Quantity__c = this.totalActualQuantityDistribution;
    }

    sortName(event) {
        try{
            //this.sortedDirection = 'desc';
            this.sortData(event.currentTarget.dataset.sortName);

        }
        catch(e) {
            console.log(e);
        }
    }

    sortData(sortColumnName) {
        try{
            // check previous column and direction
        console.log('this.sortedDirection-----',this.sortedDirection);
        if (this.sortedColumn === sortColumnName) {
            this.sortedDirection = this.sortedDirection === 'asc' ? 'desc' : 'asc';
        }
        else {
            this.sortedDirection = 'desc';
        }

        // check arrow direction
        if (this.sortedDirection === 'asc') {
            this.isAsc = true;
            this.isDsc = false;
        }
        else {
            this.isAsc = false;
            this.isDsc = true;
        }

        // check reverse direction
        let isReverse = this.sortedDirection === 'asc' ? 1 : -1;

        this.sortedColumn = sortColumnName;

        // sort the data
        console.log('this.recordLocal.Product_Distribution_Plans__r bef-------------',this.recordLocal.Product_Distribution_Plans__r );
        this.recordLocal.Product_Distribution_Plans__r = JSON.parse(JSON.stringify(this.recordLocal.Product_Distribution_Plans__r)).sort((a, b) => {
            a = a[sortColumnName] ? a[sortColumnName].toLowerCase() : ''; // Handle null values
            b = b[sortColumnName] ? b[sortColumnName].toLowerCase() : '';

            return a > b ? 1 * isReverse : -1 * isReverse;
        });;
        console.log('this.recordLocal.Product_Distribution_Plans__r aft-------------',this.recordLocal.Product_Distribution_Plans__r );
        }
        catch(e) {
            console.log(e);
        }
    }

}