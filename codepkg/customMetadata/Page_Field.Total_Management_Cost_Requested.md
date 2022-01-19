<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>Total Management Cost Requested</label>
    <protected>false</protected>
    <values>
        <field>Active__c</field>
        <value xsi:type="xsd:boolean">true</value>
    </values>
    <values>
        <field>Channel_Event_Config__c</field>
        <value xsi:type="xsd:string">{
	&quot;sum&quot;: [{
		&quot;fieldType&quot;: &quot;PageTable&quot;,
		&quot;fieldAPIName&quot;: &quot;Cost_Estimate_Total__c&quot;,
		&quot;pageFieldDeveloperName&quot;: &quot;Pre_Award_Table&quot;,
		&quot;operationType&quot;: &quot;sum&quot;
	}, {
		&quot;fieldType&quot;: &quot;PageTable&quot;,
		&quot;fieldAPIName&quot;: &quot;Hourly_Rate__c,Hours__c&quot;,
		&quot;pageFieldDeveloperName&quot;: &quot;Staff_Time_Table&quot;,
		&quot;operationType&quot;: &quot;multiplication&quot;,
		&quot;formula&quot;: &quot;Hourly_Rate__c * Hours__c&quot;
	}, {
		&quot;fieldType&quot;: &quot;PageTable&quot;,
		&quot;fieldAPIName&quot;: &quot;Cost_Estimate_Total__c&quot;,
		&quot;pageFieldDeveloperName&quot;: &quot;Travel_Expenses_Table&quot;,
		&quot;operationType&quot;: &quot;sum&quot;
	},{
		&quot;fieldType&quot;: &quot;PageTable&quot;,
		&quot;fieldAPIName&quot;: &quot;Cost_Estimate_Total__c&quot;,
		&quot;pageFieldDeveloperName&quot;: &quot;Equipment_Expenses_Table&quot;,
		&quot;operationType&quot;: &quot;sum&quot;
	},{
		&quot;fieldType&quot;: &quot;PageTable&quot;,
		&quot;fieldAPIName&quot;: &quot;Cost_Estimate_Total__c&quot;,
		&quot;pageFieldDeveloperName&quot;: &quot;Supplies_Table&quot;,
		&quot;operationType&quot;: &quot;sum&quot;
	},{
		&quot;fieldType&quot;: &quot;PageTable&quot;,
		&quot;fieldAPIName&quot;: &quot;Cost_Estimate_Total__c&quot;,
		&quot;pageFieldDeveloperName&quot;: &quot;Indirect_CostsTable&quot;,
		&quot;operationType&quot;: &quot;sum&quot;
	},{
		&quot;fieldType&quot;: &quot;PageTable&quot;,
		&quot;fieldAPIName&quot;: &quot;Cost_Estimate_Total__c&quot;,
		&quot;pageFieldDeveloperName&quot;: &quot;Other_Table&quot;,
		&quot;operationType&quot;: &quot;sum&quot;
	}]
}</value>
    </values>
    <values>
        <field>Channel_Event_Name__c</field>
        <value xsi:type="xsd:string">TotalManagementCostCalculation</value>
    </values>
    <values>
        <field>Column_Size__c</field>
        <value xsi:type="xsd:string">2</value>
    </values>
    <values>
        <field>Controller_Field__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>Display_Label__c</field>
        <value xsi:type="xsd:string">Total Management Cost Requested</value>
    </values>
    <values>
        <field>Document_Table_Columns__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>Document_Upload_Additional_Config__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>Enable_Channel_Message__c</field>
        <value xsi:type="xsd:boolean">true</value>
    </values>
    <values>
        <field>Enable_Field_Formula__c</field>
        <value xsi:type="xsd:boolean">false</value>
    </values>
    <values>
        <field>Enable_Field_Specific_Doc__c</field>
        <value xsi:type="xsd:boolean">false</value>
    </values>
    <values>
        <field>Enabled_Maximum_Value__c</field>
        <value xsi:type="xsd:boolean">true</value>
    </values>
    <values>
        <field>Enabled_Minimum_Value__c</field>
        <value xsi:type="xsd:boolean">false</value>
    </values>
    <values>
        <field>Field_API_Name__c</field>
        <value xsi:type="xsd:string">Total_Management_Cost_Requested__c</value>
    </values>
    <values>
        <field>Field_Criteria_value__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>Field_Formula_Configuration__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>Field_Specific_Value__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>Field_Type__c</field>
        <value xsi:type="xsd:string">Currency</value>
    </values>
    <values>
        <field>Filter_Document_Types__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>Help_Text__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>Hide_Field_API_Name__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>Hide_Field_Custom_Attribute__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>Hide_Field_Operator__c</field>
        <value xsi:type="xsd:string">Equal</value>
    </values>
    <values>
        <field>Hide_Field_Value__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>Is_Read_Only__c</field>
        <value xsi:type="xsd:boolean">true</value>
    </values>
    <values>
        <field>Max_Length__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>Maximum_Value_Configuration__c</field>
        <value xsi:type="xsd:string">{
&quot;fields&quot;: &quot;Maximum_Eligible_Management_Cost__c&quot;,
&quot;maxValue&quot;: 0,
&quot;maxValueFormula&quot;:&quot;Maximum_Eligible_Management_Cost__c&quot;,
&quot;errorMessage&quot;: &quot;You cannot request more than the Maximum Management Cost Allowed&quot;
}</value>
    </values>
    <values>
        <field>Minimum_Value_Configuration__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>Multiple_Table_Query__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>Page_Section__c</field>
        <value xsi:type="xsd:string">Management_Cost_Budget_Breakdown</value>
    </values>
    <values>
        <field>Placeholder__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>Related_To_Object_Name__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>Required__c</field>
        <value xsi:type="xsd:boolean">true</value>
    </values>
    <values>
        <field>Search_Class_Name__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>Sequence__c</field>
        <value xsi:type="xsd:double">75.0</value>
    </values>
    <values>
        <field>Static_Content__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>Table_Additional_Config__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>Table_Columns__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>Table_Name__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>Table_Object__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>Table_Parent_Relationship_Field_API__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>Table_Record_Limit__c</field>
        <value xsi:type="xsd:string">5</value>
    </values>
    <values>
        <field>Table_Where_Clause__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>User_Defined_Picklist_Values__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>Validation_Error_Message__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>Validation_Pattern__c</field>
        <value xsi:nil="true"/>
    </values>
</CustomMetadata>
