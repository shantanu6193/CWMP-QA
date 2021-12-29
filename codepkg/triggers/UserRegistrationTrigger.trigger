trigger UserRegistrationTrigger on User_Registration__c (after update) {
     new UserRegistrationHelper().process();
}