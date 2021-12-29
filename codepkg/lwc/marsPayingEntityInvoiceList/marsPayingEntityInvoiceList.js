import {
    LightningElement,
    track
} from 'lwc';
import Utility from 'c/utility';
import getInvoiceList from '@salesforce/apex/MARS_PayingEntityInvoiceListCtrl.getInvoiceList';
import getInvoiceData from '@salesforce/apex/MARS_PayingEntityInvoiceListCtrl.getInvoiceData';
import approveInvoice from '@salesforce/apex/MARS_PayingEntityInvoiceListCtrl.approveInvoice';
import approvePaymentInvoice from '@salesforce/apex/MARS_PayingEntityInvoiceListCtrl.approvePaymentInvoice';
import rejectPaymentInvoice from '@salesforce/apex/MARS_PayingEntityInvoiceListCtrl.rejectPaymentInvoice';
import saveSignature from '@salesforce/apex/MARS_PayingEntityInvoiceListCtrl.saveSignature';
import rejectInvoice from '@salesforce/apex/MARS_PayingEntityInvoiceListCtrl.rejectInvoice';
import getInvoiceDownloadURL from '@salesforce/apex/MARS_PayingEntityInvoiceListCtrl.getInvoiceDownloadURL';
import getContentVersionPreview from '@salesforce/apex/MARS_PayingEntityInvoiceListCtrl.getContentVersionPreview';
import getInvoiceListByFilter from '@salesforce/apex/MARS_PayingEntityInvoiceListCtrl.getInvoiceListByFilter';
//import getInvoiceSupportDocDownloadURL from '@salesforce/apex/MARS_PayingEntityInvoiceListCtrl.getInvoiceSupportDocDownloadURL';

export default class MarsInvoiceList extends Utility {
    isViewModalOpen = false;
    @track payingEntityInvoiceList = [];
    @track paidInvoiceList = [];
    generationInvoiceList;
    contentVersions;
    invoiceRecord;
    downloadUrl;
    invoiceId;
    printedTitle;
    printedName;
    isRejected = false;
    isApproved = false;
    rejectionComments;
    @track isApproveModalOpen = false;
    @track isRejectModalOpen = false;
    payingAmount;
    paymentDate;
    invoicePaymentComments;
    itemIndex;
    //downloadSupportDocUrl;
    @track isCommentsMandatory = true;
    @track invoiceAmount;
    @track invoiceNumber;
    @track incidentName;
    @track macsId;
    @track paidVisibleRecords;
    @track pendingVisibleRecords;
    initData() {
        this.executeAction(getInvoiceList, {}, (response) => {
            this.payingEntityInvoiceList = response.payingEntityInvoiceList;
            this.paidInvoiceList = response.paidPayments;
            console.log('###: payingEntityInvoiceList: ' + JSON.stringify(this.payingEntityInvoiceList))
            console.log('###: paidInvoiceList: ' + JSON.stringify(this.paidInvoiceList))
        });
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
        console.log('###: paymentAmount: ' + JSON.stringify(this.payingAmount));
        console.log('###: invoiceAmount: ' + JSON.stringify(this.invoiceAmount));
        console.log('###: paymentDate: ' + JSON.stringify(this.paymentDate));
        console.log('###: invoicePaymentComments: ' + JSON.stringify(this.invoicePaymentComments));
        if (this.isCommentsMandatory) {
            this.showErrorNotification('Error', 'Comments is mandatory when Invoice Amount and Paid Amount are not matching')
            return;
        }
        this.executeAction(approvePaymentInvoice, {
            invoicePaymentId: this.itemIndex,
            paidAmount: this.payingAmount,
            dateOfPayment: this.paymentDate,
            comments: this.invoicePaymentComments
        }, result => {
            if (result) {
                this.showSuccessNotification('Success', 'Invoice Payment Updated');
                this.isApproveModalOpen = false;
            }
        });
    }
    rejectPaymentRecord(event) {
        //event.preventDefault();
        console.log('###: paymentAmount: ' + JSON.stringify(this.payingAmount));
        console.log('###: paymentDate: ' + JSON.stringify(this.paymentDate));
        console.log('###: invoicePaymentComments: ' + JSON.stringify(this.invoicePaymentComments));
        this.executeAction(rejectPaymentInvoice, {
            invoicePaymentId: this.itemIndex,
            comments: this.invoicePaymentComments
        }, result => {
            if (result) {
                this.showSuccessNotification('Success', 'Invoice Payment Updated');
                this.isRejectModalOpen = false;
            }
        });
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
    openApproveModal(event) {
        console.log('####: in open modal')
        console.log('###: event: ' + event)
        console.log('###: event: ' + JSON.stringify(event.currentTarget))
        console.log('###: this.payingEntityInvoiceList: ' + JSON.stringify(this.payingEntityInvoiceList))
        this.isApproveModalOpen = true;
        this.itemIndex = event.currentTarget.dataset.index;
        this.payingEntityInvoiceList.forEach(element => {
            console.log('###: element: ' + element)
            if (element.Id === this.itemIndex) {
                this.invoiceAmount = element.Invoice_Amount__c;
            }
        });
        console.log('###: itemIndex: ' + JSON.stringify(this.itemIndex))
        console.log('###: itemIndex: ' + this.itemIndex)
        console.log('###: itemIndex IA: ' + JSON.stringify(this.itemIndex.Invoice_Amount__c))
        console.log('###: itemIndex Id: ' + JSON.stringify(this.itemIndex.Id))
        console.log('###: invoiceAmount Id: ' + JSON.stringify(this.invoiceAmount))
    }
    openRejectModal(event) {
        console.log('####: in open modal')
        console.log('###: event: ' + event)
        console.log('###: event: ' + JSON.stringify(event.currentTarget))
        this.isRejectModalOpen = true;
        this.itemIndex = event.currentTarget.dataset.index;
        console.log('###: itemIndex: ' + JSON.stringify(this.itemIndex))
    }
    closeApproveModal() {
        this.isApproveModalOpen = false;
    }
    closeRejectModal() {
        this.isRejectModalOpen = false;
    }
    closeSubmitModal() {
        // to close modal set isViewModalOpen tarck value as false
        this.isViewModalOpen = false;
    }
    handlePaymentAmountChange(event) {
        this.payingAmount = event.target.value;
        if (JSON.stringify(this.invoiceAmount) === this.payingAmount) {
            this.isCommentsMandatory = false;
        } else {
            this.isCommentsMandatory = true;
        }
    }
    handlePaymentDateChange(event) {
        this.paymentDate = event.target.value;
    }
    handleCommentsChange(event) {
        this.invoicePaymentComments = event.target.value;
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
        }, (response) => {
            console.log('response==', response);
            if (response) {
                this.executeAction(approveInvoice, {
                    invoiceId: this.invoiceId,
                    printedTitle: this.printedTitle,
                    printedName: this.printedName,
                }, (response) => {
                    console.log('response==', response);
                    if (response) {
                        this.isViewModalOpen = false;
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
    /*get fileURL(){
        return this.downloadUrl;
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

    handleInvoiceNumberChange(event) {
        this.invoiceNumber = event.detail.value;
        console.log('###: invoiceNumber: ' + JSON.stringify(this.invoiceNumber))
        if (!this.invoiceNumber && !this.incidentName && !this.macsId) {
            this.initData();
        }

    }
    handleIncidentNameChange(event) {
        this.incidentName = event.detail.value;
        console.log('###: incidentName: ' + JSON.stringify(this.incidentName))
        if (!this.invoiceNumber && !this.incidentName && !this.macsId) {
            this.initData();
        }
    }
    handleMacsIdChange(event) {
        this.macsId = event.detail.value;
        console.log('###: macsId: ' + JSON.stringify(this.macsId))
        if (!this.invoiceNumber && !this.incidentName && !this.macsId) {
            this.initData();
        }
    }
    handleSearch() {
        console.log('handle Search')
        this.executeAction(getInvoiceListByFilter, {
            invoiceNumber: this.invoiceNumber,
            invoiceName: this.incidentName,
            macId: this.macsId
        }, (response) => {
            this.payingEntityInvoiceList = response.payingEntityInvoiceList;
            console.log('###: payingEntityInvoiceList: ' + JSON.stringify(this.payingEntityInvoiceList))
            console.log('###: payingEntityInvoiceList: ' + JSON.stringify(this.payingEntityInvoiceList.length))
        })
    }

    get searchDisable() {
        if (!this.invoiceNumber && !this.incidentName && !this.macsId) {
            return true;
        } else {
            return false;
        }
    }
    approvedPaginationHandler(event) {
        this.paidVisibleRecords = event.detail.slicedRecords;
    }
    pendingPaginationHandler(event) {
        this.pendingVisibleRecords = event.detail.slicedRecords;
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
}