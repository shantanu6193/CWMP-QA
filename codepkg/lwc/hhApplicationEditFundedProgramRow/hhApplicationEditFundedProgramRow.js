/**
 * Created by StackNexus Admin on 23-08-2021.
 */

import { LightningElement,api,wire,track } from 'lwc';
import { getObjectInfo ,getPicklistValues } from 'lightning/uiObjectInfoApi';
import FundedProgram_Object from '@salesforce/schema/Funded_Program__c';
import ProgramName from '@salesforce/schema/Funded_Program__c.Program_Name__c';
import HH_EN_Prior_Date_Validaton from '@salesforce/label/c.HH_EN_Prior_Date_Validaton'; 

import Utility from 'c/utility';

export default class HhApplicationEditFundedProgramRow extends Utility {
    @api index;
    isMobile = false;
    @track ProgramNamePicklistValues;
    @wire(getObjectInfo, { objectApiName: FundedProgram_Object }) objectInfo;
    @wire(getPicklistValues, {recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: ProgramName}) ProgramNameList;
    programNameLabel = '';
    @track label = {
        HH_EN_Prior_Date_Validaton
    }

    initData() {
        console.log('===',this.recordLocal);
        let width = window.screen.width;
        if(width < 800) {
            this.isMobile = true;
    }
        else {
            this.isMobile = false;
        }
        window.addEventListener('resize', this.checkDeviceWidth);
    }

    checkDeviceWidth = () => {
        let width = window.screen.width;
        if(width < 800) {
            this.isMobile = true;
        }
        else {
            this.isMobile = false;
        }
    };

    addNewRow(event){
        event.preventDefault();
        let item = {};
        const addEvent = new CustomEvent('added', { detail: {recordData:item}});
        this.dispatchEvent(addEvent);
    }

    deleteRow(event){
        event.preventDefault();
        console.log('index----',this.index);
        const deleteEvent = new CustomEvent('deleted', { detail: {index:this.index }});
        this.dispatchEvent(deleteEvent);
    }

    get todaysDate() {
		var today = new Date();
		var dd = String(today.getDate()).padStart(2, '0');
		var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
		var yyyy = today.getFullYear();
		today = yyyy+'-'+mm+'-'+dd;
		return today
	}


    programNameChanged (event) {
        this.programNameLabel = '';
        console.log('ProgramNameList: '+this.ProgramNameList);
        if(this.ProgramNameList.data.values) {
            this.ProgramNameList.data.values.forEach(selectionList => {
                if(selectionList.value == event.target.value) {
                    console.log('Selected: ',selectionList);
                    this.programNameLabel = selectionList.label;
                }
            });
        }
        this.recordLocal.Program_Name__c = event.target.value;
    }

    get otherProgramTitle() {
            return this.recordLocal.Other_Program_Name__c == undefined ? '': this.recordLocal.Other_Program_Name__c ; 
    } 

    
}