/*
 *LWC Name      : PaRequestProjectCloseout
 * Description  : This LWC used to create closeout Request. On close out list view of poratl once you click
 *                on new button we have override lwc component to create closeout Request.
 *                On community Portal page, You can search on Incident and Sub recipient is autopopulated or 
 *                in internal portal  You can search both Incident and Sub recipient.
 *                Once you select incident then file upload option is visible to as per incident selected
 *                Post uplod files  you will get Projects list in the from of table for creating the closeout 
 *                request, whose closeout is not initiated.
 *               
 * Author       : Dayal
 * Created On   : 28/05/2021
 * Modification Log:  
 * -----------------------------------------------------------------------------------------------------------------
 * Developer             Date             Description 
 * -----------------------------------------------------------------------------------------------------------------
 * Dayal             28/05/2021       Initial Implementation
**/

import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getProjectsForSR from '@salesforce/apex/PA_RequestCloseoutController.getProjectsForSR';
import initiateCloseout from '@salesforce/apex/PA_RequestCloseoutController.initiateCloseout';
import finalizeClosoeutRequest from '@salesforce/apex/PA_RequestCloseoutController.finalizeClosoeutRequest';
import apexSearchIncident from '@salesforce/apex/PA_RequestCloseoutController.apexSearchIncident';
import apexSearchAgency from '@salesforce/apex/PA_RequestCloseoutController.apexSearchAgency';
import userSubrecipientDetails from '@salesforce/apex/PA_RequestCloseoutController.getUserSubrecipientDetails';
import getReviewMetadata from '@salesforce/apex/PA_RequestCloseoutController.getReviewMetadata';
import isCurrentUserPortalUser from '@salesforce/apex/PA_RequestCloseoutController.isCurrentUserPortal';
import getCloseoutRequestDetailsOnCommunity from '@salesforce/apex/PA_RequestCloseoutController.getCloseoutRequestDetailsOnCommunity';

import Utility from 'c/utility';

const actions = [
    { label: 'Action', name: 'Review' },
];

/******-------------- Program Type ----------------************/
const CONSTANT_PROGRAM_TYPE = {
    PA_PROGRAM_FEDERAL : 'PA - Federal',
    PA_PROGRAM_CDAA : 'CDAA (State Funding)',
    PA_PROGRAM_FMAG : 'PA - FMAG'
}

export default class PaRequestProjectCloseout extends Utility {
    @api recordId;

	//used to store lookup fields
	@track selectedSRRecordId;
	selectedIncidentRecordId;
	@track isPortalUser = false;

    //Used to store project type picklist value
    selectedProjectType = 'All Projects';

	@track doYouSignedP4 = false;

	@track selectedProjectIdLst =[];
	@track selectedProjectDetails =[];
    @track subRecipientName;
    @track isLargeProjectSelect;
    @track isSmallProjectSelect;
    @track isReviewSeleted = false;
    @track projectId;
    @track checkoutResponseJson;
    @track closeoutCheckListArray = [];
    @track isSaveConfirmationShow = false;   
    @track costShareEligibilityType;  
    @track showProjectTable = false;
    @track selectedChecklistArray = [];    
	//------------Document Fields------------------
	@track uploadedFiles = [];

    selectedSmallProjects = [];
    selectedLargeProjects = [];   
    saveConfirmationLabe = 'It looks like you are about to create an NSPO Appeal, are you sure you want to create NSPO Appeal?'
    reviewMetaDataList = [];    
    readOnly = true;
    documentselectedValue;
    programType;
    radioButtonDisable = false;   

	//-------------lookup related variables------------------
	isMultiEntry = false;
	loadDataOnLookup = false;     
    /***************--------------Data Table Fields==----- ***************/
    showFMG = true;
	projectData;
    authorizedAgent; 

   @track incidentName;
   @track SignedP4 ='no'; 

    /*****************************************************************************
    * Method Name  : initData
    * Description  : this method run when page is load   
    * Inputs       : -
    * Author       : Dayal
    * Created On   : 16/05/2021
    * Modification Log: 
    *******************************************************************************/ 
	initData(){
	    this.programName = 'Public Assistance';
	    this.className = 'PA_RequestCloseoutController';
        this.executeAction(isCurrentUserPortalUser, {}, (response) => {
            this.isPortalUser = response;
        });

        this.recordId = this.getURLParameter('id');

        //tido:- add one more condition portal user login or not in if 
        if(this.recordId ){
            this.executeAction(getCloseoutRequestDetailsOnCommunity, {'closeoutRequestId' :this.recordId}, (response) => {
                if(response){
                  this.closeoutRequestDetais(response);
                }
            });  
              
        }
	}

     /*****************************************************************************
    * Method Name  : closeoutRequestDetais
    * Description  : this method retrun the closoeut request details  
    * Inputs       : -response
    * Author       : Dayal
    * Created On   : 16/11/2021
    * Modification Log: 
    *******************************************************************************/ 
    closeoutRequestDetais(response) {

        for(var key in response) {
            if(key == 'IncidentName') {
                this.incidentName = response[key];

            } else if(key == 'projectList'){

                this.projectData = response[key];
            }
        }

        let incidentDetails = JSON.parse(JSON.stringify(this.incidentName));
      
        this.programType = incidentDetails[0].Program_Name__c;
        this.SignedP4 = incidentDetails[0].Signed_P_4_Document_Available__c;
        this.selectedIncidentRecordId = incidentDetails[0].Incident__r.Id;
        this.incidentName = incidentDetails[0].Incident__r.Name;
        this.authorizedAgent = incidentDetails[0].Authorized_Agent__c;
        this.projectData = JSON.parse(JSON.stringify(  this.projectData));
        this.showProjectTable = true;  
      
        if(this.SignedP4 =='yes'){
            this.doYouSignedP4 = true;
        }

        let tableIndex = 0;
        if(this.projectData != null){
            for(let i=0; i<this.projectData.length; i++) {
                   this.projectData[i].ReviewSubmitted = false; 
                   this.projectData[i].tableIndexNumber =  ++tableIndex;  

                   //--------- Percent_Complete_To_Date__c field should not empty or null  ----
                    if(this.projectData[i].Percent_Complete_To_Date__c == undefined || this.projectData[i].Percent_Complete_To_Date__c == null || this.projectData[i].Percent_Complete_To_Date__c == '') {
                         
                        this.projectData[i].Percent_Complete_To_Date__c = 0;
                    }
                    
                   this.projectData[i].Percent_Complete_To_Date__c = this.projectData[i].Percent_Complete_To_Date__c / 100;                    
             }
        }
        this.showProjectTable = true;
        // it retrive the check quation as per program type
        this.getMetadataRecords();
        this.allProjectSelected();
    }

    allProjectSelected() {
        let hasAdded = true;
        let projectsOnUI = this.projectsToDisplay;   
        for(let i=0; i < projectsOnUI.length; i++) {                 
                this.addRemoveProjects(hasAdded, projectsOnUI[i].Id );           
            } 
	}

    /*****************************************************************************
    * Method Name  : getReviewMetadata
    * Description  : This method is used to get metadata records   
    * Inputs       : {'selectedProgramType' : this.programType}
    * Author       : Dayal
    * Created On   : 26/05/2021
    * Modification Log: 
    *******************************************************************************/      
    getMetadataRecords(){
        this.executeAction(getReviewMetadata, {'selectedProgramType' : this.programType}, (response) => {
            this.reviewMetaDataList = response;
        });
    }

    //*******--it return true value if get subrecipient name -******** */
   get isIncident() {
        if(this.incidentName && this.isPortalUser == true){
            return true;
        } 
        return false;
    }  

    //***********---------check program type fmag selected or not -------- *********/
    get isPaFmagSelected(){
        if(this.programType == CONSTANT_PROGRAM_TYPE.PA_PROGRAM_FMAG) return true;
        return false;
    }
    //***************check program type CDAA selected or not  ***************
    get isPaCDAASelected(){
        if(this.programType == CONSTANT_PROGRAM_TYPE.PA_PROGRAM_CDAA) return true;
        return false;
    }
    //***************check program type CDAA selected or not  ***************
    get isPaFederalSelected(){
        if(this.programType == CONSTANT_PROGRAM_TYPE.PA_PROGRAM_FEDERAL) return true;
        return false;
    }
     //***************document upload section is true if program type Federal or CDAA ***************
    get showDocumentSection(){
        if(this.programType == CONSTANT_PROGRAM_TYPE.PA_PROGRAM_FEDERAL || this.programType == CONSTANT_PROGRAM_TYPE.PA_PROGRAM_CDAA || (this.isPortalUser == true && this.isIncident == true))  return true;
        return false;
    }

    //***************check the upload file option visible or not ***************
    get showUploadedFiles() {
        if(this.uploadedFiles && this.uploadedFiles.length > 0) return true;
        return false;
    }

    /***************submit button is Enable when incident and subrecipent selected  and get project Data
     and at list one project selected and one file uploaded for program type Federal and CDAA*  or 
     if program type FMAG then only check if project and at list  one project selected**************/

	get isButtonDisabled() {
        //if intserna user then it check only incident and subrecipient and at list one project shoule be slected then and then submit button visible
        if(this.isPortalUser == false){

            if(this.selectedSRRecordId && this.selectedIncidentRecordId && this.projectData
                && this.selectedProjectIdLst && this.selectedProjectIdLst.length > 0 ) {
                    return false;

                } else if(this.programType == CONSTANT_PROGRAM_TYPE.PA_PROGRAM_FMAG  && (this.projectData
                             && this.selectedProjectIdLst && this.selectedProjectIdLst.length > 0)) {
                    return false;
                }

        } else {

	    if(this.selectedSRRecordId && this.selectedIncidentRecordId && this.projectData
	                && this.selectedProjectIdLst && this.selectedProjectIdLst.length > 0 && this.doYouSignedP4 == true
	                && this.uploadedFiles && this.uploadedFiles.length > 0) {
	                    return false;
        }else if(this.programType == CONSTANT_PROGRAM_TYPE.PA_PROGRAM_FMAG  && (this.projectData
                     && this.selectedProjectIdLst && this.selectedProjectIdLst.length > 0)){
                        return false;
                     }
        }

	    return true;
	}

    //*******--it return true value if get subrecipient name -******** */
    get isSubrecipient() {
        if(this.subRecipientName ){
            return true;
        } 
        return false;
    }  
    //*******--Radio button lable chamge on basis of program type if it CDAA or Federal program -******** */
    get fileRadioButtonLabel() {
        if(this.programType == CONSTANT_PROGRAM_TYPE.PA_PROGRAM_CDAA){
            return 'Do you have signed CDAA 4 and CDAA 4a forms available for the projects you are requesting to closeout?';
        }else if(this.programType == CONSTANT_PROGRAM_TYPE.PA_PROGRAM_FEDERAL){
            return 'Do you have signed P.4 available for the projects you are requesting Closeout?';
        }
    }

   /******----------File upload lable chamge on basis of program type if it CDAA or Federal program ******** */
    get fileAttacLabel() {
        if(this.programType == CONSTANT_PROGRAM_TYPE.PA_PROGRAM_CDAA){
            return 'Attach CDAA 4 and CDAA 4a form';
        }else if(this.programType == CONSTANT_PROGRAM_TYPE.PA_PROGRAM_FEDERAL){
            return 'Attach P.4';
        }
    } 

    /*****************************************************************************
    * Method Name  : handleIncidentChange
    * Description  : This function is used to select the program type as per incident selected 
    * Inputs       : response
    * Author       : Dayal
    * Created On   : 26/05/2021
    * Modification Log: 
    *******************************************************************************/  
	handleIncidentChange(response) {
            
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
            
        } else{
           
            this.selectedIncidentRecordId = undefined;
             this.projectData = undefined;
             this.doYouSignedP4 = undefined;
             this.uploadedFiles = [];
             this.showProjectTable = false;   
             //to hide document section when Incident is removed
             this.programType = ''; 
        }
    }
    
    /*****************************************************************************
    * Method Name  : handleSRChange
    * Description  : This function is used to select the Subrecipient as per user 
    *                selected on UI
    * Inputs       : response
    * Author       : Dayal
    * Created On   : 26/05/2021
    * Modification Log: 
    *******************************************************************************/  

    handleSRChange(response) {
        if(response.detail !=null && response.detail.selectedItem.id != undefined) {
            this.selectedSRRecordId = response.detail.selectedItem.id;                      
        } else {
            this.selectedSRRecordId = undefined;
            this.projectData = undefined;   
            this.doYouSignedP4 = undefined;
             this.uploadedFiles = []; 
            this.showProjectTable = false;      
        }
    }

    /*****************************************************************************
    * Method Name  : columns
    * Description  : This function is used to display the column name in table on UI
    *                
    * Inputs       : -
    * Author       : Dayal
    * Created On   : 26/05/2021
    * Modification Log: 
    *******************************************************************************/  
    get columns() {
        /*------if program type select Federal--------*/
        if(this.programType == CONSTANT_PROGRAM_TYPE.PA_PROGRAM_FEDERAL){
        return [{
                    label: 'Project#',
                    fieldName: 'Project_Number__c',
                    readOnly:true
                },
                {
                    label: 'Declaration#',
                    fieldName: 'Declaration_Number__c'
                },
                {
                    label: 'Large Project',
                    fieldName: 'IsLargeProject__c',
                    type: 'boolean'
                },                
                {
                    label: 'Total Project Award ($)',
                    fieldName: 'Total_Project_Award__c'                   
                                     
                },
                {
                    label: 'Total Amount Claimed ($)',
                    fieldName: 'Total_Amount_Claimed__c',
                    editable: true
                },
                {
                    label: 'Percent Complete To-Date (%)',
                    fieldName: 'Percent_Complete_To_Date__c'                   
                    },  

                    {   
                        label: "Checklist",
                        type: "action",
                        typeAttributes: { rowActions: actions },
                    },
             
               ];
            /*------if program type select CDAA--------*/   
            }else if(this.programType == CONSTANT_PROGRAM_TYPE.PA_PROGRAM_CDAA){
            
              return [{
                    label: 'Project#',
                    fieldName: 'Project_Number__c',
                    readOnly:true
                },
                {
                    label: 'Declaration#',
                    fieldName: 'Declaration_Number__c'
                },               
                {
                    label: 'Total Project Award ($)',
                    fieldName: 'Total_Project_Award__c'                   
                                     
                },
                {
                    label: 'Total Amount Claimed ($)',
                    fieldName: 'Total_Amount_Claimed__c',
                    editable: true
                },
                {
                    label: 'Percent Complete To-Date (%)',
                    fieldName: 'Percent_Complete_To_Date__c'                   
                    },  

                    {   
                        label: "Checklist",
                        type: "action",
                        typeAttributes: { rowActions: actions },
                    },
             
               ];
            /*------if program type select FMAG--------*/     
            }else if(this.programType == CONSTANT_PROGRAM_TYPE.PA_PROGRAM_FMAG){
            
                return [{
                      label: 'Project#',
                      fieldName: 'Project_Number__c',
                      readOnly:true
                  },
                  {
                      label: 'Declaration#',
                      fieldName: 'Declaration_Number__c'
                  },
                  {
                      label: 'Total Project Award ($)',
                      fieldName: 'Total_Project_Award__c'                   
                                       
                  },
                  {
                      label: 'Total Amount Claimed ($)',
                      fieldName: 'Total_Amount_Claimed__c',
                      editable: true
                  },
                 
                ];
       
            }
    }

   
    get fieldsToReturnForSR (){
        return "Id, Name";
    }

    /*------file formate accepted --------*/   
	get acceptedFormats() {
		return ['.pdf', '.png' , '.jpg', 'jpeg', '.doc', '.docx'];
	}

    /*****************************************************************************
    * Method Name  : handleIncidentSearch
    * Description  :  Searches Incidents with Users have project access
    *                
    * Inputs       : -
    * Author       : Dayal
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
    * Method Name  : handleAccountSearch
    * Description  :  Searches Incidents with Users have project access             
    * Inputs       : -
    * Author       : Dayal
    * Created On   : 26/05/2021
    * Modification Log: 
    *******************************************************************************/ 
    handleAccountSearch(event) {        
        apexSearchAgency({ searchTerm: event.detail.searchTerm})
        .then((results) => {            
            this.template.querySelector('[data-lookup="Account"]').setSearchResults(results);
        })
        .catch((error) => {
            this.error('Lookup Error', 'An error occured while searching with the lookup field.');
            this.errors = [error];
        });
    }

    /*****************************************************************************
    * Method Name  :  handleUploadFinished
    * Description  :  this function is used to upload the file            
    * Inputs       : -
    * Author       : Dayal
    * Created On   : 26/05/2021
    * Modification Log: 
    *******************************************************************************/ 
  
	handleUploadFinished(event) {
        const docUploadedFiles = event.detail.files;
		for(let i = 0; i < docUploadedFiles.length; i++) {
			this.uploadedFiles.push(docUploadedFiles[i]);
		}		
	}

   /*****************************************************************************
    * Method Name  :  removeUploadedFile
    * Description  :  this function is used to remove the file            
    * Inputs       : -
    * Author       : Dayal
    * Created On   : 26/05/2021
    * Modification Log: 
    *******************************************************************************/   

	removeUploadedFile(event) {
        
        const index = event.currentTarget.dataset.deleteId;
	    let indexToRemove = parseInt(index);
	    this.uploadedFiles.splice(indexToRemove, 1);
    }

    /*-------------------it show the yes no radio button on UI ---------------------*/
	get yesNoOptions() {
		return [{
				label: 'Yes',
				value: 'yes'
			},
			{
				label: 'No',
				value: 'no'
			},
		];
	}	
    
    /*****************************************************************************
    * Method Name  :  handleSearch
    * Description  :  this function isSearches the project are availabe or not for 
                      this incident ,Subrecipient, Program type       
    * Inputs       : -
    * Author       : Dayal
    * Created On   : 26/05/2021
    * Modification Log: 
    *******************************************************************************/   
	handleSearch(event) {

		//check Incident  and Subrecipient should not blank                            
        if(this.selectedIncidentRecordId == undefined ||  this.selectedSRRecordId == undefined){
            this.showErrorNotification('Error', 'Please select relevant Subrecipient and Incident');
            return;
        }

        //Federal Program Validation for file upload and select P4 yes
        if(this.programType == CONSTANT_PROGRAM_TYPE.PA_PROGRAM_FEDERAL){
           // if(this.isPortalUser == true){
            if(!this.uploadedFiles || this.uploadedFiles.length == 0) {            
                this.showErrorNotification('Error', 'Please upload P.4 document');               
                return;
            }
                if(this.doYouSignedP4 == false && this.isPortalUser == true) {
                this.showErrorNotification('Error', 'Please select "Yes" to successfully upload the P.4 before requesting for Closeout');			  
                return;
            }
           // }

        }
         //PA_PROGRAM_CDAA Program Validation for file upload and select P4 yes
        if(this.programType == CONSTANT_PROGRAM_TYPE.PA_PROGRAM_CDAA){
           // if(this.isPortalUser == true){
            if(!this.uploadedFiles || this.uploadedFiles.length == 0) {               
                this.showErrorNotification('Error', 'Please upload CDAA 4 and CDAA 4a document');                
                return;
            }

                if(this.doYouSignedP4 == false && this.isPortalUser == true) {
                this.showErrorNotification('Error', ' Please select "Yes" to successfully upload the CDAA 4 and CDAA 4a before requesting for Closeout');			  
                return;
            }
           // }
        }   
       
		let paramMap = {};
        let tableIndex = 0;
        paramMap['selectedSRRecordId'] = this.selectedSRRecordId;
        paramMap['selectedIncidentRecordId'] = this.selectedIncidentRecordId;
        paramMap['selectedProgramname'] = this.programType;
        console.log('-----------paramMap -------',paramMap);
        /*---------- get the project ad per selected Subrecipient and  Incident program type ----*/
        this.executeAction(getProjectsForSR, paramMap, (response) => {
            this.projectData = JSON.parse(JSON.stringify( response));

            if(this.projectData != null){
                for(let i=0; i<this.projectData.length; i++) {
                       this.projectData[i].ReviewSubmitted = false; 
                       this.projectData[i].tableIndexNumber =  ++tableIndex;  

                        /*---------- Percent_Complete_To_Date__c field should not empty or null  ----*/
                        if(this.projectData[i].Percent_Complete_To_Date__c == undefined || this.projectData[i].Percent_Complete_To_Date__c == null || this.projectData[i].Percent_Complete_To_Date__c == '') {
                             
                            this.projectData[i].Percent_Complete_To_Date__c = 0;
                        }
                        
                       this.projectData[i].Percent_Complete_To_Date__c = this.projectData[i].Percent_Complete_To_Date__c / 100;                    
                 }
            }
            this.showProjectTable = true;
            // it retrive the check quation as per program type
            this.getMetadataRecords();
        },
        (error)=>{
            this.projectData = [];
            this.showProjectTable = false;
            let errorMessage = error.body && error.body.message ? error.body.message : 'Something went wrong, please contact your administrator.';
            this.showNotification('Error', errorMessage, 'error');
        });
    }
    
    /*****************************************************************************
    * Method Name  :  handleClear
    * Description  :  this function is used to clear the screen once we click on clear button  
    * Inputs       : -
    * Author       : Dayal
    * Created On   : 26/05/2021
    * Modification Log: 
    *******************************************************************************/

	handleClear(event) {
		this.refreshScreen();
    }

    /*****************************************************************************
    * Method Name  :  handleSubmit
    * Description  :  This function is used to create the closeout request 
    *                 once we click on Submit button, it validate the all validation 
    *                 and then initiate the closeout request 
    * Inputs       : -
    * Author       : Dayal
    * Created On   : 26/05/2021
    * Modification Log: 
    *******************************************************************************/
	handleSubmit(event) {  
        let totalAmountClaimedSmall = 0;
        let totalAwardAmountSmall = 0;
        this.isLargeProjectSelect == false;

              
        if(this.selectedProjectDetails.length == 0) return;
        //portal user validattion like Incident subrecipent  should be selected /P.4 or cdaa quation Yes should be select and file should be uploaded
        if(this.isPortalUser == true) {

            if(this.selectedIncidentRecordId == undefined ||  this.selectedSRRecordId == undefined){
                this.showErrorNotification('Error', 'Please select relevant Subrecipient and Incident');
                return;
            }
    
            if(!this.authorizedAgent) {
                this.showErrorNotification('Error', 'Authorized Agent should not be blank');
                    return;
            }

    
            //Federal Program Validation for file upload and select P4 yes
            if(this.programType == CONSTANT_PROGRAM_TYPE.PA_PROGRAM_FEDERAL){
               
                if(!this.uploadedFiles || this.uploadedFiles.length == 0) {
                       this.showErrorNotification('Error', 'Please upload P.4 document');
                       return;
                }
                if(this.doYouSignedP4 == false && this.isPortalUser == true) {
                       this.showErrorNotification('Error', 'Please select "Yes" to successfully upload the P.4 before requesting for Closeout');
                       return;
                }
              
            }

             //PA_PROGRAM_CDAA Program Validation for file upload and select P4 yes
            if(this.programType == CONSTANT_PROGRAM_TYPE.PA_PROGRAM_CDAA){
              
                if(!this.uploadedFiles || this.uploadedFiles.length == 0) {
                    this.showErrorNotification('Error', 'Please upload CDAA 4 and CDAA 4a document');
                    return;
                }
    
                if(this.doYouSignedP4 == false && this.isPortalUser == true) {
                     this.showErrorNotification('Error', ' Please select "Yes" to successfully upload the CDAA 4 and CDAA 4a before requesting for Closeout');
                     return;
                }
              
            } 
        }

        //if the portal user then it check all validation

        let smallProjectSelected = false;
        let selectedProjectIds = [];
        for (let i = 0; i < this.selectedProjectDetails.length; i++) {
            //if project programType is  PA - Federal
            if(this.programType == CONSTANT_PROGRAM_TYPE.PA_PROGRAM_FEDERAL){

                if(this.selectedProjectDetails[i].Percent_Complete_To_Date__c === undefined || this.selectedProjectDetails[i].Percent_Complete_To_Date__c === null){ 
                    this.showErrorNotification('Error', 'Selected projects are not 100% complete!');
                    return;         
                }

                    if(this.isPortalUser == true){

                       /* if(!this.authorizedAgent) {
                            this.showErrorNotification('Error', 'Authorized Agent should not be blank');
                                return;
                        }*/

                if(this.selectedProjectDetails[i].Total_Amount_Claimed__c === undefined || this.selectedProjectDetails[i].Total_Amount_Claimed__c == null || this.selectedProjectDetails[i].Total_Amount_Claimed__c == "" || this.selectedProjectDetails[i].Total_Amount_Claimed__c == NaN){
                    this.showErrorNotification('Error', 'Total Amount Claimed is blank for the selected projects');
                    return;         
                }

                        if(!this.uploadedFiles || this.uploadedFiles.length == 0) {
                        this.showErrorNotification('Error', 'Please upload P.4 document');
                        return;
                        }

                        if(this.doYouSignedP4 == false) {
                        this.showErrorNotification('Error', 'Please select "Yes" to successfully upload the P.4 before requesting for Closeout');
                    return;
                }

                if(this.selectedProjectDetails[i].ReviewSubmitted === false){
                    this.showErrorNotification('Error', 'Checklist Responses are blank for the selected projects');
                    return;
                }
                    }

                    if(this.selectedProjectDetails[i].Percent_Complete_To_Date__c < 1 ){
                        this.showErrorNotification('Error', 'Selected projects are not 100% complete!');
                        return;
                    }

                 //caculate sum of all total project award and total amount spent 
                if(this.selectedProjectDetails[i].IsLargeProject__c == false ){
                    smallProjectSelected = true;               
                    totalAwardAmountSmall = totalAwardAmountSmall + this.selectedProjectDetails[i].Total_Project_Award__c;
                    totalAmountClaimedSmall = totalAmountClaimedSmall + parseInt(this.selectedProjectDetails[i].Total_Amount_Claimed__c);
            
                }
               
            }
            //program type  CDAA (State Funding)  selected
            if(this.programType == CONSTANT_PROGRAM_TYPE.PA_PROGRAM_CDAA){
               
                if(this.selectedProjectDetails[i].Percent_Complete_To_Date__c === undefined || this.selectedProjectDetails[i].Percent_Complete_To_Date__c === null){ 
                    this.showErrorNotification('Error', 'Selected projects are not 100% complete!');
                    return;         
                } 
                    if(this.isPortalUser == true){
                if(this.selectedProjectDetails[i].Total_Amount_Claimed__c === undefined || this.selectedProjectDetails[i].Total_Amount_Claimed__c == null || this.selectedProjectDetails[i].Total_Amount_Claimed__c == "" || this.selectedProjectDetails[i].Total_Amount_Claimed__c == NaN){
                    this.showErrorNotification('Error', 'Total Amount Claimed is blank for the selected projects');
                    return;         
                }

                        if(!this.uploadedFiles || this.uploadedFiles.length == 0) {
                            this.showErrorNotification('Error', 'Please upload CDAA 4 and CDAA 4a document');
                    return;
                }

                        if(this.doYouSignedP4 == false) {
                            this.showErrorNotification('Error', ' Please select "Yes" to successfully upload the CDAA 4 and CDAA 4a before requesting for Closeout');
                            return;
                        }

                if(this.selectedProjectDetails[i].ReviewSubmitted === false){
                    this.showErrorNotification('Error', 'Checklist Responses are blank for the selected projects');
                    return;
                }
                    }

                    if(this.selectedProjectDetails[i].Percent_Complete_To_Date__c < 1 ){
                        this.showErrorNotification('Error', 'Selected projects are not 100% complete!');
                        return;
                    }
                
            }
            
            selectedProjectIds.push(this.selectedProjectDetails[i].Id);
                     
        }
        //if project programType is  PA_PROGRAM_FEDERAL
        if(this.programType == CONSTANT_PROGRAM_TYPE.PA_PROGRAM_FEDERAL) {
            this.isSmallLargeProjectSelect(this.selectedProjectDetails);

            if(smallProjectSelected) {
                for (let i = 0; i < this.projectData.length; i++) {
                    if(this.projectData[i].IsLargeProject__c == false && selectedProjectIds.includes(this.projectData[i].Id) == false){
                        this.showErrorNotification('Error', 'Please select all small projects');
                        return;
                    }
                }             
                
            } 
            
            if( (totalAmountClaimedSmall > totalAwardAmountSmall) && this.isLargeProjectSelect == true ){
                if(this.programType == CONSTANT_PROGRAM_TYPE.PA_PROGRAM_FEDERAL){
                   this.showErrorNotification('Error', "You cannot add large projects when there is NSPO appeal in the Closeout Request");
                   return; 
                }
                      
           }   
           
           if(totalAmountClaimedSmall > totalAwardAmountSmall){
                this.isSaveConfirmationShow = true;
            }else {  
                this.closeOutRequestGenerate();
            } 
        }
        
        
        if(this.programType == CONSTANT_PROGRAM_TYPE.PA_PROGRAM_CDAA){
             for(let i = 0; i < this.projectsToDisplay.length; i++){
                 if(this.projectsToDisplay[i].isChecked == false){
                    this.showErrorNotification('Error', "Please select all projects");
                    return;  
                 }
             }
             this.closeOutRequestGenerate();
         }

         if(this.programType == CONSTANT_PROGRAM_TYPE.PA_PROGRAM_FMAG){
            for(let i = 0; i < this.projectsToDisplay.length; i++){
                if(this.projectsToDisplay[i].isChecked == false){
                   this.showErrorNotification('Error', "Please select all projects");
                   return;  
                }
            }
            this.closeOutRequestGenerate();
        }        
	}
        
    /*****************************************************************************
    * Method Name  : handleSaveConfirmationClick
    * Description  : This function is used to handle the Alert box 
    * Author       : Dayal
    * Created On   : 26/05/2021
    * Modification Log: 
    *******************************************************************************/ 
               
    handleSaveConfirmationClick(event){      
        if(event.detail.status == 'confirm') {
            this.closeOutRequestGenerate();
            this.isSaveConfirmationShow = false;  

          } else {
            this.isSaveConfirmationShow = false;           
        }
    }

    /*****************************************************************************
    * Method Name  : closeOutRequestGenerate
    * Description  : This function is used Generate the closeOutRequest
    * Author       : Dayal
    * Created On   : 26/05/2021
    * Modification Log: 
    *******************************************************************************/   
    closeOutRequestGenerate(){
        this.showLoader = true;
        let contentDocIds = []; 
        let contentDocFilenames = [];
        for(let i=0; i< this.uploadedFiles.length; i++) {
            contentDocIds.push(this.uploadedFiles[i].documentId);       
            contentDocFilenames.push(this.uploadedFiles[i].name);  
        }  
        
       /****************--------------if project programType is  PA - FMAG  then -----------*****************/
       if(this.programType == CONSTANT_PROGRAM_TYPE.PA_PROGRAM_FMAG){
            for (let i = 0; i < this.selectedProjectDetails.length; i++) {
                if(this.selectedProjectDetails[i].Total_Amount_Claimed__c === undefined || this.selectedProjectDetails[i].Total_Amount_Claimed__c == null || this.selectedProjectDetails[i].Total_Amount_Claimed__c == "" || this.selectedProjectDetails[i].Total_Amount_Claimed__c == NaN){
                    this.selectedProjectDetails[i].Total_Amount_Claimed__c = 0;       
                }
            }           
        }

       
        let projectSeleted =[];
        for (let i = 0; i < this.selectedProjectDetails.length; i++) {
            let projetDetails = {
                'Id': this.selectedProjectDetails[i].Id,
                'Total_Amount_Claimed__c': this.selectedProjectDetails[i].Total_Amount_Claimed__c
            }
            projectSeleted.push(projetDetails);  
        }
       
        let paramMap = {};
        paramMap['projectLst'] = JSON.stringify(projectSeleted);
        for(let i = 0; i < this.projectData.length ; i++){
            let project = this.projectData[i];
            if(project.ReviewSubmitted == true){
               this.closeoutCheckListArray = this.closeoutCheckListArray.concat(project.checklistArray);
            }

        }

        if(this.isPortalUser == true) {
        paramMap['closeoutCheckList'] = JSON.stringify(this.closeoutCheckListArray);
        paramMap['files'] = contentDocIds;
            paramMap['fileNames'] = contentDocFilenames;
            paramMap['selectedProgramType'] = this.programType;
            paramMap['authorizedAgent'] = this.authorizedAgent;
            paramMap['SignedP4DocumentAvailable'] = this.SignedP4;
            paramMap['closeoutRequestId'] = this.recordId;

            this.executeAction(finalizeClosoeutRequest, paramMap, (response) => {
                if(response){
                    this.showSuccessNotification('Success', 'Your request has been submitted successfully!');
                    this.navigateRecordViewPage(response);
                    this.handleClose();
                    
                } else {
                    this.showErrorNotification('Error', "Closeout Request not finalized");
                }              
                
            });

        } else {
            paramMap['closeoutCheckList'] = JSON.stringify(this.closeoutCheckListArray);
            paramMap['files'] = contentDocIds;
            paramMap['fileNames'] = contentDocFilenames;
        paramMap['subrecipient'] = this.selectedSRRecordId;
        paramMap['incident'] = this.selectedIncidentRecordId;
        paramMap['selectedProgramType'] = this.programType;
            paramMap['authorizedAgent'] = this.authorizedAgent;
            paramMap['SignedP4DocumentAvailable'] = this.SignedP4;

        this.executeAction(initiateCloseout, paramMap, (response) => {
                if(response) {
            this.showSuccessNotification('Success', 'Your request has been submitted successfully!');
                   // this.navigateRecordViewPage(response);
                    this.handleClose();
                    this.openCloseoutRequestTab(response);
                    
                } else {
                    this.showErrorNotification('Error', "Closeout Request not generate");
                }
               
            
        });
    }
    }

    /*****************************************************************************
    * Method Name  : handleCancel
    * Description  : This function is once click on Cancel button then it move to main page of closeout request
    * Author       : Dayal
    * Created On   : 26/05/2021
    * Modification Log: 
    *******************************************************************************/   
  
    handleCancel(){
        this.navigateToObjectListView('Closeout_Request__c');
    }

    /*****************************************************************************
    * Method Name  : removeElementById
    * Description  : This function is use to remeove the selectd project
    * Author       : Dayal
    * Created On   : 26/05/2021
    * Modification Log: 
    *******************************************************************************/  

	removeElementById(recordId, projectArr) {
	    let arrToReturn = [];
	    for(let i=0; i<projectArr.length; i++) {
	        if(projectArr[i].Id != recordId) {
	            arrToReturn.push(projectArr[i]);
            }
        }
        return arrToReturn;
    }

    /*****************************************************************************
    * Method Name  : allSelected
    * Description  : This function is use to  select-all project
    * Author       : Dayal
    * Created On   : 26/05/2021
    * Modification Log: 
    *******************************************************************************/  
    allSelected(e) {

        let projectsOnUI = this.projectsToDisplay;   
        for(let i=0; i < projectsOnUI.length; i++) {                 
                this.addRemoveProjects(e.target.checked, projectsOnUI[i].Id );           
            } 
    }
    
    /*****************************************************************************
    * Method Name  : addRemoveProjects
    * Description  : This function is use remove the project from list which we selected
    * Author       : Dayal
    * Created On   : 26/05/2021
    * Modification Log: 
    *******************************************************************************/  

    addRemoveProjects(hasAdded, selectedProjectId){        
         let projectsOnUI = this.projectsToDisplay;
         if(hasAdded == true) {
             for(let i=0; i < projectsOnUI.length; i++) {
                  if(projectsOnUI[i].Id == selectedProjectId) {
                      if(projectsOnUI[i].IsLargeProject__c == true) {
                          this.selectedLargeProjects.push(projectsOnUI[i]);
                      } else {
                          this.selectedSmallProjects.push(projectsOnUI[i]);
                }
            }
        }
         } else {
            this.selectedSmallProjects = this.removeElementById(selectedProjectId, this.selectedSmallProjects);
            this.selectedLargeProjects = this.removeElementById(selectedProjectId, this.selectedLargeProjects);
         }

         this.selectedProjectIdLst = [];
         this.selectedProjectDetails = [];
         this.selectedProjectDetails = this.selectedSmallProjects.concat(this.selectedLargeProjects);
         
         this.selectedProjectDetails = this.getUniqueList( this.selectedProjectDetails);

         for(let i=0; i < this.selectedProjectDetails.length; i++) {
             this.selectedProjectIdLst.push(this.selectedProjectDetails[i].Id);
         }   
    }

    /*****************************************************************************
    * Method Name  : selectProjects
    * Description  : This function is use to select and remove the project
    * Author       : Dayal
    * Created On   : 26/05/2021
    * Modification Log: 
    *******************************************************************************/  
	selectProjects(e) {
        this.addRemoveProjects(e.target.checked, e.target.dataset.id);
        
    }

    /*****************************************************************************
    * Method Name  : handleRowAction
    * Description  : This function is use to -Handle table row level Action
    * Author       : Dayal
    * Created On   : 26/05/2021
    * Modification Log: 
    *******************************************************************************/
    handleRowAction(event) {
        this.projectId =  event.currentTarget.dataset.key
        let index =  event.currentTarget.dataset.index;
        this.isReviewSeleted = true;
        if(this.projectData[index].checklistArray != null){
          this.selectedChecklistArray = this.projectData[index].checklistArray;
        }else{
            this.selectedChecklistArray = [];
        }
      
    }

    /*****************************************************************************
    * Method Name  : handleModalAction
    * Description  : This function is use to -check list selected
    * Author       : Dayal
    * Created On   : 26/05/2021
    * Modification Log: 
    *******************************************************************************/
  
    handleModalAction(event){
        let projectId = event.detail.projectId;       
         this.isReviewSeleted = false;
         for(let i = 0; i < this.projectData.length ; i++){
            if(this.projectData[i].Id == projectId){
                this.projectData[i].ReviewSubmitted = true;
                this.projectData[i].checklistArray = event.detail.closeoutCheckList;
            }
         }
        let successMessage = "Thank you for reviewing and submitting all the required information and documentation. A Cal\n";
        successMessage +=  "OES Specialist may follow up with more requests or clarifications for each project, as necessary. \n"  ;
         //let  successMessage = "Thank you for reviewing and submitting all the required information and documentation. A CalOES Specialist may follow up with more requests or clarifications for each project, as necessary. \n";
          this.showSuccessNotification('Success', successMessage);
         
    }

    /*****************************************************************************
    * Method Name  : modalclose
    * Description  : This function is use to -close the modal of check list
    * Author       : Dayal
    * Created On   : 26/05/2021
    * Modification Log: 
    *******************************************************************************/
    modalclose(){
        this.isReviewSeleted = false; 
    }

    /*****************************************************************************
    * Method Name  : handleColumEdite
    * Description  : This function is use to -captuer the total amount claim amount on UI
    * Author       : Dayal
    * Created On   : 26/05/2021
    * Modification Log: 
    *******************************************************************************/
    handleColumEdite(event) {    
        let recordInputs =   event.detail.value;
        let recordInputsId =   event.currentTarget.dataset.key;            
        for(let i = 0; i < this.projectData.length ; i++){
            if(this.projectData[i].Id == recordInputsId){                   
                this.projectData[i].Total_Amount_Claimed__c = recordInputs;
                break;
            }
        }            
    }

    /*****************************************************************************
    * Method Name  : isSmallLargeProjectSelect
    * Description  : This function is use to -this method check is both small and large project selected or not
    * Author       : Dayal
    * Created On   : 26/05/2021
    * Modification Log: 
    *******************************************************************************/  
    isSmallLargeProjectSelect(selectedProjectDetails){
        this.isLargeProjectSelect = false;
        this.isSmallProjectSelect = false;
        for (let i = 0; i < selectedProjectDetails.length; i++){
            if( selectedProjectDetails[i].IsLargeProject__c == true){
               this.isLargeProjectSelect =true; 
            }else if( selectedProjectDetails[i].IsLargeProject__c == false){
               this.isSmallProjectSelect =true; 
            }		
       }       
    }
    
    /*****************************************************************************
    * Method Name  : handleP4DocumentChange
    * Description  : This function is use to -get the unique list of selected project
    * Author       : Dayal
    * Created On   : 26/05/2021
    * Modification Log: 
    *******************************************************************************/ 
	handleP4DocumentChange(event){
	    const selectedOption = event.detail.value;
        this.SignedP4 = selectedOption;
        this.doYouSignedP4 = false;
        if(selectedOption == 'yes') {
           this.doYouSignedP4 = true;
        }
	}

    /*****************************************************************************
    * Method Name  : handleSelectSmall
    * Description  : This function is use to -select all small projects
    * Author       : Dayal
    * Created On   : 26/05/2021
    * Modification Log: 
    *******************************************************************************/ 
	handleSelectSmall(){      
        if(this.isLargeProjectSelect == true){
            this.showErrorNotification('Error', "please select either Large project or Small Project");
            return;    
        }
		this.selectAllSmallProject();
	}
    
    /*****************************************************************************
    * Method Name  : getUniqueList
    * Description  : This function is use to -get the unique list of selected project
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

    /*****************************************************************************
    * Method Name  : getsubrecipientName
    * Description  : This function is use to -get the suprecipient
    * Author       : Dayal
    * Created On   : 26/05/2021
    * Modification Log: 
    *******************************************************************************/  
  
    @wire(userSubrecipientDetails)
    getsubrecipientName({
        error,
        data
    }) {
        if(data && data[0].Profile.Name == 'CalOES Portal User' && data[0].Contact.Account.Name) {
            this.subRecipientName = data[0].Contact.Account.Name != undefined ? data[0].Contact.Account.Name : '';
            this.selectedSRRecordId = data[0].Contact.Account.Id;
            this.showFMG = false;               
        } else if (error) {
            this.showErrorNotification('Error', error);
        } 
        
    }

    /***********************Display the projectTypeOptions******************* */
    get projectTypeOptions() {
        return [
            { label: 'All Projects', value: 'All Projects' },
            { label: 'Small Projects', value: 'Small Projects' },
            { label: 'Large Projects', value: 'Large Projects' }
            
        ];
    }

    /************************handle the project change******************* */
    handleProjectTypeChange(event) {
        this.selectedProjectType = event.detail.value;
    }
    //************************Display the project on basis of all or large or Small******************* */
    get projectsToDisplay() {
       
        let selectedProjectIds = this.getSelectedRows;
        let projectToReturn = [];
        if(this.selectedProjectType == 'Small Projects') {

            for(let i=0; i<this.projectData.length; i++) {
                if(this.projectData[i].IsLargeProject__c != true) {
                    projectToReturn.push(this.projectData[i]);
                }
            }
        } else if(this.selectedProjectType == 'Large Projects') {
            for(let i=0; i<this.projectData.length; i++) {
                if(this.projectData[i].IsLargeProject__c == true) {
                    projectToReturn.push(this.projectData[i]);
                }
            }
        } else {
            projectToReturn = this.projectData;
        }

        if(projectToReturn) {
           
            for(let i=0; i < projectToReturn.length; i++) {
                if(selectedProjectIds.includes(projectToReturn[i].Id)) {
                    
                    projectToReturn[i].isChecked = true;
                }else{
                    projectToReturn[i].isChecked  = false;
                }
            }
        }

        return projectToReturn;
    }

    /************************--get the selected project--******************* */
    get getSelectedRows() {
        let recordsToReturn = [];
        if(this.selectedProjectType == 'Small Projects') {
            recordsToReturn = this.selectedSmallProjects;

        } else if(this.selectedProjectType == 'Large Projects') {
            recordsToReturn = this.selectedLargeProjects;

        } else {
            recordsToReturn = this.selectedProjectDetails;
        }
        let idsToReturn = [];
        for(let i=0; i < recordsToReturn.length; i++) {
            idsToReturn.push(recordsToReturn[i].Id);

        }
        return idsToReturn;
    }
    
    handleAuthorizedAgentChange(event) {
        this.authorizedAgent = event.detail.value;
        this.authorizedAgent = this.authorizedAgent.trim();  

        let emailFieldCmp = this.template.querySelector('.authorizedAgent');

        if( (this.authorizedAgent == null ||  this.authorizedAgent == undefined ||  this.authorizedAgent == '') && this.isPortalUser == true){
            emailFieldCmp.setCustomValidity('Complete this field.');
            emailFieldCmp.reportValidity();
            return ;
        }else{
            emailFieldCmp.setCustomValidity('');
            emailFieldCmp.reportValidity();
        }
       
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

    openCloseoutRequestTab(closeOutRequestId) {        
        const closeclickedevt = new CustomEvent('openCloseoutRequestTab', {
            detail: { closeOutRequestId }
        });
         // Fire the custom event
        this.dispatchEvent(closeclickedevt); 
    }
}