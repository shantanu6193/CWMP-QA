/***********************************************************************************************************************************
* Class Name   : ProgressBarWithSubStepsDesignCtrl
* Description  : This class for get dynamic picklist values
* Author       : Pankaj
* Created On   : 04/21/2020
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Pankaj              04/21/2020      Initial Implementation
**************************************************************************************************************************************/

global class ProgressBarWithSubStepsDesignCtrl extends VisualEditor.DynamicPickList {
    VisualEditor.DesignTimePageContext context;

    global ProgressBarWithSubStepsDesignCtrl(VisualEditor.DesignTimePageContext context) {
        this.context = context;
    }

    /***********************************************
    * Method Name : getDefaultValue
    * Author : Pankaj
    * Inputs : -
    * Description: This method return default value of picklist
    *********************************************/
    global override VisualEditor.DataRow getDefaultValue() {
        VisualEditor.DataRow defaultValue = new VisualEditor.DataRow('--Select--', '');
        return defaultValue;
    }

    /***********************************************
    * Method Name : getValues
    * Author : Pankaj
    * Inputs : -
    * Description: This method return dynamic picklist rows
    *********************************************/
    global override VisualEditor.DynamicPickListRows getValues() {
        VisualEditor.DynamicPickListRows values = new VisualEditor.DynamicPickListRows();
        String objectname = context.entityName;

        List<Map<String,String>> picklistFields = SkyWalkerUtility.getSObjectPickListFields(objectname);

        for(Map<String,String> pickListField : picklistFields){
            VisualEditor.DataRow value = new VisualEditor.DataRow(pickListField.get('Label'), pickListField.get('Value'));
            values.addRow(value);
        }
        /*VisualEditor.DataRow value = new VisualEditor.DataRow(objectname,'Value');
        values.addRow(value);*/
        return values;
    }
}