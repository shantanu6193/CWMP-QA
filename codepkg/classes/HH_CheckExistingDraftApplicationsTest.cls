@isTest(seeAllData=false)
public class HH_CheckExistingDraftApplicationsTest {

    @isTest 
    public static void testGetExistingDraftApplicationsCount() {
        Test.startTest();
        HH_CheckExistingDraftApplicationsCtrl.getExistingDraftApplicationsCount();
        Test.stopTest();
    }
}