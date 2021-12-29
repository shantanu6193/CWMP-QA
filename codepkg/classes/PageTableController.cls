public without sharing class PageTableController {

     /***************************************************************************
    * Method Name : getObjectDetails
    * Inputs :      List<String> tableColumnNames,String objectName,String dataLimit
    * Description:  this method retrive object detail with column name 
    *******************************************************************************/
   @AuraEnabled
   public static Map<String, Object> getTableRecordDetails(List<String> tableColumnNames, String objectName, String dataLimit, String whereClause, String getParentRecordQuery){
        try {
            Map<String, Object> returnMap = new Map<String, Object>();
    Set<String> uniqueColumnNames = new set<String>(tableColumnNames);
    List<String> listColumnNames = new List<String>(uniqueColumnNames);
            returnMap.put('parentRecordList', null);
            returnMap.put('recordList',null);
            System.debug('query---'+getParentRecordQuery);
            if(String.isNotBlank(getParentRecordQuery)) {
                SObject[] parentRecordList = Database.query(getParentRecordQuery);
                System.debug('getParentRecord---'+parentRecordList);
                returnMap.put('parentRecordList',parentRecordList);
                if(parentRecordList != null && parentRecordList.size() > 0) {
    String columnNames = String.join(listColumnNames, ', ' ); 
    system.debug( 'Joined with coma column Names is ' + columnNames);  
    String query = 'SELECT ' + columnNames +' FROM '+ objectName+' ';
    if(String.isNotBlank(whereClause)){
                        if(whereClause.contains('{parentRecordId}')) {
                            whereClause = whereClause.replace('{parentRecordId}', (String)parentRecordList[0].get('Id'));
                        }
        query += ' WHERE '+whereClause;
    }
       query += ' limit '+dataLimit;
                    returnMap.put('recordList',Database.query(query));
                }
            }
            
            
            return returnMap;
        } catch(AuraHandledException e) {
            throw new AuraHandledException(e.getMessage());
        }
   } 

     /***************************************************************************
    * Method Name : updateObjectDetails
    * Inputs :      List<String> tableColumnNames,String objectName,String dataLimit
    * Description:  this method retrive object detail with column name 
    *******************************************************************************/
    @AuraEnabled
    public static boolean updateObjectDetails(List<sObject> objectDetails) {
        try {
            if(objectDetails.size() > 0){
             upsert objectDetails;
             return true;   
           //  system.debug('table updated successfully'+objectDetails);
            }
        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        return false;
    }
    /***************************************************************************
    * Method Name : deleteTableRowRecord
    * Inputs :      String recordId
    * Description:  this method is used for delete Table row record
    *******************************************************************************/
    @AuraEnabled
    public static void deleteTableRowRecord(String recordId) {
        try {
            if(String.isNotBlank(recordId)) {
                Id objRecId = recordId;
                String objAPIName = objRecId.getSObjectType().getDescribe().getName();
                String query = 'SELECT Id FROM ' + objAPIName + ' WHERE Id=: recordId';
                sObject record = Database.query(query);
                delete record;
            }
        } catch (Exception e) {
            system.debug('Error'+e.getMessage());
        } 

    }
    @AuraEnabled
    public static Map<String, Object> executeTableAction(String parentId, String rowId, String className) {
        try{
            Type t = Type.forName(className);
            PageTableActionsInterface PageTableActionsInterface = (PageTableActionsInterface) t.newInstance();
            return PageTableActionsInterface.executeAction(parentId, rowId);
        }catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
}