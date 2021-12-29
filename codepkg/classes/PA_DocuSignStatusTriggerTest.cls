@isTest
public with sharing class PA_DocuSignStatusTriggerTest {
    
    @isTest
    public static void DocuSignStatusTriggerTest(){
        Program__c parentProgramName = new Program__c();
        parentProgramName.Name = 'Public Assistance';
        parentProgramName.Stage__c = 'Closed';           
        insert parentProgramName;
        dfsle__EnvelopeStatus__c docuSignStatus = new dfsle__EnvelopeStatus__c(dfsle__SourceId__c = parentProgramName.Id);
        insert docuSignStatus;
        
    }
}