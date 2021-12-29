/***********************************************************************************************************************************
* Class Name   : RelatedRecordCtrl
* Description  : This class for get Related records
* Author       : Pankaj
* Created On   : 11/03/2020
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Pankaj              11/03/2020      Initial Implementation
**************************************************************************************************************************************/

public with sharing class RelatedRecordCtrl {

	/***********************************************
    * Method Name : getRecords
    * Author : Pankaj
    * Inputs : String objectName,String recordId,String fieldName,string allFields
    * Description: This method return list of Sobject records from specified object name, recordId, field name and all fields
    *********************************************/
	@AuraEnabled(cacheable=true)  
	public static List<SObject> getRecords(String objectName,String recordId,String fieldName,string allFields) {
		// System.debug('soql::' + soql);
		// return Database.query(soql);

		String query;
		String targetQuery;
		if(!String.isEmpty(fieldName)){
			query = 'SELECT Id, ' + fieldName +' from '+ ObjectName + ' where Id='+'\''+recordId + '\' ';
			SObject sObj=Database.query(query); 
			Object getFieldName = sObj.get(fieldName);
			targetQuery = 'Select '+allFields+' from '+objectName +' where '+fieldName+'=\''+getFieldName+'\' AND '+'Id !='+'\''+recordId+'\' ';
		}else {
			targetQuery = 'SELECT Id, '+allFields+' from '+ ObjectName + ' where Id='+'\''+recordId + '\' ';
		}
		
		List<SObject> targetObjList = Database.query(targetQuery); 
		return targetObjList;
	}

    /***********************************************
    * Method Name : countRecords
    * Author : Pankaj
    * Inputs : String countSOQL
    * Description: This method return record count
    *********************************************/
	@AuraEnabled(cacheable=true) 
	public static Integer countRecords(String countSOQL) {
		if (String.isNotEmpty(countSOQL)) {
			return database.countQuery(countSOQL);
		}
		return 0;
  	}
}