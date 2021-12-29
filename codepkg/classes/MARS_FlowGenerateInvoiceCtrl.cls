/**
 * Created by Chandrabhan on 28-06-2021.
 */

public without sharing class MARS_FlowGenerateInvoiceCtrl implements Process.Plugin {
    public Process.PluginDescribeResult describe() {
        Process.PluginDescribeResult result = new Process.PluginDescribeResult();
        result.Name = 'Generate Invoice';
        result.Tag = 'MARS_FlowGenerateInvoiceCtrl Classes';
        result.inputParameters = new List<Process.PluginDescribeResult.InputParameter> {
                new Process.PluginDescribeResult.InputParameter('InvoiceId',
                        Process.PluginDescribeResult.ParameterType.STRING, true),
                new Process.PluginDescribeResult.InputParameter('InvoiceType',
                        Process.PluginDescribeResult.ParameterType.STRING, true)

        };
        result.outputParameters = new List<Process.PluginDescribeResult.OutputParameter> {
            new Process.PluginDescribeResult.OutputParameter('NewInvoiceId', 
                Process.PluginDescribeResult.ParameterType.STRING)
        };    
        return result;
    }

    public Process.PluginResult invoke(Process.PluginRequest request) {
        Map<String,Object> result = new Map<String,Object>();
        String invoiceId = (String) request.inputParameters.get('InvoiceId');
        String invoiceType = (String) request.inputParameters.get('InvoiceType');
        List<String> invoiceIds = new List<String>();
        List<String> f42Ids = new List<String>();
        List<String> expenseClaims = new List<String>();  
        List<Invoice__c> invoiceList = [SELECT Account__c,Incident__c,Funding_Rule__c FROM Invoice__c WHERE Id =: invoiceId];
        List<F_42_Invoices__c> f42List =  [SELECT Id, F_42__c, Expense_Claim__c FROM F_42_Invoices__c WHERE Invoice__c =: invoiceId];
        if(invoiceList.size() > 0  && f42List.size() > 0) {
            for(F_42_Invoices__c f42Record : f42List) {
                if(f42Record.F_42__c != null) {
                    f42Ids.add(f42Record.F_42__c);
                } else if(f42Record.Expense_Claim__c != null) {
                    expenseClaims.add(f42Record.Expense_Claim__c);
                }
         }
        invoiceIds = MARSInvoiceHelper.createInvoiceStaging(invoiceList[0].Incident__c, invoiceList[0].Account__c, f42Ids, invoiceList[0].Funding_Rule__c, invoiceId, invoiceType, expenseClaims);
        result.put('NewInvoiceId',invoiceIds.get(0));
    }
        return new Process.PluginResult(result);
    }
}