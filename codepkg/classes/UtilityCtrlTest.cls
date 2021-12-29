@IsTest
private  class UtilityCtrlTest {
    
    @IsTest
    public static void test1() {
        Test.startTest();
        System.runAs(new User(Id=UserInfo.getUserId())) {
            UtilityCtrl.isGuestUser();
        }
        Test.stopTest();
    }
}