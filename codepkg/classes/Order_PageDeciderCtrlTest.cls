/**
 * Created by PREM on 31-07-2020.
 */

@isTest(SeeAllData=true) public with sharing class Order_PageDeciderCtrlTest {

    @isTest(SeeAllData=true) public static void testGetInitData(){
//        List<User> userList = [SELECT Id from User WHERE IsActive = true];
//        for(User newUser : userList){
//            System.runAs(newUser){
//                List<UserAppInfo> userApp = [SELECT Id, AppDefinitionId
//                FROM UserAppInfo WHERE UserId = :UserInfo.getUserId()];
//                if(userApp.size()>0){
//                    Map<String, Object> returnMap = new Map<String, Object>();
//                    Opportunity newOpportunity = PHOS_TestHelper.getOpportunity(true);
//                    String oppId = String.valueOf(newOpportunity.id);
//                    test.startTest();
//                    returnMap = Order_PageDeciderCtrl.getInitData(oppId);
//                    System.assert(returnMap.size()>0);
//                    test.stopTest();
//                    break;
//                }
//            }
//        }
    }
}