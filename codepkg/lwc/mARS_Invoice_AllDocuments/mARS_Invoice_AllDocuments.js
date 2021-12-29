import {
    LightningElement,
    api,
    track
} from 'lwc';
import Utility from 'c/utility';
import getData from "@salesforce/apex/MARS_Invoice_AllDocuments.getAllRelatedFiles";


export default class MARS_Invoice_AllDocuments extends Utility {
    @api recordId;
    mapFiles = [];
    @track downloadURL = '/sfc/servlet.shepherd/version/download';
    @track downloadURLLength;
    @track allContentVersionsMap = [];
    @track selectFileDownloadMap = {};
    @track disabled = true;

    initData() {
        console.log('record id: ' + this.recordId);
        this.downloadURLLength = this.downloadURL.length;
        this.executeAction(getData, {
            recordId: this.recordId
        }, (result) => {
            console.log('result' + JSON.stringify(result))
            console.log('result' + result)
            console.log('result data' + JSON.stringify(result.data))
            this.mapFiles = Object.keys(result.mapDocs).map(key => ({
                key: key,
                value: result.mapDocs[key]
            }));
            this.allContentVersionsMap = result.allContentVersionURLsMap;
            console.log('###: mapFiles: ' + JSON.stringify(this.mapFiles));
        });
    }

    getInvoiceURL(event) {
        this.downloadUrl = '';
        const itemIndex = event.currentTarget.dataset.index;
        console.log('itemIndex: ' + itemIndex);
        let downloadUrl = '/sfc/servlet.shepherd/version/download/' + itemIndex;
        console.log('### download URL: ' + downloadUrl)
        window.open(downloadUrl);
    }

    selectedDownloadHandler() {
        Object.values(this.selectFileDownloadMap).forEach(url => {
            console.log('### url: ' + url)
            window.open(url, '_blank');
        })
        //window.open(this.downloadURL);
    }

    downloadAllHandler() {
        console.log('###:allContentVersionsMap: ' + JSON.stringify(this.allContentVersionsMap));
        for (let value in this.allContentVersionsMap) {
            console.log('###: value: ' + this.allContentVersionsMap[value])
            window.open(this.allContentVersionsMap[value], '_blank');
        }
    }

    checkboxHandler(event) {
        const itemIndex = event.currentTarget.dataset.index;
        const itemName = event.currentTarget.dataset.name;
        if (event.target.checked) {
            if (this.selectFileDownloadMap[itemName]) {
                this.selectFileDownloadMap[itemName] = this.selectFileDownloadMap[itemName] + '/' + itemIndex;
            } else {
                this.selectFileDownloadMap[itemName] = this.downloadURL + '/' + itemIndex;
            }
        } else {
            this.selectFileDownloadMap[itemName] = this.selectFileDownloadMap[itemName].replace("/" + itemIndex, "");
        }
        for (let url of Object.values(this.selectFileDownloadMap)) {
            if (url.length !== (this.downloadURLLength)) {
                this.disabled = false;
                break;
            } else {
                this.disabled = true;
            }
        }
        console.log('###: downloadURL: ' + JSON.stringify(this.downloadURL));
        console.log('###: selectFileDownloadMap: ' + JSON.stringify(this.selectFileDownloadMap));
    }
}