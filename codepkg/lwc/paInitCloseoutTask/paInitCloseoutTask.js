/**
* Class Name   : PaInitCloseoutTask
* Description  : This class is used to create closeout Task. 
                 On close out list view once you click on new we have override lwc component to create closeout task.
 *               On this page, You can search on Incident or Sub recipient. *              
                 You can choose to use existing Closeout Task (matching with selected Incident, Subrecipient & Program) to be reused by selecting from lookup.
                 Once you click on submit close out task will get created.
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
import getProjectsForSR from '@salesforce/apex/paInitCloseoutTaskController.getProjectsForSR';
import initCloseoutTask from '@salesforce/apex/paInitCloseoutTaskController.initCloseoutTask';
import apexSearchIncident from '@salesforce/apex/paInitCloseoutTaskController.apexSearchIncident';
import apexSearchAgency from '@salesforce/apex/paInitCloseoutTaskController.apexSearchAgency';
import apexSearchCloseoutTask from '@salesforce/apex/paInitCloseoutTaskController.apexSearchCloseoutTask';
import apexCheckNSPO from '@salesforce/apex/paInitCloseoutTaskController.apexCheckNSPO';
import Utility from 'c/utility';

/******-------------- Program Type ----------------************/
const CONSTANT_PROGRAM_TYPE = {
    PA_PROGRAM_FEDERAL : 'PA - Federal',
    PA_PROGRAM_CDAA : 'CDAA (State Funding)',
    PA_PROGRAM_FMAG : 'PA - FMAG'
}

export default class PaInitCloseoutTask extends Utility {

    //used to store lookup fields
	selectedSRRecordId;
	selectedIncidentRecordId;
    selectedCloseoutTaskId;
    preSelectedTargetCloseoutTask = [];
    //Used to store project type picklist value
    selectedProjectType = 'All Projects';
    documentselectedValue;
   
    //Used to store project table data
    projectData;
    showProjectTable = false;
    @track showSearchButton = false;
    
    //lookup related variables
	isMultiEntry = false;
	loadDataOnLookup = false;

    selectedSmallProjects = [];
    selectedLargeProjects = [];   
    @track programType;
    
    /******-------------- getSelectedRow from ui---------------************/
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

    //************************Display the project on basis of all or large or Small******************* */
    get projectsToDisplay() {
        if(this.selectedProjectType == 'Small Projects') {
            let projectToReturn = [];
            for(let i=0; i<this.projectData.length; i++) {
                if(this.projectData[i].IsLargeProject__c != true) {
                    projectToReturn.push(this.projectData[i]);
                }
            }
            return projectToReturn;
        } else if(this.selectedProjectType == 'Large Projects') {
            let projectToReturn = [];
            for(let i=0; i<this.projectData.length; i++) {
                if(this.projectData[i].IsLargeProject__c == true) {
                    projectToReturn.push(this.projectData[i]);
                }
            }
            return projectToReturn;
        }
        return this.projectData;
    }

    /*****************************************************************************
    * Method Name  : getSelectedProject
    * Description  : This function is use to -add the project in small project and large project 
                     on basis of project size
    * Author       : Digamber
    * Created On   : 26/05/2021
    * Modification Log: 
    *******************************************************************************/    
    getSelectedProject(event) {
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

    get options() {
        return [
            { label: 'P.4', value: 'P.4' },
            { label: 'CDAA', value: 'CDAA' },
        ];
    }

    initData(){
        this.programName = 'Public Assistance';
        this.className = 'paInitCloseoutTaskController';
    }

    /*********************** FMAG project type selected  ******************* */
    get isPaFmagSelected(){
        if(this.programType == CONSTANT_PROGRAM_TYPE.PA_PROGRAM_FMAG) return true;
        return false;
    }

     /*********************** CDAA project type selected  ******************* */
    get isPaCDAASelected(){
        if(this.programType == CONSTANT_PROGRAM_TYPE.PA_PROGRAM_CDAA) return true;
        return false;
    }

    /*********************** CDAA project type selected  ******************* */
    get isPaFederalSelected(){
        if(this.programType == CONSTANT_PROGRAM_TYPE.PA_PROGRAM_FEDERAL) return true;
        return false;
    }

    /*****************************************************************************
    * Method Name  : handleAccountSearch
    * Description  : This function is use to -Searches Incidents with Users have project access
    * Author       : Digamber
    * Created On   : 26/05/2021
    * Modification Log: 
    *******************************************************************************/ 
    handleAccountSearch(event) {
        apexSearchAgency({ searchTerm: event.detail.searchTerm, selectedIncidentId: this.selectedIncidentRecordId})
        .then((results) => {
            this.template.querySelector('[data-lookup="Account"]').setSearchResults(results);
        })
        .catch((error) => {
            this.error('Lookup Error', 'An error occured while searching with the lookup field.');
            this.errors = [error];
        });
    }

    /*****************************************************************************
    * Method Name  : handleSRChange
    * Description  : This function is use to -This function is used to select the Subrecipient as per user 
    * Author       : Digamber
    * Created On   : 26/05/2021
    * Modification Log: 
    *******************************************************************************/   
    handleSRChange(response) {
        this.selectedSRRecordId = undefined;
        if(response.detail !=null && response.detail.selectedItem.id != undefined) {
            this.selectedSRRecordId = response.detail.selectedItem.id;
        }else{
            this.projectData = [];
            this.preSelectedTargetCloseoutTask = [];    
            this.showProjectTable = false;       
        }        
    }

   /*****************************************************************************
    * Method Name  : handleIncidentSearch
    * Description  : This function is use to -Searches Incidents with Users have project access
    * Author       : Digamber
    * Created On   : 26/05/2021
    * Modification Log: 
    *******************************************************************************/  
    handleIncidentSearch(event) {

        apexSearchIncident({ searchTerm: event.detail.searchTerm})
        .then((results) => {
            this.template.querySelector('[data-lookup="Incident__c"]').setSearchResults(results);
        })
        .catch((error) => {
            this.error('Lookup Error', 'An error occured while searching with the lookup field.');
            this.errors = [error];
        });
    }

    /*****************************************************************************
    * Method Name  : handleIncidentChange
    * Description  : This function is use to -select the program type as per incident selected 
    * Author       : Digamber
    * Created On   : 26/05/2021
    * Modification Log: 
    *******************************************************************************/  
    handleIncidentChange(response) {
        this.selectedIncidentRecordId = undefined;     
            
        if(response.detail !=null && response.detail.selectedItem.id != undefined) {
            this.selectedIncidentRecordId = response.detail.selectedItem.sObject.Incident_Name__r.Id;
            if(response.detail.selectedItem.sObject.Program_Name__r.Name == CONSTANT_PROGRAM_TYPE.PA_PROGRAM_FEDERAL){
                this.programType =  CONSTANT_PROGRAM_TYPE.PA_PROGRAM_FEDERAL;
                this.showProjectTable = false;  
                this.projectData = undefined;
            }else if(response.detail.selectedItem.sObject.Program_Name__r.Name == CONSTANT_PROGRAM_TYPE.PA_PROGRAM_CDAA){
                this.programType =  CONSTANT_PROGRAM_TYPE.PA_PROGRAM_CDAA;
                this.showProjectTable = false;  
                this.projectData = undefined;
            }else if(response.detail.selectedItem.sObject.Program_Name__r.Name == CONSTANT_PROGRAM_TYPE.PA_PROGRAM_FMAG){
                this.programType =  CONSTANT_PROGRAM_TYPE.PA_PROGRAM_FMAG;
                this.showProjectTable = false; 
                this.projectData = undefined; 
            }
            
        }else{
            this.projectData = [];     
            this.preSelectedTargetCloseoutTask = [];   
            this.showProjectTable = false;     
        }
    }

    /*****************************************************************************
    * Method Name  : handleCloseoutTaskSearch
    * Description  : This function is use to -search the closeout task which are existing (Target)
    * Author       : Digamber
    * Created On   : 26/05/2021
    * Modification Log: 
    *******************************************************************************/    
    handleCloseoutTaskSearch(event) {

       apexSearchCloseoutTask({ searchTerm: event.detail.searchTerm, selectedSRRecordId: this.selectedSRRecordId, selectedIncidentRecordId: this.selectedIncidentRecordId, selectedProgramName: this.programType})
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
    * Description  : This function is use to -select the closeout task
    * Author       : Digamber
    * Created On   : 26/05/2021
    * Modification Log: 
    *******************************************************************************/    
   
    handleCloseoutTaskChange(response) {
        this.selectedCloseoutTaskId = undefined;
        if(response.detail !=null && response.detail.selectedItem.id != undefined) {
            this.selectedCloseoutTaskId = response.detail.selectedItem.id;
        }
    }

    /*****************************************************************************
    * Method Name  : handleSearch
    * Description  : This function is use to -get the project list as per incident and subrecipent 
    *                whoes closeout task not generated
    * Author       : Digamber
    * Created On   : 26/05/2021
    * Modification Log: 
    *******************************************************************************/   
    handleSearch(event) {
       let paramMap = {};//getProjectsForSR
        paramMap['selectedSRRecordId'] = this.selectedSRRecordId;
        paramMap['selectedIncidentRecordId'] = this.selectedIncidentRecordId;
        paramMap['selectedProgramName'] = this.programType;
        
        if(this.selectedIncidentRecordId == undefined ||  this.selectedSRRecordId == undefined){
            this.showErrorNotification('Error', 'Please select relevant Subrecipient and Incident');
            return;
        }
        
        this.executeAction(getProjectsForSR, paramMap, (response) => {
           
            this.projectData = response;
            if(this.projectData.length==0){
                this.showErrorNotification('Error', 'No project found');
                    return;
            }

            for(let i=0; i<this.projectData.length; i++){

               if(this.projectData[i].CloseOuts__r[0].Closeout_Request__r != undefined && this.projectData[i].CloseOuts__r[0].Closeout_Request__r != null) {
                   
                this.projectData[i].CloseoutRequest = this.projectData[i].CloseOuts__r[0].Closeout_Request__r.Name;
            }
            }

            this.showProjectTable = true;
            
        });
        
    }

    /*****************************************************************************
    * Method Name  :  handleClear
    * Description  :  this function is used to clear the screen once we click on clear button  
    * Inputs       : -
    * Author       : Digamber
    * Created On   : 26/05/2021
    * Modification Log: 
    *******************************************************************************/
    handleClear(event) {
        this.refreshScreen();
    }

    /************************this function is used to handle the project type-******************* */
    handleProjectTypeChange(event) {
        this.selectedProjectType = event.detail.value;
    }

    /*****************************************************************************
    * Method Name  : columns
    * Description  : This function is used to display the column name in table on UI
    *                
    * Inputs       : -
    * Author       : Digamber
    * Created On   : 26/05/2021
    * Modification Log: 
    *******************************************************************************/  
    
    get columns() {
    if(this.programType == CONSTANT_PROGRAM_TYPE.PA_PROGRAM_FEDERAL){
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
        }else if(this.programType == CONSTANT_PROGRAM_TYPE.PA_PROGRAM_CDAA){

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
                    label: 'Total Project Award ($)',
                    fieldName: 'Total_Project_Award__c',
                    type: 'currency',
                    cellAttributes: { alignment: 'left' }
                }

           ];

        }else if(this.programType == CONSTANT_PROGRAM_TYPE.PA_PROGRAM_FMAG){

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
                   label: 'Total Project Award ($)',
                   fieldName: 'Total_Project_Award__c',
                   type: 'currency',
                   cellAttributes: { alignment: 'left' }
                }

            ];

        }
    }

    /***************submit button is Enable when incident and subrecipent selected  and get project Data
     and at list one project selected and one file uploaded for program type Federal and CDAA* 
     if program type FMAG then only check if project and at list  one project selected**************/

    get isButtonDisabled() {
        let selectedProjects = this.selectedSmallProjects.concat(this.selectedLargeProjects);
        let idsToReturn = [];
        for(let i=0; i < selectedProjects.length; i++) {
            idsToReturn.push(selectedProjects[i].Id);
        }
        if(this.selectedSRRecordId && this.selectedIncidentRecordId && this.projectData
                    && idsToReturn.length > 0 ) {
                        return false;
        }
        return true;
    }

    /*****************************************************************************
    * Method Name  :  handleSubmit
    * Description  :  this function is used to create the closeout task  
    * Inputs       : -
    * Author       : Digamber
    * Created On   : 26/05/2021
    * Modification Log: 
    *******************************************************************************/  
    handleSubmit(event) {
        
        let selectedProjects = this.selectedSmallProjects.concat(this.selectedLargeProjects);
        let idsToReturn = [];
        let selectedSmallProjectsId = [];
        
        for(let i=0; i < selectedProjects.length; i++) {
            idsToReturn.push(selectedProjects[i].Id);
            if(!selectedProjects[i].IsLargeProject__c){
                selectedSmallProjectsId.push(selectedProjects[i].Id);
            }
        }
       
        if(idsToReturn == 0) {
            return;
        }
        
        //CDAA Closeout Task
        if(this.programType == CONSTANT_PROGRAM_TYPE.PA_PROGRAM_CDAA || this.programType == CONSTANT_PROGRAM_TYPE.PA_PROGRAM_FMAG){
           
            if(selectedProjects.length != this.projectData.length){
                this.showErrorNotification('Error', "Please select all projects");
                return;  
            }
            let paramMap = {};
            console.log("*** initCloseoutTask()");
            paramMap['selectedProjectIdLst'] = idsToReturn;
            paramMap['selectedSRRecordId'] = this.selectedSRRecordId;
            paramMap['selectedIncidentRecordId'] = this.selectedIncidentRecordId;
            paramMap['selectedTargetCloseoutTaskId'] = this.selectedCloseoutTaskId;
            paramMap['selectedProgramName'] = this.programType;

           this.executeAction(initCloseoutTask, paramMap, (response) => {
                    this.showLoader = true;
                    this.showSuccessNotification('Success', 'Your request has been submitted successfully!');
                   
                    
                    //close current page
                    this.handleClose();
                    //navigate to closeout task	detail page
                    this. openCloseoutTaskTab(response);
                    
            });          
                
        }
        //FEDERAL Closeout Task
       if (this.programType == CONSTANT_PROGRAM_TYPE.PA_PROGRAM_FEDERAL) {

            if(this.selectedSmallProjects.length>0) {
                for (let i = 0; i < this.projectData.length; i++) {
                    if(this.projectData[i].IsLargeProject__c == false && idsToReturn.includes(this.projectData[i].Id) == false){
                        this.showErrorNotification('Error', 'Please select all small projects');
                        return;
                    }
                }
            }
            
                //Confirm no large project is added to NSPO Closeout Tasks 
                let paramMap = {};
                paramMap['selectedSmallProjectsIdList'] = selectedSmallProjectsId;
                paramMap['selectedLargeProjectCount'] = this.selectedLargeProjects.length;
                paramMap['selectedCloseoutTaskId'] = this.selectedCloseoutTaskId;               
             

                this.executeAction(apexCheckNSPO, paramMap, (response) => {

                    if(response){
                        this.showErrorNotification('Error', "You cannot add large projects when there is NSPO appeal in the Closeout Task");
                        return;     
                } else {
                        let paramMap = {};
                   
                        paramMap['selectedProjectIdLst'] = idsToReturn;
                        paramMap['selectedSRRecordId'] = this.selectedSRRecordId;
                        paramMap['selectedIncidentRecordId'] = this.selectedIncidentRecordId;
                        paramMap['selectedTargetCloseoutTaskId'] = this.selectedCloseoutTaskId;
                        paramMap['selectedProgramName'] = this.programType;
                        this.executeAction(initCloseoutTask, paramMap, (response) => {
                        this.showLoader = true;
                            this.showSuccessNotification('Success', 'Your request has been submitted successfully!');

                        this.handleClose();
                            //navigate to closeout task	detail page
                       // this.navigateRecordViewPage(response);
                        this. openCloseoutTaskTab(response);

                        });
                    } 
                });
        
            }
    }

    /*****************************************************************************
    * Method Name  : getUniqueList
    * Description  : This function is use to -get the unique list of project
    * Author       : Dayal
    * Created On   : 26/05/2021
    * Modification Log: 
    *******************************************************************************/   
    getUniqueList(arrayList) {
        let values = [];
        for(let i = 0; i < arrayList.length; i++){
            if(values.includes(arrayList[i]) == false) {
                values.push(arrayList[i]);
            }
        }
        return values;
    }

    //*********************** show the project type option  *****************
    get projectTypeOptions() {
        return [
            { label: 'All Projects', value: 'All Projects' },
            { label: 'Small Projects', value: 'Small Projects' },
            { label: 'Large Projects', value: 'Large Projects' }
            
        ];
    }

    //*********************** it return true if incident and subrecipent not selected *****************
    get disableCloseoutTaskLookup(){
        if(this.selectedSRRecordId && this.selectedIncidentRecordId){
            return false;
        }
        return true;
    }

     /*****************************************************************************
    * Method Name  : handleClose
    * Description  : This function is use to close the current Active Tab 
    * Author       : Dayal
    * Created On   : 26/05/2021
    * Modification Log: 
    *******************************************************************************/ 
    handleClose(){ 
       
        const closeclickedevt = new CustomEvent('closeclicked');
        // Fire the custom event
         this.dispatchEvent(closeclickedevt); 
    }
  
    /*****************************************************************************
    * Method Name  : openCloseoutRequestTab
    * Description  : This function is used to open the current created closeout request 
    * Author       : Dayal
    * Created On   : 26/05/2021
    * Modification Log: 
    *******************************************************************************/ 

    openCloseoutTaskTab(closeoutTaskId) {        
        const closeclickedevt = new CustomEvent('openCloseoutTaskTab', {
            detail: { closeoutTaskId }
        });
         // Fire the custom event
        this.dispatchEvent(closeclickedevt); 
}
}