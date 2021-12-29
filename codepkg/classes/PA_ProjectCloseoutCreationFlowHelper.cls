/*************************************************************************************
* Class Name   : PA_ProjectCloseoutCreationFlowHelper
* Description  : this flow is used to create project closoeut in flow when update percent to complete field 100 %
* Author       : Prajakta
* Created On   : 17/11/2021
* Modification Log:  
* -----------------------------------------------------------------------
* Developer             Date             Description 
* -----------------------------------------------------------------------
* Prajakta               17/11/2021     Initial Implementation
**************************************************************************************/

public with sharing class PA_ProjectCloseoutCreationFlowHelper {

    @InvocableMethod(label='Creation Of Project Closeout' description='Creation Of Project Closeout')
    public static List<List<String>> createProjectCloseout( List<projectListData> projectData){
        
        List<Project__c> inputCollection = projectData[0].inputCollection;
        List<String> projectClosRecordIds = new List<String>();
        List<List<String>> projectClosRecordIds2 = new List<List<String>>();
        List<Group> recordOwner= [SELECT Id FROM Group  WHERE DeveloperName ='Public_Assistance_Analyst' AND Type='Queue'];
        Set<String> projectIds = new Set<String>();
        for(Project__c projRec : inputCollection) {
            projectIds.add(projRec.Id);
        }
        List<Project_Closeout__c> projcloseout = [Select id,Project_Name__c from Project_Closeout__c Where Project_Name__c In:projectIds];
        Set<Id> projCloseoutIds = new Set<Id>();
        for(Project_Closeout__c projClo : projcloseout){
            projCloseoutIds.add(projClo.Project_Name__c);
        }

        List<Project_Closeout__c> projectCloseoutToInitiateList = new List<Project_Closeout__c>();
        List<Project__c> projectList = new List<Project__c>();
        for(Project__c projRec : inputCollection) {
            if(projCloseoutIds.contains(projRec.Id)) continue;
            Project_Closeout__c closeoutInitiate = new Project_Closeout__c();
            closeoutInitiate.Project_Name__c = projRec.Id;
            closeoutInitiate.Status__c = 'Request for Closeout';
            if(recordOwner.size() > 0) {
                closeoutInitiate.OwnerId = recordOwner[0].Id;
            }
            projectCloseoutToInitiateList.add(closeoutInitiate);


        }
        PA_SystemContextHelper.upsertProjectCloseouts(projectCloseoutToInitiateList);
        List<Project_Closeout__Share> projectCloseoutShareListToInsert = new List<Project_Closeout__Share>();
        List<projectCloseoutId> responseWrapper= new List<projectCloseoutId>();
        for(Project_Closeout__c prjCloseOut :projectCloseoutToInitiateList){
            projectCloseoutId response = new projectCloseoutId();
            response.recId = prjCloseOut.Id;
            responseWrapper.add(response);
            projectClosRecordIds.add(prjCloseOut.Id);
            Project_Closeout__Share projectCloseoutShare = new Project_Closeout__Share();
            // Set the ID of record being shared
            projectCloseoutShare.ParentId = prjCloseOut.Id;
            // Set the ID of user or group being granted access
            projectCloseoutShare.UserOrGroupId = UserInfo.getUserId();
            // Set the access level
            projectCloseoutShare.AccessLevel = 'Read';
            projectCloseoutShare.RowCause = Schema.Project_Closeout__Share.RowCause.ProjectCloseoutShare__c;

            // Add objects to list for insert
            projectCloseoutShareListToInsert.add(projectCloseoutShare);

        }
        PA_SystemContextHelper.insertProjectCloseoutShareRecords(projectCloseoutShareListToInsert);
        projectClosRecordIds2.add(projectClosRecordIds);
        return projectClosRecordIds2;

    }
   
    public class projectListData {
        @InvocableVariable(label='Creation Of Project Closeout Records' description='Creation Of Project Closeout Records' required=true)
        public List<Project__c> inputCollection;
    }

    public class projectCloseoutId {
        @InvocableVariable(label='Project Closeout Records' description='Project Closeout Records')
        public Id recId;
    }

}