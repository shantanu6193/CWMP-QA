import { LightningElement,track,api,wire  } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import ORDER_OBJECT from '@salesforce/schema/Order__c';
import COUNTY_CASE_FIELD from '@salesforce/schema/Order__c.What_is_the_county_s_7_day_case_rate__c';
import EDD_AVAILABLE_COUNTY_FIELD from '@salesforce/schema/Order__c.ICU_beds_available_in_the_County__c';
//import POPULATION_DENSITY_FIELD from '@salesforce/schema/Order__c.What_is_the_county_s_population_density__c';
//import POPULATION_YEARS_FIELD from '@salesforce/schema/Order__c.Population_65_years_old_in_county__c'; 
//import SPECIALITY_CENTER_FIELD from '@salesforce/schema/Order__c.Is_the_facility_a_specialty_center__c';
import PERSONNEL_FIELD from '@salesforce/schema/Order__c.Personnel__c';
import COUNTY_POPULATION_FIELD from '@salesforce/schema/Order__c.What_of_County_population_vaccinated__c'; 
import HOSPOTAL_BURDEN_FIELD from '@salesforce/schema/Order__c.Hospital_Burden_Score__c';
import submitRequest from '@salesforce/apex/PHOSMACSQuestions_Ctrl.submitRequest';
import getRecordData from '@salesforce/apex/PHOSMACSQuestions_Ctrl.getRecordData';
import isCommunityUser from '@salesforce/apex/ApexUtils.checkCommunityUser';
import Utility from 'c/utility';
import { getRecord } from 'lightning/uiRecordApi';

const FIELDS = [PERSONNEL_FIELD,COUNTY_CASE_FIELD,EDD_AVAILABLE_COUNTY_FIELD,COUNTY_POPULATION_FIELD,HOSPOTAL_BURDEN_FIELD];
export default class PhosMACSQuestions extends Utility {
    communityUser;
    @api recordId;
    confirmCompliance;
    initData() {
        this.executeAction(isCommunityUser, {}, (response) => {
            this.communityUser = response;
        });
    }

    @wire(getRecord, {recordId: '$recordId', fields: FIELDS})
    receiveRecord({error, data}) {
        if (error) {
             console.log('--Error--',error);
        } else if (data) {
            this.refreshData();
        }
    }
    
    refreshData() {
        this.executeAction(getRecordData, {'recordId' : this.recordId}, (response) => {
            this.recordLocal = response;
            if(this.recordLocal.Confirm_Compliance_Checkboxes__c)
            this.confirmCompliance=this.recordLocal.Confirm_Compliance_Checkboxes__c.replaceAll(";","\n")
        });
    }

    get showSupplementalQuestions() {
        if(this.recordLocal.Type_of_Personnel__c == 'Medical Personnel' || this.recordLocal.Type_of_Personnel__c == 'Vaccination-related Personnel')
            return true;
        return false;
    }
    get showMedicalQuestions() {
        if(this.recordLocal.Type_of_Personnel__c == 'Medical Personnel')
            return true;
        return false;
    }

    get showVaccineQuestions() {
        if(this.recordLocal.Type_of_Personnel__c == 'Vaccination-related Personnel')
            return true;
        return false;
    }

    @wire(getObjectInfo, { objectApiName: ORDER_OBJECT })
    objectInfo;

    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: COUNTY_CASE_FIELD
    })
    question1PicklistValues;

    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: EDD_AVAILABLE_COUNTY_FIELD
    })
    question2PicklistValues;

    /*@wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: POPULATION_DENSITY_FIELD
    })
    question3PicklistValues;

    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: POPULATION_YEARS_FIELD
    })
    question4PicklistValues;

    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: SPECIALITY_CENTER_FIELD
    })
    question5PicklistValues;*/
    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: COUNTY_POPULATION_FIELD
    })
    question6PicklistValues;
    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: HOSPOTAL_BURDEN_FIELD
    })
    question7PicklistValues;

    handleReset(){
        //this.template.querySelector('form').reset();
        let fieldsToBlank = ['What_is_the_county_s_7_day_case_rate__c','ICU_beds_available_in_the_County__c','What_is_the_county_s_population_density__c','Population_65_years_old_in_county__c','Is_the_facility_a_specialty_center__c','What_of_County_population_vaccinated__c','Hospital_Burden_Score__c'];
        for(var i=0; i < fieldsToBlank.length; i++) {
            this.setFieldsToBlank(fieldsToBlank[i]);
        }
    }

    submit(){
        const allValid = this.validateInputs();
        if (allValid){
                this.executeAction(submitRequest, {'recordData' : JSON.stringify(this.recordLocal), 'recordId' : this.recordId}, (response) => {
                this.showNotification('Success', 'Supplemental Questions submitted successfully', 'success', 'sticky');
            });
        }    
    }
     get isGACH() {
        if(this.recordLocal.Is_this_for_a_GACH__c == 'Yes')
            return true;
        return false;
    }

    get languagePreferred() {
        if(this.recordLocal.Specific_language_preferred__c == 'Yes')
            return true;
        return false;
    }

    get otherVaccinationSite() {
        if(this.recordLocal.Vaccination_site_type__c == 'Other')
            return true;
        return false;
    }

    get dosePlan() {
        if(this.recordLocal.X2nd_Dose_plan_in_place__c == 'Yes')
            return true;
        return false;
    }

    get stateHelped() {
        if(this.recordLocal.Has_state_previously_helped__c == 'Yes')
            return true;
        return false;
    }
}