<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>Total Management Cost Allowed</label>
    <protected>false</protected>
    <values>
        <field>Error_Message__c</field>
        <value xsi:type="xsd:string">You cannot request more than the Maximum Management Cost Allowed</value>
    </values>
    <values>
        <field>Expression__c</field>
        <value xsi:type="xsd:string">Total_Management_Cost_Requested__c &gt; Maximum_Eligible_Management_Cost__c</value>
    </values>
    <values>
        <field>Field_API_Name__c</field>
        <value xsi:type="xsd:string">Total_Management_Cost_Requested__c,Maximum_Eligible_Management_Cost__c</value>
    </values>
    <values>
        <field>Page_Layout_Config__c</field>
        <value xsi:type="xsd:string">HMGP_Grant_Management_Cost_Application</value>
    </values>
</CustomMetadata>
