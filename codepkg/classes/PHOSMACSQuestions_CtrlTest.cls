/**
 * Created by Shivraj on 13-01-2021.
 */
@IsTest
public with sharing class PHOSMACSQuestions_CtrlTest {
    @isTest public static void testBehaviour(){
        Order__c order = PHOS_TestHelper.getOrder(false);
        insert order;
        String data = '{"What_is_the_county_s_7_day_case_rate__c":"100-175","ICU_beds_available_in_the_County__c":"< 15%","What_is_the_county_s_population_density__c":"> 500 ppl p/sq. mi","Population_65_years_old_in_county__c":"10-15%","Is_the_facility_a_specialty_center__c":"3 disciplines"}';
        PHOSMACSQuestions_Ctrl.submitRequest(data, order.Id);
        PHOSMACSQuestions_Ctrl.getRecordData(order.Id);
    }
}