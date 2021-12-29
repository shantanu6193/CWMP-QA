import { LightningElement,track,api,wire } from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
//import Role from '@salesforce/schema/AccountContactRole__c.Role__c';
import Status from '@salesforce/schema/AccountContactRole__c.Status__c';
import Contact_Role_Global_List from '@salesforce/schema/AccountContactRole__c.Contact_Role_Global_List__c';
import getDetail from '@salesforce/apex/ALS_ContactAcountEdit_Ctrl.getDetails';
import saveDetails from '@salesforce/apex/ALS_ContactAcountEdit_Ctrl.saveDetails';

export default class AlsContactAccountEdit extends LightningElement {

    fieldsToReturn = "Id, Name  ";
    @api contactId;
    @api junctionId;
    @track AccountDetail = {};
    @track isDisabled = false;
    @track junctionRecord = {};
    //@track RoleList;
    @api isModalOpen;
    @track isAccount= false;
    @track isEdit = false;
    @track StatusList;
    @track ContactRoleGlobalList;
    @api accountId;
    @track ConId;
    @track isRendered =false;

    //whereClauseForContactRole = "WHERE Category__c = \'Contact Role\'";
    //fieldsToReturnForRole ="Id,Name";


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
					this.AccountDetail =result.accountObj;
					//console.log('this.junctionRecord+++++ Id '+ JSON.stringify(this.junctionRecord));
					//console.log('this.AccountDetail+++++++++ Id '+ JSON.stringify(this.AccountDetail));
                    window.scrollTo(0,0);
                    this.isRendered =true;
					this.defaultRoleId = this.junctionRecord.Contact_Role__c;
                    this.getdetailVisible()
				})
				.catch(error => {
					console.log('Error', error);
					window.scrollTo(0,0);
				});
		}
	}	
   
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
            console.log('Status List picklist error', error);
		}
    }
    
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

    onAccountSelection(e){ 
        if(e.detail.selectedRecord)
        {
            //console.log('Inside onAccountSelection++++++++++++')
            this.AccountDetail = JSON.parse(JSON.stringify(e.detail.selectedRecord));
        
            this.isAccount = true;
            if(this.AccountDetail =='')
            {
                this.isDisabled =false;
            }
            else{
                this.isDisabled =true;
            }
        }
        else{
            this.AccountDetail={};
            this.isAccount = false;
            this.isDisabled =false;
        }
		
		
    } 
    oncontactSelection(e){ 
		//console.log(e.detail.selectedValue+'******'+e.detail.selectedRecordId) ;
		//this.accountName = e.detail.selectedValue;  
		//this.accountRecordId = e.detail.selectedRecordId;  
        this.AccountDetail['ContactId']=e.detail.selectedRecordId;
        this.ConId =e.detail.selectedRecordId;
    } 

    
    handleAccountChange(e) {
            this.AccountDetail[e.target.getAttribute('data-field')] = e.target.value;
    }
    
    handleOnClickEdit(e){
		//console.log('Inside EditContact++++++++++++++++++++++++++++++++++++++');
		//this.isEdit = true;
		this.isDisabled =false;
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
	
    clearForm()
	{   
        if(this.isEdit)
        {
            //this.junctionRecord ={};
            this.junctionRecord.Contact_Role_Global_List__c=null;
            this.junctionRecord.Status__c=null;
             this.isDisabled =true;
            this.template.querySelector('[data-lookup="Account_Lookup"]').ClearVal();
        }
        else{
            this.AccountDetail ={};
        //this.junctionRecord ={};
        this.isDisabled =false;
        this.isAccount = false;
        this.junctionRecord.Contact_Role_Global_List__c=null;
        this.junctionRecord.Status__c=null;
        this.template.querySelector('[data-lookup="Account_Lookup"]').ClearVal();

        }
		//this.template.querySelector('c-lwc-lookup').ClearVal();
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

successToast() {
    const event = new ShowToastEvent({
        title: 'Success',
        message: 'Success! Success! Your record has been saved successfully..',
        variant: 'success',
        mode: 'dismissable' //pester
    });
    this.dispatchEvent(event);
}

errorToast(msg) {
    const event = new ShowToastEvent({
        title: 'Error',
        message: msg,
        variant: 'error',
        mode: 'dismissable'
    });
    this.dispatchEvent(event);
}

     onOutSideLookupClick(){
            this.template.querySelector('[data-lookup="Account_Lookup"]').hideDropDownList();
     }

    validation(){
		if(this.junctionRecord.Contact_Role_Global_List__c && this.junctionRecord.Status__c && this.AccountDetail.Name  )//&& this.AccountDetail.ContactId
		{
           return true;
		}
        else
        {
			return false;
		}
	}


saveRecord(e) {
    /*console.log('handleClick===== 1'+JSON.stringify(this.AccountDetail));
    console.log('handleClick===== 2'+JSON.stringify(this.junctionRecord));
    console.log('handleClick===== 3'+this.ConId);*/
    if(this.validation()){
        saveDetails({
            AccountDetail: JSON.stringify(this.AccountDetail),
            junctionRecord: JSON.stringify(this.junctionRecord),
            isAccount:this.isAccount,
            isEdit:this.isEdit,
            ContactIds :this.ConId
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

        console.log(this.AccountDetail);
        console.log(this.junctionRecord);
        }
     else{
        this.errorToast('Please fill required fields..');
         }
}

    get getContactId()
	{
		return this.contactId;
    }
    
    get EditContact()
	{
		return this.isEdit;
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