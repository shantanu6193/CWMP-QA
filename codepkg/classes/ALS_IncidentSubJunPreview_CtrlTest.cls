/**
 * Created by StackNexus Admin on 25-01-2021.
 */

@IsTest
private class ALS_IncidentSubJunPreview_CtrlTest {
    @IsTest
    static void testBehavior() {
        Account acc = new Account(Name='test12f', Entity_Type__c=ALS_CONSTANTS.Account_EntityType_City);
        insert acc;
        Incident__c incident =new Incident__c(Name='Test ');
        insert  incident;
        Test.startTest();
            ALS_IncidentSubrecipientJunPreview_Ctrl.getIncidentSubrecipientInfo(acc.Id,'');
            ALS_IncidentSubrecipientJunPreview_Ctrl.getIncidentSubrecipientInfo(incident.Id,'');
        Test.stopTest();
    }
}