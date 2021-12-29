/**
 * Created by Admin on 07-04-2020.
 */

trigger DIP_LeadTrigger on Lead (before insert , before update , after update, after insert ) {
    new DIP_LeadTriggerHandler().process();
}