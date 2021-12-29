public without sharing class DocuSignIntegrationCtrl {
    private String templateId {get; set;}
    private String contactId {get; set;}
    private List<Id> recordIds {get; set;}
    public DocuSignIntegrationCtrl(String templateId, String contactId, List<Id> recordIds) {
        this.templateId = templateId;
        this.contactId = contactId;
        this.recordIds = recordIds;
    }

    public String docuSignEnvelopeGenerator() {
        return sendNow();
    }

    private String SendNow() {
        //envelopeID = generateEnvelope();
        return generateEnvelope();
        //generateRecipientView(envelopeID); Instead of this sendEmailFromAPI
    }

    private HttpRequest getHttpRequest(String url) {
        HttpRequest request = new HttpRequest();
        request.setEndpoint(url);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'Bearer ' + getSessionId());
        // Set the body as a JSON object
        return request;
    }

    private String getSessionId() {
        Integration_Config__mdt integrationConfig = IntegrationHelper.getConfig('DOCU_SIGN');
        JWT jwt = new JWT(integrationConfig.Algo__c);
        jwt.iss = integrationConfig.Integration_Key__c;
        jwt.sub = integrationConfig.User_Id__c;
        jwt.aud = integrationConfig.aud__c;
        jwt.pkcs8 = integrationConfig.pkcs8__c;
        Map<String,String> claims = new  Map<String,String>();
        claims.put('scope','signature impersonation');
        jwt.claims = claims;
        return JWTBearer.getAccessToken(integrationConfig.Auth_Base_URL__c, jwt);
    }

    private List<DocuSignTab> prepareRecordFields() {
        List<DocuSignTab> returnMergeFieldList = new List<DocuSignTab>();
        for(Id recordId : this.recordIds) {
            DescribeSObjectResult describeResult = recordId.getSObjectType().getDescribe();
            List<String> fieldNames = new List<String>(describeResult.fields.getMap().keySet());
            returnMergeFieldList.addAll(prepareSingleRecordMergeFields(describeResult, fieldNames, recordId));
        }
        return returnMergeFieldList;
    }

    private List<DocuSignTab> prepareSingleRecordMergeFields(DescribeSObjectResult describeResult, List<String> fieldNames, Id recordId) {
        List<DocuSignTab> singleRecordMergeFields = new List<DocuSignTab>();
        String query = 'SELECT '+String.join( fieldNames, ',' )+' FROM '+ describeResult.getName() +' WHERE '+' Id = :recordId '+' LIMIT 1 ';
        List<SObject> recordsData = Database.query(query);
        for(String field : fieldNames) {
            singleRecordMergeFields.add(getDocuSignTab(describeResult.getName()+'.'+field, String.valueOf(recordsData[0].get(field))));
            // if(describeResult.fields.getMap().get(field).getDescribe().getType() == Schema.DisplayType.Reference) {

            // }
        }
        return singleRecordMergeFields;
    }


    private DocuSignTabs getProcessedDocuSignTabs() {
        DocuSignTabs docuSignTabs = new DocuSignTabs();
        docuSignTabs.textTabs = new List<DocuSignTab>();
        //docuSignTabs.checkboxTabs = new List<DocuSignTab>();

        docuSignTabs.textTabs.addAll(prepareRecordFields());
        return docuSignTabs;
    }

    private DocuSignTab getDocuSignTab(String label, Object value) {
        DocuSignTab docuSignTab = new DocuSignTab();
        docuSignTab.tabLabel = label;
        docuSignTab.value = value;
        return docuSignTab;
    }
    private List<DocuSignTab> getDocuSignTabs(String label, Object value, Integer count) {
        List<DocuSignTab> docuSignTabs = new List<DocuSignTab>();
        DocuSignTab docuSignTab = new DocuSignTab();
        docuSignTab.tabLabel = label;
        docuSignTab.value = value;
        docuSignTabs.add(docuSignTab);

        for (Integer i = 1; i <= count; i++) {
            docuSignTab = new DocuSignTab();
            docuSignTab.tabLabel = label + '_' + i;
            docuSignTab.value = value;
            docuSignTabs.add(docuSignTab);
        }


        return docuSignTabs;
    }

    private String generateEnvelope() {
        Http http = new Http();
        String endPointURL = KeyValueHelper.getTextValue('SSO_Create_Envelope_End_Point_URL');
        endPointURL = endPointURL.replace('{ACCOUNT_ID}', KeyValueHelper.getTextValue('SSO_Account_Id'));
        HttpRequest request = getHttpRequest(endPointURL);

        DocuSignAttributes docuSignAttributes = new DocuSignAttributes();
        docuSignAttributes.emailSubject = 'Request From HMA';
        docuSignAttributes.templateId = this.templateId;//orderRec.SSOF_Template__r.Template_Id__c;


        List<Contact> contactList = [SELECT Name, email FROM Contact WHERE Id = :(this.contactId) LIMIT 1];
        DocuSignRole docuSignRole = new DocuSignRole();
        docuSignRole.roleName = 'Recipient1';
        docuSignRole.name = contactList[0].Name; //UserInfo.getFirstName() + ' ' + UserInfo.getLastName();
        docuSignRole.email = contactList[0].email;
        //docuSignRole.clientUserId = contactList[0].email;//UserInfo.getUserEmail();
        docuSignRole.tabs = getProcessedDocuSignTabs();

        List<DocuSignRole> docusignRoles = new List<DocuSignRole>{docuSignRole};
        docuSignAttributes.templateRoles = docusignRoles;

        docuSignAttributes.customFields.textCustomFields = new List<DocuSignTextCustomFields>();
        docuSignAttributes.customFields.textCustomFields.add(new DocuSignTextCustomFields());

        // Signer signer = new Signer();
        // signer.email = contactList[0].email;
        // signer.name = contactList[0].Name;
        // signer.clientUserId = contactList[0].email;
        // signer.recipientId = '1';
        // docuSignAttributes.recipients.signers.add(signer);
        System.debug('---' + JSON.serialize(docuSignAttributes));

        request.setBody(JSON.serialize(docuSignAttributes));
        HttpResponse response = http.send(request);
        // Parse the JSON response
        if (response.getStatusCode() != 201) {
            System.debug('The status code returned was not expected: ' +
                    response.getStatusCode() + ' ' + response.getStatus());
            throw new CustomExceptionController.CustomMessageException(response.getStatusCode() + '--' + response.getBody());
        } else {
            System.debug(response.getBody());
            String responseStr = response.getBody();
            Map<String, String> resMap = (Map<String, String>) JSON.deserialize(responseStr, Map<String, String>.class);
            return resMap.get('envelopeId');
        }
    }



    /*
    * Update envelope classes
     */
    public class Documents {
        public List<Document> documents;
    }

    public class Document {
        public String documentBase64;
        public String fileExtension;
        public String documentId;
        public String name;
    }

    public class CompositeTemplate {
        public String compositeTemplateId;
        public Document document;
        public List<ServerTemplate> serverTemplates;
        public List<inlineTemplates> inlineTemplates;
    }

    public class Attachment {
        public String data;
        public String label;
        public String attachmentType;
        public String attachmentId;
        public String name;
    }

    public class ServerTemplate {
        public String sequence;
        public String templateId;
    }

    public class inlineTemplates {
        public String sequence;
    }



/*
* Create envelope classes
 */
    public class DocuSignAttributes {
        public String accountId;
        public String emailSubject;
        public String templateId;
        public List<DocusignRole> templateRoles;
        public DocuSignTabs tabs;
        public DocuSignCustomFields customFields = new DocuSignCustomFields();
        public String status = 'Sent';
        public List<Attachment> envelopeAttachments;
        public List<CompositeTemplate> compositeTemplates;
        public List<Document> documents;
        public Recipient recipients = new Recipient();

    }

    public class DocuSignRole {
        public String roleName;
        public String name;
        public String email;
        public String clientUserId;
        public DocuSignTabs tabs;

    }

    public Class Recipient {
        public List<Signer> signers = new List<Signer>();
    }

    public class Signer {
        public String email;
        public String name;
        public String recipientId;
        public String clientUserId;
    }

    public class DocuSignTabs {
        public List<DocuSignTab> textTabs;
        public List<DocuSignTab> checkboxTabs;
    }

    public class DocuSignTab {
        public String tabLabel;
        public Object value;
        //public Object selected;
    }

    public class DocuSignCustomFields {
        List<DocuSignTextCustomFields> textCustomFields;
    }

    public class DocuSignTextCustomFields {
        public String name = 'test';
        public String required = 'false';
        public String show = 'true';
        public String value = '34';
    }

}