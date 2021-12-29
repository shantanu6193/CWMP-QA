/**
 * Created by Admin on 13-05-2020.
 */

trigger SupportResourceTrigger on Support_Resource__c (after insert, after update) {
    new SupportResourceTriggerHelper().process();
}