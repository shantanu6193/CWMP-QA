/**
 * Created by Shivraj on 02-09-2020.
 */

trigger ProductDistributionPlanTrigger on Product_Distribution_Plan__c (before insert, before update, after insert,after update, before delete) {
    new ProductDistributionPlanHelper().process();
}