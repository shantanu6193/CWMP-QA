public with sharing class JWTBearer {
    public static String getAccessToken(String tokenEndpoint, JWT jwt) {

        String access_token = null;
        String jwtToken = jwt.issue();
        String body = 'grant_type=urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Ajwt-bearer&assertion=' + jwtToken;
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint(tokenEndpoint + '?' + body);
        req.setHeader('Content-type', 'application/x-www-form-urlencoded');
        req.setHeader('grant_type', 'urn:ietf:params:oauth:grant-type:jwt-bearer');
        req.setHeader('assertion', jwtToken);

        req.setBody(body);
        Http http = new Http();
        HTTPResponse res = http.send(req);
        System.debug(res.getBody());

        if ( res.getStatusCode() == 200 ) {
            System.JSONParser parser = System.JSON.createParser(res.getBody());
            while (parser.nextToken() != null) {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'access_token')) {
                    parser.nextToken();
                    access_token = parser.getText();
                    break;
                }
            }
        }
        return access_token;

    }
}