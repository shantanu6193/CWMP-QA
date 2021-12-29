/**
 * Created by PREM on 03-11-2020.
 */

trigger AccountTrigger on Account (before insert, before update, after update) {
    new AccountTriggerHelper().process();
}