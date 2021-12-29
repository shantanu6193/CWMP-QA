/***********************************************************************************************************************************
* Class Name   : HMA_SearchLookupCtrl
* Description  : This class for HMA search lookup data
* Author       : Pankaj
* Created On   : 06/23/2020
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Pankaj              06/23/2020       Initial Implementation
**************************************************************************************************************************************/

public without sharing class HMA_SearchLookupCtrl {
    private final static Integer MAX_RESULTS = 500;

    /***********************************************
    * Method Name : searchProgram
    * Author : Pankaj
    * Inputs : String searchTerm, List<String> selectedIds
    * Description: This method return list of LookupSearchResult from Program
    *********************************************/
    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> searchProgram(String searchTerm, List<String> selectedIds) {

        String query = 'SELECT Id, Name FROM Program__c ';
        if(String.isNotEmpty(searchTerm)) {
            query += ' where Name like\'%' + searchTerm + '%\'';
        }
        List<Program__c> programList = Database.query(query);
        // Prepare results
        List<LookupSearchResult> results = new List<LookupSearchResult>();
        // Extract Accounts & convert them into LookupSearchResult
        String programIcon = 'standard:channel_programs';
        for (Program__c program : programList) {
            results.add(
                    new LookupSearchResult(
                            program.Id,
                            'Product2',
                            programIcon,
                            program.Name,
                            null,
                            program
                    )
            );
        }
        // Optionnaly sort all results on title
        results.sort();
        System.debug('results---' + results);
        return results;
    }

    /***********************************************
    * Method Name : searchContact
    * Author : Pankaj
    * Inputs : String searchTerm, List<String> selectedIds
    * Description: This method return list of LookupSearchResult from Contact
    *********************************************/
    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> searchContact(String searchTerm, List<String> selectedIds) {

        String query = 'SELECT Id, Name, FirstName, LastName, Title, Phone, MobilePhone, Email,AccountId,Account.Name FROM Contact';
        if(String.isNotEmpty(searchTerm)) {
            query += ' where Name like\'%' + searchTerm + '%\'';
        }
        List<Contact> contactReferences = Database.query(query);
        // Prepare results
        List<LookupSearchResult> results = new List<LookupSearchResult>();

        // Extract Accounts & convert them into LookupSearchResult
        String contactIcon = 'standard:contact';
        for (Contact conReference : contactReferences) {
            results.add(
                    new LookupSearchResult(
                            conReference.Id,
                            'Contact',
                            contactIcon,
                            conReference.Name,
                            null,
                            conReference
                    )
            );
        }

        // Optionnaly sort all results on title
        results.sort();
        System.debug('results---' + results);
        return results;
    }

    /***********************************************
    * Method Name : searchAgency
    * Author : Pankaj
    * Inputs : String searchTerm, List<String> selectedIds
    * Description: This method return list of LookupSearchResult from Account
    *********************************************/
    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> searchAgency(String searchTerm, List<String> selectedIds) {
      
        String query = 'SELECT Id, Name FROM Account';
        if(String.isNotEmpty(searchTerm)) {
            query += ' where Name like\'%' + searchTerm + '%\'';
        }
        List<Account> accountReferences = Database.query(query);

        // Prepare results
        List<LookupSearchResult> results = new List<LookupSearchResult>();

        // Extract Accounts & convert them into LookupSearchResult
        String accountIcon = 'standard:account';
        for (Account agencyAccountReference : accountReferences) {
                results.add(
                        new LookupSearchResult(
                                agencyAccountReference.Id,
                                'Account',
                                accountIcon,
                                agencyAccountReference.Name, 
                                null, 
                                agencyAccountReference
                        )
            );
        }

        // Optionnaly sort all results on title
        results.sort();
        System.debug('results---' + results);
        return results;
    }
}