/**
 * Created by harsh on 27-01-2021.
 */

public without sharing class PageLayoutCtrl {
    /*In Use*/
    @AuraEnabled(Cacheable=true)
    public static Map<String, Object> getPageDetails(String recordId, String programTemplatePageId){
        try{
            return PageLayoutHelper.getPageDetails(recordId, programTemplatePageId, 'ASC');
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(Cacheable=true)
    public static Map<String, Object> getProjectSitePageDetailsByPageLayoutId(String pageLayoutId){
        try{
            return PageLayoutHelper.getPageLayoutDetails(pageLayoutId);
        }catch(Exception e){
            System.debug(e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
    }


    @AuraEnabled(Cacheable=true)
    public static Map<String, Object> getPageLayoutDetails(String pageLayoutName){
        try{
           return PageLayoutHelper.getPageLayoutDetails(pageLayoutName);
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }


    @AuraEnabled
    public static Map<String, Object> getRecordDetails(String recordId, String pageLayoutId){
        Map<String, Object> returnMap = new Map<String, Object>();
        try{
            returnMap.put('isSuccess', false);
            if(String.isEmpty(pageLayoutId)){
                returnMap.put('errorMsg', 'Page Layout Id null');
                return returnMap;
            }
            Map<String, Object> pageLayoutDetails = PageLayoutHelper.prepareQueryDetails(pageLayoutId);
            recordId = String.escapeSingleQuotes(recordId);
            String objectName = PageLayoutHelper.getObjectName(recordId);
            System.debug('objectName----'+objectName);
            System.debug('pageLayoutDetails.get(pageLayoutObject)----'+pageLayoutDetails.get('pageLayoutObject'));
            String query = '';
            if(objectName.equals(pageLayoutDetails.get('pageLayoutObject'))){
                query = 'Select '+pageLayoutDetails.get('fieldAPIs')+' FROM '+pageLayoutDetails.get('pageLayoutObject')+' WHERE Id=:recordId';
            }else{
                query = 'Select '+pageLayoutDetails.get('fieldAPIs')+' FROM '+pageLayoutDetails.get('pageLayoutObject')+' WHERE '+objectName+'=:recordId';
            }
            System.debug('query: '+query);
            List<sObject> sObjectList = Database.query(query);
            System.debug('sObjectList : '+ sObjectList);
            returnMap.put('recordDetails', null);
            if(sObjectList.size() > 0){
                returnMap.put('recordDetails', sObjectList.get(0));
                returnMap.put('isSuccess', true);
            }
            System.debug('returnMap--'+returnMap);
            return returnMap;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static Map<String, Object> dynamicTableClassApex(String recordId, String className, String pageFieldDeveloperName) {
        try{
            System.debug('className----------------' + className);
            Map<String, Object> returnMap = new Map<String, Object>();
            Type t = Type.forName(className);
            DynamicTableInterface dynamicLookupInterface = (DynamicTableInterface) t.newInstance();
            //SearchLookupInterface searchLookupInterface = (SearchLookupInterface) t.newInstance();
            return dynamicLookupInterface.executeClass(recordId, pageFieldDeveloperName);
        }catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> search(String searchTerm, List<String> selectedIds, String className) {
        try{
            Type t = Type.forName(className);
            SearchLookupInterface searchLookupInterface = (SearchLookupInterface) t.newInstance();
            return searchLookupInterface.search(searchTerm);
        }catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
 
    @AuraEnabled
    public static Map<String, Object> getFieldDependencies(String objectName, String controllingField, String dependentField){
        try{
            return PageLayoutHelper.getFieldDependencies(objectName, controllingField, dependentField);
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Map<String, Object> getListofTable(String query){
        try {
            return PageLayoutHelper.getListOfTable(query);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(Cacheable=true)
    public static Map<String, Object> getLoggedInUsrDetails(){
        try{
            Map<String, Object> returnMap = new Map<String, Object>();
            returnMap.put('success', false);
            User usr = [SELECT Id, UserRole.Name FROM User WHERE Id=:UserInfo.getUserId()];
            returnMap.put('userDetails', usr);
            returnMap.put('success', true);
            return returnMap;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
}