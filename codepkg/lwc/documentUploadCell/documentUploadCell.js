import { LightningElement, api, wire, track } from 'lwc';
import Utility from 'c/utility';
import HH_EN_Edit from '@salesforce/label/c.HH_EN_Edit';
import HH_EN_Delete from '@salesforce/label/c.HH_EN_Delete';
import HH_EN_Click_to_preview from '@salesforce/label/c.HH_EN_Click_to_preview';

export default class DocumentUploadCell extends Utility {
    @api columns;
    @api recordValues;
    @api isPortalEnabled;
    @track isOpenDeleteConfirmationModal = false;
    @track label ={
                HH_EN_Edit,
                HH_EN_Delete,
                HH_EN_Click_to_preview
             }
    initData() {
        /*console.log('********************', this.columns.label, '********************');
        console.log('cell-column', this.columns);
        console.log('cell-recordValues', JSON.parse(JSON.stringify(this.recordValues)));*/
    }
    get fieldValue() {
        console.log('value--', this.recordValues.documentRecord[this.columns.fieldName]);
        if(this.recordValues && this.columns) {
            return this.recordValues.documentRecord[this.columns.fieldName];
        }
        return '';
    }
    get isNotActionORVersionORNameORGlobalCell() {
        return (this.columns.label != 'Upload Date' && this.columns.label != 'File Name' && this.columns.label != 'Versions' && this.columns.label != 'Action' && this.columns.label != 'Name' && this.columns.label != 'Global') ? true : false;
    }
    get isVersionCell() {
        return this.columns.label == 'Versions' ? true : false;
    }
     get isFileNameCell() {
            return this.columns.label == 'File Name' ? true : false;
        }

    get isNameCell() {
            return this.columns.label == 'Name' ? true : false;
    }
    get isUploadDateCell() {
            return this.columns.label == 'Upload Date' ? true : false;
    }
    get isFirefox(){
        if(navigator.userAgent.indexOf("Firefox") != -1){
           return true;
        }else{
            return false;
        }
    }
    get isGlobalCell() {
            return this.columns.label == 'Global' ? true : false;
    }
    get isActionCell() {
        return this.columns.label == 'Action' ? true : false;
    }
    get isEditIcon() {

        if(this.recordValues && this.recordValues.hideEdit == true) {//Check for Document Edit Access for HH Community user if yes return false
            return false;
        }else if(this.recordValues && this.recordValues.hideEdit == undefined && this.recordValues.currentUser['IsPortalEnabled']){//Check for comunnity user if yes return false
             return false;
        }
        return true;
   }
   get isCopyIcon() {
       if(this.columns && this.recordValues) {
            return this.columns.actionList.includes('clone');
       }
       return false;
   }
   get isDeleteIcon() {
       //&& this.recordValues.documentRecord.Is_Required__c!='Required'
       if(this.columns && this.recordValues && this.recordValues.hideDelete == false ) {//Check for Document delete Access for HH Community user if no return true
                return true;
       }else if(this.columns && this.recordValues && this.recordValues.hideDelete == undefined) {
             return this.columns.actionList.includes('delete') && this.recordValues.ContentVersionRecord && this.recordValues.ContentVersionRecord.ContentDocumentId != null ;
        }
        return false;
   }
   get isDownloadIcon() {
       //Check for comunnity user if yes return true
       if(this.recordValues && this.recordValues.currentUser['IsPortalEnabled'] && this.recordValues.contentDocumentLink && this.recordValues.contentDocumentLink.ContentDocumentId) return true;
       return false;
   }
  //Check for Document upload Access for HH Community user if yes return true
  get isUploadActionAccess() {
     if(this.recordValues.hideUpload == true) {
          return true;
     }
     return false;
  }

   handleUploadFinished(event) {
        let jsonObject = {documentRecordId : this.recordValues.documentRecord['Id'], uploadedFiles : event.detail.files };
        const fileUploadFinishedEvent = new CustomEvent('fileuploadfinished', {
            detail: jsonObject,
        });
        this.dispatchEvent(fileUploadFinishedEvent);
   }
   /*handleGlobalBoxChange(event){
           this.checkbox = event.target.checked;
           console.log('+++++++++'+this.checkbox);
           console.log('++++event+++++'+event.target.getAttribute('data-id'));
           console.log('+++++++++'+event.target.getAttribute('data-name'));
           let jsonObject = {documentRecordId : event.target.getAttribute('data-id'), checkboxValue : event.target.checked ,documentRecordName : event.target.getAttribute('data-name') };
           const checkboxCheckedEvent = new CustomEvent('checkboxchecked', {
               detail: jsonObject,
           });
           this.dispatchEvent(checkboxCheckedEvent);
   }*/
   viewFileVersion(event) {
        if(JSON.parse(JSON.stringify(this.recordValues)).contentDocumentLink.ContentDocumentId && !this.recordValues.currentUser['IsPortalEnabled']) {
            let fileId = JSON.parse(JSON.stringify(this.recordValues)).contentDocumentLink.ContentDocumentId;
            this.navigateRecordViewPage(fileId);
        }else{
            let fileId = JSON.parse(JSON.stringify(this.recordValues)).contentDocumentLink.ContentDocumentId;
            window.open('/sfc/servlet.shepherd/document/download/'+fileId, '_blank');
        }
   }
   handleDeleteContentDocument(event) {
       this.isOpenDeleteConfirmationModal = true;
   }
   handleDeleteConfirmationClick(event) {
        let action = event.detail;
        if(action.status == 'confirm') {
            this.deleteContentDocument();
        }
        this.isOpenDeleteConfirmationModal = false;
   }
   deleteContentDocument() {
            let conDoc = null;
            if(this.recordValues.contentDocumentLink != undefined && this.recordValues.contentDocumentLink['ContentDocumentId'] != undefined){
                conDoc = this.recordValues.contentDocumentLink['ContentDocumentId'];
            }
            let jsonObject = {contentDocumentId : conDoc,
                              documentRecordId : this.recordValues.documentRecord['Id']}
            const deleteContentDocumentEvent = new CustomEvent('deletecontentdocument', {
                detail: jsonObject,
            });
            this.dispatchEvent(deleteContentDocumentEvent);
        }
   navigateToDocumentEditPage(event) {
        let jsonObject = {documentRecordId : this.recordValues.documentRecord['Id'],
                         documentType : this.recordValues.documentRecord['Document_Type__c'] };
        const DocumentEditEvent = new CustomEvent('documentedit', {
                detail : jsonObject,
        });
        this.dispatchEvent(DocumentEditEvent);
   }
   navigateToUniversalDocumentClonePage(event) {
           console.log('Document-Id-: ', event.target.getAttribute("data-value"));
           console.log('documentRecordName-: ', event.target.getAttribute("data-name"));
           let jsonObject = {documentRecordId : event.target.getAttribute("data-value"),
                            documentRecordName : event.target.getAttribute('data-name') };
           const DocumentCopyEvent = new CustomEvent('universaldocumentclone', {
                   detail : jsonObject,
           });
           this.dispatchEvent(DocumentCopyEvent);
   }

   handleFilePreview(event) {
	   if(this.isPortalEnabled){
		   //console.log('Document-Id-:isPortalEnabled ', event.target.getAttribute("data-value") +'------'+ this.isPortalEnabled);
		   window.open('/sfc/servlet.shepherd/document/download/'+event.target.getAttribute("data-value"), '_blank');
	   }else{
	   console.log('Document-Id-: ', event.target.getAttribute("data-value"));
	   const FilePreviewEvent = new CustomEvent('navigatetofile', {
			   detail : event.target.getAttribute("data-value")
	   });
	   this.dispatchEvent(FilePreviewEvent);
   }
   }

    handleDownloadDocument(event) {
        console.log('dataValue_Download_icon : ', event.target.getAttribute("data-value"));
        let contentDocumentId = event.target.getAttribute("data-value");
        if(contentDocumentId) {
            this.downloadUrl = '/sfc/servlet.shepherd/document/download/' + contentDocumentId;
            window.open(this.downloadUrl);
        }
    }
}