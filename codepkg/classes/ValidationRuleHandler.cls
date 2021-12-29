public inherited sharing class ValidationRuleHandler {
    private List<Validation_Rule_Config__mdt> validationRules;
    public ValidationRuleHandler(String sobjectName) {
        validationRules = MetadataUtility.getValidationRules(sobjectName);
    }


    private void processValidationRules() {
        //if(validationRuleConfig != null && validationRuleCon)
    }

    public Boolean validateRecords(Account records) {
        Boolean flag = true;
        //flag = flag && phoneValidation(records);
        return flag;
    }

    // private Boolean phoneValidation(Account acc) {
    //     if(validationRuleMdt != null && validationRuleMdt.label=='Phone Length = 10' && validationRuleMdt.Is_Active__c) {
    //         if(String.valueOf(acc.phone).length()!=10) {
    //             acc.addError('Phone Number should be of 10 digits only');
    //             return false;
    //         }
    //     }
    //     return true;
    // }
}