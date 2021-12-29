public without sharing class HHDocument {

    @AuraEnabled public Document__c document;
    @AuraEnabled public String contentDocumentId;
    @AuraEnabled public String latestVersionId;
    @AuraEnabled public String fileName;
    @AuraEnabled public String VersionNumber;

    public HHDocument(){}
    public HHDocument(Document__c document, String contentDocumentId, String latestVersionId, String fileName, String VersionNumber) {
        this.contentDocumentId = contentDocumentId;
        this.latestVersionId = latestVersionId;
        this.fileName = fileName;
        this.VersionNumber = VersionNumber;
    }

    public void setDocument(Document__c document) {
        this.document = document;
    }

    public void setContentDocumentId( String contentDocumentId) {
        this.contentDocumentId = contentDocumentId;
    }

    public void setLatestVersionId(String latestVersionId) {
        this.latestVersionId = latestVersionId;
    }

    public void setFileName (String fileName) {
        this.fileName = fileName;
    }

    public void setVersionNumber (String VersionNumber) {
    this.VersionNumber = VersionNumber;
    }

    public HHDocument getDocumentInfo() {
        return this;
    }
}