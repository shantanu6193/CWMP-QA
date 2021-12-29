public without sharing class MARS_Incident_Search_Ctrl {



        @AuraEnabled(cacheable=true)
        public static list<Incident__c> getIncidentList(string searchKey) {
            string searchKeyword = '%' + searchKey + '%';
            
           // create Incident__c list to store search result 
           list<Incident__c> incidentListRecord = new list<Incident__c>();
         
           // query Incident__c records
            for(Incident__c conObj : [Select Id, Name, Event_Type__c, isActive__c, Order_No__c, Year__c,
                                       Incident_Start_Date__c, Incident_End_Date__c 
                                       From Incident__c
                                       WHERE Available_for_Application__c   INCLUDES ('MARS') and Name LIKE : searchKeyword ]){
               incidentListRecord.add(conObj);
            }
            
             if(incidentListRecord.size() == 0){
                throw new AuraHandledException('No Record Found..'); 
             }
             
            return incidentListRecord;
        }
        @AuraEnabled(cacheable=true)
        public static list<Incident__c> getIncidentListByNumber(string searchnum) {
            string searchNumber = '%' + searchnum + '%';
            
           // create Incident__c list to store search result 
           list<Incident__c> incidentListRecord = new list<Incident__c>();
         
           // query Incident__c records
            for(Incident__c conObj : [Select Id, Name, Event_Type__c, isActive__c, Order_No__c, Year__c,
                                       Incident_Start_Date__c, Incident_End_Date__c 
                                    From Incident__c
                                WHERE  Available_for_Application__c   INCLUDES ('MARS') and Order_No__c like : searchNumber ]){
               incidentListRecord.add(conObj);
            }
            
             if(incidentListRecord.size() == 0){
                throw new AuraHandledException('No Record Found..'); 
             }
             
            return incidentListRecord;
        }

}