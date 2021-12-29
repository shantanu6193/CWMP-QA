/*
 *LWC Name      : PaRequestProjectCloseoutReviewMediatorModal
 * Description  : -
 *               
 * Author       : -
 * Created On   : 28/05/2021
 * Modification Log:  
 * -----------------------------------------------------------------------------------------------------------------
 * Developer             Date             Description 
 * -----------------------------------------------------------------------------------------------------------------
 * -             28/05/2021       Initial Implementation
**/

import { LightningElement, track, wire, api } from 'lwc';
import Utility from 'c/utility';

export default class PaRequestProjectCloseoutReviewMediatorModal extends Utility {

    //project id
    @api recordId;

    //stores custom metadata record
    @api customMetadataList;
    @api costShareEligibilityType;

    //store & edit checklist responses
    closeoutCheckListWorking = new Map();
    //stores all checklists response to be passed to parent
    @track closeoutCheckList = [];
    @api selectedChecklistArray;



    //Init custom metadata record
    initData(){
        console.log('customMetadataList',this.customMetadataList);
    }

    get showHeader(){
        if(this.costShareEligibilityType == 'CDAA'){
            return 'Please complete the following checklist items:';
        }else{
            return 'Please complete the following checklist items:';
        }
    }

    //CLOSE WINDOW 
    closeButton(event){
        this.dispatchEvent(new CustomEvent('modalclose'));
    }

    handleCancel(){
        this.dispatchEvent(new CustomEvent('modalclose'));
    }

    handleDone(event){
        //queryselector
        // for loop iterate and call child getter
        //push list
        let checkListArray = [];
        let isFieldValid =  true;
        let rowElements = this.template.querySelectorAll('c-pa-request-project-closeout-review-modal');
        rowElements.forEach(element => {
            const questionRenderedValue = element.renderQuestionValue();
            if(questionRenderedValue){
          const tableRow = element.getRecordDetails();
          if(tableRow != undefined){
            checkListArray.push(tableRow);
            }else{
                isFieldValid = false;
          }
            }


        });

        if(isFieldValid ==  true){
          this.dispatchEvent(new CustomEvent('submitmodalaction', { detail: { 'closeoutCheckList': checkListArray,'projectId':this.recordId} }));
        }

    }


    handleDependantQuestions(event){
        let question = event.detail.question;
        let response = event.detail.response;
        let metadataDeveloperName = event.detail.metadataDeveloperName;
        let rowElements = this.template.querySelectorAll('c-pa-request-project-closeout-review-modal[data-developername="'+metadataDeveloperName+'"]');
        rowElements.forEach(element => {
            if(response == 'Yes'){
              element.showDependantQuestions();
            }else{
              element.hideDependantQuestions();
            }

        });

    }


}