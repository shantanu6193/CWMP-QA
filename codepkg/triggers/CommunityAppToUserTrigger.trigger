/**
 * Created by Pankaj on 09-07-2020.
 */

trigger CommunityAppToUserTrigger on Community_Application_to_User__c (before delete, after insert, after update) {
    new CommunityAppToUserTriggerHelper().process();
}