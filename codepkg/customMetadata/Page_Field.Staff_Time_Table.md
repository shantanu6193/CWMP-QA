<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>Staff Time Table</label>
    <protected>false</protected>
    <values>
        <field>Active__c</field>
        <value xsi:type="xsd:boolean">true</value>
    </values>
    <values>
        <field>Channel_Event_Config__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>Channel_Event_Name__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>Column_Size__c</field>
        <value xsi:type="xsd:string">1</value>
    </values>
    <values>
        <field>Controller_Field__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>Display_Label__c</field>
        <value xsi:nil="true"/>
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
        <value xsi:type="xsd:boolean">false</value>
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
        <value xsi:type="xsd:boolean">false</value>
    </values>
    <values>
        <field>Enabled_Minimum_Value__c</field>
        <value xsi:type="xsd:boolean">false</value>
    </values>
    <values>
        <field>Field_API_Name__c</field>
        <value xsi:nil="true"/>
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
        <value xsi:type="xsd:string">Table</value>
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
        <value xsi:type="xsd:boolean">false</value>
    </values>
    <values>
        <field>Max_Length__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>Maximum_Value_Configuration__c</field>
        <value xsi:nil="true"/>
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
        <value xsi:type="xsd:boolean">false</value>
    </values>
    <values>
        <field>Search_Class_Name__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>Sequence__c</field>
        <value xsi:type="xsd:double">20.0</value>
    </values>
    <values>
        <field>Static_Content__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>Table_Additional_Config__c</field>
        <value xsi:type="xsd:string">{
	&quot;summaryRow&quot;: true,
	&quot;summaryRowType&quot;: &quot;dynamic&quot;,
	&quot;columnSummaryFields&quot;: [{
		&quot;Type&quot;: &quot;formula&quot;,
		&quot;operator&quot;: &quot;Sum&quot;,
		&quot;formulaFields&quot;: &quot;Cost_Estimate_Total__c&quot;
	}],
	&quot;NewAction&quot;: true,
	&quot;NewActionLabel&quot;: &quot;Add Line Item&quot;,
	&quot;NewActionLocation&quot;: &quot;Top&quot;,
	&quot;isTableEditMode&quot;: true,
	&quot;ParentAPIName&quot;: &quot;Project_Cost__c&quot;,
	&quot;GetParentRecord&quot;: &quot;SELECT Id from Project_Cost__c WHERE Project_Budget__r.Application__c = &apos;{recordId}&apos; AND Type__c =&apos;Staff Time&apos; LIMIT 1&quot;,
	&quot;isMessageChannelEnabled&quot;: true,
	&quot;messageChannelName&quot;: [&quot;TotalManagementCostCalculation&quot;],
	&quot;messageChannelConfig&quot;: {
		&quot;Cost_Estimate_Total__c&quot;: {
			&quot;messageChannelType&quot;: &quot;sum&quot;,
			&quot;messageChannelValueAssignedToParentFieldAPI&quot;: &quot;Total_Management_Cost_Requested__c&quot;
		}
	}
}</value>
    </values>
    <values>
        <field>Table_Columns__c</field>
        <value xsi:type="xsd:string">[{
		&quot;label&quot;: &quot;Position&quot;,
		&quot;fieldName&quot;: &quot;Position__c&quot;,
		&quot;required&quot;: true
	},
	{
		&quot;label&quot;: &quot;Hourly Rate&quot;,
		&quot;fieldName&quot;: &quot;Hourly_Rate__c&quot;,
		&quot;required&quot;: true
	},
	{
		&quot;label&quot;: &quot;Hours&quot;,
		&quot;fieldName&quot;: &quot;Hours__c&quot;,
		&quot;required&quot;: true
	},
	{
		&quot;label&quot;: &quot;Amount&quot;,
		&quot;fieldName&quot;: &quot;Cost_Estimate_Total__c&quot;,
		&quot;readOnly&quot;: true,
		&quot;required&quot;: true,
		&quot;formulaFields&quot;: &quot;Hourly_Rate__c,Hours__c&quot;,
		&quot;operator&quot;: &quot;multiplication&quot;
	},
	{
		&quot;label&quot;: &quot;Description&quot;,
		&quot;fieldName&quot;: &quot;Cost_Estimate_Narra__c&quot;,
		&quot;required&quot;: true
	},
	{
		&quot;label&quot;: &quot;Action&quot;,
		&quot;actionList&quot;: &quot;delete&quot;
	}
]</value>
    </values>
    <values>
        <field>Table_Name__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>Table_Object__c</field>
        <value xsi:type="xsd:string">Project_Cost_Line_Item__c</value>
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
        <value xsi:type="xsd:string">Project_Cost__r.Project_Budget__r.Application__c=&apos;{recordId}&apos; AND Project_Cost__r.RecordType.Name=&apos;Management Cost&apos; AND  Project_Cost__r.Type__c=&apos;Staff Time&apos;</value>
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
