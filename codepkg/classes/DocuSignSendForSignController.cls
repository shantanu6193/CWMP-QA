public without sharing class DocuSignSendForSignController {

    
    /***********************************************
    * Method Name : getDocuSignTemplateId
    * Author : Digambar
    * Inputs : String docuSignTemplateName
    * Description: This method return Id of DocuSign template
    *********************************************/
    @AuraEnabled(Cacheable=true)
    public static String  getDocuSignTemplateId(String docuSignTemplateName, String recordId) {
        String url = '';
        if(String.isEmpty(docuSignTemplateName) || String.isEmpty(recordId)) {
            throw new AuraHandledException('DocuSign Template Name Undefined. Contact Your Administrator');
        }
        List<dfsle__EnvelopeConfiguration__c> template = [SELECT Id, Name FROM dfsle__EnvelopeConfiguration__c WHERE Name=: docuSignTemplateName];
    	if(template.isEmpty()) {
            throw new AuraHandledException('Invalid DocuSign Template Name. Contact Your Administrator');
        }
        String templateId = template.get(0).Id;
        System.debug('#templateId :'+templateId);
        url = '/apex/dfsle__sending?sId=' + recordId +'&templateId=' + templateId + '&recordId=' + recordId + '&title=DocuSign&quickSend=false&isEmbedded=false';
        //url = '/apex/dfsle__gendocumentgenerator?sId =' + recordId +'&templateId=' + templateId + '&recordId=' + recordId + '&title=DocuSign&quickSend=false&isEmbedded=false';
        //url = '/apex/dfsle__gendocumentgenerator?sId=a1H35000001E8MFEA0&templateId=a1U35000004bD8vEAE&recordId=a1H35000001E8MFEA0&title=FederalApplicationCloseoutCDAACostShare&quickSend=false&isEmbedded=false';
        System.debug('#url Before Pagereference:'+url);
        PageReference pageRef = new PageReference(url);
        url = pageRef.getUrl();
        System.debug('#url After Pagereference:'+url);
        return url;
    }

     /***********************************************
    * Method Name : generateDocument
    * Author : Digambar
    * Inputs : String recordId
    * Description: This method create Document object
    *********************************************/
    @AuraEnabled
    public static void generateDocument(String recordId) {
        //Check if FIR Sign Document is already created and not uploaded
        Key_Value_Store__mdt mtdtFIRDocName = Key_Value_Store__mdt.getInstance('PA_FIR_Document_Name');
        System.debug('#mtdtFIRDocName: '+mtdtFIRDocName);
        System.debug('#mtdtFIRDocName VALUE: '+mtdtFIRDocName.Text_Value__c);

        Integer count = [SELECT COUNT() 
						 FROM Document__c
						 WHERE Closeout_Task__c =: recordId
      						   AND Document_Name__c =: mtdtFIRDocName.Text_Value__c
                               AND Date_Uploaded__c = NULL];
        system.debug('#COUNT :'+count);
        //Create Document
        if(count == 0){
            List<Document__c> docListVal = new List<Document__c>();
            Document__c docObj = new Document__c();
            docObj.Document_Name__c = mtdtFIRDocName.Text_Value__c;
            docObj.Original_File_Name__c = mtdtFIRDocName.Text_Value__c;
            docObj.Document_Type__c = 'Closeout';
            docObj.Closeout_Task__c = recordId;
            docListVal.add(docObj);
            system.debug('#docListVal :'+docListVal);
            try{
                insert docListVal;
            }
            catch(DmlException e) {
                    System.debug('#DML Exception: ' + e.getMessage());
            }
        }       
        //Update DocuSign Status
        List<Closeout_Task__c> closeoutTaskList = new List<Closeout_Task__c>();
        Closeout_Task__c closeoutTask = new Closeout_Task__c(Id = recordId, Docusign_Status__c = 'PENDING');
        closeoutTaskList.add(closeoutTask);
        try{
                update closeoutTaskList;
        }
        catch(DmlException e) {
                System.debug('#DML Exception: ' + e.getMessage());
        }
    }
    //******************************************************************************************************************************** */
}