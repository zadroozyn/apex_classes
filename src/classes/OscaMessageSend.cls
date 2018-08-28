public class OscaMessageSend {

	public class UnauthorizedException extends Exception {}
	public class ResponseException extends Exception {}
	public class MissingDependeciesException extends Exception {}

	private OscaAuthorization oscaAuth;

	public OscaMessageSend() {
		this(new OscaAuthorization());
	}

	public OscaMessageSend(OscaAuthorization oscaAuth) {
		this.oscaAuth = oscaAuth;
	}

	public OscaResponse sendMessage(String endpoint, String message) {
		HttpRequestBuilder reqBuilder = new HttpRequestBuilder(oscaAuth.getEndpointBase() + endpoint, 'POST');
		reqBuilder.setHeader('Authorization', oscaAuth.getAuthHeader());
		reqBuilder.setHeader('Content-Type', 'application/json');
		reqBuilder.setHeader('Accept', 'text/plain');
		reqBuilder.setBody(message);
		HttpResponse res = reqBuilder.sendRequest();
		if(res.getStatusCode() == 200) {
			System.debug('OscaMessageSend response received');
			String resWithoutIlligalChars = res.getBody().replaceAll('\n',' ').replaceAll('\r',' ');
			System.debug(resWithoutIlligalChars);
			return (OscaResponse) JSON.deserialize(resWithoutIlligalChars, OscaResponse.class);
		} else if(res.getStatusCode() == 401) {
			throw new UnauthorizedException();
		} else if(res.getStatusCode() == 424) {
			throw new MissingDependeciesException();
		} else {
			throw new ResponseException('Code: '+res.getStatusCode());
		}
	}

	public class OscaResponse {
		public List<OscaLineResponse> successes;
		public List<OscaLineResponse> failures;
	}

	public class OscaLineResponse {
		public Id objId;
		public String cause;
	}
}