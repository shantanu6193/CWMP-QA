<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>FEMA Request For Information</label>
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
        <value xsi:type="xsd:string">{
&quot;AttributeKey&quot;: &quot;role&quot;,
&quot;AttributeValue&quot;: &quot;FEMA EHP Analyst,FEMA Programmatic Analyst,FEMA Viewer&quot;,
&quot;operation&quot;: &quot;NotIN&quot;
}</value>
    </values>
    <values>
        <field>Hide_Field_Operator__c</field>
        <value xsi:nil="true"/>
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
        <value xsi:type="xsd:string">Request_For_Information</value>
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
        <value xsi:type="xsd:double">110.0</value>
    </values>
    <values>
        <field>Static_Content__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>Table_Additional_Config__c</field>
        <value xsi:type="xsd:string">{
&quot;NewAction&quot;:true,
&quot;NewActionLabel&quot;: &quot;Add Request for Information&quot;,
&quot;NewActionLocation&quot;: &quot;Top&quot;,
	&quot;isTableEditMode&quot;: false,
	&quot;ParentAPIName&quot;: &quot;Application__c&quot;,
	&quot;GetParentRecord&quot;: &quot;SELECT Id from Request_For_Information__c WHERE Application__c= &apos;{recordId}&apos; LIMIT 1&quot;,
	&quot;NewActionType&quot;: &quot;Modal&quot;,
	&quot;ModalName&quot;: &quot;FEMA RFI Modal&quot;,
	&quot;EditActionType&quot;: &quot;Modal&quot;,
	&quot;checkTableActionAccess&quot;: true,
	&quot;TableActionAccessClass&quot;: &quot;HMA_SubApplicationRole&quot;
}</value>
    </values>
    <values>
        <field>Table_Columns__c</field>
        <value xsi:type="xsd:string">[
        {
                &quot;label&quot;:&quot;RFI Name&quot;,
                &quot;fieldName&quot;:&quot;Name&quot;,
                &quot;required&quot;:false,
                &quot;readOnly&quot;:false
        },
        {
                &quot;label&quot;:&quot;RFI Type&quot;,
                &quot;fieldName&quot;:&quot;RFI_Type__c&quot;,
                &quot;required&quot;:false,
                &quot;readOnly&quot;:false
        },
        {
                &quot;label&quot;:&quot;Description&quot;,
                &quot;fieldName&quot;:&quot;Description__c&quot;,
                &quot;required&quot;:false,
                &quot;readOnly&quot;:false
        },
        {
		&quot;label&quot;: &quot;RFI Deadline&quot;,
		&quot;fieldName&quot;: &quot;RFI_Deadline__c&quot;,
		&quot;required&quot;: false,
		&quot;readOnly&quot;: false

	},
        {
                &quot;label&quot;:&quot;Status&quot;,
                &quot;fieldName&quot;:&quot;Status__c&quot;,
                &quot;required&quot;:false,
                &quot;readOnly&quot;:false
        },
	{
		&quot;label&quot;: &quot;Action&quot;,
		&quot;actionList&quot;: &quot;Edit,Delete&quot;
	}
]</value>
    </values>
    <values>
        <field>Table_Name__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>Table_Object__c</field>
        <value xsi:type="xsd:string">Request_For_Information__c</value>
    </values>
    <values>
        <field>Table_Parent_Relationship_Field_API__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>Table_Record_Limit__c</field>
        <value xsi:type="xsd:string">20</value>
    </values>
    <values>
        <field>Table_Where_Clause__c</field>
        <value xsi:type="xsd:string">Application__c=&apos;{recordId}&apos; AND RFI_Type__c  IN( &apos;FEMA OES Programmatic&apos;,  &apos;FEMA OES EHP&apos;) ORDER BY Name</value>
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
