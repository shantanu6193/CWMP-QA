import { LightningElement, api, track, wire } from 'lwc';
import Utility from 'c/utility';
import getConfigInfoObjectandFieldAPIName from '@salesforce/apex/ApprovalComponentController.getConfigInfoObjectandFieldAPIName';

export default class ApprovalComponent extends Utility {
    @api showFileUpload;
    @api recordId;

    @track allUploadedFileNames = [];
    @api commentsVal;
    @api  selectedValue = '';
    @api options = [];
    @api contDocIds = [];
    @api mapData = {};
    @track objAPIVal;
    @track fieldAPIVal;
    @api isModalOpen;

    

    initData(){
        this.getConfigInfo();
    }
    
    getConfigInfo(){
        getConfigInfoObjectandFieldAPIName({})
        .then(result =>{
            if(result) {
                console.log('Display of option in salesforce==='+result[0]);
                console.log('Display of result.values in salesforce==='+result.length);
                let optionsValues = [];
                for(let i = 0; i < result.length; i++) {
                    optionsValues.push({
                        label: result[i],
                        value: result[i]
                    })
                }
                this.options = optionsValues;
                window.console.log('optionsValues ===> '+JSON.stringify(optionsValues));
            }
        })
        .catch(error =>{
            console.log('Error Val is:==>'+JSON.stringify(error)[0]);
        })
    }

    // Selection of Radio Button Value...
    handleChange(event){
        this.selectedValue = event.detail.value;
        // Creates the event with the data.
        const selectedEvent = new CustomEvent("approvalvaluechange", {
            detail: {approvalVal:this.selectedValue}
          });

          //Dispatch of Events...
          this.dispatchEvent(selectedEvent);
    }

    handleCommentChange(event){
        this.commentsVal = event.target.value;
        // Creates the event with the data.
        const commentEvent = new CustomEvent("commentvaluechange", {
            detail: {commentsVal:this.commentsVal}
          });

          //Dispatch of Events...
          this.dispatchEvent(commentEvent);
    }


    handleUploadFinished(event) {
         // Get the list of uploaded files
         const uploadedFiles = event.detail.files;
         console.log('uploadedFiles Val ===>'+uploadedFiles);
         //alert("No. of files uploaded : " + uploadedFiles.length);
         let uploadedFileNames = '';
         let contDocId = '';
         for(let i = 0; i < uploadedFiles.length; i++) {
             uploadedFileNames += uploadedFiles[i].name + '';
             contDocId = uploadedFiles[i].documentId;
             this.allUploadedFileNames.push(uploadedFileNames);
             this.contDocIds.push(contDocId);
         }
         // Creates the event for contDocId.
        const contDocIdsEvent = new CustomEvent("contdocidsvaluechange", {
            detail: [...this.contDocIds]
          });

          //Dispatch of Events...
          this.dispatchEvent(contDocIdsEvent);

        // this.allUploadedFiles.forEach(fileIterator => this.allUploadedFiles.push(fileIterator.name));
         window.console.log('allUploadedFiles Val ===> '+this.allUploadedFiles);
    }

    
    @api  handleReest() {
        this.template.querySelector('form').reset();
    }

}