import { LightningElement, track, api, wire } from 'lwc';
import Utility from 'c/utility';
import HH_EN_Homeowner_Application_Documentation_Page_Para_1_2 from '@salesforce/label/c.HH_EN_Homeowner_Application_Documentation_Page_Para_1_2';
import HH_EN_Homeowner_Application_Documentation_Page_Para_4_5 from '@salesforce/label/c.HH_EN_Homeowner_Application_Documentation_Page_Para_4_5';
import HH_EN_HOMEOWNER_APPLICATION_DOCUMENTATION from '@salesforce/label/c.HH_EN_HOMEOWNER_APPLICATION_DOCUMENTATION';
import HH_EN_Upload_Date from '@salesforce/label/c.HH_EN_Upload_Date';
import HH_EN_Document_Type from '@salesforce/label/c.HH_EN_Document_Type';
import HH_EN_File_Name from '@salesforce/label/c.HH_EN_File_Name';
import HH_EN_Action from '@salesforce/label/c.HH_EN_Action';
import HH_EN_Click_to_preview from '@salesforce/label/c.HH_EN_Click_to_preview';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import Doc_OBJECT from '@salesforce/schema/Document__c';
import Document_Type from '@salesforce/schema/Document__c.Document_Type__c';
import Document_Stage from '@salesforce/schema/Document__c.Stage__c';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import HH_EN_Property_Owner_ID from '@salesforce/label/c.HH_EN_Property_Owner_ID';
import HH_EN_Proof_of_Ownership from '@salesforce/label/c.HH_EN_Proof_of_Ownership';
import HH_EN_Proof_of_Rental from '@salesforce/label/c.HH_EN_Proof_of_Rental';
import HH_EN_Select_a_document_type_to_upload from '@salesforce/label/c.HH_EN_Select_a_document_type_to_upload';
import HH_EN_Version from '@salesforce/label/c.HH_EN_Version';
import HH_EN_Stage from '@salesforce/label/c.HH_EN_Stage';
import HH_EN_Upload_File from '@salesforce/label/c.HH_EN_Upload_File';
import HH_EN_Add_Document from '@salesforce/label/c.HH_EN_Add_Document';
import HH_EN_Please_select_Document_Type from '@salesforce/label/c.HH_EN_Please_select_Document_Type';
import HH_EN_Delete from '@salesforce/label/c.HH_EN_Delete';
import HH_EN_Cancel from '@salesforce/label/c.HH_EN_Cancel';
import HH_EN_Confirm from '@salesforce/label/c.HH_EN_Confirm';
import HH_EN_DuDocPropertyOwnerID from '@salesforce/label/c.HH_EN_DuDocPropertyOwnerID';
import HH_EN_Other from '@salesforce/label/c.HH_EN_Other';
import HH_EN_Other_Comments from '@salesforce/label/c.HH_EN_Other_Comments';
import HH_EN_DuDocProofofOwnership from '@salesforce/label/c.HH_EN_DuDocProofofOwnership';
import HH_EN_DuDocProof_of_Rental from '@salesforce/label/c.HH_EN_DuDocProof_of_Rental';

export default class HhPrHhApplicationDocumentationopertyInfo extends Utility {
	isLoading = true;
    @api record;
    @api documentType;
    @track documentTypeToCreate;
    //@wire(getObjectInfo, { objectApiName: Doc_OBJECT }) objectInfo;
    //@wire(getPicklistValues, {recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: Document_Type}) DocumentType;
    //@wire(getPicklistValues, {recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: Document_Stage}) DocumentStage;
    @track title ='';
    @track isDuplicateDoc = false;
	@track label = {
			HH_EN_HOMEOWNER_APPLICATION_DOCUMENTATION,
			HH_EN_Homeowner_Application_Documentation_Page_Para_1_2,
			HH_EN_Homeowner_Application_Documentation_Page_Para_4_5,
			HH_EN_Upload_Date,
			HH_EN_Document_Type,
			HH_EN_File_Name,
			HH_EN_Action,
			HH_EN_Click_to_preview,
			HH_EN_Proof_of_Rental,
			HH_EN_Proof_of_Ownership,
			HH_EN_Property_Owner_ID,
			HH_EN_Select_a_document_type_to_upload,
			HH_EN_Version,
			HH_EN_Stage,
			HH_EN_Upload_File,
			HH_EN_Add_Document,
			HH_EN_Please_select_Document_Type,
			HH_EN_Delete,
			HH_EN_Cancel,
			HH_EN_Confirm,
            HH_EN_Other,
            HH_EN_Other_Comments,
            HH_EN_DuDocPropertyOwnerID,
            HH_EN_DuDocProofofOwnership,
            HH_EN_DuDocProof_of_Rental
	}

        get docTypeValues() {
            return [
                {label:this.label.HH_EN_Proof_of_Rental, value:'Proof of Rental'},
                {label:this.label.HH_EN_Property_Owner_ID, value:'Property Owner ID'},
                {label:this.label.HH_EN_Proof_of_Ownership, value:'Proof of Ownership'}
            ];
        }

	documentTypeFieldChanged(event){
	    this.documentTypeToCreate = event.detail.value;
	    if(event.detail.value == 'Proof of Rental'){
	      	    this.documentType = this.label.HH_EN_Proof_of_Rental;
        }
        else if(event.detail.value == 'Property Owner ID'){
           	    this.documentType = this.label.HH_EN_Property_Owner_ID;
        }
        else if(event.detail.value == 'Proof of Ownership'){
                this.documentType = this.label.HH_EN_Proof_of_Ownership;
        }
    }

	handleUploadFinished(event) {
            let jsonObject = {uploadedFiles : event.detail.files, documentRecordId: event.target.getAttribute("data-value") };
            const fileUploadFinishedEvent = new CustomEvent('fileuploadfinished', {
                detail: jsonObject,
            });
            this.dispatchEvent(fileUploadFinishedEvent);
   }

   get isFirefox(){
       if(navigator.userAgent.indexOf("Firefox") != -1){
          return true;
       }else{
           return false;
       }
   }

    handleDelete(event){
         let jsonObject = {documentId : event.target.getAttribute("data-value"),conDocId :  event.target.getAttribute("data-documentid")};
                    const fileUploadFinishedEvent = new CustomEvent('delete', {
                        detail: jsonObject,
                    });
                    this.dispatchEvent(fileUploadFinishedEvent);
    }
	initData() {}

    handlePreviewDocument(event){
         window.open('/sfc/servlet.shepherd/document/download/'+event.target.getAttribute("data-documentid"), '_blank');
         //window.open('/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId='+event.target.getAttribute("data-versionid"), '_blank');
    }

//    getDocumentTypeTitle(event){
//        if(this.DocumentType.data.values) {
//            this.DocumentType.data.values.forEach(selectionList => {
//                if(selectionList.value == event.target.getAttribute("data-value")) {
//                    this.title = selectionList.label;
//                }else if(event.target.getAttribute("data-value") == null){
//                     this.title ='';
//                 }
//            });
//        }
//    }
        getDocumentTypePicklistTitle(event){
            if(this.DocumentType.data.values) {
                this.DocumentType.data.values.forEach(selectionList => {
                    if(selectionList.value == this.documentType) {
                        this.title = selectionList.label;
                    }else if(event.target.getAttribute("data-value") == null){
                         this.title ='';
                }
            });
        }
    }

//    getStageTitle(event){
//        if(this.DocumentStage.data.values) {
//            this.DocumentStage.data.values.forEach(selectionList => {
//                if(selectionList.value == event.target.getAttribute("data-value")) {
//                    this.title = selectionList.label;
//                }else if(event.target.getAttribute("data-value") == null){
//                    this.title ='';
//                }
//            });
//        }
//    }

   get messageToDisplay(){
       if(this.documentType == this.label.HH_EN_Property_Owner_ID){
           return this.label.HH_EN_DuDocPropertyOwnerID;
       }
      else if(this.documentType == this.label.HH_EN_Proof_of_Ownership ){
          return this.label.HH_EN_DuDocProofofOwnership;
      }
     else if(this.documentType == this.label.HH_EN_Proof_of_Rental){
        return this.label.HH_EN_DuDocProof_of_Rental;
     }
   }

   handleCreateDocumentButton() {
       if(this.documentType){
           let idDuplicate = false;
           if(this.record.documents) {
               this.record.documents.forEach(selectionList => {
                   if(selectionList.document.Document_Type__c == this.documentType) {
                       idDuplicate = true;
                   }
               });
           }
           if(idDuplicate == true){
          this.isDuplicateDoc = true;
           }else{
               this.documentCreate();
           }
       }
       else{
           this.showNotification('', this.label.HH_EN_Please_select_Document_Type, 'error', 'dismissible');
       }
   }
   handleDocCreationConfirmationClick(event) {
        let action = event.detail;
        if(action.status == 'confirm') {
            this.documentCreate();
        }
        this.isDuplicateDoc = false;
   }

   documentCreate(){
       let jsonObject = {documentType: this.documentTypeToCreate };
            const fileUploadFinishedEvent = new CustomEvent('doccreate', {
                detail: jsonObject,
            });
            this.dispatchEvent(fileUploadFinishedEvent);
   }
}