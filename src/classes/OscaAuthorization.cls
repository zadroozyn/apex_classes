public class OscaAuthorization {
	private OSCA_credentials__c authCredentials;
    private Organization thisInstance;
    private String authEncoded;

    public class AuthorizationException extends Exception {}  

    public OscaAuthorization() {
        getInstanceCredentials();
    }

    private void getInstanceCredentials() {
        thisInstance = [SELECT Id, Name, IsSandbox from Organization];
        String instanceName = thisInstance.IsSandbox ? (String) thisInstance.Id : 'Production';
        authCredentials = OSCA_credentials__c.getInstance(instanceName);
        if(authCredentials == null) {
            authCredentials = OSCA_credentials__c.getInstance(instanceName.left(15));
        }
        if(authCredentials == null) {
            throw new AuthorizationException(OscaAuthorization.class.getName()+', No authorization credentials for this instance: '+instanceName);
        }

        authEncoded = 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(authCredentials.Username__c + ':' + authCredentials.Password__c));
    }

    public String getAuthHeader() {
        return authEncoded;
    }

    public String getEndpointBase() {
    	return authCredentials.Interface_URL__c;
    }
}