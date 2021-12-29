/**
 * Created by StackNexus Admin on 18-08-2021.
 */

import { LightningElement, wire, api, track} from 'lwc';
import HH_EN_Select_Language from '@salesforce/label/c.HH_EN_Select_Language';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import updateLanguage from '@salesforce/apex/HHCommunityLanguageSelector.updateLanguage';
import getLanguage from '@salesforce/apex/HHCommunityLanguageSelector.getLanguage';
import UR_OBJECT from '@salesforce/schema/User_Registration__c';
import Translation_Language from '@salesforce/schema/User_Registration__c.Translation_Language__c';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { CurrentPageReference } from 'lightning/navigation';

export default class HHCommunityLanguageSelector extends LightningElement {
        @track label ={
         HH_EN_Select_Language,
        }
        @track language = 'en_US';

    /* To hold the current selected language after page reload.*/
        @wire(CurrentPageReference)
                      getStateParameters(currentPageReference) {
                         if (currentPageReference) {
                            this.urlStateParameters = currentPageReference.state;
                            if(this.urlStateParameters.language){
                                this.language = this.urlStateParameters.language;
                            }else{
                                this.getUserLanguage();
                            }
                         }
                     }

      /* Change language of Page once user select Language */
           languageFieldChanged(event){
               console.log('result------');
               this.language = event.target.value;
               updateLanguage({ 'language' : this.language })
                       .then((result) => {
                           console.log('result----',JSON.stringify(result));
                           var queryParams = new URLSearchParams(window.location.search);
                           queryParams.set("language", this.language);
                           history.replaceState(null, null, "?" + queryParams.toString());
                           location.reload();
                       })
                       .catch((err) => {
                         alert(err.body.message);
                       });


          }
      @wire(getObjectInfo, { objectApiName: UR_OBJECT }) objectInfo;
      @wire(getPicklistValues, {recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: Translation_Language}) TranslationLanguage;
    connectedCallback(){
       this.getUserLanguage();
    }
    getUserLanguage(){
        getLanguage()
          .then((result) => {
             console.log('result getLanguage----',JSON.stringify(result));
             this.language = result;
             var queryParams = new URLSearchParams(window.location.search);
             queryParams.set("language", this.language);
             history.replaceState(null, null, "?" + queryParams.toString());
             //location.reload();
          })
          .catch((err) => {
            alert(err.body.message);
          });
    }
}