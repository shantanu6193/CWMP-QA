import { LightningElement,api,track,wire } from 'lwc';
//import {handleEmailValidation} from './util';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import saveDetails from '@salesforce/apex/ALS_ProjectJunctionEditController_Ctrl.saveDetails'
import getDetail from '@salesforce/apex/ALS_ProjectJunctionEditController_Ctrl.getDetails';
import getIncidentAndSubrecipientNameJS from '@salesforce/apex/ALS_ProjectJunctionEditController_Ctrl.getIncidentAndSubrecipientName';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import Has_Signing_Authority from '@salesforce/schema/Project_Role__c.Has_Signing_Authority__c';
import Mailing from '@salesforce/schema/Project_Role__c.Is_Mailing_Contact__c';
import Contact_Type from '@salesforce/schema/Project_Role__c.Contact_Type__c';
import Contact_Role_Global_List from '@salesforce/schema/AccountContactRole__c.Contact_Role_Global_List__c';
import Project_Role_Global_List from '@salesforce/schema/Project_Role__c.Project_Role_Global_List__c';
import PROJECT_ROLE_OBJ from '@salesforce/schema/Project_Role__c';
import PROGRAMS_FIELD from '@salesforce/schema/Project_Role__c.Programs__c';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
export default class AlsProjectJunctionEdit extends LightningElement {
   
    fieldsToReturn = " Id, Name, Sub_Recipient_FIPS__c  ";
   // fieldsToReturnForRole =" Id,Name ";
    fieldsToReturnForContact =" Id, Name, FirstName, LastName, Email, Phone, Title ";
   // whereClauseForProjectRole = " WHERE Category__c = \'Project Role\'";
   // whereClauseForContactRole = " WHERE Category__c = \'Contact Role\'";
    @api junctionId;
    @api projectId;
    @api isModalOpen;
    @api sourceObject;
    @track AccountId;
    @track AccountDetail; 
    //@track projectDetail;
    @track ContactDetail ={};
    @track projectRoleRecord ={};
    @track isEdit =false;
    @track isRendered =false;
    @track detailVisible =false;
    @track defaultContactId ;
    @track defaultAccountId ;
    @track newContactDetail ={};
    @track NewRelationContact = {};
    @track contactRole={};
    @track showContactRole =false;
    @track isDisable=false;
    @track sAuthorityList;
	@track IsMailingContactList;
    @track ContactType;
    @track ContactRole;
    @track showContactSection;
    @track hideNewRelationContact =false;
    @track hideExistingContact =false;
    @track isContactRoleRequired =false;
    @track contactRoleRequired =false;
    @track disalbleCross ="lookupOne";
    @track ContactRoleGlobalList;
    @track ProjectRoleGlobalList;
    @track issIncidentName;
    @track issSubrecipientName;
    @track isISSobject;
    @track showPrograms;
    @track programs = [];
    @track programType = [];
    @track selectedPrograms;
    @track programTypeValuesLoaded = false;

      
    connectedCallback()	{
        console.log('his.junctionId',this.junctionId);
        //If junctionId contains value means record already exist (Means form should show Edit format of form)
		if(this.junctionId != null){
            this.isEdit =true;
            //Fetching existing data of current record
			getDetail({
				junctionIds: this.junctionId
			})
				.then(result => {
                    this.projectRoleRecord =result.JunctionObj;
                    console.log('this.programs',this.programs);
                    console.log('this.projectRoleRecord.Programs__c',this.projectRoleRecord.Programs__c);

                    if(this.projectRoleRecord.Programs__c != null){
                        this.programs.push(this.projectRoleRecord.Programs__c)
                    }
                    window.scrollTo(0,0);
                    this.isRendered =true;
                    this.defaultContactId = this.projectRoleRecord.AccountContactJunction__r.Contact_Name__c;
                    this.defaultAccountId = this.projectRoleRecord.AccountContactJunction__r.Account_Name__c;
                    this.disalbleCross ="lookupTwo";
                    this.getdetailVisible();
				})
				.catch(error => {
					console.log('Error', error);
					window.scrollTo(0,0);
                });
		}
		if(this.sourceObject === 'Incident-Subrecipient') {

		    //Note : projectId receives object Ids too, change the variable name later
            getIncidentAndSubrecipientNameJS({ incidentSubrecipientSummaryId : this.projectId})
            .then(result => {
                this.issIncidentName = result.incidentName;
                this.issSubrecipientName = result.subrecipientName;
                this.isISSobject = true;
                this.showPrograms = true
            })
            .catch(error => {
                console.log('Error', error);
                window.scrollTo(0,0);
            });
        } else if(this.sourceObject === 'Subrecipient') {
            //this.programType.push(this.projectRoleRecord.Programs__c);
            this.showPrograms = true
            this.isISSobject = false;
        }else{
            this.showPrograms = false
            this.isISSobject = false;
        }

    }

    @wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: Has_Signing_Authority  })
    wiredSAuthority({
		data,
		error
	}) {
		if (data) {
			this.sAuthorityList = data.values;
		}
		if (error) {
            console.log('sAuthorityList picklist error', error);
		}
	}

	@wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: Mailing })
    wiredIsMailingContact({
		data,
		error
	}) {
		if (data) {
			this.IsMailingContactList = data.values;
		}
		if (error) {
            console.log('Is mailing contact list picklist error', error);
		}
	}
    //Picklist Values for Contact Type
	@wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: Contact_Type  })
    wiredContactType({
		data,
		error
	}) {
		if (data) {
			this.ContactType = data.values;
		}
		if (error) {
            console.log('sAuthorityList picklist error', error);
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
		}
		if (error) {
			console.log('Contact Role List picklist error '+error);
		}
    }
    
    //Picklist Values for Project Role
	@wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: Project_Role_Global_List })
    wiredProjectRole({
		data,
		error
	}) {
		if (data) {
			this.ProjectRoleGlobalList = data.values;
		}
		if (error) {
			console.log('Contact Role List picklist error '+error);
		}
	}
    @wire(getObjectInfo, { objectApiName: PROJECT_ROLE_OBJ })
    objectInfo;

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: PROGRAMS_FIELD })
        statePicklistValues({ error, data }) {
        if (data) {
            for(let key in data.values){
                this.programType.push({'label':data.values[key]['label'], 'value':data.values[key]['value']});
                console.log('this.programType',this.programType);
            }
            this.programTypeValuesLoaded = true;
        } else if (error) { console.log('state error= ',error); }
    }
    //When user selects Account
    onAccountSelection(e){ 
        this.AccountDetail = JSON.parse(JSON.stringify(e.detail.selectedRecord));
        this.AccountId =this.AccountDetail.Id;
        if(e.detail.selectedRecord) {
            if(this.isEdit == true) { //Show Page in Edit Format
                this.showContactSection =false;
            } else{
                this.showContactSection =true;
                this.hideNewRelationContact =false;
                this.hideExistingContact =false;
                this.showContactRole =false;
                
            }
        } else{
            this.isDisable =false;
            this.ContactDetail ={};
            this.showContactSection =false;
            this.hideExistingContact =true;
          this.hideNewRelationContact =true;
          this.showContactRole =true;
        }
    }

    //When user selects Existing Account Contact
    handleExistingRelationContact(e){
        if(e.detail.selectedRecord){
            this.contactRole['Contact_Role_Global_List__c'] = null;
            this.ContactDetail = JSON.parse(JSON.stringify(e.detail.selectedRecord)); 
            this.hideNewRelationContact =true;
            this.isContactRoleRequired =false;
            this.showContactRole =true;
            this.isDisable =true;
        }else {
           this.isContactRoleRequired =true;
            this.hideNewRelationContact =false;
            this.showContactRole =false;
            this.isDisable =false;
            if(this.isDisable ==false){
               this.ContactDetail ={};
            }
        }
    }
        //When user Select New contact for Create relation
        handleNewRelationContact(e){
            if(e.detail.selectedRecord){
                this.ContactDetail = JSON.parse(JSON.stringify(e.detail.selectedRecord));
                this.hideExistingContact =true;
                this.showContactRole =true;
                this.isDisable =true;
                if( this.contactRole['Contact_Role_Global_List__c'] == null){
                    this.isContactRoleRequired =true;
                }else{
                     this.isContactRoleRequired =false;
                }

            }else {
                this.isContactRoleRequired =false;
                this.hideExistingContact =false;
                this.showContactRole =false;
                this.isDisable =false;
                if(this.isDisable ==false){
                     this.ContactDetail ={};
                  }
            }
        }
            //When user Creates new contact and then Creates a relation
            handleCreateNewContact(e){

                 if(e.target.value){
                     this.hideExistingContact =true;
                     this.hideNewRelationContact =true;
                      this.ContactDetail[e.target.getAttribute('data-field')] = e.target.value;
                      if(this.ContactDetail.LastName != null){
                          if(this.contactRole.Contact_Role_Global_List__c){
                            this.isContactRoleRequired =false;
                          }else{
                            this.isContactRoleRequired =true;
                          }
                      } else{
                        this.isContactRoleRequired =false;
                      }
                } else if( this.ContactDetail == {}){
                      this.hideExistingContact =false;
                      this.hideNewRelationContact =false;
                      this.isContactRoleRequired =false;
                }
           }

    handleProjectRoleListChange(e){
        this.projectRoleRecord['Project_Role_Global_List__c'] = e.target.value;
    }

    handleProjectRoleDetail(e){
        this.projectRoleRecord[e.target.getAttribute('data-field')] = e.target.value;
    }

    handleContactRoleListChange(e){
        this.contactRole['Contact_Role_Global_List__c'] = e.target.value;
        this.isContactRoleRequired =false;
    }

    /*onProjectSelection(e){
       this.projectDetail = e.detail.selectedRecord;
    }*/

    closeModal(event) {
        this.isModalOpen = event.target.value;
        const selectedEvent = new CustomEvent("closemodal", {
        detail: this.isModalOpen
    });
    this.dispatchEvent(selectedEvent);
    }

    successToast(){
		const event = new ShowToastEvent({
			title: 'Success',
			message: 'Success! Your record has been saved successfully..',
			variant: 'success',
			mode: 'dismissable'
		});
        this.dispatchEvent(event);
        this.template.querySelector('c-lwc-lookup').ClearVal();
	}

	errorToast(msg){
		const event = new ShowToastEvent({
			title: 'Error',
			message: msg,
			variant: 'error',
			mode: 'dismissable' //pester
		});
		this.dispatchEvent(event);
    }

    clearForm(){
        console.log('Inside Clear');
          if(this.isEdit){
            //this.template.querySelector('[data-lookup="project_Role__c_Lookup"]').ClearVal();
            this.projectRoleRecord.Project_Role_Global_List__c=null;
            this.projectRoleRecord.Has_Signing_Authority__c =null;
            this.projectRoleRecord.Is_Mailing_Contact__c =null;
            this.projectRoleRecord.Contact_Type__c =null;
            console.log('Is Edit ? '+this.isEdit);  
          }
          else{
            //this.template.querySelector('[data-lookup="project_Role__c_Lookup"]').ClearVal();
            this.projectRoleRecord ={};
            this.ContactDetail ={};
            this.isDisable =false;
            this.showContactSection =false;
            this.hideExistingContact =true;
            this.hideNewRelationContact =true;
             this.contactRole['Contact_Role_Global_List__c'] = null;
             this.AccountDetail =null;
            //this.showContactRole =true;
            this.template.querySelector('[data-lookup="Account_Lookup"]').ClearVal();
            this.template.querySelector('[data-lookup="Contact_Lookup"]').ClearVal();
            this.template.querySelector('[data-lookup="NewContact_Lookup"]').ClearVal();
          }
    }
    onOutSideLookupClick(){
        this.template.querySelector('[data-lookup="Account_Lookup"]').hideDropDownList();
        this.template.querySelector('[data-lookup="Contact_Lookup"]').hideDropDownList();
        this.template.querySelector('[data-lookup="NewContact_Lookup"]').hideDropDownList();
    }
    //Checking validation for required fields
    validation(){
            if(this.isEdit == true && this.projectRoleRecord.Project_Role_Global_List__c != null &&
            this.projectRoleRecord.Has_Signing_Authority__c != null &&
            this.projectRoleRecord.Is_Mailing_Contact__c !=null &&
            this.projectRoleRecord.Contact_Type__c  != null
            ){
                return true;
            }
            else if(this.isEdit == false && this.AccountDetail
             && this.ContactDetail.LastName
             && this.projectRoleRecord.Has_Signing_Authority__c
             && this.projectRoleRecord.Contact_Type__c
             && this.projectRoleRecord.Is_Mailing_Contact__c
             && this.projectRoleRecord.Project_Role_Global_List__c
             && this.isContactRoleRequired != true )
             {
                   return true;
             }
             else{
                 return false;
             }
    }

    handleSelectedvalues(event){
        const selectedVal = event.detail.eventvalue;
        this.programs=[];
        selectedVal.forEach((element) => {
            this.programs.push(element)
        });
    }


    saveRecord(event){
        let selectedValues = '';
        for(let key in this.programs) {
            selectedValues += this.programs[key]+";";
        }
        if(selectedValues != '') {
            selectedValues = selectedValues.slice(0,-1);
        }
        this.projectRoleRecord.Programs__c = selectedValues;
        console.log('this.projectRoleRecord.Programs__c',this.projectRoleRecord.Programs__c);
         if(this.sourceObject == 'Incident-Subrecipient' || this.sourceObject == 'Subrecipient') {
             if(this.projectRoleRecord.Programs__c) {

             } else {
                 this.errorToast('Please select Programs');
                 return;
             }
         }
       
      if(this.validation()) {//If All validation requirements get full filled then call to Apex for Saving data

        saveDetails({
            //projectDetail:JSON.stringify(this.projectDetail),
            projectRecordId:this.projectId ,
            AccountDetail:JSON.stringify(this.AccountDetail),
            ContactDetail:JSON.stringify(this.ContactDetail),
            contactRole:JSON.stringify(this.contactRole),
            ProjectRoleDetail:JSON.stringify(this.projectRoleRecord),
            isEdit : this.isEdit,
            srcObject : this.srcObjectApiName,
            programs : selectedValues
        })
            .then(result => {
                this.successToast();
                console.log('created');
                this.closeModal(event);
                window.scrollTo(0,0);

            })
            .catch(error => {
                console.log('Error', error);
                this.errorToast(error.body.message);
                window.scrollTo(0,0);
            });
        
      }
      else{
          if(this.AccountDetail){
              this.errorToast('Please fill required fields');
          }else{
               this.errorToast('Please select Account');
          }
      }
    }

   //To Auto populate project field fro LWC lookup
    get getprojectId(){
        return this.projectId;    
    }

    //To Change label of Page (Edit Project Role/New Project Role)
    get getEditRecord(){
        return this.isEdit;
    }

    //To Check user clicked on Edit button or view button
    get getdetailVisible(){
      if(this.isRendered == true || this.isEdit == false){
          return true;
      }
      return false;
    }

    get headerText() {
        switch(this.sourceObject) {
            case 'Project' : return 'Project';
            case 'Incident' : return 'Incident';
            case 'Incident-Subrecipient' : return 'Incident Subrecipient';
            case 'Subrecipient' : return 'Subrecipient';
        }
    }

    get roleLabel() {
        return this.sourceObject === 'Project' ? 'Project Role' : 'Role';
    }

    get srcObjectApiName() {
        switch(this.sourceObject) {
            case 'Project' : return 'Project__c';
            case 'Incident' : return 'Incident__c';
            case 'Incident-Subrecipient' : return 'Incident_Subrecipient_Stage__c';
            case 'Subrecipient' : return 'Account';
        }
    }

    get srcObjNameFieldLabel() {
        switch(this.sourceObject) {
            case 'Project' : return 'Project Name';
            case 'Incident' : return 'Incident Name';
            case 'Incident-Subrecipient' : return 'Incident Subrecipient Name';
            case 'Subrecipient' : return 'Subrecipient Name';
        }
    }
}