@isTest(seeAllData=false)
public class HH_TemplateCtrlTest {

    @isTest 
    public static void testGetUserName() {
        Test.startTest();
        HH_TemplateCtrl.getUserName();
        Test.stopTest();
    }
}