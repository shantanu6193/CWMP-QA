import { LightningElement,wire,track } from 'lwc';
import Utility from 'c/utility';
import { getObjectInfo,getPicklistValues } from 'lightning/uiObjectInfoApi';


import HH_EN_Property_Owner from '@salesforce/label/c.HH_EN_Property_Owner';
import HH_EN_Primary_Residence from '@salesforce/label/c.HH_EN_Primary_Residence';
import HH_EN_Rental_Property from '@salesforce/label/c.HH_EN_Rental_Property';
import HH_EN_Currently_Occupied from '@salesforce/label/c.HH_EN_Currently_Occupied';
import HH_EN_Property_Currently_Damaged from '@salesforce/label/c.HH_EN_Property_Currently_Damaged';
import HH_EN_Describe_the_damages from '@salesforce/label/c.HH_EN_Describe_the_damages';
import HH_EN_Car_Ownership from '@salesforce/label/c.HH_EN_Car_Ownership';
import HH_EN_Is_Anyone_65 from '@salesforce/label/c.HH_EN_Is_Anyone_65';
import HH_EN_Is_Anyone_Age_5_and_Under from '@salesforce/label/c.HH_EN_Is_Anyone_Age_5_and_Under';
import HH_EN_Anyone_Not_a_Proficient_English_Speaker from '@salesforce/label/c.HH_EN_Anyone_Not_a_Proficient_English_Speaker';
import HH_EN_Ethnicities_of_Household_Members from '@salesforce/label/c.HH_EN_Ethnicities_of_Household_Members';
import HH_EN_Is_Anyone_has_Disabilities from '@salesforce/label/c.HH_EN_Is_Anyone_has_Disabilities';
import HH_EN_Disability_Defination from '@salesforce/label/c.HH_EN_Disability_Defination';
import HH_EN_Household_members from '@salesforce/label/c.HH_EN_Household_members';
import HH_EN_Members_In_Your_Household from '@salesforce/label/c.HH_EN_Members_In_Your_Household';
import HH_EN_Eligibility_Information_Page_Title from '@salesforce/label/c.HH_EN_Eligibility_Information_Page_Title';
import HH_EN_Residents_Occupying_the_Property from '@salesforce/label/c.HH_EN_Residents_Occupying_the_Property';
import HH_EN_Eligibility_Information_Instruction from '@salesforce/label/c.HH_EN_Eligibility_Information_Instruction';
import HH_EN_Household_members_Table from '@salesforce/label/c.HH_EN_Household_members_Table';
import HH_EN_Household_Composition_of_the_Property_Owner_Note from  '@salesforce/label/c.HH_EN_Household_Composition_of_the_Property_Owner_Note';
import HH_EN_Household_Composition_of_the_Property_Owner_Para_1 from '@salesforce/label/c.HH_EN_Household_Composition_of_the_Property_Owner_Para_1';
import HH_EN_Household_Composition_of_the_Property_Owner_Para_2 from '@salesforce/label/c.HH_EN_Household_Composition_of_the_Property_Owner_Para_2';
import HH_EN_Household_Composition_of_the_Property_Owner_Para_3 from '@salesforce/label/c.HH_EN_Household_Composition_of_the_Property_Owner_Para_3';
import HH_EN_Household_Composition_of_the_Property_Owner_Para_4 from '@salesforce/label/c.HH_EN_Household_Composition_of_the_Property_Owner_Para_4';
import HH_EN_Household_Composition_of_the_Property_Owner_Para_5 from '@salesforce/label/c.HH_EN_Household_Composition_of_the_Property_Owner_Para_5';
import HH_EN_Household_Composition_of_the_Property_Owner_Para_6 from '@salesforce/label/c.HH_EN_Household_Composition_of_the_Property_Owner_Para_6';
import HH_EN_Household_Composition_of_the_Property_Owner_Para_7 from '@salesforce/label/c.HH_EN_Household_Composition_of_the_Property_Owner_Para_7';
import HH_EN_Add_Line_Item from'@salesforce/label/c.HH_EN_Add_Line_Item';
import HH_EN_Is_Head_of_Household from'@salesforce/label/c.HH_EN_Is_Head_of_Household';
import HH_EN_Relationship_to_Homeowner from'@salesforce/label/c.HH_EN_Relationship_to_Homeowner';
import HH_EN_Date_of_Birth from '@salesforce/label/c.HH_EN_Date_of_Birth';
import HH_EN_Annual_Income from '@salesforce/label/c.HH_EN_Annual_Income';
import HH_EN_First_Name from '@salesforce/label/c.HH_EN_First_Name';
import HH_EN_Last_Name from '@salesforce/label/c.HH_EN_Last_Name';
import HH_EN_Action from '@salesforce/label/c.HH_EN_Action';
import HH_EN_Household_Composition from '@salesforce/label/c.HH_EN_Household_Composition';
import HH_EN_Available from '@salesforce/label/c.HH_EN_Available';
import HH_EN_Selected from '@salesforce/label/c.HH_EN_Selected';
import HH_EN_Eligibility_Info_Static_Text from '@salesforce/label/c.HH_EN_Eligibility_Info_Static_Text';
import HH_EN_House_Hold_Member_Validation from '@salesforce/label/c.HH_EN_House_Hold_Member_Validation';
import HH_EN_Household_Member_Error from '@salesforce/label/c.HH_EN_Household_Member_Error';
import APPLICATION_OBJECT from '@salesforce/schema/HH_Application__c';
import Property_Owner__c from '@salesforce/schema/HH_Application__c.Property_Owner__c';
import Primary_Residence__c from '@salesforce/schema/HH_Application__c.Primary_Residence__c';
import Property_Currently_Damaged__c from '@salesforce/schema/HH_Application__c.Property_Currently_Damaged__c';
import Rental_Property__c from '@salesforce/schema/HH_Application__c.Rental_Property__c';
import Currently_Occupied__c from '@salesforce/schema/HH_Application__c.Currently_Occupied__c';
import Is_Anyone_has_Disabilities__c from '@salesforce/schema/HH_Application__c.Is_Anyone_has_Disabilities__c';
import Car_Ownership__c from '@salesforce/schema/HH_Application__c.Car_Ownership__c';
import Is_Anyone_65__c from '@salesforce/schema/HH_Application__c.Is_Anyone_65__c';
import Is_Anyone_Age_5_and_Under__c from '@salesforce/schema/HH_Application__c.Is_Anyone_Age_5_and_Under__c';
import Anyone_Not_a_Proficient_English_Speaker__c from '@salesforce/schema/HH_Application__c.Anyone_Not_a_Proficient_English_Speaker__c';
import Ethnicities_of_Household_Members__c from '@salesforce/schema/HH_Application__c.Ethnicities_of_Household_Members__c';

export default class HhEligibilityInfo extends Utility {
	isLoading = true;
	showTable= true;
	isRentalProperty = false;
	currentIndex = 1;

	@track label = {
		HH_EN_Eligibility_Information_Page_Title,
		HH_EN_Eligibility_Information_Instruction,
		HH_EN_Household_Composition_of_the_Property_Owner_Note,
		HH_EN_Household_Composition_of_the_Property_Owner_Para_1,
		HH_EN_Household_Composition_of_the_Property_Owner_Para_2,
		HH_EN_Household_Composition_of_the_Property_Owner_Para_3,
		HH_EN_Household_Composition_of_the_Property_Owner_Para_4,
		HH_EN_Household_Composition_of_the_Property_Owner_Para_5,
		HH_EN_Household_Composition_of_the_Property_Owner_Para_6,
		HH_EN_Household_Composition_of_the_Property_Owner_Para_7,
		HH_EN_Household_members_Table,
		HH_EN_Household_members,
		HH_EN_Property_Owner,
		HH_EN_Primary_Residence,
		HH_EN_Rental_Property,
		HH_EN_Currently_Occupied,
		HH_EN_Property_Currently_Damaged,
		HH_EN_Describe_the_damages,
		HH_EN_Car_Ownership,
		HH_EN_Is_Anyone_65,
		HH_EN_Is_Anyone_Age_5_and_Under,
		HH_EN_Anyone_Not_a_Proficient_English_Speaker,
		HH_EN_Ethnicities_of_Household_Members,
		HH_EN_Is_Anyone_has_Disabilities,
		HH_EN_Disability_Defination,
		HH_EN_Members_In_Your_Household,
		HH_EN_Household_members,
		HH_EN_Residents_Occupying_the_Property,
		HH_EN_Add_Line_Item,
		HH_EN_Is_Head_of_Household,
		HH_EN_Relationship_to_Homeowner,
		HH_EN_Date_of_Birth,
		HH_EN_Annual_Income,
		HH_EN_First_Name,
		HH_EN_Last_Name,
		HH_EN_Action,
		HH_EN_Household_Composition,
		HH_EN_Available,
		HH_EN_Selected,
		HH_EN_Eligibility_Info_Static_Text,
		HH_EN_House_Hold_Member_Validation,
		HH_EN_Household_Member_Error
	}

    storeValueMap = new Map();
	@track ethnicitiesSelected = [];
	noOfTableRows;

	@wire(getObjectInfo, { objectApiName: APPLICATION_OBJECT })
	objectInfo;

	@wire(getPicklistValues, {
		recordTypeId: '$objectInfo.data.defaultRecordTypeId',
		fieldApiName: Property_Owner__c
	})
	propertOwnerPicklistValues;

	@wire(getPicklistValues, {
		recordTypeId: '$objectInfo.data.defaultRecordTypeId',
		fieldApiName: Primary_Residence__c
	})
	primaryResidencePicklistValues;

	@wire(getPicklistValues, {
		recordTypeId: '$objectInfo.data.defaultRecordTypeId',
		fieldApiName: Rental_Property__c
	})
	rentalPropertyPicklistValues;

	@wire(getPicklistValues, {
		recordTypeId: '$objectInfo.data.defaultRecordTypeId',
		fieldApiName: Currently_Occupied__c
	})
	propertyOccupiedPicklistValues;

	@wire(getPicklistValues, {
		recordTypeId: '$objectInfo.data.defaultRecordTypeId',
		fieldApiName: Is_Anyone_has_Disabilities__c
	})
	disabilityPicklistValues;


	@wire(getPicklistValues, {
		recordTypeId: '$objectInfo.data.defaultRecordTypeId',
		fieldApiName: Car_Ownership__c
	})
	carOwnerShipPicklistValues;

	@wire(getPicklistValues, {
		recordTypeId: '$objectInfo.data.defaultRecordTypeId',
		fieldApiName: Is_Anyone_65__c
	})
	anyoneoldPicklistValues;

	@wire(getPicklistValues, {
		recordTypeId: '$objectInfo.data.defaultRecordTypeId',
		fieldApiName: Is_Anyone_Age_5_and_Under__c
	})
	anyoneChildPicklistValues;

	@wire(getPicklistValues, {
		recordTypeId: '$objectInfo.data.defaultRecordTypeId',
		fieldApiName: Anyone_Not_a_Proficient_English_Speaker__c
	})
	notEngProficientPicklistValues;

	@wire(getPicklistValues, {
		recordTypeId: '$objectInfo.data.defaultRecordTypeId',
		fieldApiName: Ethnicities_of_Household_Members__c
	})
	ethnicitiesHHPicklistValues;

	@wire(getPicklistValues, {
		recordTypeId: '$objectInfo.data.defaultRecordTypeId',
		fieldApiName: Is_Anyone_has_Disabilities__c
	})
	anyoneDisabledPicklistValues;

	initData() {
		if(this.recordLocal.Ethnicities_of_Household_Members__c != undefined) {
			this.ethnicitiesSelected = this.recordLocal.Ethnicities_of_Household_Members__c.split(";");
		}
		if(this.recordLocal.Rental_Property__c == 'Yes') {
			this.isRentalProperty = true;
		} else {
			this.isRentalProperty = false;
		}

		if (this.recordLocal != undefined && this.recordLocal.contacts != undefined) {
				for(let i =0; i<this.recordLocal.contacts.length; i++) {
						this.recordLocal.contacts[i].index = this.currentIndex;
						this.recordLocal.contacts[i]['Contact__r.FirstName'] = this.recordLocal.contacts[i].Contact__r.FirstName;
						this.recordLocal.contacts[i]['Contact__r.LastName'] = this.recordLocal.contacts[i].Contact__r.LastName;
						this.currentIndex++;
				}

				if(this.recordLocal.contacts.length > 0){
				this.noOfTableRows = this.recordLocal.contacts.length;
				}else{
				    this.noOfTableRows='';
				    let member = {};
                    member['index'] = this.currentIndex;
                    member['Role__c'] = 'Household Member';
                    member['Contact__r'] ={};
                    this.recordLocal.contacts.push(member);
                    this.currentIndex++;
                }
		}

		this.skipCustomLogicValidation = true;
		console.log('Eligibility: ',JSON.parse(JSON.stringify(this.recordLocal)));
	}

	handleRentalPropertyChange(event) {
		let value = event.target.value;
		if(value == 'Yes') {
		    this.recordLocal.Currently_Occupied__c = this.storeValueMap.get('Yes-Currently_Occupied__c');
			this.isRentalProperty = true;
		} else {
			this.isRentalProperty = false;
			this.recordLocal.Currently_Occupied__c = '';
		}
		this.recordLocal.Rental_Property__c = value;
	}

    fieldChangedMap(event){
        if(event.target.getAttribute('data-field') == 'Currently_Occupied__c'){
            let keyString = this.recordLocal['Rental_Property__c']+'-'+event.target.getAttribute('data-field');
            this.storeValueMap.set(keyString, event.target.value);
            this.recordLocal['Currently_Occupied__c'] = this.storeValueMap.get(keyString);
        }
    }

	editTableRows(event) {
			this.noOfTableRows =  event.target.value;
	}

	addLineItem() {
			let member = {};
			member['index'] = this.currentIndex;
			member['Role__c'] = 'Household Member';
			member['Contact__r'] ={};
			this.recordLocal.contacts.push(member);
			this.currentIndex++;	
	}

	/*
	* Delete selected row
	*/
	handleDeleteContact(response){
			let childIndex = response.detail.index;
			if( this.recordLocal.contacts.length > 1) {
					this.recordLocal.contacts.splice(childIndex, 1);
			}
	}

	ethnicitiesChanged(event) {
		let selectedValues = '';
		for(let key in event.detail.value) {
			selectedValues += event.detail.value[key]+";";
		}
		if(selectedValues != '') {
			selectedValues = selectedValues.slice(0,-1);
		}
		this.recordLocal.Ethnicities_of_Household_Members__c = selectedValues;
	}

	/*
    * Get records from child component
    */
	updateListToParentComponentList() {
			if(this.recordLocal.contacts != undefined) {
					for(let i=0; i<this.recordLocal.contacts.length; i++) {
						let contactRec = this.template.querySelector('[data-id="'+i+'"]').getRecordDetails();
						if(contactRec == undefined) {
								return undefined;
						}
					}
					for(let i=0; i<this.recordLocal.contacts.length; i++) {
						let contactRec = this.template.querySelector('[data-id="'+i+'"]').getRecordDetails();
						if(contactRec == undefined) {
								return undefined;
						}
						this.recordLocal.contacts[i] = contactRec;
					}
			}	
			console.log('with ChildRecords---', JSON.stringify(this.recordLocal));
			return this.recordLocal;
	}

	/*
	* Get records from child component
	*/
	updateRecordLocal() {
			this.allInputsValidated = true;	
			let showError = false;
			if (this.noOfTableRows != undefined && this.noOfTableRows > 0 && this.recordLocal.contacts == undefined) {
					showError = true;
			} else if (this.noOfTableRows != undefined && this.recordLocal.contacts != undefined && this.noOfTableRows != this.recordLocal.contacts.length) {
					showError = true;	
			}
            let householdMemberFieldCmp = this.template.querySelector('.householdMember');
			if(showError) {
				//this.showNotification('',this.label.HH_EN_House_Hold_Member_Validation,'error','sticky');
				householdMemberFieldCmp.setCustomValidity(this.label.HH_EN_House_Hold_Member_Validation);
				householdMemberFieldCmp.reportValidity();
				this.allInputsValidated = false;
				return;
			}

			let recordLocal = this.updateListToParentComponentList();
			if(recordLocal == undefined) {
					this.allInputsValidated = false;
			} else {
					this.recordLocal = recordLocal;
					console.log('this.recordLocal---', JSON.stringify(this.recordLocal));
			}
	}

	get todaysDate() {
		var today = new Date();
		var dd = String(today.getDate()).padStart(2, '0');
		var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
		var yyyy = today.getFullYear();
		today = yyyy+'-'+mm+'-'+dd;
		return today
	}
    checkZero(event){
        let householdMemberFieldCmp1 = this.template.querySelector('.householdMember');
        if(event.target.value == 0 || event.target.value == null){
            householdMemberFieldCmp1.setCustomValidity(this.label.HH_EN_Household_Member_Error);
            this.allInputsValidated = false;
        }else{
            householdMemberFieldCmp1.setCustomValidity("");
        }
        householdMemberFieldCmp1.reportValidity();
    }
}