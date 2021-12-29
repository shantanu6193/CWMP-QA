/**
 * Created by harsh on 21-04-2021.
 */

import { LightningElement, track, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import Utility from 'c/utility';
import getProjectSitePageDetails from '@salesforce/apex/HMA_ApplicationCtrl.getProjectSitePageDetails';
import updateProjectSiteRecord from '@salesforce/apex/HMA_ApplicationCtrl.updateProjectSiteRecord';

export default class HmaApplicationProjectSite extends Utility {

    @track parentId;
    @track parentProgramTemplatePageId;
    @track programTemplatePageId;
    @track projectSiteId;
    @track projectSitePageId;
    @track returnUrlPage;
    @track isProjectSiteRecordCreated = false;
    @track mode;
    @track pageLayoutId;
    @track isBackButton = true;

    @wire(CurrentPageReference)
    setCurrentPageRef(currentPageReference) {
        if(currentPageReference && currentPageReference.state) {
          if(currentPageReference.state.projectSiteId) {
            this.recordId = currentPageReference.state.projectSiteId;
            this.projectSiteId = currentPageReference.state.projectSiteId;
          }
          /*if(currentPageReference.state.parentId) {
            this.parentId = currentPageReference.state.parentId;
          }*/
          if(currentPageReference.state.projectSitePageId) {
            this.projectSitePageId = currentPageReference.state.projectSitePageId;
          }
          if(currentPageReference.state.programTemplatePageId) {
            this.programTemplatePageId = currentPageReference.state.programTemplatePageId;
          }
          if(currentPageReference.state.parentProgramTemplatePageId) {
            this.parentProgramTemplatePageId = currentPageReference.state.parentProgramTemplatePageId;
          }
          /*Config required*/
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
        this.pageLayoutId = this.getURLParameter('pageLayoutId');

        console.log('this.projectSiteId--'+  this.projectSiteId);
        console.log('this.projectSitePageId--'+this.projectSitePageId);
        console.log('this.parentId--'+this.getURLParameter('parentId'));
        console.log('this.isProjectSiteRecordCreated--'+this.isProjectSiteRecordCreated);
        console.log('this.this.mode--'+this.mode);
        if(this.parentId && (this.pageLayoutId == undefined || this.pageLayoutId == null)){
          this.getProjectSitePageLayoutAndRecordDetails();
        }
    }

    getProjectSitePageLayoutAndRecordDetails(){
        this.showLoader = true;
        this.executeAction(getProjectSitePageDetails, {projectSiteId:this.projectSiteId, projectSitePageId : this.projectSitePageId, parentId: this.parentId, mode: this.mode}, (response) => {
            console.log('createProjectSiteRecord response: ',response);
            this.showLoader = false;
            if(response['isSuccess']){
                let siteRecordId = this.projectSiteId;
                if(response['projectSiteRecord'] && response['projectSiteRecord']['Id']){
                    siteRecordId = response['projectSiteRecord']['Id'];
                    this.projectSiteId = response['projectSiteRecord']['Id'];
                }
                let programSitePage = response['sitePages'];
                let pageLayout = response['pageLayout'];
                this.programTemplatePageId = programSitePage.Program_Template_Page__c;
                this.isProjectSiteRecordCreated = true;
                let param = {};
                param = {   parentId:this.parentId,
                            parentProgramTemplatePageId: this.parentProgramTemplatePageId,
                            projectSiteId: this.projectSiteId,
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

    get isProgramTemplatePageIdAvailable(){
        if(this.programTemplatePageId){
            return true;
         }else{
            return false;
        }
    }

    buttonAction(event){
        console.log('Hma Site_Button action:--------- ',JSON.stringify(event.detail));
        let jsonObject = JSON.parse(JSON.stringify(event.detail));
      if(jsonObject.buttonAction == 'back') {
        this.handleURLRedirect();
        return;
      }
        this.updateSiteRecord();
    }

    updateSiteRecord(){
        let record = this.template.querySelector("c-page-layout").returnCurrentRecord();
        this.showLoader = true;
        this.executeAction(updateProjectSiteRecord, {recordDetails: JSON.stringify(record), mode: this.mode, parentId: this.parentId }, (response) => {
            console.log('updateSiteRecord: ',response);
            this.showLoader = false;
            if(response.isSuccess) {
                this.handleURLRedirect();
            }
        });
    }

    handleURLRedirect(){
        console.log('--this.parentId---'+this.parentId);
        console.log('--this.parentProgramTemplatePageId---'+this.parentProgramTemplatePageId);
        this.redirectToCommunityCustomPage(this.returnUrlPage,{id:this.parentId, programTemplatePageId: this.parentProgramTemplatePageId});
    }

}