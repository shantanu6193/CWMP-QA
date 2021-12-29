/*
 *LWC Name      : PaRequestProjectCloseoutReviewModal
 * Description  : -
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

export default class PaRequestProjectCloseoutReviewModal extends Utility {

    //stores single custom metadata record
    @api customMetadata;
    @api selectedChecklist;
    @api recordId;
    @track renderQuestions = false;
    //stores comment flag

    //Init custom metadata record
    initData(){
        for(let i = 0; i < this.selectedChecklist.length ; i++){
             let checklist = this.selectedChecklist[i];
             if(checklist.Checklist__c == this.customMetadata.Question__c){
                this.recordLocal = JSON.parse(JSON.stringify(checklist));
             }

        }
        if(this.customMetadata.Show_Only_For_Yes_Value__c == null){
            this.renderQuestions = true;
        }
        this.recordLocal.Checklist__c = this.customMetadata.Question__c;
        this.recordLocal.Project__c = this.recordId;

    }



    get radioLabel(){
        return this.customMetadata.Sequence__c +  '. ' + this.customMetadata.Question__c;
    }

    //getter for radio options
    get options(){
        let values = [];
        if(this.customMetadata.Render_yes__c  ){
                values.push({ label: 'Yes', value: 'Yes' });
        }
        if(this.customMetadata.Render_No__c){
            values.push({ label: 'No', value: 'No' });
        }
        if(this.customMetadata.Render_NA__c){
            values.push({ label: 'N/A', value: 'N/A' });
        }
        return values;
    }


    get renderHelptext(){
      return  this.customMetadata.Helptext__c;
    }


    fieldRadioSelectionCustom(event){
        this.fieldRadioSelection(event);
        this.dispatchEvent(new CustomEvent('rendereddependantquestion', { detail: { 'question':this.recordLocal.Checklist__c,'response':this.recordLocal.Response__c,'metadataDeveloperName':this.customMetadata.DeveloperName} }));

    }

    get renderComment(){
        if(this.recordLocal.Response__c == 'Yes' && this.customMetadata.Show_Yes_Comments__c){
           return true;

        } else if(this.recordLocal.Response__c == 'No' && this.customMetadata.Show_No_Comments__c) {
           return true;

        } else if(this.recordLocal.Response__c == 'N/A' && this.customMetadata.Shown_NA_Comments__c) {
           return true;
        }
        return false;
    }

    get renderStaticText(){
        if(this.recordLocal.Response__c == 'Yes' && this.customMetadata.Static_Text__c != null){
           return true;
        }else{
           return false;
        }

    }
    get renderHelptextDocument1(){
        if(this.customMetadata.Helptext_Document_URL1__c != null && this.customMetadata.Helptext_Document_Name1__c != null && this.recordLocal.Response__c == 'No') {
           return true;
        } else {
           return false;
        }

    }

    get renderHelptextDocument2(){
        if(this.customMetadata.Helptext_Document_URL2__c != null && this.customMetadata.Helptext_Document_Name2__c != null && this.recordLocal.Response__c == 'No') {
           return true;
        } else {
           return false;
        }

    }

    @api
    showDependantQuestions(){
       this.renderQuestions = true;

    }

    @api
    hideDependantQuestions(){
       this.renderQuestions = false;
       this.recordLocal.Response__c = undefined;
       this.dispatchEvent(new CustomEvent('rendereddependantquestion', { detail: { 'question':this.recordLocal.Checklist__c,'response':this.recordLocal.Response__c,'metadataDeveloperName':this.customMetadata.DeveloperName} }));

    }

    @api
    renderQuestionValue(){
       return this.renderQuestions;
    }
}