/***********************************************************************************************************************************
* Class Name   : UserService
* Description  : This Batch Class for Sharing Project Records during User Reg Flow
* Author       : Atul
* Created On   : 05/24/2021
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Atul                05/24/2021       Initial Implementation
**************************************************************************************************************************************/

public  class UserRegistrationPostActionBatch  implements Database.Batchable<CommAppActionClass>, Database.Stateful {

    List<Community_Application_to_User__c> commAppToUserLst = new List<Community_Application_to_User__c>();
    List<String> postDeserializeActiveActionList = new List<String>();
    String userId;

    public UserRegistrationPostActionBatch(String commAppPostActionJSON, String userId) {
        postDeserializeActiveActionList = (List<String>)JSON.deserialize(commAppPostActionJSON, List<String>.class);
        this.userId = userId;
    }

    public Iterable<CommAppActionClass> start(Database.BatchableContext bc) {
        List<CommAppActionClass> finalCommAppPostActionList = new List<CommAppActionClass>();
        for(String postActiveActionVal : postDeserializeActiveActionList){
            List<CommAppActionClass> commAppPostActionList = ( List<CommAppActionClass>)JSON.deserialize(postActiveActionVal, List<CommAppActionClass>.class); 
            finalCommAppPostActionList.addAll(commAppPostActionList);   
        }
        return finalCommAppPostActionList;
    }

    public void execute(Database.BatchableContext BC, List<CommAppActionClass> comAppPostActionList) {
        Map<Id, Set<Id>> applicationIdToUserIds = new Map<Id, Set<Id>>();
        for(CommAppActionClass commAppActionClass : comAppPostActionList) {
            if(CommAppActionClass.action == 'ShareProject') {
                ProjectSharingHelper.skipSendEmail = true;
                ProjectSharingHelper.shareRecords(commAppActionClass.value);
            }
            if(CommAppActionClass.action == 'ShareSubApplication'){
                if(applicationIdToUserIds.get(CommAppActionClass.value) == null) {
                    applicationIdToUserIds.put(CommAppActionClass.value, new Set<Id>());
                }
                applicationIdToUserIds.get(CommAppActionClass.value).add(this.userId);
            }
        }
        if(applicationIdToUserIds.size() > 0) {
            HMA_Utility.shareCustomObjectRecordsWithUser(applicationIdToUserIds, 'Application__share', 'Edit', Schema.Application__share.RowCause.Shared_with_Responsible_Representative__c);
            HMA_Utility.shareApplicationRelatedDocumentsWithSpecificUser(applicationIdToUserIds);
            HMA_Utility.shareProjectSiteRelatedDocumentsWithSpecificUser(applicationIdToUserIds);
        }
    }

    public void finish(Database.BatchableContext BC){

    }

     public class CommAppActionClass {
        public String action;
        public String value;
    }
    
}