/**
 * Created by Sushant p on 16-04-2021.
 */

public with sharing class UpdateSupplementAwardJob implements Database.Batchable<sObject>, Schedulable, Database.Stateful {
    private final String query;

    public UpdateSupplementAwardJob(String query) {
        this.query = query;
    }
    // Schedulable method
    public void execute(SchedulableContext ctx) {
        Database.executeBatch(new UpdateSupplementAwardJob(query));
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<sObject> scope) {
        set<Id> awardsToUpdate = new set<Id>();
        for(SObject sc : scope) {
            Award__c aw = (Award__c) sc;
            awardsToUpdate.add(aw.Id);
        }

        //List<Award__c> awardList =[SELECT Id,Amendment_Request__r.SupplementAward__c FROM Award__c WHERE Amendment_Request__c != null];
        List<Award__c> awardList =[SELECT Id,Amendment_Request__r.SupplementAward__c FROM Award__c WHERE Id IN : awardsToUpdate];
        for(Award__c awd :awardList){
            awd.Supplement_Award__c = awd.Amendment_Request__r.SupplementAward__c == null?0.00:awd.Amendment_Request__r.SupplementAward__c;
        }
        update awardList;
    }


    public void finish(Database.BatchableContext bc) {
    }

}