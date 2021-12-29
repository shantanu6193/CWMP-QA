import {
    LightningElement,
    track
} from 'lwc';
import Utility from 'c/utility';
import getInvoiceList from '@salesforce/apex/MARS_InvoiceListCtrl.getInvoiceList';
import getInvoiceData from '@salesforce/apex/MARS_InvoiceListCtrl.getInvoiceData';
import approveInvoice from '@salesforce/apex/MARS_InvoiceListCtrl.approveInvoice';
import saveSignature from '@salesforce/apex/MARS_InvoiceListCtrl.saveSignature';
import rejectInvoice from '@salesforce/apex/MARS_InvoiceListCtrl.rejectInvoice';
import getInvoiceDownloadURL from '@salesforce/apex/MARS_InvoiceListCtrl.getInvoiceDownloadURL';
import getContentVersionPreview from '@salesforce/apex/MARS_InvoiceListCtrl.getContentVersionPreview';
//import getInvoiceSupportDocDownloadURL from '@salesforce/apex/MARS_InvoiceListCtrl.getInvoiceSupportDocDownloadURL';


export default class MarsInvoiceList extends Utility {
    isViewModalOpen = false;
    agencyId;
    pendingApprovalInvoiceList;
    approvedInvoiceList;
    contentVersions;
    invoiceRecord;
    downloadUrl;
    invoiceId;
    printedTitle;
    printedName;
    isRejected = false;
    isApproved = false;
    rejectionComments;
    @track approvedVisibleRecords;
    @track pendingVisibleRecords;
    agencyName;
    incidentName;
    invoiceNumber;
    //downloadSupportDocUrl;
    initData() {
        let urlId = this.getURLParameter("id");
        this.agencyId = urlId;
        if (this.agencyId) {
            this.executeAction(getInvoiceList, {
                'agencyId': this.agencyId
            }, (response) => {
                this.pendingApprovalInvoiceList = response.pendingApprovalInvoiceList;
                this.approvedInvoiceList = response.approvedInvoiceList;
            });
        }
    }
    handleInvoiceNumberChange(event) {
        this.invoiceNumber = event.detail.value;
        console.log('###: invoiceNumber: ' + JSON.stringify(this.invoiceNumber))
    }
    handleIncidentNameChange(event) {
        this.incidentName = event.detail.value;
        console.log('###: incidentName: ' + JSON.stringify(this.incidentName))
    }
    handleAgencyNameChange(event) {
        this.agencyName = event.detail.value;
        console.log('###: agencyName: ' + JSON.stringify(this.agencyName))
    }
    handleSearch() {
        console.log('handle Search')
        if (!this.invoiceNumber && !this.incidentName && !this.agencyName) {
            this.showErrorNotification('Enter atleast one filter');
        }
    }
    rejectRecord(event) {
        //event.preventDefault();
        const itemIndex = event.currentTarget.dataset.index;
        this.invoiceId = itemIndex;
        this.isRejected = true;
        this.isApproved = false;
        this.getRecord()
    }
    approveRecord(event) {
        //event.preventDefault();
        const itemIndex = event.currentTarget.dataset.index;
        this.invoiceId = itemIndex;
        this.isApproved = true;
        this.isRejected = false;
        this.getRecord();
    }
    getRecord() {
        this.executeAction(getInvoiceData, {
            invoiceId: this.invoiceId
        }, (result) => {
            this.invoiceRecord = result.invoiceRecord;
            this.contentVersions = result.contentVersions;
            if (this.contentVersions) {
                this.downloadUrl = '/sfc/servlet.shepherd/version/download/' + this.contentVersions[0].Id;
            }
        });
        this.isViewModalOpen = true;
    }
    closeSubmitModal() {
        // to close modal set isViewModalOpen tarck value as false
        this.isViewModalOpen = false;
    }
    get showForPendingInvoices() {
        if (this.invoiceRecord.Status__c == 'Pending For Local Agency Approval') {
            return true;
        } else return false;
    }
    saveApproveData() {
        let signatureBlob = this.template.querySelector('[data-id="signature"]').getSignatureBlob();
        if (signatureBlob == undefined) {
            this.showErrorNotification('Please sign Invoice');
            this.template.querySelector('[data-id="signature"]').refreshCanvas();
            return;
        }
        if (this.printedTitle == undefined) {
            this.showErrorNotification('Please enter printed title');
            return;
        }
        if (this.printedName == undefined) {
            this.showErrorNotification('Please enter printed name');
            return;
        }
        this.executeAction(saveSignature, {
            invoiceId: this.invoiceId,
            signatureBlob: signatureBlob,
            printedTitle: this.printedTitle,
            printedName: this.printedName
        }, (response) => {
            console.log('response==', response);
            if (response) {
                this.executeAction(approveInvoice, {
                    invoiceId: this.invoiceId
                }, (response) => {
                    console.log('response==', response);
                    if (response) {
                        this.isViewModalOpen = false;
                        this.printedTitle = undefined;
                        this.printedName = undefined;
                        this.showSuccessNotification('Invoice is approve');
                    } else {
                        this.showErrorNotification('Invoice is not approved');
                    }
                    this.initData();
                });
            } else {
                this.showErrorNotification('Signature is not Submitted');
            }
        });
    }
    saveRejectedData() {

        if (this.rejectionComments == undefined) {
            this.showErrorNotification('Please enter rejection comments');
            return;
        }
        this.executeAction(rejectInvoice, {
            invoiceId: this.invoiceId,
            comments: this.rejectionComments,
        }, (response) => {
            console.log('response==', response);
            if (response) {
                this.isViewModalOpen = false;
                this.showSuccessNotification('Invoice is Rejected Successfully.');
            } else {
                this.showErrorNotification('Invoice is not Rejected');
            }
            this.initData();
        });
    }
    handlePrintedTitle(event) {
        this.printedTitle = event.target.value;
    }
    handlePrintedName(event) {
        this.printedName = event.target.value;
    }
    handelComments(event) {
        this.rejectionComments = event.target.value;
    }
    getInvoiceURL(event) {
        this.downloadUrl = '';
        const itemIndex = event.currentTarget.dataset.index;
        this.invoiceId = itemIndex;
        console.log(JSON.stringify(event.currentTarget.dataset));
        this.executeAction(getInvoiceDownloadURL, {
            invoiceId: this.invoiceId
        }, (result) => {
            this.contentVersions = result.contentVersions;
            if (this.contentVersions) {
                this.downloadUrl = '/sfc/servlet.shepherd/version/download/' + this.contentVersions[0].Id;
                window.open(this.downloadUrl);
            }
        });
    }
    /*getInvoiceSupportDcoURL(event) {
        this.downloadSupportDocUrl = '';
        const itemIndex = event.currentTarget.dataset.index;
        this.invoiceId = itemIndex;
        console.log(JSON.stringify(event.currentTarget.dataset));
        this.executeAction(getInvoiceSupportDocDownloadURL, {
            invoiceId: this.invoiceId
        }, (result) => {
            this.contentVersions = result.contentVersions;
            console.log('this.contentVersions==',this.contentVersions.length);
            if (this.contentVersions.length != 0) {
                this.downloadSupportDocUrl = '/sfc/servlet.shepherd/version/download/' + this.contentVersions[0].Id;
                window.open(this.downloadSupportDocUrl);
            } else {
                this.showErrorNotification('Invoice Supported Documents not found');
            }
        });
    }*/
    viewPdf(event) {
        console.log('###: In viewPdf')
        const itemIndex = event.currentTarget.dataset.index;
        console.log('###: itemIndex: ' + JSON.stringify(itemIndex))
        this.invoiceId = itemIndex;
        this.executeAction(getContentVersionPreview, {
            previewId: this.invoiceId
        }, (result) => {
            console.log('###: result: ' + JSON.stringify(result));
            this.navigateToFilePreview(result);
        });
    }
    approvedPaginationHandler(event) {
        this.approvedVisibleRecords = event.detail.slicedRecords;
    }
    pendingPaginationHandler(event) {
        this.pendingVisibleRecords = event.detail.slicedRecords;
    }
}