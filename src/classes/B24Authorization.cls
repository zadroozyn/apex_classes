public class B24Authorization {


    private B24_Integration__c authCredentials;
    private Organization thisInstance;
    private HttpRequestBuilder tokenRequestBuilder;
    @testVisible private Token tokenObj;

    public class AuthorizationException extends Exception {}  

    public B24Authorization() {
        getInstanceCredentials();
    }

    private void getInstanceCredentials() {
        thisInstance = [SELECT Id, Name, IsSandbox from Organization];
        String instanceName = thisInstance.IsSandbox ? (String) thisInstance.Id : 'Production';
        System.debug(B24_Integration__c.getAll());
        authCredentials = B24_Integration__c.getInstance(instanceName);
        if(authCredentials == null) {
            authCredentials = B24_Integration__c.getInstance(instanceName.left(15));
        }
        if(authCredentials == null) {
            throw new AuthorizationException(B24MessageFetch.class.getName()+', No authorization credentials for this instance: '+instanceName);
        }
    }

    public Boolean isValid() {
        return tokenObj != null && tokenObj.expires > System.now().addSeconds(60);
    }

    public String getAuthHeader() {
        return tokenObj.token_type + ' ' + tokenObj.access_token;
    }

    public String getEndpointKey() {
        return authCredentials.Endpoint_Key__c;
    }

    public String authorize() {
        HttpRequestBuilder tokenRequestBuilder = 
            new HttpRequestBuilder('https://portal.btwentyfour.com/token','POST');
        tokenRequestBuilder.setHeader('Cache-Control', 'no-cache');
        tokenRequestBuilder.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        String body = 'grant_type=password&username='+getUsername()+'&password='+getPassword();
        tokenRequestBuilder.setBody(body);
        HttpResponse tokenResponse = tokenRequestBuilder.sendRequest();
        if(tokenResponse.getStatusCode()<200 || tokenResponse.getStatusCode()>299 || String.isBlank(tokenResponse.getBody())) {
            throw new AuthorizationException('Authorization failed, response: ' + tokenResponse.getStatusCode() + ' ' + tokenResponse.getBody());
        }
        System.debug(tokenResponse.getBody());
        tokenObj = new Token( tokenResponse.getBody() );
        return getAuthHeader();
    }

    private String getUsername() {
        return authCredentials.Username__c;
    }

    private String getPassword() {
        return authCredentials.Password__c;
    }

    @testVisible private class Token {
        public String access_token;
        public String token_type;
        public Integer expires_in;
        public String userName;
        public String issued;
        public DateTime expires;

        public Token(String jsonToken) {
            Map<String, Object> mapTokenFields = (Map<String, Object>) JSON.deserializeUntyped(jsonToken);
            access_token = (String) mapTokenFields.get('access_token');
            token_type = (String) mapTokenFields.get('token_type');
            expires_in = Integer.valueOf(mapTokenFields.get('expires_in'));
            userName = (String) mapTokenFields.get('userName');
            issued = (String) mapTokenFields.get('.issued');
            expires = System.now().addSeconds(this.expires_in);
        }
    }
}