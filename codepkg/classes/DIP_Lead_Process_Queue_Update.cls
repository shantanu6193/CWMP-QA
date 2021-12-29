/**
 * Created by Neha on 21-04-2020.
 */

global with sharing class DIP_Lead_Process_Queue_Update implements  Database.Batchable<sObject>,Database.Stateful {

    global Integer recordsProcessed = 0;
    global Database.QueryLocator start(Database.BatchableContext bc) {
        // collect the batches of records or objects to be passed to execute
        List<String> FieldStrings = new List<String>();
        FieldStrings.add('Owner');
        FieldStrings.add('Created');
        String query ='Select Id ,Name,Parent_Lead__c,In_Queue_Since__c, (Select Id , OldValue , NewValue , Field , CreatedDate '+
                'From Histories where Field IN (\''+String.join(FieldStrings,'\',\'') + '\') ORDER BY CreatedDate DESC )From Lead Where Days_in_Current_Queue_c__c=null  ' ;
        //where Days_in_Current_Queue_c__c=null

        /*Map<id,Lead> mapAllLeadsByIds = new Map<Id, Lead>([Select Id ,Name,Parent_Lead__c,In_Queue_Since__c, (Select Id , OldValue , NewValue , Field , CreatedDate
       From Histories where Field IN ('Owner','Created') ORDER BY CreatedDate DESC )From Lead where Id ='00Qr0000001XnxjEAC']);*/

        //String.join( fieldNames, ',' ) //(\''+String.join(jobTitlesIdList,'\',\'') + '\')
        System.debug(query);
        return database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<Lead> records){

        // process each batch of records
        Map<Id,LeadHistory> mapLeadToHistoriesDirect = new Map<Id, LeadHistory>();
        Map<Id,LeadHistory> mapLeadToHistoriesGetUsers = new Map<Id, LeadHistory>();
        Map<id,Lead> mapAllLeadsByIds = new Map<Id, Lead>();
        for(Lead l:records){
            mapAllLeadsByIds.put(l.Id,l);
        }
        /*Map<id,Lead> mapAllLeadsByIds = new Map<Id, Lead>([Select Id ,Name,Parent_Lead__c,In_Queue_Since__c, (Select Id , OldValue , NewValue , Field , CreatedDate
        From Histories where Field IN ('Owner','Created') ORDER BY CreatedDate DESC )From Lead where Id ='00Qr0000001XnxjEAC']);*/


        List<Lead> allLeads = mapAllLeadsByIds.values();

for(Lead currentLead:allLeads) {
    for (LeadHistory record : currentLead.Histories) {

        if (record.Field == 'Owner') {
            if (record.OldValue.toString().startsWith('00G') && record.NewValue.toString().startsWith('00G')) {
                mapLeadToHistoriesDirect.put(currentLead.Id, record);
                break;
            }

            else if (record.OldValue.toString().startsWith('005') && record.NewValue.toString().startsWith('005')) {
                List<User> userList = [select Id,Parent_Queue__c from User where Id = :record.OldValue.toString() OR Id = :record.NewValue.toString()];
                if (userList[0] != null && userList[1] != null) {
                    if (userList[0].Parent_Queue__c != userList[1].Parent_Queue__c) {
                        mapLeadToHistoriesDirect.put(currentLead.Id, record);
                        break;
                    }
                }
            }

            else if (record.OldValue.toString().startsWith('005') && record.NewValue.toString().startsWith('00G')) {
                User user = [select Id, Parent_Queue__c from User where Id = :record.OldValue.toString()][0];
                Group queue = [SELECT Id, Name from Group Where Type = 'Queue' And Id = :record.NewValue.toString()][0];
                if (user.Parent_Queue__c != null && !(user.Parent_Queue__c.equalsIgnoreCase(queue.Name))) {
                    mapLeadToHistoriesDirect.put(currentLead.Id, record);
                    break;
                }

                else if (user.Parent_Queue__c == null) {
                    mapLeadToHistoriesDirect.put(currentLead.Id, record);
                    break;
                }

            }

            else if (record.NewValue.toString().startsWith('005') && record.OldValue.toString().startsWith('00G')) {
                User user = [select Id, Parent_Queue__c from User where Id = :record.NewValue.toString()][0];
                Group queue = [SELECT Id, Name from Group Where Type = 'Queue' And Id = :record.OldValue.toString()][0];
                if (user.Parent_Queue__c != null && !(user.Parent_Queue__c.equalsIgnoreCase(queue.Name))) {
                    mapLeadToHistoriesDirect.put(currentLead.Id, record);
                    break;
                } else if (user.Parent_Queue__c == null) {
                    mapLeadToHistoriesDirect.put(currentLead.Id, record);
                    break;
                }

            }

        } else if (record.Field == 'Created') {
            mapLeadToHistoriesDirect.put(currentLead.Id, record);
            break;
        }
    }
}

        System.debug(mapLeadToHistoriesDirect);

        for(Lead lead:allLeads){
            System.debug(lead.Id+ '***************************' + mapLeadToHistoriesDirect.get(lead.Id));
            if(mapAllLeadsByIds.get(lead.Id)!=null && mapLeadToHistoriesDirect.get(lead.Id)!=null) {
                Lead toUpdate = mapAllLeadsByIds.get(lead.Id);
                toUpdate.In_Queue_Since__c = mapLeadToHistoriesDirect.get(lead.Id).CreatedDate;
            }
        }

        recordsProcessed += allLeads.size();
        update allLeads;

    }
    global void finish(Database.BatchableContext bc){
        System.debug(recordsProcessed + ' records processed.!');
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors,
                JobItemsProcessed,
                TotalJobItems
        FROM AsyncApexJob
        WHERE Id = :bc.getJobId()];
        System.debug(job + ' job processed.!');
        // execute any post-processing operations
    }

}