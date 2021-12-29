public with sharing class IntegrationHelper {
    public IntegrationHelper() {

    }
    
    public static Integration_Config__mdt getConfig(String configName) {
        List<Integration_Config__mdt> integrationConfigs = [
                SELECT
                        Auth_Base_URL__c,
                        Auth_Type__c,
                        Base_URL__c,
                        DeveloperName,
                        Id,
                        Integration_Key__c,
                        Label,
                        Language,
                        MasterLabel,
                        NamespacePrefix,
                        Password__c,
                        QualifiedApiName,
                        User_Id__c,
                        User_Name__c,
                        algo__c,
                        aud__c,
                        pkcs8__c,
                        Public_Key__c,
                        Private_Key__c
                FROM Integration_Config__mdt WHERE DeveloperName=:configName];

        if(integrationConfigs.size() == 0)
            throw new CustomExceptionController.CustomMessageException('Config not found');
        return integrationConfigs.get(0);
    }
    public static String getToken(String configName) {
        Integration_Config__mdt config = getConfig(configName);
        if (config.Auth_Type__c == 'Basic') {
            return getTokenUsingBasic(config);
        }
        return null;
    }

    private static String getTokenUsingBasic(Integration_Config__mdt integrationConfig) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        String url = integrationConfig.Auth_Base_URL__c;
        request.setEndpoint(url );
        request.setMethod('POST');

        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');


        request.setBody('grant_type=password&username=' + EncodingUtil.urlEncode(integrationConfig.User_Name__c, 'UTF-8')
        + '&password=' + EncodingUtil.urlEncode(integrationConfig.Password__c, 'UTF-8'));
        HttpResponse response = http.send(request);
        System.debug('body---' + response.getBody());
        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
        return (String)responseMap.get('access_token');
    }
}