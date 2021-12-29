@isTest public class ProgressBarWithSubStepsDesignCtrlTest {
    
    @isTest public static void testGetDefaultValue(){
        
        VisualEditor.DesignTimePageContext context =  new VisualEditor.DesignTimePageContext();
        ProgressBarWithSubStepsDesignCtrl newObj = new ProgressBarWithSubStepsDesignCtrl(context);
        
        test.startTest();
        VisualEditor.DataRow getval = newObj.getDefaultValue();
        test.stopTest();
    }
        
    
    @isTest public static void testGetValues(){
        
        VisualEditor.DesignTimePageContext context =  new VisualEditor.DesignTimePageContext();
        context.entityName = 'Account';
        ProgressBarWithSubStepsDesignCtrl newObj = new ProgressBarWithSubStepsDesignCtrl(context);
        
        test.startTest();
        VisualEditor.DynamicPickListRows getval = newObj.getValues();
        test.stopTest();
        
    }
    
    
    
}