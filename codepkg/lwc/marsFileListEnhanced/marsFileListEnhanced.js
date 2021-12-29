import { LightningElement, api, track } from 'lwc';
 import Utility from 'c/utility';
 import getFileContents from '@salesforce/apex/MARS_FileListCtrl.getContents';
 import deleteFile from '@salesforce/apex/MARS_FileListCtrl.deleteFile';
 
 export default class MarsFileListEnhanced extends Utility {
 
         @api recordId;
         @api renderDelete = false;
         @track fileList = [];
         @track isLoaded = false;
         @api renderDeleteAction = false;
         @api renderDownloadAction = false;
         @api header;
 
         initData(){
             console.log('renderFilesAction= '+this.renderFilesAction);
             this.retrieveFiles();
         }
 
         @api
         refreshFileList() {
             this.retrieveFiles();
         }
 
         retrieveFiles(){
             console.log("recordId= "+this.recordId);
             this.executeAction(getFileContents, {'recordId' : this.recordId,'otherRecordIds':JSON.stringify([]),'dateFieldAPIName': '','fileTypesToHide':JSON.stringify([])}, (response) => {
                 console.log('files=',response);
                 debugger;
                 //this.fileList = response['contentVersions'];
                 this.processFileList(response['contentVersions']);
                 this.isLoaded = true;
             });
         }
 
         deleteFile(event){
             let index = event.currentTarget.dataset.index;
             let fileId = this.fileList[index].ContentDocumentId;
             console.log('index='+index);
             console.log('fileId='+fileId);
             this.executeAction(deleteFile, {'fileId':fileId, 'recordId' : this.recordId,'otherRecordIds':JSON.stringify([]),'dateFieldAPIName': '','fileTypesToHide':JSON.stringify([])}, (response) => {
                 console.log('files=',response);
                 debugger;
                 //this.fileList = response['contentVersions'];
                 this.processFileList(response['contentVersions']);
             });
         }
 
         processFileList(response){
             let tempArray = [];
             for(let key in response){
                 let file = response[key];
                 let downloadUrl = '/sfc/servlet.shepherd/version/download/'+file.Id;
                 tempArray.push({'Type__c': file.Type__c,
                                 'Title':file.Title,
                                 'ContentModifiedDate':file.ContentModifiedDate,
                                 'Id':file.Id,
                                 'downloadUrl':downloadUrl,
                                 'ContentDocumentId':file.ContentDocumentId});
             }
             console.log('tempArray =', tempArray);
             this.fileList = tempArray;
         }
 
         get hasFiles(){
             return this.fileList.length > 0;
         }
 
         renderedCallback() {
             let parentNameElements = this.template.querySelectorAll('.parent-element-hover');
             if(parentNameElements) {
                 for(let index = 0; index < parentNameElements.length; index++) {
                     let parentNameElem = parentNameElements[index];
                     if(parentNameElem != null && (parentNameElem.offsetWidth < parentNameElem.scrollWidth)) {
                         let siblingElem = parentNameElem.nextSibling;
                         if(siblingElem != null && siblingElem.classList) {
                             siblingElem.classList.add('grtx-tooltip-hover');
                         }
                     }
                 }
             }
         }
 }