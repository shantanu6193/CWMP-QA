public without sharing class PACloseoutPoratalMessageController {
    /***********************************************************************************************
    * Method  Name   : getMessage
    * Description    : 
    * Return         : 
    * Inputs         : 
    * Author       : Digamber
    * Created On   : 01/11/2021
    * Modification Log:  
    * -----------------------------------------------------------------------------------------------*/
    @AuraEnabled(Cacheable=true)
    public static Map<String, Object> getMessage(String recordId) {
        Map<String, Object> result = new Map<String, Object>();
        result.put('msg', '');
        result.put('isMsgVisible', false);            
        
        Closeout_Request__c closeoutRequest = [SELECT Id, Name, Status__c FROM Closeout_Request__c WHERE Id =:recordId];
        Key_Value_Store__mdt closeoutTextInProcess = Key_Value_Store__mdt.getInstance('CloseoutTextInProcess');
        Key_Value_Store__mdt closeoutTextOnHold = Key_Value_Store__mdt.getInstance('CloseoutTextOnHold');
        Key_Value_Store__mdt closeoutTextComplete = Key_Value_Store__mdt.getInstance('CloseoutTextComplete');
        Key_Value_Store__mdt closeoutTextPendingClaim = Key_Value_Store__mdt.getInstance('CloseoutTextPendingClaim');

        if(closeoutTextInProcess.Text_Value__c.contains(closeoutRequest.Status__c)){
            result.put('msg', System.Label.CloseoutTextInProcess);
            result.put('isMsgVisible', true);  
        }
        else if(closeoutTextOnHold.Text_Value__c.contains(closeoutRequest.Status__c)){
            result.put('msg', System.Label.CloseoutTextOnHold);
            result.put('isMsgVisible', true);  
        }
        else if(closeoutTextComplete.Text_Value__c.contains(closeoutRequest.Status__c)){
            result.put('msg', System.Label.CloseoutTextComplete);
            result.put('isMsgVisible', true);  
        }
        else if(CloseoutTextPendingClaim.Text_Value__c.contains(closeoutRequest.Status__c)){
            result.put('msg', System.Label.CloseoutTextPendingClaim);
            result.put('isMsgVisible', true);  
        }
        return result;
    }

}