/*
 *LWC Name      : PaCloseoutTaskRemoveProjectModal
 * Description  : This LWC is used to override the Remove project button on closoeut task
 *               
 * Author       : Digamber
 * Created On   : 28/05/2021
 * Modification Log:  
 * -----------------------------------------------------------------------------------------------------------------
 * Developer             Date             Description 
 * -----------------------------------------------------------------------------------------------------------------
 * Digamber             28/05/2021       Initial Implementation
**/
import { LightningElement,api,wire,track } from 'lwc';
import isFullAccessCloseoutTaskUserWire from '@salesforce/apex/PACloseoutTaskRemoveProjectController.isFullAccessCloseoutTaskUserWire';
import { CloseActionScreenEvent } from 'lightning/actions';
import Utility from 'c/utility';
import { NavigationMixin } from 'lightning/navigation';

export default class PaCloseoutTaskRemoveProjectModal extends  Utility{
    
    //closeoutTaskRecordId
    @api recordId;
    @track wireExecutor = new Date().getTime();

    initData(){
        this.wireExecutor = new Date().getTime()+'';
        this.programName = 'Public Assistance';
        this.className = 'PACloseoutTaskRemoveProjectController';
    } 

    /*****************************************************************************
    * Method Name  : getCloseoutTaskWire
    * Description  : This function is used to verify the closoeut task have remove project permission or not
    * Inputs       : -
    * Author       : Digamber
    * Created On   : 26/05/2021
    * Modification Log: 
    *******************************************************************************/    
    @wire(isFullAccessCloseoutTaskUserWire, {closeoutTaskId: '$recordId', status:'$wireExecutor'})
    getCloseoutTaskWire({data, error}){
       
        if(data){
         
            if(data.isFullAccessCloseoutTaskUserWire == 'false'){
                    this.showErrorNotification('Error', 'You do not have permission to access Closeout Task Remove Projects');
                    this.closeTab();
                    return;
            } else {
                    this.handleNavigate();
            }
        }else{
            this.error = error;
            this.data = undefined;
        }
    }

    /*****************************************************************************
    * Method Name  : closeTab
    * Description  : This function is used to close the tab
    * Inputs       : -
    * Author       : Digamber
    * Created On   : 26/05/2021
    * Modification Log: 
    *******************************************************************************/ 
    closeTab(){
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    /*****************************************************************************
    * Method Name  : handleNavigate
    * Description  : This function is used to navigate the page
    * Inputs       : -
    * Author       : Digamber
    * Created On   : 26/05/2021
    * Modification Log: 
    *******************************************************************************/ 
  
    handleNavigate(){
        var compDefinition = {
            componentDef: "c:paCloseoutTaskRemoveProject",
            attributes: {
                recordId: this.recordId,
            }
        };

        // Base64 encode the compDefinition JS object
        var encodedCompDef = btoa(JSON.stringify(compDefinition));
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            label: 'Remove Projects',
            attributes: {
                url: '/one/one.app#' + encodedCompDef,
                apiName: 'ABDS'
            }
        });
    }
}