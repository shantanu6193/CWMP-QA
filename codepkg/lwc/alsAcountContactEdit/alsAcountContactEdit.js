/**
 * Created by nehab on 26-10-2020.
 */

import {LightningElement , wire , track , api} from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
//import Has_Signing_Authority from '@salesforce/schema/AccountContactRole__c.Has_Signing_Authority__c';
//import Contact_Role from '@salesforce/schema/AccountContactRole__c.Role__c';
import Status from '@salesforce/schema/AccountContactRole__c.Status__c';
import Contact_Role_Global_List from '@salesforce/schema/AccountContactRole__c.Contact_Role_Global_List__c';
//import Is_Mailing_Contact from '@salesforce/schema/AccountContactRole__c.Is_Mailing_Contact__c';
//import Contact_Type from '@salesforce/schema/AccountContactRole__c.Contact_Type__c';
import saveDetails from '@salesforce/apex/ALS_AcountContactEdit_Ctrl.saveDetails';
import getDetail from '@salesforce/apex/ALS_AcountContactEdit_Ctrl.getDetails';
export default class AlsAcountContactEdit extends LightningElement {
	@api accountId;
	@api junctionId ='';
	@track isEdit = false;
	//@track contactRecord = {};
	@track junctionRecord = {};
	//@track sAuthorityList;
	////@track RoleList;
	@track StatusList;
	@track ContactRoleGlobalList;
	//@track IsMailingContactList;
	//@track ContactType;
	@api isModalOpen;
	@track contactRecordId;
	@track ContactDetail = {};
	@track tempContact = {};
	@track isDisabled = false;
	@track isContact= false;
	@track AccId;
	@track defaultRoleId ;
	@track contactRole={};
	@track ContactRole;
	@track isRendered =false;
	fieldsToReturn = "Id, Name, FirstName, LastName, Email, Phone, Title";
	//fieldsToReturnForRole ="Id,Name";
	//whereClauseForContactRole = "WHERE Category__c = \'Contact Role\'";


	connectedCallback()
	{
		//console.log('junctionId+++++ ', this.junctionId);
		if(this.junctionId != null){
			this.isEdit =true;
			this.isDisabled=true;

			getDetail({
				junctionIds: this.junctionId
			   })
				.then(result => {
					//console.log('result++++++++++ ',JSON.stringify(result));
					//console.log('result++++++++++ Id '+result.JunctionObj.Id);
					this.junctionRecord =result.JunctionObj;
					this.ContactDetail =result.ContactObj;
					//console.log('this.junctionRecord+++++ Id '+ JSON.stringify(this.junctionRecord));
					//console.log('this.ContactDetail+++++++++ Id '+ JSON.stringify(this.ContactDetail));
					window.scrollTo(0,0);
					this.isRendered =true;
					this.defaultRoleId = this.junctionRecord.Contact_Role__c;
					this.getdetailVisible();
				})
				.catch(error => {
					console.log('Error', error);
					window.scrollTo(0,0);
				});
		}
	}

	//Picklist Values for Status
	@wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: Status })
    wiredStatus({
		data,
		error
	}) {
		if (data) {
			this.StatusList = data.values;
			//console.log('Status List picklist', this.StatusList);
		}
		if (error) {
            console.log('Status picklist error '+error);
		}
	}

	//Picklist Values for Contact Role
	@wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: Contact_Role_Global_List })
    wiredContactRole({
		data,
		error
	}) {
		if (data) {
			this.ContactRoleGlobalList = data.values;
			//console.log('Contact Role List picklist', this.ContactRoleGlobalList);
		}
		if (error) {
			console.log('Contact Role List picklist error '+error);
		}
	}

	handleContactChange(e) {
		try{
			//let tmpObj = JSON.parse(JSON.stringify(this.detailContact));
			//console.log('e.target.getAttribute(data-field)+++++ '+e.target.getAttribute('data-field'));
			//console.log('e.target.value++++ '+e.target.value);
            this.ContactDetail[e.target.getAttribute('data-field')] = e.target.value;
			//console.log('this.ContactDetail++ '+JSON.stringify(this.ContactDetail));
			//this.ContactDetail = tmpObj;
		}
		catch(e)
		{
			console.log('handleContactChange Exception',e);
		}
	}

	handleJunctionChange(e) {
		this.junctionRecord[e.target.getAttribute('data-field')] = e.target.value;
	}
	handleContactRoleChange(e){

        this.junctionRecord['Contact_Role__c'] = JSON.parse(JSON.stringify(e.detail.selectedRecordId));
        //console.log('this.contactRole++',JSON.stringify( this.junctionRecord));
	}

	handleContactRoleListChange(e){
		this.junctionRecord['Contact_Role_Global_List__c'] = e.target.value;
	}

	onAccountSelection(e){
		//console.log(e.detail.selectedValue+'******'+e.detail.selectedRecordId) ;
		//this.accountName = e.detail.selectedValue;
		//this.accountRecordId = e.detail.selectedRecordId;
		this.ContactDetail['AccountId']=e.detail.selectedRecordId;
		this.AccId =e.detail.selectedRecordId;
		//console.log('this.ContactDetail[AccountId]++++++++++++'+this.ContactDetail.AccountId);
	}

	onContactSelection(e){
		if(e.detail.selectedRecord)
		{
            //console.log('Inside onContactSelection++++++++++++')
		this.tempContact = JSON.parse(JSON.stringify(e.detail.selectedRecord));
		this.ContactDetail = this.tempContact;
            //console.log('this.ContactDetail++++++++++++'+this.ContactDetail);
		this.isContact = true;
		if(this.ContactDetail =='')
		{
			this.isDisabled =false;
		}
		else{
			this.isDisabled =true;
		}
		}
		else{
			this.ContactDetail ={};
			this.isDisabled =false;
			this.isContact = false;
		}
	}
	handleOnClickEdit(e)
	{
		//console.log('Inside EditContact++++++++++++++++++++++++++++++++++++++');
		//this.isEdit = true;
		this.isDisabled =false;
	}

	closeModal(event) {
			this.isModalOpen = event.target.value;
            const selectedEvent = new CustomEvent("closemodal", {
            detail: this.isModalOpen
        });
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
        //console.log('handleSuccess event Child - Event Dispatched');
	}

	 onOutSideLookupClick(){
        this.template.querySelector('[data-lookup="Contact_Lookup"]').hideDropDownList();
     }

	successToast() {
		const event = new ShowToastEvent({
			title: 'Success',
			message: 'Success! Your record has been saved successfully..',
			variant: 'success',
			mode: 'dismissable'
		});
		this.dispatchEvent(event);
	}

	errorToast(mes) {
		const event = new ShowToastEvent({
			title: 'Error',
			message:mes ,
			variant: 'error',
			mode: 'dismissable' //pester
		});
		this.dispatchEvent(event);
	}
	clearForm()
	{
		if(this.isEdit)
		{
			console.log('IsEsdit ='+this.isEdit);
		this.isDisabled =true;
		//this.junctionRecord ={};
		this.junctionRecord.Status__c=null;
		this.junctionRecord.Contact_Role_Global_List__c=null;
	    //this.ContactDetail ={};
		}
		else{
			console.log('IsEsdit ='+this.isEdit);
	   this.template.querySelector('[data-lookup="Contact_Lookup"]').ClearVal();
		this.isDisabled =false;
		this.isContact = false;
		this.junctionRecord ={};
	    this.ContactDetail ={};

		}
	}

	validation()
	{
		if(this.junctionRecord.Status__c && this.junctionRecord.Contact_Role_Global_List__c && this.ContactDetail.LastName) //this.junctionRecord.Has_Signing_Authority__c && this.junctionRecord.Contact_Type__c && this.junctionRecord.Role__c
		{
           return true;
		}
		else{
			return false;
		}
	}

	saveRecord(e) {
		/*console.log('saveRecord===== '+JSON.stringify(this.ContactDetail));
		console.log('saveRecord===== '+JSON.stringify(this.junctionRecord));
		console.log('saveRecord===== '+JSON.stringify(this.isContact));
		console.log('saveRecord===== '+JSON.stringify(this.isEdit));
		console.log('saveRecord===== '+JSON.stringify(this.AccId));
		console.log('++++++++++++++++++++++++++++++++++++++++'+ JSON.stringify(this.contactRole));*/

		if(this.validation()){
			saveDetails({
				ContactDetail: JSON.stringify(this.ContactDetail),
				junctionRecord: JSON.stringify(this.junctionRecord),
				isContact:this.isContact,
				isEdit:this.isEdit,
				AccountIds:this.AccId

			   })
				.then(result => {
					this.successToast();
					console.log('created');
					this.closeModal(e);
					window.scrollTo(0,0);

				})
				.catch(error => {
					console.log('Error', error);
					this.errorToast(error.body.message);
					window.scrollTo(0,0);
				});

			console.log(this.ContactDetail);
			console.log(this.junctionRecord);

			}
			else{
				this.errorToast('LastName ,Status and Contact Role are required..');
			}
	}
	get hasContact(){
		return this.isContact;
	}
	get EditContact()
	{
		return this.isEdit;
	}

	get getAccountId()
	{
		return this.accountId;
	}
	get getJunctionId()
	{
		return this.junctionId;
	}

	get getdetailVisible()
    {
      if(this.isRendered == true || this.isEdit == false)
      {
          return true;
      }
      return false;
    }
 }