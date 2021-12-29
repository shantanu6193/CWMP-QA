import { LightningElement, api, track, wire } from 'lwc';
import Utility from 'c/utility';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import PRE_APPLICATION_OBJECT from '@salesforce/schema/Pre_Application__c';
import Proposed_project_area_documented_FIELD from '@salesforce/schema/Pre_Application__c.Proposed_project_area_documented__c';
import Project_location_have_the_hazard_FIELD from '@salesforce/schema/Pre_Application__c.Project_location_have_the_hazard__c';
import LHMP_Development_Status_FIELD from '@salesforce/schema/Pre_Application__c.LHMP_Development_Status__c';
import Activity_in_Mitigation_Plan_FIELD from '@salesforce/schema/Pre_Application__c.Activity_in_Mitigation_Plan__c';
import Does_your_entity_have_an_active_LHMP_FIELD from '@salesforce/schema/Pre_Application__c.Does_your_entity_have_an_active_LHMP__c';


export default class HmaNOIActivityInfo extends Utility {
    /*showBenefitActivitySection = false;
    showLocalHazardSection = false;*/
    @track appMatch = false;
    showDateField = true;
    recordTypeId;
    recordTypeName;
    @wire(getObjectInfo, { objectApiName: PRE_APPLICATION_OBJECT }) objectInfo;
    @wire(getPicklistValues, { recordTypeId: '$recordTypeId', fieldApiName: Proposed_project_area_documented_FIELD}) projectDocumentedPicklistValues;
    @wire(getPicklistValues, { recordTypeId: '$recordTypeId', fieldApiName: Project_location_have_the_hazard_FIELD}) locationHazardPicklistValues;
    @wire(getPicklistValues, { recordTypeId: '$recordTypeId', fieldApiName: LHMP_Development_Status_FIELD}) lhmpStatusPicklistValues;
    @wire(getPicklistValues, { recordTypeId: '$recordTypeId', fieldApiName: Activity_in_Mitigation_Plan_FIELD}) activityMitigationPicklistValues;
    @wire(getPicklistValues, { recordTypeId: '$recordTypeId', fieldApiName: Does_your_entity_have_an_active_LHMP_FIELD}) activeLHMPPicklistValues;

    
    get activeLHMPValue(){
        if(this.recordLocal.Does_your_entity_have_an_active_LHMP__c == 'Yes') {
            return false;
        }
        if(this.recordLocal.Does_your_entity_have_an_active_LHMP__c == 'No') {
            return true;
        } 
    }

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

    initData(){
        if(this.recordLocal.RecordTypeId != undefined || this.recordLocal.RecordTypeId != null) {
            this.recordTypeId = this.recordLocal.RecordTypeId;
            this.recordTypeName = this.recordLocal.RecordType.Name;
            console.log('recordTypeId----',this.recordTypeId);
            console.log('recordTypeName----',this.recordTypeName);
        }
        if((this.recordLocal.Application_Type__c == 'Project' || this.recordLocal.Application_Type__c != 'Community Flood Mitigation Project' || this.recordLocal.Application_Type__c != 'Individual Flood Mitigation Project') && this.recordLocal.Applicant_Type__c == 'Private Non-Profit') {
            let fieldsToBlank = ['Does_your_entity_have_an_active_LHMP__c','LHMP_Approval_Date__c','LHMP_Development_Status__c','Activity_in_Mitigation_Plan__c'];
            for(var i=0; i < fieldsToBlank.length; i++) {
                this.setFieldsToBlank(fieldsToBlank[i]);
            }
        }
        if((this.recordLocal.Application_Type__c != 'Project' && this.recordLocal.Application_Type__c != 'Community Flood Mitigation Project' && this.recordLocal.Application_Type__c != 'Individual Flood Mitigation Project') && this.recordLocal.Applicant_Type__c != 'Private Non-Profit') {
            let fieldsToBlank = ['Proposed_project_area_documented__c','If_yes_proposed_project__c','Project_location_have_the_hazard__c','If_yes_project_location__c'];
            for(var i=0; i < fieldsToBlank.length; i++) {
                this.setFieldsToBlank(fieldsToBlank[i]);
            }
        }

        if((this.recordLocal.Application_Type__c != 'Project' && this.recordLocal.Application_Type__c != 'Community Flood Mitigation Project' && this.recordLocal.Application_Type__c != 'Individual Flood Mitigation Project') && this.recordLocal.Applicant_Type__c == 'Private Non-Profit') {
            let fieldsToBlank = ['Proposed_project_area_documented__c','If_yes_proposed_project__c','Project_location_have_the_hazard__c','If_yes_project_location__c','Does_your_entity_have_an_active_LHMP__c','LHMP_Approval_Date__c','LHMP_Development_Status__c','Activity_in_Mitigation_Plan__c'];
            for(var i=0; i < fieldsToBlank.length; i++) {
                this.setFieldsToBlank(fieldsToBlank[i]);
            }
        }
    }

    activeLHMPfieldChanged(event){
        this.recordLocal.Does_your_entity_have_an_active_LHMP__c = event.target.value;
        if(this.recordLocal.Does_your_entity_have_an_active_LHMP__c == 'No') {
            this.recordLocal.LHMP_Approval_Date__c = null;
        }
        this.showDateField = false;
        setTimeout(() => {
            this.showDateField = true;
        }, 100);
    }

    activityFieldChanged(event){
        this.recordLocal.Total_Activity_Cost__c = event.target.value;
        this.recordLocal.Applicant_Match__c = (this.recordLocal.Total_Activity_Cost__c * 25)/100;
        this.recordLocal.Federal_Request_Share__c = (this.recordLocal.Total_Activity_Cost__c * 75)/100;

        this.recordLocal.Percentage_of_Applicant_Match__c = (this.recordLocal.Applicant_Match__c / this.recordLocal.Total_Activity_Cost__c) * 100;
        this.recordLocal.Percentage_of_Federal_Request_Share__c = (this.recordLocal.Federal_Request_Share__c / this.recordLocal.Total_Activity_Cost__c) * 100;
    }
    
    appFieldChanged(event){
        let inputCmp = this.template.querySelector('.input1');
        this.recordLocal.Applicant_Match__c = event.target.value;
        /*let percentValue = (this.recordLocal.Applicant_Match__c / this.recordLocal.Total_Activity_Cost__c) * 100;
        console.log(percentValue);
        if(percentValue < 25){
            this.appMatch = true;
            inputCmp.setCustomValidity("Subapplicant Match must be at least 25%.");
        } else {
            this.appMatch = false;
            inputCmp.setCustomValidity("");
        }*/
        this.recordLocal.Federal_Request_Share__c = (this.recordLocal.Total_Activity_Cost__c - this.recordLocal.Applicant_Match__c);
        
        this.recordLocal.Percentage_of_Applicant_Match__c = (this.recordLocal.Applicant_Match__c / this.recordLocal.Total_Activity_Cost__c) * 100;
        this.recordLocal.Percentage_of_Federal_Request_Share__c = (this.recordLocal.Federal_Request_Share__c / this.recordLocal.Total_Activity_Cost__c) * 100;
    }

    validateCustomInput(){
        console.log('---this.appMatch',this.appMatch);
        if(this.appMatch == true) return false;
        else return true;
    }
    get getApplicantType(){
        if(this.recordLocal.Applicant_Type__c == 'Private Non-Profit') {
            return false;
        }
        return true;
    }
    get getApplicationType(){
        if(this.recordLocal.Application_Type__c == 'Project' || this.recordLocal.Application_Type__c == 'Community Flood Mitigation Project' || this.recordLocal.Application_Type__c == 'Individual Flood Mitigation Project') {
            return true;
        }
        return false;
    }

    get showProposedProjectField(){
        if(this.recordLocal.Proposed_project_area_documented__c == 'Yes') {
            return true;
        }
        else if(this.recordLocal.Proposed_project_area_documented__c == 'No') {
            this.Proposed_project_area_documented__c = '';
        }
        return false;
    }
    get showProjectlocationField(){
        if(this.recordLocal.Project_location_have_the_hazard__c == 'Yes') {
            return true;
        }
        else if(this.recordLocal.Project_location_have_the_hazard__c == 'No') {
            this.If_yes_project_location__c = '';
        }
        return false;
    }

    get hideFieldsForBRICAndFMA() {
        if((this.recordTypeName == 'BRIC' && this.recordLocal.Applicant_Type__c == 'Capability and Capacity Building (C&CB)') ||
           (this.recordTypeName == 'FMA' && (this.recordLocal.Applicant_Type__c == 'Flood Hazard Mitigation Planning'|| this.recordLocal.Applicant_Type__c == 'Project Scoping'))) {
            return false;
        }
        return true;
    }
}