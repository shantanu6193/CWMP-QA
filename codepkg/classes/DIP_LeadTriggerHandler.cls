/***********************************************************************************************************************************
* Class Name   : DIP_LeadTriggerHandler
* Description  : This handler class for DIP_Lead Trigger
* Author       : Pankaj
* Created On   : 04/07/2020
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Pankaj             04/07/2020       Initial Implementation
**************************************************************************************************************************************/

public without sharing class DIP_LeadTriggerHandler extends TriggerHelper {

    /***********************************************
    * Method Name : processBeforeInsert
    * Author : Pankaj
    * Inputs : -
    * Description: This method call before the records are insert 
    *********************************************/
    public Override void processBeforeInsert() {

        //Sets the parent to duplicate lead
        Map<String,Lead> parentLeadsMap = new Map<String, Lead>();

        Set<String> leadEmails = new Set<String>();
        for(Lead lead:(List<Lead>) Trigger.new){
             leadEmails.add(lead.Email);
        }

        parentLeadsMap = getOriginalLeads(leadEmails);

        for(Lead lead:(List<Lead>) Trigger.new){
          if(parentLeadsMap.containsKey(lead.Email)){
              lead.Parent_Lead__c = parentLeadsMap.get(lead.Email).Id;
          }
        }

        //Sets Queue owner field for reports and dashboard
         processForQueueAssignment();

    }

    /***********************************************
    * Method Name : processBeforeUpdate
    * Author : Pankaj
    * Inputs : -
    * Description: This method call before the records are update 
    *********************************************/
    public  Override void processBeforeUpdate() {
        processForQueueAssignment();
        markUnresponsiveForQueueChange();

    }

    /***********************************************
    * Method Name : processAfterUPdate
    * Author : Pankaj
    * Inputs : -
    * Description: This method call after the records are update 
    *********************************************/
    public  Override void processAfterUPdate() {

          processConvertedLeads();


    }

    /***********************************************
    * Method Name : processAfterInsert
    * Author : Pankaj
    * Inputs : -
    * Description: This method call after the records are insert 
    *********************************************/
    public  Override void processAfterInsert() {
        deleteLeads();
  }

    /***********************************************
    * Method Name : getOriginalLeads
    * Author : Pankaj
    * Inputs : Set<String> leadEmails
    * Description: This method map of original Leads
    *********************************************/
    private Map<String,Lead> getOriginalLeads( Set<String> leadEmails) {
        Map<String,Lead> parentLeadsMap = new Map<String, Lead>();

        List<Lead> leadsList = [Select Id,Email from Lead  Where Email IN : leadEmails AND Parent_Lead__c = NUll ORDER BY CreatedDate DESC ];

        for(Lead lead : leadsList){
            parentLeadsMap.put(lead.Email,lead);
        }

        return parentLeadsMap;
    }

    /***********************************************
    * Method Name : processForQueueAssignment
    * Author : Pankaj
    * Inputs : -
    * Description: This method process the Queue assignment for Leads 
    *********************************************/
    private void processForQueueAssignment( ) {

        Map<Id,Id> leadToQueueIds = new Map<Id, Id>();
        Map<Id,Id> leadToUserIds = new Map<Id, Id>();

        for(Lead lead:(List<Lead>) Trigger.new){

            Lead oldLead;
            if(Trigger.isUpdate){
                oldLead =(Lead) Trigger.oldMap.get(lead.Id);
            }

            if((oldLead != null && oldLead.OwnerId != lead.OwnerId) || Trigger.isInsert ) {
                if (lead.OwnerId.getSobjectType() == Schema.Group.getSObjectType()) {
                    leadToQueueIds.put(lead.Id, lead.OwnerId);
                } else if (lead.OwnerId.getSobjectType() == Schema.User.getSObjectType()) {
                    leadToUserIds.put(lead.Id, lead.OwnerId);
                }
            }

        }

        Map<Id,Group> queueOwnerMap = new Map<Id, Group>( [Select Id, Name From Group Where Type='Queue' AND Id In :leadToQueueIds.values()]);
        Map<Id,User> userOwnerMap = new Map<Id, User>( [Select Id, Name , Parent_Queue__c From User Where  Id In :leadToUserIds.values()]);


        for(Lead lead:(List<Lead>) Trigger.new) {
            Lead oldLead;
            if (Trigger.isUpdate) {
                oldLead = (Lead) Trigger.oldMap.get(lead.Id);
            }


            if ((oldLead != null && oldLead.OwnerId != lead.OwnerId) || Trigger.isInsert) {

                if (lead.OwnerId.getSobjectType() == Schema.Group.getSObjectType()) {
                    //  lead.Queue_Owner__c = lead.Owner.Name;
                    Group g = queueOwnerMap.get(lead.OwnerId);
                    lead.Queue_Owner__c = g.Name;
                } else if (lead.OwnerId.getSobjectType() == Schema.User.getSObjectType()) {
                    /* User u = (User)lead.Owner ;
                lead.Queue_Owner__c = u.Parent_Queue__c;*/
                    User u = userOwnerMap.get(lead.OwnerId);
                    lead.Queue_Owner__c = u.Parent_Queue__c;
                }

            }
        }

    }

    /***********************************************
    * Method Name : processConvertedLeads
    * Author : Pankaj
    * Inputs : -
    * Description: This method process the converted Leads
    *********************************************/
    private void processConvertedLeads(){

        //List<Lead> convertedLeadsList = new List<Lead>();
        Map<Id,Id> leadToOppIdsMap = new Map<Id, Id>();

        for (Lead lead : (List<Lead>) Trigger.new) {

            if(lead.IsConverted == true){

                //convertedLeadsList.add(lead);
                leadToOppIdsMap.put(lead.Id , lead.ConvertedOpportunityId);
            }
        }

        // method to add opportunity Id to all history records for Lead that is converted
        updateRelatedHistoryRecords(leadToOppIdsMap);
    }

    /***********************************************
    * Method Name : markUnresponsiveForQueueChange
    * Author : Pankaj
    * Inputs : -
    * Description: This method mark unresponsive for queue changes
    *********************************************/
    private void markUnresponsiveForQueueChange (){
        for(Lead lead:(List<Lead>) Trigger.new) {
            Lead oldLead;
            if (Trigger.isUpdate) {
                if(lead.Queue_Owner__c!=null && ! (lead.Queue_Owner__c.equalsIgnoreCase(((Lead)(Trigger.oldMap.get(lead.Id))).Queue_Owner__c)) )

                    lead.Unresponsive__c = false;
            }

        }

    }

    /***********************************************
    * Method Name : updateRelatedHistoryRecords
    * Author : Pankaj
    * Inputs : Map<Id,Id> leadToOppIdsMap
    * Description: This method update the related history records 
    *********************************************/
    private void updateRelatedHistoryRecords(Map<Id,Id> leadToOppIdsMap){

        List<Lead_Status_History_Tracker__c> historyRecordsList = [Select Id , Lead__c , Opportunity__c  From Lead_Status_History_Tracker__c Where Lead__c IN :leadToOppIdsMap.keySet()];

        for(Lead_Status_History_Tracker__c historyRecord : historyRecordsList){
            historyRecord.Opportunity__c = leadToOppIdsMap.get(historyRecord.Lead__c);
        }

        update historyRecordsList;

    }

    /***********************************************
    * Method Name : deleteLeads
    * Author : Pankaj
    * Inputs : -
    * Description: This method delete leads if company name contains google, yahoo etc. Can be added in custom metadata Lead_Company_Name
    *********************************************/
    private static void deleteLeads(){
        String companyNames = KeyValueHelper.getTextValue('Lead_Company_Name');
        List<String> companyNameList = companyNames.split(',');
        List<Lead> deleteLeadList = new List<Lead>();
        for(Lead leadRec : (List<Lead>) Trigger.new) {
            if(leadRec.Company != null){
                if(companyNameList.contains(leadRec.Company.toLowerCase())){
                    Lead tempLead = new Lead(Id=leadRec.Id);
                    deleteLeadList.add(tempLead);
                }
            }
        }
        
        delete deleteLeadList;
   }    

}