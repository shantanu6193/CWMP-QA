import { LightningElement, api, track, wire } from 'lwc';
import Utility from 'c/utility';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import PREAPPILCATION from '@salesforce/schema/Pre_Application__c';
import COUNTY_FIELD from '@salesforce/schema/Pre_Application__c.County__c';
import APPTYPE_FIELD from '@salesforce/schema/Pre_Application__c.Application_Type__c';
import PROJECTTYPE_FIELD from '@salesforce/schema/Pre_Application__c.Project_Type__c';
import HAZARD_FIELD from '@salesforce/schema/Pre_Application__c.Hazard__c';
import APPLICANT_FIELD from '@salesforce/schema/Pre_Application__c.Applicant_Type__c';
import REGION_FIELD from '@salesforce/schema/Pre_Application__c.Region__c';
import STATE_FIELD from '@salesforce/schema/Pre_Application__c.State__c';
import SUBAPPLICANT_COMM_FIELD from '@salesforce/schema/Pre_Application__c.Subapplicant_a_small_community__c';
import getContact from '@salesforce/apex/HMANOIRequest_Ctrl.getCommunityContact';

export default class HmaNOIGeneralInfo extends Utility{
    projectValues;
    hazardValues;
    projectTypePicklist;
    hazardPicklist;
    regionPicklist;
    regionValues;
    statePicklist;
    disabledHazard = false;
    showEINField = true;
    @api recordTypeId;
    @api recordTypeName;
    
    disabledProjectType = false;

    get recordTypeBRIC() {
        if(this.recordTypeName == 'BRIC') {
            return true;
        }
        return false;
    }
    get recordTypeFMA() {
        if(this.recordTypeName == 'FMA') {
            return true;
        }
        return false;
    }
    get recordTypeHMGP() {
        if(this.recordTypeName == 'HMGP') {
            return true;
        }
        return false;
    }
    @wire(getObjectInfo, { objectApiName: PREAPPILCATION }) objectInfo;
    @wire(getPicklistValues, { recordTypeId: '$recordTypeId', fieldApiName: COUNTY_FIELD}) countyPicklist;
    @wire(getPicklistValues, { recordTypeId: '$recordTypeId', fieldApiName: APPTYPE_FIELD}) appTypePicklist;
    @wire(getPicklistValues, { recordTypeId: '$recordTypeId', fieldApiName: APPLICANT_FIELD}) applicantPicklist;
    @wire(getPicklistValues, { recordTypeId: '$recordTypeId', fieldApiName: STATE_FIELD}) statePicklist;
    @wire(getPicklistValues, { recordTypeId: '$recordTypeId', fieldApiName: SUBAPPLICANT_COMM_FIELD}) subapplicantCommPicklist;
   
    @wire(getPicklistValues, { recordTypeId: '$recordTypeId', fieldApiName: PROJECTTYPE_FIELD})
    projectTypeInfo({ data, error }) {
        if (data){
            this.projectTypePicklist = data;
            this.projectValues = data.values;
            if(this.recordLocal.Application_Type__c) {
                let key = this.projectTypePicklist.controllerValues[this.recordLocal.Application_Type__c];
                this.projectValues = this.projectTypePicklist.values.filter(opt => opt.validFor.includes(key)); 
            } else{
                this.projectValues = [];
                this.disabledProjectType = true;
            }
        }
    }
    @wire(getPicklistValues, { recordTypeId: '$recordTypeId', fieldApiName: HAZARD_FIELD})
    hazardInfo({ data, error }) {
        if (data){
            this.hazardPicklist = data;
            this.hazardValues = data.values;
        }
    }
    @wire(getPicklistValues, { recordTypeId: '$recordTypeId', fieldApiName: REGION_FIELD})
    regionInfo({ data, error }) {
        if (data){
            this.regionPicklist = data;
            this.regionValues = data.values;
        }
    }

    initData(){
        console.log('record id----',this.recordTypeId);
        console.log('record id----',this.recordTypeName);
        if(this.recordLocal.RecordTypeId != undefined || this.recordLocal.RecordTypeId != null) {
            this.recordTypeId = this.recordLocal.RecordTypeId;
            this.recordTypeName = this.recordLocal.RecordType.Name;
            console.log('recordTypeId----',this.recordTypeId);
            console.log('recordTypeName----',this.recordTypeName);
        }
        if(!this.recordLocal.State__c){
            this.recordLocal.State__c = 'CA';
        }
        this.executeAction(getContact, {}, (response) => {
            if(response){
                if(!this.recordLocal.First_Name_of_Person_Completing_NOI__c) this.recordLocal.First_Name_of_Person_Completing_NOI__c = response.FirstName;
                if(!this.recordLocal.Last_Name_of_Person_Completing_NOI__c ) this.recordLocal.Last_Name_of_Person_Completing_NOI__c = response.LastName;
                if(!this.recordLocal.Applicant_Name_Entity__c) this.recordLocal.Applicant_Name_Entity__c = response.Account.Name;
                if(!this.recordLocal.Requestor__c) this.recordLocal.Requestor__c = response.Id;   
            }
        });
        this.disabledHazard = true;
        if(this.recordTypeId) {
           this.recordLocal.RecordTypeId = this.recordTypeId;
        }
    }
    get isProjectTypeDisabled() {
        if(this.recordLocal.Application_Type__c) {
            return false;
        }
        return true;
    }
    get isHazardDisabled() {
        if(this.recordLocal.Project_Type__c) {
            return false;
        }
        return true;
    }
    get getApplicantType(){
        if(this.recordLocal.Applicant_Type__c == 'Private Non-Profit') {
            return true;
        }
        return false;
    }
    get getApplicant(){
        if(this.recordLocal.Applicant_Type__c == 'Private Non-Profit') {
            return false;
        }
        if(this.recordLocal.Applicant_Type__c != 'Private Non-Profit') {
            //this.recordLocal.EIN_For_Private_Non_Profits__c = '';
            return true;
        }
    }
  
    handleChangeCustom(event){
        this.recordLocal.Applicant_Type__c = event.target.value;
        if(this.recordLocal.Applicant_Type__c != 'Private Non-Profit') {
            this.recordLocal.EIN_For_Private_Non_Profits__c = null;
        }
        this.showEINField = false;
        setTimeout(() => {
            this.showEINField = true;
        }, 100);
    }
    handleChange(event){
        this.recordLocal.Application_Type__c = event.target.value;
        this.disabledProjectType = false;
        this.recordLocal.Project_Type__c = '';
        let key = this.projectTypePicklist.controllerValues[event.target.value];
        this.projectValues = this.projectTypePicklist.values.filter(opt => opt.validFor.includes(key)); 
        this.recordLocal.Hazard__c = '';  
    }

    handleChangeProjectType(event) {
        this.recordLocal.Project_Type__c = event.target.value;
        console.log('event.target.value-',event.target.value);
        console.log('----',this.recordLocal.Project_Type__c);
        this.recordLocal.Hazard__c = '';
        let keyHazard = this.hazardPicklist.controllerValues[event.target.value];
        this.hazardValues = this.hazardPicklist.values.filter(opt => opt.validFor.includes(keyHazard));
        if(this.hazardValues.length == 0) this.disabledHazard = true;
        else this.disabledHazard = false;
        //if(this.recordLocal.Application_Type__c == 'Planning') {
            if(this.hazardValues.length == 1) {
                this.recordLocal.Hazard__c = this.hazardValues[0].value;
                this.disabledHazard = false;
            } 
        //}
    }
    handleCountyChange(event){
        this.recordLocal.County__c = event.target.value;

        this.recordLocal.Region__c = '';
        let key = this.regionPicklist.controllerValues[event.target.value];
        this.regionValues = this.regionPicklist.values.filter(opt => opt.validFor.includes(key));
        this.recordLocal.Region__c = this.regionValues[0].value;
    }
    validateCustomInput(){
        return true;
    }
    get projectType(){
        if(this.recordTypeName == 'HMGP' && this.recordLocal.Application_Type__c == 'Project'){
            return true;
        }
        else{
            return false;
        }
    }
    get initiative(){
        if(this.recordTypeName == 'HMGP' && this.recordLocal.Application_Type__c == '5% Initiative'){
            return true;
        }
        else{
            return false;
        }
    }

    get projectTypeBRIC() {
            if(this.recordTypeName == 'BRIC' && this.recordLocal.Application_Type__c == 'Project'){
                return true;
            }
            else{
                return false;
            }
    }

    get bricCnCB() {
        if(this.recordTypeName == 'BRIC' && this.recordLocal.Application_Type__c == 'Capability and Capacity Building (C&CB)'){
            return true;
        }
        else{
            return false;
        }
    }

    get projectTypeFMA() {
        if(this.recordTypeName == 'FMA' && this.recordLocal.Application_Type__c == 'Individual Flood Mitigation Project'){
            return true;
        }
        else{
            return false;
        }
    }
    get projectTypeFMATable() {
        if(this.recordTypeName == 'FMA' && this.recordLocal.Application_Type__c == 'Community Flood Mitigation Project'){
            return true;
        }
        else{
            return false;
        }
    }
}