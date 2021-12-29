/*
 *LWC Name      : PaCloseoutCheckListTable
 * Description  : This LWC used to display the check list of project closoeut in ther from og table
 *               
 * Author       : Dayal
 * Created On   : 03/12/2021
 * Modification Log:  
 * -----------------------------------------------------------------------------------------------------------------
 * Developer             Date             Description 
 * -----------------------------------------------------------------------------------------------------------------
 * Dayal             03/12/2021      Initial Implementation*/

import { LightningElement, track, wire, api} from 'lwc';
import getCloseoutCheckList from '@salesforce/apex/PA_RequestCloseoutController.getCloseoutCheckList';
import Utility from 'c/utility';

const columns = [
    {
        label: 'Closeout Checklist Name',
        fieldName: 'checkListName',
        type: 'url',
        typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'}
    }, {
        label: 'Checklist',
        fieldName: 'Checklist__c',
        type: 'text',
    }, {
        label: 'Response',
        fieldName: 'Response__c',
        type: 'text',
    }, {
        label: 'Comment',
        fieldName: 'Comment__c',
        type: 'phone'
    }
];



export default class PaCloseoutCheckListTable  extends Utility {
    @ api recordId;
    consData = [];
    columns = columns;

    /*****************************************************************************
    * Method Name  : initData
    * Description  : this method run when page is load   
    * Inputs       : -
    * Author       : Dayal
    * Created On   : 16/05/2021
    * Modification Log: 
    *******************************************************************************/ 
	initData(){
           
        if(this.recordId ){
            this.executeAction(getCloseoutCheckList, {'projectClosoeutId' :this.recordId}, (response) => {
                if (response) {
                    let checkList = []; 
                    
                    response.forEach((record) => {
                        let checkListRecord = Object.assign({}, record);  
                        checkListRecord.checkListName = '/' + checkListRecord.Id;
                        checkList.push(checkListRecord);
                        
                    });
                    
                    this.consData = checkList;
                    this.error = undefined;
        
                } else if (error) {
                    this.error = result.error;
                }
            });  
              
        }
	}

}