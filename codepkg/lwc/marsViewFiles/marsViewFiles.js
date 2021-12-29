import { LightningElement,track,api } from 'lwc';
import Utility from 'c/utility';
export default class MarsViewFiles extends Utility {
    @track fileList = [];
    @api attachmentType='Attachment Type';
    initData(){
        if(this.record != undefined) {
            let tempArray = [];
            for(let key in this.record){
                let file = this.record[key];
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

    }
}