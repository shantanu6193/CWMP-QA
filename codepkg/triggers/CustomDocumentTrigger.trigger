/**
 * Created by nehab on 14-10-2020.
 */

trigger CustomDocumentTrigger on Document__c (after update) {
    new CustomDocumentTriggerHelper().process();
}