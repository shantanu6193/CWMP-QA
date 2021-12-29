/**
 * Created by harsh on 23-04-2021.
 */

import { LightningElement, wire, track } from 'lwc';
import Utility from 'c/utility';
import { CurrentPageReference } from 'lightning/navigation';
import getProjectSitePageDetails from '@salesforce/apex/HMA_ApplicationCtrl.getProjectSitePageDetails';

export default class HmaApplicationCreateProjectSite extends Utility {
     @track parentId;
     @track parentProgramTemplatePageId;
     @track returnUrlPage;
     @track mode;
     @track isProjectSiteRecordCreated = false;
    @wire(CurrentPageReference) 
    setCurrentPageRef(currentPageReference) {
        if(currentPageReference && currentPageReference.state) {
          if(currentPageReference.state.parentId) {
            this.parentId = currentPageReference.state.parentId;
          }
          if(currentPageReference.state.parentProgramTemplatePageId) {
            this.parentProgramTemplatePageId = currentPageReference.state.parentProgramTemplatePageId;
          }
          if(currentPageReference.state.returnUrlPage) {
            this.returnUrlPage = currentPageReference.state.returnUrlPage;
          }
          if(currentPageReference.state.mode) {
            this.mode = currentPageReference.state.mode;
          }
        }
    }

    initData(){
         /*currentPage reference not working as per expected so getUrlParam used*/
        this.parentId = this.getURLParameter('parentId');
        this.projectSiteId = this.getURLParameter('projectSiteId');
        this.projectSitePageId = this.getURLParameter('projectSitePageId');
        this.mode = this.getURLParameter('mode');
        if(this.parentId && this.mode == 'create'){
            this.getProjectSitePageLayoutAndRecordDetails();
        }
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
                param = {   parentId:this.parentId,
                            parentProgramTemplatePageId: this.parentProgramTemplatePageId,
                            projectSiteId: siteRecordId,
                            projectSitePageId : programSitePage.Id,
                            programTemplatePageId: programSitePage.Program_Template_Page__c,
                            pageLayoutId:pageLayout.Id,
                            returnUrlPage: this.returnUrlPage,
                            mode: 'edit'
                            };
                 console.log('param--'+param);
                this.redirectToCommunityCustomPage('application-project-site-edit',param);
            }
        });

    }

}