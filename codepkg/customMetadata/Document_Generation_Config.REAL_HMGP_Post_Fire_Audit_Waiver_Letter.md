<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>REAL-HMGP Post-Fire-Audit Waiver Letter</label>
    <protected>false</protected>
    <values>
        <field>Doc_Generate_URL__c</field>
        <value xsi:type="xsd:string">/apex/dfsle__gendocumentgenerator?sId=a1Ft000000aUHl7EAG&amp;templateId=a1Ft000000aUHl7EAG&amp;recordId={RecordId}&amp;title=Generate%20PDF</value>
    </values>
    <values>
        <field>Document_Name__c</field>
        <value xsi:type="xsd:string">Audit Waiver Letter</value>
    </values>
    <values>
        <field>Filter_Criteria2__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>Filter_Criteria__c</field>
        <value xsi:type="xsd:string">HMGP Post-Fire</value>
    </values>
    <values>
        <field>Module__c</field>
        <value xsi:type="xsd:string">REAL</value>
    </values>
    <values>
        <field>Primaray_Object_API_Name__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>Primaray_Object_Filter_Clauses__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>Primary_Object_Label__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>Related_Object1_API_Name__c</field>
        <value xsi:type="xsd:string">Payment_Request__c</value>
    </values>
    <values>
        <field>Related_Object1_Filter_Clauses__c</field>
        <value xsi:type="xsd:string">Project__c=&apos;{recordId}&apos; AND Stage__c =&apos;Payment Processing&apos; AND PaymentType__c =&apos;Final Payment&apos;</value>
    </values>
    <values>
        <field>Related_Object1_Label__c</field>
        <value xsi:type="xsd:string">Payment Request</value>
    </values>
    <values>
        <field>Related_Object2_API_Name__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>Related_Object2_Filter_Clauses__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>Related_Object2_Label__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>Related_Object3_API_Name__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>Related_Object3_Filter_Clauses__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>Related_Object3_Label__c</field>
        <value xsi:nil="true"/>
    </values>
</CustomMetadata>
