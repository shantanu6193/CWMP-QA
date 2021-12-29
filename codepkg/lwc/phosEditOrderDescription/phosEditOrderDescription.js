import { LightningElement,wire } from 'lwc';
import Utility from 'c/utility';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import ORDER_OBJECT from '@salesforce/schema/Order__c';
import GACH_FIELD from '@salesforce/schema/Order__c.Is_this_for_a_GACH__c';
import TRANSFER_PATIENTS_FIELD from '@salesforce/schema/Order__c.Have_you_attempted_to_transfer_patients__c';
import ADD_ICU_MST_BEDS_FIELD from '@salesforce/schema/Order__c.Allows_additional_ICU_or_M_S_T_beds__c';
import PERSONNEL_ICU_FIELD from '@salesforce/schema/Order__c.Does_site_need_personnel_to_keep_ICU__c';
//import TOTAL_ICU_BEDS_OCCUPIED_FIELD from '@salesforce/schema/Order__c.Total_ICU_beds_occupied__c';
import CANCELLED_SURGERIES_FIELD from '@salesforce/schema/Order__c.Have_you_cancelled_all_surgeries__c';
//import AVERAGE_TIME_ESI_FIELD from '@salesforce/schema/Order__c.Average_time_of_T_to_T_for_ESI_Cat_3__c';
//import ACTIVE_STAFFING_WAIVER_FIELD from '@salesforce/schema/Order__c.Do_you_have_an_active_staffing_waiver__c';
import ACCEPT_TRANSFERS_FIELD from '@salesforce/schema/Order__c.Would_you_be_able_to_accept_transfers__c';
import TYPE_OF_PERSONNEL_FIELD from '@salesforce/schema/Order__c.Type_of_Personnel__c';
import SPECIFIC_LANG_PREF_FIELD from '@salesforce/schema/Order__c.Specific_language_preferred__c';
import VACCINATION_SITE_TYPE_FIELD from '@salesforce/schema/Order__c.Vaccination_site_type__c';
import CLIENT_ANTICIPATED_FIELD from '@salesforce/schema/Order__c.Clients_Anticipated_at_Site__c';
import DOES_ANTICIPATED_FIELD from '@salesforce/schema/Order__c.Doses_Anticipated_per_Day__c';
import DOES_PER_DAY_PREVIOUS_FIELD from '@salesforce/schema/Order__c.Doses_per_Day_Previous_Events__c';
import STATUS_EVENT_CURRENTLY_FIELD from '@salesforce/schema/Order__c.What_status_is_the_event_currently_in__c';
import CONFIRM_COMPLIANCE_FIELD from '@salesforce/schema/Order__c.Confirm_Compliance_Checkboxes__c';
import PROVIDE_STAFF_FOR_VACCINATION_FIELD from '@salesforce/schema/Order__c.We_provide_staff_for_vaccination_events__c';
import SCHOOL_REQUIREMENTS_CONFORMATION_FIELD from '@salesforce/schema/Order__c.School_Requirements_Confirmation__c';
import NURSING_AND_RATIO_FIELD from '@salesforce/schema/Order__c.Using_team_nursing_and_out_of_ratio__c';
export default class PhosEditOrderDescription extends Utility {
    isLoading = true;
    value = '';
    personnelTypeOptions;
    personnelTypeList;
    confirmComplianceOptions;
    confirmComplianceList;
    ConfirmComplianceCheckboxes;
    initData() {
        if(this.recordLocal.Confirm_Compliance_Checkboxes__c != undefined){
            this.ConfirmComplianceCheckboxes = this.recordLocal.Confirm_Compliance_Checkboxes__c.replaceAll(";",",")
        } else {
            this.ConfirmComplianceCheckboxes ='';
        }
    }
    get showGACHSubQuestions(){
        if(this.recordLocal.Is_this_for_a_GACH__c == "Yes")
            return true;
        return false; 
    }
    get vaccinationSdministrationSiteOther(){
        if(this.recordLocal.Vaccination_site_type__c == "Other")
            return true;
        return false;
    }
    get staffSpeakSpecificLanguage(){
        if(this.recordLocal.Specific_language_preferred__c == "Yes")
            return true;
        return false;
    }
    get showGACHSubQuestionsNo(){
        if(this.recordLocal.Is_this_for_a_GACH__c == "No")
            return true;
        return false; 
    }
    get isVaccine(){
        if(this.recordLocal.Type_of_Personnel__c == 'Vaccination-related Personnel'){
            return true;
        }
        return false;
    }
    get isPersonnel(){
        if(this.recordLocal.Type_of_Personnel__c == 'Medical Personnel'){
            return true;
        }
        return false;
    }
    get isOutbreak(){
        if(this.recordLocal.Type_of_Personnel__c == 'Outbreak Response Team (ORT)'){
            return true;
        }
        return false;
    }
    @wire(getObjectInfo, { objectApiName: ORDER_OBJECT })
    objectInfo;

    @wire(getPicklistValues, {recordTypeId: '$objectInfo.data.defaultRecordTypeId',fieldApiName: GACH_FIELD})
    gachPicklistValues;

    @wire(getPicklistValues, {recordTypeId: '$objectInfo.data.defaultRecordTypeId',fieldApiName: TRANSFER_PATIENTS_FIELD})
    transferPatientsValues;

    @wire(getPicklistValues, {recordTypeId: '$objectInfo.data.defaultRecordTypeId',fieldApiName: ADD_ICU_MST_BEDS_FIELD})
    addICUMSTBedPicklistValues;

    @wire(getPicklistValues, {recordTypeId: '$objectInfo.data.defaultRecordTypeId',fieldApiName: PERSONNEL_ICU_FIELD})
    keepPersonnelICUBedPicklistValues;

   /* @wire(getPicklistValues, {recordTypeId: '$objectInfo.data.defaultRecordTypeId',fieldApiName: TOTAL_ICU_BEDS_OCCUPIED_FIELD})
    totalICUBedOccupiedPicklistValues;*/

    @wire(getPicklistValues, {recordTypeId: '$objectInfo.data.defaultRecordTypeId',fieldApiName: CANCELLED_SURGERIES_FIELD})
    cancelledSurgeriesPicklistValues;

    /*@wire(getPicklistValues, {recordTypeId: '$objectInfo.data.defaultRecordTypeId',fieldApiName: AVERAGE_TIME_ESI_FIELD})
    avgTimeESIPicklistValues;

    @wire(getPicklistValues, {recordTypeId: '$objectInfo.data.defaultRecordTypeId',fieldApiName: ACTIVE_STAFFING_WAIVER_FIELD})
    staffingWaiverPicklistValues;*/

    @wire(getPicklistValues, {recordTypeId: '$objectInfo.data.defaultRecordTypeId',fieldApiName: ACCEPT_TRANSFERS_FIELD})
    acceptTransferdPicklistValues;

    @wire(getPicklistValues, {recordTypeId: '$objectInfo.data.defaultRecordTypeId',fieldApiName: TYPE_OF_PERSONNEL_FIELD})
    personnelTypePicklistValues({data,error}){
        if(data){
            this.personnelTypeList = data.values;
            let fieldsToTooltip =['Includes Vaccinators, Admin, Logistics, and Security staff for Vaccination Events','Includes Medical/Clinical Staff for Healthcare Facilities','Includes Personnel not covered by Vaccination-related Personnel or Medical Personnel','Includes both Personnel and Supplies for rapid deployment in an outbreak setting']
            let picklistValues = [];
            let pickListData = data.values;
            for(let i = 0; i < this.personnelTypeList.length; i++)
            {
                let isChecked = false;
                if( this.recordLocal.Type_of_Personnel__c == this.personnelTypeList[i].value){
                    isChecked = true;
                }
                picklistValues.push({
                    label: pickListData[i].value, 
                    value: pickListData[i].label,
                    description: fieldsToTooltip[i],
                    checked: isChecked
                });
            }
            this.personnelTypeOptions = picklistValues;
        } else if(error){
            console.log('Error--->',error);
        }
    }

    @wire(getPicklistValues, {recordTypeId: '$objectInfo.data.defaultRecordTypeId',fieldApiName: SPECIFIC_LANG_PREF_FIELD})
    specificLangPrefPicklistValues;

    @wire(getPicklistValues, {recordTypeId: '$objectInfo.data.defaultRecordTypeId',fieldApiName: VACCINATION_SITE_TYPE_FIELD})
    vaccinationSiteTypePicklistValues;

    @wire(getPicklistValues, {recordTypeId: '$objectInfo.data.defaultRecordTypeId',fieldApiName: CLIENT_ANTICIPATED_FIELD})
    clientsAnticipatedPicklistValues;

    @wire(getPicklistValues, {recordTypeId: '$objectInfo.data.defaultRecordTypeId',fieldApiName: DOES_ANTICIPATED_FIELD})
    doesesAnticipatedPicklistValues;

    @wire(getPicklistValues, {recordTypeId: '$objectInfo.data.defaultRecordTypeId',fieldApiName: DOES_PER_DAY_PREVIOUS_FIELD})
    dosesPerDayPreviousPicklistValues;

    @wire(getPicklistValues, {recordTypeId: '$objectInfo.data.defaultRecordTypeId',fieldApiName: STATUS_EVENT_CURRENTLY_FIELD})
    statusEventCurrentlyPicklistValues;

    @wire(getPicklistValues, {recordTypeId: '$objectInfo.data.defaultRecordTypeId',fieldApiName: CONFIRM_COMPLIANCE_FIELD})
    confirmCompliancePicklistValues;

    @wire(getPicklistValues, {recordTypeId: '$objectInfo.data.defaultRecordTypeId',fieldApiName: NURSING_AND_RATIO_FIELD})
    nursinRatioPicklistValues;

    @wire(getPicklistValues, {recordTypeId: '$objectInfo.data.defaultRecordTypeId',fieldApiName: PROVIDE_STAFF_FOR_VACCINATION_FIELD})
    provideStaffForVaccinationPicklistValues;

    @wire(getPicklistValues, {recordTypeId: '$objectInfo.data.defaultRecordTypeId',fieldApiName: SCHOOL_REQUIREMENTS_CONFORMATION_FIELD})
    provideSchoolRequirementsConfirmation;

    
    handleGACHChange(event) {
        this.recordLocal.Is_this_for_a_GACH__c = event.target.value;
        if(this.recordLocal.Is_this_for_a_GACH__c != 'Yes') {
            let fieldsToBlank = ['Does_site_need_personnel_to_keep_ICU__c','Total_ICU_beds_occupied__c','Have_you_attempted_to_transfer_patients__c','Have_you_cancelled_all_surgeries__c','Would_you_be_able_to_accept_transfers__c','Allows_additional_ICU_or_M_S_T_beds__c','What_is_current_census_of_COVID_patients__c','What_is_current_total_patient_census__c','Using_team_nursing_and_out_of_ratio__c'];
            for(var i=0; i < fieldsToBlank.length; i++) {
                this.setFieldsToBlank(fieldsToBlank[i]);
            }
        }
    }
    validateCustomInput(){
        if(this.recordLocal.Type_of_Personnel__c) {
            return true;
        } else {
            this.showErrorNotification('Error', 'Please select Type of Personnel');
            return false;
        }
    }
    
    handleVaccinePersonnel(event){
        this.recordLocal.Type_of_Personnel__c = event.target.value;
        this.personnelTypeOptions.forEach(option => option.checked = option.value === this.recordLocal.Type_of_Personnel__c);
        if(this.recordLocal.Type_of_Personnel__c == 'Vaccination-related Personnel'){
            let fieldsToBlank = ['Does_site_need_personnel_to_keep_ICU__c','Have_you_attempted_to_transfer_patients__c','Have_you_cancelled_all_surgeries__c','Would_you_be_able_to_accept_transfers__c','Is_this_for_a_GACH__c','Allows_additional_ICU_or_M_S_T_beds__c','What_is_current_census_of_COVID_patients__c','What_is_current_total_patient_census__c','Using_team_nursing_and_out_of_ratio__c'];
            for(var i=0; i < fieldsToBlank.length; i++) {
                this.setFieldsToBlank(fieldsToBlank[i]);
            }
           
        }else if(this.recordLocal.Type_of_Personnel__c == 'Medical Personnel'){
            // sent null to all vaccine questions
            this.ConfirmComplianceCheckboxes='';
            this.recordLocal.Confirm_Compliance_Checkboxes__c='';
            let fieldsToBlank = ['Total_Vaccinator_Staff_needed__c','School_Requirements_Confirmation__c','Specific_Vaccinator_Licenses_req_d__c','Total_Logistics_Staff_needed__c','Logistics_Task_Assignments__c','Logistics_staff_tasks__c','Total_Admin_Data_Staff_needed__c','Admin_Data_Staff_Assignments__c','Total_Security_Staff_needed__c','Specific_language_preferred__c','Language_specified__c','Date_Time_staff_are_needed__c','Address_for_staff__c','Schedule_for_staff__c','Vaccination_site_type__c','Other_Vaccination_Site__c','Communication_with_Locals__c','X2nd_Dose_plan_detail__c','How_many_clients_previously_helped__c','What_is_the_site_name__c','Clients_Anticipated_at_Site__c','Doses_Anticipated_per_Day__c','Doses_per_Day_Previous_Events__c','What_status_is_the_event_currently_in__c','Confirm_Compliance_Checkboxes__c','Compliance_Narrative__c','We_provide_staff_for_vaccination_events__c'];
            for(var i=0; i < fieldsToBlank.length; i++) {
                this.setFieldsToBlank(fieldsToBlank[i]);
            }
        }
        else if(this.recordLocal.Type_of_Personnel__c == 'Non-Medical Personnel' || this.recordLocal.Type_of_Personnel__c == 'Outbreak Response Team (ORT)'){
            this.recordLocal.Confirm_Compliance_Checkboxes__c='';
            this.ConfirmComplianceCheckboxes='';
            // set null to all Medical and Vaccine questions
            let fieldsToBlank = ['Does_site_need_personnel_to_keep_ICU__c','School_Requirements_Confirmation__c','Have_you_attempted_to_transfer_patients__c','Have_you_cancelled_all_surgeries__c','Would_you_be_able_to_accept_transfers__c','Is_this_for_a_GACH__c','Allows_additional_ICU_or_M_S_T_beds__c','Total_Vaccinator_Staff_needed__c','Specific_Vaccinator_Licenses_req_d__c','Total_Logistics_Staff_needed__c','Logistics_Task_Assignments__c','Logistics_staff_tasks__c','Total_Admin_Data_Staff_needed__c','Admin_Data_Staff_Assignments__c','Total_Security_Staff_needed__c','Specific_language_preferred__c','Language_specified__c','First_date_of_Event__c','Date_Time_staff_are_needed__c','Address_for_staff__c','Schedule_for_staff__c','Vaccination_site_type__c','Other_Vaccination_Site__c','Communication_with_Locals__c','X2nd_Dose_plan_detail__c','How_many_clients_previously_helped__c','What_is_the_site_name__c','Clients_Anticipated_at_Site__c','Doses_Anticipated_per_Day__c','Doses_per_Day_Previous_Events__c','What_status_is_the_event_currently_in__c','Confirm_Compliance_Checkboxes__c','Compliance_Narrative__c','We_provide_staff_for_vaccination_events__c','What_is_current_census_of_COVID_patients__c','What_is_current_total_patient_census__c','Using_team_nursing_and_out_of_ratio__c'];
            for(var i=0; i < fieldsToBlank.length; i++) {
                this.setFieldsToBlank(fieldsToBlank[i]);
            }
        } 
                 
    }
    handleSpealLaguageChange(event){
        this.recordLocal.Specific_language_preferred__c = event.target.value;
        if(this.recordLocal.Specific_language_preferred__c != 'Yes'){
            this.recordLocal.Language_specified__c = '';
        }    
    }

    handleVaccineAdminSiteOtherChange(event){
        this.recordLocal.Vaccination_site_type__c = event.target.value;
        if(this.recordLocal.Vaccination_site_type__c != 'Other'){
            this.recordLocal.Other_Vaccination_Site__c = '';
        } 
    }

    handleCheckboxSelected(event){
        this.ConfirmComplianceCheckboxes = event.target.value;
        this.recordLocal.Confirm_Compliance_Checkboxes__c='';
        let selectedVal=event.target.value;
        for(let i=0;i<selectedVal.length;i++){
            if(i == 0 ){
                this.recordLocal.Confirm_Compliance_Checkboxes__c = selectedVal[i];
            }else{
                this.recordLocal.Confirm_Compliance_Checkboxes__c =  this.recordLocal.Confirm_Compliance_Checkboxes__c +';'+selectedVal[i];
            }
            
        }
    }
    
}