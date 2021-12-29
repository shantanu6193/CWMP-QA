@IsTest(SeeAllData=false)
public with sharing class PHOS_WarehouseSearchCtrlTest {
    @IsTest
    static void testapexSearchWarehouse(){
        
        List<Warehouse_Config__mdt> wareHouseData = [SELECT Id,Account_Id__c,MasterLabel,isActive__c,Send_Email__c,Creation_Status__c
                                                                FROM Warehouse_Config__mdt where MasterLabel =:'Bloomington'];
        Product2 testProd = PHOS_TestHelper.getProductMask(true);
        Warehouse_Product__c wp = new Warehouse_Product__c();
        wp.Product__c = testProd.Id;
        wp.Warehouse__c = '001t000000SKOGNAA5';
        wp.Warehouse_Code_And_SKU_Id__c = 'CV12_P-229211';
        insert wp;
        Inventory__c newInventory = new Inventory__c();
        newInventory.TX_Number__c = '61651';
        newInventory.SKU_Id__c = 'P-229211';
        newInventory.Warehouse_Code_And_SKU_Id__c = 'CV12_P-229211';
        newInventory.Remaining_Inventory__c = 100;
        newInventory.Warehouse_Product__c = wp.Id;
        insert newInventory;
        test.startTest();
        List<LookupSearchResult> result = PHOS_WarehouseSearchCtrl.apexSearchWarehouse('Bloomington','P-229211');
        test.stopTest();
        System.assertNotEquals(result.size(),0);
    }
}