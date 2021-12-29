/*
 *LWC Name      : PaRequestProjectCloseoutModal
 * Description  : This LWC is used to closeout check list  quation
 *               
 * Author       : Prajakta
 * Created On   : 28/05/2021
 * Modification Log:  
 * -----------------------------------------------------------------------------------------------------------------
 * Developer             Date             Description 
 * -----------------------------------------------------------------------------------------------------------------
 * Prajakta             28/05/2021       Initial Implementation
**/


import { LightningElement, track, wire, api } from 'lwc';
import Utility from 'c/utility';

export default class PaRequestProjectCloseoutModal extends Utility {
    @track radioValue1;
    @track radioValue2;
    @track radioValue3;
    @track radioValue4;
    @track radioValue5;
    @track radioValue6;
    @track radioValue7;
    @track percentFieldValue;
    @track showComponent = false;

    @track closeoutCheckList = [];

    @api recordId;
    @track question1 = 'Have you submitted Cost Summary and all documentation for claimed costs? ';
    @track question2 = 'Have all Direct Administrative (DAC) costs have been claimed?';
    @track question3 = 'Have all Record of Environmental Consideration (REC) items been addressed?';
    @track question4 = 'Has  approved Hazard Mitigation work been completed?';
    @track question5 = 'Was there any contract work completed?';
    @track question6 = 'Have you submitted justification for Cost Variances from approved amounts in the PW?';
    @track question7 = 'Have You Submitted Insurance Claim Reconcillation documents, if applicable?';

    @track renderComment1 = false;
    @track renderComment2 = false;
    @track renderComment3 = false;
    @track renderComment4 = false;
    @track renderComment5 = false;
    @track renderComment6 = false;
    @track renderComment7 = false;

    @track commentsVal1;
    @track commentsVal2;
    @track commentsVal3;
    @track commentsVal4;
    @track commentsVal5;
    @track commentsVal6;
    @track commentsVal7;

    get options() {
       return [
           { label: 'Yes', value: 'Yes' },
           { label: 'No', value: 'No' },
       ];
    }

    get options1() {
        return [
            { label: 'Yes', value: 'Yes' },
            { label: 'No', value: 'No' },
        ];
    }


    get options2() {
        return [
            { label: 'Yes', value: 'Yes' },
            { label: 'No', value: 'No' },
        ];
    }

    get options3() {
        return [
            { label: 'Yes', value: 'Yes' },
            { label: 'No', value: 'No' },
            { label: 'N/A', value: 'N/A' }
        ];
    }

    get options4() {
        return [
            { label: 'Yes', value: 'Yes' },
            { label: 'No', value: 'No' },
            { label: 'N/A', value: 'N/A' }
        ];
    }


    get options5() {
    return [
            { label: 'Yes', value: 'Yes' },
            { label: 'No', value: 'No' },
            { label: 'N/A', value: 'N/A' }
        ];
    }

    get options6() {
        return [
          { label: 'Yes', value: 'Yes' },
          { label: 'No', value: 'No' },
          { label: 'N/A', value: 'N/A' }
        ];
    }

    handleRadioChange(event){
        let fieldName = event.target.name;
        if(fieldName == 'Label1'){
            this.radioValue1 = event.detail.value;
            if(this.radioValue1 == 'No'){
                this.renderComment1 = true;
            }else{
                this.renderComment1 = false;
            }
        }else if(fieldName == 'Label2'){
            this.radioValue2 = event.detail.value;
            if(this.radioValue2 == 'No'){
                this.renderComment2 = true;
            }else{
               this.renderComment2 = false;
            }
        }else if(fieldName == 'Label3'){
            this.radioValue3 = event.detail.value;
            if( this.radioValue3 == 'No'){
                this.renderComment3 = true;
            }else{
                this.renderComment3 = false;
            }
        }else if(fieldName == 'Label4'){
            this.radioValue4 = event.detail.value;
            if(this.radioValue4 == 'No'){
                this.renderComment4 = true;
            }else{
                 this.renderComment4 = false;
            }
        }else if(fieldName == 'Label5'){
            this.radioValue5 = event.detail.value;
            if(this.radioValue5 == 'Yes'){
                this.renderComment5 = true;
            }else{
                this.renderComment5 = false;
            }
        }else if(fieldName == 'Label6'){
            this.radioValue6 = event.detail.value;
            if(this.radioValue6 == 'Yes'){
                this.renderComment6 = true;
            }else{
              this.renderComment6 = false;
            }
        }else if(fieldName == 'Label7'){
            this.radioValue7 = event.detail.value;
            if(this.radioValue7 == 'No'){
                this.renderComment7 = true;
            }else{
               this.renderComment7 = false;
            }
        }
     
    }

    handleCommentChange(event){
        let fieldName = event.target.name;
        if(fieldName == 'comment1'){
           this.commentsVal1 = event.detail.value;

        }else if(fieldName == 'comment2'){
           this.commentsVal2 = event.detail.value;

        }else if(fieldName == 'comment3'){
           this.commentsVal3 = event.detail.value;

        }else if(fieldName == 'comment4'){
           this.commentsVal4 = event.detail.value;

        }else if(fieldName == 'comment5'){
           this.commentsVal5 = event.detail.value;

        }else if(fieldName == 'comment6'){
           this.commentsVal6 = event.detail.value;

        }else if(fieldName == 'comment7'){
           this.commentsVal7 = event.detail.value;

        }
        }

        closeButton(event){
            this.dispatchEvent(new CustomEvent('modalclose'));
        }

        handleDone(event){
            this.closeoutCheckList.push({'Checklist__c' : this.question1, 'Response__c' : this.radioValue1, 'Comment__c': this.commentsVal1, 'Project__c':this.recordId},
            {'Checklist__c' : this.question2, 'Response__c' : this.radioValue2, 'Comment__c': this.commentsVal2, 'Project__c':this.recordId},
            {'Checklist__c' : this.question3, 'Response__c' : this.radioValue3, 'Comment__c': this.commentsVal3, 'Project__c':this.recordId},
            {'Checklist__c' : this.question4, 'Response__c' : this.radioValue4, 'Comment__c': this.commentsVal4, 'Project__c':this.recordId},
            {'Checklist__c' : this.question5, 'Response__c' : this.radioValue5, 'Comment__c': this.commentsVal5, 'Project__c':this.recordId},
            {'Checklist__c' : this.question6, 'Response__c' : this.radioValue6, 'Comment__c': this.commentsVal6,'Project__c':this.recordId},
            {'Checklist__c' : this.question7, 'Response__c' : this.radioValue7, 'Comment__c': this.commentsVal7,'Project__c':this.recordId});

               this.dispatchEvent(new CustomEvent('submitmodalaction', { detail: { 'closeoutChecklistList': this.closeoutCheckList,'projectId':this.recordId} }));
        }

}