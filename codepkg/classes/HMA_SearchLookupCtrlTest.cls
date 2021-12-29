@isTest public with sharing class HMA_SearchLookupCtrlTest {
   @isTest public static void testSearchProgram(){
       Program__c program = HMA_TestHelper.getProgram(true);
       string searchTerm = program.Name;
       List<String> selectedIds = new List<String>();
       selectedIds.add(program.Id);
       test.startTest();
       List<LookupSearchResult> result =  HMA_SearchLookupCtrl.searchProgram(searchTerm,selectedIds);
       test.stopTest();
       system.assert(result.size()>0);
    }
    @isTest public static void testSearchContact(){
        Contact contact = HMA_TestHelper.getContact(true);
        string searchTerm = contact.FirstName;
        List<String> selectedIds = new List<String>();
        selectedIds.add(contact.Id);
        test.startTest();
        List<LookupSearchResult> result =  HMA_SearchLookupCtrl.searchContact(searchTerm,selectedIds);
        test.stopTest();
        system.assert(result.size()>0);
     }
     @isTest public static void testSearchAccount(){
        Account account = HMA_TestHelper.getAccount(true);
        string searchTerm = account.Name;
        List<String> selectedIds = new List<String>();
        selectedIds.add(account.Id);
        test.startTest();
        List<LookupSearchResult> result =  HMA_SearchLookupCtrl.searchAgency(searchTerm,selectedIds);
        test.stopTest();
        system.assert(result.size()>0);
     }
    
}