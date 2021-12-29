/**
 * Created by Admin on 07-04-2020.
 */

@IsTest
private class DIP_LeadTriggerTest {
    @IsTest
    static void testBehavior() {

        Test.startTest();
        Lead ParentLead = new Lead(FirstName = 'Test',LastName = 'Original' , Email ='dummy@test.com' , Company ='test Company');
        insert Parentlead;

        Lead ChildLead = new Lead(FirstName = 'Test',LastName = 'Child' , Email ='dummy@test.com' , Company ='test Child Company');
        insert ChildLead;

        Test.stopTest();
    }

}