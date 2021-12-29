import { LightningElement, track, api, wire} from 'lwc';
import Utility from 'c/utility';
import { getObjectInfo,getPicklistValues } from 'lightning/uiObjectInfoApi';
import APPLICATION_OBJECT from '@salesforce/schema/HH_Application__c';
import getApplicationData from '@salesforce/apex/HH_ApplicationCtrl.getApplicationRecord';
import saveApplication from '@salesforce/apex/HH_ApplicationCtrl.saveApplication';
import validateApplication from '@salesforce/apex/HH_ApplicationValidationCtrl.validateApplication';
import saveDocument from '@salesforce/apex/HH_ApplicationCtrl.updateDocumentRecord';
import createDocument from '@salesforce/apex/HH_ApplicationCtrl.createDocumentRecord';
import deleteDocument from '@salesforce/apex/HH_ApplicationCtrl.deleteDocument';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import HH_EN_Applicant_Certification_Right_of_Entry_Page_Title from '@salesforce/label/c.HH_EN_Applicant_Certification_Right_of_Entry_Page_Title';
import HH_EN_California_Wildfire_Home_Hardening_Application_Page_Tittle from '@salesforce/label/c.HH_EN_California_Wildfire_Home_Hardening_Application_Page_Tittle';
import HH_EN_Applicant_Information_Page_Title from '@salesforce/label/c.HH_EN_Applicant_Information_Page_Title';
import HH_EN_Eligibility_Information_Page_Title from '@salesforce/label/c.HH_EN_Eligibility_Information_Page_Title';
import HH_EN_Residence_Information from '@salesforce/label/c.HH_EN_Residence_Information';
import HH_EN_HOMEOWNER_APPLICATION_DOCUMENTATION from '@salesforce/label/c.HH_EN_HOMEOWNER_APPLICATION_DOCUMENTATION';
import HH_EN_Save_Submit from '@salesforce/label/c.HH_EN_Save_Submit';
import HH_EN_Save_Exit from '@salesforce/label/c.HH_EN_Save_Exit';
import HH_EN_Save_Continue from '@salesforce/label/c.HH_EN_Save_Continue';
import HH_EN_Save from '@salesforce/label/c.HH_EN_Save';
import HH_EN_Previous from '@salesforce/label/c.HH_EN_Previous';
import HH_EN_DocumentReuiredError from '@salesforce/label/c.HH_EN_DocumentReuiredError';
import HH_EN_Application_saved_successfully from '@salesforce/label/c.HH_EN_Application_saved_successfully';
import HH_EN_Thank_You from '@salesforce/label/c.HH_EN_Thank_You';
import HH_EN_Application_submitted_successfully from '@salesforce/label/c.HH_EN_Application_submitted_successfully';
import HH_EN_Exit from '@salesforce/label/c.HH_EN_Exit';
import HH_EN_Preview from '@salesforce/label/c.HH_EN_Preview';
import HH_EN_Please_Check_Required_Validation from '@salesforce/label/c.HH_EN_Please_Check_Required_Validation';
import HH_EN_Self_Relation_To_Homeowner_Validation from '@salesforce/label/c.HH_EN_Self_Relation_To_Homeowner_Validation';
import HH_EN_Fill_Required_Fields_on_Page from '@salesforce/label/c.HH_EN_Fill_Required_Fields_on_Page';
import HH_EN_Property_Owner_ID from '@salesforce/label/c.HH_EN_Property_Owner_ID';
import HH_EN_Proof_of_Ownership from '@salesforce/label/c.HH_EN_Proof_of_Ownership';
import HH_EN_Proof_of_Rental from '@salesforce/label/c.HH_EN_Proof_of_Rental';
import HH_EN_Stage from '@salesforce/label/c.HH_EN_Stage';
import HH_EN_Uploaded from '@salesforce/label/c.HH_EN_Uploaded';
import HH_EN_Application_Already_Submitted from '@salesforce/label/c.HH_EN_Application_Already_Submitted';
import HH_Information_PDF from '@salesforce/label/c.HH_Information_PDF';
import HH_EN_HERE from '@salesforce/label/c.HH_EN_HERE';
import HH_EN_Duplicate_Contact_Detected from '@salesforce/label/c.HH_EN_Duplicate_Contact_Detected';


export default class hhApplication extends Utility {
    currentStage = '';
    navigationStage = '';
    actionClicked = '';
    recordId;
    currentPathOrder ;
    houseHoldNumber;
    language = 'en_US';
    isSubmit = false;
    isHomeowner = false;
    @track isExternalUser = false;
    @track disableSave = false;
    @track showPath = false;
    @track customPaths =[];
    @track label = {
        HH_EN_Applicant_Certification_Right_of_Entry_Page_Title,
        HH_EN_California_Wildfire_Home_Hardening_Application_Page_Tittle,
        HH_EN_Applicant_Information_Page_Title,
        HH_EN_Eligibility_Information_Page_Title,
        HH_EN_Residence_Information,
        HH_EN_HOMEOWNER_APPLICATION_DOCUMENTATION,
        HH_EN_Save_Submit,
        HH_EN_Save_Exit,
        HH_EN_Save_Continue,
        HH_EN_Save,
        HH_EN_Previous,
        HH_EN_Application_saved_successfully,
        HH_EN_Application_submitted_successfully,
        HH_EN_Thank_You,
        HH_EN_DocumentReuiredError,
        HH_EN_Exit,
        HH_EN_Please_Check_Required_Validation,
        HH_EN_Preview,
        HH_EN_Self_Relation_To_Homeowner_Validation,
        HH_EN_Fill_Required_Fields_on_Page,
        HH_EN_Proof_of_Rental,
        HH_EN_Proof_of_Ownership,
        HH_EN_Property_Owner_ID,
        HH_EN_Stage,
        HH_EN_Uploaded,
        HH_EN_Application_Already_Submitted,
        HH_Information_PDF,
        HH_EN_HERE,
        HH_EN_Duplicate_Contact_Detected
    }

    get stagesList() {
            return ['ApplicantInfo','EligibilityInfo','PropertyInfo','ApplicationDocumentation','ApplicantCertification','Preview'];
    }

    /*Prepare Path details */
    preparePathDetails() {
        console.log('Applicant Label: '+this.label.HH_EN_Applicant_Information_Page_Title);
       this.customPaths =  [
            {'name':'ApplicantInfo','order':1, 'label': this.label.HH_EN_Applicant_Information_Page_Title},
            {'name':'EligibilityInfo','order':2,'label': this.label.HH_EN_Eligibility_Information_Page_Title},
            {'name':'PropertyInfo','order':3, 'label': this.label.HH_EN_Residence_Information},
            {'name':'ApplicationDocumentation', 'order':4,'label': this.label.HH_EN_HOMEOWNER_APPLICATION_DOCUMENTATION},
            {'name':'ApplicantCertification', 'order':5,'label':this.label.HH_EN_Applicant_Certification_Right_of_Entry_Page_Title},
            {'name':'Preview', 'order':6,'label':this.label.HH_EN_Preview}
        ];
        this.customPaths.forEach(p => {
            if(p.name == this.currentStage) {
                this.currentPathOrder = p.order; 
            }
        });
        this.showPath = true;
        this.retrieveData(this.currentStage);
        console.log('paths: ',this.customPaths);
        console.log('currentPathOrder: ',this.customPaths);
    }

    /* Get RecordId and CurrentStage */
    @wire(CurrentPageReference)
    setCurrentPageRef(currentPageReference) {
        if(currentPageReference && currentPageReference.state ) {
            if(currentPageReference.state.id) {
                this.recordId = currentPageReference.state.id;
            }
            if(currentPageReference.state.c__id) {
                this.recordId = currentPageReference.state.c__id;
            }
            
            if(currentPageReference.state.currentStage) {
                let currentStageURL = currentPageReference.state.currentStage;
                if(currentStageURL) {
                this.currentStage = currentStageURL;
                this.preparePathDetails();
                }   
            }
            if(currentPageReference.state.c__currentStage) {
                let currentStageURL = currentPageReference.state.c__currentStage;
                if(currentStageURL) {
                this.currentStage = currentStageURL;
                this.preparePathDetails();
                }   
            }
            
        } 
    }

    
    /*Initialize the currentStage and Application Data */
    initData() {
        if(this.currentStage == undefined || this.currentStage=='' || this.currentStage == 'Record Submitted'){
            this.currentStage ='ApplicantInfo';
            this.preparePathDetails();
        }
        console.log('ApplicationID: '+this.recordId);
        //this.retrieveData(this.currentStage);
		console.log('Application loading for Stage:'+this.currentStage);
    }

    /* Retrieve Application and related Data*/
    retrieveData(stageName) {
        console.log('retrieveData:----- '+this.currentStage);
        this.recordId = this.recordId == undefined ? null : this.recordId;
        this.executeAction(getApplicationData, {'applicationId' : this.recordId}, 
            (response) => {
                console.log('retrieveData Success:----- '+this.currentStage);
                    this.handleGetDataResponse(response, stageName);
            },(error)=>{
                if(error.body != undefined && error.body.message != undefined) {
                    this.showNotification('Error Fetching Data1', error.body.message, 'error', 'Dismissible');
                } else {
                    this.showNotification('Error Fetching Data2', error, 'error', 'Dismissible');
                }
        });
    }

    handleGetDataResponse(result, stageName) {
        this.record = result.application;
        this.recordLocal = result.application;
        this.isHomeowner = result.isHomeowner;
        this.isExternalUser = result.isExternalUser;
        this.recordLocal['contacts'] = result.appContacts;
        this.recordLocal['deedContacts'] = result.deedContacts;
        this.recordLocal['fundedPrograms'] = result.fundedPrograms;
        this.recordLocal['documents'] = result.documents;
        this.houseHoldNumber = result.houseHoldNumber;
        this.currentStage = stageName;
    }

    @wire(getObjectInfo, { objectApiName: APPLICATION_OBJECT })
    objectInfo;

    get isApplicantInfoStage() {
        if(this.currentStage == 'ApplicantInfo') return true;
        return false;
    }
    get isEligibilityInfoStage() {
        if(this.currentStage == 'EligibilityInfo') return true;
        return false;
    }
    get isPropertyInfoStage() {
            if(this.currentStage == 'PropertyInfo') return true;
            return false;
    }
    get isApplicationDocumentationStage() {
        if(this.currentStage == 'ApplicationDocumentation') return true;
        return false;
    }
    get isApplicantCertificationStage() {
        if(this.currentStage == 'ApplicantCertification') return true;
        return false;
    }
    get isApplicationPreviewStage() {
        if(this.currentStage == 'Preview') return true;
        return false;
    }

    validatePage(event) {
        console.log('Validation Invoked from Step: ',event.detail.stageName);
        if(this.getData(false) == false) {
            return;
        } else {
            this.navigationStage = event.detail.stageName;
            this.actionClicked ='navigationSave';
            this.saveRecord(this.record);
        }
    }

    getData(isPrevious) {
        if(this.template.querySelector('[data-custom="innerComponent"]') != undefined) {
            if(isPrevious == true) {
                this.template.querySelector('[data-custom="innerComponent"]').skipAllValidations();
                let localRecord = this.template.querySelector('[data-custom="innerComponent"]').getRecordDetails();
                console.log('localRecord: ',localRecord);    
                this.record = localRecord;
                return true;
            } else {
                console.log('this.currentStage: ',this.currentStage);
                this.template.querySelector('[data-custom="innerComponent"]').enableAllValidations();
                let localRecord = this.template.querySelector('[data-custom="innerComponent"]').getRecordDetails();
                if(localRecord == undefined) {
                    console.error('Validate the page...!');
                    this.disableSave = false;
                    this.showNotification('',this.label.HH_EN_Please_Check_Required_Validation,'error','Dismissible');
                    return false;
                }
                if (this.currentStage == 'ApplicantInfo') {
                    this.record = this.recordLocal;
                    let validEmail  = this.template.querySelector('[data-custom="innerComponent"]').validateEmail();
                    if(validEmail == false) {
                        console.error('Validate email...!');
                        this.showNotification('',this.label.HH_EN_Please_Check_Required_Validation,'error','Dismissible');
                        return false;
                    }
                    this.houseHoldNumber  = this.template.querySelector('[data-custom="innerComponent"]').getHouseHoldNumber();
                    if(localRecord != undefined) {
                        this.record['Applicant__r'] = localRecord;
                        return true;
                    }
                } 

                if(this.currentStage == 'EligibilityInfo') {
                    if(localRecord != undefined ) {
                        let contacts = localRecord.contacts;
                        if(contacts != undefined && contacts.length > 0) {
                            let selfRelationshipFound = 0;
                            for(let i=0; i< localRecord.contacts.length; i++) {
                                let contactRec = localRecord.contacts[i];
                                if(contactRec.Relationship_to_Homeowner__c != undefined && contactRec.Relationship_to_Homeowner__c == 'Self') {
                                    selfRelationshipFound++;
                                }
                            }
                            if(selfRelationshipFound > 1) {
                                this.showNotification('',this.label.HH_EN_Self_Relation_To_Homeowner_Validation,'error','Dismissible');
                                return false;
                            }
                        }
                }
                }
                this.record = localRecord;
                return true;
            }
        }
        
        return false;
    }

    redirectToPrevious() {
        this.getData(true);
        this.actionClicked = 'Previous';
        if(this.isExternalUser) {
        this.redirectToCommunityCustomPage('hh-application', {'id' : this.recordId, 'currentStage' : this.getPreviousStage()});
        } else {
            this.dispatchCloseEvent();
            let state = {};
            state['c__id'] = this.recordId;
            state['c__currentStage'] = this.getPreviousStage();
            this.navigateToComponent('c__HH_Application',state);
           // this.redirectToTabPage('HH_Application_Form',{'c__id' : this.recordId, 'c__currentStage' : this.getPreviousStage()})
        }
        this.currentStage = this.getPreviousStage();
    }

    redirectToNext() {
        console.log('clicked');
        this.disableSave = true;
        this.isSubmit = false;
             if(this.getData(false) == false) {
            this.disableSave = false;
                  return;
              }
             this.actionClicked = 'SaveandContinue';
             this.saveRecord(this.record);
    }
    AppDocValidation(){
         let proofOfRental   =false;
         let propertyOwnerID =false;
         let proofOfOwnership=false;
         let isProofOfRentalDocAvailable = false;

         for(let i=0; i<this.record.documents.length; i++){
              if(this.record.documents[i].document.Document_Type__c == this.label.HH_EN_Proof_of_Rental){
                  isProofOfRentalDocAvailable = true;
              }
             if(this.record.documents[i].document.Stage__c == this.label.HH_EN_Uploaded){
                if(this.record.documents[i].document.Document_Type__c == this.label.HH_EN_Property_Owner_ID){
                    propertyOwnerID = true;
                }
                if(this.record.documents[i].document.Document_Type__c == this.label.HH_EN_Proof_of_Rental){
                    proofOfRental = true;
                }
                if(this.record.documents[i].document.Document_Type__c == this.label.HH_EN_Proof_of_Ownership){
                    proofOfOwnership = true;
                }
             }else if(this.record.documents[i].document.Stage__c != this.label.HH_EN_Uploaded
                 && this.record.documents[i].document.Document_Type__c == this.label.HH_EN_Proof_of_Rental
                 && this.record.Currently_Occupied__c !='Yes'){
                  proofOfRental = true;
             }
         }
         if(this.record.Currently_Occupied__c !='Yes' && isProofOfRentalDocAvailable == false){
             proofOfRental = true;
         }
         if(proofOfRental == true && propertyOwnerID == true && proofOfOwnership == true){
             this.validateApplication();
         }else{
             this.showNotification('Error', this.label.HH_EN_DocumentReuiredError, 'error', 'Dismissible');
         }
    }

    validateApplication() {
        let pageNumbers = '';
        this.executeAction(validateApplication, {'applicationId' : this.recordId},
        
        (response) => { 
            for (let pageNumber in response) {
                if(response[pageNumber] == false) {
                    pageNumbers += pageNumber+', '
                }
            }
            if(pageNumbers != '') {
                pageNumbers = pageNumbers.substring(0, pageNumbers.length - 2);
                let errorMessage = this.label.HH_EN_Fill_Required_Fields_on_Page;
                errorMessage = errorMessage.replace('{{x}}',pageNumbers);
                this.showNotification('',errorMessage,'error','Dismissible');
            } else {
             this.actionClicked = 'SaveandSubmit';
             this.saveRecord(this.record, false);
            }
           
        },(error)=>{
            this.disableSave = false;
            if(error.body != undefined && error.body.message != undefined) {
                this.showNotification('Error Fetching Data3', error.body.message, 'error', 'Dismissible');
         }else{
                this.showNotification('Error Fetching Data4', error, 'error', 'Dismissible');
         }
        });    
    }
    quickSave() {
        this.disableSave = true;
        this.isSubmit = false;
        if(this.getData(false) == false) {
            this.disableSave = false;
            return;
        }
        
        this.actionClicked = 'QuickSave';
        this.saveRecord(this.record, true);
    }
    
    
    saveAndExit() {
        this.disableSave = true;
        this.isSubmit = false;
        if(this.getData(false) == false) {
            this.disableSave = false;
            return;
        }
        this.actionClicked = 'SaveandExit';
        this.saveRecord(this.record, true);
    }

    exit() {
        if(this.recordId != undefined || this.recordId != null) {
            this.dispatchCloseEvent();
            this.navigateRecordViewPage(this.recordId);
        } else {
            this.dispatchCloseEvent();
            let state = {};
            state['HH_Application__c-filterId'] = 'All';
            this.navigateToListView('HH_Application__c',state);
        }
        
    }

    submit() {
        this.isSubmit = true;
         if(this.getData(false) == false) return;
         this.AppDocValidation();
    }

    massageContacts(contactsToMassage) {
        contactsToMassage.forEach(contact => {
            if(contact['Contact__r.FirstName'] != undefined && contact['Contact__r.LastName'] != undefined) {
                let f = contact['Contact__r.FirstName']; 
                let l = contact['Contact__r.LastName'];
                contact.Contact__r['FirstName'] =	f;
                contact.Contact__r['LastName'] =	l;
                delete contact.index;
                delete contact['Contact__r.FirstName'];
                delete contact['Contact__r.LastName']; 
            }
        });
        return contactsToMassage;
    }
    saveRecord(record, quickSaved) {
        console.log(' saveRecordsaveRecord..');
        if(this.recordId != undefined) {
           record['Id'] = this.recordId;
        }
        let recordToSend = JSON.parse(JSON.stringify(record));

        let contacts = [];
        if (recordToSend.contacts != undefined) {
            contacts = this.massageContacts(recordToSend.contacts);
        }
        if(recordToSend.deedContacts != undefined) {
            contacts = contacts.concat(this.massageContacts(recordToSend.deedContacts));
            console.log('All application contacts: ',contacts)
        }
        recordToSend['Application_Contacts__r'] = contacts;
        if(recordToSend.Application_Contacts__r && !recordToSend.Application_Contacts__r.records) {
            recordToSend.Application_Contacts__r= {
                totalSize: recordToSend.Application_Contacts__r.length,
                done: true,
                records: recordToSend.Application_Contacts__r
            };
        }
        
        recordToSend['Funded_Programs__r'] = recordToSend.fundedPrograms;
        if(recordToSend.Funded_Programs__r != undefined && !recordToSend.Funded_Programs__r.records) {
            recordToSend.Funded_Programs__r= {
                totalSize: recordToSend.Funded_Programs__r.length,
                done: true,
                records: recordToSend.Funded_Programs__r
            };
        }

        delete recordToSend.contacts;
        delete recordToSend.deedContacts;
        delete recordToSend.documents;
        delete recordToSend.fundedPrograms;
        this.executeAction(saveApplication, {'applicationDataJSON' : JSON.stringify(recordToSend),'houseHoldNumber' : this.houseHoldNumber,'isSubmit' : this.isSubmit,'currentStage':this.currentStage},
        (response) => { 
            this.disableSave = false;
            this.processSaveCallback(response); 
        },(error)=>{
            this.disableSave = false;
            if(error.body != undefined && error.body.message != undefined && error.body.message.includes('Application not editable')) {
                this.showNotificationwithMessageData('',this.label.HH_EN_Application_Already_Submitted, 'info', 'Dismissible', this.label.HH_Information_PDF, this.label.HH_EN_HERE);
            }
            else if(error.body != undefined && error.body.message != undefined) {
                if(error.body.message.includes("DUPLICATES_DETECTED")) {
                    this.showNotification('', this.label.HH_EN_Duplicate_Contact_Detected, 'error', 'dismissible');
            } else {
                    this.showNotification('Error', error.body.message, 'error', 'Dismissible');
                }
            } else {
                this.showNotification('Error', error, 'error', 'Dismissible');
            }
        });
    }
    


    getNextStage() {
        if(this.currentStage == 'ApplicantInfo') return 'EligibilityInfo';
        else if(this.currentStage == 'EligibilityInfo') return 'PropertyInfo'; 
        else if(this.currentStage == 'PropertyInfo') return 'ApplicationDocumentation'
        else if(this.currentStage == 'ApplicationDocumentation') return 'ApplicantCertification';
        else if(this.currentStage == 'ApplicantCertification') return 'Preview';
    }

    getPreviousStage() {
        if(this.currentStage == 'Preview') return 'ApplicantCertification';
        else if(this.currentStage == 'ApplicantCertification') return 'ApplicationDocumentation';
        else if(this.currentStage == 'ApplicationDocumentation')  return 'PropertyInfo';
        else if(this.currentStage == 'PropertyInfo') return 'EligibilityInfo';
        else if(this.currentStage == 'EligibilityInfo') return 'ApplicantInfo';
    }

    processSaveCallback(response) {
        this.record = response.application;
        if((this.recordId == undefined || this.recordId == null) && this.record.Id != undefined) {
            this.recordId = this.record.Id;
        }
        if(this.actionClicked == 'SaveandExit') {
            this.dispatchCloseEvent();
            this.navigateRecordViewPage(this.recordId);
        } else if (this.actionClicked == 'QuickSave') {
            this.showNotification('', this.label.HH_EN_Application_saved_successfully, 'success', 'Dismissible');
            if(this.isExternalUser) {
            this.redirectToCommunityCustomPage('hh-application', {'id' : this.recordId, 'currentStage' : this.currentStage});
            } else {
                this.dispatchCloseEvent();
                let state = {};
                state['c__id'] = this.recordId;
                state['c__currentStage'] = this.currentStage;
                this.navigateToComponent('c__HH_Application',state);
                //this.redirectToTabPage('HH_Application_Form',{'c__id' : this.recordId, 'c__currentStage' : this.currentStage});
            }
            
        } else if (this.actionClicked == 'SaveandContinue') {
            if(this.isExternalUser) {
            this.redirectToCommunityCustomPage('hh-application', {'id' : this.recordId, 'currentStage' : this.getNextStage()});
            } else {
                this.dispatchCloseEvent();
                let state = {};
                state['c__id'] = this.recordId;
                state['c__currentStage'] = this.getNextStage();
                this.navigateToComponent('c__HH_Application',state);
                //this.redirectToTabPage('HH_Application_Form',{'c__id' : this.recordId, 'c__currentStage' : this.getNextStage()})
            }
            
        } else if (this.actionClicked == 'SaveandSubmit') {
            this.showNotification(this.label.HH_EN_Thank_You, this.label.HH_EN_Application_submitted_successfully, 'success', 'Dismissible');
            this.dispatchCloseEvent();
                this.navigateRecordViewPage(this.recordId);
            if(!this.isExternalUser) {
            setTimeout(function() {
                    eval("$A.get('e.force:refreshView').fire();");
              }, 500);
       }
       } else if (this.actionClicked == 'navigationSave') {
            this.showNotification('', this.label.HH_EN_Application_saved_successfully, 'success', 'Dismissible');
            this.redirectToAppPage(this.navigationStage);
       }
    }


   
    
     handleFileUploadFinished(event){
        console.log('handleFileUploadFinished--- '+event.detail.documentRecordId+'----'+JSON.stringify(event.detail.uploadedFiles));
        let file= JSON.parse(JSON.stringify(event.detail.uploadedFiles));
        this.executeAction(saveDocument, {'documentRecordId' : event.detail.documentRecordId, 'fileName' : file[0].name},
                      (response) => {
                              this.retrieveData(this.currentStage);
                      },(error)=>{
                          if(error.body != undefined && error.body.message != undefined) {
                    this.showNotification('Error Fetching Data7', error.body.message, 'error', 'Dismissible');
                          } else {
                    this.showNotification('Error Fetching Data8', error, 'error', 'Dismissible');
                          }
                  });
     }

     handleDeleteDoument(event){
        this.executeAction(deleteDocument, {'documentId' : event.detail.documentId, 'conDocId' : event.detail.conDocId},
               (response) => {
                       this.retrieveData(this.currentStage);
               },(error)=>{
                   if(error.body != undefined && error.body.message != undefined) {
                    this.showNotification('',error.body.message,'error','Dismissible');
                   } else {
                    this.showNotification('',error,'error','Dismissible');
                   }
               });
     }

     handleCreatedDocumentRecord(event){
         console.log('handleCreatedDocumentRecord--- '+event.detail.documentType+'----'+this.recordId);
         this.executeAction(createDocument, {'documentType' : event.detail.documentType, 'ApplicationId' :this.recordId},
            (response) => {
                    this.retrieveData(this.currentStage);
            },(error)=>{
                if(error.body != undefined && error.body.message != undefined) {
                this.showNotification('Error Fetching Data9', error.body.message, 'error', 'Dismissible');
                } else {
                this.showNotification('Error Fetching Data0', error, 'error', 'Dismissible');
                }
            });
     }

     /*
    * Notifies parent component when close clicked
    */
     dispatchCloseEvent() {
        let close = true;
        const closeclickedevt = new CustomEvent('closeclicked', {
            detail: { close },
        });
         this.dispatchEvent(closeclickedevt);
    }

    

    redirectToAppPage(stageName) {
        if(this.isExternalUser) {
                this.redirectToCommunityCustomPage('hh-application', {'id' : this.recordId, 'currentStage' : stageName});
        } else {
            this.dispatchCloseEvent();
            let state = {};
            state['c__id'] = this.recordId;
            state['c__currentStage'] = stageName;
            this.navigateToComponent('c__HH_Application',state);
        }
    }
   
}