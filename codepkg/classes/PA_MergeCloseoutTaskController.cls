/**
* Class Name   : PA_MergeCloseoutTaskController
* Description  : This class used  Merge closeout Task. On close out list view once you click on Merge Closeout we have override lwc component
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

public with sharing class PA_MergeCloseoutTaskController {
    public PA_MergeCloseoutTaskController() {

    }

    /***********************************************************************************************
    * Method Name   : getCloseOutTaskDetails
    * Description     : This method is used to get closeout task Details
    * Return          : map of closeout task
    * Inputs          : String closeOutTaskId
    * Author       : Atul
    * Created On      : 26/05/2021
    * Modification Log:  
    * ---------------------------------------------------------------------------------------------*/  
    @AuraEnabled(cacheable=true)
    public static Map<String,Object> getCloseOutTaskDetails(String closeOutTaskId){
       
        Map<String, Object> resultMap = new Map<String, Object>();
        Boolean isMergeCloseoutAccessible = false;
        List<Closeout_Task__c> closeOutTaskList = [SELECT Id, Name, Incident__c, Cost_Share_Eligibility__c, Subrecipient_Name__r.Name, Incident__r.Name, Status__c, Subrecipient_Name__c
                                                    FROM Closeout_Task__c 
                                                    WHERE Id =:closeOutTaskId];

        String rolIdVal = UserInfo.getUserRoleId(); 
        String userIdVal =  UserInfo.getUserId();
        List<UserRole> userValObj = [SELECT Id,DeveloperName FROM UserRole WHERE Id=:rolIdVal];  
        List<PermissionSetAssignment> permSetValObj = [SELECT AssigneeId,PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId =:userIdVal];   
        Id profileId= userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        
        //added filter clause userRole permission set 
        if((!userValObj.isEmpty() && (userValObj[0].DeveloperName =='PA_PM1' || userValObj[0].DeveloperName =='PA_PM2' || userValObj[0].DeveloperName =='PA_PM3')) || (!permSetValObj.isEmpty() && (permSetValObj[0].PermissionSet.Name =='PA_DAPS_Special_Permission' || profileName == 'System Administrator'))){
            isMergeCloseoutAccessible = true;
        }

        resultMap.put('mergeCloseOutCheck', isMergeCloseoutAccessible);                                         
        resultMap.put('masterCloseoutTask', closeOutTaskList[0]);
        return  resultMap;                                          
    }

    
    /***********************************************************************************************
    * Method Name   : getProjectsAssociatedCloseOutTask
    * Description  :this Method is used get project which assocoate with closeout task
    * Return          : List of projects
    * Inputs          : String incidentName, String subRecipentName, String closeOutTaskId
    * Author       : Atul
    * Created On      : 26/05/2021
    * Modification Log:  
    * ---------------------------------------------------------------------------------------------*/  
    @AuraEnabled(cacheable=true)
    public static List<Project__c> getProjectsAssociatedCloseOutTask(String incidentName, String subRecipentName, String closeOutTaskId){
        List<Project__c> projectsList = new List<Project__c>();

        List<Project__c> projList = [SELECT Id, Name, CalOES_Project_Number__c, CloseOut_Task__c, Project_Number__c, Obligating_Sub_Recipient__c, Incident_Name__c 
                                     FROM  Project__c 
                                     WHERE Obligating_Sub_Recipient__c=:subRecipentName and Incident_Name__c=:incidentName and 
                                     CloseOut_Task__c=:closeOutTaskId];
        return  projList;                            
    }

    /***********************************************************************************************
    * Method  Name    : getProjectsAssociatedCloseOutTask
    * Description  :this Method is used search closeout task
    * Return          : List of Lookup result which contains closeout task
    * Inputs          : String searchTerm, String incidentId, String subRecipentId, String masterCloseoutTaskId
    * Author       : Atul
    * Created On      : 26/05/2021
    * Modification Log:  
    * ---------------------------------------------------------------------------------------------*/ 

    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> apexSearchCloseoutTask(String searchTerm, String incidentId, String subRecipentId, String masterCloseoutTaskId) {
        Set<String> statusValSet = PA_CONSTANTS.closeoutTaskStatus();
        
        List<Closeout_Task__c> closeoutTaskSourceList = [SELECT Id, Subrecipient_Name__c, Incident__c, RecordTypeId FROM Closeout_Task__c WHERE Id =: masterCloseoutTaskId];
        // prepare SOQL query
         String query = 'Select Id, Name, Incident__c, Subrecipient_Name__r.Name, Incident__r.Name, Status__c, Subrecipient_Name__c From CloseOut_Task__c Where Name != null AND Total_Number_Of_Projects__c > 0';
        // add filter clause only if added by user
            if(String.isNotEmpty(searchTerm)) {
                query += ' AND  Name like\'%' + searchTerm + '%\'';
            }
            query += ' AND  Incident__c =\'' +incidentId+'\' AND Subrecipient_Name__c =\''+subRecipentId+'\'';
            query += ' AND  Status__c NOT IN: statusValSet';
            query += ' AND  Id !=\''+masterCloseoutTaskId+'\'';
            query += ' AND RecordTypeId =\'' + closeoutTaskSourceList.get(0).RecordTypeId+'\'';
            query += ' Limit 200'; 
            system.debug('#query :'+query);   
             List<CloseOut_Task__c> closeOutTaskResultList = Database.query(query);

            List<LookupSearchResult> results = new List<LookupSearchResult>(); 
            String productIcon = 'standard:account';
            for (CloseOut_Task__c closeOutRefResult : closeOutTaskResultList) {
                results.add(
                        new LookupSearchResult(
                                closeOutRefResult.Id,
                                'Account',
                                productIcon,
                                closeOutRefResult.Name,
                                (closeOutRefResult.Status__c !=null ? closeOutRefResult.Status__c: ''),
                                closeOutRefResult
                        )
                );
            }
            // Optionnaly sort all results on title
            results.sort();
           
            return results;    
    }

    /***********************************************************************************************
    * Method Name   : mergeSelectedCloseOutTask
    * Description  :this Method is used to merge closeout task in master
    * Return          : -
    * Inputs          : String selectedCloseoutTaskId, String masterCloseoutTaskId
    * Author       : Atul
    * Created On      : 26/05/2021
    * Modification Log:  
    * ---------------------------------------------------------------------------------------------*/ 
    @AuraEnabled()
    public static void mergeSelectedCloseOutTask(String selectedCloseoutTaskId, String masterCloseoutTaskId){
        
        List<Project__c> updatedProjectList = new List<Project__c>();
        List<Project_Closeout__c> updateProjectCloseOutList = new List<Project_Closeout__c>();
        List<Project__c> selectedCloseoutProjectList = [SELECT Id,Name,CloseOut_Task__c FROM Project__c
                                                       WHERE CloseOut_Task__c =:selectedCloseoutTaskId];
        
        List<Closeout_Task__c> masterCloseOutObj = [SELECT Declaration_Number__c,Id,Incident__c,Name,OwnerId
                                                    FROM Closeout_Task__c
                                                    WHERE Id=:masterCloseoutTaskId LIMIT 1];                                                

        List<Project_Closeout__c> selectedProjectCloseOutList = [SELECT Id,Name,Closeout_Request__c,Closeout_Task__c,Project_Name__c,Status__c,OwnerId
                                                                 FROM Project_Closeout__c
                                                                 WHERE Closeout_Task__c =:selectedCloseoutTaskId];
        List<Document__c> updatedDocumentList = new List<Document__c>();
        List<Document__c> docsList = [SELECT Id, Closeout_Task__c, Document_Name__c FROM Document__c WHERE Closeout_Task__c =:selectedCloseoutTaskId];
        //Selected documents list of closeout task
        if(docsList.size() > 0){
            for(Document__c doc : docsList){
                if(doc.Document_Name__c == 'P.4' ){
                doc.Closeout_Task__c = masterCloseoutTaskId;
                updatedDocumentList.add(doc);
            }
        }
        }

        //Selected projects list of closeout task 
        if(selectedCloseoutProjectList.size() > 0){
            for(Project__c projVal : selectedCloseoutProjectList){
                projVal.CloseOut_Task__c = masterCloseoutTaskId;
                updatedProjectList.add(projVal);
            }
        }

        //Selected projects list of closeout task 
        if(selectedProjectCloseOutList.size() > 0){
            for(Project_Closeout__c projCloseoutVal : selectedProjectCloseOutList){
                projCloseoutVal.Closeout_Task__c = masterCloseoutTaskId;
                projCloseoutVal.OwnerId = masterCloseOutObj[0].OwnerId;
                updateProjectCloseOutList.add(projCloseoutVal);
            }
        }

        //updated projects list 
        if(updatedProjectList.size() > 0){
            update updatedProjectList;
        }

        // updated projects list of closeout task
        if(updateProjectCloseOutList.size() > 0){
            update updateProjectCloseOutList;
        }

        if(updatedDocumentList.size() > 0){
           update updatedDocumentList;
        }

        // Grant Edit Access for Project ....
        CloseoutTaskTriggerHelper cloutTaskTriggerObj = new CloseoutTaskTriggerHelper();
        cloutTaskTriggerObj.grantEditAccessToProjects(masterCloseOutObj);

        //selected closeout task id should not null...
        if(selectedCloseoutTaskId !=null){
            Closeout_Task__c closeoutTaskVal = [SELECT Id,NAME FROM Closeout_Task__c WHERE Id=:selectedCloseoutTaskId LIMIT 1];
            delete closeoutTaskVal;
        }
    }

    /***********************************************************************************************
    * Method Name   : getSalesforceCustomBaseURL
    * Description  :this Method is used get base url
    * Return          : -
    * Inputs          : -
    * Author       : Atul
    * Created On      : 26/05/2021
    * Modification Log:  
    * ---------------------------------------------------------------------------------------------*/  
   
    // Get Base URL from Custom Metadata..To Read Value
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