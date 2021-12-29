/**
* Class Name   : paInitCloseoutTaskController
* Description  : This class is used to create closeout Task. 
                 On close out list view once you click on new we have override lwc component to create closeout task.
 *               On this page, You can search on Incident or Sub recipient.
 *               Post selection you will get Projects whose closeout is initiated.
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
public without sharing class paInitCloseoutTaskController {
    
    /***********************************************************************************************
    * Method  Name   : getProjectsForSR
    * Description    : This method is used to get Project based on selected Sub Recipient or Incident or selected program
    * Return         : List of Projects
    * Inputs         : String selectedSRRecordId, String selectedIncidentRecordId, String selectedProgramName
    * Author       : Digamber
    * Created On   : 26/05/2021
    * Modification Log:  
    * -----------------------------------------------------------------------------------------------*/
    @AuraEnabled
    public static List<Project__c> getProjectsForSR(String selectedSRRecordId, String selectedIncidentRecordId, String selectedProgramName) {
        // Sub Recipient , Incident and Program is required to search project. If either is blank then throw exception.
        if(String.isEmpty(selectedSRRecordId) || String.isEmpty(selectedIncidentRecordId) ||  String.isEmpty(selectedProgramName)) {
            throw new AuraHandledException('Please select Sub Recipient and Incident and program type');
        }
       
        List<Project__c> projList = [Select Id, (SELECT Closeout_Request__r.Name FROM CloseOuts__r), Name, Project_Number__c, Damage_Category__c,IsLargeProject__c, Total_Project_Award__c
                                        from Project__c
                                        where Id IN (SELECT Project_Name__c
                                        FROM Project_Closeout__c
                                        WHERE Project_Name__r.Obligating_Sub_Recipient__c =:selectedSRRecordId
                                        AND Project_Name__r.Incident_Name__c =: selectedIncidentRecordId
                                        AND CloseOut_Task__c = null
                                        AND Closeout_Request__c != null)
                                        AND  Funding_Opportunity_Name__r.Program_Name__r.Name =:selectedProgramName
                                    ];
        // if no project found then throw exception on UI.
        if(projList.size() == 0) {
            throw new AuraHandledException('Projects not available for selected incident and subrecipient');
        }
        return projList;
    }

    
    /***********************************************************************************************
    * Method Name : apexSearchIncident
    * Description    : This method is used to get Incident based on Search term entered by User
    * Return         : List of Lookup result which contains Incidents
    * Inputs         : searchTerm - search term entered by User.
    * Author         : Digamber
    * Created On     : 26/05/2021
    * Modification Log:
    * -----------------------------------------------------------------------------------------------*/
    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> apexSearchIncident(String searchTerm) {
        
        // prepare SOQL query
            String query = 'SELECT Id, Name, Program_Name__r.Name, Declaration_Number__c, Incident_Name__r.Name FROM Funding_Opportunity__c WHERE Name != null';
        // add filter clause only if added by user
            if(String.isNotEmpty(searchTerm)) {
                query += ' AND (Incident_Name__r.Name like\'%' + searchTerm + '%\' OR Declaration_Number__c like\'%' + searchTerm + '%\')';
            }
                    query += ' AND Program_Name__r.Name IN(\'PA - Federal\', \'CDAA (State Funding)\', \'PA - FMAG\')';
            query += ' Limit 200'; 

            List<Funding_Opportunity__c> fundingOpsList = Database.query(query);

            List<LookupSearchResult> results = new List<LookupSearchResult>();

            // Extract incidents & convert them into LookupSearchResult
            String productIcon = 'standard:account';
            String subtitle = '';
            
            for (Funding_Opportunity__c fundingOp : fundingOpsList) {
                subtitle = '';
                if(!String.isBlank(fundingOp.Program_Name__r.Name)){
                    subtitle = fundingOp.Program_Name__r.Name + ' ; ';
                }
                if(!String.isBlank(fundingOp.Declaration_Number__c)){
                    subtitle += fundingOp.Declaration_Number__c;
                }
                results.add(
                        new LookupSearchResult(
                                fundingOp.Id,
                                'Account',
                                productIcon,
                                fundingOp.Incident_Name__r.Name,
                                subtitle,
                                fundingOp
                        )
                );
            }
        //sort all results on title
            results.sort();
            return results;
            }

    /***********************************************************************************************
    * Method Name : apexSearchCloseoutTask
    * Description    : This method is used to get closeout task as per selected incident and subrecipent and program type
    * Return         : List of Lookup result which contains closeout task
    * Inputs         : searchTerm - search term entered by User,
                       String subrecipent Id, String incident id, String program type
    * Author         : Digamber
    * Created On     : 26/05/2021
    * Modification Log:
    * -----------------------------------------------------------------------------------------------*/    
    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> apexSearchCloseoutTask(String searchTerm, String selectedSRRecordId, String selectedIncidentRecordId, String selectedProgramName) {
        Set<String> statusValSet = PA_CONSTANTS.closeoutTaskStatus();
       
        //prepared query
        String query = 'SELECT Id, Name, Reviewer__r.Name, Status__c FROM Closeout_Task__c';

        // Added filter clasue only if added by user
        if(String.isNotEmpty(searchTerm)) {
            query += ' Where Name like\'%' + searchTerm + '%\' AND Subrecipient_Name__c = \'' + selectedSRRecordId + '\' AND Incident__c = \'' + selectedIncidentRecordId+ '\'';
        }

        // Added filter clasue of CDAA program type
        if(selectedProgramName == PA_CONSTANTS.PA_PROGRAM_CDAA){
            query += ' AND RecordTypeId = \''+Schema.SObjectType.Closeout_Task__c.getRecordTypeInfosByDeveloperName().get('CDAA').getRecordTypeId()+'\'';
       }

        // Added filter clasue of Federal program type
       if(selectedProgramName == PA_CONSTANTS.PA_PROGRAM_FEDERAL){
            query += ' AND RecordTypeId = \''+Schema.SObjectType.Closeout_Task__c.getRecordTypeInfosByDeveloperName().get('PA_Federal').getRecordTypeId()+'\'';
       }
        // Added filter clasue of FMAG program type
       if(selectedProgramName == PA_CONSTANTS.PA_PROGRAM_FMAG){
            query += ' AND RecordTypeId = \''+Schema.SObjectType.Closeout_Task__c.getRecordTypeInfosByDeveloperName().get('PA_FMAG').getRecordTypeId()+'\'';
       }
        query += ' AND  Status__c NOT IN: statusValSet';
        query += ' Limit 200';
      
        List<Closeout_Task__c> closeOutTaskList = Database.query(query);
        List<LookupSearchResult> results = new List<LookupSearchResult>();

        for(Closeout_Task__c closeOutTask : closeOutTaskList){
                String subtitle = 'Reviewer: ' + closeOutTask.Reviewer__r.Name + '  Status: ' + closeOutTask.Status__c;
                results.add(
                    new LookupSearchResult(
                        closeOutTask.id,
                        'Closeout_Task__c',
                        'standard:account',
                        closeOutTask.Name,
                        subtitle,
                        closeOutTask
                    )    
                );  
        }
        results.sort();
        return results;
    }

    /***********************************************************************************************
    * Method Name : apexSearchAgency
    * Description: This method return list of LookupSearchResult from Account
    * Return         : List of Lookup result which contains Account
    * Inputs         : String searchTerm, String entityTypeFilter
    * Author         : Pankaj
    * Created On     : 26/05/2021
    * Modification Log:
    * -----------------------------------------------------------------------------------------------*/   

    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> apexSearchAgency(String searchTerm, String selectedIncidentId) {
        // Prepare query paramters
        //searchTerm += '*';
        String query = 'SELECT Id,Name,Entity_Type__c FROM Account ';
        // Added filter clasue only if added by user
        if(String.isNotEmpty(searchTerm)) {
            query += ' WHERE Name like\'%' + searchTerm + '%\'';
        }

        // Added filter clasue only if  selectedIncidentId added by user
        if(String.isNotEmpty(selectedIncidentId)){
            query += ' AND Id IN (Select Account__c from Incident_Subrecipient_Stage__c where Incident__c = \''+selectedIncidentId+'\')';
        }
        query += ' Limit 200';
       
        List<Account> accounts = Database.query(query);
        // Prepare results
        // Extract Accounts & convert them into LookupSearchResult
        List<LookupSearchResult> results = new List<LookupSearchResult>();
        String productIcon = 'standard:account';
        for (Account opProductReference : accounts) {
            results.add(
                    new LookupSearchResult(
                            opProductReference.Id,
                            'Account',
                            productIcon,
                            opProductReference.Name,
                            (opProductReference.Entity_Type__c != null ? opProductReference.Entity_Type__c  : ''),
                            opProductReference
                    )
            );
        }
        // Optionnaly sort all results on title
        results.sort();
        return results;
    }

    /***********************************************************************************************
    * Method  Name   : apexSearchAgency
    * Description    : This method return list of LookupSearchResult from Account
    * Return         : List of Lookup result which contains Account
    * Inputs         : String searchTerm, String entityTypeFilter
    * Author         : Pankaj
    * Created On     : 26/05/2021
    * Modification Log:
    * -----------------------------------------------------------------------------------------------*/   

    @AuraEnabled
    public static String initCloseoutTask(List<String>  selectedProjectIdLst,  String selectedSRRecordId, String selectedIncidentRecordId, String selectedTargetCloseoutTaskId, String selectedProgramName){
        Closeout_Task__c closeoutTask =null;      
        List<Closeout_Task__c> selectedTargetCloseoutTask = new List<Closeout_Task__c>();   
        String incidentSubrecipientStageId ='';     
                
        List<Group> recordOwner= [SELECT Id FROM Group  WHERE DeveloperName ='Public_Assistance_PM1' AND Type='Queue'];

        List <Incident_Subrecipient_Stage__c> incidentSubrecipientStage = [SELECT ID from Incident_Subrecipient_Stage__c where Account__c =: selectedSRRecordId AND Incident__c =:selectedIncidentRecordId];
       
        //if incident Subrecipient Stage get 
        if(incidentSubrecipientStage.size() > 0){
            incidentSubrecipientStageId = incidentSubrecipientStage[0].Id;
        }

        // Added filter clause by selected Target Closeout Task Id added by user
        if(String.isNotEmpty(selectedTargetCloseoutTaskId)){
            closeoutTask = new Closeout_Task__c(Id=selectedTargetCloseoutTaskId);           
            selectedTargetCloseoutTask = [SELECT Id, OwnerId, Name, Authorized_Agent__c FROM Closeout_Task__c WHERE Id =:selectedTargetCloseoutTaskId ];
            if(String.isBlank(selectedTargetCloseoutTask[0].Authorized_Agent__c )){
                String authorizedAgent = getAuthorizedAgent(selectedProjectIdLst);
                if(String.isNotBlank(authorizedAgent)){
                    closeoutTask.Authorized_Agent_Name__c = authorizedAgent;
                }
            }          
        } else {               
                closeoutTask = new Closeout_Task__c();
                closeoutTask.Reviewer__c = UserInfo.getUserId();
                closeoutTask.Incident__c = selectedIncidentRecordId;
                closeoutTask.Subrecipient_Name__c = selectedSRRecordId;        
                closeoutTask.Status__c = 'Pending Assignment';
                closeoutTask.Incident_Subrecipient_Summary__c = incidentSubrecipientStageId;
                String authorizedAgent = getAuthorizedAgent(selectedProjectIdLst);
                if(String.isNotBlank(authorizedAgent)){
                    closeoutTask.Authorized_Agent_Name__c = authorizedAgent;
                }

                //if get the record owner
                if(recordOwner.size() > 0){
                    closeoutTask.OwnerId = recordOwner[0].Id;
                }

                //Added filter clause by CDAA program type
                if(selectedProgramName == PA_CONSTANTS.PA_PROGRAM_CDAA){
                     closeoutTask.RecordTypeId =  Schema.SObjectType.Closeout_Task__c.getRecordTypeInfosByDeveloperName().get('CDAA').getRecordTypeId();
                }

                //Added filter clause by Federal program type
                if(selectedProgramName == PA_CONSTANTS.PA_PROGRAM_FEDERAL){
                    closeoutTask.RecordTypeId = Schema.SObjectType.Closeout_Task__c.getRecordTypeInfosByDeveloperName().get('PA_Federal').getRecordTypeId();
                }
                //Added filter clause by FMAG program type
                if(selectedProgramName == PA_CONSTANTS.PA_PROGRAM_FMAG){
                    closeoutTask.RecordTypeId = Schema.SObjectType.Closeout_Task__c.getRecordTypeInfosByDeveloperName().get('PA_FMAG').getRecordTypeId();
                }               
        }
                
        PA_SystemContextHelper.upsertCloseoutTask(closeoutTask);
        //update project closeout
        List<Project_Closeout__c> projectCloseoutList = [SELECT Id,Closeout_Task__c FROM  Project_Closeout__c WHERE Project_Name__c IN:selectedProjectIdLst];
        for (Project_Closeout__c projectCloseout : projectCloseoutList) {
            projectCloseout.Closeout_Task__c = closeoutTask.Id;
            projectCloseout.OwnerId = recordOwner[0].Id;
        }
        TriggerHelper.skipTrigger = false;
        update projectCloseoutList;
       
        //update project
        List<Project__c> projectListToBeUpdated = new List<Project__c>();
        for (String projectId : selectedProjectIdLst) {
            Project__c project = new Project__c(Id=projectId, Closeout_Task__c=closeoutTask.Id);
            projectListToBeUpdated.add(project);
        }
        update projectListToBeUpdated; 

        //Grant edit access of respective projects to owner of target closeout task, if target closeout task owner is self access user
        if(String.isNotEmpty(selectedTargetCloseoutTaskId)){
            List<Closeout_Task__c> selectedTargetCloseoutTaskList = [SELECT Id, OwnerId, Name FROM Closeout_Task__c WHERE Id =:selectedTargetCloseoutTaskId ];
            if(selectedTargetCloseoutTaskList.size() > 0){
                if(isSelfAccessCloseoutTaskUser(selectedTargetCloseoutTaskList[0].OwnerId)){
                    grantEditAccessToProjects(selectedProjectIdLst, selectedTargetCloseoutTaskList[0]);
                }
            }
        }
        addContentDocumentLink(selectedProjectIdLst , closeoutTask.Id, selectedProgramName, selectedTargetCloseoutTaskId);
        return closeoutTask.Id;
    }

    /***********************************************************************************************
    * Method Name : addContentDocumentLink
    * Description    : This method is used to add content Document in closeout task which is on 
                   closeout request as per project which linked to closeout request
    * Return         :-
    * Inputs         : List<String>  selectedProjectIdLst, String closeoutTaskId, String projrctType
    * Author         : Dayal
    * Created On     : 26/05/2021
    * Modification Log:
    * -----------------------------------------------------------------------------------------------*/ 

     public static void addContentDocumentLink(List<String>  selectedProjectIdLst, String closeoutTaskId, String projrctType, String selectedTargetCloseoutTaskId){
        String projectTypeDetails ='P.4';
        List<Project_Closeout__c> projectCloseoutList = [SELECT Id,Name,Closeout_Request__r.Id
                                                       FROM Project_Closeout__c WHERE Project_Name__r.Id In: selectedProjectIdLst];
        Set<Id> closeoutRequestIdSet = new Set<Id> ();    
        for(Project_Closeout__c projectCloseout : projectCloseoutList){
            closeoutRequestIdSet.add(projectCloseout.Closeout_Request__r.Id);
        }
        List<ContentDocumentLink> condoc=  [SELECT Id,ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE 
                                          LinkedEntityId In: closeoutRequestIdSet];
        
        List<Document__c> documentList = new List<Document__c>();  
        
        //Added filter clause program type contain CDAA
        if(projrctType == PA_CONSTANTS.PA_PROGRAM_CDAA){
            projectTypeDetails = 'CDAA Form 4/ CDAA Form 4a';
        }else if(projrctType == PA_CONSTANTS.PA_PROGRAM_FMAG){
            projectTypeDetails = 'FMAG';
        }
        
        //create Document 
        for(ContentDocumentLink document : condoc){
            Document__c doc = new Document__c();
            doc.Document_Name__c =  projectTypeDetails;        
            doc.Closeout_Task__c = closeoutTaskId;
            doc.Closeout_Request__c = document.LinkedEntityId;
            documentList.add(doc);
        }        
        insert documentList;
        // link the document to contentDocument
        List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>(); 
        if(documentList.size() > 0){
            for(Integer i = 0 ;i<documentList.size(); i++){
                for(Integer j = 0; j<condoc.size(); j++){
                    ContentDocumentLink cdl = condoc[j].clone();
                    if(i == j){
                        cdl.LinkedEntityId = documentList[i].Id;
                        contentDocumentLinks.add(cdl);
                    }               
                }
            }       
        }      
    
        PA_SystemContextHelper.upsertContentDocLinks(contentDocumentLinks);    

        //create Document FIR and Signed FIR
        if(String.isEmpty(selectedTargetCloseoutTaskId)){
        List<Document__c> firDocumentList = new List<Document__c>();  

        Document__c docFir = new Document__c();
        Key_Value_Store__mdt mtdtFIRDocName = Key_Value_Store__mdt.getInstance('PA_FIR_Document_Name');
        docFir.Document_Name__c =  mtdtFIRDocName.Text_Value__c;   
        docFir.Document_Type__c = 'FIR';
        docFir.Closeout_Task__c = closeoutTaskId;
        firDocumentList.add(docFir);   
        
        Document__c docSigned_FIR = new Document__c();
        Key_Value_Store__mdt mtdtSignedFIRDocName = Key_Value_Store__mdt.getInstance('PA_Signed_FIR_Document_Name');
        docSigned_FIR.Document_Name__c =  mtdtSignedFIRDocName.Text_Value__c;   
        docSigned_FIR.Document_Type__c = 'Signed FIR';
        docSigned_FIR.Closeout_Task__c = closeoutTaskId;
        firDocumentList.add(docSigned_FIR);  
        
        if(firDocumentList.size() > 0){
            insert firDocumentList;
        }
    }
    }

    /***********************************************************************************************
    * Method Name : isSelfAccessCloseoutTaskUser
    * Description    : This method will return boolean that specified user is self access user only or all
                        access with respect to closeout task.
    * Return         :- it retrun boolean values if closeout task owner have self access
    * Inputs         : List<String>  selectedProjectIdLst, String closeoutTaskId, String projrctType
    * Author : Digambar
    * Created On     : 26/05/2021
    * Modification Log:
    * -----------------------------------------------------------------------------------------------*/ 

    public static Boolean isSelfAccessCloseoutTaskUser(String closeoutTaskOwnerId){
    
        Integer closeoutTaskOwnerCount = [SELECT COUNT()
                                          FROM PermissionSetAssignment 
                                          WHERE PermissionSetId NOT IN (SELECT Id FROM PermissionSet WHERE Name IN ('PA_Manager', 'PA_DAPS_Special_Permission')) 
                                          AND AssigneeId =:  closeoutTaskOwnerId];

        //Added filter clause if getting the closeout task owner
        if(closeoutTaskOwnerCount > 0){     
            return true;                                  
        }
        return false;
    }

    /***********************************************************************************************
    * Method Name : grantEditAccessToProjects
    * Description: This method will grant edit access to relevant projects.
    * Return         :- -
    * Inputs         : List<String>  selectedProjectIdLst, Closeout_Task__c selectedTargetCloseoutTask
    * Author         : Digambar
    * Created On     : 26/05/2021
    * Modification Log:
    * -----------------------------------------------------------------------------------------------*/ 

    public static void grantEditAccessToProjects(List<String>  selectedProjectIdLst, Closeout_Task__c selectedTargetCloseoutTask){
        // Create a new list of sharing objects for Project to be inserted
        List<Project__Share> projectShareListToInsert  = new List<Project__Share>();
        for(String project : selectedProjectIdLst){
                
                // Declare variables for Project sharing object
                Project__Share projectShare = new Project__Share();
                
                // Set the ID of record being shared
                projectShare.ParentId = project;
                
                // Set the ID of user or group being granted access
                projectShare.UserOrGroupId = selectedTargetCloseoutTask.OwnerId;
                
                // Set the access level
                projectShare.AccessLevel = 'edit';
                
                // Set the Apex sharing reason 
                projectShare.RowCause = Schema.Project__Share.RowCause.CloseoutTaskMoveProject__c;
                
                // Add objects to list for insert
                projectShareListToInsert.add(projectShare);
        }                
         //Insert sharing records and capture save result 
         // The false parameter allows for partial processing if multiple records are passed into the operation 
         Database.SaveResult[] projectShareListDBResults = Database.insert(projectShareListToInsert,false);
        
        // Create counter
        Integer i=0;
        // Process the save results
         for(Database.SaveResult dbResult : projectShareListDBResults){
            if(!dbResult.isSuccess()){
                // Get the first save result error
                Database.Error err = dbResult.getErrors()[0];
                
            }
            i++; 
        }
}

    /***********************************************************************************************
    * Method Name : apexCheckNSPO
    * Description    : This method is used to check the NSPO and NSPU if we select target closeout task.
    * Return         :- -
    * Inputs         : List<String>  selectedSmallProjectsIdList, Integer selectedLargeProjectCount, String selectedCloseoutTaskId
    * Author : Digambar
    * Created On     : 26/05/2021
    * Modification Log:
    * -----------------------------------------------------------------------------------------------*/ 

    @AuraEnabled
    public static Boolean apexCheckNSPO(List<String>  selectedSmallProjectsIdList, Integer selectedLargeProjectCount, String selectedCloseoutTaskId){
        if(String.isNotEmpty(selectedCloseoutTaskId)){
            
            List<Project__c> targetCloseoutTaskSmallProject = [SELECT Id, Name FROM Project__c WHERE IsLargeProject__c = false AND Closeout_Task__c =: selectedCloseoutTaskId];
            List<Project__c> targetCloseoutTaskLargeProject = [SELECT Id, Name FROM Project__c WHERE IsLargeProject__c = true AND Closeout_Task__c =: selectedCloseoutTaskId];
           
            if((selectedSmallProjectsIdList.size() + targetCloseoutTaskSmallProject.size()) > 0 && (selectedLargeProjectCount + targetCloseoutTaskLargeProject.size()) > 0){
               
                AggregateResult[] groupedResults =  [SELECT sum(Total_Project_Award__c)totalProjectAward , sum(Total_Amount_Claimed__c)totalAmountSpent
                                                    FROM Project_Closeout__c 
                                                    where  Project_Name__r.IsLargeProject__c = false
                                                        AND (Project_Name__c In:selectedSmallProjectsIdList
                                                        OR Closeout_Task__c =:selectedCloseoutTaskId)
                                                    ];
                //if totalProjectAward is less then totalAmountSpent then return true
                if( (Double)groupedResults[0].get('totalProjectAward') < (Double)groupedResults[0].get('totalAmountSpent')){
                    return true;
                }
                return false;
            }
            return false;
        }else {
                if(selectedSmallProjectsIdList.size()>0 && selectedLargeProjectCount>0){
                    AggregateResult[] groupedResults =  [SELECT sum(Total_Project_Award__c)totalProjectAward , sum(Total_Amount_Claimed__c)totalAmountSpent
                                                         FROM Project_Closeout__c 
                                                         WHERE  Project_Name__c In:selectedSmallProjectsIdList 
                                                        ];
                    //if totalProjectAward is less then totalAmountSpent then return true
                    if( (Double)groupedResults[0].get('totalProjectAward') < (Double)groupedResults[0].get('totalAmountSpent')){
                        return true;
                    }
                    return false;
                }   
                return false;
        }
    }
    /***********************************************************************************************
    * Method  Name   : getAuthorizedAgent
    * Description    : This method is used to get Authorized_Agent__c from closeout request respective to Selected Projects.
    * Return         :- Authorized_Agent__c
    * Inputs         : List<String>  selectedProjectIdLst
    * Author         : Digambar
    * Created On     : 12/10/2021
    * Modification Log:
    * -----------------------------------------------------------------------------------------------*/ 
    public static String getAuthorizedAgent(List<String>  selectedProjectIdLst){
        String authorizedAgent = '';         
        List<Project__c> projectList = [SELECT Id, Closeout_Request__c, Closeout_Request__r.Authorized_Agent__c 
                                        FROM Project__c 
                                        WHERE Id IN : selectedProjectIdLst
                                          AND Closeout_Request__r.Authorized_Agent__c != null];
        system.debug('#getauthorizedAgent projectList :'+projectList);
        if(projectList.size() > 0 ){
            authorizedAgent = projectList.get(0).Closeout_Request__r.Authorized_Agent__c;
        }
        system.debug('#authorizedAgent :'+authorizedAgent);
        return authorizedAgent;
    }
}