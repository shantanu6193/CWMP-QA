/**
 * Created by harsh on 09-03-2021.
 */


public without sharing class FlowSendEmail implements Process.Plugin{


    public Process.PluginDescribeResult describe() {
        Process.PluginDescribeResult result = new Process.PluginDescribeResult();
        result.Name = 'Send Email';
        result.Tag = 'FlowSendEmail Classes';
        result.inputParameters = new
                List<Process.PluginDescribeResult.InputParameter> {
                new Process.PluginDescribeResult.InputParameter('targetObjectId',
                        Process.PluginDescribeResult.ParameterType.STRING, false),
                new Process.PluginDescribeResult.InputParameter('emailTemplateId',
                        Process.PluginDescribeResult.ParameterType.STRING, true),
                new Process.PluginDescribeResult.InputParameter('whatId',
                        Process.PluginDescribeResult.ParameterType.STRING, false),
                new Process.PluginDescribeResult.InputParameter('orgWideAddressId',
                        Process.PluginDescribeResult.ParameterType.STRING, false)

        };
/*        result.outputParameters = new
                List<Process.PluginDescribeResult.OutputParameter>{
                new Process.PluginDescribeResult.OutputParameter('accountId',
                        Process.PluginDescribeResult.ParameterType.STRING)

        };*/
        return result;
    }

    public Process.PluginResult invoke(Process.PluginRequest request) {
        String targetObjectId = (String) request.inputParameters.get('targetObjectId');
        String emailTemplateId = (String) request.inputParameters.get('emailTemplateId');
        String whatId = (String) request.inputParameters.get('whatId');
        String orgWideAddressId = (String) request.inputParameters.get('orgWideAddressId');

        System.debug('Used details: '+UserInfo.getName());


        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        if(String.isNotEmpty(targetObjectId)){
            mail.setTargetObjectId(targetObjectId);
        }
        if(String.isNotEmpty(whatId)){
            mail.setWhatId(whatId);
        }
        if(String.isNotEmpty(orgWideAddressId)){
            mail.setOrgWideEmailAddressId(orgWideAddressId);
        }

        mail.setTemplateId(emailTemplateId);
        if(String.isNotEmpty(targetObjectId) && String.isNotEmpty(emailTemplateId)) {
        	Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });    
        }

        Map<String,Object> result = new Map<String,Object>();
        return new Process.PluginResult(result);
    }

}