/**
 * Created by harsh on 23-03-2021.
 */

import { LightningElement, wire, track, api} from 'lwc';
import getDocumentsWithProgramDocuments from '@salesforce/apex/DocumentUploadCtrl.getDocumentsWithDocumentInfo';
import getDocumentInfo from '@salesforce/apex/DocumentUploadCtrl.getDocumentInfo';
import validateAndRetrieveDocumentMetaConfiguration from '@salesforce/apex/DocumentUploadCtrl.validateAndRetrieveDocumentMetaConfiguration';
import validateAndRetrieveCloneDocumentMetaConfiguration from '@salesforce/apex/DocumentUploadCtrl.validateAndRetrieveCloneDocumentMetaConfiguration';
import deleteContentDocument from '@salesforce/apex/DocumentUploadCtrl.deleteContentDocument';
import saveDetails from '@salesforce/apex/DocumentUploadCtrl.saveFileDetails';
import cloneGlobalDocument from '@salesforce/apex/DocumentUploadCtrl.cloneGlobalDocument';
import getSourceGlobalDocumentListToDisplay from '@salesforce/apex/DocumentUploadCtrl.getSourceGlobalDocumentListInfo';
import { NavigationMixin } from 'lightning/navigation';
import resourceName from '@salesforce/resourceUrl/DocumentUpload';
import HH_EN_New from '@salesforce/label/c.HH_EN_New';
import { loadStyle } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference } from 'lightning/navigation';
import { subscribe, unsubscribe, APPLICATION_SCOPE, MessageContext} from 'lightning/messageService';
import documentUploadMessageChannel from '@salesforce/messageChannel/HMGPDocumentUploadMessageChannel__c';
import getEditDocDetails from '@salesforce/apex/CustomDocumentCreateEdit.getDocumentInfo';
import HH_EN_Application_Already_Submitted from '@salesforce/label/c.HH_EN_Application_Already_Submitted';
import HH_Information_PDF from '@salesforce/label/c.HH_Information_PDF';
import HH_EN_HERE from '@salesforce/label/c.HH_EN_HERE';

export default class DocumentUpload extends NavigationMixin(LightningElement) {
     docStyle = resourceName + '/DocUpload_Style.css';
     @api recordId;
     @api columnList = [];
     @api documentNamesToRender;/*Used in Dynamic Page Layout Framework passing from PageField LWC component*/
     @api childRecordId;
     @api excludeDocumentTypes = [];
     @api record;
     @track documentDetail ={};
     @track recordLocal = {};
     @api isAllFieldsReadOnly;
     @track recordIdLocal;
     @track currentProjectName;
     @track DocumentsWithProgramDocument;
     @track error;
     @track showPreview = false;
     @track previewId;
     @track dataMap;
     @track fileId;
     @track sortedDirection;
     @track isModalOpen=false;
     isedit = false;
     iscreate = false;
     iscopyglobaldocument = false;
     @track selectedEvent;
     @track refreshTime = '';
     isAsc;
     isDsc;
     key = 0;
     issortName = false;
     issortType =false;
     issortStage = false;
     displaySortArrow = false;

     @track tableColumns = [];
     @track cloneDocumentTableColumns =[];
     @track lookupFieldAPIName = '';
     @track allDocumentTypes = [];
     @track documentInfo = [];
     @track allDocumentInfo = [];
     @track columnFieldAPINames = [];
     subscription = null;
     @track excludeDocumentTypesLocal = [];
     @track sourceDocumentList;
     @track selectedSourceDocumentValue;
     @track documentName;
     //@track messageToDisplay;
     isDocumentFound =false;
     @track destinationDocumentId;
     @track label ={
                    HH_EN_New,
                    HH_EN_Application_Already_Submitted,
                    HH_Information_PDF,
                    HH_EN_HERE
                 }

     @wire(MessageContext)
     messageContext;

     @wire(CurrentPageReference)
     setCurrentPageRef(currentPageReference) {
         this.urlStateParameters = currentPageReference.state;
         if(currentPageReference && currentPageReference.state) {
           if(currentPageReference.state.id) {
                 this.recordIdLocal = currentPageReference.state.id;
           }
           if(currentPageReference.state.parentId) {
               this.recordIdLocal = currentPageReference.state.parentId;
          }
         }
     }

     /*Subscript HMGPDocumentUploadMessageChannel__c*/
     subscribeToMessageChannel() {
         if (!this.subscription) {
             this.subscription = subscribe(
                 this.messageContext,
                 documentUploadMessageChannel,
                 (message) => this.handleMessage(message),
                 { scope: APPLICATION_SCOPE }
             );
         }
     }

     // Handler for message received by component
     handleMessage(message) {
         let docTypeArray = message.DocumentTypes.split(",");
         let exitingDocType = this.allDocumentTypes;
         let exitingDocTypeLocal = this.excludeDocumentTypesLocal;
         for(let d=0; d< docTypeArray.length; d++){
             if(message.action =='add'){
                if(!this.allDocumentTypes.includes(docTypeArray[d])){
                   exitingDocType.push(docTypeArray[d]);
                }
                const index = exitingDocTypeLocal.indexOf(docTypeArray[d]);
                if (index > -1) {
                   exitingDocTypeLocal.splice(index, 1);
                }
             }else if(message.action =='remove'){
                if(this.allDocumentTypes.includes(docTypeArray[d])){
                    const index = this.allDocumentTypes.indexOf(docTypeArray[d]);
            if (index > -1) {
                        exitingDocType.splice(index, 1);
            }
        }
                if(!exitingDocTypeLocal.includes(docTypeArray[d])){exitingDocTypeLocal.push(docTypeArray[d]);}
             }
         }
         this.allDocumentTypes = exitingDocType;//TODO: If not in use then remove
         this.excludeDocumentTypesLocal = exitingDocTypeLocal;
        this.reloadDocumentUploadTable();
     }

     /*After handleMessage*/
     reloadDocumentUploadTable(){
         let docArrayLocal = [];
         for(let i=0; i < this.allDocumentInfo.length; i++){
             let recordDoc = this.allDocumentInfo[i];
             if(recordDoc && this.excludeDocumentTypesLocal && !this.excludeDocumentTypesLocal.includes(recordDoc['documentRecord'].Document_Name__c)){
                 docArrayLocal.push(recordDoc);
             }
         }
         if(docArrayLocal.length > 0){
             this.documentInfo = docArrayLocal;
         }
     }

     connectedCallback(){
          loadStyle(this, `${this.docStyle}`);
          if(this.record) {
               this.recordIdLocal = this.record.Id;
          }else if(this.recordId) {
               this.recordIdLocal = this.recordId;
          }
       /*Used in Dynamic Page Layout Framework passing from PageField LWC component
       which contains Document Name exp:DocName1,DocName2*/
       if(this.documentNamesToRender) {
            this.allDocumentTypes = this.documentNamesToRender.split(",");
          }

               if(this.recordIdLocal) {
                    this.getDocumentMetaConfiguration();
               }

          this.subscribeToMessageChannel();
       if(this.excludeDocumentTypes && this.excludeDocumentTypes.length > 0){
         this.excludeDocumentTypesLocal = JSON.parse(JSON.stringify(this.excludeDocumentTypes));
       }
     }
     getDocumentMetaConfiguration() {
          validateAndRetrieveDocumentMetaConfiguration({'recordId' : this.recordIdLocal})
          .then(result => {
               if(result.isValid) {
                   this.lookupFieldAPIName = result.lookupFieldName;
                    if(this.columnList.length > 0) {
                         this.tableColumns = JSON.parse(JSON.stringify(this.columnList));
                    } else {
                         this.tableColumns = JSON.parse(result.tableColumns);
                         this.getDocumentRecordInfo();
                    }
                    if(this.tableColumns.length > 0) {
                         this.getFieldAPINames();
                         /**Hide table Action column for Viewer user */
                         if(this.isAllFieldsReadOnly) {
                              this.hideActionColumnFromDocumentTable();
                         }                         
                    }
               } else {
                    this.showErrorNotification('Validation Error', 'We do not support document creation on this record');  //Show error toast
               }
          })
          .catch(error => {
               console.log('validateRecordId-error-', error);
          });
     }
     hideActionColumnFromDocumentTable() {
          if(this.tableColumns.length > 0) {
               for(let i=0; i< this.tableColumns.length; i++) {
                    if(this.tableColumns[i] && this.tableColumns[i].label && this.tableColumns[i].label == 'Action') {
                         this.tableColumns.splice(i, 1);
                    }
               }
          }
     }
     getCloneDocumentTableMetaConfiguration() {
               validateAndRetrieveCloneDocumentMetaConfiguration({'destinationRecordId' : this.recordIdLocal})
               .then(result => {
                    this.cloneDocumentTableColumns = JSON.parse(result.cloneGlobalDocumentTableColumns);
               })
               .catch(error => {
                    console.log(' Error-', error);
               });
          }

     getFieldAPINames() {
          if(this.tableColumns.length > 0) {
               for(let i=0; i< this.tableColumns.length; i++) {
                    if(this.tableColumns[i] && this.tableColumns[i].fieldName) {
                         this.columnFieldAPINames.push(this.tableColumns[i].fieldName);
                    }
               }
          }
          if(this.columnFieldAPINames.length > 0 && this.allDocumentTypes.length > 0){

            this.getDocumentRecordInfo();
          }
     }

     getDocumentRecordInfo(){
          getDocumentInfo({'masterRecordId' : this.recordIdLocal,
                             'documentTypes' : JSON.parse(JSON.stringify(this.allDocumentTypes)),
                              'columnList' :  JSON.parse(JSON.stringify(this.columnFieldAPINames)),
                              'lookupFieldAPIName' : this.lookupFieldAPIName})
            .then(result => {
               if(this.excludeDocumentTypesLocal && this.excludeDocumentTypesLocal.length == 0){
                   this.documentInfo = result.docWrapperList;
               }
               this.allDocumentInfo = result.docWrapperList;
               this.prepareDocumentRecordsOnInit();
            })
            .catch(error => {
               console.log('doc-error------', error);
            });
     }

     prepareDocumentRecordsOnInit(){
          let docArrayLocal = [];
          for(let i=0; i <= this.allDocumentInfo.length; i++){
              let recordDoc = this.allDocumentInfo[i];
              /*ignore excluded document type */
              if(recordDoc && this.excludeDocumentTypesLocal && !this.excludeDocumentTypesLocal.includes(recordDoc['documentRecord'].Document_Name__c)){
                  docArrayLocal.push(recordDoc);
              }
          }
          if(docArrayLocal.length > 0){
              this.documentInfo = docArrayLocal;
          }
     }

     deleteContentDocument(event) {
          deleteContentDocument({'contentDocId' : event.detail.contentDocumentId,
                                 'recordId': this.recordIdLocal,
                                 'documentId':event.detail.documentRecordId
                                })
               .then(result => {
                    this.getDocumentRecordInfo();
               }).catch(error => {
                    this.errorToast('Error', error.body.message, 'error');
               });
     }

       navigateToFilePreview(event){
              // this.previewId = event.target.getAttribute("data-value");
              this.previewId = event.detail;
               this[NavigationMixin.Navigate]({
                    type: 'standard__namedPage',
                    attributes: {
                         pageName: 'filePreview'
                    },
                    state : {
                         selectedRecordId: this.previewId
                    }
               })
          }
     get IsPortalEnabledForNewButton() {
          if(this.documentInfo.length > 0 && this.documentInfo[0]['currentUser'].IsPortalEnabled && (this.documentInfo[0].hideEdit == undefined || this.documentInfo[0].hideEdit == true)) {
               return true;
          }
          return false;
     }

      get IsPortalEnabledForDownload() {
          if(this.documentInfo.length > 0 && this.documentInfo[0]['currentUser'].IsPortalEnabled){
               return true;
          }
          return false;
     }

     get getTableColumnKey() {
          return ++ this.key;
     }
     @wire(getDocumentsWithProgramDocuments , {'masterRecordId':'$recordIdLocal' ,'refreshDate' :'$refreshTime'})
     wiredDocs({error,data}){
          if(data){
               this.currentProjectName = data.ProjectName;
               this.DocumentsWithProgramDocument = data.docWrapperList;
               this.error = undefined;
          }
          else if (error) {
               this.error = error;
               this.errorToast('Error', error.body.message, 'error');
               this.DocumentsWithProgramDocument = undefined;
          }
     }

     handleFileUploadFinished(event) {
         let file= JSON.parse(JSON.stringify(event.detail.uploadedFiles));
          this.updateDocument(event.detail.documentRecordId, file[0].name);
     }
     navigateToCloneUniversalDocument(event){
         this.destinationDocumentId = event.detail.documentRecordId;
         this.getSourceDocumentList(event.detail.documentRecordName,event.detail.documentRecordId);
     }

     onSelectSourceDocument(event){
          this.closeModal();
          this.cloneGlobalDoc(this.destinationDocumentId,event.detail.selectedSourceDocumentValue);
     }

     updateDocument(documentRecordId,uploadedFileName){
          saveDetails({
               documentRecordId: documentRecordId,
               uploadedFileName: uploadedFileName,
               recordId: this.recordIdLocal
          })
              .then(result => {
                   this.dataMap = result;
                   this.currentProjectName = result.ProjectName;
                   this.DocumentsWithProgramDocument = result.docWrapperList;
                   this.error = undefined;
                   this.refreshTime = Date.now();
                   this.getDocumentRecordInfo();
              })
              .catch(error => {
                   this.refreshTime = Date.now();
                   console.log('updateDocument - There is an error here'+JSON.stringify(error));
              });
     }

    cloneGlobalDoc(destinationDocumentId, sourceDocumentId){
          cloneGlobalDocument({
               sourceDocumentId: sourceDocumentId,
               destinationDocumentId: destinationDocumentId,
               destinationRecordId: this.recordIdLocal
          })
              .then(result => {
                   this.dataMap = result;
                   this.currentProjectName = result.ProjectName;
                   this.DocumentsWithProgramDocument = result.docWrapperList;
                   this.error = undefined;
                   this.refreshTime = Date.now();
                   this.getDocumentRecordInfo();
                   this.errorToast('Success','Document Uploaded Successfully...','success');

              })
              .catch(error => {
                 this.error = undefined;
                 this.refreshTime = Date.now();
                 this.getDocumentRecordInfo();
                 this.errorToast('Error',error.body.message,'error');
              });
     }

    getSourceDocumentList(documentRecordName,documentRecordId){
           getSourceGlobalDocumentListToDisplay({
                documentRecordName: documentRecordName,
                destinationRecordId: this.recordIdLocal,
                documentRecordId:documentRecordId
           })
               .then(result => {
                    this.sourceDocumentList =  result.sourceDocumentList;
                    this.isDocumentFound = true;
                    this.openModal();
                    this.iscopyglobaldocument = true;
                    this.isedit = false;
                    this.iscreate = false;
                    this.getCloneDocumentTableMetaConfiguration();
               })
               .catch(error => {
                  this.iscopyglobaldocument =false;
                  this.closeModal();
                  this.isDocumentFound =false;
                  //this.messageToDisplay =error.body.message;
                  this.errorToast('Error',error.body.message,'error');//error.body.message
               });
     }

     navigateToFileDetail(event){
          this.fileId = event.target.getAttribute("data-value");
          this[NavigationMixin.Navigate]({
               type: 'standard__recordPage',
               attributes: {
                    recordId: this.fileId,
                    objectApiName: 'ContentDocument',
                    actionName: 'view'
               }
          })
     }

     /*Navigate to Edit Page*/
     handleDocumentEdit(event) {
          this.childRecordId = event.detail.documentRecordId;
          this.documentName = event.detail.documentRecordName;
          this.iscopyglobaldocument =false;
          this.iscreate = false;

          getEditDocDetails({'documentId':event.detail.documentRecordId,'masterRecordId':this.recordIdLocal})
                .then(result => {
                      this.recordLocal = result.documentRecord;
          this.isModalOpen = true;
          this.isedit = true;
                })
                .catch(error => {
               if(error.body != undefined && error.body.message != undefined && error.body.message.includes('Application not editable')) {
                    console.log(' error.body.message vv- '+ error.body.message);
                    this.showNotificationwithMessageData('',this.label.HH_EN_Application_Already_Submitted, 'info', 'Dismissible', this.label.HH_Information_PDF, this.label.HH_EN_HERE);
                }else{
                    this.errorToast('Error', error.body.message, 'error');
                }

                  });
     }

     /*Navigate to New Page*/
     createNewDoc(){
          this.isModalOpen = true;
          this.iscreate =true;
          this.isedit=false;
          this.iscopyglobaldocument =false;
     }

     openModal() {
          this.isModalOpen = true;
     }
     closeModal() {
          this.isModalOpen = false;
     }
     hanldeProgressValueChange() {
          this.isModalOpen = false;
          this.getDocumentRecordInfo();
     }
     sortingMethod(event){
          if(event.currentTarget.dataset.id =='Name'){
              this.sortName(event);
          }else if(event.currentTarget.dataset.id =='Category'){
              this.sortCategory(event);
          }else if(event.currentTarget.dataset.id =='Stage'){
              this.sortStage(event);
          }
     }
    get isNameCell() {
        return this.tableColumns.label =='Name' ? true : false;
    }
    get isCategoryCell() {
        return this.tableColumns.label == 'Category' ? true : false;
    }
    get isStageCell() {
        return this.tableColumns.label == 'Stage' ? true : false;
    }
    get isOtherCell() {
         return (this.columns.label != 'Name' && this.columns.label != 'Category' && this.columns.label != 'Stage') ? true : false;
    }
     sortName(event){
          this.issortName = true;
          this.issortType= false;
          this.issortStage = false;
          this.sort(event);
     }

     sortCategory(event){
          this.issortType= true;
          this.issortName = false;
          this.issortStage = false;
          this.sort(event);
     }

     sortStage(event){
          this.issortType= false;
          this.issortName = false;
          this.issortStage = true;
          this.sort(event);
     }

     sort(event){
               this.sortedDirection = this.sortedDirection === 'asc' ? 'desc' : 'asc';
           if(this.sortedDirection =='asc'){
                this.isAsc = true;
                this.isDsc = false;
           }
           else{
                this.isDsc=true
                this.isAsc = false;
           }
           var reverse = this.sortedDirection === 'asc' ? 1 : -1;
        let table = JSON.parse(JSON.stringify(this.documentInfo));
          table.sort((a,b) => {return a.documentRecord[event.currentTarget.dataset.id] > b.documentRecord[event.currentTarget.dataset.id] ? 1 * reverse : -1 * reverse});
        this.documentInfo = table;
     }

     showSortArrow() {
          this.displaySortArrow = true;
     }

     hideSortArrow() {
          this.displaySortArrow = false;
     }

    errorToast(title1,message1,variant1) {
                const evt = new ShowToastEvent({
                    title: title1,
                    message: message1,
                    variant: variant1,
                    mode:'Dismissible'
                });
                this.dispatchEvent(evt);
        }
    get currentLanguage() {
             return (this.urlStateParameters.language == 'es') ? true : false;
    }

    showNotificationwithMessageData = (_title, _message, _variant, _mode, _url, _label) => {
     const event = new ShowToastEvent({
         title: _title,
         message: _message,
         variant: _variant,
         mode: _mode,
         messageData: [
             '',
             {
                 url: _url,
                 label: _label,
             },
         ],
     });
     this.dispatchEvent(event);
};

}