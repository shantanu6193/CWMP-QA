/***********************************************************************************************************************************
* Class Name   : PA_ProjectSharingBatch
* Description  : This Batch is run as one time activity to update existing project roles and share projects with users.
* Author       : Prajakta
* Created On   : 26/08/2021
* Modification Log:
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Pankaj            26/08/2021       Initial Implementation
**************************************************************************************************************************************/

global with sharing class PA_ProjectSharingBatch implements Database.Batchable<sObject>, Database.Stateful{
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator('SELECT Id, Incident_Subrecipient_Summary__c, AccountContactJunction__r.Contact_Name__c,  Project_Name__c,Sharing_Batch_Executed__c, Subrecipient__c FROM Project_Role__c where Sharing_Batch_Executed__c = false');
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        List<Project_Role__c> roleList = new List<Project_Role__c>();
        List<Contact> contactList = new  List<Contact>();
        for(Project_Role__c  role : (List<Project_Role__c>)scope) {
            system.debug('role'+role.id);
            contactList  = [SELECT Id, PA_Invitation_Send__c from Contact WHERE Id=:role.AccountContactJunction__r.Contact_Name__c];
            if(contactList.size() > 0 && contactList[0].PA_Invitation_Send__c == true){
            ProjectSharingHelper.skipSendEmail = true;
            }else{
                ProjectSharingHelper.skipSendEmail = false;
                contactList[0].PA_Invitation_Send__c = true;
            }
            ProjectSharingHelper.shareRecords(role.Id);
            role.Sharing_Batch_Executed__c = true;
            roleList.add(role);
            system.debug('roleList------------'+roleList);
            system.debug('contactList[0]------------'+contactList[0]);
        }
        update contactList[0];
        update roleList;

    }

    global void finish(Database.BatchableContext BC) {

    }
}