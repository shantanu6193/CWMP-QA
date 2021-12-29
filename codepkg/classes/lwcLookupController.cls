public without sharing class lwcLookupController {

    @AuraEnabled(cacheable=true)
    public static List<sobject> findDefaultRecord(String searchId, String objectName) {//used for Edit Page 
     //Dynamic query for Account, Contact ,Project.
      return Database.query('SELECT Id, Name FROM ' +objectName+ ' WHERE Id =  \'' + searchId + '\'');
    }

    @AuraEnabled(cacheable=true)
    public static Map<String,Object> findContactsRelatedToAccount(String searchKey, String AccountId) {
     
      String selectedAccountId = AccountId;
      string searchText = '\'%' + String.escapeSingleQuotes(searchKey) + '%\'';
      List<AccountContactRole__c> accountContactsRole = [SELECT Id , Contact_Name__c, Account_Name__c FROM AccountContactRole__c WHERE Account_Name__c = : selectedAccountId];
      Set<Id> ConIds = new Set<Id>();
      for(AccountContactRole__c Conlist : accountContactsRole){
        ConIds.add(Conlist.Contact_Name__c);
      }

      String inClause = String.format( '(\'\'{0}\'\')',new List<String> { String.join( new List<Id>(ConIds) , '\',\'') });
      String str ='SELECT Id, Name, FirstName, LastName ,Email, Phone, Title FROM  Contact  WHERE Name LIKE '+searchText+' AND Id IN'+inClause  ;
      Map<String,Object> resultSet = new Map<String,Object>();
      
      //return conRecord;
      List<Contact> contactList =Database.query(str);
      resultSet.put('contactList',contactList);
      return resultSet;
    }

    @AuraEnabled(cacheable=true)
    public static List<sobject> findRecords(String searchKey, String objectName){
      String ObjName =objectName;
      string searchText = '\'%' + String.escapeSingleQuotes(searchKey) + '%\'';
      String str ='SELECT Id, Name FROM ' +objectName+ ' WHERE Name LIKE '+searchText;
      return Database.query(str);
    }

    @AuraEnabled(cacheable=true)//Fetching Data using SOSL
    public static Map<String,Object> searchSobjectUsingSOSL(String searchText,
                                                            String objectName,
                                                            String fieldsToReturn,
                                                            String whereClause,
                                                            String orderBy
                                                            ) {
       /* System.debug('---searchText--' + searchText);
        System.debug('---objectName--' + objectName);
        System.debug('---fieldsToReturn--' + fieldsToReturn);
        System.debug('---whereClause--' + whereClause);
        System.debug('---orderBy--' + orderBy);*/
        Map<String, Object> returnMap = new Map<String, Object>();
        //lim = lim != null ? lim : 100;
        whereClause = whereClause != null ? whereClause : '';
        String searchQueryString = 'FIND {' +
        String.escapeSingleQuotes(searchText) +
        '*} IN ALL FIELDS RETURNING ' +
        objectName +
        ' ( ' +
        fieldsToReturn +' '+
        whereClause +
        ' ORDER BY ' + orderBy +
        ' Limit 15 )';
        //System.debug('---searchqueryString--' + searchQueryString);
        List<List<SObject>> searchList = search.query(searchQueryString);
        returnMap.put('soslResult',searchList[0]);
        //returnMap.put('Query',searchQueryString);
        //System.debug('returnMap&&&&& '+returnMap);
        return returnMap;
      }

}