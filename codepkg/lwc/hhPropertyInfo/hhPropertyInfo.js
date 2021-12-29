import { LightningElement,wire,api,track } from 'lwc';
import Utility from 'c/utility';
import HH_EN_Physical_Address_Information from '@salesforce/label/c.HH_EN_Physical_Address_Information';
import HH_EN_Property_Structure from '@salesforce/label/c.HH_EN_Property_Structure';
import HH_EN_Property_Street_Address from '@salesforce/label/c.HH_EN_Property_Street_Address';
import HH_EN_Property_City from '@salesforce/label/c.HH_EN_Property_City';
import HH_EN_Property_Zip from '@salesforce/label/c.HH_EN_Property_Zip';
import HH_EN_Property_State from '@salesforce/label/c.HH_EN_Property_State';
import HH_EN_Property_Count from '@salesforce/label/c.HH_EN_Property_Count';
import HH_EN_Property_Currently_Damaged from '@salesforce/label/c.HH_EN_Property_Currently_Damaged';
import HH_EN_Describe_the_damages from '@salesforce/label/c.HH_EN_Describe_the_damages';
import HH_EN_Year_of_construction from '@salesforce/label/c.HH_EN_Year_of_construction';
import HH_EN_Authority_to_make_updates_to_the_Home from '@salesforce/label/c.HH_EN_Authority_to_make_updates_to_the_Home';
import HH_EN_Total_Living_Area from '@salesforce/label/c.HH_EN_Total_Living_Area';
import HH_EN_Number_of_Stories from '@salesforce/label/c.HH_EN_Number_of_Stories';
import HH_EN_Accessible_by_a_Passenger_Vehicle from '@salesforce/label/c.HH_EN_Accessible_by_a_Passenger_Vehicle';
import HH_EN_Is_National_Register_of_Historic_Places from '@salesforce/label/c.HH_EN_Is_National_Register_of_Historic_Places';
import HH_EN_Any_Other_Names_on_the_Property_Deed from '@salesforce/label/c.HH_EN_Any_Other_Names_on_the_Property_Deed';
import HH_EN_rovide_the_first_and_last_names from '@salesforce/label/c.HH_EN_rovide_the_first_and_last_names';
import HH_EN_Property_Foreclosed_or_in_Foreclosure from '@salesforce/label/c.HH_EN_Property_Foreclosed_or_in_Foreclosure';
import HH_EN_Property_Liens from '@salesforce/label/c.HH_EN_Property_Liens';
import HH_EN_Good_Standing_on_Property_Taxes from '@salesforce/label/c.HH_EN_Good_Standing_on_Property_Taxes';
import HH_EN_Assessed_Value_of_the_Property from '@salesforce/label/c.HH_EN_Assessed_Value_of_the_Property';
import HH_EN_Measures_to_Reduce_Wildfire_Damage_Risk from '@salesforce/label/c.HH_EN_Measures_to_Reduce_Wildfire_Damage_Risk';
import HH_EN_List_of_Measures from '@salesforce/label/c.HH_EN_List_of_Measures';
import HH_EN_Assistance_for_Home_s_risk_to_wildfire from '@salesforce/label/c.HH_EN_Assistance_for_Home_s_risk_to_wildfire';
import HH_EN_HH_EN_Dates_Funding_Received_and_Program_Names from '@salesforce/label/c.HH_EN_HH_EN_Dates_Funding_Received_and_Program_Names';
import HH_EN_Residence_Information from '@salesforce/label/c.HH_EN_Residence_Information';
import HH_EN_Funding_Received_Previously from '@salesforce/label/c.HH_EN_Funding_Received_Previously';
import HH_EN_Date_Funding_Received from '@salesforce/label/c.HH_EN_Date_Funding_Received';
import HH_EN_Other_Program_Name from '@salesforce/label/c.HH_EN_Other_Program_Name';
import HH_EN_Program_Name from '@salesforce/label/c.HH_EN_Program_Name';
import HH_EN_Action from '@salesforce/label/c.HH_EN_Action';
import HH_EN_Add_Line_Item from '@salesforce/label/c.HH_EN_Add_Line_Item';
import HH_EN_Available from '@salesforce/label/c.HH_EN_Available';
import HH_EN_Selected from '@salesforce/label/c.HH_EN_Selected';
import HH_EN_First_Name from '@salesforce/label/c.HH_EN_First_Name';
import HH_EN_Last_Name from '@salesforce/label/c.HH_EN_Last_Name';
import HH_EN_Four_Digit_Validation from '@salesforce/label/c.HH_EN_Four_Digit_Validation';
import HH_EN_MissingFieldValueError from '@salesforce/label/c.HH_EN_MissingFieldValueError';
import HH_EN_Prior_Year_Validation from '@salesforce/label/c.HH_EN_Prior_Year_Validation';
import HH_EN_characters_remaining from '@salesforce/label/c.HH_EN_characters_remaining';
import HH_Application_Stage_Draft from '@salesforce/label/c.HH_Application_Stage_Draft';
import HH_Application_Status_New from '@salesforce/label/c.HH_Application_Status_New';
import HH_EN_any_assistance_from_any_program from '@salesforce/label/c.HH_EN_any_assistance_from_any_program';
import HH_EN_assistance_and_approximately_when from '@salesforce/label/c.HH_EN_assistance_and_approximately_when';
import HH_EN_property_currently_damaged_static_text from '@salesforce/label/c.HH_EN_property_currently_damaged_static_text';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import APPLICATION_OBJECT from '@salesforce/schema/HH_Application__c';
import PROPERTY_STRUCTURE_FIELD from '@salesforce/schema/HH_Application__c.Property_Structure__c';
import Did_you_receive_wildfire_assistance__c from '@salesforce/schema/HH_Application__c.Did_you_receive_wildfire_assistance__c';
import County__c from '@salesforce/schema/HH_Application__c.County__c';
import Authority_to_make_updates_to_the_Home__c from '@salesforce/schema/HH_Application__c.Authority_to_make_updates_to_the_Home__c';
import Accessible_by_a_Passenger_Vehicle__c from '@salesforce/schema/HH_Application__c.Accessible_by_a_Passenger_Vehicle__c';
import Is_National_Register_of_Historic_Places__c from '@salesforce/schema/HH_Application__c.Is_National_Register_of_Historic_Places__c';
import Property_Foreclosed_or_in__c from '@salesforce/schema/HH_Application__c.Property_Foreclosed_or_in__c';
import Property_Liens__c from '@salesforce/schema/HH_Application__c.Property_Liens__c';
import Good_Standing_with_a_payment_plan_on_you__c from '@salesforce/schema/HH_Application__c.Good_Standing_with_a_payment_plan_on_you__c';
import Measures_to_Reduce_risks_to_wi__c from '@salesforce/schema/HH_Application__c.Measures_to_Reduce_risks_to_wi__c';
import Any_Other_Names_on_the_Property_Deed__c  from '@salesforce/schema/HH_Application__c.Any_Other_Names_on_the_Property_Deed__c';
import Property_Currently_Damaged__c from '@salesforce/schema/HH_Application__c.Property_Currently_Damaged__c'; 
import checkCommunityUserCounty from '@salesforce/apex/HH_ApplicationCtrl.getCommunityUserCounty';

export default class HhPropertyInfo extends Utility {
	@track label = {
			HH_EN_Residence_Information,
			HH_EN_Funding_Received_Previously,
			HH_EN_Physical_Address_Information,	
			HH_EN_Property_Structure,
			HH_EN_Property_Street_Address,
			HH_EN_Property_Structure,
			HH_EN_Property_City,
			HH_EN_Property_State,
			HH_EN_Property_Zip,
			HH_EN_Property_Count,
			HH_EN_Year_of_construction,
			HH_EN_Property_Currently_Damaged,
			HH_EN_Describe_the_damages,
			HH_EN_Authority_to_make_updates_to_the_Home,
			HH_EN_Total_Living_Area,
			HH_EN_Number_of_Stories,
			HH_EN_Accessible_by_a_Passenger_Vehicle,
			HH_EN_Is_National_Register_of_Historic_Places,
			HH_EN_Any_Other_Names_on_the_Property_Deed,
			HH_EN_rovide_the_first_and_last_names,
			HH_EN_Property_Foreclosed_or_in_Foreclosure,
			HH_EN_Property_Liens,
			HH_EN_Good_Standing_on_Property_Taxes,
			HH_EN_Assessed_Value_of_the_Property,
			HH_EN_Measures_to_Reduce_Wildfire_Damage_Risk,
			HH_EN_List_of_Measures,
			HH_EN_Assistance_for_Home_s_risk_to_wildfire,
			HH_EN_HH_EN_Dates_Funding_Received_and_Program_Names,
			HH_EN_Date_Funding_Received,
			HH_EN_Other_Program_Name,
			HH_EN_Program_Name,
			HH_EN_Action,
			HH_EN_Add_Line_Item,
			HH_EN_Available,
			HH_EN_Selected,
			HH_EN_First_Name,
			HH_EN_Last_Name,
			HH_EN_Four_Digit_Validation,
			HH_EN_Prior_Year_Validation,
			HH_EN_MissingFieldValueError,
			HH_EN_characters_remaining,
			HH_Application_Stage_Draft,
			HH_Application_Status_New,
			HH_EN_any_assistance_from_any_program,
			HH_EN_assistance_and_approximately_when,
			HH_EN_property_currently_damaged_static_text
	}
    storeValueMap = new Map();
    @track deedRowSize =0;
	isLoading = true;
	isMortgaged = false;
	otherNamesPresent = false;
	showMeasures= false;
	showPrograms= false;
  currentIndex = 0;
	currentDeedIndex = 100;
	describeDamage = false;
	isMobile = false;
	makeCountyFieldReadOnly = false;
	@track dualListSelected = [];
    @track count =1000;
    @track countMeasures = 1000;
    @track countProgram = 1000;
		@api isHomeowner;

	@wire(getObjectInfo, { objectApiName: APPLICATION_OBJECT })
	objectInfo;

	@wire(getPicklistValues, {
		recordTypeId: '$objectInfo.data.defaultRecordTypeId',
		fieldApiName: PROPERTY_STRUCTURE_FIELD
	})
	propertStructurePicklistValues;

	@wire(getPicklistValues, {
		recordTypeId: '$objectInfo.data.defaultRecordTypeId',
		fieldApiName: County__c
	})
	countyPicklistValues;

	@wire(getPicklistValues, {
		recordTypeId: '$objectInfo.data.defaultRecordTypeId',
		fieldApiName: Authority_to_make_updates_to_the_Home__c
	})
	authorityPicklistValues;

	@wire(getPicklistValues, {
		recordTypeId: '$objectInfo.data.defaultRecordTypeId',
		fieldApiName: Accessible_by_a_Passenger_Vehicle__c
	})
	passengerVPicklistValues;

	@wire(getPicklistValues, {
		recordTypeId: '$objectInfo.data.defaultRecordTypeId',
		fieldApiName: Is_National_Register_of_Historic_Places__c
	})
	regHistoryPlacesPicklistValues;

	@wire(getPicklistValues, {
		recordTypeId: '$objectInfo.data.defaultRecordTypeId',
		fieldApiName: Any_Other_Names_on_the_Property_Deed__c
	})
	propertyDeedPicklistValues;

	@wire(getPicklistValues, {
		recordTypeId: '$objectInfo.data.defaultRecordTypeId',
		fieldApiName: Property_Foreclosed_or_in__c
	})
	propertyForeClosurePicklistValues;

	@wire(getPicklistValues, {
		recordTypeId: '$objectInfo.data.defaultRecordTypeId',
		fieldApiName: Property_Liens__c
	})
	propertyLiensPicklistValues;

	@wire(getPicklistValues, {
		recordTypeId: '$objectInfo.data.defaultRecordTypeId',
		fieldApiName: Good_Standing_with_a_payment_plan_on_you__c
	})
	paymentPlanPicklistValues;

	@wire(getPicklistValues, {
		recordTypeId: '$objectInfo.data.defaultRecordTypeId',
		fieldApiName: Measures_to_Reduce_risks_to_wi__c
	})
	reduceRiskPicklistValues;

	@wire(getPicklistValues, {
		recordTypeId: '$objectInfo.data.defaultRecordTypeId',
		fieldApiName: Did_you_receive_wildfire_assistance__c
	})
	wildfireAssistancePicklistValues;

	@wire(getPicklistValues, {
		recordTypeId: '$objectInfo.data.defaultRecordTypeId',
		fieldApiName: Property_Currently_Damaged__c
	})
	propertyCurrentlyDamagedPicklistValues;

	initData() {
	    this.characterCount();
		let width = window.screen.width;
        if(width < 800) {
            this.isMobile = true;
        }
        else {
            this.isMobile = false;
        }
        window.addEventListener('resize', this.checkDeviceWidth);

//			if(this.recordLocal.Number_of_Stories__c == 0) {
//				this.recordLocal.Number_of_Stories__c = null;
//			}
//			if(this.recordLocal.Total_Living_Area__c == 0) {
//				this.recordLocal.Total_Living_Area__c = null;
//			}
			
			this.recordLocal.State__c = 'CA';
			
			if(this.recordLocal.Any_Other_Names_on_the_Property_Deed__c != undefined && this.recordLocal.Any_Other_Names_on_the_Property_Deed__c == 'Yes') {
				this.otherNamesPresent = true;
			} else {
				this.otherNamesPresent = false;
			}	 

			if(this.recordLocal.Measures_to_Reduce_risks_to_wi__c != undefined && this.recordLocal.Measures_to_Reduce_risks_to_wi__c == 'Yes') {
                let keyString = 'List_of_Measures__c-Yes';
                this.storeValueMap.set(keyString,this.recordLocal['List_of_Measures__c']);
                this.characterCount();
				this.showMeasures = true;
			} else {
				this.showMeasures = false;
			}	 

			if(this.recordLocal.Did_you_receive_wildfire_assistance__c != undefined && this.recordLocal.Did_you_receive_wildfire_assistance__c == 'Yes') {
                let keyString = 'Which_program_s_and_when__c-Yes';
                this.storeValueMap.set(keyString, this.recordLocal['Which_program_s_and_when__c']);
				this.showPrograms = true;
			} else {
				this.showPrograms = false;
			}

			if(this.recordLocal.Property_Currently_Damaged__c != undefined) {
				this.dualListSelected = this.recordLocal.Property_Currently_Damaged__c.split(";");
				if(this.dualListSelected != undefined && this.dualListSelected.length > 0) {
					this.describeDamage = true;
                    let keyString = 'Damage_Description__c-true';
                    this.storeValueMap.set(keyString,this.recordLocal['Damage_Description__c']);
                    this.characterCount();
				} else {
                    this.recordLocal['Damage_Description__c'] = null;
					this.describeDamage = false;
					this.count = 1000;
				}
			}

			if (this.recordLocal != undefined && (this.recordLocal.deedContacts != undefined && this.recordLocal.deedContacts.length > 0)) {
					for(let i =0; i<this.recordLocal.deedContacts.length; i++) {
						this.recordLocal.deedContacts[i].index = this.currentDeedIndex;
						console.log('---267--- '+this.currentDeedIndex);
						this.recordLocal.deedContacts[i]['Contact__r.FirstName'] = this.recordLocal.deedContacts[i].Contact__r.FirstName;
						this.recordLocal.deedContacts[i]['Contact__r.LastName'] = this.recordLocal.deedContacts[i].Contact__r.LastName;
						this.currentDeedIndex++;
					}
			} else {
						this.recordLocal.deedContacts = [];
						let deed = {};
						deed['index'] = this.currentDeedIndex;
						deed['Role__c'] = 'Co-owner';
						deed['Contact__r'] ={};
						this.recordLocal.deedContacts.push(deed);
						this.currentDeedIndex++;
					}
		
			if (this.recordLocal != undefined && (this.recordLocal.fundedPrograms != undefined && this.recordLocal.fundedPrograms.length > 0)) {
				console.log('in---',this.recordLocal.fundedPrograms);
				for(let i =0; i<this.recordLocal.fundedPrograms.length; i++) {
					this.recordLocal.fundedPrograms[i].index = this.currentIndex;
					this.currentIndex++;
				}
			}
			else {
				this.recordLocal.fundedPrograms = [];
				this.recordLocal.fundedPrograms.push({index : 0});
			}
			console.log('rec---',this.recordLocal);
			if(this.isHomeowner == false) {
			this.executeAction(checkCommunityUserCounty,{},
			(response) => { 
					if(response.county != undefined) {
						this.recordLocal.County__c = response.county;
						this.makeCountyFieldReadOnly = true;
					} else {
						this.makeCountyFieldReadOnly = false;
					}
			},(error)=>{
					if(error.body != undefined && error.body.message != undefined) {
							this.showErrorNotification('Error',error.body.message);
					} else {
							this.showErrorNotification('Error',error);
					}
			});
			} else {
					if(this.recordLocal.County__c != undefined &&
						!(this.recordLocal.Stage__c == this.label.HH_Application_Stage_Draft &&
							(this.recordLocal.Status__c == undefined || this.recordLocal.Status__c == this.label.HH_Application_Status_New))) {
							this.makeCountyFieldReadOnly = true;
					}
			}
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

	dualListChanged(event) {
		let selectedValues = '';
		for(let key in event.detail.value) {
			
			selectedValues += event.detail.value[key]+";";
		}
		if(selectedValues != '') {
			this.describeDamage = true;
			let keyString = 'Damage_Description__c-true';
            this.recordLocal['Damage_Description__c'] =this.storeValueMap.get(keyString);
            this.characterCount();
			selectedValues = selectedValues.slice(0,-1);
		} else {
		    this.recordLocal['Damage_Description__c'] = null;
			this.describeDamage = false;
			this.count = 1000;
		}
		this.recordLocal.Property_Currently_Damaged__c = selectedValues;
		console.log('--------335 '+this.recordLocal['Damage_Description__c']);
	}

    blankCheck(event) {
        var withoutSpace = this.recordLocal[event.target.getAttribute('data-field')].replace(/ /g,"");
        if(withoutSpace.length == 0){
            this.recordLocal[event.target.getAttribute('data-field')] = null;
        }
    }

	handleAddDeedContact(response) {
		let deed = {};
		deed['index'] = this.currentDeedIndex;
		deed['Role__c'] = 'Co-owner';
		deed['Contact__r'] ={};
		this.recordLocal.deedContacts.push(deed);
		this.currentDeedIndex++;
	}

	/*
	* Delete selected row
	*/
	handleDeleteDeedContact(response){
			let childIndex = response.detail.index;
			if( this.recordLocal.deedContacts.length > 1) {
					this.recordLocal.deedContacts.splice(childIndex, 1);
			}
	}

	updateDeedContacts() {
		if(this.recordLocal.deedContacts != undefined) {
				for(let i=0; i<this.recordLocal.deedContacts.length; i++) {
					let dataIndex = this.recordLocal.deedContacts[i].index;
					if(this.template.querySelector('[data-id="'+dataIndex+'"]') != null) {
						let deedContactRec = this.template.querySelector('[data-id="'+dataIndex+'"]').getRecordDetails();
						this.recordLocal.deedContacts[i] = deedContactRec;
					} else {
						this.recordLocal.deedContacts = [];
						return true;
					}
				}
		}	
		return true;
	}

	updateFundedPrograms() {
		if(this.recordLocal.fundedPrograms != undefined ) {
			for(let i=0; i <this.recordLocal.fundedPrograms.length; i++) {
					if(this.template.querySelector('[data-id="'+i+'"]') != null) {
						let fundedProgramRec = this.template.querySelector('[data-id="'+i+'"]').getRecordDetails();
						console.log('fundedProgramRec------',fundedProgramRec);
						if(fundedProgramRec == undefined) {
								return false;
						}
						delete fundedProgramRec.index;
						if(this.recordLocal.Id != undefined) {
							fundedProgramRec['HH_Application__c'] = this.recordLocal.Id;
						}
						this.recordLocal.fundedPrograms[i] = fundedProgramRec;
					}  else {
						this.recordLocal.fundedPrograms = [];
						return true;	
				}
			}			
		}
		return true;
	}

	updateListToParentComponentList() {
			//validate both tables first
			if(this.recordLocal.deedContacts != undefined ) {
				if(!this.otherNamesPresent) {
					this.recordLocal.deedContacts = [];
				} else {
					for(let i=0; i < this.recordLocal.deedContacts.length; i++) {
						let dataIndex = this.recordLocal.deedContacts[i].index;
						if(this.template.querySelector('[data-id="'+dataIndex+'"]') != null) {
							let deedContactRec = this.template.querySelector('[data-id="'+dataIndex+'"]').getRecordDetails();
						if(deedContactRec == undefined) {
								return undefined;
						}
					}
				}
			}
			}

			let dc = this.updateDeedContacts();
			let  fp = this.updateFundedPrograms();
			console.log('Deed Contacts Validated: ',dc);
			console.log('Funded Programs Validated: ',fp);
			if(!dc) {
				return undefined;
			}
			if(!fp) {
				return undefined;
			}
			console.log('PropertyInfo data: ', JSON.parse(JSON.stringify(this.recordLocal)));
			return this.recordLocal;
  }

	updateRecordLocal() {
			this.allInputsValidated = true;
			this.allInputsValidated = this.validateYearOfConstruction();
			let recordLocal = this.updateListToParentComponentList();
			if(recordLocal == undefined) {
				this.allInputsValidated = false;
			} else {
				this.recordLocal = recordLocal;
				console.log('this.recordLocal---', JSON.stringify(this.recordLocal));
			}
	}



	validateYearOfConstruction() {
		let yocField = this.template.querySelector('.propertyYear');
		let mailRegex =  /[1-9]\d{3,3}/;
		let year =  this.recordLocal.Year_of_Construction__c;
		let allValid = true;

		if(year == null || year == undefined || year == '') {
				yocField.setCustomValidity(this.label.HH_EN_MissingFieldValueError);
				allValid = false;
		}
		else {
				let yearMatcher = mailRegex.test(year);
				if(yearMatcher == false ) {
						allValid = false;
						yocField.setCustomValidity(this.label.HH_EN_Prior_Year_Validation);
				}else {
					let today = new Date();
					let currentYear = today.getFullYear();
					let yearOfConstruction = parseInt(year);
					if(yearOfConstruction >  currentYear) {
							yocField.setCustomValidity(this.label.HH_EN_Prior_Year_Validation);
							allValid = false;
					}  else {
							allValid = true;
							yocField.setCustomValidity('');
					}
				}
		}
		yocField.reportValidity();
		return allValid;
	}	

	handlePropertyDeedChanged(event) {
		if(event.target.value == 'Yes') {
			if(this.recordLocal.deedContacts == undefined || this.recordLocal.deedContacts.length == 0) {
				this.recordLocal.deedContacts = [];
				this.handleAddDeedContact(null);
			}
			this.otherNamesPresent = true;

		} else {
			for(let i=0; i < this.recordLocal.deedContacts.length; i++) {
				let dataIndex = this.recordLocal.deedContacts[i].index;
				if(this.template.querySelector('[data-id="'+dataIndex+'"]') != null) {
					let deedContactRec = this.template.querySelector('[data-id="'+dataIndex+'"]').getUnvalidatedRecord();
					if(deedContactRec != undefined) {
							this.recordLocal.deedContacts[i] = deedContactRec;
					}
				}
			}
			this.otherNamesPresent = false;
		}
		this.recordLocal.Any_Other_Names_on_the_Property_Deed__c = event.target.value;
	}

	handleReduceRisksChanged(event) {
		if(event.target.value == 'Yes') {
			this.showMeasures = true;
            let keyString = 'List_of_Measures__c-Yes';
            this.recordLocal['List_of_Measures__c'] =this.storeValueMap.get(keyString);
            this.characterCount();
		} else {
			this.recordLocal.List_of_Measures__c = '';
			this.showMeasures = false;
			this.countMeasures = 1000;
		}
		this.recordLocal.Measures_to_Reduce_risks_to_wi__c = event.target.value;
		console.log('List_of_Measures__c---507 '+this.recordLocal['List_of_Measures__c'])
	}

	handleWildfireAssistanceChanged(event) {
		if(event.target.value == 'Yes') {
			this.showPrograms = true;
            let keyString = 'Which_program_s_and_when__c-Yes';
            this.recordLocal['Which_program_s_and_when__c'] =this.storeValueMap.get(keyString);
            this.characterCount();
		} else {
			this.recordLocal.Which_program_s_and_when__c = '';
			this.showPrograms = false;
			this.countProgram = 1000;
		}
		this.recordLocal.Did_you_receive_wildfire_assistance__c = event.target.value;
		console.log('Which_program_s_and_when__c'+this.recordLocal['Which_program_s_and_when__c']);
	}

	get minYearAllowed() {
		return 1000.00;
	}

	get todaysDate() {
		var today = new Date();
		var dd = String(today.getDate()).padStart(2, '0');
		var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
		var yyyy = today.getFullYear();
		today = yyyy+'-'+mm+'-'+dd;
		return today
	}

	handleDamageDescription(event){
        let keyString = 'Damage_Description__c-true';
        this.storeValueMap.set(keyString,event.target.value);
        this.recordLocal['Damage_Description__c'] =this.storeValueMap.get(keyString);
        this.characterCount();
    }

    handleListOfMeasures(event){
        let keyString = 'List_of_Measures__c-Yes';
        this.storeValueMap.set(keyString,event.target.value);
        this.recordLocal['List_of_Measures__c'] =this.storeValueMap.get(keyString);
        this.characterCount();
    }

    handlePrograms(event){
        let keyString = 'Which_program_s_and_when__c-Yes';
        this.storeValueMap.set(keyString,event.target.value);
        this.recordLocal['Which_program_s_and_when__c'] =this.storeValueMap.get(keyString);
        this.characterCount();
    }
    characterCount(){
        if(this.recordLocal['Damage_Description__c']){
            this.count = 1000 - this.recordLocal['Damage_Description__c'].length ;
        }else{
            this.count = 1000;
        }
        if(this.recordLocal['List_of_Measures__c']){
            this.countMeasures = 1000 - this.recordLocal['List_of_Measures__c'].length;
        }else{
            this.countMeasures = 1000;
        }
        if(this.recordLocal['Which_program_s_and_when__c']){
            this.countProgram = 1000 - this.recordLocal['Which_program_s_and_when__c'].length;
        }else{
            this.countProgram = 1000;
        }
    }
    fieldChangedMap(event){
        let keyString = 'Which_program_s_and_when__c-Yes';
        this.storeValueMap.set(keyString, event.target.value);
        this.recordLocal['Which_program_s_and_when__c'] = this.storeValueMap.get(keyString);
    }
}