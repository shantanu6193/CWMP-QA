/**
 * Created by harsh on 24-08-2021.
 */

import { LightningElement, track, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import Utility from 'c/utility';
import getProjectSitePageDetails from '@salesforce/apex/HMA_ApplicationCtrl.getProjectSitePageDetails';
import updateProjectSiteRecord from '@salesforce/apex/HMA_ApplicationCtrl.updateProjectSiteRecord';

export default class HmaApplicationProjectSiteDetailsInternal extends Utility {

    @track parentId;
    @track parentProgramTemplatePageId;
    @track programTemplatePageId;
    @track projectSiteId;
    @track projectSitePageId;
    @track returnUrlPage;
    @track isProjectSiteRecordCreated = false;
    @track mode;
    @track pageLayoutId;

    @wire(CurrentPageReference)
    setCurrentPageRef(currentPageReference) {
        if(currentPageReference && currentPageReference.state) {
          if(currentPageReference.state.c__projectSiteId) {
            this.recordId = currentPageReference.state.c__projectSiteId;
            this.projectSiteId = currentPageReference.state.c__projectSiteId;
          }
          if(currentPageReference.state.c__parentId) {
            this.parentId = currentPageReference.state.c__parentId;
          }
          if(currentPageReference.state.c__projectSitePageId) {
            this.projectSitePageId = currentPageReference.state.c__projectSitePageId;
          }
          if(currentPageReference.state.c__programTemplatePageId) {
            this.programTemplatePageId = currentPageReference.state.c__programTemplatePageId;
          }
          if(currentPageReference.state.c__parentProgramTemplatePageId) {
            this.parentProgramTemplatePageId = currentPageReference.state.c__parentProgramTemplatePageId;
          }
          /*Config required*/
          if(currentPageReference.state.c__returnUrlPage) {
            this.returnUrlPage = currentPageReference.state.c__returnUrlPage;
          }
          if(currentPageReference.state.c__mode) {
            this.mode = currentPageReference.state.c__mode;
            this.getProjectSitePageLayoutAndRecordDetails();
          }
        }
    }

    initData(){
    }

    getProjectSitePageLayoutAndRecordDetails(){

        this.showLoader = true;
        this.executeAction(getProjectSitePageDetails, {projectSiteId:'', projectSitePageId : '', parentId: this.parentId, mode: this.mode}, (response) => {
            console.log('createProjectSiteRecord response: ',response);
            this.showLoader = false;
            if(response['isSuccess']){
                let siteRecordId = this.projectSiteId;
                if(response['projectSiteRecord'] && response['projectSiteRecord']['Id']){
                    siteRecordId = response['projectSiteRecord']['Id'];
                }
                let programSitePage = response['sitePages'];
                let pageLayout = response['pageLayout'];
                this.programTemplatePageId = programSitePage.Program_Template_Page__c;
                this.isProjectSiteRecordCreated = true;
                let param = {};
                param = {   c__parentId:this.parentId,
                            c__parentProgramTemplatePageId: this.parentProgramTemplatePageId,
                            c__projectSiteId: siteRecordId,
                            c__projectSitePageId : programSitePage.Id,
                            c__programTemplatePageId: programSitePage.Program_Template_Page__c,
                            c__pageLayoutId:pageLayout.Id,
                            c__returnUrlPage: this.returnUrlPage,
                            };
                 console.log('param--'+param);
                this.navigateNavItemPage('ApplicationProjectSiteDetails',param);
            }
        });

    }

    get isProgramTemplatePageIdAvailable(){
        if(this.programTemplatePageId){
            return true;
         }else{
            return false;
        }
    }
}