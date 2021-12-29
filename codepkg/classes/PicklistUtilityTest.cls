@isTest public class PicklistUtilityTest {
    
    @isTest public static void testGetPicklistOptions(){
        
        test.startTest();
        List<Map<String, String>> returnList =  PicklistUtility.getPicklistOptions('Account', 'AccountSource');
        test.stopTest();
        System.assert(returnList.size() > 0);
    }
    
    @isTest public static void testGetPicklistOptionsDifferentPar(){
        
        Schema.SObjectType sObjectType = SkyWalkerUtility.getSObjectType('Account');
        test.startTest();
        List<Map<String, String>> picklistVal = PicklistUtility.getPicklistOptions(sObjectType, 'AccountSource');
        test.stopTest();
        System.assert(picklistVal.size() > 0);
    }
    
    /*@isTest public static void testGetDependentPicklistOptions(){
        
        Schema.SObjectType sObjectTypeVal = SkyWalkerUtility.getSObjectType('Account');
        System.debug('--------------->' + sObjectTypeVal);
        test.startTest();
        Map<String, List<Map<String, String>>> picklistVal = PicklistUtility.getDependentPicklistOptions(sObjectTypeVal, 'AccountSource');
        test.stopTest();
        System.assert(picklistVal.size() > 0);
        }
    
    @isTest public static void testGetDependentPicklistOptionsWithStringArgs(){
        
        test.startTest();
        Map<String, List<Map<String, String>>> picklistVal = PicklistUtility.getDependentPicklistOptions('Account', 'AccountSource');
        test.stopTest();
        System.assert(picklistVal.size() > 0);
        } 
    
    @isTest public static void testGetDependentPicklistValues(){
        
        Schema.sObjectField sObjectFieldVal = SkyWalkerUtility.getSObjectField('Account', 'Name');
        test.startTest();
        Map<Object, List<String>> picklistVal = PicklistUtility.getDependentPicklistValues(sObjectFieldVal);
        test.stopTest();
        System.assert(picklistVal.size() > 0);
        } */
    

}