public with sharing class ContactRoleTriggerHelper extends TriggerHelper
{
    public override void processBeforeInsert() 
    {
        avoidDuplicateContactRole();
    }
    //This method is used to prevent creation of Duplicate Contact Role Record....
    private void avoidDuplicateContactRole(){
        Set<Id> accountIds = new Set<Id>(); //To collect the Account Ids...
        Set<Id> contactIds = new Set<Id>(); //TO collect the Contact Ids...
        for(AccountContactRole__c conRole : (List<AccountContactRole__c>) Trigger.new) {
            if (conRole.Account_Name__c != null) {
                accountIds.add(conRole.Account_Name__c); //Collecting the Account Id...
            }
            if (conRole.Contact_Name__c != null) {
                contactIds.add(conRole.Contact_Name__c); //Collecting the Contact Id...
            }
        }
        if (!accountIds.isEmpty() && !contactIds.isEmpty()) { //Checking for null pointer exception.....
            //Fetching all the Contact Roles whose account are in "accountIds" collection and Contacts are in "contactids" collection...
            List<AccountContactRole__c> existingRole = [SELECT Id, Name, Account_Name__c, Contact_Name__c FROM AccountContactRole__c
            WHERE Account_Name__c IN : accountIds AND Contact_Name__c IN : contactIds];
            for(AccountContactRole__c conRole : (List<AccountContactRole__c>) Trigger.new) {
                for (AccountContactRole__c acRole : existingRole) { //Iteartiung the existing Contact roles..
                    if (acRole.Account_Name__c == conRole.Account_Name__c && acRole.Contact_Name__c == conRole.Contact_Name__c) { // Checking for the Contact Role with same Account and Contact..
                        conRole.addError(System.Label.REAL_ContactRole_DuplicateError); // Displaying the error...
                    }
                }
            }
        }
    }
}