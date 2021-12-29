/**
 * Created by Admin on 28-04-2020.
 */

Global with sharing class DIP_BackUpdateTracker_Batch implements Database.Batchable <sObject>,Database.Stateful{

        global Integer recordsProcessed = 0;
        global Database.QueryLocator start(Database.BatchableContext bc) {
            String query='Select Id, Email , Name ,Parent_Lead__c from Lead Where Parent_Lead__c=null  ORDER BY Email';
           /*
            String query = 'Select Id , Queue_Owner__c , Days_in_Current_Queue_c__c , Unresponsive__c,' +
                    '(Select Id , ActivityDateTime , ActivitySubtype , CreatedDate from ActivityHistories Where ActivitySubtype = \'Email\'  ORDER BY CreatedDate DESC  LIMIT 1) ' +
                    'From Lead Where IsConverted=false AND Queue_Owner__c!=null';*/
            System.debug('Query String in Start ------- >  '+query);
            return database.getQueryLocator(query);
        }

    global void execute(Database.BatchableContext param1, List<Lead> allLeads) {
        Set<String> processedLeads = new Set<String>();
        Map<String,List<Lead>> parentChildMap = new Map<String, List<Lead>>();
        List<Lead> toUpdate =new List<Lead>();

        for(Lead lead:allLeads){
            processedLeads.add(lead.Id);
            List<Lead> leadMatch = new List<Lead>();
            //System.debug('processedLeads ' +processedLeads);
            for(Lead underProcessingLead:allLeads) {
                if((underProcessingLead.Parent_Lead__c == Null) &&
                        !processedLeads.contains(underProcessingLead.Id) &&
                        (lead.Email !=null && underProcessingLead.Email!=null && lead.Email.equalsIgnoreCase(underProcessingLead.Email)
                        )){
                    leadMatch.add(underprocessingLead);
                    underProcessingLead.Parent_Lead__c = lead.Id;
                    processedLeads.add(underProcessingLead.Id);
                }
            }
            if(leadMatch.size()>0) {
                parentChildMap.put(lead.Id, leadMatch);
                toUpdate.addAll(leadMatch);
            }
        }

//System.debug(allLeadsMap.get('00Qr0000001cj1JEAQ'));
        System.debug(parentChildMap.size());
        System.debug(toUpdate);
update toUpdate;


    }

    global void finish(Database.BatchableContext param1) {
    }
}