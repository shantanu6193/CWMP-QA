/**
 * Created by Shivraj on 05-10-2020.
 */
@IsTest(SeeAllData=false)
public class PHOS_DistributionPlanVersionCtrlTest {
    @IsTest
    public static void testPlanVersion() {
        Distribution_Plan_Version__c planData =  PHOS_TestHelper.getPlanVersion(true);
        Test.startTest();
        PHOS_DistributionPlanVersionCtrl.getVersion(planData.Id);
        Test.stopTest();
    }
}