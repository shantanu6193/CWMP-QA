import { LightningElement,wire } from 'lwc';
import Utility from 'c/utility';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import ORDER_OBJECT from '@salesforce/schema/Order__c';
import COUNTY_FIELD from '@salesforce/schema/Order__c.County__c';
import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import ENTITY_TYPE_FIELD from '@salesforce/schema/Account.Entity_Type__c';
import getRecipientContact from '@salesforce/apex/PHOS_Order_EditCtrl.getRecipientContact';

export default class PhosEditOrderRequesterInfo extends Utility {
    isLoading = true;
    value = '';
    //entityType='';
    isCommunityUser = false;
    isHealthCareUser = true;
    isOperationalArea = false;
    isRequestorAgencyDisabled = true;
    isRequesterAgency = false;
    orderRec=[];
    address=[];
    showRequesterAgencyLookup = false;
    initData(){
        if(this.recordLocal.Account__r != undefined) {
            this.recordLocal.entityType = this.recordLocal.Account__r.Entity_Type__c;
        }
      
        this.getRecipientContactDetails();
        
        if(this.recordLocal.Personnel__c == false){
            // set null to all Medical and Vaccine questions
            let fieldsToBlank = ['Type_of_Personnel__c','Bed_to_staff_ratio_bed_staff__c','Does_site_need_personnel_to_keep_ICU__c','Total_ICU_beds_occupied__c','Have_you_attempted_to_transfer_patients__c','Have_you_cancelled_all_surgeries__c','Do_you_have_an_active_staffing_waiver__c','Would_you_be_able_to_accept_transfers__c','Is_this_for_a_GACH__c','How_many_total_staff_are_you_requesting__c','Allows_additional_ICU_or_M_S_T_beds__c','Average_time_of_T_to_T_for_ESI_Cat_3__c','Total_Vaccinator_Staff_needed__c','Specific_Vaccinator_Licenses_req_d__c','Total_Logistics_Staff_needed__c','Logistics_staff_tasks__c','Total_Admin_Data_Staff_needed__c','Admin_Data_Staff_Assignments__c','Total_Security_Staff_needed__c','Specific_language_preferred__c','Language_specified__c','First_date_of_Event__c','Date_Time_staff_are_needed__c','Address_for_staff__c','Schedule_for_staff__c','Vaccination_site_type__c','Other_Vaccination_Site__c','How_many_clients_expected__c','Is_allocation_amount_sufficient__c','What_is_closest_phase_tier__c','Communication_with_Locals__c','Any_unmet_communication_needs__c','X2nd_Dose_plan_in_place__c','X2nd_Dose_plan_detail__c','Has_state_previously_helped__c','How_many_clients_previously_helped__c'];
            for(var i=0; i < fieldsToBlank.length; i++) {
                this.setFieldsToBlank(fieldsToBlank[i]);
            }
        }
    }

    @wire(getObjectInfo, { objectApiName: ACCOUNT_OBJECT })
    accountObjectInfo;

    @wire(getObjectInfo, { objectApiName: ORDER_OBJECT })
    orderObjectInfo;

    @wire(getPicklistValues, {
        recordTypeId: '$accountObjectInfo.data.defaultRecordTypeId',
        fieldApiName: ENTITY_TYPE_FIELD
    })
    entityTypePicklistValues;

    @wire(getPicklistValues, {
        recordTypeId: '$orderObjectInfo.data.defaultRecordTypeId',
        fieldApiName: COUNTY_FIELD
    })
    countyPicklistValues;

    getRequestorAgency(event){
        let agencyRec = event.detail.agencyData; 
        console.log('agencyRec',agencyRec);
        this.recordLocal.Requestor_Agency_Text__c = agencyRec.Name;
        this.recordLocal.Account__c = agencyRec.Id;
        console.log('values--------->',agencyRec.Name + '-----' + agencyRec.Id);
    }
    getIndustryValue(event) {
        this.recordLocal.Industry__c = event.detail.industry;
        console.log('Industry__c--->',event.detail.industry);
    }
    getSubIndustryValue(event) {
        this.recordLocal.Sub_Industry__c = event.detail.subIndustry;
        console.log('Sub_Industry__c--->',event.detail.subIndustry);
    }
    entityTypeChange(event){
        this.recordLocal.entityType = event.target.value;
    }
    updateDeliveryInfo(event){
        let checked = event.target.checked;
        console.log('Same as above---',checked);
        if(checked == false) return;
        this.recordLocal.Delivery_Recipient_First_Name_Text__c = this.recordLocal.Requestor_First_Name_Text__c;
        this.recordLocal.Delivery_Recipient_Last_Name_Text__c = this.recordLocal.Requestor_Last_Name_Text__c;
        this.recordLocal.Delivery_Recipient_Title_Text__c = this.recordLocal.Requestor_Title_Text__c;
        this.recordLocal.Delivery_Recipient_Email_Text__c = this.recordLocal.Requestor_Email_Text__c;
        this.recordLocal.Delivery_Recipient_Phone_Text__c = this.recordLocal.Requestor_Phone_Text__c;
    }
    handleAddressSelection(event){
        try{
            console.log('address-selected');
            let address = event.detail.address;
            //let address = event.getParam('address');
            //console.log('address----',JSON.stringify(address));
            console.log('address[0].properties.District----',address[0].properties.District);
            let streetAddress = address[0].properties.StAddr;
            let streetAddress2 = address[0].properties.District;
            let state = address[0].properties.RegionAbbr;
            let city = address[0].properties.City;
            let zipCode = address[0].properties.Postal;
            let country = address[0].properties.Country;
            this.recordLocal.Shipping_Street__c = streetAddress;
            if(streetAddress2) {
              this.recordLocal.Shipping_Street_2__c = streetAddress2;
            }
            this.recordLocal.Shipping_State__c = state;
            this.recordLocal.Shipping_ZipPostal_Code__c = zipCode;
            this.recordLocal.Shipping_Country__c = country;
            this.recordLocal.Shipping_City__c = city;
            this.address = address[0].properties.LongLabel;
            this.recordLocal.Address_Geolocation__Latitude__s = address[0].latlng.lat;
            this.recordLocal.Address_Geolocation__Longitude__s = address[0].latlng.lng;
            //console.log('add------',address);
        }
        catch(e){
            console.log(e);
        }
    }

    getRecipientContactDetails(){
        getRecipientContact()
        .then((results) => {
            console.log('results---->', results);
            let user = results.user;
            let communityUser = results.IsCommunityUser;
            let contact = results.contact;
            this.sCommunityUser = communityUser;
            if(contact != undefined) {
                if(contact.Account.Entity_Type__c == 'Health Care Facility') {
                    this.isHealthCareUser = false;
                }
                //Call below code only if new order is creating
                if(this.recordLocal.Requestor_Last_Name_Text__c == undefined){
                    this.recordLocal.Requestor_First_Name_Text__c = contact.FirstName;
                    this.recordLocal.Requestor_Last_Name_Text__c = contact.LastName;
                    this.recordLocal.Requestor_Agency_Text__c = contact.Account.Name;
                    this.recordLocal.Requestor_Email_Text__c = contact.Email;
                    this.recordLocal.Requestor_Phone_Text__c = contact.Phone;
                    this.recordLocal.Requestor_Title_Text__c = contact.Title;
                    if(contact.Account != undefined && contact.Account.Entity_Type__c != undefined) {
                        this.recordLocal.entityType = contact.Account.Entity_Type__c;
                    }
                    if(contact.Account != undefined && contact.Account.Entity_Type__c == 'County'){
                        this.recordLocal.County__c = contact.Account.Name;
                    }
                    if(contact.Account != undefined && contact.Account.Parent != undefined && contact.Account.Parent.Entity_Type__c == 'County'){  
                        this.recordLocal.County__c = contact.Account.Parent.Name;
                    }
                    if(contact.Account != undefined && contact.Account.Parent != undefined && contact.Account.Parent.Entity_Type__c == 'County'){  
                        this.recordLocal.County__c = contact.Account.Parent.Name;
                    }
                    if(contact.Account != undefined && contact.Account.Entity_Type__c == 'State Agency'){
                        this.recordLocal.County__c = contact.Account.Entity_Type__c;
                    }
                    if(contact.Account != undefined && contact.Account.Entity_Type__c == 'Non-Governmental Entity'){
                        this.recordLocal.County__c = contact.Account.Entity_Type__c;
                    }
                    if(this.recordLocal.County__c != undefined && this.recordLocal.County__c.endsWith(', County of')){
                        this.recordLocal.County__c = this.recordLocal.County__c.replace(', County of','')
                    }
                   
                }
                if(contact.Account != undefined && contact.Account.Entity_Type__c == 'County'){
                    this.isOperationalArea = true; 
                }
                if(contact.Account != undefined && contact.Account.Parent != undefined && contact.Account.Parent.Entity_Type__c == 'County'){ 
                    this.isRequesterAgency = true; 
                    this.isOperationalArea = true; 
                }
                if(contact.Account != undefined && contact.Account.Entity_Type__c == 'State Agency'){
                    this.isOperationalArea = true;
                }
                if(contact.Account != undefined && contact.Account.Entity_Type__c == 'Non-Governmental Entity'){
                    this.isOperationalArea = true;
                }
                if(contact.Account != undefined && (contact.Account.Entity_Type__c == 'County' || contact.Account.Entity_Type__c == 'Region')){
                    this.isRequestorAgencyDisabled = false;
                }
            }
            else {
                this.isRequestorAgencyDisabled = false;
            }
            this.showRequesterAgencyLookup = true;
        })
        .catch((error) => {
            console.error('error------>', error);
            this.error('Lookup Error', 'An error occured while searching with the lookup field.');
            console.error('Lookup error', JSON.stringify(error));
            this.errors = [error];
        });
    } 
    deliveryPhoneValidation() {
        let number = this.recordLocal.Delivery_Recipient_Phone_Text__c;
        let cleanedNumber = ('' + number).replace(/\D/g, '');
        let phoneNumber = cleanedNumber.match(/^(\d{3})(\d{3})(\d{4})$/);
        let newNumber = '';
        let allValidPhone = true;
        if (phoneNumber) {
            newNumber = '(' + phoneNumber[1] + ') ' + phoneNumber[2] + '-' + phoneNumber[3];
            console.log('newNumber',newNumber);
            this.recordLocal.Delivery_Recipient_Phone_Text__c = newNumber;
        }

        let inputCmp = this.template.querySelector('.deliveryPhone');
        var value = this.recordLocal.Delivery_Recipient_Phone_Text__c;
        console.log('value---',value);
        if (value != newNumber) {
            allValidPhone =false;
            inputCmp.setCustomValidity("Enter a valid phone number ex:(123) 456 7890");
        } else {
            inputCmp.setCustomValidity(""); // if there was a custom error before, reset it
        }
        inputCmp.reportValidity(); // Tells lightning:input to show the error right away without needing interaction
        return allValidPhone;
    }
    formatPhone(){
        let number = this.recordLocal.Requestor_Phone_Text__c;
        let cleanedNumber = ('' + number).replace(/\D/g, '');
        let phoneNumber = cleanedNumber.match(/^(\d{3})(\d{3})(\d{4})$/);
        let newNumber = '';
        let allValidPhone = true;
        if (phoneNumber) {
            newNumber = '(' + phoneNumber[1] + ') ' + phoneNumber[2] + '-' + phoneNumber[3];
            console.log('newNumber',newNumber);
            this.recordLocal.Requestor_Phone_Text__c = newNumber;
        }

        let inputCmp = this.template.querySelector('.requesterPhone');
        var value = this.recordLocal.Requestor_Phone_Text__c;
        console.log('value---',value);
        if (value != newNumber) {
            allValidPhone =false;
            inputCmp.setCustomValidity("Enter a valid phone number ex:(123) 456 7890");
        } else {
            inputCmp.setCustomValidity(""); // if there was a custom error before, reset it
        }
        inputCmp.reportValidity(); // Tells lightning:input to show the error right away without needing interaction
        return allValidPhone;
    }
    validateCustomInput(){
        let validAgency = this.template.querySelector('c-phos-requestor-agency-lookup').validateCustomInput();
        let validIndustry = this.template.querySelector('c-phos-industry-pick-list').validateInputs();
        let latCmp = this.template.querySelector('[data-field="Address_Geolocation__Latitude__s"]');
        let longCmp = this.template.querySelector('[data-field="Address_Geolocation__Longitude__s"]');
        let requesterPhoneValid = this.formatPhone();
        let deliveryPhone = this.deliveryPhoneValidation();
        console.log('latCmp----',latCmp.value);
        console.log('longCmp----',longCmp.value);
        let addressValid = true;
        if ((latCmp.value == undefined || latCmp.value == '' || latCmp.value == null) && (longCmp.value == undefined || longCmp.value == '' || longCmp.value == null)) {
            addressValid = false;
        } else {
            addressValid = true;
        }
        /*if(validAgency && validIndustry && addressValid){
            return true;
        }*/
        if(addressValid == false){
            this.showNotification('Error', 'Please select address from map', 'error', 'dismissable');
        }
       console.log('addressValid***',addressValid);
        return (validAgency && validIndustry && addressValid && requesterPhoneValid && deliveryPhone);
        //return allinput;
    }
}