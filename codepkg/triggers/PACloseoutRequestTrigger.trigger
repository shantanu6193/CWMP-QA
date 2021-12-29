/**
 * Created by hp on 16-06-2021.
 */

trigger PACloseoutRequestTrigger on Closeout_Request__c (after update, after insert, before insert, before update) {
    new PA_CloseoutRequestTriggerHelper().process();
}