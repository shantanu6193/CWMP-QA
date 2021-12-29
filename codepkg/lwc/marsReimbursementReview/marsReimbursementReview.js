import { LightningElement,api,track } from 'lwc';
import Utility from 'c/utility';
//import getReimbursementReviewList from "@salesforce/apex/Mars_ReimbursementReviewCtrl.getReimbursementReviewList";
import getData from "@salesforce/apex/Mars_ReimbursementReviewCtrl.getData";
import saveComments from "@salesforce/apex/Mars_ReimbursementReviewCtrl.saveComments";
import deleteFile from "@salesforce/apex/Mars_ReimbursementReviewCtrl.deleteFile";
export default class MarsReimbursementReview extends Utility {
    isViewModalOpen = false;
    reimbursementLineRecords=[];  
    reimbursRecord=[];
    reimbursemenId;
    contentVersions=[]; 
    showFilesTable = false;
    @track uploadedFiles = [];
    localAgencyComments;
    AttachmentType;
    imageUrl;
    getData() {
        this.executeAction(getData, {
            reimbursemenId: this.reimbursemenId
            }, (result) => {
                console.log('ReimbursementLineItems===>',JSON.stringify(result));
                this.reimbursementLineRecords = result.ReimbursementLineItems;
                this.reimbursRecord = result.Reimbursement;
                this.contentVersions = result.contentVersions;
                this.imageUrl = result.signature;
                console.log('this.contentVersions==',JSON.stringify(this.contentVersions));
        });
    }
    handleCommentsChange(event) {
        this.localAgencyComments = event.target.value;
    }
   
    get showRejectReason(){
        if(this.reimbursRecord.Approver_Comments__c != undefined || this.reimbursRecord.Approver_Comments__c != null) return true;
        else return false;
    }
    get hasFiles(){
        return this.contentVersions.length > 0;
    }
    saveRecord() {
        let fileRecordsToSave = this.validateFileType();
        if(fileRecordsToSave) {
            this.showErrorNotification('Error', 'Please select Attachment Type');
            return;
        }
        if(this.localAgencyComments == undefined) {
            this.showErrorNotification('Error', 'Please Enter Mutual Aid Staff Comments');
            return;
        }
        this.AttachmentType = this.getAttachmentType();
        this.executeAction(saveComments, {
            reimbursemenId: this.reimbursemenId,
            attachmentType:this.AttachmentType,
            fileUpdateWrapper: JSON.stringify(this.uploadedFiles),
            comments:this.localAgencyComments,
            accountId:this.accountId
            }, (result) => {
                    this.reimbursemenId = undefined;
                    this.AttachmentType = undefined;
                    this.uploadedFiles = undefined;
                    this.localAgencyComments = undefined;
                    this.showFilesTable = false;
                    this.reimbursementLineRecords = undefined;
                    this.reimbursRecord = undefined;
                    this.contentVersions = undefined;
                    this.imageUrl = undefined;
                    this.isViewModalOpen = false;
                    this.showLoader = false;
                    this.showSuccessNotification('Records Submitted Successfully.');
                    this.dispatchEvent(new CustomEvent('showrecord'));
                    
            });
            //this.showErrorNotification('Error', 'Update functionality is pending');
    }
    deleteAttachedFile(event) {
        event.preventDefault();
        const itemIndex = event.currentTarget.dataset.index;
        console.log('Delete row===>', itemIndex);
        this.executeAction(deleteFile, {
            contentVersionId: itemIndex
        }, (result) => {
            var index = this.uploadedFiles.findIndex(function(fileIndex) {
                return fileIndex.contentVersionId === itemIndex;
            });
            this.uploadedFiles.splice(index, 1)
            this.showSuccessNotification('File is deleted successfully')
            if (this.uploadedFiles.length == 0)
                this.showFilesTable = false;
        });
    }
    handleUploadFinished(event) {
        try {
            this.showFilesTable = true;
            let uploadedFile = event.detail.files;
            uploadedFile.forEach((element) => {
                element.Type = undefined;
                this.uploadedFiles.push(element)
            });
        } catch (e) {
            console.log('Error Uplaod file===>', e);
        }
    }
    validateFileType() {
        try{
            if(this.uploadedFiles.length > 0) {
                for (let i = 0; i < this.uploadedFiles.length; i++) {
                    if (this.uploadedFiles[i].Type == undefined) {
                        return true;
                    }
                }
            }
        } catch(e) {
            console.log('error==',e);
        }
       
        return false;
    }
    handleAttachmentChange(event) {
        const itemIndex = event.currentTarget.dataset.index;
        for(let i=0;i<this.uploadedFiles.length;i++) { 
            if(this.uploadedFiles[i].contentVersionId == itemIndex) {
                this.uploadedFiles[i].Type = event.target.value;
            }
        }
    }
    getAttachmentType(){
        let attachmentType = this.reimbursRecord.Attachment_Type__c;
        for(let i=0;i<this.uploadedFiles.length;i++){
            if(i==0 && attachmentType == undefined || attachmentType ==''){
                attachmentType = this.uploadedFiles[i].Type;
            } else {
                if(!attachmentType.includes(this.uploadedFiles[i].Type)){
                    attachmentType = attachmentType+','+ this.uploadedFiles[i].Type;
                }
            }
        }
        return attachmentType;
    }
    get attachmentType() {
        return [{
                label: 'Approval Documentation',
                value: 'Approval Documentation'
            },
            {
                label: 'Receipts',
                value: 'Receipts'
            },
            {
                label: 'Damage Claim',
                value: 'Damage Claim'
            },
            {
                label: 'Resource Order',
                value: 'Resource Order'
            },
            {
                label: 'Other',
                value: 'Other'
            },
        ];
    }
    get showSubmit() {
        if(this.reimbursRecord.Status__c == 'Approved' || this.reimbursRecord.Status__c == 'Rejected') return true;
        else return false;
    }

    @api get recordId() {
        return this.reimbursemenId;
    }
    set recordId(value) {
        this.reimbursemenId = value;
        this.getData();
    }
}