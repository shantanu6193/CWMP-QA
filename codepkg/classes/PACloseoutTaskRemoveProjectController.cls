/**
* Class Name   : PACloseoutTaskRemoveProjectController
* Description  : This class is used to remove project from  closeout Task. 
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
public without sharing class PACloseoutTaskRemoveProjectController {
    
    /***********************************************************************************************
    * Method Name : isFullAccessCloseoutTaskUserWire
    * Description: This method will return boolean that specified user is all access user.
    * Return         : map
    * Inputs         : String closeoutTaskId, String status
    * Author         : Digamber
    * Created On     : 26/05/2021
    * Modification Log:  
    * -----------------------------------------------------------------------------------------------*/

    @AuraEnabled(Cacheable=true)
    public static Map<String,String> isFullAccessCloseoutTaskUserWire(String closeoutTaskId, String status){
        
        Map<String, String> result = new Map<String, String>();
        Integer closeoutTaskOwnerCount = [SELECT COUNT()
                                          FROM PermissionSetAssignment 
                                          WHERE PermissionSetId IN (SELECT Id FROM PermissionSet WHERE Name IN ('PA_Manager', 'PA_DAPS_Special_Permission')) 
                                          AND AssigneeId =:  UserInfo.getUserId()];
        if(closeoutTaskOwnerCount > 0){     
            result.put('isFullAccessCloseoutTaskUserWire','true');                                 

        } else { 
            result.put('isFullAccessCloseoutTaskUserWire','false');
        }
        //get closeout task name
        Closeout_Task__c closeoutTask = [SELECT Id, Name, Status__c FROM Closeout_Task__c WHERE Id =: closeoutTaskId];
        result.put('closeOutTaskName',closeoutTask.Name);
        return result;
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
    public static List<LookupSearchResult> apexSearchCloseoutTask(String searchTerm) {
        //prepared query        
        String apexSearchCloseoutTaskQuery = 'SELECT Id, Name, Subrecipient_Name__r.Name, Incident__r.Name, Status__c FROM Closeout_Task__c';
       
        // add filter clause only if added by user
        if(String.isNotEmpty(searchTerm)) {

            apexSearchCloseoutTaskQuery += ' Where Name like\'%' + searchTerm + '%\' OR Subrecipient_Name__r.Name like\'%' + searchTerm + '%\' OR Incident__r.Name like\'%' + searchTerm + '%\'';
        }
        apexSearchCloseoutTaskQuery += ' Limit 200';

        List<Closeout_Task__c> closeOutTaskList = Database.query(apexSearchCloseoutTaskQuery);
        List<LookupSearchResult> results = new List<LookupSearchResult>();

        for(Closeout_Task__c closeOutTask : closeOutTaskList){
                String subtitle = 'Incident: ' + closeOutTask.Incident__r.Name + ' Subrecipient: ' + closeOutTask.Subrecipient_Name__r.Name + ' Status: ' + closeOutTask.Status__c;
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
    * Method Name : apexSearchTargetCloseoutTask
    * Description    : This method is used to get target closeout task as per selected incident and subrecipent and program type
    * Return         : List of Lookup result which contains closeout task
    * Inputs         : String searchTerm, String selectedCloseoutTaskId
    * Author         : Digamber
    * Created On     : 26/05/2021
    * Modification Log:
    * -----------------------------------------------------------------------------------------------*/ 
    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> apexSearchTargetCloseoutTask(String searchTerm, String selectedCloseoutTaskId) {
      
        List<Closeout_Task__c> closeoutTaskSourceList = [SELECT Id, Subrecipient_Name__c, Incident__c, RecordTypeId FROM Closeout_Task__c WHERE Id =: selectedCloseoutTaskId];
        String apexSearchTargetCloseoutTaskQuery = 'SELECT Id, Name, Reviewer__r.Name, Status__c FROM Closeout_Task__c';
        Set<String> statusValSet = PA_CONSTANTS.closeoutTaskStatus();        

        //Added filter clause by search by user
        if(String.isNotEmpty(searchTerm)) {
            apexSearchTargetCloseoutTaskQuery += ' Where Name like\'%' + searchTerm + '%\' AND Id != \''+closeoutTaskSourceList.get(0).Id+'\' AND Subrecipient_Name__c = \'' + closeoutTaskSourceList.get(0).Subrecipient_Name__c + '\' AND Incident__c = \'' + closeoutTaskSourceList.get(0).Incident__c + '\' AND RecordTypeId =\'' + closeoutTaskSourceList.get(0).RecordTypeId+'\'';             
        }
        
        apexSearchTargetCloseoutTaskQuery += ' AND  Status__c NOT IN: statusValSet';
        apexSearchTargetCloseoutTaskQuery += ' Limit 200';

        List<Closeout_Task__c> closeOutTaskList = Database.query(apexSearchTargetCloseoutTaskQuery);

        List<LookupSearchResult> results = new List<LookupSearchResult>();
        
        for(Closeout_Task__c closeOutTask : closeOutTaskList){
                String subtitle = 'Reviewer: ' + closeOutTask.Reviewer__r.Name + ' Status: ' + closeOutTask.Status__c;
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
        System.debug('results---' + results);
        return results;
    }

    /***********************************************************************************************
    * Method Name : getProjectsForCR
    * Description    : This method is used to get the project list as per selected closeout task
    * Return         : List of project
    * Inputs         : String selectedCloseoutTaskId
    * Author         : Digamber
    * Created On     : 26/05/2021
    * Modification Log:
    * -----------------------------------------------------------------------------------------------*/   
    @AuraEnabled
    public static List<Project__c> getProjectsForCR(String selectedCloseoutTaskId) {
        //if selected Closeout Task Id is empty the it throw an error on UI
        if(String.isEmpty(selectedCloseoutTaskId)) {
            throw new AuraHandledException('Please select Closeout Task');
        }
       
        List<Project__c> projList = [SELECT Id, (SELECT Closeout_Request__r.Name FROM CloseOuts__r), Name, Project_Number__c, Damage_Category__c,IsLargeProject__c, Total_Project_Award__c
                                     FROM Project__c 
                                    WHERE CloseOut_Task__c =: selectedCloseoutTaskId];                                    
                                   
        return projList;
    }
    
    /***********************************************************************************************
    * Method Name : apexCheckNSPO
    * Description    : This method is used to check the NSPO and NSPU for selected closeout task
    * Return         : Bolean value if NSPO generate then true 
    * Inputs         : List<String>  selectedSmallProjectsIdList, Integer selectedLargeProjectCount, String selectedCloseoutTaskId
    * Author         : Digamber
    * Created On     : 26/05/2021
    * Modification Log:
    * -----------------------------------------------------------------------------------------------*/   
   
    @AuraEnabled
    public static Boolean apexCheckNSPO(List<String>  selectedSmallProjectsIdList, Integer selectedLargeProjectCount, String selectedCloseoutTaskId){

            List<Project__c> targetCloseoutTaskSmallProject = [SELECT Id, Name FROM Project__c WHERE IsLargeProject__c = false AND Closeout_Task__c =: selectedCloseoutTaskId];
            List<Project__c> targetCloseoutTaskLargeProject = [SELECT Id, Name FROM Project__c WHERE IsLargeProject__c = true AND Closeout_Task__c =: selectedCloseoutTaskId];
       
            if((selectedSmallProjectsIdList.size() + targetCloseoutTaskSmallProject.size()) > 0 && (selectedLargeProjectCount + targetCloseoutTaskLargeProject.size()) > 0){
          
                AggregateResult[] groupedResults =  [SELECT sum(Total_Project_Award__c)totalProjectAward , sum(Total_Amount_Claimed__c)totalAmountSpent
                                                    FROM Project_Closeout__c 
                                                    where  Project_Name__r.IsLargeProject__c = false
                                                        AND (Project_Name__c In:selectedSmallProjectsIdList
                                                        OR Closeout_Task__c =:selectedCloseoutTaskId)
                                                    ];

                if( (Double)groupedResults[0].get('totalProjectAward') < (Double)groupedResults[0].get('totalAmountSpent')){
                    return false;
                }
            }
            return true;
    }

    /***********************************************************************************************
    * Method Name : removeProjects
    * Description    : This method is used to remove the project from closeout task which are selected or added into existing closeout task
    * Return         : Bolean value if project removed from closeout task then it return true otherwise false 
    * Inputs         : List<String>  selectedSmallProjectsIdList, Integer selectedLargeProjectCount, 
                       String selectedCloseoutTaskId, String selectedTargetCloseoutTaskId, List<Project__c> selectedAllProjects
    * Author         : Digamber
    * Created On     : 26/05/2021
    * Modification Log:
    * -----------------------------------------------------------------------------------------------*/   

    @AuraEnabled
    public static Boolean removeProjects(List<String>  selectedSmallProjectsIdList, Integer selectedLargeProjectCount, String selectedCloseoutTaskId, String selectedTargetCloseoutTaskId, List<Project__c> selectedAllProjects){
        Set<String> selectedProjectIdSet = new Set<String>();
        String projrctType = PA_CONSTANTS.PA_PROGRAM_CDAA;
        //SOURCE CLOSEOUT TASK 
        if(String.isEmpty(selectedTargetCloseoutTaskId)){
            //update project
            for(Project__c project : selectedAllProjects){
                project.CloseOut_Task__c = null; 
                selectedProjectIdSet.add(project.Id);  

                //Revoke shared access to projects owner
                List<Project__Share> sharesToDelete = [SELECT Id 
                                                       FROM Project__Share 
                                                       WHERE RowCause IN('CloseoutTaskAssignment__c', 'CloseoutTaskMoveProject__c')
                                                       AND ParentId =: project.Id 
                                                       LIMIT 200];

                //project shared to delete should not empty                                      
                if(!sharesToDelete.isEmpty()){
                    Database.Delete(sharesToDelete, false);
                }
            }

            //update project closeout
            List<Group> paAnalystGroup = [SELECT Id FROM Group  WHERE DeveloperName ='PA_Analyst' AND Type='Queue'];
            List<Project_Closeout__c> projectCloseoutList = [SELECT Id,Closeout_Task__c FROM  Project_Closeout__c WHERE Project_Name__c IN:selectedAllProjects];
            for (Project_Closeout__c projectCloseout : projectCloseoutList) {
                    projectCloseout.Closeout_Task__c = null;
                    if(paAnalystGroup.size() > 0){
                        projectCloseout.OwnerId = paAnalystGroup[0].Id;
                    }
            }
            update selectedAllProjects;
            update projectCloseoutList;
        }
        //TARGET CLOSEOUT TASK
        else{
            //Confirm no large project is added to target NSPO Closeout Tasks 
            if(!apexCheckNSPO(selectedSmallProjectsIdList, selectedLargeProjectCount, selectedTargetCloseoutTaskId)){
                return false;
            }

            //Get object/owner of target closeouttask
            Closeout_Task__c selectedTargetCloseoutTask = [SELECT Id, OwnerId, RecordType.Name FROM Closeout_Task__c WHERE Id =: selectedTargetCloseoutTaskId];
            
            //update project
            for(Project__c project : selectedAllProjects){
                project.CloseOut_Task__c = selectedTargetCloseoutTaskId;   
                selectedProjectIdSet.add(project.Id); 

                //Revoke shared access to projects owner
                List<Project__Share> sharesToDelete = [SELECT Id 
                                                       FROM Project__Share 
                                                       WHERE RowCause IN('CloseoutTaskAssignment__c', 'CloseoutTaskMoveProject__c')
                                                       AND ParentId =: project.Id 
                                                       LIMIT 200
                                                       ];
                if(!sharesToDelete.isEmpty()){
                Database.Delete(sharesToDelete, false);
                }
            }

            //update project closeout's closeouttask & owner
            List<Project_Closeout__c> projectCloseoutList = [SELECT Id FROM  Project_Closeout__c WHERE Project_Name__c IN:selectedAllProjects];
            for (Project_Closeout__c projectCloseout : projectCloseoutList) {
                projectCloseout.Closeout_Task__c = selectedTargetCloseoutTaskId;
                projectCloseout.OwnerId = selectedTargetCloseoutTask.OwnerId;
            }
            update selectedAllProjects;
            update projectCloseoutList;
            
            //Grant edit access of respective projects to owner of target closeout task, if target closeout task owner is self access user
            if(isSelfAccessCloseoutTaskUser(selectedTargetCloseoutTask.OwnerId)){     
                grantEditAccessToProjects(selectedAllProjects, selectedTargetCloseoutTask);
            }
            List<String> projectIdSet = new List<String> (selectedProjectIdSet);
            //if selected closeout task record type is Federal then assign project type as Federal
            if(selectedTargetCloseoutTask.RecordType.Name == PA_CONSTANTS.PA_PROGRAM_FEDERAL){
                projrctType =  PA_CONSTANTS.PA_PROGRAM_FEDERAL;
            }else if(selectedTargetCloseoutTask.RecordType.Name == PA_CONSTANTS.PA_PROGRAM_FMAG){
                projrctType =  PA_CONSTANTS.PA_PROGRAM_FMAG;
            }

            addContentDocumentLink(projectIdSet,selectedTargetCloseoutTaskId, projrctType);
        }

        removeContentDocumentLink(selectedProjectIdSet, selectedCloseoutTaskId);
        return true;
    }

    /***********************************************************************************************
    * Method Name : removeContentDocumentLink
    * Description    : This method is used to remove the content document on closeout task a project which are going to be removed
    * Return         : -
    * Inputs         : Set<String>  selectedProjectIdSet, String closeoutTaskId
    * Author         : Digamber
    * Created On     : 26/05/2021
    * Modification Log:
    * -----------------------------------------------------------------------------------------------*/ 
    private static void removeContentDocumentLink(Set<String>  selectedProjectIdSet, String closeoutTaskId){

        List<Project_Closeout__c> projectCloseoutList = [SELECT Id,Name,Closeout_Request__r.Id
                                                       FROM Project_Closeout__c WHERE Project_Name__r.Id In: selectedProjectIdSet];
        
        Set<Id> closeoutRequestIdSet = new Set<Id> ();    
        for(Project_Closeout__c projectCloseout : projectCloseoutList){
            closeoutRequestIdSet.add(projectCloseout.Closeout_Request__r.Id);
        }

        List<Project_Closeout__c> projectCloseoutDetails = [SELECT Id,Name,Closeout_Request__r.Name, Project_Name__r.Name 
        FROM Project_Closeout__c WHERE Project_Name__r.Id Not In: selectedProjectIdSet 
        and Closeout_Task__r.Id =:closeoutTaskId and Closeout_Request__r.Id In : closeoutRequestIdSet];

        Set<String> closeoutIdSet = new Set<String>();
        for(Project_Closeout__c projectCloseutData :projectCloseoutDetails){
            closeoutIdSet.add(projectCloseutData.Closeout_Request__r.Id);
        }

        Set<String> closeoutIdRemoveIdSet = new Set<String>();
        for(String closeoutId :closeoutRequestIdSet){
            if(closeoutIdSet.contains(closeoutId) == false){
                closeoutIdRemoveIdSet.add(closeoutId);
            }
        }

        if(closeoutIdRemoveIdSet.size() > 0){
       
            List<ContentDocumentLink> conDocumentList=  [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE 
                                            LinkedEntityId In: closeoutIdRemoveIdSet];
       
            Set<Id> contentDocumentIdSet= new Set<Id>();
            
            //collect all content document id 
            for(ContentDocumentLink conDocument : conDocumentList){
                contentDocumentIdSet.add(conDocument.ContentDocumentId);
            }  

            List<ContentDocumentLink> documentContentList=  [SELECT Id,ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE 
                                                            ContentDocumentId In: contentDocumentIdSet];
            //find the document Id which refer to closeout task
            List<Document__c> documentList = [SELECT Closeout_Request__c,Closeout_Task__c,Document_Name__c,Id
                                            FROM Document__c WHERE Closeout_Task__c =: closeoutTaskId];

            List<ContentDocumentLink> contentDocList = new List<ContentDocumentLink>();
            List<Document__c> documentDetailsList = new List<Document__c>();

            for(ContentDocumentLink documentLink : documentContentList){
                for(Document__c closeoutTaskDocument : documentList){
                    if(closeoutTaskDocument.Id == documentLink.LinkedEntityId){
                
                        ContentDocumentLink conDocu = new ContentDocumentLink(Id = documentLink.Id,  LinkedEntityId = null);
                       Document__c  doc = new Document__c(Id = closeoutTaskDocument.Id, Closeout_Task__c = null, Closeout_Request__c = null);                   
                    
                        documentDetailsList.add(doc);
                        contentDocList.add(conDocu);
                    }
                }
            }
            
            upsert documentDetailsList;
            PA_SystemContextHelper.upsertContentDocLinks(contentDocList);
        }
    
    }

    /***********************************************************************************************
    * Method  Name   : addContentDocumentLink
    * Description    : This method is used to add content Document in closeout task which is on 
                       closeout request as per project which linked to closeout request
    * Return         :-
    * Inputs         : List<String>  selectedProjectIdLst, String closeoutTaskId, String projrctType
    * Author         : Dayal
    * Created On     : 14/10/2021
    * Modification Log:
    * -----------------------------------------------------------------------------------------------*/ 

    public static void addContentDocumentLink(List<String>  selectedProjectIdLst, String closeoutTaskId, String projrctType){
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
        if(projrctType == PA_CONSTANTS.PA_PROGRAM_CDAA) {

            projectTypeDetails = 'CDAA Form 4/ CDAA Form 4a';

        }else if(projrctType == PA_CONSTANTS.PA_PROGRAM_FMAG) {

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
    }

    /***********************************************************************************************
    * Method Name : grantEditAccessToProjects
    * Description: This method will grant edit access to relevant projects.
    * Return         : -
    * Inputs         : List<Project__c> selectedAllProjects, Closeout_Task__c selectedTargetCloseoutTask
    * Author         : Digamber
    * Created On     : 26/05/2021
    * Modification Log:
    * -----------------------------------------------------------------------------------------------*/ 

    public static void grantEditAccessToProjects(List<Project__c> selectedAllProjects, Closeout_Task__c selectedTargetCloseoutTask){
        // Create a new list of sharing objects for Project to be inserted
        List<Project__Share> projectShareListToInsert  = new List<Project__Share>();
        //Grant Project Edit Access
        for(Project__c project : selectedAllProjects){
            
                // Declare variables for Project sharing object
                Project__Share projectShare = new Project__Share();
                
                // Set the ID of record being shared
                projectShare.ParentId = project.Id;
                
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
    * Method Name : isSelfAccessCloseoutTaskUser
    * Description    : This method will return boolean that specified user is self
                        access user only or all access with respect to closeout task.
    * Return         : -
    * Inputs         : String closeoutTaskId
    * Author         : Digamber
    * Created On     : 26/05/2021
    * Modification Log:
    * -----------------------------------------------------------------------------------------------*/ 
    public static Boolean isSelfAccessCloseoutTaskUser(String closeoutTaskId){
    
        Integer closeoutTaskOwnerCount = [SELECT COUNT()
                                          FROM PermissionSetAssignment 
                                          WHERE PermissionSetId NOT IN (SELECT Id FROM PermissionSet WHERE Name IN ('PA_Manager', 'PA_DAPS_Special_Permission')) 
                                          AND AssigneeId =:  closeoutTaskId];
        if(closeoutTaskOwnerCount > 0){     
            return true;                                  
        }
        return false;
    }
    
    /***********************************************************************************************
    * Method Name : getSalesforceCustomBaseURL
    * Description: Get Closeout task Base URL from Custom Metadata..To Read Value
    * Return         : -
    * Inputs         : -
    * Author         : Digamber
    * Created On     : 26/05/2021
    * Modification Log:
    * -----------------------------------------------------------------------------------------------*/ 
  
 @AuraEnabled(Cacheable=true)
public static string getSalesforceCustomBaseURL(){
    try {
            String sBaseUrl = KeyValueHelper.getTextValue('Merge_Closeout_Task_BaseUrl');
            return sBaseUrl;
        
    } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
    }
}
}