@isTest
private class MARS_AgencyPageTabCtrlTest {
    static testMethod void getAccountDetailstest() {
        Account acct = TestUtility.createAccount('test');
        MARS_AgencyPageTabCtrl.getData(acct.Id);
    }
}