@IsTest
public with sharing class DIP_Mark_Lead_Unresponsive_SchedulerTest {
    
    public static testMethod void testschedule() {

        Test.StartTest();
        DIP_Mark_Lead_Unresponsive_Scheduler sh1 = new DIP_Mark_Lead_Unresponsive_Scheduler();
        
        String sch = '0 0 23 * * ?'; 
        system.schedule('Test Territory Check', sch, sh1);
         Test.stopTest(); }
}