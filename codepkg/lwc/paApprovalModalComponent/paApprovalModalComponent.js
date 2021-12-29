/*
 *LWC Name      : PaApprovalModalComponent
 * Description  : 
 *               
 * Author       : Digamber
 * Created On   : 28/05/2021
 * Modification Log:  
 * -----------------------------------------------------------------------------------------------------------------
 * Developer             Date             Description 
 * -----------------------------------------------------------------------------------------------------------------
 * Digamber             28/05/2021       Initial Implementation
**/
import { LightningElement, track, api } from 'lwc';
import Utility from 'c/utility';
import createApprovalCloseOutTask from '@salesforce/apex/ApprovalComponentController.createApprovalCloseOutTask';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';

export default class PaApprovalModalComponent extends Utility {

    @api recordId;
    @track isFileUploadShow;
    @track approvalValSelected;
    @track commentValChange;
    @track contDocIds = [];

    initData() {
        this.isFileUploadShow = true;
    }

    
    /*****************************************************************************
    * Method Name  : handleapprovalvaluechange
    * Description  : this function is used to get the modal selected value
    * Inputs       : -
    * Author       : Digamber
    * Created On   : 26/05/2021
    * Modification Log: 
    *******************************************************************************/     
    handleapprovalvaluechange(event) {
        this.approvalValSelected = event.detail.approvalVal;
    }

    
    /*****************************************************************************
    * Method Name  : handlecommentvaluechange
    * Description  : this function is used to get the modal commented value
    * Author       : Digamber
    * Created On   : 26/05/2021
    * Modification Log: 
    *******************************************************************************/      
    handlecommentvaluechange(event) {
        this.commentValChange = event.detail.commentsVal;
    }

    
    /*****************************************************************************
    * Method Name  : handlecontdocids
    * Description  : this function is used to get document id
    * Inputs       : -
    * Author       : Digamber
    * Created On   : 26/05/2021
    * Modification Log: 
    *******************************************************************************/      
    handlecontdocids(event) {
        this.contDocIds = event.detail;
    }

    /*****************************************************************************
    * Method Name  : submitDetails
    * Description  : -
    * Inputs       : -
    * Author       : Digamber
    * Created On   : 26/05/2021
    * Modification Log: 
    *******************************************************************************/
    submitDetails() {
        this.validateSubmitCondition();
        
    }

    /*****************************************************************************
    * Method Name  : validateSubmitCondition
    * Description  : Validation Submit Condition......
    * Inputs       : -
    * Author       : Digamber
    * Created On   : 26/05/2021
    * Modification Log: 
    *******************************************************************************/
    validateSubmitCondition() {
        
        if (this.commentValChange === undefined && (this.approvalValSelected === 'Adjust' || this.approvalValSelected === 'Request for Information')) {
           // alert('Please Enter Comments Input');
            this.showErrorToast();
        }else{
            this.createCloseOutTaskVal();
        }
    }

    /*****************************************************************************
    * Method Name  : showErrorToast
    * Description  : showing the tost message on UI
    * Inputs       : -
    * Author       : Digamber
    * Created On   : 26/05/2021
    * Modification Log: 
    *******************************************************************************/
    showErrorToast() {
        const evt = new ShowToastEvent({
            title: 'Warning Message',
            message: 'Please Enter Comment Value...',
            variant: 'warning',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }

    /*****************************************************************************
    * Method Name  : createCloseOutTaskVal
    * Description  : -
    * Inputs       : -
    * Author       : Digamber
    * Created On   : 26/05/2021
    * Modification Log: 
    *******************************************************************************/
    createCloseOutTaskVal() {
        createApprovalCloseOutTask({
            approvalSelection: this.approvalValSelected, commentsVal: this.commentValChange,
            contDocsIdLst: this.contDocIds, relatedRecordId: this.recordId
        })
            .then(data => {
               
                this.template.querySelectorAll("c-approval-component").forEach(element => {
                    element.handleReest();
                });
                // Show success messsage
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Success!!',
                    message: 'Success Updated Info!!',
                    variant: 'success'
                }));
                getRecordNotifyChange([{recordId: this.recordId}]);
            })
            .catch(error => {
                this.error = error.message;
                window.console.log('error ===> ' + error);
            })
    }
}