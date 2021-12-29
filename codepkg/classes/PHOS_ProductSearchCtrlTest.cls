/**
 * Created by PREM on 05-10-2020.
 */
@isTest
public with sharing class PHOS_ProductSearchCtrlTest {
    @isTest
    public static void apexSearchProductTest(){
        test.startTest();
            /*Account acc = PHOS_TestHelper.getAccount(false);
            acc.Name = 'testAcc1234';
            acc.Phone='1221223';
            acc.Website='https://www.google133.com';
            insert acc;
            Contact con = PHOS_TestHelper.getPortalContact(false);
            con.AccountId = acc.Id;
            insert con;
            Profile p = [select Id,name from Profile where Name like 'PHOS Customer Community Plus Login User' limit 1];
            User u = PHOS_TestHelper.getPortalUser(false);
            u.Email = 'tteetttaggg@gmail.com';
            u.ContactId = con.Id;
            u.ProfileId = p.Id;
            insert u;
            System.runAs(u){
                Order_Product__c orderItem = PHOS_TestHelper.getOrderItemgoggle(true);*/
                //List<Product2> products = new List<Product2>();
                Product2 product1 = PHOS_TestHelper.getProductMask(true);
                List<Product2> productList = new List<Product2>();
        		productList.add(product1);
                List<LookupSearchResult> resultList = PHOS_ProductSearchCtrl.apexSearchProduct('cloth Mask');

            
        test.stopTest();
    }
}