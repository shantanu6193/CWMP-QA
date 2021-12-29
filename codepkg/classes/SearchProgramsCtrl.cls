/**
 * Created by harsh on 10-02-2021.
 */

public without sharing class SearchProgramsCtrl implements SearchLookupInterface{


    public List<LookupSearchResult> search(String searchTerm) {
        String query = 'SELECT Id, Name FROM Program__c WHERE Parent_Program__r.Name = \'Hazard Mitigation Assistance\'';
        if(String.isNotEmpty(searchTerm)) {
            query += ' AND Name like\'%' + searchTerm + '%\'';
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
}