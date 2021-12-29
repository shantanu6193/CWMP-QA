import { LightningElement, api, track } from 'lwc';
import Utility from 'c/utility';
import processRecord from '@salesforce/apex/HMA_ApplicationCtrl.processRecord';
import processNextPreviousProgramTemplatePage from '@salesforce/apex/HMA_ApplicationCtrl.processNextPreviousProgramTemplatePage';
import processReadOnlyRecord from '@salesforce/apex/HMA_ApplicationCtrl.processReadOnlyRecord';
import getLoggedInUserContactRoleForApplication from '@salesforce/apex/HMA_ApplicationCtrl.getLoggedInUserContactRoleForApplication';
import { CurrentPageReference } from 'lightning/navigation';


export default class hmaApplicationDetailsInternal extends Utility {
    @api recordId;

    nextPageLayoutSequence = 0;
    @track applicationRecord = {};
    @track accountRecord = {};
    @track showApplicationWorkSchedule = false;
    @track previousButtonLayout = '';


    @track programTemplatePageIdLocal;
    @track nextPageLayout;
    @track previousPageLayout;
    @track objectApiName;
    @track tableRecordDetails = [];
    @track workScheduleLineItems = [];
    @track projectCostLineItems = [];
    @track tableRecordMap = [];
    @track nextProgramTemplatePage;
    @track isAnyFieldsChange = false;
    @track isActionInProgress = false;
    @track isSubmitAllowed = false;
    @track isSaveAllowed = false;
    @track isAllFieldsReadOnly = true;
    @track hideFieldCustomAttributeRole = {
                           	"role": "FEMA Programmatic Analyst,FEMA EHP Analyst"
                           };

    @api
    get programTemplatePageId(){
        return this.programTemplatePageIdLocal;
    }

    set programTemplatePageId(value){
        console.log('programTemplatePageId value: '+value);
        this.programTemplatePageIdLocal = value;
    }

    initData() {
        console.log('nextPageLayoutSequence init: ',this.nextPageLayoutSequence);
        console.log('recordId init: ',this.recordId);
        window.scrollTo(0,0);
    }
    
    buttonAction(event) {
        let jsonObject = JSON.parse(JSON.stringify(event.detail));
        this.executeAction(processNextPreviousProgramTemplatePage, { recordId: this.recordId, 
                                                                    programTemplatePageId: this.programTemplatePageIdLocal,
                                                                    'buttonAction': jsonObject.buttonAction }, (response) => {
            if(response.isSuccess) {
                if(response['nextProgramTemplatePage'] != null) {
                    this.programTemplatePageIdLocal = response['nextProgramTemplatePage'].Id;
                }
            }
        }, (error) => {
            console.log('Error : ', error);
            this.isActionInProgress = false;
            this.showErrorNotification('', error.body.message);
        });
        //HMA_AppCtrl
        //Next/ Previous

    }
}