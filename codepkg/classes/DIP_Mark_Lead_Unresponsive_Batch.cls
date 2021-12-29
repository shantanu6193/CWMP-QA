/***********************************************************************************************************************************
* Class Name   : DIP_Mark_Lead_Unresponsive_Batch
* Description  : This batch class for DIP mark Lead unresponsive
* Author       : Pankaj
* Created On   : 04/22/2020
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Pankaj             04/22/2020       Initial Implementation
**************************************************************************************************************************************/

Global with sharing class DIP_Mark_Lead_Unresponsive_Batch  implements Database.Batchable <sObject>,Database.Stateful{

    global Integer recordsProcessed = 0;
    global Database.QueryLocator start(Database.BatchableContext bc) {
       /* String query = 'Select Id , Requests_Follow_up_with_State_Contact__c, Queue_Owner__c , Days_in_Current_Queue_c__c , Unresponsive__c,' +
                '(Select Id , ActivityDateTime , ActivitySubtype , CreatedDate from ActivityHistories Where ActivitySubtype = \'Email\' OR  ActivitySubtype = \'ListEmail\'  ORDER BY CreatedDate DESC  LIMIT 1) ' +
                'From Lead Where IsConverted=false AND Queue_Owner__c!=null';*/
        String query = 'Select Id , Requests_Follow_up_with_State_Contact__c, Queue_Owner__c , ' +
                'Days_in_Current_Queue_c__c , Unresponsive__c,' +
                '(Select Id , ActivityDateTime , ActivitySubtype , CreatedDate from ActivityHistories ORDER BY CreatedDate DESC  LIMIT 1) ,' +
                '(Select Id ,CreatedDate from Events  ORDER BY CreatedDate DESC  LIMIT 1) ' +
                ' From Lead Where IsConverted=false AND Queue_Owner__c!=null';
        System.debug('Query String in Start ------- >  '+query);
        return database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<Lead> allLeadsList) {

        List<Lead> toUpdate = new List<Lead>();

        Datetime ActivityHistoryDatetime ;
        Datetime EventDatetime ;
        Datetime compareDatetime;


        for(Lead lead :allLeadsList){

            if(lead.ActivityHistories != null && lead.ActivityHistories.size()>0){
                ActivityHistoryDatetime = lead.ActivityHistories[0].CreatedDate;
            }
            if(lead.Events != null && lead.Events.size()>0){
                EventDatetime = lead.Events[0].CreatedDate;
            }
            if(ActivityHistoryDatetime != null && EventDatetime !=null){
                compareDatetime = ActivityHistoryDatetime > EventDatetime ? ActivityHistoryDatetime : EventDatetime;
            }

            if(ActivityHistoryDatetime == null && EventDatetime != null){
                compareDatetime = EventDatetime;
            }

            if(EventDatetime == null && ActivityHistoryDatetime != null){
                compareDatetime = ActivityHistoryDatetime;
            }


            if(lead.Queue_Owner__c == 'COVID - Contributions Group - Donations'){

                if(lead.Days_in_Current_Queue_c__c!=null && lead.Days_in_Current_Queue_c__c < 7){

                    if(lead.Unresponsive__c == true){

                        lead.Unresponsive__c = false;
                        toUpdate.add(lead);

                    }


                }else if(lead.Days_in_Current_Queue_c__c!=null && lead.Days_in_Current_Queue_c__c >= 7){

                    if(compareDatetime != null){

                        if( compareDatetime.date().daysBetween( System.now().date())  >= 7 ){

                            lead.Unresponsive__c = true;
                            toUpdate.add(lead);
                        }else if(compareDatetime.date().daysBetween( System.now().date())  < 7){

                            lead.Unresponsive__c = false;
                            toUpdate.add(lead);
                        }

                    } else if((lead.ActivityHistories == null || lead.ActivityHistories.size() == 0) && (lead.Events == null || lead.Events.size() == 0)){
                            lead.Unresponsive__c = true;
                            toUpdate.add(lead);
                    }

                }

            } else if(lead.Queue_Owner__c == 'COVID - CDPH Validation Group'){
               /* Boolean followUpWithState = lead.Requests_Follow_up_with_State_Contact__c ;
                Integer dayLimit = followUpWithState ? 1:2;*/

                if(lead.Days_in_Current_Queue_c__c!=null && lead.Days_in_Current_Queue_c__c <= 1){

                    if(lead.Unresponsive__c == true){

                        lead.Unresponsive__c = false;
                        toUpdate.add(lead);

                    }


                }else if(lead.Days_in_Current_Queue_c__c!=null && lead.Days_in_Current_Queue_c__c > 1){

                    if(compareDatetime != null){

                        if( compareDatetime.date().daysBetween( System.now().date())  >= 2 ){

                            lead.Unresponsive__c = true;
                            toUpdate.add(lead);
                        }else if(compareDatetime.date().daysBetween( System.now().date())  < 2){

                            lead.Unresponsive__c = false;
                            toUpdate.add(lead);
                        }

                    } else if((lead.ActivityHistories == null || lead.ActivityHistories.size() == 0)  && (lead.Events == null || lead.Events.size() == 0)){
                        lead.Unresponsive__c = true;
                        toUpdate.add(lead);
                    }

                }

            }

            else{

                if(lead.Days_in_Current_Queue_c__c!=null && lead.Days_in_Current_Queue_c__c < 2){

                    if(lead.Unresponsive__c == true){

                        lead.Unresponsive__c = false;
                        toUpdate.add(lead);

                    }

                }else if(lead.Days_in_Current_Queue_c__c!=null && lead.Days_in_Current_Queue_c__c >= 2){

                    if(compareDatetime != null){

                        if(compareDatetime.date().daysBetween( System.now().date())  >= 2 ){

                            lead.Unresponsive__c = true;
                            toUpdate.add(lead);
                        }else if(compareDatetime.date().daysBetween( System.now().date())  < 2){

                            lead.Unresponsive__c = false;
                            toUpdate.add(lead);
                        }

                    } else if((lead.ActivityHistories == null || lead.ActivityHistories.size() == 0) && (lead.Events == null || lead.Events.size() == 0)){
                        lead.Unresponsive__c = true;
                        toUpdate.add(lead);
                    }

                }

            }

        }
        update toUpdate;
        recordsProcessed += toUpdate.size();
    }

    global void finish(Database.BatchableContext bc) {
        System.debug(recordsProcessed + ' records processed.!');
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors,
                JobItemsProcessed,
                TotalJobItems
        FROM AsyncApexJob
        WHERE Id = :bc.getJobId()];
        System.debug(job + ' job processed.!');
    }

}