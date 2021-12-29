/**
* Class Name   : PA_CommunityHomeCtrl
* Description  : 
* Author       : Pankaj
* Created On   : 26/05/2021
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Pankaj             26/01/2021       Initial Implementation
*/

public with sharing class PA_CommunityHomeCtrl {
    
    /***********************************************************************************************
    * Method  Name   : getArticles
    * Description    : -
    * Return         : -
    * Inputs :
    * Author         : Pankaj
    * Created On     : 26/05/2021
    * Modification Log:  
    * -----------------------------------------------------------------------------------------------*/
    
    @AuraEnabled
    public static List<KnowledgeArticleVersion> getArticles() {
        List<KnowledgeArticleVersion> knowledgeList = [SELECT Id,KnowledgeArticleId,Language,PublishStatus,Summary,Title,UrlName
            FROM KnowledgeArticleVersion where PublishStatus = 'Online' AND Language = 'en_US' WITH DATA CATEGORY PHOS__c below PHOS_Portal__c];
        return knowledgeList;
    }

    /***********************************************************************************************
    * Method  Name   : getDatatwo
    * Description    : -
    * Return         : -
    * Inputs :
    * Author         : Pankaj
    * Created On     : 26/05/2021
    * Modification Log:  
    * -----------------------------------------------------------------------------------------------*/
   
    @AuraEnabled
    public static Map<String, Object> getDatatwo() {
        Map<String, Object> returnMap = new Map<String, Object>();
        List<PHOS_Document_Repository__mdt> docList = [SELECT DeveloperName,Id,Is_Active__c,Label,Language,MasterLabel,Sequence__c,URL__c
            FROM PHOS_Document_Repository__mdt where Is_Active__c = true Order By Sequence__c];
        returnMap.put('DocumentList',docList);
        returnMap.put('KnowledgeList',getArticles());
        returnMap.put('ReportUrl', customMetaValReportUrl());
        return returnMap;
    }

    /***********************************************************************************************
    * Method  Name   : getDatatwo
    * Description    : -
    * Return         : -
    * Inputs :
    * Author         : Pankaj
    * Created On     : 26/05/2021
    * Modification Log:  
    * -----------------------------------------------------------------------------------------------*/

    @AuraEnabled
    public static String customMetaValReportUrl(){
        String resultVal = '';
        List<Key_Value_Store__mdt> keyValStoreLst = [SELECT Text_Value__c,DeveloperName 
                                                    FROM Key_Value_Store__mdt
                                                    WHERE DeveloperName = 'PA_Report_URL'];
        System.debug('Key_Value_Store query result==='+keyValStoreLst);                                            
        if(keyValStoreLst.size() > 0){
            resultVal = keyValStoreLst[0].Text_Value__c;
        }   
        return  resultVal;                                        
    }
}