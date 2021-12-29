@isTest
private class MARS_FlowGenerateInvoiceCtrl_Test {
    @isTest
    static void flowTaskTest(){
        Account testAccount = MARS_TestHelper.getAccount(true);
        F42__c f42Rec = MARS_TestHelper.getF42(false);
        Incident__c incident = MARS_TestHelper.getIncident(true);
        f42Rec.Incident__c = incident.Id;
        f42Rec.Account__c = testAccount.Id;
        insert f42Rec;
        Invoice__c invoice = new Invoice__c();
        invoice.Account__c = testAccount.Id;
        invoice.Status__c = 'Pending For Local Agency Approval';
        insert invoice;
        /*F_42_Invoices__c child = new F_42_Invoices__c();
        child.F_42__c = f42Rec.Id;
        child.Invoice__c = invoice.Id;
        insert child;*/
        MARS_FlowGenerateInvoiceCtrl plugin = new MARS_FlowGenerateInvoiceCtrl();
        Map<String, Object> inputParams = new Map<String, Object>();
        string invoiceId = invoice.Id;		
        string invtype = 'Regenerate Invoice';
        inputParams.put('InvoiceId', invoiceId);
        inputParams.put('InvoiceType', invtype);
        Process.PluginRequest request = new Process.PluginRequest(inputParams);
        plugin.invoke(request);
        Process.PluginDescribeResult result = plugin.describe();
    }
}