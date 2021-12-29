/**
* LWC Name   : paCloseoutTaskRemoveProject
* Description  : This LWC is used to remove project from  closeout Task. 
                 On close out list view once you click on Remove project we have override lwc component to remove project  closeout task.
 *               You can choose to use existing Closeout Task (matching with selected Incident, Subrecipient & Program) to be remove project from master and added to in existing by selecting from lookup.
                 Once you click on update then project will be removed.
* Author       : Digamber
* Created On   : 26/05/2021
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Digamber             26/05/2021       Initial Implementation
*/
import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Utility from 'c/utility';
import apexSearchCloseoutTask from '@salesforce/apex/PACloseoutTaskRemoveProjectController.apexSearchCloseoutTask';
import apexSearchTargetCloseoutTask from '@salesforce/apex/PACloseoutTaskRemoveProjectController.apexSearchTargetCloseoutTask';
import getProjectsForCR from '@salesforce/apex/PACloseoutTaskRemoveProjectController.getProjectsForCR';
import removeProjects from '@salesforce/apex/PACloseoutTaskRemoveProjectController.removeProjects';
import isFullAccessCloseoutTaskUserWire from '@salesforce/apex/PACloseoutTaskRemoveProjectController.isFullAccessCloseoutTaskUserWire';

export default class paCloseoutTaskRemoveProject extends Utility{

    //closeoutTaskRecordId
    @api recordId;

    //store closeout task id
    selectedCloseoutTaskId;
    preSelectedCloseoutTask = [];

    //store target closeout task id
    selectedTargetCloseoutTaskId;
    preSelectedTargetCloseoutTask = [];

    //Used to store project type picklist value
    selectedProjectType = 'All Projects';

    //Used to store project table data
    projectData = [];
    
    //lookup related variables
	isMultiEntry = false;
	loadDataOnLookup = false;
    loadDataOnInit = false;

    //Store small/large project selections
    selectedSmallProjects = [];
    selectedLargeProjects = [];

    //store wire result
    @track wiredResult = [];

    initData(){
        this.programName = 'Public Assistance';
        this.className = 'PACloseoutTaskRemoveProjectController';
    }

    /*****************************************************************************
    * Method Name  : getCloseoutTaskWire
    * Description  : This function is used to get detials of selected closeout task for remove the project
    * Inputs       :-
    * Author       : Digamber
    * Created On   : 26/05/2021
    * Modification Log: 
    *******************************************************************************/
    @wire(isFullAccessCloseoutTaskUserWire, {closeoutTaskId: '$recordId'}) 
    getCloseoutTaskWire(result){
        this.wiredResult = result;    
        if(result.data){
            this.selectedCloseoutTaskId = this.recordId;
            this.preSelectedCloseoutTask = [{
                id:this.recordId,
                sObjectType:'Closeout_Task__c',
                title:result.data.closeOutTaskName,
                icon:'standard:account',
                subtitle:''
            }];               

                //Load project table
                getProjectsForCR({selectedCloseoutTaskId: this.selectedCloseoutTaskId})
                .then((results) => {

                    this.projectData = results;
                    for(let i=0; i<this.projectData.length; i++){
                        this.projectData[i].CloseoutRequest = this.projectData[i].CloseOuts__r[0].Closeout_Request__r.Name;
                    }

                })
                .catch((error) => {
                    this.error('Lookup Error', 'An error occured while searching with the lookup field.');
                    this.errors = [error];
                });    
        }else{
            this.error = result.error;
            this.data = undefined;
        }    
    }
    //*********************- this getter method is used to get project type --***    
    get projectTypeOptions() {
        return [
            { label: 'All Projects', value: 'All Projects' },
            { label: 'Small Projects', value: 'Small Projects' },
            { label: 'Large Projects', value: 'Large Projects' }
            
        ];
    }

    //*********************- this getter is used to display the coloum name--**
    get columns() {
        return [    
                {
                    label: 'Closeout Request',
                    fieldName: 'CloseoutRequest'
                },
                {
                    label: 'Project Name',
                    fieldName: 'Name'
                },
                {
                    label: 'Project Number',
                    fieldName: 'Project_Number__c'
                },
                {
                    label: 'Damage Category',
                    fieldName: 'Damage_Category__c'
                },
                {
                    label: 'Large Project',
                    fieldName: 'IsLargeProject__c',
                    type: 'boolean'
                },
                {
                    label: 'Total Project Award ($)',
                    fieldName: 'Total_Project_Award__c',
                    type: 'currency',
                    cellAttributes: { alignment: 'left' }
                }
       ];
    }

    /*****************************************************************************
    * Method Name  : handleCloseoutTaskSearch
    * Description  : This function is used to search the closeout task
    * Inputs       :-
    * Author       : Digamber
    * Created On   : 26/05/2021
    * Modification Log: 
    *******************************************************************************/  
    handleCloseoutTaskSearch(event) {

        apexSearchCloseoutTask({ searchTerm: event.detail.searchTerm})
         .then((results) => {
             this.template.querySelector('[data-lookup="Closeout_Task__c"]').setSearchResults(results);
         })
         .catch((error) => {
             this.error('Lookup Error', 'An error occured while searching with the lookup field.');
             
             this.errors = [error];
         });
     }

    /*****************************************************************************
    * Method Name  : handleCloseoutTaskChange
    * Description  : This function is used to display the clsoeout task which is selected
    * Inputs       :-
    * Author       : Digamber
    * Created On   : 26/05/2021
    * Modification Log: 
    *******************************************************************************/  
     handleCloseoutTaskChange(response) {
        this.selectedCloseoutTaskId = undefined;
        if(response.detail !=null && response.detail.selectedItem.id != undefined) {
            this.selectedCloseoutTaskId = response.detail.selectedItem.id;
           
            getProjectsForCR({selectedCloseoutTaskId: this.selectedCloseoutTaskId})
            .then((results) => {
                
                this.projectData = results;
                for(let i=0; i<this.projectData.length; i++){
                    this.projectData[i].CloseoutRequest = this.projectData[i].CloseOuts__r[0].Closeout_Request__r.Name;
                }
            })
            .catch((error) => {
                this.error('Lookup Error', 'An error occured while searching with the lookup field.');
               
                this.errors = [error];
            });
        }
        else{
                this.projectData = [];
                this.preSelectedTargetCloseoutTask = [];
        }
    }

    /*****************************************************************************
    * Method Name  : handleTargetCloseoutTaskSearch
    * Description  : This function is used to search the target closeout task
    * Inputs       :-
    * Author       : Digamber
    * Created On   : 26/05/2021
    * Modification Log: 
    *******************************************************************************/ 
    handleTargetCloseoutTaskSearch(event) {

        apexSearchTargetCloseoutTask({ searchTerm: event.detail.searchTerm, selectedCloseoutTaskId: this.selectedCloseoutTaskId})
         .then((results) => {
             this.template.querySelector('[data-lookup="Closeout_Task__c2"]').setSearchResults(results);
         })
         .catch((error) => {
             this.error('Lookup Error', 'An error occured while searching with the lookup field.');
             this.errors = [error];
         });
     }

    /*****************************************************************************
    * Method Name  : handleTargetCloseoutTaskChange
    * Description  : This function is used to display the selected target closeout task
    * Inputs       :-
    * Author       : Digamber
    * Created On   : 26/05/2021
    * Modification Log: 
    *******************************************************************************/ 
     handleTargetCloseoutTaskChange(response) {
        this.selectedTargetCloseoutTaskId = undefined;
        if(response.detail !=null && response.detail.selectedItem.id != undefined) {
            this.selectedTargetCloseoutTaskId = response.detail.selectedItem.id;
        }
    }

    /*******---This getter is used to display the project as per project type--****/
    get projectsToDisplay() {
        if(this.selectedProjectType == 'Small Projects' && this.projectData.length>0) {
            let projectToReturn = [];
            for(let i=0; i<this.projectData.length; i++) {
                if(this.projectData[i].IsLargeProject__c != true) {
                    projectToReturn.push(this.projectData[i]);
                }
            }
            return projectToReturn;
        } else if(this.selectedProjectType == 'Large Projects' && this.projectData.length>0) {
            let projectToReturn = [];
            for(let i=0; i<this.projectData.length; i++) {
                if(this.projectData[i].IsLargeProject__c == true) {
                    projectToReturn.push(this.projectData[i]);
                }
            }
            return projectToReturn;
        }
        else if(this.selectedProjectType == 'RESET'){
            let projectToReturn = [];
            return projectToReturn;
        }

        return this.projectData;
    }

    /*****************************************************************************
    * Method Name  : handleProjectTypeChange
    * Description  : This function is used to select the project type
    * Inputs       :-
    * Author       : Digamber
    * Created On   : 26/05/2021
    * Modification Log: 
    *******************************************************************************/ 
    handleProjectTypeChange(event) {
        this.selectedProjectType = event.detail.value;
    }
   
    /*****************************************************************************
    * Method Name  : setSelectedProject
    * Description  : This function is used to select the project as per project type
    * Inputs       :-
    * Author       : Digamber
    * Created On   : 26/05/2021
    * Modification Log: 
    *******************************************************************************/    
    setSelectedProject(event) {

        const selectedRows = event.detail.selectedRows;

        if(this.selectedProjectType == 'Small Projects') {
            this.selectedSmallProjects = [];
            for (let i = 0; i < selectedRows.length; i++) {
                this.selectedSmallProjects.push(selectedRows[i]);
            }
        } else if(this.selectedProjectType == 'Large Projects') {
            this.selectedLargeProjects = [];
            for (let i = 0; i < selectedRows.length; i++) {
                this.selectedLargeProjects.push(selectedRows[i]);
            }
        } else {
            this.selectedSmallProjects = [];
            this.selectedLargeProjects = [];
            for (let i = 0; i < selectedRows.length; i++) {
                if(selectedRows[i].IsLargeProject__c == true) {
                    this.selectedLargeProjects.push(selectedRows[i]);
                } else {
                    this.selectedSmallProjects.push(selectedRows[i]);
                }
            }
        }
    }

    /*********-- This getter is used to display the project in tbale as per slecetd project taype--**/
    get getSelectedRows() {
        let recordsToReturn = [];
        if(this.selectedProjectType == 'Small Projects') {
            recordsToReturn = this.selectedSmallProjects;
        } else if(this.selectedProjectType == 'Large Projects') {
            recordsToReturn = this.selectedLargeProjects;
        } else {
            recordsToReturn = this.selectedSmallProjects.concat(this.selectedLargeProjects);
        }
        let idsToReturn = [];
        for(let i=0; i < recordsToReturn.length; i++) {
            idsToReturn.push(recordsToReturn[i].Id);
        }
        return idsToReturn;
    }
   
    /*****************************************************************************
    * Method Name  : handleSubmit
    * Description  : This function is used to Remove the project or added project 
    *                from closeout task and also check the validation before remove project 
    *                from closeout task or added project in existing closeout task
    * Author       : Digamber
    * Created On   : 26/05/2021
    * Modification Log: 
    *******************************************************************************/    
    handleSubmit(event) {
        this.showLoader = true;
        let selectedProjects = this.selectedSmallProjects.concat(this.selectedLargeProjects);      
        let smallProjectCountInSelectedProjects = 0;
        let smallProjectCountInAllProjects = 0;
        let selectedSmallProjectsId = []; 

        //Get count of small projects in selected projects
        for (let i = 0; i < selectedProjects.length; i++) {
            if(selectedProjects[i].IsLargeProject__c == false ){
                selectedSmallProjectsId.push(selectedProjects[i].Id);
                smallProjectCountInSelectedProjects++;
            }
        }
        //Get count of small projects in all projects
        for (let i = 0; i < this.projectData.length; i++) {
            if(this.projectData[i].IsLargeProject__c == false ){
                smallProjectCountInAllProjects++;
            }
        }
        //Validate either all or none small project selected
        if(smallProjectCountInSelectedProjects>0 && smallProjectCountInSelectedProjects != smallProjectCountInAllProjects) {
                this.showErrorNotification('Error', 'Please select all small project!');
                    return;
        }
        
        
            
            removeProjects({ selectedSmallProjectsIdList: selectedSmallProjectsId, selectedLargeProjectCount:this.selectedLargeProjects.length, selectedCloseoutTaskId: this.selectedCloseoutTaskId, selectedTargetCloseoutTaskId: this.selectedTargetCloseoutTaskId, selectedAllProjects: selectedProjects})
                    .then((results) => {
                        
                        if(!results){
                            this.showErrorNotification('Error', 'You cannot add large projects when there is NSPO appeal in the Closeout Task');
                            return;
                        }else{
                            this.showSuccessNotification('Success', 'Your request has been submitted successfully!');
                            
                            if(this.selectedTargetCloseoutTaskId){
                                //navigate to target closeout task	detail page
                                this.navigateRecordViewPage(this.selectedTargetCloseoutTaskId);
                            }
                            //close activities
                            this.handleCancelClick();
                            
                        }
                    })
                    .catch((error) => {
                        this.error('Lookup Error', 'An error occured while searching with the lookup field.');
                        this.errors = [error];
                    });
    }

    /*******--This Getter is uesed to disable or enable button of submit--**********/
    get isButtonDisabled() {
        let selectedProjects = this.selectedSmallProjects.concat(this.selectedLargeProjects);
        if(this.selectedCloseoutTaskId && selectedProjects.length>0){
            return false;
        }
        return true;
    }

    /*****************************************************************************
    * Method Name  : handleClear
    * Description  : This function is ised to clear the UI
    * Author       : Digamber
    * Created On   : 26/05/2021
    * Modification Log: 
    *******************************************************************************/    
   
    handleClear(event) {
        this.refreshScreen();
    }

   /*****************************************************************************
    * Method Name  : closeTab
    * Description  : This function is used to close the remove project tab
    * Author       : Digamber
    * Created On   : 26/05/2021
    * Modification Log: 
    *******************************************************************************/    
    closeTab(){
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    /*****************************************************************************
    * Method Name  : handleCancelClick
    * Description  : This function is used cancel button function 
    * Author       : Digamber
    * Created On   : 26/05/2021
    * Modification Log: 
    *******************************************************************************/    
    handleCancelClick() {
        //const value = this.selectCloseoutTaskName;
        const closeclickedevt = new CustomEvent('closeclicked');

         // Fire the custom event
         this.dispatchEvent(closeclickedevt); 
    }
}