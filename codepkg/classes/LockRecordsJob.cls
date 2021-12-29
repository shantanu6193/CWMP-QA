/**
 * Created by Neha on 09-03-2021.
 */

public with sharing class LockRecordsJob implements Database.Batchable<sObject>, Schedulable {
    private final String query;

    public LockRecordsJob(String query) {
        this.query = query;
    }

    // Schedulable method
    public void execute(SchedulableContext ctx) {
        Database.executeBatch(new LockRecordsJob(query));
    }

    // Database.Batchable methods
    public Database.QueryLocator start(Database.BatchableContext bc) {
        List<String> stagelist = new List<String>();
        stagelist.add('Paid');
        stagelist.add('Returned Project Payment'); 
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<sObject> scope) {
        List<String> prIdsToLock = new List<String>();
        List<String> transmittalIdsToLock = new List<String>();
        List<String> paymentIdsToLock = new List<String>();
        if(scope.size() > 0) {
            for(SObject sc : scope) {
                Payment_Request__c pr = (Payment_Request__c) sc;
                prIdsToLock.add(pr.Id);
                for (Transmittal__c tr : pr.Transmittals__r) {
                    transmittalIdsToLock.add(tr.Id);
                }
                /*for (Payment__c payment : pr.Payments__r) {
                    paymentIdsToLock.add(payment.Id);
                }*/
            }
            System.debug(prIdsToLock);
            System.debug(transmittalIdsToLock);
            System.debug(paymentIdsToLock);

            //ApexUtils.lockRecord(paymentIdsToLock);
            ApexUtils.lockRecord(transmittalIdsToLock);
            ApexUtils.lockRecord(prIdsToLock);
        }
    }

    public void finish(Database.BatchableContext bc) {
    }
}