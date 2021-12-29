/**
* LWC Name     : PaMergeCloseoutTask
* Description  : This LWC used  Merge closeout Task. On close out list view once you click on Merge Closeout we have override lwc component
                 to merge closeout task. On this page, You can search on closeout Task.                
                 Post selection you will get closeout task list which have  same incident and Subrecipient
                 Once you select closeout task then Incident, subrecipent, stauts and closeout task related project are display,
                 Once you click on Merge then closeout task related project are merged in Master closeout task.
* Author       : Atul
* Created On   : 26/05/2021
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Atul             26/05/2021       Initial Implementation
*/

import { LightningElement,api,wire,track } from 'lwc';
import getCloseOutTaskDetails from '@salesforce/apex/PA_MergeCloseoutTaskController.getCloseOutTaskDetails';
import getProjectsAssociatedCloseOutTask from '@salesforce/apex/PA_MergeCloseoutTaskController.getProjectsAssociatedCloseOutTask';
import apexSearchCloseoutTask from '@salesforce/apex/PA_MergeCloseoutTaskController.apexSearchCloseoutTask';
import mergeSelectedCloseOutTask from '@salesforce/apex/PA_MergeCloseoutTaskController.mergeSelectedCloseOutTask';
import Utility from 'c/utility';

const columns = [
    {
        label: 'Project Name',
        fieldName: 'Name'
    },
    {
        label: 'Project Number',
        fieldName: 'CalOES_Project_Number__c'
    },
];

export default class PaMergeCloseoutTask extends Utility {
    @api recordId;
    loadDataOnLookup = false;
    @track closeoutTaskRecord = {};
    @track projectData = {};
    @track selectedProjectData = {};
    masterIncidentName;
    masterSubRecipentName;
    @track selectedCloseoutTaskRecord = {};
    selectCloseoutTaskName;
    @track selectedIncidentName;
    @track selectedSubRecipentName;
    @track columns;
    selectedCloseOutTaskId;
    isMergeButtonDisabled = true;
    objectAPINameVal = 'Closeout_Task__c';
    
    initData(){
        this.programName = 'Public Assistance';
        this.className = 'PA_MergeCloseoutTaskController';
    }
    
    /*---get incident Name ----*/
    get selectedIncidentNameStr(){
        if(this.selectedIncidentName){
            return this.selectedIncidentName;
        }
    }

    
    /*****************************************************************************
    * Method Name  : getCloseoutTaskWire
    * Description  : This method is used to get the closeout task Details which is selected  
    * Inputs       : -
    * Author       : Atul
    * Created On   : 26/05/2021
    * Modification Log: 
    *******************************************************************************/      
    
    @wire(getCloseOutTaskDetails, {closeOutTaskId: '$recordId'})
    getCloseoutTaskWire({data, error}){
        if(data){
            this.closeoutTaskRecord = data.masterCloseoutTask;
            this.error = undefined;
           
            this.masterIncidentName = this.closeoutTaskRecord.Incident__r.Name;
            this.masterSubRecipentName = this.closeoutTaskRecord.Subrecipient_Name__r.Name;
            this.getProjectDetails();
        }else{
            this.error = error;
            this.data = undefined;
        }
    }

    /*****************************************************************************
    * Method Name  : getProjectDetails
    * Description  : This method is used to get the project details
    * Inputs       : -
    * Author       : Atul
    * Created On   : 26/05/2021
    * Modification Log: 
    *******************************************************************************/     
    getProjectDetails(){

        let paramMap = {};
        paramMap['incidentName'] = this.closeoutTaskRecord.Incident__c;
        paramMap['subRecipentName'] = this.closeoutTaskRecord.Subrecipient_Name__c;
        paramMap['closeOutTaskId'] = this.recordId;

        this.executeAction(getProjectsAssociatedCloseOutTask, paramMap, (response) => {
            console.log('Result Block ===='+response);
            this.projectData = response;
            this.columns = columns;
        }); 
    }

    /*****************************************************************************
    * Method Name  : handleCloseoutChange
    * Description  : This method is used to display the closeout task which are selected on UI
    * Inputs       : -
    * Author       : Atul
    * Created On   : 26/05/2021
    * Modification Log: 
    *******************************************************************************/     
   
    handleCloseoutChange(response){
       
        if(response.detail){
            this.selectedCloseOutTaskId = response.detail.selectedItem.id;
            this.getCloseOutTask();
        }else{
         
           this.handleClearSearch();
        }
    }

    /*****************************************************************************
    * Method Name  : handleClearSearch
    * Description  : This method is used to clear the UI Page 
    * Inputs       : -
    * Author       : Atul
    * Created On   : 26/05/2021
    * Modification Log: 
    *******************************************************************************/   
    handleClearSearch(){
        this.selectedCloseOutTaskId = '';
        this.selectedCloseoutTaskRecord = '';
            this.selectedIncidentName = '';
            this.selectedSubRecipentName = '';
        this.selectedProjectData = '';
    }

    /*****************************************************************************
    * Method Name  : handleCloseoutSearch
    * Description  : This method is used to serach the closeout task 
    * Inputs       : -
    * Author       : Atul
    * Created On   : 26/05/2021
    * Modification Log: 
    *******************************************************************************/      
    handleCloseoutSearch(event){
        
        apexSearchCloseoutTask({searchTerm: event.detail.searchTerm, 'incidentId':this.closeoutTaskRecord.Incident__c, 'subRecipentId':this.closeoutTaskRecord.Subrecipient_Name__c, 
                                 'masterCloseoutTaskId':this.recordId})
        .then((results) => {
           
            this.template.querySelector('[data-lookup="Closeout_Task__c"]').setSearchResults(results);
        })
        .catch((error) => {
            this.error('Lookup Error', 'An error occured while searching with the lookup field.');
           
            this.errors = [error];
        });
    }

    /*****************************************************************************
    * Method Name  : getCloseOutTask
    * Description  : This method is used to get  closeout task 
    * Inputs       : -
    * Author       : Atul
    * Created On   : 26/05/2021
    * Modification Log: 
    *******************************************************************************/      
    getCloseOutTask(){
        
        let paramMap = {};
        paramMap['closeOutTaskId'] = this.selectedCloseOutTaskId;
        this.executeAction(getCloseOutTaskDetails, paramMap, (response) => {
           
            this.selectedCloseoutTaskRecord = response.masterCloseoutTask;
            this.selectCloseoutTaskName = this.selectedCloseoutTaskRecord.Name;
            this.selectedIncidentName = this.selectedCloseoutTaskRecord.Incident__r.Name;
            this.selectedSubRecipentName = this.selectedCloseoutTaskRecord.Subrecipient_Name__r.Name;
           this.getSelectedProjectDetails();
        });
    }

    /*****************************************************************************
    * Method Name  : getSelectedProjectDetails
    * Description  : This method is to merge button is visible or not
    * Inputs       : -
    * Author       : Atul
    * Created On   : 26/05/2021
    * Modification Log: 
    *******************************************************************************/     
    getSelectedProjectDetails(){
        // todo execute action...
        let paramMap = {};
        paramMap['incidentName'] = this.selectedCloseoutTaskRecord.Incident__c;
        paramMap['subRecipentName'] = this.selectedCloseoutTaskRecord.Subrecipient_Name__c;
        paramMap['closeOutTaskId'] = this.selectedCloseoutTaskRecord.Id;
        this.executeAction(getProjectsAssociatedCloseOutTask, paramMap, (response) => {
            
            this.selectedProjectData = response;
            this.columns = columns;
            if(response.length > 0){
            this.isMergeButtonDisabled = false;
            }else{
                this.isMergeButtonDisabled = true;
            }
            
        });   
    }

    /*****************************************************************************
    * Method Name  : mergeCloseOutTask
    * Description  : This function  is to once we click on merge button then closeout task is merge in master
    * Inputs       : -
    * Author       : Atul
    * Created On   : 26/05/2021
    * Modification Log: 
    *******************************************************************************/    
    mergeCloseOutTask(){
        this.showLoader = true;
        // todo execute Action..
        let paramMap = {};
        paramMap['selectedCloseoutTaskId'] = this.selectedCloseoutTaskRecord.Id;
        paramMap['masterCloseoutTaskId'] = this.closeoutTaskRecord.Id;
        this.executeAction(mergeSelectedCloseOutTask, paramMap, (response) =>{
            console.log('Result Block ===='+response);
            this.showSuccessNotification('Success', 'Closeout task merged successfully!');
            this.handleCancelClick();
        });
    }

    /*****************************************************************************
    * Method Name  : handleCancelClick
    * Description  : This function  is to once we click on cancel button then it redirect to 
    *                closeout task page
    * Inputs       : -
    * Author       : Atul
    * Created On   : 26/05/2021
    * Modification Log: 
    *******************************************************************************/    
   
    handleCancelClick() {
        const value = this.selectCloseoutTaskName;
        const closeclickedevt = new CustomEvent('closeclicked', {
            detail: {value},
        });

         // Fire the custom event
         this.dispatchEvent(closeclickedevt); 
    }

    /*****************************************************************************
    * Method Name  : handleButtonCancelClick
    * Description  : This function  is to once we click on cancel button then it redirect to 
    *                closeout task page
    * Inputs       : -
    * Author       : Atul
    * Created On   : 26/05/2021
    * Modification Log: 
    *******************************************************************************/    

    handleButtonCancelClick() {       
        const closeclickedevt = new CustomEvent('closeclicked', {
            detail: { close },
        });

         // Fire the custom event
         this.dispatchEvent(closeclickedevt); 
    }
    

}