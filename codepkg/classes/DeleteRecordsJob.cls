/**
 * Created by Neha on 26-02-2021.
 */

public with sharing class DeleteRecordsJob implements Database.Batchable<sObject>, Schedulable {
    private final String query;

    public DeleteRecordsJob(String query) {
        this.query = query;
    }

    // Schedulable method
    public void execute(SchedulableContext ctx) {
        Database.executeBatch(new DeleteRecordsJob(query));
    }

    // Database.Batchable methods
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<sObject> scope) {
        delete scope;
    }

    public void finish(Database.BatchableContext bc) {
    }
}