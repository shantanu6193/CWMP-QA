/**
* Component Name   : PACloseoutRequestPortalUserMesage
* Description  : 
* Author       : Digamber
* Created On   : 01/11/2021
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Digamber             01/11/2021       Initial Implementation
*/

import { LightningElement, track, wire, api } from 'lwc';
import getMessage from '@salesforce/apex/PACloseoutPoratalMessageController.getMessage';
import Utility from 'c/utility';

export default class PaCloseoutPortalMessage extends Utility {

    @api recordId;
    isMsgVisible = false;
    msg = '';

    @wire(getMessage, {recordId: '$recordId'}) 
    getMsg(result){
        console.log('#result :', result);
        if(result.data){
            this.isMsgVisible = result.data.isMsgVisible;
            this.msg = result.data.msg;
            console.log('#this.isMsgVisible :', this.isMsgVisible);
            console.log('#this.msg :', this.msg);
        }

    }
}