trigger DocuSignStatusTrigger on dfsle__EnvelopeStatus__c (after insert, after update) {
    new DocuSignStatusTriggerHelper().process();
}