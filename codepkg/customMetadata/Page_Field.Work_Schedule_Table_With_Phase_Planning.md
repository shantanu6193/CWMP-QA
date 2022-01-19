<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>Work Schedule Table With Phase Planning</label>
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
        <value xsi:type="xsd:string">Work_Schedule_With_Phase_Column_Planning</value>
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
        <value xsi:type="xsd:double">10.0</value>
    </values>
    <values>
        <field>Static_Content__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>Table_Additional_Config__c</field>
        <value xsi:type="xsd:string">{
	&quot;summaryRow&quot;: true,
&quot;summaryRowType&quot;: &quot;static&quot;,
	&quot;isTableEditMode&quot;: true,
	&quot;NewAction&quot;: false,
	&quot;NewActionLabel&quot;: &quot;&quot;,
	&quot;NewActionLocation&quot;: &quot;&quot;,
	&quot;ParentAPIName&quot;: &quot;Work_Schedule__c&quot;,
	&quot;GetParentRecord&quot;: &quot;SELECT Id from Work_Schedule__c WHERE Application__c = &apos;{recordId}&apos; LIMIT 1&quot;,
	&quot;summaryFields&quot;: [{
		&quot;Type&quot;: &quot;Formula&quot;,
		&quot;operator&quot;: &quot;Sum&quot;,
		&quot;formulaFields&quot;: &quot;Start_Month__c,Duration_Months__c&quot;,
		&quot;value&quot;: &quot;Max&quot;,
		&quot;parentFieldAPIName&quot;: &quot;parentFieldAPIName__c&quot;,
		&quot;parentFieldLabel&quot;: &quot;Total Duration&quot;,
		&quot;parentFieldHelpText&quot;: &quot;&quot;
	}]
}</value>
    </values>
    <values>
        <field>Table_Columns__c</field>
        <value xsi:type="xsd:string">[
	{
		&quot;label&quot;:&quot;Phase&quot;,
		&quot;fieldName&quot;:&quot;Planning_Phase__c&quot;,
		&quot;required&quot;:&quot;true&quot;,
		&quot;readOnly&quot;:&quot;true&quot;,
		&quot;summaryValue&quot;: &quot;Closeout&quot;
	},
	{
		&quot;label&quot;:&quot;Task Name&quot;,
		&quot;fieldName&quot;:&quot;Task_Name__c&quot;,
		&quot;required&quot;:&quot;true&quot;,
		&quot;summaryValue&quot;: &quot;Closeout&quot;
	},
	{
		&quot;label&quot;:&quot;Description&quot;,
		&quot;fieldName&quot;:&quot;Description__c&quot;,
		&quot;required&quot;:&quot;true&quot;,
		&quot;summaryValue&quot;: &quot;Project Closeout line item&quot;
	}, 
	{
		&quot;label&quot;:&quot;Start Month&quot;,
		&quot;fieldName&quot;:&quot;Start_Month__c&quot;,
		&quot;required&quot;:&quot;true&quot;,
		&quot;summaryValue&quot;: &quot;&quot;
	},
	{
		&quot;label&quot;:&quot;Duration (Months)&quot;,
		&quot;fieldName&quot;:&quot;Duration_Months__c&quot;,
		&quot;required&quot;:&quot;true&quot;,
		&quot;summaryValue&quot;: &quot;3&quot;
	}
]</value>
    </values>
    <values>
        <field>Table_Name__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>Table_Object__c</field>
        <value xsi:type="xsd:string">Work_Schedule_Line_Item__c</value>
    </values>
    <values>
        <field>Table_Parent_Relationship_Field_API__c</field>
        <value xsi:type="xsd:string">Work_Schedule__r.Application__c</value>
    </values>
    <values>
        <field>Table_Record_Limit__c</field>
        <value xsi:type="xsd:string">10</value>
    </values>
    <values>
        <field>Table_Where_Clause__c</field>
        <value xsi:type="xsd:string">Work_Schedule__r.Application__c=&apos;{recordId}&apos;</value>
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
