public without sharing class HMGP_SendDocuSignToResponsibleRepCtrl implements PageTableActionsInterface{
    public Map<String, Object> executeAction(String parentId, String rowId) {
        Map<String, Object> returnMap = new Map<String, Object>();
        returnMap.put('isSuccess', false);
        try{
            //Application__c app = [SELECT Id, Subapplicant_Entity__c, Disaster__c from Application__c WHERE Id=:String.escapeSingleQuotes(parentId)];
            Application_Extension__c appExt = [SELECT Id, Application__c, Application__r.Subapplicant_Entity__c, Application__r.Disaster__c from Application_Extension__c WHERE Id=:String.escapeSingleQuotes(parentId)];
            Contact_Role__c contactRole = [SELECT Id, Contact__c, Role__c from Contact_Role__c WHERE Id=:String.escapeSingleQuotes(rowId)];
            if(appExt != null && appExt.Application__r.Subapplicant_Entity__c != null && appExt.Application__r.Disaster__c != null && contactRole != null && contactRole.Contact__c != null){
                List<Id> recordIds = new List<Id>();
                String templateIdMaintenanceCommitment = KeyValueHelper.getTextValue('Docusign_Maintenance_Commitment_TempId');
                if(contactRole.Role__c.contains('Maintenance Commitment')){
                    recordIds = new List<Id> {parentId, appExt.Application__c, appExt.Application__r.Subapplicant_Entity__c, appExt.Application__r.Disaster__c, contactRole.Contact__c};
                }else if(contactRole.Role__c.contains('Match Commitment')){
                    recordIds = new List<Id> {parentId, appExt.Application__c, appExt.Application__r.Subapplicant_Entity__c, contactRole.Contact__c};
                    templateIdMaintenanceCommitment = KeyValueHelper.getTextValue('Docusign_Match_Commitment_TempId');
                }
                //List<Id> recordIds = new List<Id> {parentId, app.Subapplicant_Entity__c, app.Disaster__c, contactRole.Contact__c};
                DocuSignIntegrationCtrl docusignObject = new DocuSignIntegrationCtrl(templateIdMaintenanceCommitment, contactRole.Contact__c, recordIds);
                String envelopeId = docusignObject.docuSignEnvelopeGenerator();
                if(String.isNotEmpty(envelopeId)){
                    update new Contact_Role__c(Id=contactRole.Id, Signature_Status__c ='Sent For Signature', DocuSign_Envelope_Id__c = envelopeId);
                }
                returnMap.put('isSuccess', true);
            }
        }catch(Exception e){
            returnMap.put('errorMsg', e.getMessage());
        }
        return returnMap;
    }
}