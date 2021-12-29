/**
 * Created by nehab on 30-09-2020.
 */

import {LightningElement , wire , track , api} from 'lwc';
import getDocumentsWithProgramDocuments from '@salesforce/apex/ALS_DocumentUpload_Ctrl.getDocumentsWithDocumentInfo';
import saveDetails from '@salesforce/apex/ALS_DocumentUpload_Ctrl.saveFileDetails';
import { NavigationMixin } from 'lightning/navigation';
import resourceName from '@salesforce/resourceUrl/ALS_Styles';
import { loadStyle } from 'lightning/platformResourceLoader';
import {
	ShowToastEvent
	} from 'lightning/platformShowToastEvent';

export default class AlsDocumentUpload extends NavigationMixin(LightningElement) {
     alsStyle = resourceName + '/ALS_DocUpload_Style.css';
     @api recordId;
     @track currentProjectName;
     @track DocumentsWithProgramDocument;
     @track error;
     @track showPreview = false;
     @track previewId;
     @track dataMap;
     @track fileId;
     @track sortedDirection;
     @track 
     isModalOpen=false;
     isedit = false;
     iscreate = false;
     subscription = {};
     @api channelName = '/event/Update_Document_Detail__e';
     @track selectedEvent;
     @api childRecordId;
     @track refreshTime = '';
     isAsc;
     isDsc;
     issortName = false;
     issortType =false;
     isSortStaus =false;
     issortStage = false;
     lookupField;
     displaySortArrow = false;

     connectedCallback(){
          loadStyle(this, `${this.alsStyle}`);
          console.log('record id: '+this.recordId);
     }
 
     @wire(getDocumentsWithProgramDocuments , {'masterRecordId':'$recordId' ,'refreshDate' :'$refreshTime'})
     wiredDocs({error,data}){
          console.log('Record Id ', this.recordId);
          console.log('Record  data', data);
          if(data){
               this.dataMap = data;
               this.lookupField = data.lookupFieldName;
               console.log('this.lookupField '+this.lookupField );
               console.log('AlsDocumentUpload -In side Wired Docs ', JSON.stringify(data));
               this.currentProjectName = data.ProjectName;
               this.DocumentsWithProgramDocument = data.docWrapperList;
               console.log('DocumentsWithProgramDocument',this.DocumentsWithProgramDocument);
               this.error = undefined;
          }
          else if (error) {
               this.error = error;
               this.errorToast(error);
               this.DocumentsWithProgramDocument = undefined;
               console.log('AlsDocumentUpload - There is an error here'+JSON.stringify(error));
          }
     }

     // get acceptedFormats() {
     //      return ['.pdf'];
     //  }
      
      handleUploadFinished(event) {
          const uploadedFiles = event.detail.files;
          console.log('Inside handleUploadFinished ',event.target.getAttribute("data-value"));
          this.updateDocument(event.target.getAttribute("data-value"),uploadedFiles[0].documentId);
     }


     updateDocument(documentRecordId,uploadedFileId){
          console.log('****-');
          console.log('****-',documentRecordId,'-******-',uploadedFileId)
          console.log('Inside updateDocument -- Before call');
          saveDetails({
               documentRecordId: documentRecordId,
               uploadedFileId: uploadedFileId,
               recordId: this.recordId
          })
              .then(result => {
                   this.dataMap = result;
                   console.log('updateDocument -In side Wired Docs ', JSON.stringify(result));
                   this.currentProjectName = result.ProjectName;
                   this.DocumentsWithProgramDocument = result.docWrapperList;
                   console.log('updateDocument',this.DocumentsWithProgramDocument);
                   this.error = undefined;
              })
              .catch(error => {
                  /* this.error = error;
                   this.DocumentsWithProgramDocument = undefined;*/
                   console.log('updateDocument - There is an error here'+error);
              });
     }


     navigateToFilePreview(event){
          this.previewId = event.target.getAttribute("data-value");
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


     navigateToFileDetail(event){
          console.log('navigateToFileDetail - navigateToFileDetail'+event.target.attributes);
          this.fileId = event.target.getAttribute("data-value");
          console.log('inside navigateToFileDetail -- FileId ',this.fileId);
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
     navigateToDocumentEditPage(event){
          this.isModalOpen = true;
          this.childRecordId = event.target.getAttribute("data-value");
          this.isedit = true;
          this.iscreate = false;
      }

      openModal(event) {
          this.isModalOpen = true;
      }
      closeModal(event) {
          this.isModalOpen = false;
      }

     handleDocumentEdit(event){
          console.debug('I am in handleDocumentEdit ');
     }

     hanldeProgressValueChange() {
          this.isModalOpen = false;
          this.refreshTime = Date.now();
     }

    @api onTabRefreshed(event){
          console.log('I am in onTabRefreshed ');
          this.refreshTime = Date.now();
          console.log('refreshed time', this.refreshTime);
     }

     sortName(event){
          console.log('i am in sort name');
          this.isSortStaus = false;
          this.issortName = true;
          this.issortType= false;
          this.issortStage = false;

          this.sort(event);
     }

     sortType(event){
          this.isSortStaus = false;
          this.issortType= true; 
          this.issortName = false;
          this.issortStage = false;
          this.sort(event);
     }
     sortStatus(event){
               this.isSortStaus = true;
               this.issortType= false;
               this.issortName = false;
               this.issortStage = false;
               this.sort(event);
          }

     sortStage(event){
          this.isSortStaus = false;
          this.issortType= false; 
          this.issortName = false;
          this.issortStage = true;
          this.sort(event);
     }

     sort(event){
          //console.log('I am in sort function');
          //console.log('e.currentTarget.dataset.id)'+event.currentTarget.dataset.id);
               this.sortedDirection = this.sortedDirection === 'asc' ? 'desc' : 'asc';
           //console.log('sorted direction: '+this.sortedDirection)
           if(this.sortedDirection =='asc'){
                this.isAsc = true;
                this.isDsc = false;
           }
           else{
                this.isDsc=true
                this.isAsc = false;
           }
           var reverse = this.sortedDirection === 'asc' ? 1 : -1;
        let table = JSON.parse(JSON.stringify(this.DocumentsWithProgramDocument));
          table.sort((a,b) => {return a.documentRecord[event.currentTarget.dataset.id] > b.documentRecord[event.currentTarget.dataset.id] ? 1 * reverse : -1 * reverse});     
        this.DocumentsWithProgramDocument = table;    
     }

     showSortArrow() {
          this.displaySortArrow = true;
     }

     hideSortArrow() {
          this.displaySortArrow = false;
     }

     createNewDoc(){
          this.isModalOpen = true;
          this.iscreate =true;
          this.isedit=false;
     }
     errorToast(msg) {
     	const event = new ShowToastEvent({
     		title: 'Error',
     		message: 'We do not support document creation on this record.',
     		variant: 'Error',
     		mode: 'sticky'
     	});
     	this.dispatchEvent(event);
     	}

}